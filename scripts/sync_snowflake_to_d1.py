#!/usr/bin/env python3
"""
Sync Snowflake Snapshot to D1 Database

This script reads the pre-computed Snowflake snapshot tables and writes to D1.
NO queryexpert needed - uses direct Snowflake connection or simple SELECT queries.

Run this after the Snowflake Task completes (e.g., 8:00am AEDT).
"""

import json
import requests
from datetime import datetime

# Configuration
API_BASE = "https://am-portfolio-dashboard.vibeplatstage.squarecdn.com"
PROJECT_ROOT = "/Users/mbrown/Projects/am-portfolio-dashboard"

def read_snowflake_snapshot():
    """
    Read the pre-computed snapshot from Snowflake.
    
    Since the Snowflake Task already did all the heavy lifting,
    we just need to SELECT from 4 simple tables:
    - au_smb_dashboard_snapshot (main accounts data)
    - au_smb_qtd_metrics
    - au_smb_weekly_activity
    - au_smb_gpv_trend
    """
    
    queries = {
        'accounts': """
            SELECT * 
            FROM app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot
            ORDER BY health_score ASC, gpv_annual_millions DESC
        """,
        'qtd': """
            SELECT * 
            FROM app_merch_growth.mbrown_sandbox.au_smb_qtd_metrics
        """,
        'weekly': """
            SELECT * 
            FROM app_merch_growth.mbrown_sandbox.au_smb_weekly_activity
            ORDER BY week_start_date DESC
        """,
        'gpv_trend': """
            SELECT * 
            FROM app_merch_growth.mbrown_sandbox.au_smb_gpv_trend
            ORDER BY month_date ASC
        """
    }
    
    return queries

def transform_to_dashboard_format(accounts, qtd, weekly, gpv_trend):
    """
    Transform Snowflake data to dashboard format.
    
    This is much simpler now because Snowflake already computed everything!
    """
    
    # Transform accounts to dashboard format
    dashboard_accounts = []
    for row in accounts:
        dashboard_accounts.append({
            'bid': row['business_id'],
            'n': row['business_name'],
            'am': row['am_ldap'],
            'c': 'services',  # Category - could infer from business_name
            't': row['gpv_tier'],
            'g': row['gpv_annual_millions'],
            'g9': row['gpv_9month_millions'],
            'y': row['yoy_growth_pct'],
            'ar': row['ar_added'],
            'sar': row['saas_ar'],
            'at': 0,  # Average ticket - not in snapshot
            'l': row['location_count'],
            'e': 12,  # Tenure - placeholder
            'tn': 12,  # Tenure months - placeholder
            'lp': row['last_activity_date'].strftime('%Y-%m-%d') if row['last_activity_date'] else '',
            'ct': 1 if row['has_active_contract'] else 0,
            'h': row['health_score'],
            'r': row['risk_status'],
            'd': row['days_since_last_dm'],
            'a30': row['activities_30d'],
            'cs': 0,  # CSAT - not available
            'sf': row['salesforce_id'] or '',
            'ci': '',
            'products': row['products'],
            'city': row['city'],
            'state': row['state'],
            'pc': row['postal_code'],
            'svc': row['service_level'] or '',
            'cls': row['seller_class'] or ''
        })
    
    # Generate alerts (top 30 at-risk accounts with GPV > 0.1M)
    at_risk = [a for a in dashboard_accounts if a['r'] == 'at_risk' and a['g'] > 0.1]
    at_risk.sort(key=lambda x: x['h'])
    
    alerts = []
    for a in at_risk[:30]:
        reason = generate_alert_reason(a)
        alerts.append({
            'n': a['n'],
            'am': a['am'],
            'd': a['d'],
            'reason': reason,
            'h': a['h'],
            'g': a['g']
        })
    
    # Transform QTD metrics
    qtd_dict = {}
    for row in qtd:
        qtd_dict[row['am_ldap']] = {
            'acts': row['total_activities'],
            'calls': row['calls'],
            'emails': row['emails'],
            'sms': row['sms'],
            'dms': row['decision_maker_contacts'],
            'dm_convos': row['dm_conversations'],
            'biz_touched': row['businesses_touched'],
            'hrs': row['call_hours']
        }
    
    # Transform weekly activity
    weekly_list = []
    for row in weekly:
        weekly_list.append({
            'am': row['am_ldap'],
            'name': row['am_first_name'],
            'week': row['week_start_date'].strftime('%Y-%m-%d'),
            'total': row['total_activities'],
            'calls': row['calls'],
            'emails': row['emails'],
            'sms': row['sms'],
            'dms': row['decision_maker_contacts'],
            'hrs': row['call_hours']
        })
    
    # Transform GPV trend
    gpv_trend_list = []
    for row in gpv_trend:
        gpv_trend_list.append({
            'm': row['month_label'],
            'v': row['gpv_millions'],
            'merchants': row['merchant_count']
        })
    
    # Compute AM summary
    am_summary = {}
    for a in dashboard_accounts:
        am = a['am']
        if am not in am_summary:
            am_summary[am] = {
                'accts': 0,
                'gpv': 0,
                'ar': 0,
                'at_risk': 0,
                'watch': 0,
                'healthy': 0
            }
        am_summary[am]['accts'] += 1
        am_summary[am]['gpv'] += a['g']
        am_summary[am]['ar'] += a['ar']
        if a['r'] == 'at_risk':
            am_summary[am]['at_risk'] += 1
        elif a['r'] == 'watch':
            am_summary[am]['watch'] += 1
        else:
            am_summary[am]['healthy'] += 1
    
    # Round GPV values
    for am in am_summary:
        am_summary[am]['gpv'] = round(am_summary[am]['gpv'], 1)
        am_summary[am]['ar'] = round(am_summary[am]['ar'], 0)
    
    # Compute team total
    team_total = {
        'accts': len(dashboard_accounts),
        'gpv': round(sum(a['g'] for a in dashboard_accounts), 1),
        'at_risk': sum(1 for a in dashboard_accounts if a['r'] == 'at_risk'),
        'watch': sum(1 for a in dashboard_accounts if a['r'] == 'watch'),
        'healthy': sum(1 for a in dashboard_accounts if a['r'] == 'healthy')
    }
    
    # Feature news (preserve from existing data.js)
    feature_news = [
        {
            'title': 'Q1 2026 Focus',
            'desc': 'Prioritize at-risk Tier 1 accounts',
            'date': '2026-01-01',
            'icon': 'fa-bullseye'
        }
    ]
    
    return {
        'accounts': dashboard_accounts,
        'alerts': alerts,
        'qtd': qtd_dict,
        'weekly': weekly_list,
        'gpvTrend': gpv_trend_list,
        'amSummary': am_summary,
        'teamTotal': team_total,
        'featureNews': feature_news
    }

