# AM Portfolio Dashboard — Handoff & Continuation Guide

**Last updated:** 2026-03-05
**Author:** Mallory Brown, AU SMB Team Lead
**Built with:** Goose + Snowflake + existing AM data infrastructure. Zero new systems required.

---

## Quick Start

**Live site:** GitHub Pages (pushes to `main` auto-deploy, live within ~60 seconds)
**Local path:** `/Users/mbrown/Projects/am-portfolio-dashboard/`

### Git Remotes (two repos)
| Remote | Repo | Purpose |
|--------|------|---------|
| `origin` | https://github.com/mbrown-sq/am-portfolio-dashboard | **Daily workflow** — push directly to `main`, auto-deploys to GitHub Pages |
| `org` | https://github.com/squareup/ausmbapp | Team/org visibility — has branch protection, requires PRs |

### Day-to-day workflow (use `origin`)
```
cd /Users/mbrown/Projects/am-portfolio-dashboard
# Edit files
git add -A && git commit -m "description" && git push origin main
# Live within ~60 seconds
```

### Syncing to org repo (occasional, requires PR)
```
git push org main
# This will fail with branch protection — create a PR instead:
git checkout -b my-branch-name
git push org my-branch-name
# Then create PR at https://github.com/squareup/ausmbapp/pulls
git checkout main
```

**Related docs:**
- `STRATEGY.md` — Vision, strategy & alignment to Project Orbit and GTM Automation
- `recipes/seller-signals-agent.yaml` — Goose recipe for live Snowflake data agent (Phase 1 chatbot)
- AM Comp SMB Metrics Explainer: [go/AMCompHub](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c)
- SMB AM Seller Account Signals Data Guide (Google Doc — 15 seller signal tables)
- Data Query Building Blocks for AM Agent (Google Doc — AM performance query patterns)

---

## Project Overview

A **Seller Intelligence Platform** for AU SMB Account Managers — a single-screen tool that transforms raw portfolio data into actionable seller insights, conversation starters, and prioritised next best actions.

**Key stats:**
- 1,729 AU SMB accounts with full data
- 99% product adoption coverage (from Snowflake)
- 9 AMs across the team
- A$839.2M total portfolio GPV
- 213 at-risk accounts, 1,078 on watch, 438 healthy

**What it does:** Click one account → see everything: narrative, actions, features, retention risk, products, peers. AM reads for 30 seconds → picks up the phone armed with specific numbers and conversation starters.

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
| `sar` | SaaS AR (annual, dollars) — used for stickiness assessment | Original data |
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

### `index.html` — ALL the UI + logic (~1,800 lines)
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
- `function churnRiskFraming(a)` — Retention intelligence (5-section rewrite)
- `function sellerMilestones(a)` — Anniversary/growth milestone detection
- `function findSimilarSellers(a)` — Peer comparison logic
- `function velocityBadge(vel)` — GPV velocity display
- `function peerBenchmarkHtml(a)` — Peer benchmark bar chart
- `function toggleDetail(idx)` — Opens the full-screen modal
- `function closeModal()` — Closes the modal
- `function renderCategoryChart()` — GPV by category panel
- `function populateAMSelect()` — Dynamic AM dropdown

### `recipes/seller-signals-agent.yaml` — Goose data agent recipe
A comprehensive Goose recipe that can answer AM questions by querying Snowflake in real-time.
Covers 25+ data tables across seller signals and AM performance metrics.
See "Chatbot / Data Agent" section below for details.

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

## Completed Work

### Retention Intelligence ✅ (rewritten 2026-03-05)
**File:** `index.html` → search for `function churnRiskFraming(a)`
**Status:** Completely rewritten from generic comp-framing to 5-section seller-outcome-focused intelligence.

**What changed:**
- Removed all generic "protects your payout" and "60% of variable comp" language
- Added `saasAr` field mapping (from `sar` in data.js) for stickiness assessment
- Fixed contract multiplier math: now correctly uses **in-quarter GPV** (quarterly), not annualized, per [AM Comp SMB Metrics Explainer](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c)
- Contract multiplier now references both GPV Growth & Retention (60%) AND AR Growth (40%)

**New 5-section structure:**
1. **Churn Pattern Diagnosis** — Failure of Education / Failure of Responsiveness (from Project Orbit churned seller research), with specific conversation openers in blue callout boxes. Education risk uses seller name, tenure, and GPV to personalize. Responsiveness risk differentiates between severe decline (>20%) and moderate decline, with different conversation openers for each.
2. **Stickiness Assessment** — Uses product count, contract status, and SaaS AR to rate:
   - 🔒 High stickiness (5+ products, contracted, SaaS AR > 0) — "focus on satisfaction, not retention"
   - 🔓 Moderate stickiness (≤2 products, no contract) — "every product you add creates a reason to stay"
   - ⚠️ Low stickiness (payments-only, no contract, zero SaaS) — "could switch with zero friction"
