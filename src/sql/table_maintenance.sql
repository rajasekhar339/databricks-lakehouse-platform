OPTIMIZE IDENTIFIER(:catalog || '.silver.orders') ZORDER BY (order_date);
VACUUM IDENTIFIER(:catalog || '.silver.orders') RETAIN 168 HOURS;
OPTIMIZE IDENTIFIER(:catalog || '.gold.daily_sales');
VACUUM IDENTIFIER(:catalog || '.gold.daily_sales') RETAIN 168 HOURS;
