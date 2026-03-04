# AU SMB Portfolio Intelligence Platform
## Vision, Strategy & Alignment to Project Orbit and GTM Automation

**Author:** Mallory Brown, AU SMB Team Lead
**Date:** March 4, 2026
**Status:** Working prototype live on GitHub Pages

---

## Executive Summary

We've built a working prototype of a **Seller Intelligence Platform** for AU SMB Account Managers — a single-screen tool that transforms raw portfolio data into actionable seller insights, conversation starters, and prioritised next best actions.

This isn't a replacement for SmartHub. It's a demonstration of **what the AM experience could look like** when we combine unified data, seller context, and intelligent recommendations into one view — aligned to the GTM Automation Strategy and Project Orbit's retention priorities.

The prototype is live today with real data: 1,729 AU SMB accounts, 99% product adoption coverage, location data, peer benchmarking, and AI-generated seller narratives. It was built in a single day using existing Snowflake data, requiring zero new infrastructure.

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

**Retention Intelligence**
Flags the two churn patterns from the Orbit research:
- Failure of Education: sellers on free POS for years who don't know what Square offers
- Failure of Responsiveness: declining GPV + no recent DM
- Portfolio impact framing tied to GPV Growth & Retention attainment (60% of comp)

**Product Adoption (99% coverage from Snowflake)**
Real data showing every Square product each seller uses — and what they don't. Every gap is a conversation starter with dollar estimates of the opportunity.

**Peer Benchmarking & Similar Sellers**
Shows where a seller sits vs peers in the same category. Surfaces product gaps: *"3/4 similar food sellers use Loyalty — this one doesn't."*

**Milestone Celebrations**
Anniversaries, GPV milestones, growth recognition — reasons to call that aren't about selling.

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
| **Retention** | Risk flags | Churn pattern identification + comp impact framing |
| **Peers** | None | Similar seller comparison + product gap analysis |

**This is not a replacement for SmartHub.** SmartHub is the system of record. This platform is the **intelligence layer** that sits on top — turning SmartHub's data into action.

The long-term vision is integration: this intelligence could surface inside SmartHub, inside a GTM console, or as a standalone tool. The value is in the logic, not the container.

---

## Alignment to GTM Automation Strategy

### Direct Alignment

| GTM Initiative | How This Platform Addresses It |
|---------------|-------------------------------|
| **Pre-call Bot** ("Surface key info and areas to probe") | Know Your Seller narrative + Next Best Actions |
| **Post-call Bot** ("Next best actions, logging, follow-up") | NBA engine generates prioritised actions per account |
| **Post-Sale** ("Give one portfolio view they can trust") | Single unified view with data from 5+ Snowflake sources |
| **Unified Data Layer** ("Productize GTM data") | Joins SFDC, Hexagon, AM Ownership, Product Events, Employment into one dataset |
| **Content Automation** ("Centralize AM content") | Feature Awareness links product recommendations to relevant context |

### Alignment to Project Orbit (Code Red: Retention)

| Orbit Priority | Platform Feature |
|---------------|-----------------|
| Reduce $19.47B churned GPV | Retention Intelligence flags at-risk accounts with attainment impact |
| Address "Failure of Education" | Product adoption gaps + dollar estimates + conversation scripts |
| Address "Failure of Responsiveness" | DM ownership window tracking (6-month model) + proactive outreach triggers |
| SMB+ without AM = at-risk segment | Payments-only seller flagging |
| F&B = highest churn category | Category-specific retention signals and feature matching |
| Concierge expansion to $900K | Auto-flags sellers who now qualify for Concierge support |
| New feature launches (3P Pausing, Split Payments, etc.) | Feature Awareness matches 10 recent Orbit features to relevant sellers |
| "Retention Dashboard PoC exploring SmartHub integration" | This IS that PoC — built with real data, ready for feedback |

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
Slack notifications for urgent alerts (GPV drops, milestone celebrations)
    ↓
