04 — Data Analysis

Objective

Analyze the prepared valid product sales data to answer the business question:

> "How is the business performing based on valid product sales, and where are the opportunities or risks?"

Each analysis below examines a different dimension of the data — overall performance, trend over time, product concentration, customer value, customer retention, and geography — to build a complete picture of business performance, risk, and opportunity.


1. Key Business Metrics (KPIs)

Calculates the core business metrics for valid product sales: total revenue, units sold, orders, customers, products, average order value, average basket size, average revenue per customer, average unit selling price, and average orders per customer.

Query: da_01_basic_kpis.sql

Output: output_csv_files/basic_kpis.csv


2. Monthly Sales Metrics

Breaks down the core KPIs (revenue, orders, customers, units sold, AOV, basket size) at a monthly grain to show trend over time.

Query: da_02_monthly_kpis.sql

Output: output_csv_files/monthly_kpis.csv


3. Monthly Revenue Growth Rate

Calculates month-over-month revenue and percent growth, to assess how consistently the business is growing.

Query: da_03_mom_growth_rate.sql

Output: output_csv_files/mom_growth_rate.csv

Visualization: images/monthly_revenue_mom_growth.png

Visualization: images/quarterly_revenue_share.png

FINDINGS:

Q4 drives the year. The final quarter accounts for over a third of annual revenue — 35.2% in 2010 (€3.3M) and 33.5% in 2011 (€3.2M) — driven by peak holiday and end-of-year shopping. November is the single strongest month, pulling in over €1.4M each year as early Christmas shopping and major holiday sales events take hold.

A sharp post-holiday slump follows. Revenue drops steeply from November into December (down ~46% in 2010 and ~58% in 2011) as shipping cutoffs pass before Christmas Day, then stays quiet through January and February. Q1 is consistently the quietest period, generating only about 20% of annual revenue.

The seasonal ramp is predictable and repeatable. Revenue builds quarter over quarter in a consistent pattern: Q1 (~20%) → Q2 (~21%) → Q3 (~25%) → Q4 (~34%), with notable rebounds in March and May that kick off spring momentum ahead of the late-summer buildup into Q4.

The pattern holds year over year. 2010 and 2011 show nearly identical seasonal rhythms, suggesting a highly predictable shopping calendar that can be planned around with confidence.

BUSINESS RECOMMENDATIONS:

* Prepare logistics ahead of the autumn surge. Boost warehouse staffing and build up top-selling inventory by late summer (August–September) to handle the November peak without delivery delays.

* Run targeted promotions through the Q1 lull. Clearance sales or New Year deals in January and February can help sustain purchasing activity through the predictable post-holiday slowdown.


4. Monthly Revenue Volatility (Outlier Detection)

Flags months whose revenue growth deviates significantly from the average month-over-month growth rate, using a z-score, to identify unusually strong or weak months. Reuses the month-over-month growth calculation from the previous analysis as its base.

Query: da_04_monthly_revenue_outlier_analysis.sql

Output: output_csv_files/monthly_revenue_outlier_analysis.csv

Visualization: images/mom_growth_volatility_tiers.png

FINDINGS:

Most months remain highly stable in the Normal Range. A total of 15 out of 24 months (Jan, Feb, Apr, May, Jun, Jul, Aug, Sep, Oct 2010; Jan, Feb, Jun, Jul, Aug, Oct 2011) remain within standard baseline boundaries (<= 1 SD). These stable periods provide high operational predictability for baseline staffing and supply chain operations.

Moderate shifts align directly with seasonal inflection points. Eight months fall into the Moderate Shift tier (1–2 SD): March, November, and December 2010; March, April, May, September, and November 2011. These statistical swings represent predictable business milestones—specifically spring rebounds (March/May), pre-holiday ramp-ups (September/November), and immediate post-peak contractions (April/December 2010)—rather than random volatility.

December 2011 stands as the single true outlier. Only one month across the entire 24-month dataset triggers Outlier status (> 2 SD): December 2011 with a sharp drop of -57.7% (Z-score: 2.22). While a December decline is expected following the November peak, the depth of this drop significantly exceeded December 2010 (-45.8%), marking it as the primary operational risk point.

