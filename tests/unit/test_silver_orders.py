from datetime import datetime

from lakehouse.silver.orders import clean_orders

COLUMNS = ["order_id", "customer_id", "status", "amount", "order_ts", "_ingested_at"]


def test_keeps_latest_version_of_each_order(spark):
    raw = spark.createDataFrame(
        [
            ("o1", "c1", "placed", "10.00", "2026-09-01 10:00:00", datetime(2026, 9, 1, 11)),
            ("o1", "c1", "shipped", "10.00", "2026-09-01 10:00:00", datetime(2026, 9, 2, 11)),
        ],
        COLUMNS,
    )
    rows = clean_orders(raw).collect()
    assert len(rows) == 1
    assert rows[0].status == "SHIPPED"


def test_drops_invalid_rows(spark):
    raw = spark.createDataFrame(
        [
            ("o1", "c1", "PLACED", "5.00", "2026-09-01 10:00:00", datetime(2026, 9, 1)),
            (None, "c1", "PLACED", "5.00", "2026-09-01 10:00:00", datetime(2026, 9, 1)),
            ("o3", "c1", "PLACED", "-1.00", "2026-09-01 10:00:00", datetime(2026, 9, 1)),
            ("o4", "c1", "UNKNOWN", "5.00", "2026-09-01 10:00:00", datetime(2026, 9, 1)),
        ],
        COLUMNS,
    )
    assert [r.order_id for r in clean_orders(raw).collect()] == ["o1"]


def test_derives_order_date(spark):
    raw = spark.createDataFrame(
        [("o1", "c1", "PLACED", "5.00", "2026-09-01 23:59:00", datetime(2026, 9, 2))],
        COLUMNS,
    )
    assert str(clean_orders(raw).first().order_date) == "2026-09-01"
