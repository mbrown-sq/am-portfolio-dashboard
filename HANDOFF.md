# AM Portfolio Dashboard — Handoff & Continuation Guide

## Quick Start

**Live site:** GitHub Pages (pushes to `main` auto-deploy)
**Repo:** https://github.com/mbrown-sq/am-portfolio-dashboard
**Local path:** `/Users/mbrown/Projects/am-portfolio-dashboard/`

```
cd /Users/mbrown/Projects/am-portfolio-dashboard
# Edit files
git add -A && git commit -m "description" && git push origin main
# Live within ~60 seconds
```

---

## File Structure

### `data.js` — ALL the data (436KB)
This is the single source of truth. `index.html` loads it via `<script src="data.js">`.

```javascript
const DATA = {
  accounts: [...],    // 1,729 accounts with all fields
  alerts: [...],      // 30 at-risk alerts with business-context reasons
  qtd: {...},         // QTD activity metrics per AM
  weekly: [...],      // Weekly activity data (5 weeks × 9 AMs)
  gpvTrend: [...],    // 6-month GPV trend
  amSummary: {...},   // Per-AM summary stats
  teamTotal: {...},   // Team-wide totals
  featureNews: [...]  // Feature awareness items (manually curated)
};
```

**Account fields:**
| Field | Description | Source |
|-------|-------------|--------|
| `n` | Business name | Original data |
| `am` | AM key (antony, simran, etc.) | Original data |
| `c` | Category (food, retail, beauty, services) | Original data |
| `t` | GPV Tier (1, 2, 3) | Original data |
| `g` | Annualized GPV (millions) | Original data |
| `g9` | 9-month trailing GPV (millions) | Original data |
| `y` | YoY growth % | Original data |
| `ar` | Annualized revenue (dollars) | Original data |
| `at` | Average ticket (dollars) | Original data |
| `l` | Active locations count | Original data |
| `tn` | Tenure (months with Square) | Original data |
| `ct` | Contract (true/false) | Original data |
| `h` | Health score (0-100) | Original data |
| `r` | Risk status (healthy/watch/at_risk) | Original data |
| `d` | Days since last activity | Original data |
| `a30` | Activities in last 30 days | Original data |
| `cs` | CSAT score (0-5, mostly 0) | Original data |
| `sf` | Salesforce Account ID | Original data |
| `ci` | City/info tag | Original data |
| `lp` | Last processed date (YYYY-MM-DD) | Original data |
| `products` | Comma-separated product list | Snowflake: MERCHANT_PRODUCT_EVENTS |
| `city` | City name | Snowflake: VDIM_USER |
| `state` | State (VIC, NSW, QLD, etc.) | Snowflake: VDIM_USER |
| `pc` | Postcode | Snowflake: VDIM_USER |
| `svc` | AM Service Level | Snowflake: AM_FACT_ACCOUNT_OWNERSHIP_V2 |
| `cls` | Seller Class | Snowflake: AM_FACT_ACCOUNT_OWNERSHIP_V2 |
| `sar` | SaaS AR (annual, dollars) — used for stickiness assessment | Original data |

**Feature News format** (in `data.js` → `DATA.featureNews`):
```javascript
{
  "name": "3P Order Pausing from POS",
  "date": "2026-03-02",
  "match": {"cat": ["food"]},           // Targeting rules
  "talk": "Your kitchen staff can...",   // Exact talk track for AMs
  "badge": "NEW"                         // NEW, FIX, BENEFIT, SAVE, UPDATE, IMPROVEMENT
}
```
Match rules: `cat` (array), `minTicket`, `minLocations`, `minGpv`, `hasProduct` (array).

### `index.html` — ALL the UI + logic (~1,200 lines)
Single-file app. No build step, no dependencies beyond CDN fonts/icons.

**Structure:**
- Lines 1-340: CSS (dark theme, all component styles)
- Lines 340-380: GooseApp metadata + PRD
- Lines 380-490: HTML structure (topbar, KPIs, table, alerts, bottom grid, footer)
- Lines 490+: `<script>` — data mapping, render functions, seller intelligence

