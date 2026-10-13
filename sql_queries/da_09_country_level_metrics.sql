/*
  ==============================================================================
  COUNTRY-LEVEL SALES PERFORMANCE & CONTRIBUTION ANALYSIS
  ==============================================================================
  Aggregates transactional sales data by country to calculate core performance
  metrics (Total Revenue, Transactions, Unique Customers, and AOV) alongside
  each country's percentage contribution to overall global revenue.

  Metrics included:
  - Total Revenue ($)
  - Total Transactions (Distinct Invoices)
  - Total Customers (Distinct Active Accounts)
  - Average Order Value (AOV)
  - Revenue Contribution (%)
  ==============================================================================
*/

-- -----------------------------------------------------------------------------
-- SECTION 1: AGGREGATE REVENUE PER INVOICE (ORDER LEVEL)
-- -----------------------------------------------------------------------------
WITH country_orders AS
(
    SELECT
        country,
        invoice_id,
        customer_id,
        SUM(revenue) AS order_revenue
    FROM 'valid_product_sales.csv'
    WHERE country IS NOT NULL
    GROUP BY
        country,
        invoice_id,
        customer_id
),

-- -----------------------------------------------------------------------------
-- SECTION 2: AGGREGATE CORE KPI METRICS BY COUNTRY
-- -----------------------------------------------------------------------------
country_metrics AS
(
    SELECT
        country,
        SUM(order_revenue) AS total_revenue,
        COUNT(DISTINCT invoice_id) AS total_transactions,
        COUNT(DISTINCT customer_id) AS total_customers,
        AVG(order_revenue) AS average_order_value
    FROM country_orders
    GROUP BY
        country
)

-- -----------------------------------------------------------------------------
-- SECTION 3: FINAL OUTPUT & GLOBAL REVENUE CONTRIBUTION PERCENTAGE
-- -----------------------------------------------------------------------------
SELECT
    country,
    ROUND(total_revenue, 2) AS total_revenue,
    total_transactions,
    total_customers,
    ROUND(average_order_value, 2) AS average_order_value,
    -- Calculates each country's percentage share of all combined country revenues
    ROUND(total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER (), 0), 2) AS revenue_pct_contribution
FROM country_metrics
ORDER BY
    total_revenue DESC;