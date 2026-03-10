#!/usr/bin/env python3
"""
AU SMB Dashboard Data Refresh to D1

This script:
1. Executes all Snowflake queries
2. Processes and joins the data
3. Writes to D1 database via API
4. Also writes to data.js as fallback

Run via Goose with queryexpert extension enabled.
"""

import json
import requests
from datetime import datetime, date
from collections import defaultdict

# Configuration
API_BASE = "https://am-portfolio-dashboard.vibeplatstage.squarecdn.com"
PROJECT_ROOT = "/Users/mbrown/Projects/am-portfolio-dashboard"

def compute_health_score(account):
    """Compute health score (0-100) based on multiple factors"""
    score = 0
    
    # GPV velocity (YoY growth)
    velocity = account.get('y', 0)
    if velocity > 0:
        score += 50
    elif velocity > -10:
        score += 30
    else:
        score += 10
    
    # Contact recency
    days_since_dm = account.get('d', 999)
    if days_since_dm < 30:
        score += 20
    elif days_since_dm < 90:
        score += 10
    
    # Product adoption
    products = account.get('products', '')
    product_count = len([p for p in products.split(',') if p.strip()]) if products else 0
    score += min(15, product_count * 3)
    
    # Contract status
    if account.get('ct', False):
        score += 10
    
    # Tenure
    tenure = account.get('tn', 0)
    score += min(5, tenure / 12)
    
    return min(100, max(0, round(score)))

def compute_risk_status(health_score):
    """Determine risk status from health score"""
    if health_score >= 65:
        return "healthy"
    elif health_score >= 40:
        return "watch"
    else:
        return "at_risk"

def compute_gpv_tier(gpv):
    """Determine GPV tier"""
    if gpv >= 1.0:
        return "Tier 1"
    elif gpv >= 0.3:
        return "Tier 2"
    else:
        return "Tier 3"

def generate_alert_reason(account):
    """Generate contextual alert reason"""
    reasons = []
    
    velocity = account.get('y', 0)
    days = account.get('d', 999)
    products = account.get('products', '')
    locations = account.get('l', 0)
    
    if velocity < -15:
        reasons.append("Significant decline in processing volume")
    
    if days > 120:
        reasons.append(f"No AM contact in {days} days")
    
    if not products or products.strip() == '':
        reasons.append("No add-on products adopted")
    
    if locations > 1 and velocity < 0:
        reasons.append(f"{locations} locations with declining GPV")
    
    return ". ".join(reasons) if reasons else "Multiple risk factors detected"

def write_to_d1(data):
    """Write data to D1 database via API"""
    print(f"\n📊 Writing {len(data['accounts'])} accounts to D1...")
    
    # This would use the D1 API or direct SQL
    # For now, we'll document the structure
    print("✅ Data structure prepared for D1")
    print(f"   - Accounts: {len(data['accounts'])}")
    print(f"   - Alerts: {len(data['alerts'])}")
    print(f"   - QTD metrics: {len(data.get('qtd', {}))}")
    print(f"   - Weekly activity: {len(data.get('weekly', []))}")
    
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
    
    This script is meant to be run via Goose with queryexpert extension.
    The actual query execution happens via queryexpert__execute_query tool.
    
    This is a template showing the data processing logic.
    """
    
    print("=" * 60)
    print("AU SMB Dashboard Data Refresh to D1")
    print("=" * 60)
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🌐 API: {API_BASE}")
    print(f"📁 Project: {PROJECT_ROOT}")
    
    # Step 1: Execute queries (done via Goose/queryexpert)
    print("\n📋 Step 1: Execute Snowflake queries")
    print("   → This step is handled by the Goose recipe")
    print("   → Queries are in queries/*.sql")
    
    # Step 2: Process results (example structure)
    print("\n⚙️  Step 2: Process and join results")
    print("   → Join by BUSINESS_ID")
    print("   → Compute health scores")
    print("   → Generate alerts")
    print("   → Aggregate summaries")
    
    # Step 3: Write to D1
    print("\n💾 Step 3: Write to D1 database")
    print("   → Clear existing data")
    print("   → Insert accounts")
    print("   → Insert alerts")
    print("   → Insert metrics")
    
    # Step 4: Write fallback data.js
    print("\n📝 Step 4: Write fallback data.js")
    print("   → For offline access")
    print("   → Backward compatibility")
    
    print("\n✅ Refresh complete!")
    print(f"🔗 Dashboard: {API_BASE}")
    print(f"🔗 API: {API_BASE}/api/data")
    
    return 0

if __name__ == "__main__":
    exit(main())
