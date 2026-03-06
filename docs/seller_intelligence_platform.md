# AU SMB Seller Intelligence Platform

*Turning portfolio data into actionable seller intelligence — so AMs walk into every call as advisors, not administrators.*

**Author:** Mallory Brown, AU SMB Team Lead
**Date:** March 5, 2026
**Status:** Live prototype on GitHub Pages with real data
**Dashboard:** mbrown-sq.github.io/am-portfolio-dashboard

---

# The Problem

**AMs spend more time gathering information than acting on it.**

To prepare for a single seller call, an AM currently has to:
- Open SmartHub → find the account → see basic metrics
- Open Salesforce → check activity history, opportunities, contract status
- Open Looker → check GPV trends, AR growth
- Open Regulator → check compliance/risk
- Mentally synthesise all of this before picking up the phone

The result: AMs are reactive instead of proactive. They're administrators instead of advisors. And sellers notice.

**Project Orbit's churned seller research identified two key churn patterns:**

1. **Failure of Education** — sellers assume Square can't grow with them because no one has shown them what's possible
2. **Failure of Responsiveness** — Square responds too little, too late

These two patterns are the biggest drivers of the **$19.47B in annual churned GPV** identified by Code Red. They are exactly what AMs are positioned to solve — if they have the right tools.

> *"AMs are spending hours every day at Square, trying to learn about our Sellers, products, and processes → costs us growth for Sellers and GPV."* — GTM Automation Strategy

---

# The Solution

**A single-screen Seller Intelligence Platform** that transforms raw portfolio data into actionable insights, conversation starters, and prioritised next best actions.

An AM clicks one seller → reads for 30 seconds → picks up the phone armed with specific numbers, talk tracks, product recommendations with peer proof points, and retention intelligence grounded in real data.

**Live today with real data:**
- 1,729 AU SMB accounts with full data
- A$839.2M total portfolio GPV
- 99% product adoption coverage from Snowflake
- 9 AMs across the team
- 213 at-risk accounts, 1,078 on watch, 438 healthy
- Built using existing Snowflake data — zero new infrastructure required

---

# Features & Benefits

## 1. Know Your Seller Narrative

Every account gets a plain-English briefing with specific numbers — not generic summaries. Covers tenure, GPV trajectory, average ticket context (e.g. "high-frequency counter-service — speed and reliability matter most"), location scale, and acceleration signals.

*Example: "Bromley's Bread is a food & beverage business that's been with Square for 7.3 years. 6 locations based around the Mentone area — they're operating at chain scale. Processing A$2.24M annually — top 1% of food sellers. Their trailing 9-month GPV is A$3.03M vs A$2.24M annualised — that's +35% acceleration. They're likely expanding."*

**Benefit:** AMs walk into calls knowing the business, not just the account. Sellers feel understood from the first sentence.

**Code Red alignment:** Directly addresses Failure of Education — AMs can demonstrate they know the seller's business.

## 2. Next Best Actions (up to 5 per account)

Prioritised actions across three categories:
- 🔴 **URGENT** — DM ownership window closing, GPV declining, contract at risk
- 📈 **GROW** — product recommendations with dollar estimates, peer proof points
- 🎉 **CELEBRATE** — anniversaries, GPV milestones, growth recognition

Every recommendation includes exact talk tracks — specific words the AM can say to the seller.

**Benefit:** AMs don't have to figure out what to do — the platform tells them, in priority order, with the words to say.

**Code Red alignment:** Addresses Failure of Responsiveness — proactive outreach triggers before it's too late.

## 3. Product Recommendations via Peer Comparison

Compares each seller against similar businesses in the same MCC category and surfaces product gaps with context. Instead of "you should try Loyalty," it's:

*"3 out of 4 similar food sellers in your portfolio use Loyalty — here's what it could do for a business like yours."*

The AM has a reason, a proof point, and a conversation starter — backed by real data from 99% product adoption coverage across the portfolio.

**Benefit:** Product conversations become advisory, not sales pitches. AMs can reference what similar businesses are doing.

**Code Red alignment:** Addresses Failure of Education — sellers learn what Square can do for businesses like theirs.

## 4. Feature Awareness

When new features ship (3P Order Pausing, Split Payments, etc.), the dashboard automatically matches them to relevant sellers based on category, ticket size, product usage, and location count — with exact talk tracks.

*Example: "3P Order Pausing just launched — your kitchen staff can now pause DoorDash/Uber Eats orders directly from POS during busy service."*

**Benefit:** AMs don't have to figure out which sellers care about which launches. The platform does the matching.

**Code Red alignment:** Addresses Failure of Education — sellers hear about relevant features proactively.