BUSINESS RECOMMENDATIONS:

* Treat Moderate Shifts as Planned Milestones: Overall business risk remains low since 23 out of 24 months fall within expected or manageable bounds. Management can treat Moderate Tier shifts as normal seasonal milestones rather than unexpected operational shocks.

* Buffer for the December Drop-off: Operations and inventory management must account for the steep post-November drop so the business isn't left overstaffed or carrying excess holiday inventory into January.


5. Cumulative Product Revenue Share

Ranks products from highest to lowest revenue and calculates each product's individual and cumulative share of total revenue, to assess how concentrated revenue is across the product catalog.

Query: da_05_cumulative_product_revenue_share.sql

Output: output_csv_files/cumulative_product_revenue_share.csv


6. Pareto Analysis (80/20 Rule) for Product Revenue

Determines how many products, and what share of the total catalog, are required to generate 80% of total revenue — a direct measure of product concentration risk.

Query: da_06_pareto_summary.sql

Output: output_csv_files/pareto_summary.csv

FINDINGS:

Strict Alignment with the 80/20 Rule: Top-performing SKUs represent 21.24% of the catalog, generating 80% of total sales across the 4,902 evaluated products.

Concentrated Revenue in Core Catalog: A core subset of 1,041 SKUs drives the vast majority of total sales, forming the main driver of overall business revenue.

Large Long-Tail Inventory: The remaining 78.76% of products (3,861 SKUs) account for only 20% of total sales, showing a massive long tail of slow-moving inventory.

BUSINESS RECOMMENDATIONS:

* Focus Procurement on Core SKUs: Inventory and supply chain teams prioritize stock replenishment for the 1,041 core SKUs to prevent stockouts on top-selling products.

* Review Long-Tail Catalog for Clearance: Merchandising teams audit the 3,861 low-performing SKUs to identify slow-moving items for discount clearance or delisting.

* Align Ad Spend with High-Yield SKUs: Performance marketing shifts ad budget toward the top 21.24% of products to maximize return on ad spend (ROAS).

NOTE: Refer to da_06a_pareto_tier_a_skus.sql (output exported to pareto_tier_a_skus.csv) and da_06b_pareto_tail_skus.sql (output exported to pareto_tail_skus.csv) to view the specific product queries for the top 80% and bottom 20% revenue drivers, respectively.


7. RFM Customer Segmentation

Segments customers based on Recency, Frequency, and Monetary value to identify customer value patterns and segments at risk of churn. Customers are scored 1–5 on each dimension and grouped into named segments: Champions, Loyal Customers, Slipping Loyalists, At Risk (High Value), New / Promising, Hibernating (High Value), Hibernating, Lost / Churned, and Standard / Active (residual segment for customers not captured by another rule).

Query: da_07_rfm_customer_segmentation.sql

Output: output_csv_files/rfm_customer_segmentation.csv

NOTE: Note: Refer to Section 8 (RFM Segment Summary) for the analysis on this segment distribution, as customer values are aggregated and quantified there.

8. RFM Segment Summary

Summarizes customer count and revenue share for each RFM segment, to quantify customer concentration and the revenue currently sitting in at-risk segments. This query reads from the exported RFM segmentation output (output_csv_files/rfm_customer_segmentation.csv) rather than the raw valid_product_sales.csv, since it summarizes the results of the segmentation analysis above rather than recalculating them.

Query: da_08_rfm_overall_segment_distribution.sql

Output: output_csv_files/rfm_overall_segment_distribution.csv

FINDING:

Strict Alignment with the 80/20 Rule: Top-performing SKUs represent 21.24% of the catalog, generating 80% of total sales across the 4,902 evaluated products.

Concentrated Revenue in Core Catalog: A core subset of 1,041 SKUs drives the vast majority of total sales, forming the main driver of overall business revenue.

Large Long-Tail Inventory: The remaining 78.76% of products (3,861 SKUs) account for only 20% of total sales, showing a massive long tail of slow-moving inventory.

