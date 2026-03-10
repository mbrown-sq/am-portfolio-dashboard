-- Get QTD AM metrics
SELECT
  LOWER(ame.LDAP) AS am,
  COUNT(*) AS acts,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Call' THEN 1 END) AS calls,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Email' THEN 1 END) AS emails,
  COUNT(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'SMS' THEN 1 END) AS sms,
  COUNT(CASE WHEN act.IS_DM = 1 THEN 1 END) AS dms,
  COUNT(DISTINCT CASE WHEN act.IS_DM = 1 THEN act.BUSINESS_ID END) AS dm_convos,
  COUNT(DISTINCT act.BUSINESS_ID) AS biz_touched,
  ROUND(SUM(CASE WHEN act.ACTIVITY_TYPE_GROUPED = 'Call' THEN act.CALL_DURATION_SECONDS ELSE 0 END) / 3600.0, 1) AS hrs
FROM app_merch_growth.app_merch_growth_etl.am_fact_activities act
JOIN app_merch_growth.app_merch_growth_etl.am_fact_employment_current ame
  ON act.OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND act.ACTIVITY_DATE >= DATE_TRUNC('quarter', CURRENT_DATE())
  AND act.ACTIVITY_TYPE_GROUPED IN ('Call','Email','SMS','Field Visit','Google Meet','Slack')
GROUP BY LOWER(ame.LDAP)