## 5. Retention Intelligence (5-section analysis)

Grounded in Project Orbit's churned seller research. Every at-risk or declining seller gets a structured analysis:

1. **Churn Pattern Diagnosis** — Identifies Failure of Education vs Failure of Responsiveness with personalised conversation openers using the seller's name, tenure, and GPV
2. **Stickiness Assessment** — Rates seller lock-in using product count, contract status, and SaaS AR (High / Moderate / Low stickiness)
3. **What's at Stake** — Portfolio weight and AR impact in dollar terms; contract multiplier framing only when actionable
4. **Category-Specific Risk Signals** — F&B (avg ticket-aware: café/QSR vs premium dining), Retail (online channel check), Beauty (Appointments as competitor risk via Fresha/Timely)
5. **Peer Context** — Compares seller's decline against category-wide trends. "26% of retail sellers declining" = market-wide issue. "Only 8% declining" = outlier, dig deeper.

57% of accounts (993 of 1,729) trigger at least one retention signal.

**Benefit:** AMs understand not just that a seller is at risk, but why — and what to say about it.

**Code Red alignment:** This is the retention playbook in action. Directly operationalises the Orbit churned seller research.

## 6. Risk Transparency

Every seller's risk status (Healthy / Watch / At-Risk) is fully explained. AMs can hover any risk badge in the table and see exactly why:

*"GPV declining -18%, no contact in 94 days, only 1 product, no contract"*

When filtered to an individual AM, the dashboard shows their GPV split across risk buckets — so they can see their exposure at a glance.

**Benefit:** No black boxes. AMs trust the data because they can see the reasoning.

## 7. Milestones & Celebrations

Automatically detects anniversaries, GPV milestones, growth recognition — reasons to call that aren't about selling.

**Benefit:** Builds relationships. Sellers remember when their AM called to say congratulations.

## 8. Portfolio Overview

- AM dropdown filters all sections to one AM's book
- KPI cards showing account count, GPV, at-risk/watch counts
- GPV by Risk Status breakdown per AM
- Weekly activity tracking (calls, emails, SMS per AM)
- QTD metrics (dials, DM calls, seller breadth)
- GPV by category breakdown
- At-risk alerts panel with SFDC links
- Full CSV export of filtered data
- Salesforce direct links for every account

---

# Seller One-Pager

A dedicated button in each seller's detail view that generates a comprehensive briefing document by pulling live data from Snowflake. The one-pager includes:

- **Business snapshot** — location, tenure, service level, contract status, churn risk score
- **GPV & revenue trends** — quarterly with period-over-period and year-over-year comparisons
- **Full product adoption** — every product with first/last used dates, dormant product flags
- **Communication history synthesised into a narrative** — not just a list of calls, but a story: "Over the last 6 months, the main themes have been their expansion plans (discussed Oct and Dec), concerns about 3P delivery (raised Nov, resolved Jan), and interest in Loyalty (mentioned twice, not yet adopted)."
- **Gong call summaries** — AI-generated briefs, highlights, action items, and key points from recorded calls
- **CS support case history** — open cases, patterns, categories
- **Recommended talking points** — 3-5 specific, data-backed conversation starters that reference past interactions

**How it works:** AM clicks "Seller One-Pager" in the dashboard → prompt is copied to clipboard → paste into Goose → full briefing generates from live Snowflake data.

**Data sources:** AM_FACT_ACTIVITIES (calls, emails, SMS), GONG_DETAILED_CALLS (call transcripts and AI summaries), SUPPORT_CASE_LIST (CS cases), MERCHANT_PRODUCT_EVENTS (products), SMB_VARCOMP_GPV (revenue), CHURN_PREDICTIONS_WINBACK (ML churn score).

**Benefit:** An AM can prep for any call in 60 seconds with full context on what's been discussed, what was promised, and what to bring up next.

**Code Red alignment:** Directly addresses both churn patterns — the AM is educated about the seller AND responsive to past conversations.

---

# Data Agent / Chatbot

## What it is

A Goose-powered data agent that can answer natural language questions about any seller, book of business, or performance metric by querying Snowflake in real-time. Covers **25+ data tables** across:

**Seller Signals (15 tables):**
- Churn predictions (ML probability scores, outreach priority)
- Hardware lifecycle (warranty expiration, device health, inactive hardware)
- Product adoption & cross-sell funnels (conversion blockers, days to convert)
- Seller insights & sentiment (pain points, competitors, reasons lost)
- Engagement & communication preferences (notification delivery, plugin status)
- Device LTV (hardware ROI)

