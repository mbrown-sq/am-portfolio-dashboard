-- Get GPV data (annualized, 9-month trailing, YoY)
SELECT
  gpv.BUSINESS_ID AS bid,
  ROUND(SUM(gpv.GPV_LP) / 1000000, 2) AS g,
  ROUND(SUM(gpv.GPV_LP_PRIOR_YEAR) / 1000000, 2) AS g_prior,
  gpv.OWNERSHIP_QTR
FROM am_analytics.am_analytics_etl.smb_varcomp_gpv gpv
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON gpv.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
  AND gpv.OWNERSHIP_QTR >= DATEADD('month', -12, DATE_TRUNC('quarter', CURRENT_DATE()))
GROUP BY gpv.BUSINESS_ID, gpv.OWNERSHIP_QTR
ORDER BY gpv.BUSINESS_ID, gpv.OWNERSHIP_QTR DESC
