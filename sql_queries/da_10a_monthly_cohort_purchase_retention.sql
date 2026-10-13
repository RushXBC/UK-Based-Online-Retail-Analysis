 /*
  COHORT RETENTION RATE
  ==============================================================================
  Measures monthly customer retention based on customer purchase activity.
  Each customer is assigned to their first purchase month and tracked for
  24 months after acquisition.
  Metrics include:
  - Cohort Month
  - Cohort Size
  - Active Customers
  - Monthly Retention Rate
  - M00 to M24 Retention
  ==============================================================================
 */

WITH customer_first_purchase_date AS
(
    -- assigns each customer to the month of their first purchase
    SELECT
        customer_id,
        DATE_TRUNC(
            'month',
            MIN(TRY_CAST(invoice_date AS DATE))
        ) AS cohort_month
    FROM 'valid_product_sales.csv'
    WHERE
        customer_id IS NOT NULL
        AND TRY_CAST(invoice_date AS DATE) IS NOT NULL
    GROUP BY
        customer_id
),

customer_active_months AS
(
    -- gets the unique months in which each customer made a purchase
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC(
            'month',
            TRY_CAST(invoice_date AS DATE)
        ) AS active_month
    FROM 'valid_product_sales.csv'
    WHERE
        customer_id IS NOT NULL
        AND TRY_CAST(invoice_date AS DATE) IS NOT NULL
),

with_month_since_first_purchase AS
(
    -- calculates how many months each active month is from the customer's cohort month
    SELECT
        ca.customer_id,
        cf.cohort_month,
        ca.active_month,
        DATE_DIFF(
            'months',
            cf.cohort_month,
            ca.active_month
        ) AS month_since_first_purchase
    FROM customer_active_months AS ca

    INNER JOIN customer_first_purchase_date AS cf
        ON ca.customer_id = cf.customer_id
),

cohort_retention AS
(
    -- counts active customers for each cohort and month since acquisition
    SELECT
        cohort_month,
        month_since_first_purchase,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM with_month_since_first_purchase
    WHERE
        month_since_first_purchase BETWEEN 0 AND 24
    GROUP BY
        cohort_month,
        month_since_first_purchase
),

cohort_sizes AS
(
    -- counts the total number of customers acquired in each cohort
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_first_purchase_date
    WHERE cohort_month IS NOT NULL
    GROUP BY
        cohort_month
),

retention_rates AS
(
    -- calculates the percentage of the original cohort active in each month
    SELECT
        CAST(cr.cohort_month AS DATE) AS cohort_month,
        cs.cohort_size,
        cr.month_since_first_purchase,
        ROUND(
            cr.active_customers * 100.0 / cs.cohort_size,
            2
        ) AS retention_rate
    FROM cohort_retention AS cr

    INNER JOIN cohort_sizes AS cs
        ON cr.cohort_month = cs.cohort_month
)

-- pivots monthly retention rates into a cohort retention matrix
PIVOT retention_rates

ON
    'M' || LPAD(
        CAST(month_since_first_purchase AS VARCHAR),
        2,
        '0'
    )

USING MAX(retention_rate)

GROUP BY
    cohort_month,
    cohort_size

ORDER BY
    cohort_month;