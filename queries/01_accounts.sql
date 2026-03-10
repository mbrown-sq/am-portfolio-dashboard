-- Get all AU SMB accounts (core account data)
SELECT
  aeo.BUSINESS_NAME AS n,
  aeo.BUSINESS_ID AS bid,
  LOWER(ame.LDAP) AS am,
  aeo.AM_SERVICE_LEVEL AS svc,
  aeo.SELLER_CLASS AS cls,
  aeo.IS_ACTIVELY_MANAGED,
  sfa.ID AS sf
FROM app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
LEFT JOIN app_sales.gold_layer.sfdc_account_raw_temp sfa
  ON aeo.SBS_BOOK_OF_BUSINESS_ID_C = sfa.SBS_BOOK_OF_BUSINESS_ID_C
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