**Key JS sections (search for these comments):**
- `// ===== MAP DATA.js INTO LOCAL VARIABLES =====` — transforms DATA.* into local vars
- `// ===== RENDER FUNCTIONS =====` — KPIs, table, alerts, charts, QTD
- `function sellerNarrative(a)` — Know Your Seller text generation
- `function nextBestActions(a)` — NBA engine (urgent/grow/celebrate)
- `function matchFeatures(a)` — Feature news matching
- `function churnRiskFraming(a)` — Retention intelligence
- `function sellerMilestones(a)` — Anniversary/growth milestone detection
- `function findSimilarSellers(a)` — Peer comparison logic
- `function velocityBadge(vel)` — GPV velocity display
- `function peerBenchmarkHtml(a)` — Peer benchmark bar chart
- `function toggleDetail(idx)` — Opens the full-screen modal
- `function closeModal()` — Closes the modal
- `function renderCategoryChart()` — GPV by category panel
- `function populateAMSelect()` — Dynamic AM dropdown

---

## Snowflake Data Sources

### Product Adoption (99% match)
```sql
-- The key query that powers product adoption
SELECT 
  aeo.BUSINESS_NAME,
  LISTAGG(DISTINCT COALESCE(mpe.PRODUCT_PARENT_NAME, mpe.PRODUCT_NAME), ',') as products
FROM APP_SALES.APP_SALES_ETL.MERCHANT_PRODUCT_EVENTS mpe
JOIN APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP dao
  ON mpe.MERCHANT_TOKEN = dao.MERCHANT_TOKEN
JOIN APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2 aeo
  ON dao.BUSINESS_ID = aeo.BUSINESS_ID
JOIN APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB'
  AND aeo.IS_ACTIVELY_MANAGED = 1
GROUP BY aeo.BUSINESS_NAME
```

### Location Data (99% match)
```sql
SELECT 
  aeo.BUSINESS_NAME,
  vu.RECEIPT_CITY, vu.RECEIPT_STATE, vu.RECEIPT_POSTAL_CODE,
  aeo.AM_SERVICE_LEVEL, aeo.SELLER_CLASS
FROM APP_BI.HEXAGON.VDIM_USER vu
JOIN APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP dao
  ON vu.MERCHANT_TOKEN = dao.MERCHANT_TOKEN
JOIN APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2 aeo
  ON dao.BUSINESS_ID = aeo.BUSINESS_ID
JOIN APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT ame
  ON aeo.ACTIVE_OWNER_ID = ame.SFDC_OWNER_ID
WHERE ame.AM_TEAM = 'AU SMB' AND aeo.IS_ACTIVELY_MANAGED = 1
QUALIFY ROW_NUMBER() OVER (PARTITION BY aeo.BUSINESS_ID ORDER BY vu.MERCHANT_LATEST_PAYMENT_DATE DESC NULLS LAST) = 1
```

### Key Table Reference
| Table | What it has | Key field |
|-------|------------|-----------|
| `APP_SALES.APP_SALES_ETL.MERCHANT_PRODUCT_EVENTS` | Product adoption per merchant token | MERCHANT_TOKEN |
| `APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP` | Business ID ↔ Merchant Token mapping | BUSINESS_ID, MERCHANT_TOKEN |
| `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2` | AM ownership, service level, seller class | BUSINESS_ID |
| `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT` | AM team, email, role | SFDC_OWNER_ID |
| `APP_BI.HEXAGON.VDIM_USER` | Location (city, state, postcode), business name | MERCHANT_TOKEN |
| `APP_SALES.GOLD_LAYER.SFDC_ACCOUNT_RAW_TEMP` | SFDC account data, website, phone | ID (SFDC Account ID) |
| `AM_ANALYTICS.AM_ANALYTICS_ETL.SMB_VARCOMP_AR_GROWTH` | AR Growth wins per business | BUSINESS_ID |
| `APP_MKTG_INTL.INTL_PROD.SOFT_CHURN_REPORTING` | Soft churn linkages (Dan Nulley) | MERCHANT_TOKEN |

### SFDC ↔ Business ID mapping
```
SFDC Account ID → SBS_BOOK_OF_BUSINESS_ID_C → BUSINESS_ID (in AM tables)
```

---

## What Needs Work

