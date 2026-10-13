/*
  ==============================================================================
  PREPARE VALID PRODUCT SALES
  (CREATE INITIAL PREPARED DATA VIEW)
  ==============================================================================

  BUSINESS RULES

  1. Quantity must be greater than 0.
  2. Price must be greater than 0.
  3. Cancellation invoices (Invoice starting with 'C') are rejected.
  4. A non-NULL Description is accepted.
  5. A NULL Description is accepted only when a matching description exists
     for the same StockCode and Price.
  6. Rows with NULL Description that cannot be recovered are rejected.


  DESIGN DECISIONS

  1. When recovering a NULL Description, use the most common description for
     the same StockCode and Price combination.
  2. Revenue is calculated as Quantity multiplied by Price.
  3. StockCode is trimmed to remove unnecessary surrounding spaces.
  4. Description is converted to uppercase and trimmed for consistency.
  5. InvoiceDate is converted from text to a timestamp.
  6. Customer IDs are retained when available.
  7. Country values are retained as provided.
  ==============================================================================
*/


-- -----------------------------------------------------------------------------
-- SECTION 1: SOURCE DATA
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW prepared_data AS
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


-- -----------------------------------------------------------------------------
-- SECTION 3: SELECT THE STANDARD DESCRIPTION
-- -----------------------------------------------------------------------------

standard_descriptions AS (

    SELECT
        StockCode,
        Price,
        Description AS StandardDescription
    FROM description_frequency
    WHERE row_num = 1
),


-- -----------------------------------------------------------------------------
-- SECTION 4: APPLY VALID PRODUCT SALES RULES
-- -----------------------------------------------------------------------------

prepared_data AS (

    SELECT
        s.Invoice AS invoice_id,
        s.StockCode AS stock_code,

        CASE
            WHEN s.Description IS NOT NULL
                THEN TRIM(UPPER(s.Description))
            ELSE TRIM(UPPER(d.StandardDescription))
        END AS description,

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
      AND (
          s.Description IS NOT NULL
          OR d.StandardDescription IS NOT NULL
      )
)


-- -----------------------------------------------------------------------------
-- SECTION 5: FINAL PREPARED DATASET
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
FROM prepared_data;