import argparse
from dataclasses import dataclass

from pyspark.sql import SparkSession

# same scope name in every workspace, backed by that env's key vault
SECRET_SCOPE = "kv-lakehouse"


@dataclass(frozen=True)
class JobContext:
    catalog: str

    def table(self, layer: str, name: str) -> str:
        return f"{self.catalog}.{layer}.{name}"

    def volume_path(self, layer: str, volume: str, *parts: str) -> str:
        return "/".join([f"/Volumes/{self.catalog}/{layer}/{volume}", *parts])


def parse_args(argv=None) -> JobContext:
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog", required=True)
    args, _ = parser.parse_known_args(argv)
    return JobContext(catalog=args.catalog)


def get_spark() -> SparkSession:
    return SparkSession.builder.getOrCreate()


def get_secret(spark: SparkSession, key: str) -> str:
    from pyspark.dbutils import DBUtils

    return DBUtils(spark).secrets.get(scope=SECRET_SCOPE, key=key)
