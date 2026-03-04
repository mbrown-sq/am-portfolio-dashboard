# AU SMB Portfolio Intelligence Platform
## Vision, Strategy & Alignment to Project Orbit and GTM Automation

**Author:** Mallory Brown, AU SMB Team Lead
**Created:** March 4, 2026
**Last updated:** March 5, 2026
**Status:** Working prototype live on GitHub Pages — Retention Intelligence rewritten, Data Agent recipe built

---

## Executive Summary

We've built a working **Seller Intelligence Platform** for AU SMB Account Managers — a single-screen tool that transforms raw portfolio data into actionable seller insights, conversation starters, and prioritised next best actions.

This isn't a replacement for SmartHub. It's a demonstration of **what the AM experience could look like** when we combine unified data, seller context, and intelligent recommendations into one view — aligned to the GTM Automation Strategy and Project Orbit's retention priorities.

The prototype is live today with real data: 1,729 AU SMB accounts, 99% product adoption coverage, location data, peer benchmarking, and AI-generated seller narratives. It was built in a single day using existing Snowflake data, requiring zero new infrastructure.

**Since the initial build (March 4), two major additions:**
1. **Retention Intelligence rewrite** — replaced generic comp-framing with a 5-section seller-outcome-focused model grounded in Project Orbit's churned seller research, with comp-accurate contract multiplier math
2. **Data Agent recipe** — a Goose recipe covering 25+ Snowflake tables (seller signals + AM performance metrics) that lets AMs ask natural language questions about their book of business

---

## The Problem We're Solving

From the GTM Automation Strategy doc:

> *"AMs are spending hours every day at Square, trying to learn about our Sellers, products, and processes → costs us growth for Sellers and GPV."*

From the Goose for AM discovery (Emil Kiroff):

> *"To answer a single seller question, AMs must search Salesforce, Smart Hub, Regulator, and often Slack to find both structured and unstructured context."*

From the Project Orbit churned seller research:

> Two key churn patterns identified:
> 1. **Failure of Responsiveness** — Square responds too little too late
> 2. **Failure of Education** — sellers assume we can't grow with them

**The current AM workflow:**
- Open SmartHub → find the account → see basic metrics
- Open Salesforce → check activity history, opportunities, contract status
- Open Looker → check GPV trends, AR growth
- Open Regulator → check compliance/risk
- Mentally synthesise all of this before picking up the phone

**What we've built:**
- Click one account → see everything: narrative, actions, features, retention risk, products, peers
- AM reads for 30 seconds → picks up the phone armed with specific numbers and conversation starters
- Every recommendation includes exact words the AM can say to the seller
- Ask a natural language question → get a Snowflake-backed answer about any seller or metric

---

## What the Platform Does Today

### For Every Seller (1,729 accounts):

**Know Your Seller Narrative**
A plain-English briefing with specific numbers — not generic summaries. Example:

> *"Bromley's Bread is a food & beverage business that's been with Square for 7.3 years. 6 locations based around the Mentone area — they're operating at chain scale. They're processing A$2.24M annually — top 1% of food sellers. Their trailing 9-month GPV is A$3.03M vs A$2.24M annualised — that's +35% acceleration. They're likely expanding. Their avg ticket of $12.00 points to high-frequency counter-service — speed and reliability at the register matter most."*

**Next Best Actions (up to 5 per account)**
Prioritised across three categories:
- 🔴 **URGENT** — DM ownership window closing, GPV declining, contract at risk
- 📈 **GROW** — product recommendations with dollar estimates, peer proof points
- 🎉 **CELEBRATE** — anniversaries, GPV milestones, growth recognition

**Feature Awareness**
Matches recently shipped features to relevant sellers with exact talk tracks:
> *"3P Order Pausing just launched — your kitchen staff can now pause DoorDash/Uber Eats orders directly from POS during busy service."*

**Retention Intelligence (rewritten March 5)**
Five-section seller-outcome-focused model, grounded in Project Orbit's churned seller research:

1. **Churn Pattern Diagnosis** — Identifies Failure of Education vs Failure of Responsiveness patterns with personalised conversation openers (uses seller name, tenure, GPV; differentiates severe vs moderate decline)
2. **Stickiness Assessment** — Rates seller lock-in using product count, contract status, and SaaS AR (High / Moderate / Low) with specific guidance for each level
3. **What's at Stake** — Portfolio weight + AR impact for at-risk accounts; contract multiplier framing only when actionable (non-contracted sellers >A$500K GPV), using correct in-quarter GPV math per [go/AMCompHub](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c)
4. **Category-Specific Risk Signals** — F&B (avg ticket-aware: café/QSR vs premium dining), Retail (online channel check), Beauty (Appointments as competitor risk via Fresha/Timely)
5. **Peer Context** — Compares seller's decline against category-wide trends to distinguish market-wide issues from outliers

