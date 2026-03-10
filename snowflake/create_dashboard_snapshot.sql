-- AU SMB Dashboard Snapshot Table
-- This query combines all 10 individual queries into one comprehensive view
-- Run this once to create the table, then schedule it to refresh daily

CREATE OR REPLACE TABLE app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot AS

WITH 
-- Step 1: Base accounts
accounts AS (
  SELECT
    aeo.BUSINESS_NAME AS business_name,
    aeo.BUSINESS_ID AS business_id,
    LOWER(ame.LDAP) AS am_ldap,
    ame.FIRST_NAME AS am_first_name,
    aeo.AM_SERVICE_LEVEL AS service_level,
    aeo.SELLER_CLASS AS seller_class,
    sfa.ID AS salesforce_id
  FROM app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
    ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
  LEFT JOIN app_sales.gold_layer.sfdc_account_raw_temp sfa
    ON aeo.SBS_BOOK_OF_BUSINESS_ID_C = sfa.SBS_BOOK_OF_BUSINESS_ID_C
  WHERE ame.AM_TEAM = 'AU SMB'
    AND aeo.IS_ACTIVELY_MANAGED = 1
),

-- Step 2: GPV metrics (annualized, 9-month, YoY)
gpv_data AS (
  SELECT
    gpv.BUSINESS_ID,
    gpv.OWNERSHIP_QTR,
    ROUND(SUM(gpv.GPV_LP) / 1000000, 2) AS gpv_millions,
    ROUND(SUM(gpv.GPV_LP_PRIOR_YEAR) / 1000000, 2) AS gpv_prior_millions,
    ROW_NUMBER() OVER (PARTITION BY gpv.BUSINESS_ID ORDER BY gpv.OWNERSHIP_QTR DESC) AS quarter_rank
  FROM am_analytics.am_analytics_etl.smb_varcomp_gpv gpv
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
    ON gpv.BUSINESS_ID = aeo.BUSINESS_ID
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
    ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
  WHERE ame.AM_TEAM = 'AU SMB'
    AND aeo.IS_ACTIVELY_MANAGED = 1
    AND gpv.OWNERSHIP_QTR >= DATEADD('month', -12, DATE_TRUNC('quarter', CURRENT_DATE()))
  GROUP BY gpv.BUSINESS_ID, gpv.OWNERSHIP_QTR
),

gpv_summary AS (
  SELECT
    BUSINESS_ID,
    -- Annualized GPV (last 4 quarters)
    SUM(CASE WHEN quarter_rank <= 4 THEN gpv_millions ELSE 0 END) AS gpv_annual,
    -- 9-month GPV (last 3 quarters)
    SUM(CASE WHEN quarter_rank <= 3 THEN gpv_millions ELSE 0 END) AS gpv_9month,
    -- YoY growth
    SUM(CASE WHEN quarter_rank <= 4 THEN gpv_millions ELSE 0 END) AS gpv_current,
    SUM(CASE WHEN quarter_rank <= 4 THEN gpv_prior_millions ELSE 0 END) AS gpv_prior,
    CASE 
      WHEN SUM(CASE WHEN quarter_rank <= 4 THEN gpv_prior_millions ELSE 0 END) > 0 
      THEN ROUND(
        ((SUM(CASE WHEN quarter_rank <= 4 THEN gpv_millions ELSE 0 END) - 
          SUM(CASE WHEN quarter_rank <= 4 THEN gpv_prior_millions ELSE 0 END)) / 
         SUM(CASE WHEN quarter_rank <= 4 THEN gpv_prior_millions ELSE 0 END)) * 100, 
        1
      )
      ELSE 0 
    END AS yoy_growth_pct
  FROM gpv_data
  GROUP BY BUSINESS_ID
),

