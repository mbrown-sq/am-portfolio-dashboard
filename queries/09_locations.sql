-- Get location data
SELECT
  dao.BUSINESS_ID AS bid,
  vu.RECEIPT_CITY AS city,
  vu.RECEIPT_STATE AS state,
  vu.RECEIPT_POSTAL_CODE AS pc,
  COUNT(DISTINCT CASE WHEN vu.IS_UNIT = 1 AND vu.UNIT_ACTIVE_STATUS = TRUE
    THEN vu.BEST_AVAILABLE_UNIT_TOKEN END) AS locations
FROM app_bi.hexagon.vdim_user vu
JOIN app_merch_growth.public.dim_am_ownership dao
  ON vu.MERCHANT_TOKEN = dao.MERCHANT_TOKEN
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON dao.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
  AND vu.IS_CURRENTLY_DEACTIVATED = 0
GROUP BY dao.BUSINESS_ID, vu.RECEIPT_CITY, vu.RECEIPT_STATE, vu.RECEIPT_POSTAL_CODE
QUALIFY ROW_NUMBER() OVER (PARTITION BY dao.BUSINESS_ID
  ORDER BY MAX(vu.MERCHANT_LATEST_PAYMENT_DATE) DESC NULLS LAST) = 1
