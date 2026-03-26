# GOOSE_BRIEF.md — Read This First Every Session

> **Start every session with:**
> ```
> Read /Users/mbrown/Projects/am-portfolio-dashboard/GOOSE_BRIEF.md
> ```
> Then say what you need. Goose will have full context.
>
> **End every session with:**
> ```
> Wrap up
> ```
> Goose will update this file, mission-control-data.json, and give you a recap.
>
> **Last updated:** 2026-03-12 by Goose

---

## Who I Am

**Mallory Brown** — AU SMB Account Manager Team Lead at Square (Australia)
- Non-engineering background — I'm a business operator learning to build
- I think in outcomes and seller experience, not code
- I need clear, concise guidance — not menus of 7 options
- When I'm stuck, give me **one recommended path** and explain why. I'll ask for alternatives if I want them.

## How to Work With Me

1. **Be concise.** Action first, explanation only if I ask "why?"
2. **One recommendation, not a menu.** I trust your judgment — pick the best path.
3. **Build small, test often.** Never dump 500+ lines of code at once. Small change → verify → next change.
4. **Don't over-explain engineering concepts.** If I need to run a command, just give me the command. I'll ask if I don't understand.
5. **Track what's done and what's open.** End every session by updating the "Current Status" section below.

### ADHD Working Style — Important!

My brain connects ideas across tasks. I will jump between things mid-session and that's fine — **don't fight it, track it.**

**What Goose should do:**
- When I switch topics, just go with it. Don't say "let's finish X first."
- **But** before switching, quickly note where we were. One line like: *"Parking the modal fix — we got the click handler working, next step is styling. Moving to [new topic]."*
- If I seem stuck or circling, gently say: *"We've been on this for a while. Want to park it and come back, or push through?"*
- At the end of the session, give me a **quick recap of ALL threads** we touched — what moved forward, what's parked, what's still stuck.

**What I should do:**
- When I have a new idea mid-task, just say it. Goose will track it.
- If I want to stay focused, I'll say: *"Just noting this for later"* and Goose will add it to backlog without switching.
- End sessions with: *"Update GOOSE_BRIEF.md with what we did today"*

---

## The Project: AU SMB Seller Intelligence Platform

### What It Is
A single-screen dashboard that transforms raw portfolio data into actionable seller intelligence for AU SMB Account Managers. An AM clicks one seller → reads for 30 seconds → picks up the phone as an advisor, not an administrator.

### Why It Matters
- AMs spend more time gathering info than acting on it
- Project Orbit identified $19.47B/year churned GPV driven by "Failure of Education" and "Failure of Responsiveness" — exactly what AMs solve with better tooling
- 1,729 AU SMB accounts, A$839.2M portfolio GPV, 9 AMs

### Live URLs
- **Dashboard:** https://am-portfolio-dashboard.vibeplatstage.squarecdn.com
- **Refresher tile:** https://dashboard-refresher.vibeplatstage.squarecdn.com
- **GitHub (personal):** https://github.com/mbrown-sq/am-portfolio-dashboard
- **GitHub (org):** https://github.com/squareup/ausmbapp (PR pending approval)

### Deployed G2 Sites
| Site | D1 Database | URL |
|------|-------------|-----|
| am-portfolio-dashboard | `am-portfolio-dashboard-db` | https://am-portfolio-dashboard.vibeplatstage.squarecdn.com |
| dashboard-refresher | `dashboard-refresher-db` | https://dashboard-refresher.vibeplatstage.squarecdn.com |
| square-hardware-selector | `square-hardware-selector-db` | https://square-hardware-selector.vibeplatstage.squarecdn.com |

### Key Features (Working)
- Know Your Seller narrative (plain-English briefing with specific numbers)
- Next Best Actions (URGENT / GROW / CELEBRATE with talk tracks)
- Product recommendations via peer comparison
- Feature awareness (matches new launches to relevant sellers)
- Retention intelligence (5-section model grounded in Orbit research)
- Risk transparency (hover badges for Healthy / Watch / At-Risk)
- Data Agent recipe (25+ Snowflake tables, natural language queries)
- Dashboard refresher G2 tile (one-click data refresh)
- D1 database + 8 REST API endpoints

