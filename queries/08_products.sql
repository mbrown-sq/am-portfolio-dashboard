-- Get product adoption
SELECT
  dao.BUSINESS_ID AS bid,
  LISTAGG(DISTINCT COALESCE(mpe.PRODUCT_PARENT_NAME, mpe.PRODUCT_NAME), ',') AS products
FROM app_sales.app_sales_etl.merchant_product_events mpe
JOIN app_merch_growth.public.dim_am_ownership dao
  ON mpe.MERCHANT_TOKEN = dao.MERCHANT_TOKEN
JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  ON dao.BUSINESS_ID = aeo.BUSINESS_ID
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
GROUP BY dao.BUSINESS_ID