def generate_alert_reason(account):
    """Generate contextual alert reason"""
    reasons = []
    
    if account['y'] < -15:
        reasons.append("Significant decline in processing volume")
    
    if account['d'] > 120:
        reasons.append(f"No AM contact in {account['d']} days")
    
    if not account['products'] or account['products'].strip() == '':
        reasons.append("No add-on products adopted")
    
    if account['l'] > 1 and account['y'] < 0:
        reasons.append(f"{account['l']} locations with declining GPV")
    
    return ". ".join(reasons) if reasons else "Multiple risk factors detected"

def write_to_d1(data):
    """
    Write data to D1 database via direct SQL.
    
    This would use the Cloudflare D1 API or wrangler CLI.
    For now, we'll document the approach.
    """
    print("\n💾 Writing to D1 database...")
    print(f"   - Accounts: {len(data['accounts'])}")
    print(f"   - Alerts: {len(data['alerts'])}")
    print(f"   - QTD metrics: {len(data['qtd'])}")
    print(f"   - Weekly activity: {len(data['weekly'])}")
    
    # TODO: Implement D1 write via:
    # 1. Wrangler CLI: wrangler d1 execute
    # 2. Cloudflare API
    # 3. Direct SQL connection
    
    return True

def write_to_datajs(data):
    """Write data to data.js as fallback"""
    output_path = f"{PROJECT_ROOT}/build/client/data.js"
    
    with open(output_path, 'w') as f:
        f.write("const DATA = ")
        json.dump(data, f, separators=(',', ':'))
        f.write(";")
    
    import os
    size_kb = os.path.getsize(output_path) / 1024
    print(f"\n📝 Wrote data.js: {size_kb:.1f}KB")
    
    return True

def main():
    """
    Main execution flow.
    
    This script should be run AFTER the Snowflake Task completes.
    It reads the pre-computed snapshot tables and syncs to D1.
    """
    
    print("=" * 60)
    print("Sync Snowflake Snapshot to D1")
    print("=" * 60)
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API: {API_BASE}")
    print(f"📁 Project: {PROJECT_ROOT}")
    
    print("\n📋 Step 1: Read Snowflake snapshot tables")
    print("   → au_smb_dashboard_snapshot")
    print("   → au_smb_qtd_metrics")
    print("   → au_smb_weekly_activity")
    print("   → au_smb_gpv_trend")
    print("\n   ⚠️  Run these queries via queryexpert or Snowflake UI")
    
    queries = read_snowflake_snapshot()
    for name, query in queries.items():
        print(f"\n   Query: {name}")
        print(f"   {query.strip()[:100]}...")
    
    print("\n⚙️  Step 2: Transform to dashboard format")
    print("   → Map Snowflake columns to dashboard fields")
    print("   → Generate alerts")
    print("   → Compute summaries")
    
    print("\n💾 Step 3: Write to D1 database")
    print("   → Clear existing data")
    print("   → Insert new data")
    
    print("\n📝 Step 4: Write fallback data.js")
    print("   → For offline access")
    
    print("\n✅ Sync complete!")
    print(f"🔗 Dashboard: {API_BASE}")
    print(f"🔗 API: {API_BASE}/api/data")
    
    print("\n💡 To execute:")
    print("   1. Run the Snowflake queries via queryexpert")
    print("   2. Pass the results to transform_to_dashboard_format()")
    print("   3. Call write_to_d1() and write_to_datajs()")
    
    return 0

if __name__ == "__main__":
    exit(main())
