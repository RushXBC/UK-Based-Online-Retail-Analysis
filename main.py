import polars as pl
import sqlite3

csv_path = r"C:\Users\Epson\Desktop\online_retail_valid_sales.csv"
db_path = r"C:\Users\Epson\Desktop\online_retail.db"

print("Reading CSV with Polars...")
df = pl.read_csv(
    csv_path,
    schema_overrides={"Invoice": pl.String, "StockCode": pl.String}
)

print("Exporting to SQLite Database...")
conn = sqlite3.connect(db_path)
df.to_pandas().to_sql("sales_data", conn, if_exists="replace", index=False)
conn.close()

print(f"Done! Database created at: {db_path}")