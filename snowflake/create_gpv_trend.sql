-- GPV Trend Snapshot
-- Creates a table with 6-month GPV trend at team level

CREATE OR REPLACE TABLE app_merch_growth.mbrown_sandbox.au_smb_gpv_trend AS

SELECT
  TO_CHAR(DATE_TRUNC('month', gpv.OWNERSHIP_QTR), 'Mon') AS month_label,
  DATE_TRUNC('month', gpv.OWNERSHIP_QTR) AS month_date,
  ROUND(SUM(gpv.GPV_LP) / 1000000, 1) AS gpv_millions,
  COUNT(DISTINCT gpv.BUSINESS_ID) AS merchant_count,
  CURRENT_TIMESTAMP() AS snapshot_timestamp
FROM am_analytics.am_analytics_etl.smb_varcomp_gpv gpv
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON gpv.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
  AND gpv.OWNERSHIP_QTR >= DATEADD('month', -6, DATE_TRUNC('month', CURRENT_DATE()))
GROUP BY DATE_TRUNC('month', gpv.OWNERSHIP_QTR)
ORDER BY month_date ASC;

-- Verify
SELECT * FROM app_merch_growth.mbrown_sandbox.au_smb_gpv_trend
ORDER BY month_date ASC;