Coverage: 57% of accounts trigger at least one retention signal (993/1,729).

**Product Adoption (99% coverage from Snowflake)**
Real data showing every Square product each seller uses — and what they don't. Every gap is a conversation starter with dollar estimates of the opportunity.

**Peer Benchmarking & Similar Sellers**
Shows where a seller sits vs peers in the same category. Surfaces product gaps: *"3/4 similar food sellers use Loyalty — this one doesn't."*

**Milestone Celebrations**
Anniversaries, GPV milestones, growth recognition — reasons to call that aren't about selling.

### Data Agent (Goose Recipe — built March 5)

A comprehensive Goose recipe (`recipes/seller-signals-agent.yaml`) that lets AMs ask natural language questions and get Snowflake-backed answers in real time. Covers **25+ tables** across two knowledge domains, built from two reference documents:

**Reference Documents:**
- **"SMB AM Seller Account Signals Data Guide"** — 15 seller signal tables across churn prediction, hardware lifecycle, product adoption, engagement, and financial signals
- **"Data Query Building Blocks for AM Agent"** — AM performance query patterns covering book composition, GPV, AR, pacing, activities, contracts, CS cases, and NNRO

**Seller Signal Tables (15):** Churn predictions, hardware warranty/health, product adoption & cross-sell, seller insights & sentiment, engagement & communication preferences, device LTV

**AM Performance Tables (10+):** Book composition, GPV at BID/MT level, AR Added/Growth, pacing to goal (pokemon_snap), activities with deduplication, contracts & multiplier eligibility, CS cases, new vs mature classification, location counts, SaaS subscriptions, NNRO

**Built-in safeguards:**
- Standardised date UDFs (never manual date math)
- 8 documented anti-patterns to avoid
- Advisory playbook with thresholds and recommended actions
- Join patterns for scoping every query to the AM's book
- AU SMB team filtering baked in

---

## How This Differs from SmartHub

| Dimension | SmartHub | Portfolio Intelligence Platform |
|-----------|----------|-------------------------------|
| **Purpose** | Operational — manage accounts, log activities | Strategic — prepare for calls, identify opportunities |
| **Data** | Per-account metrics | Cross-portfolio insights, peer comparisons, product gaps |
| **Intelligence** | Shows data | Interprets data — tells you what it means and what to do |
| **Narrative** | None | Plain-English seller briefing with conversation starters |
| **Actions** | Log activity, create task | Prioritised next best actions with specific recommendations |
| **Products** | Shows what seller has | Shows what's missing + why it matters + dollar opportunity |
| **Features** | None | Matches new features to relevant sellers with talk tracks |
| **Retention** | Risk flags | 5-section churn pattern diagnosis + stickiness + peer context |
| **Peers** | None | Similar seller comparison + product gap analysis |
| **Ad-hoc questions** | Not possible | Data agent queries 25+ Snowflake tables via natural language |

**This is not a replacement for SmartHub.** SmartHub is the system of record. This platform is the **intelligence layer** that sits on top — turning SmartHub's data into action.

The long-term vision is integration: this intelligence could surface inside SmartHub, inside a GTM console, or as a standalone tool. The value is in the logic, not the container.

---

## Alignment to GTM Automation Strategy

### Direct Alignment

| GTM Initiative | How This Platform Addresses It |
|---------------|-------------------------------|
| **Pre-call Bot** ("Surface key info and areas to probe") | Know Your Seller narrative + Next Best Actions + Data Agent for ad-hoc questions |
| **Post-call Bot** ("Next best actions, logging, follow-up") | NBA engine generates prioritised actions per account |
| **Post-Sale** ("Give one portfolio view they can trust") | Single unified view with data from 5+ Snowflake sources |
| **Unified Data Layer** ("Productize GTM data") | Joins SFDC, Hexagon, AM Ownership, Product Events, Employment into one dataset; Data Agent covers 25+ tables |
| **Content Automation** ("Centralize AM content") | Feature Awareness links product recommendations to relevant context |

### Alignment to Project Orbit (Code Red: Retention)

