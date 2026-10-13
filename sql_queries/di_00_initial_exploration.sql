/*
  ==============================================================================
  INITIAL DATA PROFILING
  ==============================================================================
*/

-- -----------------------------------------------------------------------------
-- SECTION 1: DATASET OVERVIEW
-- -----------------------------------------------------------------------------

SELECT
    '1.1 Total Rows' AS metric,
    CAST(COUNT(*) AS VARCHAR) AS value
FROM 'online_retail.csv'

UNION ALL

SELECT
    '1.2 Distinct Invoices',
    CAST(COUNT(DISTINCT Invoice) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '1.3 Distinct StockCodes',
    CAST(COUNT(DISTINCT StockCode) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '1.4 Distinct Descriptions',
    CAST(COUNT(DISTINCT Description) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '1.5 Distinct Customers',
    CAST(COUNT(DISTINCT "Customer ID") AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '1.6 Distinct Countries',
    CAST(COUNT(DISTINCT Country) AS VARCHAR)
FROM 'online_retail.csv'


-- -----------------------------------------------------------------------------
-- SECTION 2: NULL VALUE INVESTIGATION
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '2.1 NULL Invoice',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Invoice IS NULL

UNION ALL

SELECT
    '2.2 NULL StockCode',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE StockCode IS NULL

UNION ALL

SELECT
    '2.3 NULL Description',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Description IS NULL

UNION ALL

SELECT
    '2.4 NULL Quantity',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity IS NULL

UNION ALL

SELECT
    '2.5 NULL InvoiceDate',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE InvoiceDate IS NULL

UNION ALL

SELECT
    '2.6 NULL Price',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price IS NULL

UNION ALL

SELECT
    '2.7 NULL Customer ID',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE "Customer ID" IS NULL

UNION ALL

SELECT
    '2.8 NULL Country',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Country IS NULL


-- -----------------------------------------------------------------------------
-- SECTION 3: QUANTITY PROFILE
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '3.1 Minimum Quantity',
    CAST(MIN(Quantity) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '3.2 Maximum Quantity',
    CAST(MAX(Quantity) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '3.3 Zero Quantity Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity = 0

UNION ALL

SELECT
    '3.4 Negative Quantity Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity < 0

UNION ALL

SELECT
    '3.5 Positive Quantity Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Quantity > 0


-- -----------------------------------------------------------------------------
-- SECTION 4: PRICE PROFILE
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '4.1 Minimum Price',
    CAST(MIN(Price) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '4.2 Maximum Price',
    CAST(MAX(Price) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '4.3 Zero Price Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price = 0

UNION ALL

SELECT
    '4.4 Negative Price Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price < 0

UNION ALL

SELECT
    '4.5 Positive Price Rows',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE Price > 0


-- -----------------------------------------------------------------------------
-- SECTION 5: INVOICE DATE PROFILE
-- -----------------------------------------------------------------------------

UNION ALL

SELECT
    '5.1 Unparseable InvoiceDate Values',
    CAST(COUNT(*) AS VARCHAR)
FROM 'online_retail.csv'
WHERE TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M') IS NULL

UNION ALL

SELECT
    '5.2 Earliest InvoiceDate',
    CAST(MIN(TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M')) AS VARCHAR)
FROM 'online_retail.csv'

UNION ALL

SELECT
    '5.3 Latest InvoiceDate',
    CAST(MAX(TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M')) AS VARCHAR)
FROM 'online_retail.csv';