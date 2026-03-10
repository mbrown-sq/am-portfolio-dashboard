# AU SMB Dashboard Queries

This directory contains the SQL queries used to refresh the dashboard data.

## Query Files

| File | Purpose | Key Fields |
|------|---------|-----------|
| `01_accounts.sql` | Base account list with ownership | n, bid, am, svc, cls, sf |
| `02_gpv.sql` | GPV metrics (annual, 9mo, YoY) | bid, g, g_prior, OWNERSHIP_QTR |
| `03_ar.sql` | Annual Recurring Revenue | bid, ar_added, sar |
| `04_activity.sql` | Activity metrics per account | bid, am, last_dm_date, a30 |
| `05_qtd_metrics.sql` | Quarter-to-date AM metrics | am, acts, calls, emails, dms, hrs |
| `06_weekly_activity.sql` | Weekly activity (last 5 weeks) | am, name, week, total, calls, dms |
| `07_gpv_trend.sql` | Team-level GPV trend (6 months) | m, v, merchants |
| `08_products.sql` | Product adoption per account | bid, products |
| `09_locations.sql` | Location data per account | bid, city, state, pc, locations |
| `10_contracts.sql` | Contract status | bid, ct |

## Data Model

### Accounts
Each account record contains:
- **Identity**: n (name), bid (business_id), am (owner ldap)
- **Classification**: c (category), t (tier), svc (service level), cls (seller class)
- **Financial**: g (GPV annual), g9 (GPV 9mo), y (YoY %), ar (AR), sar (SaaS AR)
- **Operational**: l (locations), products, city, state, pc (postal code)
- **Engagement**: d (days since DM), a30 (activities 30d), lp (last processed)
- **Health**: h (health score 0-100), r (risk status), ct (contracted)
- **Metadata**: sf (Salesforce ID), tn (tenure months)

### Health Score Formula
```python
h = min(100, max(0, round(
  (50 if y > 0 else 30 if y > -10 else 10) +      # GPV velocity (0-50)
  (20 if d < 30 else 10 if d < 90 else 0) +       # Contact recency (0-20)
  (min(15, product_count * 3)) +                   # Product adoption (0-15)
  (10 if ct else 0) +                              # Contract (0-10)
  (min(5, tn / 12))                                # Tenure (0-5)
)))
```

### Risk Status
- **healthy**: h ≥ 65
- **watch**: 40 ≤ h < 65
- **at_risk**: h < 40

### GPV Tiers
- **Tier 1**: g ≥ 1.0M AUD
- **Tier 2**: 0.3M ≤ g < 1.0M AUD
- **Tier 3**: g < 0.3M AUD

## Execution

### Via Goose Recipe (Recommended)
```bash
# Schedule the refresh
goose run recipes/data-refresh-v2.yaml
```

### Manual Execution
```bash
# 1. Execute each query via queryexpert
for sql in queries/*.sql; do
  echo "Executing $sql..."
  # Use queryexpert__execute_query tool
done

# 2. Process results
python scripts/refresh_data.py

# 3. Deploy
cd /Users/mbrown/Projects/am-portfolio-dashboard
goose-sites deploy am-portfolio-dashboard ./build -m "Manual refresh"
```

## Data Sources

All queries use these Snowflake tables:
- `app_merch_growth.app_merch_growth_etl.am_fact_account_ownership_v2`
- `app_merch_growth.app_merch_growth_etl.am_fact_employment_current`
- `am_analytics.am_analytics_etl.smb_varcomp_gpv`
- `am_analytics.am_analytics_etl.smb_varcomp_ar_added`
- `app_merch_growth.app_merch_growth_etl.am_fact_activities`
- `am_analytics.am_analytics_etl.smb_varcomp_contracts_detail`
- `app_sales.app_sales_etl.merchant_product_events`
- `app_bi.hexagon.vdim_user`
- `app_merch_growth.public.dim_am_ownership`
- `app_sales.gold_layer.sfdc_account_raw_temp`

## Filters

All queries use these standard filters:
- `ame.AM_TEAM = 'AU SMB'`
- `aeo.IS_ACTIVELY_MANAGED = 1`

## Output Format

Results are assembled into `build/client/data.js`:
```javascript
const DATA = {
  accounts: [...],      // Array of account objects
  alerts: [...],        // Top 30 at-risk accounts
  qtd: {...},          // QTD metrics by AM
  weekly: [...],       // Weekly activity data
  gpvTrend: [...],     // 6-month GPV trend
  amSummary: {...},    // Aggregated metrics per AM
  teamTotal: {...},    // Team-level totals
  featureNews: [...]   // Manually curated news
};
```

## Troubleshooting

### Query Timeout
If queries timeout, increase the timeout in the recipe:
```yaml
extensions:
  - type: builtin
    name: queryexpert
    timeout: 900  # 15 minutes
```

### Missing Data
If a query returns no results:
1. Check the AM_TEAM filter value
2. Verify IS_ACTIVELY_MANAGED = 1 is appropriate
3. Check date ranges (queries look back 6-12 months)

### Large Result Sets
If data.js exceeds 1MB:
1. Consider filtering to only active accounts
2. Reduce historical data range
3. Migrate to D1 database + API (see migrations/0001_initial.sql)
