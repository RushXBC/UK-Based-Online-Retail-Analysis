/*
  MONTHLY SALES METRICS
  ==============================================================================

  Calculates key business metrics at a monthly grain for valid product 
  sales transactions.

  Metrics include:
  - Revenue and units sold
  - Orders and customers
  - Average order value and basket size
  ==============================================================================
*/

WITH sales AS
(
    -- transaction-line grain
    SELECT
        DATE(DATE_TRUNC('month', invoice_date)) AS month_year,
        invoice_id,
        customer_id,
        quantity,
        revenue
    FROM 'valid_product_sales.csv'
),

monthly_orders AS
(
    -- order grain; shared base for AOV and basket size
    SELECT
        month_year,
        invoice_id,
        SUM(revenue)  AS order_revenue,
        SUM(quantity) AS order_quantity
    FROM sales
    GROUP BY
        month_year,
        invoice_id
),

monthly_metrics AS
(
    -- month grain
    SELECT
        month_year,
        SUM(order_revenue)  AS revenue,
        COUNT(invoice_id)   AS orders,
        AVG(order_revenue)  AS average_order_value,
        SUM(order_quantity) AS units_sold,
        AVG(order_quantity) AS average_basket_size
    FROM monthly_orders
    GROUP BY
        month_year
),

monthly_customers AS
(
    -- distinct customers need transaction-line grain, not order grain
    SELECT
        month_year,
        COUNT(DISTINCT customer_id) AS customers
    FROM sales
    GROUP BY
        month_year
)

SELECT
    m.month_year,
    ROUND(m.revenue, 2)             AS revenue,
    m.orders,
    c.customers,
    m.units_sold,
    ROUND(m.average_order_value, 2) AS average_order_value,
    ROUND(m.average_basket_size)    AS average_basket_size
FROM monthly_metrics AS m
LEFT JOIN monthly_customers AS c
    ON m.month_year = c.month_year
ORDER BY
    m.month_year;