### Retention Intelligence ✅ (rewritten 2026-03-05)
**File:** `index.html` → search for `function churnRiskFraming(a)`
**Status:** Rewritten from generic comp-framing to 5-section seller-outcome-focused intelligence.
**New structure:**
1. **Churn Pattern Diagnosis** — Failure of Education / Failure of Responsiveness (from Orbit research), with specific conversation openers in blue callout boxes
2. **Stickiness Assessment** — uses product count, contract status, and SaaS AR (`saasAr` field, mapped from `sar` in data.js) to rate High/Moderate/Low switching cost
3. **What's at Stake** — portfolio weight + AR impact, only for at-risk or significantly declining accounts. Contract multiplier mentioned only when actionable (non-contracted sellers)
4. **Category-Specific Risk Signals** — F&B (avg ticket-aware: café vs premium dining), Retail (online channel check), Beauty (Appointments as competitor risk)
5. **Peer Context** — compares this seller's decline against category-wide trends. Flags outliers vs market-wide issues
**Coverage:** 57% of accounts trigger at least one signal (993/1,729)
**Key change:** Removed "Protecting this seller protects your payout" framing. Now frames around seller outcomes with exact conversation openers.

### Future Enrichment Opportunities
1. **Google Places API** — ratings, reviews, website, social links. Needs a GCP project (request via https://cloud-portal.sqprod.co/requests/new or #blockplat-help)
2. **Salesforce fields** — website, phone available in `SFDC_ACCOUNT_RAW_TEMP` but sparse for parent accounts. Child accounts have more data.
3. **Support ticket data** — recent CS cases would add context ("had 3 support cases last month")
4. **Churn risk ML score** — if available from data science team
5. **Real-time notifications** — Slack integration for alerts when seller GPV drops or milestones hit

### Scalability Path
Current: Manual data.js generation → git push
Next: Cron job / Squarewave task that runs the Snowflake queries daily → writes data.js → auto-pushes
Future: Real-time event-based updates via the GTM Unified Data Layer (see GTM Automation Strategy doc)

---

## Feature Inventory

| Feature | Location in code | Data source |
|---------|-----------------|-------------|
| AM dropdown (dynamic) | `populateAMSelect()` | DATA.amSummary, DATA.teamTotal |
| KPI cards | `renderKPIs()` | DATA.amSummary |
| Account table (1,729 rows) | `renderTable()` (overridden) | DATA.accounts |
| Sticky header | CSS `.data-table thead th` | — |
| Search + risk filters + contract filter | `getFilteredAccounts()` | accounts array |
| Sparklines | `makeSparkline()` | Generated from yoy |
| Velocity badges | `velocityBadge()` | g vs g9 |
| Last Contact (6mo DM model) | Table column | lp field, color thresholds at 30/90/180d |
| Contract column | Table column | ct field |
| CSV export | `exportCSV()` | Filtered accounts |
| Alerts panel | `renderAlerts()` | DATA.alerts |
| Alert SFDC + Find buttons | In alert render | sf field |
| GPV Trend chart (SVG) | `renderGPVChart()` | DATA.gpvTrend |
| Weekly Activity bars | `renderActivityBars()` | DATA.weekly |
| QTD Metrics | `renderQTD()` | DATA.qtd |
| GPV by Category | `renderCategoryChart()` | Computed from accounts |
| **Full-screen modal** | `toggleDetail()` / `closeModal()` | — |
| Know Your Seller narrative | `sellerNarrative(a)` | All account fields |
| Next Best Actions | `nextBestActions(a)` | All account fields + features |
| Feature Awareness | `matchFeatures(a)` / `featureNewsHtml(a)` | DATA.featureNews |
| Retention Intelligence | `churnRiskFraming(a)` | Account fields + portfolio calc |
| Milestones | `sellerMilestones(a)` | tenure, gpv, velocity, products |
| Peer Benchmarking | `peerBenchmarkHtml(a)` | Category stats computed at load |
| Similar Sellers | `findSimilarSellers()` / `similarSellersHtml()` | accounts array |
| Product Adoption pills | In modal build | products field |
| Salesforce direct links | `squareinc.lightning.force.com/lightning/r/Account/{sf}/view` | sf field |

---

## Tips for Continuing

1. **To edit the narrative:** Search for `function sellerNarrative(a)` — it's one function that generates all the text
2. **To add a new feature news item:** Edit the `featureNews` array in `data.js` — no code changes needed
3. **To add a new data field:** Add it to the account objects in `data.js`, then map it in the `const accounts = DATA.accounts.map(...)` block in `index.html`
4. **To change modal layout:** Search for `function toggleDetail(idx)` — the entire modal HTML is built there
5. **To add a new filter button:** Add the HTML button, then update `getFilteredAccounts()` to handle the new filter value
6. **To refresh Snowflake data:** Run the queries above, process with Python, write to data.js, git push
7. **CSS variables** are at the top of the file (`:root { --bg: #0f1923; ... }`) — change theme here
