01 — Data Source
1. Source

This project uses the Online Retail II dataset from the UCI Machine Learning Repository.

Source: UCI Machine Learning Repository — Online Retail II
LINK: https://archive.ics.uci.edu/dataset/502/online+retail+ii

The dataset contains transaction records from an online retail business covering December 2009 to December 2011.

Dataset Constraints & Analytical Ownership

No External Reference: The source dataset does not include operational documentation or an active point of contact for data inquiries.
Independent Metric Standards: All business rules, data filters, and valid sales criteria were established independently by analyzing raw transaction patterns and applying standard e-commerce practices.

2. Project Question

The dataset is used to answer the following business question:

"How is the business performing based on valid product sales, and where are the opportunities or risks?"

The raw dataset will be investigated before defining what will be treated as a valid product sale for this analysis.

3. Data Representation

Each row represents an item recorded on an invoice.

An invoice can contain multiple rows because an invoice may contain multiple items.

The data is therefore represented at the transaction-line level, rather than one row per invoice.

4. Source Columns
Column	Type	Description
Invoice	VARCHAR	Invoice number. A six-digit number identifies an invoice. An invoice beginning with C indicates a cancellation.
StockCode	VARCHAR	Code identifying a product or other transaction item.
Description	VARCHAR	Product or transaction item description.
Quantity	BIGINT	Number of units recorded on the transaction line.
InvoiceDate	VARCHAR	Date and time when the transaction was generated.
Price	DOUBLE	Unit price in British pounds (£).
Customer ID	BIGINT	Identifier assigned to a customer.
Country	VARCHAR	Country associated with the customer.
5. Raw Schema

The CSV is loaded into DuckDB with the following schema:

Column	DuckDB Type
Invoice	VARCHAR
StockCode	VARCHAR
Description	VARCHAR
Quantity	BIGINT
InvoiceDate	VARCHAR
Price	DOUBLE
Customer ID	BIGINT
Country	VARCHAR
