/*
  PARETO ANALYSIS (80/20 RULE) FOR PRODUCT REVENUE
  ==============================================================================
  Finds the number of top products that make up 80% of total sales.
  This shows how much money comes from a small group of products.
  Metrics include:
  - Total Product Count
  - SKUs Generating 80% Revenue
  - Pareto SKU Share (%)
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
),

with_cumulative_pct_share AS
(
    -- ranks products from highest to lowest sales and keeps a running total percent
    SELECT
        stock_code,
        description,
        total_revenue,
        pct_share,
        SUM(pct_share) OVER (ORDER BY pct_share DESC , stock_code ASC) AS cumulative_pct_share
    FROM with_pct_share
),

flagged AS
(
    -- marks products that belong to the top 80% sales group
    SELECT
        *,
        -- marks a 1 if the product is inside the 80% group or is the item that crosses the 80% mark
        CASE
            WHEN cumulative_pct_share <= 80
                OR COALESCE(LAG(cumulative_pct_share) OVER (ORDER BY pct_share DESC, stock_code ASC), 0) < 80
                THEN 1
            ELSE 0
        END AS product_inclusion_flag
    FROM with_cumulative_pct_share
),

summary_stats AS
(
    -- counts total products and calculates the 80% sales numbers
    SELECT
        COUNT(*) AS total_products,
        SUM(product_inclusion_flag) AS skus_generating_80pct_revenue,
        ROUND(SUM(product_inclusion_flag) * 100.0 / COUNT(*), 2) AS pareto_sku_share_pct
    FROM flagged
)

-- combines all final results into a simple list
SELECT 
    'Total Products' AS metric_name,
    total_products::VARCHAR AS metric_value,
    'Total count of unique product rows evaluated in the sample' AS business_definition
FROM summary_stats

UNION ALL

SELECT 
    'SKUs Generating 80% Revenue' AS metric_name,
    skus_generating_80pct_revenue::VARCHAR AS metric_value,
    'Number of top-performing products required to capture at least 80% of total revenue' AS business_definition
FROM summary_stats

UNION ALL

SELECT 
    'Pareto SKU Share (%)' AS metric_name,
    pareto_sku_share_pct::VARCHAR || '%' AS metric_value,
    'Percentage of product catalog driving 80% of total sales' AS business_definition
FROM summary_stats;