/*
  CUMULATIVE PRODUCT REVENUE SHARE
  ==============================================================================
  Calculates each product's sales contribution and running total percentage.
  Outputs ranked products from highest to lowest sales.
  Metrics include:
  - Product Total Sales
  - Percent Share of Global Sales
  - Cumulative Percent Share
  ==============================================================================
*/

WITH product_revenue AS
(
    -- adds up total sales for each product
    SELECT
        stock_code,
        description,
        SUM(revenue) AS total_revenue
    FROM 'valid_product_sales.csv'
    GROUP BY
        stock_code,
        description
),

with_global_total AS
(
    -- adds total sales of all products combined to every row
    SELECT
        stock_code,
        description,
        total_revenue,
        SUM(total_revenue) OVER () AS global_revenue
    FROM product_revenue
),

with_pct_share AS
(
    -- calculates what percent of total sales comes from each product
    SELECT
        stock_code,
        description,
        total_revenue,
        (total_revenue / NULLIF(global_revenue, 0)) * 100.0 AS pct_share
    FROM with_global_total
)
    -- ranks products from highest to lowest sales and keeps a running total percent
SELECT
    stock_code,
    description,
    ROUND(total_revenue, 2) AS total_revenue,
    pct_share,
    ROUND(SUM(pct_share) OVER (ORDER BY pct_share DESC), 2) AS cumulative_pct_share
FROM with_pct_share
ORDER BY
    pct_share DESC
