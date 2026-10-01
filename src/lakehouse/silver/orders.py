from pyspark.sql import DataFrame, SparkSession, Window
from pyspark.sql import functions as F

from lakehouse.common.runtime import get_spark, parse_args

VALID_STATUSES = ["PLACED", "SHIPPED", "DELIVERED", "CANCELLED"]


def clean_orders(raw: DataFrame) -> DataFrame:
    typed = raw.select(
        F.col("order_id").cast("string"),
        F.col("customer_id").cast("string"),
        F.upper(F.trim(F.col("status"))).alias("status"),
        F.col("amount").cast("decimal(18,2)").alias("amount"),
        F.to_timestamp("order_ts").alias("order_ts"),
        F.col("_ingested_at"),
    )

    valid = typed.where(
        F.col("order_id").isNotNull()
        & F.col("customer_id").isNotNull()
        & (F.col("amount") >= 0)
        & F.col("status").isin(VALID_STATUSES)
    )

    # keep only the latest version of each order
    w = Window.partitionBy("order_id").orderBy(F.col("_ingested_at").desc())
    return (
        valid.withColumn("_rn", F.row_number().over(w))
        .where("_rn = 1")
        .drop("_rn")
        .withColumn("order_date", F.to_date("order_ts"))
    )


def upsert(spark: SparkSession, df: DataFrame, target: str):
    if not spark.catalog.tableExists(target):
        df.write.saveAsTable(target)
        return
    df.createOrReplaceTempView("updates")
    spark.sql(f"""
        MERGE INTO {target} t
        USING updates s
        ON t.order_id = s.order_id
        WHEN MATCHED AND s._ingested_at > t._ingested_at THEN UPDATE SET *
        WHEN NOT MATCHED THEN INSERT *
    """)


def main(argv=None):
    ctx = parse_args(argv)
    spark = get_spark()
    raw = spark.read.table(ctx.table("bronze", "orders_raw"))
    upsert(spark, clean_orders(raw), ctx.table("silver", "orders"))


if __name__ == "__main__":
    main()
