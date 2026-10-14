**02 — Data Investigation**
---
**OBJECTIVE:**

Investigate the raw dataset to understand its structure, transaction characteristics, and relationships between important fields.

Since no documentation or contact person exists for this dataset, the investigation provides the necessary evidence to establish custom rules for valid sales.

No records are changed, removed, or corrected during this stage.

<br>

**INVESTIGATION PROCESS:**

<br>

**1. Initial Data Profiling**

The first investigation established a basic understanding of the dataset.

It examined:

- Total number of rows
- Distinct invoices
- Distinct StockCodes
- Distinct descriptions
- Distinct customers
- Distinct countries
- NULL values across the main columns
- Quantity ranges and quantity types
- Price ranges and price types
- Invoice date validity and date range

Query:

[di_00_initial_exploration.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_00_initial_exploration.sql)

<br>

**2. Transaction Characteristics**

The second investigation examined how different types of transaction values appear in the dataset.

It examined:

- Invoice values
- Invoices beginning with C
- Invoices not beginning with C
- Invoice values containing non-numeric characters
- Invoice values with lengths other than six characters
- StockCodes
- Numeric StockCodes
- Non-numeric StockCodes
- Number of rows associated with each type
- Quantity and Price

The different combinations of quantity and price were examined, including:

- Positive quantity and positive price
- Positive quantity and zero or negative price
- Negative quantity and positive price
- Negative quantity and zero or negative price
- Zero quantity with different price values
- Description and StockCode

The investigation also examined:

- StockCodes associated with multiple descriptions
- Descriptions associated with multiple StockCodes
- Rows with a NULL description but a StockCode
- Extreme values

Large quantity and price values were reviewed to identify unusual transaction records.

Query:

[di_01_transaction_characteristics.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_01_transaction_characteristics.sql)

<br>

**3. Distinct Value Investigation**

The third investigation looked at the actual distinct values contained in important categorical fields.

The following fields were reviewed:

- StockCode
- Description
- Country

The number of rows associated with each distinct value was included to show how frequently each value occurs.

This was used to identify unusual, uncommon, or non-standard values that may require consideration when defining valid product sales.

Query:

[di_02_distinct_values_investigation.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_01_transaction_characteristics.sql)

<br>

**4. StockCode and Description Relationships**

The fourth investigation focused specifically on the relationship between StockCode and Description.

It examined:

- StockCodes with multiple descriptions

This identifies products where the same StockCode appears with different descriptions.
The investigation includes the list of descriptions associated with each StockCode and the number of rows involved.

- Descriptions with multiple StockCodes

This identifies descriptions that are associated with more than one StockCode.

- StockCodes without a description

This identifies StockCodes that appear on rows where the Description is NULL.

> These relationships are important when deciding how missing or inconsistent product descriptions should be handled during data preparation.

Query:

[di_03_stockcode_description_relationship.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_03_stockcode_description_relationship.sql)

<br>

**INVESTIGATION OUTCOME:**

The investigation provides the information needed to move from raw data exploration toward defining the project's valid product sales rules.

At this stage, the investigation and the business definition remain separate:

Data investigation identifies what exists in the dataset.
Business rules define what will be considered a valid product sale.
Data preparation will apply those rules to create the prepared dataset.

The rules for valid product sales are therefore defined in the next stage rather than being treated as assumptions within the investigation queries.

INVESTIGATION FILES:
[di_00_initial_exploration.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_00_initial_exploration.sql)
<br>
[di_01_transaction_characteristics.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_01_transaction_characteristics.sql)
<br>
[di_02_distinct_values_investigation.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_01_transaction_characteristics.sql)
<br>
[di_03_stockcode_description_relationship.sql](https://github.com/RushXBC/UK-Based-Online-Retail-Analysis/blob/main/sql_queries/di_03_stockcode_description_relationship.sql)
