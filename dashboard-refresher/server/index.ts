/**
 * Server Entry Point - dashboard-refresher
 *
 * This file sets up the Hono server with middleware and routes.
 * Add your API routes BEFORE the static file handler.
 */

import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'
import { logger } from './lib/logger'
import { AppError } from './lib/errors'

// Type for Cloudflare Workers environment bindings
interface Env {
  // Add your bindings here, e.g.:
  // DB: D1Database
}

const app = new Hono<{ Bindings: Env }>()

// =============================================================================
// Middleware
// =============================================================================

// Request logging
app.use('*', async (c, next) => {
  const start = Date.now()
  await next()
  const duration = Date.now() - start
  logger.info('Request', {
    method: c.req.method,
    path: c.req.path,
    status: c.res.status,
    duration,
  })
})

// Error handling
app.onError((err, c) => {
  if (err instanceof AppError) {
    logger.warn('App error', { code: err.code, message: err.message })
    return c.json(err.toJSON(), err.statusCode as any)
  }

  logger.error('Unhandled error', { message: err.message, stack: err.stack })
  return c.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } }, 500)
})

// =============================================================================
// API Routes
// =============================================================================

// Health check
app.get('/api/health', (c) => {
  return c.json({ status: 'ok', app: 'dashboard-refresher' })
})

// TODO: Add your API routes here
// Example:
// app.get('/api/items', async (c) => {
//   return c.json({ items: [] })
// })

// =============================================================================
// Static Files (MUST BE LAST)
// =============================================================================

app.get('/*', serveStatic({ root: './' }))

export default app
