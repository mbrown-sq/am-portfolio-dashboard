# Quick Start: Fix the 9MB Error

## TL;DR

Your recipe was too big. I split it into external files. Use the new recipe instead.

## Fix It Now (3 Steps)

### 1. Delete the Broken Job
```bash
# In Goose, run:
platform__manage_schedule(action="delete", job_id="agent_created_1773106756")
```

### 2. Test the New Recipe
```bash
cd /Users/mbrown/Projects/am-portfolio-dashboard
goose run recipes/data-refresh-v2.yaml
```

### 3. Schedule It
```bash
# In Goose, run:
platform__manage_schedule(
  action="create",
  recipe_path="/Users/mbrown/Projects/am-portfolio-dashboard/recipes/data-refresh-v2.yaml",
  cron_expression="0 */6 * * *"
)
```

## What Changed?

### Old Recipe (❌ 50KB)
- All SQL queries embedded in the recipe
- Hit 9MB request size limit

### New Recipe (✅ 5KB)
- SQL queries in separate files: `queries/*.sql`
- Recipe just references them
- No more size limit errors

## Files Created

```
queries/
├── 01_accounts.sql          # Your 10 SQL queries
├── 02_gpv.sql
├── ... (8 more)
└── README.md                # Query docs

migrations/
└── 0001_initial.sql         # D1 schema (future use)

recipes/
└── data-refresh-v2.yaml     # New simplified recipe

scripts/
└── refresh_data.py          # Data processing logic

ARCHITECTURE.md              # Full explanation
SOLUTION_SUMMARY.md          # Detailed summary
QUICKSTART.md                # This file
```

## How to Modify Queries

1. Edit the `.sql` file: `queries/01_accounts.sql`
2. Test: `goose run recipes/data-refresh-v2.yaml`
3. Done! The scheduled job will use the updated query.

## Troubleshooting

### "Recipe not found"
Make sure you're in the project directory:
```bash
cd /Users/mbrown/Projects/am-portfolio-dashboard
```

### "Query timeout"
Increase timeout in `recipes/data-refresh-v2.yaml`:
```yaml
extensions:
  - type: builtin
    name: queryexpert
    timeout: 900  # 15 minutes
```

### "Still getting 9MB error"
Make sure you're using `data-refresh-v2.yaml`, not the old recipe.

## Need More Info?

- **Quick overview:** `SOLUTION_SUMMARY.md`
- **Full architecture:** `ARCHITECTURE.md`
- **Query details:** `queries/README.md`
