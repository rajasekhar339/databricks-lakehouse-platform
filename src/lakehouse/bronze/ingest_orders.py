from pyspark.sql import DataFrame
from pyspark.sql import functions as F

from lakehouse.common.runtime import get_spark, parse_args


def add_ingestion_metadata(df: DataFrame) -> DataFrame:
    return df.withColumn("_ingested_at", F.current_timestamp()).withColumn(
        "_source_file", F.col("_metadata.file_path")
    )


def main(argv=None):
    ctx = parse_args(argv)
    spark = get_spark()

    source = ctx.volume_path("bronze", "landing", "orders")
    checkpoint = ctx.volume_path("bronze", "checkpoints", "orders_raw")

    stream = (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", checkpoint)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(source)
        .select("*", "_metadata")
    )

    # availableNow = process whatever is new, then stop (batch-style scheduling)
    (
        add_ingestion_metadata(stream)
        .drop("_metadata")
        .writeStream.option("checkpointLocation", checkpoint)
        .option("mergeSchema", "true")
        .trigger(availableNow=True)
        .toTable(ctx.table("bronze", "orders_raw"))
        .awaitTermination()
    )


if __name__ == "__main__":
    main()