| Orbit Priority | Platform Feature |
|---------------|-----------------|
| Reduce $19.47B churned GPV | Retention Intelligence identifies churn patterns with seller-specific conversation openers |
| Address "Failure of Education" | Product adoption gaps + dollar estimates + stickiness assessment showing lock-in risk |
| Address "Failure of Responsiveness" | DM ownership window tracking + severity-differentiated decline alerts |
| SMB+ without AM = at-risk segment | Payments-only seller flagging with "could switch with zero friction" warning |
| F&B = highest churn category | Category-specific risk signals (avg ticket-aware: café/QSR vs premium dining) |
| Concierge expansion to $900K | Auto-flags sellers who now qualify for Concierge support |
| New feature launches (3P Pausing, Split Payments, etc.) | Feature Awareness matches 10 recent Orbit features to relevant sellers |
| "Retention Dashboard PoC exploring SmartHub integration" | This IS that PoC — built with real data, ready for feedback |
| Churn prediction models | Data Agent can query CHURN_PREDICTIONS_WINBACK for ML-scored churn probability |
| Hardware lifecycle management | Data Agent covers warranty expiration, device health, inactive hardware re-engagement |

---

## Data Architecture

### Current State (Working Prototype)
```
Snowflake Queries (manual, ~7 tables joined)
    ↓
Python processing scripts
    ↓
data.js (static file, 436KB, 1,729 accounts)
    ↓
index.html (client-side rendering, zero dependencies)
    ↓
GitHub Pages (auto-deploys on push to main)

+ Goose Data Agent (recipes/seller-signals-agent.yaml)
    ↓
  AM loads recipe in Goose → asks question → Goose queries Snowflake → returns answer
  (25+ tables, standardised UDFs, advisory playbook)
```

### Proposed Future State
```
Snowflake (scheduled queries via Squarewave — daily refresh)
    ↓
Automated pipeline (Python + git push)
    ↓
data.js (auto-generated nightly)
    ↓
GitHub Pages / Blockcell
    ↓
Embedded Chat Widget ←→ Backend (Blockcell / GCP Cloud Function)
    ↓                        ↓
Dashboard UI              Goose Agent + Snowflake (25+ tables)
    ↓
Slack notifications for urgent alerts (GPV drops, milestone celebrations)
    ↓
Optional: Surface intelligence inside SmartHub or GTM Console
```

### Data Sources

**Dashboard (static, in data.js — 7 tables):**
- `APP_SALES.APP_SALES_ETL.MERCHANT_PRODUCT_EVENTS` — product adoption
- `APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP` — business ID ↔ merchant token
- `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2` — AM ownership
- `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT` — AM team filtering
- `APP_BI.HEXAGON.VDIM_USER` — location data (city, state, postcode)
- `APP_SALES.GOLD_LAYER.SFDC_ACCOUNT_RAW_TEMP` — SFDC account fields
- `AM_ANALYTICS.AM_ANALYTICS_ETL.SMB_VARCOMP_AR_GROWTH` — AR growth wins

**Data Agent (real-time via Goose, 25+ tables):**
- Churn: `CHURN_PREDICTIONS_WINBACK`, `SHEALTH_RISK_CHURN`
- Hardware: `HARDWARE_REPLACEMENT_SUMMARY`, `HARDWARE_CHURN_RESURRECTION`, `FIVETRAN.DEVICES.DEVICES`
- Products: `MERCHANT_PRODUCT_EVENTS`, `AM_WINS_UNIFIED_COMBINED`, `AM_CROSS_SELL_PRODUCT_EVENTS_COMBINED`, `SELLER_INSIGHTS`
- Engagement: `MERCHANT_MESSAGES`, `MERCHANT_MESSAGE_UNIT_CLICKED`, `MERCHANT_MESSAGE_UNIT_DISMISSED`, `MERCHANT_SETTINGS`
- Financial: `DEVICE_LTV`
- AM Performance: `am_fact_employment_current`, `smb_varcomp_gpv_bid_mt_population`, `smb_varcomp_gpv`, `smb_varcomp_ar_added`, `pokemon_snap`, `am_fact_activities`, `am_fact_activities_fanout`, `smb_varcomp_contracts_detail`, `smb_varcomp_contracts_mt_am`, `am_varcomp_foundational`, `vdim_user`, `vfact_subscription_states_expanded`, `nnro_sources_combined`, `smb_varcomp_nnro_attainment`

**Reference Documents:**
- "SMB AM Seller Account Signals Data Guide" (Google Doc) — 15 seller signal tables with schemas, join patterns, and advisory actions
- "Data Query Building Blocks for AM Agent" (Google Doc) — AM performance query patterns, standardised UDFs, 8 anti-patterns, comp metric formulas

---

## Vision: Where This Goes

### Phase 1 — Static Dashboard + Seller Intelligence ✅ (March 4)
Static dashboard with seller intelligence, refreshed manually. 1,729 accounts with full product adoption, location, peer benchmarking, narratives, and next best actions.

