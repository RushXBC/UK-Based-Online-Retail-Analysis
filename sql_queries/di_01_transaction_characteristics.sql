/*
  ==============================================================================
  TRANSACTION CHARACTERISTICS INVESTIGATION
  ==============================================================================
*/

-- -----------------------------------------------------------------------------
-- SECTION 1: INVOICE VALUES
-- -----------------------------------------------------------------------------

SELECT
    '1.1 Invoices Starting with C' AS metric,
    CAST(COUNT(DISTINCT Invoice) AS VARCHAR) AS value
FROM 'online_retail.csv'
WHERE Invoice LIKE 'C%'

UNION ALL

SELECT
    '1.2 Invoices Not Starting with C',
    CAST(COUNT(DISTINCT Invoice) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Invoice NOT LIKE 'C%'

UNION ALL

SELECT
    '1.3 Invoice Values with Non-Numeric Characters',
    CAST(COUNT(DISTINCT Invoice) AS VARCHAR)
FROM 'online_retail.csv'
WHERE regexp_matches(Invoice, '[^0-9]')

UNION ALL

SELECT
    '1.4 Invoice Values with Length Other Than 6',
    CAST(COUNT(DISTINCT Invoice) AS VARCHAR)
FROM 'online_retail.csv'
WHERE LENGTH(Invoice) <> 6


-- -----------------------------------------------------------------------------
-- SECTION 2: STOCK CODE VALUES
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '2.1 StockCodes with Numeric Values',
    CAST(COUNT(DISTINCT StockCode) AS VARCHAR)
FROM 'online_retail.csv'
WHERE TRY_CAST(TRIM(StockCode) AS BIGINT) IS NOT NULL

UNION ALL

SELECT
    '2.2 StockCodes with Non-Numeric Values',
    CAST(COUNT(DISTINCT StockCode) AS VARCHAR)
FROM 'online_retail.csv'
WHERE TRY_CAST(TRIM(StockCode) AS BIGINT) IS NULL

UNION ALL

SELECT
    '2.3 Rows with Numeric StockCodes',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE TRY_CAST(TRIM(StockCode) AS BIGINT) IS NOT NULL

UNION ALL

SELECT
    '2.4 Rows with Non-Numeric StockCodes',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE TRY_CAST(TRIM(StockCode) AS BIGINT) IS NULL


-- -----------------------------------------------------------------------------
-- SECTION 3: QUANTITY AND PRICE COMBINATIONS
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '3.1 Positive Quantity + Positive Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity > 0
  AND Price > 0

UNION ALL

SELECT
    '3.2 Positive Quantity + Zero Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity > 0
  AND Price = 0

UNION ALL

SELECT
    '3.3 Positive Quantity + Negative Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity > 0
  AND Price < 0

UNION ALL

SELECT
    '3.4 Negative Quantity + Positive Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity < 0
  AND Price > 0

UNION ALL

SELECT
    '3.5 Negative Quantity + Zero Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity < 0
  AND Price = 0

UNION ALL

SELECT
    '3.6 Negative Quantity + Negative Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity < 0
  AND Price < 0

UNION ALL

SELECT
    '3.7 Zero Quantity + Positive Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity = 0
  AND Price > 0

UNION ALL

SELECT
    '3.8 Zero Quantity + Zero Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity = 0
  AND Price = 0

UNION ALL

SELECT
    '3.9 Zero Quantity + Negative Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity = 0
  AND Price < 0


-- -----------------------------------------------------------------------------
-- SECTION 4: DESCRIPTION AND STOCK CODE RELATIONSHIP
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '4.1 StockCodes with Multiple Descriptions',
    CAST(COUNT(*) AS VARCHAR)
FROM (
    SELECT StockCode
    FROM 'online_retail.csv'
    WHERE StockCode IS NOT NULL
    GROUP BY StockCode
    HAVING COUNT(DISTINCT Description) > 1
) AS stock_code_descriptions

UNION ALL

SELECT
    '4.2 Descriptions Associated with Multiple StockCodes',
    CAST(COUNT(*) AS VARCHAR)
FROM (
    SELECT Description
    FROM 'online_retail.csv'
    WHERE Description IS NOT NULL
    GROUP BY Description
    HAVING COUNT(DISTINCT StockCode) > 1
) AS description_stock_codes

UNION ALL

SELECT
    '4.3 Rows with NULL Description and Non-NULL StockCode',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Description IS NULL
  AND StockCode IS NOT NULL


-- -----------------------------------------------------------------------------
-- SECTION 5: EXTREME VALUES
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '5.1 Rows with Quantity >= 10,000',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity >= 10000

UNION ALL

SELECT
    '5.2 Rows with Quantity <= -10,000',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity <= -10000

UNION ALL

SELECT
    '5.3 Rows with Price > 1,000',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price > 1000

UNION ALL

SELECT
    '5.4 Rows with Price < 0',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price < 0;