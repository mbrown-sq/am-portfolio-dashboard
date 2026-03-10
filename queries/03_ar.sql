-- Get AR data
SELECT
  aeo.BUSINESS_ID AS bid,
  SUM(CASE WHEN ar.AR_TYPE = 'AR_ADDED' THEN ar.AR_VALUE ELSE 0 END) AS ar_added,
  SUM(CASE WHEN ar.AR_TYPE = 'SAAS_AR' THEN ar.AR_VALUE ELSE 0 END) AS sar
FROM am_analytics.am_analytics_etl.smb_varcomp_ar_added ar
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON ar.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
GROUP BY aeo.BUSINESS_ID