-- Step 3: AR data
ar_data AS (
  SELECT
    aeo.BUSINESS_ID,
    SUM(CASE WHEN ar.AR_TYPE = 'AR_ADDED' THEN ar.AR_VALUE ELSE 0 END) AS ar_added,
    SUM(CASE WHEN ar.AR_TYPE = 'SAAS_AR' THEN ar.AR_VALUE ELSE 0 END) AS saas_ar
  FROM am_analytics.am_analytics_etl.smb_varcomp_ar_added ar
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
    ON ar.BUSINESS_ID = aeo.BUSINESS_ID
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
    ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
  WHERE ame.AM_TEAM = 'AU SMB'
    AND aeo.IS_ACTIVELY_MANAGED = 1
  GROUP BY aeo.BUSINESS_ID
),

-- Step 4: Activity metrics
activity_data AS (
  SELECT
    act.BUSINESS_ID,
    MAX(CASE WHEN act.IS_DM = 1 THEN act.ACTIVITY_DATE END) AS last_dm_date,
    COUNT(CASE WHEN act.ACTIVITY_DATE >= DATEADD('day', -30, CURRENT_DATE()) THEN 1 END) AS activities_30d,
    MAX(act.ACTIVITY_DATE) AS last_activity_date
  FROM app_merch_growth.app_merch_growth_etl.am_fact_activities act
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
    ON act.OWNER_ID = ame.SFDC_OWNER_ID
  WHERE ame.AM_TEAM = 'AU SMB'
    AND act.ACTIVITY_DATE >= DATEADD('month', -12, CURRENT_DATE())
    AND act.ACTIVITY_TYPE_GROUPED IN ('Call','Email','SMS','Field Visit','Google Meet','Slack')
  GROUP BY act.BUSINESS_ID
),

-- Step 5: Product adoption
product_data AS (
  SELECT
    dao.BUSINESS_ID,
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
),

-- Step 6: Location data
location_data AS (
  SELECT
    dao.BUSINESS_ID,
    vu.RECEIPT_CITY AS city,
    vu.RECEIPT_STATE AS state,
    vu.RECEIPT_POSTAL_CODE AS postal_code,
    COUNT(DISTINCT CASE WHEN vu.IS_UNIT = 1 AND vu.UNIT_ACTIVE_STATUS = TRUE
      THEN vu.BEST_AVAILABLE_UNIT_TOKEN END) AS location_count
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
),

-- Step 7: Contract status
contract_data AS (
  SELECT DISTINCT
    cd.BUSINESS_ID,
    TRUE AS has_active_contract
  FROM am_analytics.am_analytics_etl.smb_varcomp_contracts_detail cd
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2 aeo
    ON cd.BUSINESS_ID = aeo.BUSINESS_ID
  JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
    ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
  WHERE ame.AM_TEAM = 'AU SMB'
    AND aeo.IS_ACTIVELY_MANAGED = 1
    AND cd.CONTRACT_STATUS = 'Active'
)