**AM Performance (10+ tables):**
- Book composition, GPV at BID/MT level, AR Added/Growth
- Pacing to goal, activities with deduplication, contracts & multiplier eligibility
- CS cases, new vs mature classification, location counts, SaaS subscriptions, NNRO

## Example questions an AM can ask
- "How am I pacing to my GPV goal this quarter?"
- "Who's at highest churn risk in my book?"
- "What products is Bromley's Bread using?"
- "Which sellers have hardware approaching end of life?"
- "How many open CS cases do my sellers have?"
- "Show me sellers with declining transactions this quarter"

## Current state
The Data Agent is accessible from a floating button on the dashboard. AMs click it, see example questions, and can copy a prompt to use in Goose.

## Future state
Embedded chat widget directly in the dashboard — AM types a question, backend routes to Goose agent → Snowflake → formatted response displayed in the dashboard. No context switching.

---

# Alignment to Code Red & GTM Automation

## Code Red: Retention ($19.47B churned GPV)

| Orbit Priority | How This Platform Addresses It |
|---|---|
| Reduce $19.47B churned GPV | Retention Intelligence identifies churn patterns with seller-specific conversation openers |
| Failure of Education | Product adoption gaps + dollar estimates + peer comparisons + stickiness assessment |
| Failure of Responsiveness | DM ownership window tracking + severity-differentiated decline alerts + proactive outreach triggers |
| SMB+ without AM = at-risk segment | Payments-only seller flagging with "could switch with zero friction" warning |
| F&B = highest churn category | Category-specific risk signals (avg ticket-aware: café/QSR vs premium dining) |
| Churn prediction models | Data Agent queries CHURN_PREDICTIONS_WINBACK for ML-scored churn probability |
| Hardware lifecycle management | Data Agent covers warranty expiration, device health, inactive hardware re-engagement |

## GTM Automation Strategy Alignment

| GTM Initiative | How This Platform Addresses It |
|---|---|
| Pre-call Bot ("Surface key info and areas to probe") | Know Your Seller narrative + Next Best Actions + Seller One-Pager with Gong call summaries |
| Post-call Bot ("Next best actions, logging, follow-up") | NBA engine generates prioritised actions per account |
| Post-Sale ("Give one portfolio view they can trust") | Single unified view with data from 25+ Snowflake sources |
| Unified Data Layer ("Productize GTM data") | Joins SFDC, Hexagon, AM Ownership, Product Events, Employment, Gong, CS Cases into one dataset |
| Content Automation ("Centralize AM content") | Feature Awareness links product recommendations to relevant context with talk tracks |

The GTM Automation Strategy scores Post-Sale at 8/15 in lifecycle prioritisation — noting it's "mostly data quality / continuity challenges" that "can be addressed through earlier data foundation work." This platform demonstrates that a working Post-Sale intelligence layer can be built today with existing data, requiring zero new infrastructure.

---

# Future Roadmap

**Phase 1 — Complete ✅**
Static dashboard with full seller intelligence (1,729 accounts), Retention Intelligence rewrite (5-section seller-outcome model), Data Agent recipe (25+ Snowflake tables), Seller One-Pager recipe (Gong summaries, activity history, CS cases).

**Phase 2 — Automated Daily Refresh**
Squarewave job runs nightly, regenerates data, pushes to GitHub Pages. AMs always see yesterday's data.

**Phase 3 — Embedded Chat Widget + Backend**
Blockcell or GCP Cloud Function backend. Chat widget embedded directly in the dashboard.

**Phase 4 — Real-Time Notifications**
Slack alerts when seller GPV drops >10%, milestones hit, DM window approaching 6 months.

**Phase 5 — External Enrichment**
Google Places API: Google reviews, ratings, website, social media. Transform narrative from internal data to: "Bromley's Bread has 4.6★ on Google with 1,200 reviews. They posted on Instagram yesterday about their new sourdough range."

**Phase 6 — Full Agentic Integration**
"Prep me for my call with Bromley's Bread" → full briefing generated. Auto-draft follow-up emails. Seller one-pagers with Rev.io / Salesforce conversation history. Voice-to-action.

---

# What We Need

1. **Squarewave access** — to automate the daily data refresh pipeline
2. **Blockcell or GCP project** — for the embedded chat backend and Google Places API enrichment
3. **AM team feedback** — the prototype is ready for testing by the full AU SMB team
4. **Connection to Orbit Retention team** — this is the "Retention Dashboard PoC exploring SmartHub integration" from the Orbit weekly
5. **GTM Eng awareness** — a working prototype with real data + 25-table data agent may change the Post-Sale prioritisation scoring

---

*Built with Goose + Snowflake + existing AM data infrastructure. Zero new systems required.*