Optional: Surface intelligence inside SmartHub or GTM Console
```

### Data Sources (all existing, no new tables needed)
- `APP_SALES.APP_SALES_ETL.MERCHANT_PRODUCT_EVENTS` — product adoption
- `APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP` — business ID ↔ merchant token
- `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2` — AM ownership
- `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT` — AM team filtering
- `APP_BI.HEXAGON.VDIM_USER` — location data (city, state, postcode)
- `APP_SALES.GOLD_LAYER.SFDC_ACCOUNT_RAW_TEMP` — SFDC account fields
- `AM_ANALYTICS.AM_ANALYTICS_ETL.SMB_VARCOMP_AR_GROWTH` — AR growth wins

---

## Vision: Where This Goes

### Phase 1 — Current ✅
Static dashboard with seller intelligence, refreshed manually. 1,729 accounts with full product adoption, location, peer benchmarking, narratives, and next best actions.

### Phase 2 — Automated Daily Refresh
Squarewave job runs nightly, regenerates data.js, pushes to GitHub Pages. AMs always see yesterday's data. Feature news updated by team leads via simple array edit.

### Phase 3 — Real-Time Notifications
Slack bot alerts AMs when:
- A seller's GPV drops >10% week-over-week
- A seller hits a milestone (anniversary, GPV crossing A$1M)
- A new feature ships that's relevant to their top accounts
- DM ownership window is approaching 6 months
- A similar seller in their portfolio just adopted a product (social proof trigger)

### Phase 4 — External Enrichment
- Google Places API: reviews, ratings, social links, business hours
- Google Business Profile: recent posts, photos, Q&A
- Social media: Instagram/Facebook follower count, posting frequency
- ABN registry: business status verification

This transforms the narrative from internal data to: *"Bromley's Bread has 4.6★ on Google with 1,200 reviews (up 15% this quarter). They posted on Instagram yesterday about their new sourdough range. Their ABN is active with 6 registered locations."*

### Phase 5 — Agentic (Goose Integration)
- "Prep me for my call with Bromley's Bread" → full briefing generated
- Auto-draft follow-up emails based on call notes
- Proactive daily outreach suggestions pushed to each AM
- Churn prediction model integrated into retention intelligence
- Voice-to-action: AM speaks call notes, system logs activity and generates next steps

---

## What We Need

1. **Squarewave access** — to automate the daily data refresh pipeline
2. **GCP project** — for Google Places API enrichment (request via cloud-portal.sqprod.co)
3. **AM team feedback** — the prototype needs testing by Antony, Simran, Pascale, and the team
4. **Connection to Orbit Retention team** — the "Retention Dashboard PoC exploring SmartHub integration" from the Orbit weekly is essentially what we've built. We should align and share learnings.
5. **GTM Eng awareness** — this prototype demonstrates the "Post-Sale" lifecycle stage (currently scored 8/15 in the GTM prioritisation). A working prototype with real data may change that scoring.
6. **Retention Mobile Pod** — the Orbit notes mention "1-2 engineers from the retention squad to partner with AM team." This platform could be the vehicle for that partnership.

---

## Why This Matters

The AM role is at an inflection point. The GTM Automation Strategy is investing heavily in prospect, qualify, and close — the front of the funnel. Post-sale (where AMs live) is deprioritised at 8/15.

But the retention numbers tell a different story: **10% churn = $19.47B GPV/year**. The churned seller research found that the two biggest drivers — Failure of Responsiveness and Failure of Education — are exactly what AMs are positioned to solve.

The gap isn't AM effort. It's AM tooling. AMs today spend more time gathering information than acting on it. This platform flips that ratio.

**The vision:** Every AM walks into every call knowing their seller's business better than the seller expects. They reference specific numbers. They mention relevant new features. They celebrate milestones. They recommend products with peer proof points and dollar estimates.

That's not a dashboard. That's a competitive advantage. It's what keeps sellers with Square and what makes them recommend us to their friends.

---

*Built with Goose + Snowflake + existing AM data infrastructure. Zero new systems required.*