BUSINESS RECOMMENDATIONS:

* Focus Procurement on Core SKUs: Inventory and supply chain teams prioritize stock replenishment for the 1,041 core SKUs to prevent stockouts on top-selling products.

* Review Long-Tail Catalog for Clearance: Merchandising and warehouse operations teams audit the 3,861 low-performing SKUs to identify slow-moving items for discount clearance or delisting, freeing up valuable shelf space and reducing warehouse storage overhead currently tied up in low-yielding inventory.


9. Country-Level Sales Performance

Aggregates revenue, transactions, customers, and average order value by country, along with each country's percentage contribution to total revenue, to identify geographic concentration and performance differences across markets.

Query: da_09_country_level_metrics.sql

Output: output_csv_files/country_level_metrics.csv

FINDINGS:

Single-Market Revenue Dependence (UK): The business relies heavily on the United Kingdom, which generates 85.77% of total revenue (16,849,429.02 across 5,347 customers and 36,238 transactions). Any downturn or disruption in the domestic market creates a major risk for total company revenue.

Account Concentration Risk in Netherlands: The Netherlands contributes 2.80% of total revenue (549,773.41) from just 22 registered customers across 216 transactions. Because average order value is extremely high (2,545.25), losing even 2 or 3 of these accounts would noticeably impact international revenue.

Lower Spend in Core Secondary Markets: Germany (107 customers, 1.95% share) and France (94 customers, 1.59% share) represent the largest customer bases outside the UK. However, their average order values (509.02 and 518.28, respectively) are close to the UK baseline (464.97), showing lower order sizes compared to the Netherlands.

High Operational Overhead in Long-Tail Markets: 29 out of 39 countries contribute 0.50% or less to total revenue. Fulfilling orders for markets with very few transactions (e.g., Nigeria with 1 transaction totaling 112.57, or Saudi Arabia with 1 transaction totaling 145.92) increases shipping and handling complexity relative to revenue generated.

Guest Checkouts & Untracked Accounts: Data shows revenue in territories such as Hong Kong (13,666.45 revenue, 9 transactions) and Bermuda (1,253.14 revenue, 1 transaction) with 0 registered customers, indicating guest checkouts without user account creation alongside potential missing customer IDs in transaction logs.

BUSINESS RECOMMENDATIONS:

* Focus Growth Initiatives on Germany and France: Marketing teams target existing customer bases in Germany (107 customers) and France (94 customers) with product bundles to increase average order values beyond the current ~510.00 level.

* Assign Account Retention Support to Key Dutch Buyers: Sales and support teams establish regular check-ins with the 22 accounts in the Netherlands to track account health and protect the 549,773.41 revenue stream.

* Review Shipping Policies for Low-Volume Countries: Operations teams evaluate minimum purchase requirements for international orders in markets contributing 0.50% or less of revenue to ensure shipping costs do not offset margins.

* Implement Guest Profile Stitching at Checkout: IT and analytics teams update checkout workflows to prompt account creation or track guest sessions using browser/session identifiers, resolving untracked revenue in regions showing 0 registered customers (such as Hong Kong and Bermuda).


10. Cohort Retention Analysis

Groups customers by their first purchase month and tracks what percentage of each cohort continues purchasing in the months following acquisition, to assess customer retention over time. Two versions of this analysis were built, using different definitions of "retained":

A. Monthly Purchase Retention — a customer is counted as retained in a given month only if they made a purchase in that specific calendar month. This is a strict, month-by-month view of repeat purchase activity.

Query: da_10a_monthly_cohort_purchase_retention.sql

Output: output_csv_files/monthly_cohort_purchase_retention.csv

FINDINGS:

Dec 2009 Cohort Benchmark: The Dec 2009 cohort maintains the highest long-term repeat purchase rates (25.45%–42.48%) across the two-year period.

November Re-engagement Peaks: Retention consistently rises every November across active cohorts (reaching 34%–40% in Nov 2011) due to Q4 pre-holiday retail demand.

Stable 5%–25% Retention Floor: Following Month 0, repeat purchase rates settle into a predictable baseline range of 5% to 25% across most cohorts.

