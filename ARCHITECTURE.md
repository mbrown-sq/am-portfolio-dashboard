# AU SMB Dashboard Architecture

## Problem: Request Size Limit (9MB)

The original recipe embedded all SQL queries and processing logic in the `instructions` field, causing the scheduled job to exceed Cloudflare's 9MB request size limit before execution even started.

## Solution: External Query Files + Simplified Recipe

### Before (❌ 9MB+ request)
```yaml
instructions: |
  Step 1: Run this query:
  SELECT ... (5KB of SQL)
  
  Step 2: Run this query:
  SELECT ... (5KB of SQL)
  
  ... (9 more queries)
  
  Step 11: Assemble data.js:
  ```python
  # 50KB of Python code
  ```
```

### After (✅ <100KB request)
```yaml
instructions: |
  1. Execute queries from queries/*.sql (10 files)
  2. Process results using scripts/refresh_data.py logic
  3. Write build/client/data.js
  4. Deploy with goose-sites
```

---

## Current Architecture (Static Data)

```
┌─────────────────────────────────────────────────────────────┐
│                     Scheduled Recipe                         │
│  (runs every 6 hours via platform__manage_schedule)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Snowflake Queries (10 files)                    │
│  queries/01_accounts.sql → queries/10_contracts.sql         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Python Data Assembly                            │
│  - Join by BUSINESS_ID                                       │
│  - Compute health scores                                     │
│  - Generate alerts                                           │
│  - Build DATA object                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              build/client/data.js (884KB)                    │
│  const DATA = { accounts: [...], alerts: [...], ... };      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              goose-sites deploy                              │
│  Uploads build/ to Cloudflare Pages                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Static HTML Dashboard                           │
│  index.html loads data.js on page load                      │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- ✅ Simple deployment (no backend needed)
- ✅ Fast page loads (no API calls)
- ✅ Works offline once loaded

**Cons:**
- ❌ Large initial payload (884KB)
- ❌ No real-time filtering (all data loaded upfront)
- ❌ Can't filter by date range or AM without reloading
- ❌ Recipe size limit issues

---

## Recommended Architecture (API + D1 Cache)

```
┌─────────────────────────────────────────────────────────────┐
│                     Scheduled Recipe                         │
│  (runs every 6 hours via platform__manage_schedule)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Snowflake Queries (10 files)                    │
│  queries/01_accounts.sql → queries/10_contracts.sql         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Python Data Assembly                            │
│  - Join by BUSINESS_ID                                       │
│  - Compute health scores                                     │
│  - Generate alerts                                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Cloudflare D1 Database                          │
│  Tables: accounts, alerts, qtd_metrics, weekly_activity,    │
│          gpv_trend, am_summary, team_total, feature_news    │
│  (see migrations/0001_initial.sql)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Hono API Worker (build/server/index.js)        │
│  GET /api/accounts?am=antony&risk=at_risk                   │
│  GET /api/alerts?limit=30                                   │
│  GET /api/qtd                                               │
│  GET /api/weekly?weeks=5                                    │
│  GET /api/gpv-trend                                         │
│  GET /api/summary                                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              React Frontend (build/client/)                  │
│  - Fetches data on demand via API                           │
│  - Real-time filtering without page reload                  │
│  - Smaller initial payload (<50KB)                          │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- ✅ Small initial payload (<50KB vs 884KB)
- ✅ Real-time filtering (no page reload)
- ✅ Can add date range filters
- ✅ Can add user-specific views
- ✅ No recipe size limit issues
- ✅ API can be used by other tools (Slack bots, etc.)

**Cons:**
- ⚠️ Requires D1 database setup
- ⚠️ Slightly more complex deployment

---

## Migration Path

### Phase 1: External Query Files (✅ DONE)
- Move SQL queries to `queries/*.sql`
- Simplify recipe to reference external files
- Keep static data.js output

**Status:** Complete. Recipe size reduced from ~50KB to ~5KB.

### Phase 2: D1 Database + API (🔄 NEXT)
1. **Setup D1 database:**
   ```bash
   cd /Users/mbrown/Projects/am-portfolio-dashboard
   goose-sites claim am-portfolio-dashboard
   goose-sites apply_migration am-portfolio-dashboard ./migrations
   ```

2. **Create Hono API worker:**
   ```bash
   mkdir -p build/server
   # Create build/server/index.js with Hono routes
   ```

