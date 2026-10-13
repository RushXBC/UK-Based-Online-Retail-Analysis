/*
  MONTHLY REVENUE GROWTH RATE
  ==============================================================================
  Calculates month-over-month revenue and percent growth for valid product 
  sales transactions.
  Metrics include:
  - Monthly revenue and prior month's revenue
  - Month-over-month percent growth
  ==============================================================================
*/

WITH monthly_revenue_with_previous AS
(
    -- month grain; pairs each month's revenue with the prior month's via LAG
    SELECT
        TRY_CAST(month_year AS DATE) AS month_year,
        revenue,
        LAG(revenue) OVER (ORDER BY month_year) AS previous_revenue
    FROM
    (
        -- transaction-line grain, rolled up to month grain
        SELECT
            DATE_TRUNC('month', invoice_date) AS month_year,
            SUM(revenue) AS revenue
        FROM 'valid_product_sales.csv'
        GROUP BY
            DATE_TRUNC('month', invoice_date)
    ) AS monthly_revenue
),

monthly_pct_growth AS
(
    -- month grain; derives percent growth from current vs. previous revenue
    SELECT
        month_year,
        ROUND(revenue, 2) AS revenue,
        ROUND(previous_revenue, 2) AS previous_revenue,
        ROUND(
            (revenue - previous_revenue)
                / NULLIF(previous_revenue, 0)
                * 100.0,
            2
        ) AS pct_growth
    FROM monthly_revenue_with_previous
)

-- final output: adds a human-readable month label for presentation
SELECT
    month_year,
    STRFTIME(month_year, '%B')
        || ' ' 
        || TRY_CAST(
            EXTRACT(year FROM month_year) AS TEXT
        ) AS month_year_text,
    revenue,
    previous_revenue,
    pct_growth
FROM monthly_pct_growth
ORDER BY
    month_year;