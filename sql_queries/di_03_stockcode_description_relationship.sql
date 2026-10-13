/*
  ==============================================================================
  STOCKCODE AND DESCRIPTION RELATIONSHIP INVESTIGATION
  ==============================================================================
*/


-- -----------------------------------------------------------------------------
-- SECTION 1: STOCKCODES WITH MULTIPLE DESCRIPTIONS
-- -----------------------------------------------------------------------------

SELECT
    StockCode,
    COUNT(DISTINCT Description) AS distinct_descriptions,
    ARRAY_AGG(DISTINCT Description ORDER BY Description) AS descriptions,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
WHERE Description IS NOT NULL
GROUP BY StockCode
HAVING COUNT(DISTINCT Description) > 1
ORDER BY distinct_descriptions DESC, row_count DESC;


-- -----------------------------------------------------------------------------
-- SECTION 2: DESCRIPTIONS WITH MULTIPLE STOCKCODES
-- -----------------------------------------------------------------------------

SELECT
    Description,
    COUNT(DISTINCT StockCode) AS distinct_stock_codes,
    ARRAY_AGG(DISTINCT StockCode ORDER BY StockCode) AS stock_codes,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
WHERE Description IS NOT NULL
GROUP BY Description
HAVING COUNT(DISTINCT StockCode) > 1
ORDER BY distinct_stock_codes DESC, row_count DESC;


-- -----------------------------------------------------------------------------
-- SECTION 3: STOCKCODES WITHOUT A DESCRIPTION
-- -----------------------------------------------------------------------------

SELECT
    StockCode,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
WHERE Description IS NULL
GROUP BY StockCode
ORDER BY row_count DESC;