/*
  ==============================================================================
  VALIDATE PREPARED PRODUCT SALES
  ==============================================================================

  VALIDATION CHECKS

  1. Count accepted valid product sales.
  2. Count rejected cancellation invoices.
  3. Count rejected rows with Quantity <= 0.
  4. Count rejected rows with Price <= 0.
  5. Count accepted rows where NULL Description was recovered.
  6. Count rejected rows where NULL Description could not be recovered.
  7. Check for exact duplicate rows in the prepared dataset.
  8. Check for repeated transaction lines in the prepared dataset.
  9. Calculate total prepared revenue.
  10. Check for NULL values in required prepared fields.
*/


-- -----------------------------------------------------------------------------
-- SECTION 1: SOURCE DATA
-- -----------------------------------------------------------------------------

WITH source_data AS (

    SELECT
        Invoice,
        TRIM(StockCode) AS StockCode,
        Description,
        Quantity,
        TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M') AS InvoiceDate,
        Price,
        "Customer ID" AS Customer_ID,
        Country
    FROM 'online_retail.csv'
),


-- -----------------------------------------------------------------------------
-- SECTION 2: FIND THE MOST COMMON DESCRIPTION
-- -----------------------------------------------------------------------------

description_frequency AS (

    SELECT
        StockCode,
        Price,
        Description,
        COUNT(*) AS description_count,

        ROW_NUMBER() OVER (
            PARTITION BY StockCode, Price
            ORDER BY COUNT(*) DESC, Description
        ) AS row_num

    FROM source_data

    WHERE Description IS NOT NULL

    GROUP BY
        StockCode,
        Price,
        Description
),


standard_descriptions AS (

    SELECT
        StockCode,
        Price,
        Description AS StandardDescription
    FROM description_frequency
    WHERE row_num = 1
),


-- -----------------------------------------------------------------------------
-- SECTION 3: CLASSIFY SOURCE ROWS
-- -----------------------------------------------------------------------------

classified_data AS (

    SELECT
        s.Invoice AS invoice_id,
        s.StockCode AS stock_code,
        s.Description AS original_description,
        d.StandardDescription AS recovered_description,
        s.Quantity AS quantity,
        s.InvoiceDate AS invoice_date,
        s.Price AS price,
        s.Quantity * s.Price AS revenue,
        s.Customer_ID AS customer_id,
        s.Country AS country,

        CASE
            WHEN s.Invoice LIKE 'C%'
                THEN 'REJECTED: Cancellation'

            WHEN s.Quantity <= 0
                THEN 'REJECTED: Quantity <= 0'

            WHEN s.Price <= 0
                THEN 'REJECTED: Price <= 0'

            WHEN s.Description IS NOT NULL
                THEN 'ACCEPTED: Existing Description'

            WHEN s.Description IS NULL
                 AND d.StandardDescription IS NOT NULL
                THEN 'ACCEPTED: Description Recovered'

            ELSE 'REJECTED: Description Cannot Be Recovered'
        END AS validation_status

    FROM source_data AS s

    LEFT JOIN standard_descriptions AS d
        ON s.StockCode = d.StockCode
        AND s.Price = d.Price
),


-- -----------------------------------------------------------------------------
-- SECTION 4: PREPARED DATA
-- -----------------------------------------------------------------------------

prepared_data AS (

    SELECT
        invoice_id,
        stock_code,

        CASE
            WHEN original_description IS NOT NULL
                THEN TRIM(UPPER(original_description))
            ELSE TRIM(UPPER(recovered_description))
        END AS description,

        quantity,
        invoice_date,
        price,
        revenue,
        customer_id,
        country

    FROM classified_data

    WHERE validation_status LIKE 'ACCEPTED:%'
),


-- -----------------------------------------------------------------------------
-- SECTION 5: EXACT DUPLICATES
-- -----------------------------------------------------------------------------

