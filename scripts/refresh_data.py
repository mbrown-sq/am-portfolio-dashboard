#!/usr/bin/env python3
"""
AU SMB Dashboard Data Refresh Script

Executes all Snowflake queries, assembles data, and writes to D1 database.
This script is designed to be run by a scheduled Goose recipe.
"""

import json
import os
from datetime import datetime, date
from pathlib import Path

# Assumes queryexpert MCP is available in Goose context
# This script should be run via Goose with queryexpert extension enabled

PROJECT_ROOT = Path("/Users/mbrown/Projects/am-portfolio-dashboard")
QUERIES_DIR = PROJECT_ROOT / "queries"
BUILD_DIR = PROJECT_ROOT / "build/client"

def load_query(filename):
    """Load SQL query from file"""
    with open(QUERIES_DIR / filename, 'r') as f:
        return f.read()

def compute_health_score(account):
    """
    Compute health score (0-100) based on multiple factors:
    - GPV velocity: 0-50 points
    - Contact recency: 0-20 points
    - Product adoption: 0-15 points
    - Contract status: 0-10 points
    - Tenure: 0-5 points
    """
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
    
    # Product adoption (count products)
    products = account.get('products', '')
    product_count = len([p for p in products.split(',') if p.strip()]) if products else 0
    score += min(15, product_count * 3)
    
    # Contract status
    if account.get('ct', False):
        score += 10
    
    # Tenure (months)
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

def generate_alert_reason(account):
    """Generate contextual alert reason based on account signals"""
    reasons = []
    
    velocity = account.get('y', 0)
    days = account.get('d', 999)
    products = account.get('products', '')
    locations = account.get('l', 0)
    
    if velocity < -15:
        reasons.append("Significant decline in processing volume — investigate if switching providers")
    
    if days > 120:
        reasons.append(f"No AM contact in {days} days — at risk of disengagement")
    
    if not products or products.strip() == '':
        reasons.append("No add-on products — could benefit from product expansion")
    
    if locations > 1 and velocity < 0:
        reasons.append(f"{locations} locations — check if decline is isolated or chain-wide")
    
    return ". ".join(reasons) if reasons else "Multiple risk factors detected"

def main():
    """
    Main execution flow:
    1. Execute all 10 Snowflake queries
    2. Join and transform data
    3. Compute health scores and alerts
    4. Write to data.js (for now - will migrate to D1)
    """
    
    print("🔄 Starting AU SMB Dashboard data refresh...")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # This script is meant to be called from Goose with queryexpert extension
    # The actual query execution would use queryexpert__execute_query tool
    # For now, this is a template showing the data processing logic
    
    print("\n✅ Query execution template ready")
    print(f"📁 Queries directory: {QUERIES_DIR}")
    print(f"📊 Build directory: {BUILD_DIR}")
    
    # List available queries
    query_files = sorted(QUERIES_DIR.glob("*.sql"))
    print(f"\n📋 Found {len(query_files)} query files:")
    for qf in query_files:
        print(f"   - {qf.name}")
    
    print("\n💡 Next steps:")
    print("   1. Run this script via Goose with queryexpert extension enabled")
    print("   2. Each query will be executed and results cached")
    print("   3. Data will be assembled and written to data.js")
    print("   4. Deploy with: goose-sites deploy am-portfolio-dashboard ./build")
    
    return 0

if __name__ == "__main__":
    exit(main())
