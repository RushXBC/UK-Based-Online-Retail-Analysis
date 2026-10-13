/*
  RFM SEGMENT SUMMARY
  ==============================================================================
  Summarizes customer count and revenue share for each RFM segment.
  Used to identify concentration and revenue-at-risk patterns.
  ==============================================================================
*/

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    -- share of total customers this segment represents
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers,
    ROUND(SUM(total_spending), 2) AS segment_revenue,
    -- share of total revenue this segment represents
    ROUND(100.0 * SUM(total_spending) / SUM(SUM(total_spending)) OVER (), 1) AS pct_of_revenue
FROM 'output_csv_files/rfm_customer_segmentation.csv'
GROUP BY customer_segment
ORDER BY customer_count DESC;