/*
  ==============================================================================
  DISTINCT VALUE INVESTIGATION
  ==============================================================================
*/

-- -----------------------------------------------------------------------------
-- SECTION 1: STOCKCODE
-- -----------------------------------------------------------------------------

SELECT
    StockCode,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
GROUP BY StockCode
ORDER BY StockCode DESC;


-- -----------------------------------------------------------------------------
-- SECTION 2: DESCRIPTION
-- -----------------------------------------------------------------------------

SELECT
    Description,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
GROUP BY Description
ORDER BY row_count DESC;


-- -----------------------------------------------------------------------------
-- SECTION 3: COUNTRY
-- -----------------------------------------------------------------------------

SELECT
    Country,
    COUNT(*) AS row_count
FROM 'online_retail.csv'
GROUP BY Country
ORDER BY row_count DESC;