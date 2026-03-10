-- Get activity data (days since last, 30-day count, QTD metrics)
SELECT
  act.BUSINESS_ID AS bid,
  LOWER(ame.LDAP) AS am,
  MAX(CASE WHEN act.IS_DM = 1 THEN act.ACTIVITY_DATE END) AS last_dm_date,
  COUNT(CASE WHEN act.ACTIVITY_DATE >= DATEADD('day', -30, CURRENT_DATE()) THEN 1 END) AS a30,
  MAX(act.ACTIVITY_DATE) AS last_activity_date
FROM app_merch_growth.app_merch_growth_etl.am_fact_activities act
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON act.OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND act.ACTIVITY_DATE >= DATEADD('month', -12, CURRENT_DATE())
  AND act.ACTIVITY_TYPE_GROUPED IN ('Call','Email','SMS','Field Visit','Google Meet','Slack')
GROUP BY act.BUSINESS_ID, LOWER(ame.LDAP)
