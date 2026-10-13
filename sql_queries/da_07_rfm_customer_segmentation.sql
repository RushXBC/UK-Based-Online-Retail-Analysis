/*
  ==============================================================================
  RFM CUSTOMER SEGMENTATION ANALYSIS
  
  This query groups customers based on RFM:
  - Recency (R): How long ago they made a purchase
  - Frequency (F): How often they make purchases
  - Monetary (M): How much total money they spend

  It gives each customer scores from 1 to 5 for R, F, and M, then assigns 
  them to a group based on their buying habits.
  ==============================================================================
*/

-- -----------------------------------------------------------------------------
-- SECTION 1: CALCULATE BASIC NUMBERS (RECENCY, FREQUENCY, SPENDING)
-- -----------------------------------------------------------------------------

-- CTE 1: Calculate days since the last purchase for each customer
WITH purchase_recency AS (

    SELECT
        customer_id,
        DATEDIFF('day', recent_purchase_date, global_recent_date) AS days_from_last_purchase
    FROM
    (
        SELECT
            customer_id,
            MAX(invoice_date) AS recent_purchase_date,
            MAX(MAX(invoice_date)) OVER () AS global_recent_date -- Latest overall date in the file
        FROM 'valid_product_sales.csv'
        WHERE customer_id IS NOT NULL
        GROUP BY customer_id
    ) AS reference_dates
),

-- CTE 2: Count total orders for each customer
customer_orders AS (

    SELECT
        customer_id,
        COUNT(DISTINCT invoice_id) AS total_orders
    FROM 'valid_product_sales.csv'
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),

-- CTE 3: Calculate total money spent by each customer
customer_spending AS (

    SELECT
        customer_id,
        SUM(revenue) AS total_spending
    FROM 'valid_product_sales.csv'
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),


-- -----------------------------------------------------------------------------
-- SECTION 2: GIVE SCORES FROM 1 TO 5 (5 IS BEST)
-- -----------------------------------------------------------------------------

customer_metrics_buckets AS (

    SELECT
        pr.customer_id,
        pr.days_from_last_purchase,
        co.total_orders,
        cs.total_spending,
        -- Recency Score: Low days elapsed get highest score (5 = bought recently)
        NTILE(5) OVER (ORDER BY pr.days_from_last_purchase DESC, pr.customer_id ASC) AS r_score,
        -- Frequency Score: High order numbers get highest score (5 = most orders)
        NTILE(5) OVER (ORDER BY co.total_orders ASC, co.customer_id ASC) AS f_score,
        -- Monetary Score: High total spending gets highest score (5 = highest spend)
        NTILE(5) OVER (ORDER BY cs.total_spending ASC, cs.customer_id ASC) AS m_score
    FROM purchase_recency AS pr
    JOIN customer_orders AS co
        ON pr.customer_id = co.customer_id
    JOIN customer_spending AS cs
        ON pr.customer_id = cs.customer_id
)


-- -----------------------------------------------------------------------------
-- SECTION 3: GROUP CUSTOMERS BY THEIR SCORES
-- -----------------------------------------------------------------------------

SELECT
    customer_id,
    days_from_last_purchase,
    total_orders,
    total_spending,
    r_score,
    f_score,
    m_score,
    -- Label each customer based on their combined scores
CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
        THEN 'Champions'

    WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3
        THEN 'Loyal Customers'

    WHEN r_score <= 2 AND (m_score >= 4 OR f_score >= 4)
        THEN 'At Risk (High Value)'

    WHEN r_score = 3 AND f_score >= 3 AND m_score >= 3
        THEN 'Slipping Loyalists'

    WHEN r_score >= 4 AND f_score <= 2
        THEN 'New / Promising'

    WHEN r_score = 3 AND (f_score >= 4 OR m_score >= 4)
        THEN 'Hibernating (High Value)'

    WHEN r_score = 3
        THEN 'Hibernating'

    WHEN r_score <= 2
        THEN 'Lost / Churned'

    ELSE 'Standard / Active'
END AS customer_segment
FROM customer_metrics_buckets
-- Show customers who haven't bought in the longest time first
ORDER BY days_from_last_purchase DESC, customer_id ASC;