3. **What's at Stake** — Portfolio weight + AR impact, only for at-risk or significantly declining accounts. Contract multiplier mentioned only when actionable (non-contracted sellers >A$500K GPV). Uses quarterly GPV for multiplier math.
4. **Category-Specific Risk Signals** — F&B (avg ticket-aware: café/QSR vs premium dining), Retail (online channel check), Beauty (Appointments as competitor risk via Fresha/Timely)
5. **Peer Context** — Compares seller's decline against category-wide trends. "26% of retail sellers declining" = market-wide issue. "Only 8% declining" = outlier, dig deeper.

**Coverage:** 57% of accounts trigger at least one signal (993/1,729)

**Comp accuracy:** Contract multiplier framing verified against [go/AMCompHub](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c):
- 1.1x multiplier applies to **in-quarter GPV** (not annualized) — quota is quarterly
- Multiplier applies to **both** GPV Growth & Retention (60% weight) and AR Growth (40% weight)
- Measured at merchant_token level, not BID level

---

## Chatbot / Data Agent (In Progress)

### Vision
An embedded chatbot in the dashboard that can answer AM questions by querying Snowflake in real-time. Example questions:
- "Show me my sellers with recently declining transactions"
- "Which sellers have hardware approaching end of life?"
- "How am I pacing to my GPV goal this quarter?"
- "Who's at highest churn risk in my book?"
- "What products is Bromley's Bread using?"
- "How many open CS cases do my sellers have?"

### Architecture (planned)
```
AM asks question in dashboard chat
        ↓
Frontend sends question + AM context to backend
        ↓
Backend (Goose agent / Blockcell / Cloud Function)
  → Interprets the question
  → Maps to correct table(s) from data guide
  → Generates Snowflake SQL (using standardized UDFs)
  → Executes query (scoped to AM's book via SFDC_OWNER_ID)
  → Formats results with advisory actions
        ↓
Response displayed in chat widget on dashboard
```

### Phase 1: Goose Recipe ✅ (built 2026-03-05)
**File:** `recipes/seller-signals-agent.yaml`
**Status:** Built and committed. Ready for testing.

A comprehensive Goose recipe covering **25+ Snowflake tables** across two knowledge domains:

**Seller Signal Tables (15 tables):**
| Tier | Table | Schema | Use Case |
|------|-------|--------|----------|
| Churn | CHURN_PREDICTIONS_WINBACK | APP_SUPPORT.DATABRICKS_ML | Churn probability, outreach priority |
| Churn | SHEALTH_RISK_CHURN | APP_RISK.APP_RISK | Risk action impact on retention |
| Hardware | HARDWARE_REPLACEMENT_SUMMARY | APP_HARDWARE.ADHOC | Warranty expiration, upgrades |
| Hardware | HARDWARE_CHURN_RESURRECTION | APP_HARDWARE.ADHOC | Inactive hardware re-engagement |
| Hardware | FIVETRAN.DEVICES.DEVICES | FIVETRAN.DEVICES | Real-time device health |
| Products | MERCHANT_PRODUCT_EVENTS | APP_SALES.APP_SALES_ETL | Product portfolio, gaps |
| Products | AM_WINS_UNIFIED_COMBINED | APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL | Adoption patterns |
| Products | AM_CROSS_SELL_PRODUCT_EVENTS_COMBINED | AM_ANALYTICS.AM_ANALYTICS_ETL | Conversion blockers |
| Products | SELLER_INSIGHTS | APP_SALES.APP_SALES_ETL | Pain points, competitors |
| Engagement | MERCHANT_MESSAGES | APP_MESSENGER.PUBLIC | Notification delivery |
| Engagement | MERCHANT_MESSAGE_UNIT_CLICKED | CUSTOMER_DATA.MESSAGESERVICE | Notification effectiveness |
| Engagement | MERCHANT_MESSAGE_UNIT_DISMISSED | CUSTOMER_DATA.MESSAGESERVICE | Notification fatigue |
| Engagement | MERCHANT_SETTINGS | MESSENGER.RAW_TIDB | Communication preferences |
| Financial | DEVICE_LTV | APP_HARDWARE.DS_MODELS | Hardware ROI |

**AM Performance Tables (10+ tables):**
| Category | Table | Use Case |
|----------|-------|----------|
| Organization | am_fact_employment_current | LDAP → SFDC_OWNER_ID mapping |
| Organization | smb_varcomp_gpv_bid_mt_population | AM book composition |
| Organization | am_fact_employment_historical | IC to Lead mapping |
| GPV | smb_varcomp_gpv | BID/MT level GPV data |
| AR | smb_varcomp_ar_added | AR Added/AR Growth |
| Pacing | pokemon_snap | VC pacing to goal |
| Activities | am_fact_activities / am_fact_activities_fanout | AM call/email/SMS activity |
| Contracts | smb_varcomp_contracts_detail / smb_varcomp_contracts_mt_am | Contract eligibility |
| Support | app_support.cases | CS cases |
| Classification | am_varcomp_foundational | New vs Mature seller |
| Locations | vdim_user | Seller location count |
| Products | vfact_subscription_states_expanded | SaaS product usage |
| NNRO | nnro_sources_combined / smb_varcomp_nnro_attainment | Net New Retention Outreach |