### Phase 1b — Retention Intelligence Rewrite ✅ (March 5)
Replaced generic comp-framing with 5-section seller-outcome-focused retention intelligence. Added SaaS AR stickiness assessment, comp-accurate contract multiplier math (in-quarter GPV per [go/AMCompHub](https://www.notion.so/square-seller/AM-Comp-SMB-Metrics-Explainer-27f70293beed80bba328ff2c653a614c)), and category-specific risk signals.

### Phase 1c — Data Agent Recipe ✅ (March 5)
Built Goose recipe covering 25+ Snowflake tables across seller signals and AM performance metrics. AMs can load the recipe and ask natural language questions about their book. Includes standardised UDFs, anti-pattern guards, advisory playbook, and AU SMB scoping.

### Phase 2 — Automated Daily Refresh + Agent Launcher
- Squarewave job runs nightly, regenerates data.js, pushes to GitHub Pages. AMs always see yesterday's data.
- Feature news updated by team leads via simple array edit.
- Dashboard includes a Data Agent launcher panel with example questions and Goose recipe integration.

### Phase 3 — Embedded Chat Widget + Backend
- **Backend** (Blockcell or GCP Cloud Function) proxies between dashboard and Snowflake — keeps API keys server-side
- **Auth** scopes queries to the AM's book using the AM dropdown identity
- Chat widget embedded in the dashboard sends questions to backend → Goose agent → Snowflake → formatted response
- Request Blockcell via internal channels; GCP via [cloud-portal.sqprod.co](https://cloud-portal.sqprod.co/requests/new)

### Phase 4 — Real-Time Notifications
Slack bot alerts AMs when:
- A seller's GPV drops >10% week-over-week
- A seller hits a milestone (anniversary, GPV crossing A$1M)
- A new feature ships that's relevant to their top accounts
- DM ownership window is approaching 6 months
- A similar seller in their portfolio just adopted a product (social proof trigger)

### Phase 5 — External Enrichment
- Google Places API: reviews, ratings, social links, business hours
- Google Business Profile: recent posts, photos, Q&A
- Social media: Instagram/Facebook follower count, posting frequency
- ABN registry: business status verification

This transforms the narrative from internal data to: *"Bromley's Bread has 4.6★ on Google with 1,200 reviews (up 15% this quarter). They posted on Instagram yesterday about their new sourdough range. Their ABN is active with 6 registered locations."*

### Phase 6 — Full Agentic Integration
- "Prep me for my call with Bromley's Bread" → full briefing generated from dashboard data + real-time Snowflake queries
- Auto-draft follow-up emails based on call notes
- Proactive daily outreach suggestions pushed to each AM
- Churn prediction model integrated into retention intelligence (PRED_PROB from ML table)
- Voice-to-action: AM speaks call notes, system logs activity and generates next steps

---

## What We Need

1. **Squarewave access** — to automate the daily data refresh pipeline
2. **Blockcell or GCP project** — for the chat backend (Phase 3) and Google Places API enrichment (Phase 5). Request via [cloud-portal.sqprod.co](https://cloud-portal.sqprod.co/requests/new) or #blockplat-help
3. **AM team feedback** — the prototype needs testing by Antony, Simran, Pascale, and the team. The Data Agent recipe is ready for testing now.
4. **Connection to Orbit Retention team** — the "Retention Dashboard PoC exploring SmartHub integration" from the Orbit weekly is essentially what we've built. We should align and share learnings.
5. **GTM Eng awareness** — this prototype demonstrates the "Post-Sale" lifecycle stage (currently scored 8/15 in the GTM prioritisation). A working prototype with real data + a 25-table data agent may change that scoring.
6. **Retention Mobile Pod** — the Orbit notes mention "1-2 engineers from the retention squad to partner with AM team." This platform could be the vehicle for that partnership.

---

## Why This Matters

The AM role is at an inflection point. The GTM Automation Strategy is investing heavily in prospect, qualify, and close — the front of the funnel. Post-sale (where AMs live) is deprioritised at 8/15.

But the retention numbers tell a different story: **10% churn = $19.47B GPV/year**. The churned seller research found that the two biggest drivers — Failure of Responsiveness and Failure of Education — are exactly what AMs are positioned to solve.

The gap isn't AM effort. It's AM tooling. AMs today spend more time gathering information than acting on it. This platform flips that ratio.

**The vision:** Every AM walks into every call knowing their seller's business better than the seller expects. They reference specific numbers. They mention relevant new features. They celebrate milestones. They recommend products with peer proof points and dollar estimates. And when they have a question the dashboard doesn't answer, they ask the Data Agent and get a Snowflake-backed answer in seconds.

That's not a dashboard. That's a competitive advantage. It's what keeps sellers with Square and what makes them recommend us to their friends.

---

*Built with Goose + Snowflake + existing AM data infrastructure. Zero new systems required.*
