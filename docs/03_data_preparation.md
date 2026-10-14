**03 — Data Preparation**
---

**OBJECTIVE**

Prepare the transaction data for analysis by defining valid product sales, handling missing descriptions, applying data standardization, removing non-product transactions, and removing exact duplicate rows.

<br>

**1. Initial Preparation**

The initial preparation defines the basic rules for a valid product sale:

- Quantity must be greater than 0.
- Price must be greater than 0.
- Cancellation invoices are excluded.
- Existing product descriptions are retained.
- NULL Descriptions are recovered when a matching description exists for the same StockCode.
- Rows with unrecoverable NULL Descriptions are excluded.

The initial preparation also:

- Trims StockCodes.
- Standardizes Descriptions to uppercase.
- Converts InvoiceDate to a timestamp.
- Calculates revenue as Quantity × Price.
- Retains Customer ID and Country.

Query: (creates a view of the initial prepared dataset)

[dp_00_prepare_valid_product_sales.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_00_prepare_valid_product_sales.sql)

<br>

**2. Initial Validation**

The initial prepared dataset is validated to check the preparation rules and identify issues requiring further treatment.

The validation checks accepted and rejected rows, missing descriptions, invalid quantities and prices, prepared revenue, and duplicate records.

This validation identified exact duplicate rows in the prepared dataset, which were addressed in the final preparation stage.

Query:

[dp_01_validate_prepared_sales.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_01_validate_prepared_sales.sql)

<br>

**3. Final Preparation**

The final preparation incorporates the findings from the validation stage.

It:

- Formats descriptions using Title Case.
- Standardizes country values.
- Excludes identified non-product service and fee transactions.
- Removes exact duplicate rows.

An exact duplicate is defined as a row where all prepared columns have identical values.

Query: (creates a view of final prepared data)

[dp_02_prepared_data_final.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_02_prepared_data_final.sql)

<br>

**4. Final Validation**

The final dataset is checked to confirm that:

- Invalid quantities and prices are absent.
- Cancellation invoices are absent.
- Non-product fees are absent.
- Descriptions are valid and trimmed.
- Dates are successfully converted.
- Country values are standardized.
- Exact duplicate rows are absent.

Row counts are also reconciled between the raw dataset, the data before deduplication, and the final dataset.

Query:

[dp_03_validate_final_dataset.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_03_validate_final_dataset.sql)

<br>

**5. Export Final Dataset**

The validated final dataset is exported to a CSV file for use in the analysis stage.

Query:

[dp_04_create_valid_product_sales_csv.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_04_create_valid_product_sales_csv.sql)

Output:

[valid_product_sales.csv](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/dataset/valid_product_sales.csv)

<br>

FINAL DATASET:

The final prepared dataset is stored as VIEW:

`prepared_data_final`

The exported analysis dataset is:

`valid_product_sales.csv`

<br>

FINAL SCHEMA

| Column | Type | Description |
|---|---|---|
| `invoice_id` | BIGINT | Invoice number identifying the transaction. |
| `stock_code` | VARCHAR | Product or transaction item code. |
| `description` | VARCHAR | Standardized product description. |
| `quantity` | BIGINT | Number of units sold on the transaction line. |
| `invoice_date` | TIMESTAMP | Date and time of the transaction. |
| `price` | DOUBLE | Unit price in British pounds (£). |
| `revenue` | DOUBLE | Transaction-line revenue calculated as Quantity × Price. |
| `customer_id` | BIGINT | Customer identifier when available; NULL for guest transactions. |
| `country` | VARCHAR | Standardized country associated with the customer. |

The final dataset contains only valid product sales that passed the preparation and validation rules.

<br>

PREPARATION FILES:

[dp_00_prepare_valid_product_sales.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_00_prepare_valid_product_sales.sql)

[dp_01_validate_prepared_sales.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_01_validate_prepared_sales.sql)

[dp_02_prepared_data_final.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_02_prepared_data_final.sql)

[dp_03_validate_final_dataset.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_03_validate_final_dataset.sql)

[dp_04_create_valid_product_sales_csv.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/dp_04_create_valid_product_sales_csv.sql)
