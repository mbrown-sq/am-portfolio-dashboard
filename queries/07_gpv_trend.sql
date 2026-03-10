-- Get GPV trend (last 6 months, team-level)
SELECT
  TO_CHAR(DATE_TRUNC('month', gpv.OWNERSHIP_QTR), 'Mon') AS m,
  ROUND(SUM(gpv.GPV_LP) / 1000000, 1) AS v,
  COUNT(DISTINCT gpv.BUSINESS_ID) AS merchants
FROM am_analytics.am_analytics_etl.smb_varcomp_gpv gpv
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON gpv.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
  AND gpv.OWNERSHIP_QTR >= DATEADD('month', -6, DATE_TRUNC('month', CURRENT_DATE()))
GROUP BY DATE_TRUNC('month', gpv.OWNERSHIP_QTR)
ORDER BY DATE_TRUNC('month', gpv.OWNERSHIP_QTR) ASC
