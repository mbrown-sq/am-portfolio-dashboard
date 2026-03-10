-- Schedule Daily Refresh of AU SMB Dashboard Snapshot
-- This creates a Snowflake Task that runs at 7:30am AEDT (9:30pm UTC) every day

-- Step 1: Create the task
CREATE OR REPLACE TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard
  WAREHOUSE = COMPUTE_WH  -- Change to your warehouse name
  SCHEDULE = 'USING CRON 30 21 * * * UTC'  -- 7:30am AEDT (during daylight saving)
  -- Note: For AEST (no daylight saving), use: 30 22 * * * UTC
AS
  CREATE OR REPLACE TABLE app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot AS
  -- (Copy the entire SELECT statement from create_dashboard_snapshot.sql here)
  -- Or use: CALL refresh_dashboard_procedure(); if you create a stored procedure
  
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
  
  -- (Include all other CTEs from create_dashboard_snapshot.sql)
  -- For brevity, I'm showing just the structure here
  -- In practice, copy the entire query from create_dashboard_snapshot.sql
  
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
  )
  
  -- ... (include all other CTEs)
  
  SELECT * FROM accounts
  -- ... (complete the query)
;

-- Step 2: Resume the task (starts the schedule)
ALTER TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard RESUME;

-- Step 3: Verify the task was created
SHOW TASKS LIKE 'refresh_au_smb_dashboard' IN SCHEMA app_merch_growth.mbrown_sandbox;

-- Step 4: Check task history (after it runs)
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'REFRESH_AU_SMB_DASHBOARD',
  SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC;

-- IMPORTANT NOTES:
-- 1. Replace COMPUTE_WH with your actual warehouse name
-- 2. You need EXECUTE TASK privilege to create tasks
-- 3. The task will run at 7:30am AEDT (9:30pm UTC) daily
-- 4. For AEST (non-daylight saving), change cron to: 30 22 * * * UTC
-- 5. To pause the task: ALTER TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard SUSPEND;
-- 6. To run manually: EXECUTE TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard;
