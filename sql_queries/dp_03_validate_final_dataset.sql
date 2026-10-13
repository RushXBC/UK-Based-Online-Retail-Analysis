/*
  ==============================================================================
  DATA QUALITY AND ROW COUNT REPORT
  ==============================================================================
  This script checks if the cleaned sales data meets all business rules 
  and shows how many rows were kept or removed from the original file.
  
  EXPECTED RESULTS:
  - Rows 1 to 7 should show 0 for metric_value and 'PASS' for status.
  - Rows 8 to 11 show total counts and dropped row summaries.
  ==============================================================================
*/

WITH source_data AS (

    SELECT
        Invoice,
        TRIM(StockCode) AS StockCode,
        INITCAP(TRIM(Description)) AS Description,
        Quantity,
        TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M') AS InvoiceDate,
        Price,
        "Customer ID" AS Customer_ID,
        Country
    FROM 'online_retail.csv'
),

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
    WHERE Description IS NOT NULL AND Description != ''
    GROUP BY StockCode, Price, Description
),

standard_descriptions AS (

    SELECT
        StockCode,
        Price,
        Description AS StandardDescription
    FROM description_frequency
    WHERE row_num = 1
),

-- Pre-deduplication logic to calculate business rule drops vs duplicate drops
prepared_data_before_deduplication AS (

    SELECT
        s.Invoice AS invoice_id,
        s.StockCode AS stock_code,
        COALESCE(s.Description, d.StandardDescription) AS description,
        s.Quantity AS quantity,
        s.InvoiceDate AS invoice_date,
        s.Price AS price,
        s.Quantity * s.Price AS revenue,
        s.Customer_ID AS customer_id,
        s.Country AS country
    FROM source_data AS s
    LEFT JOIN standard_descriptions AS d
        ON s.StockCode = d.StockCode
       AND s.Price = d.Price
    WHERE s.Invoice NOT LIKE 'C%'
      AND s.Quantity > 0
      AND s.Price > 0
      AND UPPER(s.StockCode) NOT IN (
          'POST', 'D', 'M', 'BANK CHARGES', 'PADS', 
          'DOT', 'CRUK', 'AMAZONFEE', 'ADJUST', 'S', 'B'
      )
      AND COALESCE(s.Description, d.StandardDescription) IS NOT NULL
),

pipeline_reconciliation AS (

    -- Get total counts from the raw file, intermediate view, and final view
    SELECT 
        (SELECT COUNT(*) FROM 'online_retail.csv') AS raw_count,
        (SELECT COUNT(*) FROM prepared_data_final) AS final_count,
        (SELECT COUNT(*) FROM prepared_data_before_deduplication) AS pre_dedup_count
),

audit_checks AS (

    -- 1. Check for bad numbers (negative/zero price or quantity)
    SELECT 
        1 AS check_id,
        'Number Check' AS category,
        'Rows with zero/negative price, quantity, or wrong total sales' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE quantity <= 0 
       OR price <= 0 
       OR revenue <= 0 
       OR revenue != (quantity * price)

    UNION ALL

    -- 2. Check for cancelled orders
    SELECT 
        2 AS check_id,
        'Cancelled Orders' AS category,
        'Cancelled invoices (order IDs starting with C) still present' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE UPPER(invoice_id) LIKE 'C%'

    UNION ALL

    -- 3. Check for non-product fees
    SELECT 
        3 AS check_id,
        'Extra Fees Check' AS category,
        'Shipping, postage, or admin fees still present' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE UPPER(stock_code) IN (
        'POST', 'D', 'M', 'BANK CHARGES', 'PADS', 
        'DOT', 'CRUK', 'AMAZONFEE', 'ADJUST', 'S', 'B'
    )

    UNION ALL

    -- 4. Check for missing or untrimmed item names
    SELECT 
        4 AS check_id,
        'Item Name Check' AS category,
        'Missing, empty, or unspaced item descriptions' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE description IS NULL 
       OR TRIM(description) = ''
       OR description != TRIM(description)

    UNION ALL

    -- 5. Check for broken dates
    SELECT 
        5 AS check_id,
        'Date Check' AS category,
        'Blank dates caused by bad date formats' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE invoice_date IS NULL

    UNION ALL

    -- 6. Check for uncleaned country names
    SELECT 
        6 AS check_id,
        'Country Name Check' AS category,
        'Old country names or regions that were not updated (EIRE, RSA, USA, etc.)' AS test_description,
        COUNT(*) AS metric_value,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM prepared_data_final
    WHERE country IN (
        'EIRE', 'RSA', 'Channel Islands', 'USA', 
        'Unspecified', 'European Community', 'West Indies', ''
    )

    UNION ALL

    -- 7. Check for exact duplicate rows
    SELECT 
        7 AS check_id,
        'Duplicate Check' AS category,
        'Identical duplicate rows remaining in the dataset' AS test_description,
        COALESCE(SUM(duplicate_count - 1), 0) AS metric_value,
        CASE WHEN COALESCE(SUM(duplicate_count - 1), 0) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM (
        SELECT 
            invoice_id, stock_code, description, quantity, 
            invoice_date, price, revenue, customer_id, country,
            COUNT(*) AS duplicate_count
        FROM prepared_data_final
        GROUP BY 
            invoice_id, stock_code, description, quantity, 
            invoice_date, price, revenue, customer_id, country
        HAVING COUNT(*) > 1
    ) AS duplicates

    UNION ALL

    -- 8. Total rows in original file
    SELECT 
        8 AS check_id,
        'Row Counts' AS category,
        'Total starting rows in the original raw file' AS test_description,
        raw_count AS metric_value,
        'INFO' AS status
    FROM pipeline_reconciliation

    UNION ALL

    -- 9. Total rows in final dataset
    SELECT 
        9 AS check_id,
        'Row Counts' AS category,
        'Final dataset row count' AS test_description,
        final_count AS metric_value,
        'INFO' AS status
    FROM pipeline_reconciliation

    UNION ALL

    -- 10. Rows removed by rules
    SELECT 
        10 AS check_id,
        'Row Counts' AS category,
        'Rows removed due to business rules (cancelled orders, zero prices, extra fees)' AS test_description,
        raw_count - pre_dedup_count AS metric_value,
        'INFO' AS status
    FROM pipeline_reconciliation

    UNION ALL

    -- 11. Rows removed as exact duplicates
    SELECT 
        11 AS check_id,
        'Row Counts' AS category,
        'Rows removed because they were exact copies of other rows' AS test_description,
        pre_dedup_count - final_count AS metric_value,
        'INFO' AS status
    FROM pipeline_reconciliation
)

-- Final result table sorted by step order
SELECT 
    check_id,
    category,
    test_description,
    metric_value,
    status
FROM audit_checks
ORDER BY check_id ASC;