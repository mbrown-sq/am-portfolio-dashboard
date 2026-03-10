# Manual Data Refresh Guide

Since the scheduled job is having extension configuration issues, here's how to run the refresh manually:

## Option 1: Run via Goose Interactive Session (Recommended)

1. **Open Goose** in your terminal
2. **Navigate to project:**
   ```bash
   cd /Users/mbrown/Projects/am-portfolio-dashboard
   ```

3. **Execute queries one by one:**
   ```
   For each query file (01-10), ask Goose:
   "Read queries/01_accounts.sql and execute it via queryexpert. Save the results."
   ```

4. **Process and assemble data:**
   ```
   "Use Python to join all the query results by BUSINESS_ID, compute health scores, 
   generate alerts, and write to build/client/data.js in the format: const DATA = {...};"
   ```

5. **Deploy:**
   ```bash
   goose-sites deploy am-portfolio-dashboard ./build -m "Manual refresh $(date +%Y-%m-%d)"
   ```

## Option 2: Quick Test (Skip Deployment)

Just test that queries work:

```bash
# In Goose, ask:
"Read and execute queries/01_accounts.sql. Show me the first 5 rows."
```

If that works, the queries are fine and it's just a scheduling configuration issue.

## Option 3: Fix the Scheduled Job

The issue is the queryexpert extension configuration. You need to:

1. Find the correct MCP server package name for queryexpert
2. Update the recipe with the correct cmd/args
3. Recreate the scheduled job

Current job ID: `agent_created_1773117650`

## Troubleshooting

### If queries fail:
- Check Snowflake connection
- Verify table permissions
- Check AM_TEAM filter value

### If deployment fails:
- Verify build/client/data.js exists
- Check file size (should be 400KB-1MB)
- Ensure goose-sites CLI is installed

### If scheduled job fails:
- The extension configuration needs to match your local setup
- You may need to ask your Goose admin for the correct queryexpert MCP config
