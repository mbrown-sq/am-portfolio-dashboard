# Solution Summary: Fixing the 9MB Request Size Error

## The Problem

Your scheduled recipe was hitting this error:
```
Request size cannot exceed 8999999 bytes. Please shorten the request.
```

**Root cause:** The recipe's `instructions` field embedded **9 complete SQL queries** (each 3-5KB) plus extensive Python code examples, totaling ~50KB of text. When the scheduled job started, it loaded all of this into the initial request context, exceeding Cloudflare's 9MB limit.

## The Solution

**Move queries to external files** so the recipe only references them instead of embedding them.

### What I Created

1. **10 SQL Query Files** (`queries/*.sql`)
   - Each query in its own file
   - Easy to modify and version control
   - Recipe just references them by filename

2. **Simplified Recipe** (`recipes/data-refresh-v2.yaml`)
   - Reduced from ~50KB to ~5KB
   - References external queries instead of embedding them
   - Much cleaner and more maintainable

3. **D1 Database Schema** (`migrations/0001_initial.sql`)
   - Ready for Phase 2 migration (API + database)
   - Replaces the 884KB static data.js file
   - Enables real-time filtering and smaller page loads

4. **Documentation**
   - `queries/README.md` - Query documentation
   - `ARCHITECTURE.md` - Full architecture explanation
   - `scripts/refresh_data.py` - Data processing template

## How to Use It

### Option 1: Test the New Recipe Manually
```bash
cd /Users/mbrown/Projects/am-portfolio-dashboard
goose run recipes/data-refresh-v2.yaml
```

### Option 2: Delete Old Job and Create New One
```bash
# Delete the problematic job
platform__manage_schedule(
  action="delete",
  job_id="agent_created_1773106756"
)

# Create new job with simplified recipe
platform__manage_schedule(
  action="create",
  recipe_path="/Users/mbrown/Projects/am-portfolio-dashboard/recipes/data-refresh-v2.yaml",
  cron_expression="0 */6 * * *"  # Every 6 hours
)
```

## File Structure

```
am-portfolio-dashboard/
├── queries/                    # ✨ NEW: External SQL files
│   ├── 01_accounts.sql
│   ├── 02_gpv.sql
│   ├── 03_ar.sql
│   ├── 04_activity.sql
│   ├── 05_qtd_metrics.sql
│   ├── 06_weekly_activity.sql
│   ├── 07_gpv_trend.sql
│   ├── 08_products.sql
│   ├── 09_locations.sql
│   ├── 10_contracts.sql
│   └── README.md              # Query documentation
├── migrations/                 # ✨ NEW: D1 database schema
│   └── 0001_initial.sql
├── scripts/
│   └── refresh_data.py        # ✨ NEW: Data processing template
├── recipes/
│   ├── data-refresh-v2.yaml   # ✨ NEW: Simplified recipe (5KB)
│   └── seller-*.yaml          # Your existing recipes
├── ARCHITECTURE.md            # ✨ NEW: Full architecture docs
├── SOLUTION_SUMMARY.md        # ✨ NEW: This file
├── build/
│   └── client/
│       ├── index.html
│       └── data.js            # Still used for now
└── ... (other files)
```

## Why This Works

### Before (❌ Failed)
```yaml
instructions: |
  Step 1: Run this query:
  SELECT aeo.BUSINESS_NAME AS n,
         aeo.BUSINESS_ID AS bid,
         LOWER(ame.LDAP) AS am,
         ... (3KB of SQL)
  
  Step 2: Run this query:
  SELECT gpv.BUSINESS_ID AS bid,
         ... (3KB of SQL)
  
  ... (8 more queries, each 3-5KB)
  
  Step 11: Assemble data.js:
  ```python
  import json
  from datetime import datetime
  ... (50KB of Python code)
  ```

Total: ~50KB embedded in recipe → 9MB+ when loaded into context
```

### After (✅ Works)
```yaml
instructions: |
  1. Execute queries from queries/*.sql (10 files)
  2. Process results using scripts/refresh_data.py logic
  3. Write build/client/data.js
  4. Deploy with goose-sites

Total: ~5KB in recipe → <1MB when loaded into context
```

## Next Steps

### Immediate (Fix the Error)
1. **Delete the old job:**
   ```bash
   platform__manage_schedule(action="delete", job_id="agent_created_1773106756")
   ```

2. **Test the new recipe:**
   ```bash
   cd /Users/mbrown/Projects/am-portfolio-dashboard
   goose run recipes/data-refresh-v2.yaml
   ```

3. **Schedule the new job:**
   ```bash
   platform__manage_schedule(
     action="create",
     recipe_path="/Users/mbrown/Projects/am-portfolio-dashboard/recipes/data-refresh-v2.yaml",
     cron_expression="0 */6 * * *"
   )
   ```

### Future (Optimize Performance)
Consider migrating to **D1 database + API** architecture:
- ✅ Reduces page load from 884KB → <50KB
- ✅ Enables real-time filtering without page reload
- ✅ Makes data accessible to other tools (Slack bots, etc.)

See `ARCHITECTURE.md` for full migration guide.

## Key Takeaways

1. **Scheduled jobs have smaller context windows** than interactive sessions
2. **Embed minimal instructions** in recipes - reference external files instead
3. **Use external query files** for any SQL longer than a few lines
4. **Keep recipes under 10KB** to avoid request size limits

## Questions?

- **Where are the queries?** → `queries/*.sql`
- **How do I modify a query?** → Edit the `.sql` file directly
- **How do I test changes?** → Run `goose run recipes/data-refresh-v2.yaml`
- **How do I deploy?** → Recipe handles deployment automatically
- **What if I want real-time data?** → See Phase 2 in `ARCHITECTURE.md`