exact_duplicates AS (

    SELECT
        invoice_id,
        stock_code,
        description,
        quantity,
        invoice_date,
        price,
        revenue,
        customer_id,
        country,
        COUNT(*) AS occurrences

    FROM prepared_data

    GROUP BY
        invoice_id,
        stock_code,
        description,
        quantity,
        invoice_date,
        price,
        revenue,
        customer_id,
        country

    HAVING COUNT(*) > 1
),


-- -----------------------------------------------------------------------------
-- SECTION 6: REPEATED TRANSACTION LINES
-- -----------------------------------------------------------------------------

repeated_transaction_lines AS (

    SELECT
        invoice_id,
        stock_code,
        description,
        quantity,
        price,
        COUNT(*) AS occurrences

    FROM prepared_data

    GROUP BY
        invoice_id,
        stock_code,
        description,
        quantity,
        price

    HAVING COUNT(*) > 1
)


-- -----------------------------------------------------------------------------
-- SECTION 7: VALIDATION RESULTS
-- -----------------------------------------------------------------------------

SELECT
    '1.1 Total Source Rows' AS metric,
    CAST(COUNT(*) AS VARCHAR) AS value
FROM classified_data

UNION ALL

SELECT
    '1.2 Accepted Valid Product Sales',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status LIKE 'ACCEPTED:%'

UNION ALL

SELECT
    '1.3 Accepted Rows with Existing Description',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'ACCEPTED: Existing Description'

UNION ALL

SELECT
    '1.4 Accepted Rows with Recovered Description',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'ACCEPTED: Description Recovered'

UNION ALL

SELECT
    '1.5 Rejected Cancellation Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'REJECTED: Cancellation'

UNION ALL

SELECT
    '1.6 Rejected Rows with Quantity <= 0',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'REJECTED: Quantity <= 0'

UNION ALL

SELECT
    '1.7 Rejected Rows with Price <= 0',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'REJECTED: Price <= 0'

UNION ALL

SELECT
    '1.8 Rejected Rows with Unrecoverable Description',
    CAST(COUNT(*) AS VARCHAR)
FROM classified_data
WHERE validation_status = 'REJECTED: Description Cannot Be Recovered'

UNION ALL

SELECT
    '2.1 Exact Duplicate Groups',
    CAST(COUNT(*) AS VARCHAR)
FROM exact_duplicates

UNION ALL

SELECT
    '2.2 Excess Rows from Exact Duplicates',
    CAST(COALESCE(SUM(occurrences - 1), 0) AS VARCHAR)
FROM exact_duplicates

UNION ALL

SELECT
    '2.3 Repeated Transaction Line Groups',
    CAST(COUNT(*) AS VARCHAR)
FROM repeated_transaction_lines

UNION ALL

SELECT
    '2.4 Maximum Repetitions of a Transaction Line',
    CAST(COALESCE(MAX(occurrences), 0) AS VARCHAR)
FROM repeated_transaction_lines

UNION ALL

SELECT
    '3.1 Total Prepared Revenue',
    CAST(ROUND(COALESCE(SUM(revenue), 0), 2) AS VARCHAR)
FROM prepared_data

UNION ALL

SELECT
    '3.2 Prepared Rows with NULL StockCode',
    CAST(COUNT(*) AS VARCHAR)
FROM prepared_data
WHERE stock_code IS NULL

UNION ALL

SELECT
    '3.3 Prepared Rows with NULL Description',
    CAST(COUNT(*) AS VARCHAR)
FROM prepared_data
WHERE description IS NULL

UNION ALL

SELECT
    '3.4 Prepared Rows with Quantity <= 0',
    CAST(COUNT(*) AS VARCHAR)
FROM prepared_data
WHERE quantity <= 0

UNION ALL

SELECT
    '3.5 Prepared Rows with Price <= 0',
    CAST(COUNT(*) AS VARCHAR)
FROM prepared_data
WHERE price <= 0;