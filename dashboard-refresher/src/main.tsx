import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import { initG2FetchProxy } from './lib/g2-fetch-proxy'
import './styles/theme.css'

// Initialize fetch proxy for G2 hosting (transparent - does nothing if not in G2)
initG2FetchProxy()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
