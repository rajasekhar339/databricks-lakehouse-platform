from pyspark.sql import functions as F

from lakehouse.common.runtime import get_secret, get_spark, parse_args


def main(argv=None):
    ctx = parse_args(argv)
    spark = get_spark()

    df = (
        spark.read.format("jdbc")
        .option("url", get_secret(spark, "crm-jdbc-url"))
        .option("user", get_secret(spark, "crm-jdbc-user"))
        .option("password", get_secret(spark, "crm-jdbc-password"))
        .option("dbtable", "dbo.customers")
        .load()
        .withColumn("_ingested_at", F.current_timestamp())
    )

    df.write.mode("overwrite").saveAsTable(ctx.table("bronze", "customers_raw"))


if __name__ == "__main__":
    main()
