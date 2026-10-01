from datetime import date
from decimal import Decimal

from lakehouse.gold.daily_sales import daily_sales


def test_aggregates_per_day_and_excludes_cancelled(spark):
    orders = spark.createDataFrame(
        [
            ("o1", "c1", "PLACED", Decimal("10.00"), date(2026, 9, 1)),
            ("o2", "c2", "SHIPPED", Decimal("30.00"), date(2026, 9, 1)),
            ("o3", "c1", "CANCELLED", Decimal("99.00"), date(2026, 9, 1)),
            ("o4", "c1", "DELIVERED", Decimal("5.00"), date(2026, 9, 2)),
        ],
        "order_id string, customer_id string, status string, amount decimal(18,2), order_date date",
    )
    result = {r.order_date: r for r in daily_sales(orders).collect()}

    assert result[date(2026, 9, 1)].orders == 2
    assert result[date(2026, 9, 1)].customers == 2
    assert result[date(2026, 9, 1)].revenue == Decimal("40.00")
    assert float(result[date(2026, 9, 1)].avg_order_value) == 20.0
    assert result[date(2026, 9, 2)].orders == 1