**Key features baked into the recipe:**
- Standardized date UDFs (never manual date math)
- 8 documented anti-patterns to avoid (from AM Performance Building Blocks doc)
- Advisory playbook with specific thresholds and recommended actions
- Join patterns for scoping every query to the AM's book
- AU SMB team filtering

**How to test:**
```
# In a new Goose session, load the recipe:
# Option 1: Load into context
load the file /Users/mbrown/Projects/am-portfolio-dashboard/recipes/seller-signals-agent.yaml

# Option 2: Ask a question directly
"I'm an AU SMB AM with LDAP 'antony'. Show me my sellers with highest churn risk."
```

### Phase 2: Embedded Chat Widget (needs infrastructure)
Requires:
- **Blockcell** or **GCP Cloud Function** for the backend (to keep API keys server-side)
- **Auth** to verify which AM is asking (scope queries to their book)
- Request Blockcell via internal channels, GCP via https://cloud-portal.sqprod.co/requests/new

### Phase 3: Full Agentic Integration
- "Prep me for my call with Bromley's Bread" → full briefing generated
- Auto-draft follow-up emails based on call notes
- Proactive daily outreach suggestions pushed to each AM
- Churn prediction model integrated into retention intelligence
- Voice-to-action: AM speaks call notes, system logs activity and generates next steps

---

## What Still Needs Work

### Future Enrichment Opportunities
1. **Google Places API** — ratings, reviews, website, social links. Needs a GCP project (request via https://cloud-portal.sqprod.co/requests/new or #blockplat-help)
2. **Salesforce fields** — website, phone available in `SFDC_ACCOUNT_RAW_TEMP` but sparse for parent accounts. Child accounts have more data.
3. **Support ticket data** — recent CS cases would add context ("had 3 support cases last month"). Table exists: `app_support.app_support.cases`
4. **Churn risk ML score** — available in `APP_SUPPORT.DATABRICKS_ML.CHURN_PREDICTIONS_WINBACK` (PRED_PROB field). Could be added to data.js.
5. **Real-time notifications** — Slack integration for alerts when seller GPV drops or milestones hit
6. **Hardware lifecycle data** — warranty expiration dates from `APP_HARDWARE.ADHOC.HARDWARE_REPLACEMENT_SUMMARY`. Could power proactive upgrade offers.

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
| Retention Intelligence | `churnRiskFraming(a)` | Account fields + portfolio calc + saasAr |
| Milestones | `sellerMilestones(a)` | tenure, gpv, velocity, products |
| Peer Benchmarking | `peerBenchmarkHtml(a)` | Category stats computed at load |
| Similar Sellers | `findSimilarSellers()` / `similarSellersHtml()` | accounts array |
| Product Adoption pills | In modal build | products field |
| Salesforce direct links | `squareinc.lightning.force.com/lightning/r/Account/{sf}/view` | sf field |
| **Goose data agent recipe** | `recipes/seller-signals-agent.yaml` | 25+ Snowflake tables |

---

## Tips for Continuing

1. **To edit the narrative:** Search for `function sellerNarrative(a)` — it's one function that generates all the text
2. **To edit retention intelligence:** Search for `function churnRiskFraming(a)` — 5-section structure with conversation openers
3. **To add a new feature news item:** Edit the `featureNews` array in `data.js` — no code changes needed
4. **To add a new data field:** Add it to the account objects in `data.js`, then map it in the `const accounts = DATA.accounts.map(...)` block in `index.html`
5. **To change modal layout:** Search for `function toggleDetail(idx)` — the entire modal HTML is built there
6. **To add a new filter button:** Add the HTML button, then update `getFilteredAccounts()` to handle the new filter value
7. **To refresh Snowflake data:** Run the queries above, process with Python, write to data.js, git push
8. **CSS variables** are at the top of the file (`:root { --bg: #0f1923; ... }`) — change theme here
9. **To update the Goose recipe:** Edit `recipes/seller-signals-agent.yaml` — add new tables, query patterns, or advisory actions
10. **For comp accuracy:** Always reference [go/AMCompHub](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c) — contract multiplier is 1.1x on **in-quarter** GPV and AR (quarterly, not annual)

---

## Commit History (key milestones)

| Commit | Date | Description |
|--------|------|-------------|
| Initial | 2026-03-04 | Dashboard built in a single day — 1,729 accounts, full UI, seller intelligence |
| Various | 2026-03-04 | Product adoption enrichment (99% match), location data, peer benchmarking |
| `ba8592d` | 2026-03-04 | Last commit before Retention Intelligence rewrite |
| `4eefd66` | 2026-03-05 | **Retention Intelligence rewrite** — 5-section seller-outcome-focused framing, saasAr mapping, comp-accurate contract multiplier |
| `1e4ad86` | 2026-03-05 | **Goose data agent recipe** — 25+ Snowflake tables, seller signals + AM performance |
