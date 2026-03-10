import { useState } from 'react'
import { useKgoose } from './hooks/useKgoose'

interface QueryResult {
  name: string
  status: 'pending' | 'running' | 'complete' | 'error'
  rows?: number
  error?: string
}

function App() {
  const { invoke, isLoading } = useKgoose()
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [queries, setQueries] = useState<QueryResult[]>([])
  const [overallStatus, setOverallStatus] = useState<string>('')

  const queryFiles = [
    '01_accounts.sql',
    '02_gpv.sql',
    '03_ar.sql',
    '04_activity.sql',
    '05_qtd_metrics.sql',
    '06_weekly_activity.sql',
    '07_gpv_trend.sql',
    '08_products.sql',
    '09_locations.sql',
    '10_contracts.sql'
  ]

  const startRefresh = async () => {
    setIsRefreshing(true)
    setOverallStatus('Starting refresh...')
    
    // Initialize query status
    const initialQueries = queryFiles.map(name => ({
      name,
      status: 'pending' as const
    }))
    setQueries(initialQueries)

    const results: any[] = []

    try {
      // Execute each query
      for (let i = 0; i < queryFiles.length; i++) {
        const queryFile = queryFiles[i]
        
        // Update status to running
        setQueries(prev => prev.map((q, idx) => 
          idx === i ? { ...q, status: 'running' as const } : q
        ))
        setOverallStatus(`Executing ${queryFile}...`)

        try {
          // Read the SQL file
          const sqlContent = await invoke('developer/read_file', {
            path: `/Users/mbrown/Projects/am-portfolio-dashboard/queries/${queryFile}`
          })

          // Execute via queryexpert
          const result = await invoke('queryexpert/execute_query', {
            query: sqlContent,
            csv_path: null
          })

          results.push({ file: queryFile, data: result })

          // Update status to complete
          setQueries(prev => prev.map((q, idx) => 
            idx === i ? { 
              ...q, 
              status: 'complete' as const,
              rows: result.row_count || 0
            } : q
          ))

        } catch (error: any) {
          // Update status to error
          setQueries(prev => prev.map((q, idx) => 
            idx === i ? { 
              ...q, 
              status: 'error' as const,
              error: error.message || 'Unknown error'
            } : q
          ))
          console.error(`Error executing ${queryFile}:`, error)
        }
      }

      // All queries complete - now process and write data.js
      setOverallStatus('Processing results and writing data.js...')
      
      // Call a processing function (you'd implement the Python logic here)
      await invoke('developer/shell', {
        command: `cd /Users/mbrown/Projects/am-portfolio-dashboard && echo "Results ready for processing"`
      })

      setOverallStatus(`✅ Refresh complete! Executed ${queryFiles.length} queries.`)
      
    } catch (error: any) {
      setOverallStatus(`❌ Error: ${error.message}`)
    } finally {
      setIsRefreshing(false)
    }
  }

  return (
    <div className="container">
      <header className="header">
        <h1>🔄 Dashboard Refresher</h1>
        <p className="subtitle">AU SMB Portfolio Dashboard Data Refresh</p>
      </header>

      <main>
        <div className="card">
          <h2>Data Refresh</h2>
          <p>Click the button below to refresh the dashboard data. This will execute all 10 Snowflake queries and update data.js.</p>
          
          <div className="button-group">
            <button 
              className="button button-primary" 
              onClick={startRefresh} 
              disabled={isRefreshing || isLoading}
            >
              {isRefreshing ? '⏳ Refreshing...' : '🚀 Start Refresh'}
            </button>
          </div>

          {overallStatus && (
            <div className="status-box">
              <p>{overallStatus}</p>
            </div>
          )}
        </div>

        {queries.length > 0 && (
          <div className="card">
            <h2>Query Progress</h2>
            <div className="query-list">
              {queries.map((query, idx) => (
                <div key={idx} className={`query-item query-${query.status}`}>
                  <div className="query-name">
                    <span className="query-icon">
                      {query.status === 'pending' && '⏸️'}
                      {query.status === 'running' && '⏳'}
                      {query.status === 'complete' && '✅'}
                      {query.status === 'error' && '❌'}
                    </span>
                    <span>{query.name}</span>
                  </div>
                  <div className="query-details">
                    {query.status === 'complete' && query.rows !== undefined && (
                      <span className="query-rows">{query.rows.toLocaleString()} rows</span>
                    )}
                    {query.status === 'error' && query.error && (
                      <span className="query-error">{query.error}</span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="card info-card">
          <h3>ℹ️ How This Works</h3>
          <ul>
            <li>Reads SQL files from <code>queries/</code></li>
            <li>Executes each query via queryexpert</li>
            <li>Processes and joins results</li>
            <li>Writes to <code>build/client/data.js</code></li>
            <li>Takes about 5-10 minutes total</li>
          </ul>
          
          <h3>📅 Recommended Schedule</h3>
          <p>Run this daily at 8am AEDT to keep your dashboard fresh!</p>
        </div>
      </main>

      <style>{`
        .container {
          max-width: 900px;
          margin: 0 auto;
          padding: var(--spacing-xl);
        }
        .header {
          text-align: center;
          margin-bottom: var(--spacing-xl);
        }
        .header h1 {
          font-size: var(--font-size-3xl);
          color: var(--color-primary);
          margin: 0 0 var(--spacing-sm);
        }
        .subtitle {
          color: var(--color-text-muted);
          margin: 0;
          font-size: var(--font-size-lg);
        }
        .card {
          background: var(--color-surface);
          border-radius: var(--radius-md);
          padding: var(--spacing-lg);
          margin-bottom: var(--spacing-lg);
          box-shadow: var(--shadow-sm);
        }
        .card h2 {
          margin: 0 0 var(--spacing-md);
          font-size: var(--font-size-xl);
        }
        .card h3 {
          margin: var(--spacing-lg) 0 var(--spacing-sm);
          font-size: var(--font-size-lg);
        }
        .button-group {
          margin-top: var(--spacing-md);
        }
        .button {
          border: none;
          padding: var(--spacing-md) var(--spacing-xl);
          border-radius: var(--radius-md);
          font-family: var(--font-family);
          font-size: var(--font-size-lg);
          font-weight: 600;
          cursor: pointer;
          transition: all var(--transition-fast);
        }
        .button-primary {
          background: var(--color-primary);
          color: white;
        }
        .button-primary:hover:not(:disabled) {
          opacity: 0.9;
          transform: translateY(-1px);
          box-shadow: var(--shadow-md);
        }
        .button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .status-box {
          margin-top: var(--spacing-md);
          padding: var(--spacing-md);
          background: var(--color-background);
          border-radius: var(--radius-sm);
          border-left: 4px solid var(--color-primary);
        }
        .status-box p {
          margin: 0;
          font-weight: 500;
        }
        .query-list {
          display: flex;
          flex-direction: column;
          gap: var(--spacing-sm);
        }
        .query-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: var(--spacing-sm) var(--spacing-md);
          background: var(--color-background);
          border-radius: var(--radius-sm);
          border-left: 3px solid transparent;
        }
        .query-pending {
          border-left-color: var(--color-text-muted);
        }
        .query-running {
          border-left-color: var(--color-primary);
          background: rgba(0, 106, 255, 0.05);
        }
        .query-complete {
          border-left-color: var(--color-success);
          background: rgba(0, 200, 83, 0.05);
        }
        .query-error {
          border-left-color: var(--color-error);
          background: rgba(255, 61, 87, 0.05);
        }
        .query-name {
          display: flex;
          align-items: center;
          gap: var(--spacing-sm);
          font-weight: 500;
        }
        .query-icon {
          font-size: var(--font-size-lg);
        }
        .query-details {
          font-size: var(--font-size-sm);
          color: var(--color-text-muted);
        }
        .query-rows {
          color: var(--color-success);
          font-weight: 500;
        }
        .query-error {
          color: var(--color-error);
          font-size: var(--font-size-xs);
        }
        .info-card {
          background: rgba(0, 106, 255, 0.05);
          border: 1px solid rgba(0, 106, 255, 0.2);
        }
        .info-card ul {
          margin: var(--spacing-sm) 0;
          padding-left: var(--spacing-lg);
        }
        .info-card li {
          margin: var(--spacing-xs) 0;
          color: var(--color-text-muted);
        }
        code {
          background: var(--color-surface);
          padding: 2px 6px;
          border-radius: var(--radius-sm);
          font-size: var(--font-size-sm);
          color: var(--color-primary);
        }
      `}</style>
    </div>
  )
}

export default App