### Tech Stack
- **Frontend:** Static HTML/JS (index.html) + data.js (883KB, 1,729 accounts)
- **Hosting:** G2 (Block App Kit) on Cloudflare
- **Data:** 10 SQL queries in `/queries/` folder, hitting 7+ Snowflake tables
- **API:** Hono worker on Cloudflare with D1 database
- **Recipes:** Goose recipes in `/recipes/` for data refresh and seller agent

---

## Project File Map

```
/Users/mbrown/Projects/am-portfolio-dashboard/
├── index.html              ← Main dashboard (WORKING, deployed)
├── index-v2.html           ← V2 with seller modal (IN PROGRESS)
├── data.js                 ← Dashboard data (883KB, all 1,729 accounts)
├── data-v2.js              ← Backup of data file
├── build/
│   ├── client/             ← Deployed static files
│   └── server/index.js     ← Hono API worker (8 endpoints)
├── dashboard-refresher/    ← G2 tile app for one-click refresh (React + Vite + TS)
│   ├── src/App.tsx         ← Main refresh UI (uses useKgoose hook)
│   └── server/index.ts    ← Hono backend
├── queries/                ← 10 SQL files (01_accounts.sql through 10_contracts.sql)
├── recipes/                ← Goose recipes
│   ├── data-refresh-d1.yaml
│   ├── data-refresh-scheduled.yaml
│   ├── data-refresh-v2.yaml
│   ├── seller-one-pager.yaml
│   └── seller-signals-agent.yaml  ← Data Agent (25+ tables)
├── scripts/                ← Python refresh scripts
│   ├── refresh_data.py
│   ├── refresh_to_d1.py
│   └── sync_snowflake_to_d1.py
├── snowflake/              ← Snowflake table creation + scheduling SQL
│   ├── create_dashboard_snapshot.sql
│   └── schedule_daily_refresh.sql
├── migrations/             ← D1 database schema (0001_initial.sql)
├── docs/                   ← Vision doc + example one-pager
├── STRATEGY.md             ← GTM alignment and full platform vision (Phase 1-6)
├── ARCHITECTURE.md         ← Technical architecture
├── CURRENT_STATUS.md       ← System status
└── GOOSE_BRIEF.md          ← THIS FILE — read first every session
```

---

## Key Snowflake Tables

| Table | Purpose |
|-------|---------|
| `APP_SALES.APP_SALES_ETL.MERCHANT_PRODUCT_EVENTS` | Product adoption |
| `APP_MERCH_GROWTH.PUBLIC.DIM_AM_OWNERSHIP` | BID ↔ merchant token mapping |
| `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_ACCOUNT_OWNERSHIP_V2` | AM ownership |
| `APP_MERCH_GROWTH.APP_MERCH_GROWTH_ETL.AM_FACT_EMPLOYMENT_CURRENT` | AM team filtering |
| `APP_BI.HEXAGON.VDIM_USER` | Location data (city, state, postcode) |
| `APP_SALES.GOLD_LAYER.SFDC_ACCOUNT_RAW_TEMP` | SFDC account fields |
| `AM_ANALYTICS.AM_ANALYTICS_ETL.SMB_VARCOMP_AR_GROWTH` | AR growth wins |

---

## Known Blockers & Decisions Made

| Issue | Decision | Status |
|-------|----------|--------|
| Goose scheduled jobs can't use queryexpert extension | Use G2 tile for manual refresh instead | Workaround deployed |
| Snowflake CREATE TABLE permissions denied on `app_merch_growth` | Haven't resolved — need to find accessible database or ask admin | Blocked |
| 9MB request size limit on scheduled recipes | Externalized queries to `/queries/*.sql` files | Resolved |
| Dashboard data goes stale | G2 refresher tile for now; Snowflake Tasks or Squarewave for future | Manual for now |
| Multiple Mission Control app versions | Keep `mission-control-dashboard` (latest/best), can delete older v1 and v2 | Pending cleanup |

---

## Mission Control App

A personal ADHD-friendly project management dashboard built as a Goose app.

**Current version:** `mission-control-dashboard` (the latest, most complete)
**Older versions to clean up:** `mallory-mission-control`, `mallory-mission-control-v2`