3. **Update frontend to use API:**
   ```javascript
   // Instead of: const DATA = {...};
   // Use: fetch('/api/accounts').then(r => r.json())
   ```

4. **Update refresh script to write to D1:**
   ```python
   # Instead of: write to data.js
   # Use: INSERT INTO accounts VALUES (...)
   ```

5. **Deploy:**
   ```bash
   goose-sites deploy am-portfolio-dashboard ./build -m "Migrated to D1 + API"
   ```

### Phase 3: Real-time Features (🔮 FUTURE)
- Add date range filters
- Add AM-specific dashboards
- Add export to CSV functionality
- Add Slack integration for alerts

---

## File Structure

```
am-portfolio-dashboard/
├── build/
│   ├── client/
│   │   ├── index.html          # Frontend
│   │   └── data.js             # Static data (Phase 1) or empty (Phase 2)
│   └── server/
│       └── index.js            # Hono API worker (Phase 2)
├── queries/
│   ├── 01_accounts.sql         # Base account list
│   ├── 02_gpv.sql              # GPV metrics
│   ├── 03_ar.sql               # AR data
│   ├── 04_activity.sql         # Activity metrics
│   ├── 05_qtd_metrics.sql      # QTD AM metrics
│   ├── 06_weekly_activity.sql  # Weekly activity
│   ├── 07_gpv_trend.sql        # GPV trend
│   ├── 08_products.sql         # Product adoption
│   ├── 09_locations.sql        # Location data
│   ├── 10_contracts.sql        # Contract status
│   └── README.md               # Query documentation
├── scripts/
│   └── refresh_data.py         # Data assembly logic
├── migrations/
│   └── 0001_initial.sql        # D1 schema (Phase 2)
├── recipes/
│   ├── data-refresh-v2.yaml    # Simplified recipe (Phase 1)
│   └── seller-*.yaml           # Other recipes
├── docs/
│   └── *.md                    # Documentation
├── ARCHITECTURE.md             # This file
├── HANDOFF.md                  # Project handoff doc
├── README.md                   # Project overview
└── STRATEGY.md                 # GTM strategy
```

---

## Deployment

### Current (Phase 1)
```bash
# Run scheduled recipe
goose run recipes/data-refresh-v2.yaml

# Or schedule it
platform__manage_schedule(
  action="create",
  recipe_path="/Users/mbrown/Projects/am-portfolio-dashboard/recipes/data-refresh-v2.yaml",
  cron_expression="0 */6 * * *"  # Every 6 hours
)
```

### Future (Phase 2)
```bash
# Setup D1 database
goose-sites claim am-portfolio-dashboard
goose-sites apply_migration am-portfolio-dashboard ./migrations

# Deploy with API
goose-sites deploy am-portfolio-dashboard ./build -m "API + D1"

# Schedule data refresh
platform__manage_schedule(
  action="create",
  recipe_path="/Users/mbrown/Projects/am-portfolio-dashboard/recipes/data-refresh-v2.yaml",
  cron_expression="0 */6 * * *"
)
```

---

## Troubleshooting

### Recipe Size Limit Error
**Error:** `Request size cannot exceed 8999999 bytes`

**Solution:** Use external query files (Phase 1 - already implemented)

### Query Timeout
**Error:** Query execution exceeds timeout

**Solution:** Increase timeout in recipe:
```yaml
extensions:
  - type: builtin
    name: queryexpert
    timeout: 900  # 15 minutes
```

### Large Data File
**Issue:** data.js exceeds 1MB

**Solution:** Migrate to D1 + API (Phase 2)

### Deployment Fails
**Error:** `goose-sites deploy` fails

**Solution:** Check build directory structure:
```bash
ls -R build/
# Should show:
# build/client/index.html
# build/client/data.js (or empty in Phase 2)
# build/server/index.js (Phase 2 only)
```

---

## Performance Metrics

### Phase 1 (Current)
- **Initial page load:** ~2.5s (884KB data.js + 131KB index.html)
- **Time to interactive:** ~3s
- **Recipe execution time:** ~5-10 minutes
- **Deployment time:** ~30 seconds

### Phase 2 (Target)
- **Initial page load:** ~500ms (50KB HTML + CSS)
- **Time to interactive:** ~1s (API call completes)
- **Recipe execution time:** ~5-10 minutes (same)
- **Deployment time:** ~30 seconds (same)
- **API response time:** <200ms (D1 cached data)
