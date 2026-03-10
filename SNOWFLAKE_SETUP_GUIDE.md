# 🚀 Snowflake-First Architecture Setup Guide

**NO queryexpert needed! NO Goose scheduling issues!**

---

## 🎯 Overview

This architecture uses **Snowflake Tasks** to pre-compute all dashboard data, then a simple script syncs it to D1. This eliminates:

- ❌ queryexpert extension dependency
- ❌ Goose scheduled job issues
- ❌ Complex Python data processing
- ❌ 10 separate queries to execute
- ❌ Recipe size limits

Instead:
- ✅ Snowflake does all the heavy lifting
- ✅ One simple SELECT per table
- ✅ Reliable Snowflake scheduling
- ✅ Fast D1 API responses

---

## 📋 Setup Steps

### **Step 1: Create Snowflake Tables** (One-time setup)

Run these SQL files in Snowflake (via Snowflake UI or CLI):

```sql
-- 1. Main dashboard snapshot (combines all 10 queries)
-- File: snowflake/create_dashboard_snapshot.sql
-- Runtime: ~2-3 minutes
-- Creates: app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot

-- 2. QTD metrics
-- File: snowflake/create_qtd_metrics.sql
-- Runtime: ~30 seconds
-- Creates: app_merch_growth.mbrown_sandbox.au_smb_qtd_metrics

-- 3. Weekly activity
-- File: snowflake/create_weekly_activity.sql
-- Runtime: ~30 seconds
-- Creates: app_merch_growth.mbrown_sandbox.au_smb_weekly_activity

-- 4. GPV trend
-- File: snowflake/create_gpv_trend.sql
-- Runtime: ~30 seconds
-- Creates: app_merch_growth.mbrown_sandbox.au_smb_gpv_trend
```

**How to run:**
1. Open Snowflake UI
2. Copy/paste each SQL file
3. Execute
4. Verify row counts

**Expected results:**
- `au_smb_dashboard_snapshot`: ~1,700 rows
- `au_smb_qtd_metrics`: ~9 rows (one per AM)
- `au_smb_weekly_activity`: ~45 rows (9 AMs × 5 weeks)
- `au_smb_gpv_trend`: ~6 rows (6 months)

---

### **Step 2: Schedule Daily Refresh** (One-time setup)

Run this SQL in Snowflake to create a scheduled task:

```sql
-- File: snowflake/schedule_daily_refresh.sql
-- This creates a Snowflake Task that runs at 7:30am AEDT daily

-- IMPORTANT: Edit the file first!
-- 1. Replace COMPUTE_WH with your warehouse name
-- 2. Copy the full query from create_dashboard_snapshot.sql into the task
-- 3. Adjust the cron schedule if needed:
--    - AEDT (daylight saving): 30 21 * * * UTC
--    - AEST (standard time): 30 22 * * * UTC
```

**How to run:**
1. Edit `snowflake/schedule_daily_refresh.sql`
2. Replace `COMPUTE_WH` with your warehouse
3. Copy the full query from `create_dashboard_snapshot.sql` into the task
4. Execute in Snowflake UI
5. Verify task is running: `SHOW TASKS;`

**To test manually:**
```sql
EXECUTE TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard;
```

---

### **Step 3: Sync to D1** (Run daily after Snowflake Task)

Now that Snowflake has pre-computed everything, syncing to D1 is simple:

**Option A: Via Goose (Simple)**

```bash
cd /Users/mbrown/Projects/am-portfolio-dashboard

# In Goose, run:
"Execute these 4 queries and save results:
1. SELECT * FROM app_merch_growth.mbrown_sandbox.au_smb_dashboard_snapshot
2. SELECT * FROM app_merch_growth.mbrown_sandbox.au_smb_qtd_metrics
3. SELECT * FROM app_merch_growth.mbrown_sandbox.au_smb_weekly_activity
4. SELECT * FROM app_merch_growth.mbrown_sandbox.au_smb_gpv_trend

Then run scripts/sync_snowflake_to_d1.py with these results to write to D1 and data.js"
```

**Option B: Via Python Script (Direct)**

```python
# The script is at: scripts/sync_snowflake_to_d1.py
# It shows the logic for transforming and writing data
# You'll need to add actual Snowflake connection code
```

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│              Snowflake Task (7:30am AEDT)                    │
│  Runs: refresh_au_smb_dashboard                             │
│  Creates 4 snapshot tables with pre-computed data           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              4 Snowflake Tables (Ready to read!)            │
│  - au_smb_dashboard_snapshot (~1,700 rows)                  │
│  - au_smb_qtd_metrics (~9 rows)                             │
│  - au_smb_weekly_activity (~45 rows)                        │
│  - au_smb_gpv_trend (~6 rows)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Simple Sync Script (8:00am AEDT)               │
│  Just 4 SELECT queries - NO complex processing!            │
│  Reads snapshot tables and writes to D1 + data.js          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ├──────────────┬──────────────────────────┐
                     ▼              ▼                          ▼
┌──────────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  D1 Database         │  │  data.js         │  │  API             │
│  (Fast queries)      │  │  (Fallback)      │  │  (Serves data)   │
└──────────────────────┘  └──────────────────┘  └──────────────────┘
                     │              │                          │
                     └──────────────┴──────────────────────────┘
                                    ▼
                     ┌──────────────────────────────────────┐
                     │      Dashboard (Blazingly fast!)     │
                     └──────────────────────────────────────┘