### Features (7 tabs):
1. **My Day** — Focus input ("What's the ONE thing?"), tag filters, quick-add tasks, drag-to-reorder, confetti on completion, expandable task details (doc link, notes, waiting on, stakeholders)
2. **Work In Progress** — Project cards with name, doc link, description, status (Not Started / In Progress / Blocked / On Hold / Done), filter by status
3. **Board** — 4-column kanban (Right Now / Parked / Blocked / Ideas) with drag-and-drop
4. **Timeline** — Session history with expandable entries
5. **Links** — Quick links with status dots
6. **Decisions** — Decision log table with status badges
7. **Roadmap** — Collapsible project phases with progress bars

**Design:** Dark purple theme, localStorage persistence, FAB button (context-aware: quick task on My Day, quick idea on other tabs)

---

## Active Threads (update during session)

> This is the "parking lot." When we switch tasks mid-session, Goose logs where we left off here.

| Thread | Where We Left Off | Status |
|--------|-------------------|--------|
| G2 Space Build | Brief written (G2_SPACE_PROJECT_BRIEF.md). Next: open go/g2, create Space, start building tiles using the brief as context | Active |
| Mission Control data split | JSON file created, GOOSE_BRIEF documented. Next: run `iterate_app` to embed JSON in app + add Reset button | Active |
| Seller modal (v2) | Click handler fires, modal not displaying. Next: check browser console | Parked |
| Snowflake permissions | Need to find accessible database or ask admin | Blocked |
| Mission Control cleanup | Delete old app versions (v1, v2), keep `mission-control-dashboard` | Pending |

---

## Current Status

**Last session:** 2026-03-12

### Done
- Dashboard live and working on G2 (1,729 accounts)
- Dashboard refresher G2 tile deployed
- D1 database + API deployed (8 endpoints)
- All 10 SQL queries externalized
- GitHub repos updated (personal + org PR)
- Full documentation written (8+ docs)
- Data Agent recipe built (25+ tables)
- Strategy doc complete with Phase 1-6 roadmap
- GOOSE_BRIEF.md created and maintained
- Mission Control app built (v3 = `mission-control-dashboard` with all features)
- Workflow analysis completed — identified patterns and optimisations
- Square Hardware Selector app built and deployed
- G2 Space Project Brief written (15 sections, cross-referenced with Glean)
- Project folder cleaned up (12 redundant docs removed, down to 4)
- Mission Control data separated into JSON (mission-control-data.json)
- Session workflow commands set up (Wrap up / Park this / Just noting for later)

### In Progress
- **SMB GPV Floor Proposal:** Full project brief consolidated at `GPV_FLOOR_PROPOSAL_BRIEF.md`. Includes: margin impact (323 requests, 0 bps margin erosion, 1.30% avg CP), coverage analysis (8 markets), churn by tier (floor tier 3-8x higher), CS rate card argument (sub-$500K pricing is formulaic, single-conversation, rate card at ~1.30% solves escalation gap). Supporting data in `/analysis/smb-floor-coverage-analysis.md` and `/analysis/smb-floor-emily-cindie-response.md`. One-pager live at https://gpv-floor-proposal.vibeplatstage.squarecdn.com. Google Doc: https://docs.google.com/document/d/1YI_D3CmW0vEc_3n2yKos-izJigDxD-ioaWwiOpQ87uQ/edit
- **G2 Space Build:** Brief complete (`G2_SPACE_PROJECT_BRIEF.md`). Next step is building tiles in G2 at go/g2.
- **Mission Control data sync:** JSON file created. Need to run `iterate_app` to embed in app and add Reset button.
- **Seller detail modal (index-v2.html):** Click handler fires but modal not displaying. Field name mismatches were fixed but still not working. Need to debug in browser console.
- **Phase 2 — Enrichment:** At ~25%. Automated daily refresh not yet working.

### Blocked
- **Snowflake permissions:** Can't create tables in `app_merch_growth`. Need to find accessible database or request access.

