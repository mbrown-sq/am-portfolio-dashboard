import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono();

// Enable CORS for all routes
app.use('/*', cors());

// Health check
app.get('/', (c) => {
  return c.json({ 
    status: 'ok', 
    service: 'AU SMB Portfolio Dashboard API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Get all accounts with optional filters
app.get('/api/accounts', async (c) => {
  const { am, risk, tier, search } = c.req.query();
  
  try {
    let query = 'SELECT * FROM accounts WHERE 1=1';
    const params = [];
    
    if (am) {
      query += ' AND am = ?';
      params.push(am);
    }
    
    if (risk) {
      query += ' AND r = ?';
      params.push(risk);
    }
    
    if (tier) {
      query += ' AND t = ?';
      params.push(tier);
    }
    
    if (search) {
      query += ' AND (n LIKE ? OR bid LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }
    
    query += ' ORDER BY h ASC, g DESC';
    
    const { results } = await c.env.DB.prepare(query).bind(...params).all();
    
    return c.json({
      success: true,
      count: results.length,
      accounts: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get alerts (top at-risk accounts)
app.get('/api/alerts', async (c) => {
  const limit = parseInt(c.req.query('limit') || '30');
  
  try {
    const { results } = await c.env.DB.prepare(
      'SELECT * FROM alerts ORDER BY h ASC LIMIT ?'
    ).bind(limit).all();
    
    return c.json({
      success: true,
      count: results.length,
      alerts: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get QTD metrics
app.get('/api/qtd', async (c) => {
  const { am } = c.req.query();
  
  try {
    let query = 'SELECT * FROM qtd_metrics';
    const params = [];
    
    if (am) {
      query += ' WHERE am = ?';
      params.push(am);
    }
    
    const { results } = await c.env.DB.prepare(query).bind(...params).all();
    
    return c.json({
      success: true,
      count: results.length,
      qtd: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get weekly activity
app.get('/api/weekly', async (c) => {
  const { am, weeks } = c.req.query();
  const weeksLimit = parseInt(weeks || '5');
  
  try {
    let query = 'SELECT * FROM weekly_activity WHERE 1=1';
    const params = [];
    
    if (am) {
      query += ' AND am = ?';
      params.push(am);
    }
    
    query += ' ORDER BY week DESC LIMIT ?';
    params.push(weeksLimit * 10); // Rough estimate for multiple AMs
    
    const { results } = await c.env.DB.prepare(query).bind(...params).all();
    
    return c.json({
      success: true,
      count: results.length,
      weekly: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get GPV trend
app.get('/api/gpv-trend', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(
      'SELECT * FROM gpv_trend ORDER BY id ASC'
    ).all();
    
    return c.json({
      success: true,
      count: results.length,
      trend: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get AM summary
app.get('/api/summary', async (c) => {
  const { am } = c.req.query();
  
  try {
    // Get AM summary
    let amQuery = 'SELECT * FROM am_summary';
    const amParams = [];
    
    if (am) {
      amQuery += ' WHERE am = ?';
      amParams.push(am);
    }
    
    const { results: amSummary } = await c.env.DB.prepare(amQuery).bind(...amParams).all();
    
    // Get team total
    const { results: teamTotal } = await c.env.DB.prepare(
      'SELECT * FROM team_total WHERE id = 1'
    ).all();
    
    return c.json({
      success: true,
      amSummary: amSummary.reduce((acc, row) => {
        acc[row.am] = row;
        return acc;
      }, {}),
      teamTotal: teamTotal[0] || null
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get feature news
app.get('/api/news', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(
      'SELECT * FROM feature_news ORDER BY date DESC'
    ).all();
    
    return c.json({
      success: true,
      count: results.length,
      news: results
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Get complete dashboard data (for backward compatibility)
app.get('/api/data', async (c) => {
  try {
    const [accounts, alerts, qtd, weekly, gpvTrend, amSummary, teamTotal, news] = await Promise.all([
      c.env.DB.prepare('SELECT * FROM accounts ORDER BY h ASC, g DESC').all(),
      c.env.DB.prepare('SELECT * FROM alerts ORDER BY h ASC LIMIT 30').all(),
      c.env.DB.prepare('SELECT * FROM qtd_metrics').all(),
      c.env.DB.prepare('SELECT * FROM weekly_activity ORDER BY week DESC').all(),
      c.env.DB.prepare('SELECT * FROM gpv_trend ORDER BY id ASC').all(),
      c.env.DB.prepare('SELECT * FROM am_summary').all(),
      c.env.DB.prepare('SELECT * FROM team_total WHERE id = 1').all(),
      c.env.DB.prepare('SELECT * FROM feature_news ORDER BY date DESC').all()
    ]);
    
    return c.json({
      success: true,
      data: {
        accounts: accounts.results,
        alerts: alerts.results,
        qtd: qtd.results.reduce((acc, row) => {
          acc[row.am] = row;
          return acc;
        }, {}),
        weekly: weekly.results,
        gpvTrend: gpvTrend.results,
        amSummary: amSummary.results.reduce((acc, row) => {
          acc[row.am] = row;
          return acc;
        }, {}),
        teamTotal: teamTotal.results[0] || null,
        featureNews: news.results
      }
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

// Initialize database tables (run once)
app.post('/api/init-db', async (c) => {
  try {
    // Read the schema from the migration file
    const schema = `
      CREATE TABLE IF NOT EXISTS accounts (
        bid TEXT PRIMARY KEY,
        n TEXT, am TEXT, c TEXT, t TEXT,
        g REAL, g9 REAL, y REAL, ar REAL, sar REAL, at REAL,
        l INTEGER, e INTEGER, tn INTEGER, lp TEXT, ct INTEGER,
        h INTEGER, r TEXT, d INTEGER, a30 INTEGER, cs INTEGER,
        sf TEXT, ci TEXT, products TEXT, city TEXT, state TEXT,
        pc TEXT, svc TEXT, cls TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        n TEXT, am TEXT, d INTEGER, reason TEXT, h INTEGER, g REAL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS qtd_metrics (
        am TEXT PRIMARY KEY,
        acts INTEGER, calls INTEGER, emails INTEGER, sms INTEGER,
        dms INTEGER, dm_convos INTEGER, biz_touched INTEGER, hrs REAL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS weekly_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        am TEXT, name TEXT, week TEXT, total INTEGER,
        calls INTEGER, emails INTEGER, sms INTEGER, dms INTEGER, hrs REAL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS gpv_trend (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        m TEXT, v REAL, merchants INTEGER,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS am_summary (
        am TEXT PRIMARY KEY,
        accts INTEGER, gpv REAL, ar REAL,
        at_risk INTEGER, watch INTEGER, healthy INTEGER,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS team_total (
        id INTEGER PRIMARY KEY DEFAULT 1,
        accts INTEGER, gpv REAL,
        at_risk INTEGER, watch INTEGER, healthy INTEGER,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE TABLE IF NOT EXISTS feature_news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, desc TEXT, date TEXT, icon TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      
      CREATE INDEX IF NOT EXISTS idx_accounts_am ON accounts(am);
      CREATE INDEX IF NOT EXISTS idx_accounts_risk ON accounts(r);
      CREATE INDEX IF NOT EXISTS idx_accounts_health ON accounts(h);
      CREATE INDEX IF NOT EXISTS idx_weekly_am ON weekly_activity(am, week);
    `;
    
    // Execute each statement
    const statements = schema.split(';').filter(s => s.trim());
    for (const stmt of statements) {
      if (stmt.trim()) {
        await c.env.DB.prepare(stmt).run();
      }
    }
    
    return c.json({
      success: true,
      message: 'Database tables created successfully'
    });
  } catch (error) {
    return c.json({
      success: false,
      error: error.message
    }, 500);
  }
});

export default {
  async fetch(request, env, ctx) {
    return app.fetch(request, { ...env, DB: env.DB }, ctx);
  }
};