```

---

## ✅ What You Get

### **Simplicity**
- ✅ No queryexpert extension needed
- ✅ No Goose scheduled jobs
- ✅ No complex Python processing
- ✅ Just 4 simple SELECT queries

### **Reliability**
- ✅ Snowflake handles scheduling (battle-tested)
- ✅ No recipe size limits
- ✅ No extension configuration issues
- ✅ Runs even if Goose is down

### **Performance**
- ✅ Snowflake pre-computes everything
- ✅ D1 serves data in <50ms
- ✅ Dashboard loads in <1 second
- ✅ Real-time filtering enabled

### **Maintainability**
- ✅ Update logic in Snowflake (SQL only)
- ✅ No recipe changes needed
- ✅ Easy to debug (check Snowflake tables)
- ✅ Clear separation of concerns

---

## 🔧 Maintenance

### **Update Query Logic**

To change what data is computed:

1. Edit `snowflake/create_dashboard_snapshot.sql`
2. Run it manually to test
3. Update the Snowflake Task with the new query
4. Done! Next refresh will use new logic

### **Check Task Status**

```sql
-- See if task is running
SHOW TASKS LIKE 'refresh_au_smb_dashboard';

-- Check task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'REFRESH_AU_SMB_DASHBOARD',
  SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
ORDER BY SCHEDULED_TIME DESC;
```

### **Pause/Resume Task**

```sql
-- Pause (stops automatic runs)
ALTER TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard SUSPEND;

-- Resume (starts automatic runs)
ALTER TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard RESUME;
```

### **Run Task Manually**

```sql
-- Trigger an immediate run
EXECUTE TASK app_merch_growth.mbrown_sandbox.refresh_au_smb_dashboard;
```

---

## 📁 File Structure

```
am-portfolio-dashboard/
├── snowflake/                              # ✨ NEW: Snowflake SQL files
│   ├── create_dashboard_snapshot.sql       # Main snapshot (combines 10 queries)
│   ├── create_qtd_metrics.sql              # QTD metrics
│   ├── create_weekly_activity.sql          # Weekly activity
│   ├── create_gpv_trend.sql                # GPV trend
│   └── schedule_daily_refresh.sql          # Snowflake Task scheduler
├── scripts/
│   └── sync_snowflake_to_d1.py            # ✨ NEW: Simple sync script
├── build/
│   ├── client/
│   │   ├── index.html                      # Dashboard
│   │   └── data.js                         # Fallback data
│   └── server/
│       └── index.js                        # API worker
└── docs/
    ├── SNOWFLAKE_SETUP_GUIDE.md           # This file
    ├── CURRENT_STATUS.md                  # Current status
    └── D1_SETUP_COMPLETE.md               # API documentation
```

---

## 🆚 Comparison: Old vs New

| Aspect | Old (queryexpert) | New (Snowflake-first) |
|--------|-------------------|----------------------|
| **Dependencies** | queryexpert extension | None (just Snowflake) |
| **Scheduling** | Goose scheduled jobs | Snowflake Tasks |
| **Queries** | 10 separate queries | 1 pre-computed table |
| **Processing** | Complex Python in recipe | Done in Snowflake |
| **Recipe size** | ~50KB (hit limit) | N/A (no recipe needed) |
| **Reliability** | Extension config issues | Rock solid |
| **Debugging** | Check Goose logs | Check Snowflake tables |
| **Maintenance** | Update recipe + redeploy | Update SQL + rerun task |

---

## 🎯 Next Steps

### **Today**
1. ✅ Run Step 1: Create Snowflake tables
2. ✅ Verify data looks correct
3. ✅ Test queries return expected rows

### **This Week**
1. ✅ Run Step 2: Schedule Snowflake Task
2. ✅ Wait for first automatic run (7:30am AEDT)
3. ✅ Verify task completed successfully

### **Ongoing**
1. ✅ Run Step 3: Sync to D1 daily (after Snowflake Task)
2. ✅ Monitor task history
3. ✅ Update query logic as needed

---

## ❓ FAQ

**Q: Do I need queryexpert anymore?**  
A: NO! Snowflake does all the querying. You just read the pre-computed tables.

**Q: What if the Snowflake Task fails?**  
A: Check `TASK_HISTORY()` for errors. The tables will still have yesterday's data.

**Q: Can I run this manually?**  
A: Yes! Just `EXECUTE TASK refresh_au_smb_dashboard;` in Snowflake.

**Q: How do I update the query logic?**  
A: Edit `create_dashboard_snapshot.sql`, test it, then update the task definition.

**Q: What about D1? Do I still need it?**  
A: Yes! D1 caches the Snowflake data for fast API responses (<50ms).

**Q: Can I skip D1 and just use data.js?**  
A: Yes! The sync script writes to both. D1 is optional but recommended for speed.

---

## 🔗 Links

- **Snowflake UI:** https://app.snowflake.com/
- **Dashboard:** https://g2.stage.sqprod.co/apps/am-portfolio-dashboard
- **API:** https://am-portfolio-dashboard.vibeplatstage.squarecdn.com
- **Project:** /Users/mbrown/Projects/am-portfolio-dashboard

---

**Ready to set up?** Start with Step 1 - create the Snowflake tables!
