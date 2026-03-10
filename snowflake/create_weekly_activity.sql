-- Weekly Activity Snapshot
-- Creates a table with weekly activity metrics (last 5 weeks)

CREATE OR REPLACE TABLE app_merch_growth.mbrown_sandbox.au_smb_weekly_activity AS

SELECT
  LOWER(ame.LDAP) AS am_ldap,
  ame.FIRST_NAME AS am_first_name,
  DATE_TRUNC('week', act.ACTIVITY_DATE)::DATE AS week_start_date,
  COUNT(*) AS total_activities,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Call' THEN 1 END) AS calls,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Email' THEN 1 END) AS emails,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'SMS' THEN 1 END) AS sms,
  COUNT(CASE WHEN act.IS_DM = 1 THEN 1 END) AS decision_maker_contacts,
  ROUND(SUM(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Call' THEN act.CALL_DURATION_SECONDS ELSE 0 END) / 3600.0, 1) AS call_hours,
  CURRENT_TIMESTAMP() AS snapshot_timestamp
FROM app_merch_growth.app_merch_growth_etl.am_fact_activities act
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON act.OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND act.ACTIVITY_DATE >= DATEADD('week', -5, DATE_TRUNC('week', CURRENT_DATE()))
  AND act.ACTIVITY_TYPE_GROUPED IN ('Call','Email','SMS','Field Visit','Google Meet','Slack')
GROUP BY LOWER(ame.LDAP), ame.FIRST_NAME, DATE_TRUNC('week', act.ACTIVITY_DATE)::DATE
ORDER BY week_start_date DESC, total_activities DESC;

-- Verify
SELECT 
  week_start_date,
  COUNT(DISTINCT am_ldap) AS am_count,
  SUM(total_activities) AS team_activities
FROM app_merch_growth.mbrown_sandbox.au_smb_weekly_activity
GROUP BY week_start_date
ORDER BY week_start_date DESC;
