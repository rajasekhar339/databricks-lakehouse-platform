-- fails the task if gold looks wrong
SELECT
  CASE
    WHEN COUNT(*) = 0 THEN RAISE_ERROR('gold.daily_sales is empty')
    WHEN COUNT_IF(revenue < 0) > 0 THEN RAISE_ERROR('negative revenue in gold.daily_sales')
    WHEN COUNT(*) <> COUNT(DISTINCT order_date) THEN RAISE_ERROR('duplicate order_date in gold.daily_sales')
    ELSE 'ok'
  END AS result
FROM IDENTIFIER(:catalog || '.gold.daily_sales');