-- Final: Join everything together
SELECT
  a.business_id,
  a.business_name,
  a.am_ldap,
  a.am_first_name,
  a.service_level,
  a.seller_class,
  a.salesforce_id,
  
  -- GPV metrics
  COALESCE(g.gpv_annual, 0) AS gpv_annual_millions,
  COALESCE(g.gpv_9month, 0) AS gpv_9month_millions,
  COALESCE(g.yoy_growth_pct, 0) AS yoy_growth_pct,
  
  -- AR metrics
  COALESCE(ar.ar_added, 0) AS ar_added,
  COALESCE(ar.saas_ar, 0) AS saas_ar,
  
  -- Activity metrics
  COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) AS days_since_last_dm,
  COALESCE(act.activities_30d, 0) AS activities_30d,
  act.last_activity_date,
  
  -- Product & location
  COALESCE(p.products, '') AS products,
  COALESCE(l.city, '') AS city,
  COALESCE(l.state, '') AS state,
  COALESCE(l.postal_code, '') AS postal_code,
  COALESCE(l.location_count, 0) AS location_count,
  
  -- Contract
  COALESCE(c.has_active_contract, FALSE) AS has_active_contract,
  
  -- Computed fields
  CASE 
    WHEN COALESCE(g.gpv_annual, 0) >= 1.0 THEN 'Tier 1'
    WHEN COALESCE(g.gpv_annual, 0) >= 0.3 THEN 'Tier 2'
    ELSE 'Tier 3'
  END AS gpv_tier,
  
  -- Health score (0-100)
  LEAST(100, GREATEST(0, ROUND(
    -- GPV velocity (0-50)
    CASE 
      WHEN COALESCE(g.yoy_growth_pct, 0) > 0 THEN 50
      WHEN COALESCE(g.yoy_growth_pct, 0) > -10 THEN 30
      ELSE 10
    END +
    -- Contact recency (0-20)
    CASE
      WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 30 THEN 20
      WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 90 THEN 10
      ELSE 0
    END +
    -- Product adoption (0-15)
    LEAST(15, (LENGTH(COALESCE(p.products, '')) - LENGTH(REPLACE(COALESCE(p.products, ''), ',', '')) + 
      CASE WHEN LENGTH(COALESCE(p.products, '')) > 0 THEN 1 ELSE 0 END) * 3) +
    -- Contract (0-10)
    CASE WHEN COALESCE(c.has_active_contract, FALSE) THEN 10 ELSE 0 END +
    -- Tenure (0-5) - placeholder, would need tenure data
    2.5
  , 0))) AS health_score,
  
  -- Risk status
  CASE
    WHEN LEAST(100, GREATEST(0, ROUND(
      CASE WHEN COALESCE(g.yoy_growth_pct, 0) > 0 THEN 50 WHEN COALESCE(g.yoy_growth_pct, 0) > -10 THEN 30 ELSE 10 END +
      CASE WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 30 THEN 20 WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 90 THEN 10 ELSE 0 END +
      LEAST(15, (LENGTH(COALESCE(p.products, '')) - LENGTH(REPLACE(COALESCE(p.products, ''), ',', '')) + CASE WHEN LENGTH(COALESCE(p.products, '')) > 0 THEN 1 ELSE 0 END) * 3) +
      CASE WHEN COALESCE(c.has_active_contract, FALSE) THEN 10 ELSE 0 END + 2.5
    , 0))) >= 65 THEN 'healthy'
    WHEN LEAST(100, GREATEST(0, ROUND(
      CASE WHEN COALESCE(g.yoy_growth_pct, 0) > 0 THEN 50 WHEN COALESCE(g.yoy_growth_pct, 0) > -10 THEN 30 ELSE 10 END +
      CASE WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 30 THEN 20 WHEN COALESCE(DATEDIFF('day', act.last_dm_date, CURRENT_DATE()), 999) < 90 THEN 10 ELSE 0 END +
      LEAST(15, (LENGTH(COALESCE(p.products, '')) - LENGTH(REPLACE(COALESCE(p.products, ''), ',', '')) + CASE WHEN LENGTH(COALESCE(p.products, '')) > 0 THEN 1 ELSE 0 END) * 3) +
      CASE WHEN COALESCE(c.has_active_contract, FALSE) THEN 10 ELSE 0 END + 2.5
    , 0))) >= 40 THEN 'watch'
    ELSE 'at_risk'
  END AS risk_status,
  
  -- Metadata
  CURRENT_TIMESTAMP() AS snapshot_timestamp

FROM accounts a
LEFT JOIN gpv_summary g ON a.business_id = g.BUSINESS_ID
LEFT JOIN ar_data ar ON a.business_id = ar.BUSINESS_ID
LEFT JOIN activity_data act ON a.business_id = act.BUSINESS_ID
LEFT JOIN product_data p ON a.business_id = p.BUSINESS_ID
LEFT JOIN location_data l ON a.business_id = l.BUSINESS_ID
LEFT JOIN contract_data c ON a.business_id = c.BUSINESS_ID
;

-- Verify the table was created
SELECT 
  COUNT(*) AS total_accounts,
  COUNT(CASE WHEN risk_status = 'at_risk' THEN 1 END) AS at_risk_count,
  COUNT(CASE WHEN risk_status = 'watch' THEN 1 END) AS watch_count,
  COUNT(CASE WHEN risk_status = 'healthy' THEN 1 END) AS healthy_count,
  ROUND(SUM(gpv_annual_millions), 1) AS total_gpv_millions,
  MAX(snapshot_timestamp) AS snapshot_time
FROM app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot;
