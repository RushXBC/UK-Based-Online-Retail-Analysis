/*
  ==============================================================================
  PREPARE VALID PRODUCT SALES
  DEDUPLICATED PREPARED DATA VIEW
  ==============================================================================

  BUSINESS RULES

  1. Quantity must be greater than 0.
  2. Price must be greater than 0.
  3. Cancellation invoices (Invoice starting with 'C') are rejected.
  4. Non-product service/fee StockCodes are rejected.
  5. Guest checkouts (NULL Customer_ID) are retained as valid sales.
  6. A non-NULL Description is accepted.
  7. A NULL Description is accepted only when a matching description exists
     for the same StockCode and Price.
  8. Rows with NULL Description that cannot be recovered are rejected.


  DESIGN DECISIONS

  1. When recovering a NULL Description, use the most common description for
     the same StockCode and Price combination.
  2. Revenue is calculated as Quantity multiplied by Price.
  3. StockCode is trimmed to remove unnecessary surrounding spaces.
  4. Description is converted to uppercase and trimmed for consistency.
  5. InvoiceDate is converted from text to a timestamp.
  6. Customer IDs are retained when available, allowing guest transactions 
     (NULL Customer_ID) to pass through as valid revenue entries.
  7. Country values are retained as provided.


  NEW IN DP_02

  8. Description is now formatted in Title Case using the user-defined function 
     INITCAP() and trimmed for consistency.
  9. Country values are standardized to sovereign English names (e.g., 'EIRE' -> 
     'Ireland', 'RSA' -> 'South Africa'), territories mapped to parent nations 
     ('Channel Islands' -> 'United Kingdom'), and non-geographic entries 
     ('Unspecified', 'European Community') converted to NULL.
  10. Non-product service charges, shipping/postage codes, and administrative 
      fees (e.g., 'POST', 'DOT', 'D', 'M', 'BANK CHARGES', 'AMAZONFEE', 'CRUK', 
      'ADJUST', 'PADS', 'S', 'B') are explicitly excluded from product sales.
  11. Exact duplicate rows are removed after the valid product sales rules
      are applied. A row is considered an exact duplicate when all prepared
      columns have identical values.
  ==============================================================================
*/


-- -----------------------------------------------------------------------------
-- SECTION 1: SOURCE DATA
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW prepared_data_final AS

WITH source_data AS (

    SELECT
        Invoice,
        TRIM(StockCode) AS StockCode,
        INITCAP(TRIM(Description)) AS Description,
        Quantity,
        TRY_STRPTIME(InvoiceDate, '%m/%d/%Y %H:%M') AS InvoiceDate,
        Price,
        "Customer ID" AS Customer_ID,
    CASE 
        WHEN TRIM(Country) = 'EIRE' THEN 'Ireland'
        WHEN TRIM(Country) = 'RSA' THEN 'South Africa'
        WHEN TRIM(Country) = 'USA' THEN 'United States'
        WHEN TRIM(Country) = 'Channel Islands' THEN 'United Kingdom'
        WHEN TRIM(Country) IN ('Unspecified', 'European Community', 'West Indies', '') THEN NULL
        ELSE TRIM(Country)
    END AS Country
    FROM 'online_retail.csv'
),


-- -----------------------------------------------------------------------------
-- SECTION 2: FIND THE MOST COMMON DESCRIPTION
-- -----------------------------------------------------------------------------

description_frequency AS (

    SELECT
        StockCode,
        Description,
        COUNT(*) AS description_count,

        ROW_NUMBER() OVER (
            PARTITION BY StockCode
            ORDER BY COUNT(*) DESC, Description
        ) AS row_num

    FROM source_data

    WHERE Description IS NOT NULL AND Description != ''

    GROUP BY
        StockCode,
        Description
),


-- -----------------------------------------------------------------------------
-- SECTION 3: SELECT THE STANDARD DESCRIPTION
-- -----------------------------------------------------------------------------

standard_descriptions AS (

    SELECT
        StockCode,
        Description AS StandardDescription
    FROM description_frequency
    WHERE row_num = 1
),


-- -----------------------------------------------------------------------------
-- SECTION 4: APPLY VALID PRODUCT SALES RULES & EXCLUDE NON-PRODUCT FEES
-- -----------------------------------------------------------------------------

prepared_data_before_deduplication AS (

    SELECT
        s.Invoice AS invoice_id,
        s.StockCode AS stock_code,
        d.StandardDescription AS description,
        s.Quantity AS quantity,
        s.InvoiceDate AS invoice_date,
        s.Price AS price,
        s.Quantity * s.Price AS revenue,
        s.Customer_ID AS customer_id,
        s.Country AS country

    FROM source_data AS s

    LEFT JOIN standard_descriptions AS d
        ON s.StockCode = d.StockCode

    WHERE s.Invoice NOT LIKE 'C%'
        AND s.Quantity > 0
        AND s.Price > 0
        -- NEW IN DP_02: Exclude non-product fee stock codes
        AND UPPER(s.StockCode) NOT IN (
            'POST', 'D', 'M', 'BANK CHARGES', 'PADS', 
            'DOT', 'CRUK', 'AMAZONFEE', 'ADJUST', 'S', 'B'
        )
        AND UPPER(s.StockCode) NOT LIKE 'ADJUST%'
        AND UPPER(s.StockCode) NOT LIKE 'TEST%'
        AND d.StandardDescription IS NOT NULL
),


-- -----------------------------------------------------------------------------
-- SECTION 5: REMOVE EXACT DUPLICATES
-- NEW IN DP_02
-- -----------------------------------------------------------------------------

deduplicated_data AS (

    SELECT DISTINCT
        invoice_id,
        stock_code,
        description,
        quantity,
        invoice_date,
        price,
        revenue,
        customer_id,
        country
    FROM prepared_data_before_deduplication
)


-- -----------------------------------------------------------------------------
-- SECTION 6: FINAL PREPARED DATASET
-- -----------------------------------------------------------------------------

SELECT
    invoice_id,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    revenue,
    customer_id,
    country
FROM deduplicated_data;