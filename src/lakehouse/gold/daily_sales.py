from pyspark.sql import DataFrame
from pyspark.sql import functions as F

from lakehouse.common.runtime import get_spark, parse_args


def daily_sales(orders: DataFrame) -> DataFrame:
    return (
        orders.where(F.col("status") != "CANCELLED")
        .groupBy("order_date")
        .agg(
            F.countDistinct("order_id").alias("orders"),
            F.countDistinct("customer_id").alias("customers"),
            F.sum("amount").alias("revenue"),
        )
        .withColumn("avg_order_value", F.round(F.col("revenue") / F.col("orders"), 2))
    )


def main(argv=None):
    ctx = parse_args(argv)
    spark = get_spark()
    orders = spark.read.table(ctx.table("silver", "orders"))
    (
        daily_sales(orders)
        .write.mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(ctx.table("gold", "daily_sales"))
    )


if __name__ == "__main__":
    main()