### Backlog (not started)
- Populate D1 database with actual data
- Automated daily refresh (Snowflake Tasks or Squarewave)
- Quick action buttons (Call, Email, Slack) — currently "coming soon"
- External enrichment (Google Places API, Rev.io)
- Embedded chat widget for Data Agent
- Slack notifications for urgent alerts
- Clean up old Mission Control app versions

---

## Roadmap

| Phase | Description | Progress |
|-------|-------------|----------|
| Phase 1 — Core Dashboard | Static dashboard with seller intelligence | 100% |
| Phase 1b — Retention Intelligence | 5-section seller-outcome-focused model | 100% |
| Phase 1c — Data Agent Recipe | 25+ Snowflake tables, natural language queries | 100% |
| Phase 2 — Automated Refresh + Agent Launcher | Squarewave/Snowflake Tasks, nightly refresh | 25% |
| Phase 3 — Embedded Chat + Backend | Backend proxy, auth, chat widget | 0% |
| Phase 4 — Real-Time Notifications | Slack alerts for GPV drops, milestones | 0% |
| Phase 5 — External Enrichment | Google Places, social media, ABN registry | 0% |
| Phase 6 — Full Agentic Integration | Voice-to-action, auto-drafts, proactive suggestions | 0% |

---

## Stakeholders & Collaborators

- **Emil Kiroff** — Discussed G2 integration, custom AM UIs, tension between control vs freedom
- **Michael Olaniyan** — In the group chat, involved in platform direction
- **AM Team (9 AMs):** Antony, Simran, Pascale + others — need to test prototype
- **Orbit Retention team** — Building "Retention Dashboard PoC" that aligns with this work
- **GTM Eng** — Post-Sale lifecycle scored 8/15 in prioritisation; this prototype could change that

---

## Session Log

| Date | What We Did | Key Outcome |
|------|-------------|-------------|
| 2026-03-10 | Fixed 9MB error, built G2 refresher tile, created v2 modal, pushed to GitHub, built square-hardware-selector | Refresher tile live, modal in progress, hardware selector deployed |
| 2026-03-11 | Workflow analysis, created GOOSE_BRIEF.md, iterated Mission Control app (v1 → v2 → v3 with WIP tab, task details, all features) | Better session management, Mission Control dashboard complete |
| 2026-03-12 | Wrote G2 Space Project Brief (15 sections), researched G2/Spaces via Glean, cleaned up project folder (removed 12 redundant docs), separated Mission Control data into JSON, set up session workflow commands (Wrap up / Park / Note) | G2 Space brief complete, folder clean, Mission Control data architecture streamlined, session workflow established |

---

## Mission Control Data Architecture

The Mission Control app (`mission-control-dashboard`) loads default data from an embedded `<script id="mc-data">` JSON block. User changes are saved to localStorage and override defaults.

**To update Mission Control project data:**
1. Edit `/Users/mbrown/Projects/am-portfolio-dashboard/mission-control-data.json` (the source of truth)
2. Then run `apps__iterate_app` to update the embedded JSON in the app

**To reset Mission Control to latest defaults:** Click the "Reset" button in the app's status bar. This clears localStorage and reloads from the embedded JSON.

**What lives where:**
- `mission-control-data.json` — source of truth for WIP projects, board, timeline, links, decisions, roadmap
- The app's `<script id="mc-data">` — copy of the JSON embedded in the app HTML
- localStorage — user's live edits (overrides defaults)

---

## Quick Commands

| Command | What Goose Does |
|---------|----------------|
| **"Wrap up"** | 1. Updates the Active Threads table in GOOSE_BRIEF. 2. Adds a row to the Session Log. 3. Updates the Current Status section (Done/In Progress/Blocked/Backlog). 4. Edits `mission-control-data.json` with any changes (timeline entry, WIP statuses, board moves, new decisions). 5. Gives you a quick recap of all threads touched. **Note:** The JSON edit is tiny and won't timeout. To push changes to the app, Goose runs one `apps__iterate_app` call to sync the embedded JSON. |
| **"Just noting [idea] for later"** | Adds to Backlog without switching context. Also adds to Mission Control Ideas column. |
| **"Park this"** | Notes where we are in Active Threads, moves to next topic. |

*To run the wrap-up, just say: "Wrap up"*