Top-of-Funnel Acquisition Decline: Initial cohort sizes contract significantly over time, falling from 951 customers in Dec 2009 to an average of ~100 per month in 2011.

Q1 2011 First-Month Dip: Month 1 retention experiences a temporary trough between Dec 2010 and Mar 2011 (dropping to 9.21% in Dec 2010) before recovering to 31.67% by Oct 2011.

Dec 2011 Data Truncation: Universal drops in the final Dec 2011 column reflect a partial-month data extraction cutoff rather than customer churn.

BUSINESS RECOMMENDATIONS:

* Optimization of First-Month Onboarding Sequences: Marketing implements post-purchase triggers and second-order incentives during early-lifecycle troughs (Dec 2010 at 9.21%, Jan 2011 at 16.67%) to secure immediate repeat orders.

* Operational Readiness for November Demand Peaks: Fulfillment and inventory planning teams secure stock allocations early to manage the November surge (34%–40% retention) and prevent Q4 stockouts.

* Restoration of Top-of-Funnel Acquisition: Performance marketing audits acquisition channels to reverse the volume drop from 951 users in Dec 2009 to ~100 per month in 2011.

* Segmented VIP Campaigns for High-Value Cohorts: CRM targets high-performing groups—specifically Dec 2009 (25%–42% retention)—with exclusive perks to maximize lifetime value.

* Mid-Year Promotional Strategies: E-commerce teams run off-peak category cross-sells during low periods (Sep 2011 at 2.63%) to elevate floor retention metrics.

* Standardization of Data Cutoff Labeling: Analytics explicitly annotates partial-month reporting periods like Dec 2011 on dashboards to prevent mistaking reporting lag for customer churn.

B. 90-Day Grace Period Retention — a customer remains counted as retained as long as they make at least one purchase within any rolling 90-day window; they are only considered churned once they exceed 90 days without a purchase. This better reflects retail purchase behavior, where customers may skip a calendar month without having actually churned.

Query: da_10b_customer_cohort_survival_90d.sql

Output: output_csv_files/customer_cohort_survival_90d.csv

FINDINGS:

Dec 2009 Cohort Benchmark: The Dec 2009 cohort maintains the highest cumulative survival rate across the entire 24-month horizon, ending at 18.61% retention in Dec 2011.   

90-Day Inactivity Rule Artifact: Because churn is defined as 90 consecutive days of inactivity, every cohort displays 100% survival across its first three months (Month 0 through Month 2).   

Post-90-Day Cliff: Steep drop-offs occur immediately in Month 3 across almost all cohorts. For example, the Dec 2009 cohort drops from 100% to 62.99% in Mar 2010, while the Dec 2010 cohort drops from 100% to 18.42% in Mar 2011.   

Top-of-Funnel Acquisition Decline: Initial cohort sizes contract significantly over time, falling from 951 customers in Dec 2009 to an average of ~100 per month in 2011, reaching a low of 28 customers in Dec 2011.   

Complete Churn in Weak Cohorts: The Dec 2010 cohort experiences complete cumulative customer attrition, reaching 0% retention by Oct 2011.   

Survival Floor Range: Excluding the zeroed-out Dec 2010 cohort, long-term survival rates across mature cohorts settle into a floor between 3.75% and 18.61% by Dec 2011.   

BUSINESS RECOMMENDATIONS:

* Optimization of Post-90-Day Re-engagement Sequences: Marketing triggers targeted reactivation offers right before the 90-day inactivity mark to catch the steep Month 3 drop-off (such as Dec 2010 falling to 18.42%).   

* Restoration of Top-of-Funnel Acquisition: Performance marketing audits acquisition channels to fix the volume drop from 951 users in Dec 2009 down to 28 users in Dec 2011.   

* Investigation of Dec 2010 Cohort Attrition Mechanics: CRM and product teams review onboarding factors that caused total customer loss (0% retention) in Dec 2010 to prevent similar churn patterns in newer cohorts.

**Both query versions pivot the results into a cohort retention matrix (cohort month as rows, months since acquisition — M00 through M24 — as columns).**