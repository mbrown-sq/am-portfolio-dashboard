-- Get contract status
SELECT DISTINCT
  cd.BUSINESS_ID AS bid,
  TRUE AS ct
FROM am_analytics.am_analytics_etl.smb_varcomp_contracts_detail cd
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON cd.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
  AND cd.CONTRACT_STATUS = 'Active'
