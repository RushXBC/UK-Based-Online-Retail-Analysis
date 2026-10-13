/*
  MONTHLY REVENUE VOLATILITY (Z-SCORE)
  ==============================================================================
  Flags months whose revenue growth deviates significantly from the average
  month-over-month growth rate, using a z-score.
  Metrics include:
  - Percent growth per month
  - Z-score (standard deviations from mean growth)
  - Volatility tier classification
  ==============================================================================
*/

SELECT 
    month_year,
    pct_growth,
    -- how many standard deviations away from the mean each month is
    ABS(ROUND((pct_growth - avg_pct_growth) / stddev_pct_growth, 2)) AS z_score,
    -- buckets each month into a volatility tier based on its z-score
    CASE 
        WHEN ABS((pct_growth - avg_pct_growth) / stddev_pct_growth) > 2.0
            THEN 'Outlier (>2 SD)'
            
        WHEN ABS((pct_growth - avg_pct_growth) / stddev_pct_growth) > 1.0 
            THEN 'Moderate Shift (1-2 SD)'
            
        ELSE 'Normal Range (<=1 SD)'
    END AS volatility_tier
FROM (

-- Subquery recycled from the monthly revenue growth query:
-- recalculates month-over-month percent growth as the base for volatility scoring

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
    -- month grain; percent growth vs. previous month
    SELECT
        month_year,
        ROUND(
            (revenue - previous_revenue)
                / NULLIF(previous_revenue, 0)
                * 100.0,
            2
        ) AS pct_growth
    FROM monthly_revenue_with_previous
)

SELECT
    month_year,
    STRFTIME(month_year, '%B')
        || ' ' 
        || CAST(
            EXTRACT(year FROM month_year) 
            AS TEXT) AS string_month_year,
    pct_growth,
    -- window functions here compute the mean/stddev needed for the z-score above
    AVG(pct_growth) OVER () AS avg_pct_growth,
    STDDEV_POP(pct_growth) OVER () AS stddev_pct_growth
FROM monthly_pct_growth
WHERE pct_growth IS NOT NULL  -- excludes the first month, which has no growth rate
ORDER BY month_year

-- end of recycled query
)
ORDER BY month_year;