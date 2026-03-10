-- AU SMB Portfolio Dashboard - D1 Schema

CREATE TABLE IF NOT EXISTS accounts (
  bid TEXT PRIMARY KEY,
  n TEXT,                    -- business name
  am TEXT,                   -- AM ldap
  c TEXT,                    -- category
  t TEXT,                    -- tier
  g REAL,                    -- GPV annual
  g9 REAL,                   -- GPV 9mo
  y REAL,                    -- YoY %
  ar REAL,                   -- AR
  sar REAL,                  -- SaaS AR
  at REAL,                   -- avg ticket
  l INTEGER,                 -- locations
  e INTEGER,                 -- tenure (legacy)
  tn INTEGER,                -- tenure months
  lp TEXT,                   -- last processed
  ct INTEGER,                -- contracted (boolean)
  h INTEGER,                 -- health score
  r TEXT,                    -- risk status
  d INTEGER,                 -- days since DM
  a30 INTEGER,               -- activities 30d
  cs INTEGER,                -- CSAT
  sf TEXT,                   -- Salesforce ID
  ci TEXT,                   -- city info
  products TEXT,             -- comma-separated
  city TEXT,
  state TEXT,
  pc TEXT,                   -- postal code
  svc TEXT,                  -- service level
  cls TEXT,                  -- seller class
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alerts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  n TEXT,                    -- business name
  am TEXT,                   -- AM ldap
  d INTEGER,                 -- days since DM
  reason TEXT,
  h INTEGER,                 -- health score
  g REAL,                    -- GPV
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS qtd_metrics (
  am TEXT PRIMARY KEY,
  acts INTEGER,
  calls INTEGER,
  emails INTEGER,
  sms INTEGER,
  dms INTEGER,
  dm_convos INTEGER,
  biz_touched INTEGER,
  hrs REAL,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS weekly_activity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  am TEXT,
  name TEXT,
  week TEXT,
  total INTEGER,
  calls INTEGER,
  emails INTEGER,
  sms INTEGER,
  dms INTEGER,
  hrs REAL,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gpv_trend (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  m TEXT,                    -- month label
  v REAL,                    -- GPV value
  merchants INTEGER,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS am_summary (
  am TEXT PRIMARY KEY,
  accts INTEGER,
  gpv REAL,
  ar REAL,
  at_risk INTEGER,
  watch INTEGER,
  healthy INTEGER,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS team_total (
  id INTEGER PRIMARY KEY DEFAULT 1,
  accts INTEGER,
  gpv REAL,
  at_risk INTEGER,
  watch INTEGER,
  healthy INTEGER,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS feature_news (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  desc TEXT,
  date TEXT,
  icon TEXT,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for common queries
CREATE INDEX idx_accounts_am ON accounts(am);
CREATE INDEX idx_accounts_risk ON accounts(r);
CREATE INDEX idx_accounts_health ON accounts(h);
CREATE INDEX idx_weekly_am ON weekly_activity(am, week);
