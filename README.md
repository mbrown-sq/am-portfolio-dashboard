# AU SMB Portfolio Health Dashboard

Interactive dashboard for the AU SMB Account Management team at Square.

## Features
- **Real-time portfolio overview** — 1,728 accounts across 9 AMs
- **Risk detection** — Automated health scoring and at-risk flagging
- **Activity tracking** — Weekly activity metrics per AM
- **GPV trends** — 6-month portfolio GPV trend visualization
- **QTD metrics** — Quarter-to-date goal tracking

## Data Sources
- `SBS_BOB_AGGREGATE_LIFETIME_SUMMARY` — Merchant health metrics
- `AM_FACT_ACTIVITIES` — AM activity tracking
- `POKEMON_SNAP` — Goal attainment/pacing
- `SURVEY_RESULTS` — CSAT scores
- `DIM_AM_OWNERSHIP` — AM-to-account mapping

## Built With
- Pure HTML/CSS/JavaScript
- Snowflake data (embedded snapshot)
- Goose AI + GTM Automation

---
*Part of Block's 2026 GTM Automation Strategy — Smart Hub*
