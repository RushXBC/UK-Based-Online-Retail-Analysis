/*
  BASIC BUSINESS KPIs WITH DESCRIPTIONS
  ==============================================================================

  Calculates key business metrics for valid product sales transactions along
  with plain-language definitions for reporting and dashboarding.
  ==============================================================================
*/

WITH KPIs AS
(
    -- Total revenue generated from valid product sales
    SELECT
        'Total Revenue' AS metric,
        SUM(revenue) AS value,
        'Sum of all gross revenue generated from valid product transactions.' AS description
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Total number of product units sold
    SELECT
        'Total Units Sold',
        SUM(quantity),
        'Total count of individual product items purchased across all orders.'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Total number of distinct orders
    SELECT
        'Total Orders',
        COUNT(DISTINCT invoice_id),
        'Count of unique completed transactions or invoice IDs.'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Total number of customers with an identified customer ID
    SELECT
        'Identified Customers',
        COUNT(DISTINCT customer_id),
        'Count of distinct non-null customer accounts with recorded purchases.'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Total number of distinct products sold
    SELECT
        'Unique Products Sold',
        COUNT(DISTINCT stock_code),
        'Number of distinct product SKUs (stock codes) sold at least once.'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Average revenue generated per order
    SELECT
        'Average Order Value',
        AVG(total_revenue),
        'Mean monetary value generated per distinct invoice (Total Revenue / Total Orders).'
    FROM
    (
        SELECT
            invoice_id,
            SUM(revenue) AS total_revenue
        FROM 'valid_product_sales.csv'
        GROUP BY invoice_id
    ) AS invoice_revenue

    UNION ALL

    -- Average number of units contained in each order
    SELECT
        'Average Basket Size',
        AVG(total_quantity),
        'Mean number of product units purchased per distinct invoice.'
    FROM
    (
        SELECT
            invoice_id,
            SUM(quantity) AS total_quantity
        FROM 'valid_product_sales.csv'
        GROUP BY invoice_id
    ) AS basket_size

    UNION ALL

    -- Average revenue generated per identified customer
    SELECT
        'Average Revenue per Customer',
        SUM(revenue) / COUNT(DISTINCT customer_id),
        'Total revenue divided by the total count of identified distinct customers.'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Average revenue generated per unit sold
    SELECT
        'Average Unit Selling Price',
        SUM(revenue) / SUM(quantity),
        'Effective average selling price realized per individual unit (Total Revenue / Total Units).'
    FROM 'valid_product_sales.csv'

    UNION ALL

    -- Average number of distinct orders placed by each identified customer
    SELECT
        'Average Orders per Customer',
        AVG(total_orders),
        'Mean purchase frequency across all identified customers.'
    FROM
    (
        SELECT
            customer_id,
            COUNT(DISTINCT invoice_id) AS total_orders
        FROM 'valid_product_sales.csv'
        GROUP BY customer_id
    ) AS orders_per_customer
)

SELECT
    metric,
    ROUND(value, 2) AS value,
    description
FROM KPIs;