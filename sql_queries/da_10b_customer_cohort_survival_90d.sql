/*
  COHORT RETENTION WITH 90-DAY GRACE PERIOD
  ==============================================================================
  Measures customer retention using a 90-day inactivity threshold.
  A customer remains retained as long as they make a purchase within
  every 90-day evaluation window. Once they exceed 90 days without
  a purchase, they are considered permanently churned.
  Metrics include:
  - Cohort Month
  - Cohort Size
  - Monthly Retention Rate
  - M00 to M24 Retention
  ==============================================================================
*/

WITH customer_orders AS
(
    -- gets unique purchase dates for each customer
    SELECT DISTINCT
        customer_id,
        TRY_CAST(invoice_date AS DATE) AS order_date
    FROM 'valid_product_sales.csv'
    WHERE customer_id IS NOT NULL
),

customer_cohorts AS
(
    -- assigns each customer to the month of their first purchase
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        DATE_TRUNC(
            'month',
            MIN(order_date)
        ) AS cohort_month
    FROM customer_orders
    GROUP BY
        customer_id
),

cohort_sizes AS
(
    -- counts the number of customers acquired in each cohort
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size
    FROM customer_cohorts
    GROUP BY
        cohort_month
),

cohort_grid AS
(
    -- creates monthly evaluation points from M00 to M24 for each customer
    SELECT
        c.cohort_month,
        c.customer_id,
        c.first_order_date,
        m.month_number,

        -- gets the last day of each relative cohort month
        LAST_DAY(
            c.cohort_month
                + INTERVAL (m.month_number) MONTH
        ) AS eval_date

    FROM customer_cohorts AS c

    CROSS JOIN
    (
        -- generates month numbers from M00 to M24
        SELECT RANGE AS month_number
        FROM RANGE(0, 25)
    ) AS m

    WHERE
        c.cohort_month
            + INTERVAL (m.month_number) MONTH
        <=
        DATE_TRUNC(
            'month',
            (
                SELECT MAX(order_date)
                FROM customer_orders
            )
        )
),

customer_activity_status AS
(
    -- checks whether each customer purchased within the previous 90 days
    SELECT
        g.cohort_month,
        g.customer_id,
        g.month_number,

        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM customer_orders AS o
                WHERE o.customer_id = g.customer_id
                  AND o.order_date >=
                      GREATEST(
                          c.first_order_date,
                          g.eval_date - INTERVAL 90 DAY
                      )
                  AND o.order_date <= g.eval_date
            )
            THEN 1
            ELSE 0
        END AS is_active

    FROM cohort_grid AS g

    INNER JOIN customer_cohorts AS c
        ON g.customer_id = c.customer_id
),

customer_survival AS
(
    -- keeps customers retained until they fail the 90-day activity test
    SELECT
        cohort_month,
        customer_id,
        month_number,

        MIN(is_active) OVER
        (
            PARTITION BY
                cohort_month,
                customer_id
            ORDER BY
                month_number
            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW
        ) AS is_retained

    FROM customer_activity_status
),

retention_summary AS
(
    -- calculates the percentage of each cohort still retained at each month
    SELECT
        CAST(s.cohort_month AS DATE) AS cohort_month,
        cs.cohort_size,

        'M' ||
        LPAD(
            CAST(s.month_number AS VARCHAR),
            2,
            '0'
        ) AS month_label,

        ROUND(
            SUM(s.is_retained) * 100.0
            / cs.cohort_size,
            2
        ) AS retention_rate

    FROM customer_survival AS s

    INNER JOIN cohort_sizes AS cs
        ON s.cohort_month = cs.cohort_month

    GROUP BY
        s.cohort_month,
        cs.cohort_size,
        s.month_number
)

-- pivots monthly retention rates into a cohort retention matrix
PIVOT retention_summary

ON month_label

USING MAX(retention_rate)

GROUP BY
    cohort_month,
    cohort_size

ORDER BY
    cohort_month;