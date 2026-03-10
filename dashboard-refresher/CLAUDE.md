# dashboard-refresher - Agent Instructions

This file provides instructions for AI coding agents working on this React project.

## Project Context

- **App Name**: dashboard-refresher
- **App ID**: dashboard-refresher
- **Brand**: square
- **Type**: ui
- **Framework**: React + Vite + TypeScript
- **Runtime**: cloudflare-worker
- **Database**: false
- **Deploy Command**: `goose-sites deploy dashboard-refresher ./build`

## Critical Rules

### DO NOT MODIFY These Files
These files are auto-generated and should never be changed:
- `src/lib/kgoose.ts` - Client-side MCP tool invocation
- `src/hooks/useKgoose.ts` - React hook for kgoose
- `src/styles/theme.css` - Brand CSS variables
- `server/lib/logger.ts` - Logging utilities
- `server/lib/errors.ts` - Error handling utilities
- `server/lib/db.ts` - Database utilities (if present)

### Required Directory Structure
```
dashboard-refresher/
├── agent.md              # This file (read-only reference)
├── app.yaml              # App manifest - UPDATE when adding capabilities
├── vite.config.ts        # Vite configuration
├── tsconfig.json         # TypeScript configuration
├── index.html            # Vite entry point
├── src/
│   ├── main.tsx          # React entry point
│   ├── App.tsx           # Main component - START HERE
│   ├── components/       # Add components here
│   ├── hooks/            # useKgoose lives here (DO NOT MODIFY)
│   ├── lib/              # kgoose.ts lives here (DO NOT MODIFY)
│   └── styles/           # theme.css lives here (DO NOT MODIFY)
├── server/               # Backend code
│   ├── index.ts          # Hono API server
│   ├── routes/           # API route handlers
│   └── lib/              # DO NOT MODIFY
├── tests/                # Test files
└── migrations/           # SQL migrations (if database enabled)
```

## React Patterns

### Using External Services with useKgoose

All external API calls go through the `useKgoose` hook. Users never need to provide API credentials.

```tsx
import { useKgoose } from './hooks/useKgoose'

function MyComponent() {
  const { invoke, isLoading, error, data } = useKgoose()

  const handleClick = async () => {
    try {
      const result = await invoke('datadog/list-monitors', { appId: 'my-app' })
      console.log('Result:', result)
    } catch (err) {
      // Error is also available in the `error` state
      console.error('Failed:', err)
    }
  }

  return (
    <div>
      <button onClick={handleClick} disabled={isLoading}>
        {isLoading ? 'Loading...' : 'Fetch Data'}
      </button>
      {error && <p className="error">{error.message}</p>}
      {data && <pre>{JSON.stringify(data, null, 2)}</pre>}
    </div>
  )
}
```

### Convenience Hooks for Common Services

Pre-built hooks are available for common services:

```tsx
import { useSlack, useLinear, useAirtable, useProvider } from './hooks/useKgoose'

// Slack
function SlackNotifier() {
  const { sendMessage, postToThread, isLoading } = useSlack()

  return (
    <button onClick={() => sendMessage('#general', 'Hello!')} disabled={isLoading}>
      {isLoading ? 'Sending...' : 'Notify Slack'}
    </button>
  )
}

// Linear
function IssueCreator() {
  const { createIssue, isLoading } = useLinear()

  const handleCreate = () => createIssue({
    title: 'New feature request',
    teamId: 'TEAM-123',
    description: 'Details here...'
  })

  return <button onClick={handleCreate} disabled={isLoading}>Create Issue</button>
}

// Airtable
function RecordFetcher() {
  const { query, createRecord, isLoading, data } = useAirtable()

  const handleQuery = () => query('baseId', 'tableId', 'filterQuery')

  return <button onClick={handleQuery}>Fetch Records</button>
}

// Generic provider (for any service)
function DatadogMonitor() {
  const datadog = useProvider('datadog')

  const handleFetch = () => datadog.call('list-monitors', { appId: 'my-app' })

  return <button onClick={handleFetch}>List Monitors</button>
}
```

### Using LLM Completions

Apps can call an LLM through the G2 parent window using postMessage. This is similar to the fetch proxy
pattern -- the app sends a request, G2 handles auth and routing to kgoose, and sends back the response.

Create a `useLlm` hook in `src/hooks/useLlm.ts`:

```tsx
import { useState, useCallback } from 'react'

interface LlmOptions {
  systemPrompt?: string
  jsonSchema?: object
  extensions?: string[]
}

interface UseLlmResult {
  complete: (prompt: string, options?: LlmOptions) => Promise<string>
  isLoading: boolean
  error: Error | null
}

const pendingRequests = new Map<string, {
  resolve: (content: string) => void
  reject: (error: Error) => void
}>()

// Listen for LLM responses from G2
if (typeof window !== 'undefined') {
  window.addEventListener('message', (event) => {
    if (event.data?.type === 'cloudflare-llm-response') {
      const { requestId, success, content, error } = event.data
      const pending = pendingRequests.get(requestId)
      if (pending) {
        pendingRequests.delete(requestId)
        if (success) {
          pending.resolve(content)
        } else {
          pending.reject(new Error(error || 'LLM request failed'))
        }
      }
    }
  })
}

export function useLlm(): UseLlmResult {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const complete = useCallback(async (prompt: string, options?: LlmOptions): Promise<string> => {
    setIsLoading(true)
    setError(null)

    const requestId = crypto.randomUUID()

    try {
      const result = await new Promise<string>((resolve, reject) => {
        pendingRequests.set(requestId, { resolve, reject })

        window.parent.postMessage({
          type: 'cloudflare-llm-request',
          requestId,
          messages: [{ role: 'user', content: prompt }],
          systemPrompt: options?.systemPrompt,
          jsonSchema: options?.jsonSchema,
          extensions: options?.extensions,
        }, '*')

        // Timeout after 5 minutes
        setTimeout(() => {
          if (pendingRequests.has(requestId)) {
            pendingRequests.delete(requestId)
            reject(new Error('LLM request timed out'))
          }
        }, 300000)
      })

      return result
    } catch (err) {
      const e = err instanceof Error ? err : new Error(String(err))
      setError(e)
      throw e
    } finally {
      setIsLoading(false)
    }
  }, [])

  return { complete, isLoading, error }
}
```

Usage in a component:

```tsx
import { useLlm } from '../hooks/useLlm'

function SummaryGenerator() {
  const { complete, isLoading, error } = useLlm()
  const [summary, setSummary] = useState('')

  const handleSummarize = async (text: string) => {
    const result = await complete(text, {
      systemPrompt: 'Summarize the following text in 2-3 sentences.',
    })
    setSummary(result)
  }

  return (
    <div>
      <button onClick={() => handleSummarize('...')} disabled={isLoading}>
        {isLoading ? 'Generating...' : 'Summarize'}
      </button>
      {error && <p className="error">{error.message}</p>}
      {summary && <p>{summary}</p>}
    </div>
  )
}
```

For structured JSON responses, pass a `jsonSchema`:

```tsx
const result = await complete('List 3 colors', {
  systemPrompt: 'Return a list of colors.',
  jsonSchema: {
    type: 'object',
    properties: { colors: { type: 'array', items: { type: 'string' } } },
  },
})
const parsed = JSON.parse(result)
```

To enable kgoose extensions (backend tools like builderbot):

```tsx
const result = await complete('Build me a landing page', {
  extensions: ['builderbot'],
})
```

### Action Type Convention

All actions follow the pattern: `{provider}/{action}`

Examples:
- `datadog/list-monitors`
- `datadog/create-monitor`
- `slack/send_message`
- `linear/create_issue`
- `airtable/query_base`

### Component Structure

Organize components in `src/components/`:

```
src/components/
├── features/             # Feature-specific components
│   ├── MonitorList.tsx
│   ├── MonitorForm.tsx
│   └── QueryBuilder.tsx
├── shared/               # Reusable UI components
│   ├── Button.tsx
│   ├── Card.tsx
│   ├── Input.tsx
│   └── Modal.tsx
└── layout/               # Layout components
    ├── Header.tsx
    ├── Sidebar.tsx
    └── PageContainer.tsx
```

### State Management

For simple apps, use React's built-in state:

```tsx
// Local state
const [items, setItems] = useState<Item[]>([])

// Complex state with reducer
const [state, dispatch] = useReducer(reducer, initialState)

// Shared state with Context
const AppContext = createContext<AppState | null>(null)

function AppProvider({ children }) {
  const [state, setState] = useState(initialState)
  return (
    <AppContext.Provider value={{ state, setState }}>
      {children}
    </AppContext.Provider>
  )
}
```

**Guidelines:**
- Pass props down, lift state up
- Use URL state for shareable views (query params)
- Only add Context for truly global state

## Infrastructure Constraints

### DO Use
- **External APIs**: `useKgoose` hook - ALL external service calls
- **Database**: Cloudflare D1 (SQLite-compatible) via server-side `db`
- **API Routes**: Hono framework in `server/index.ts`
- **Styling**: CSS variables from `theme.css`
- **Logging**: `logger` from `server/lib/logger`
- **Errors**: Error classes from `server/lib/errors`

### DO NOT Use
- Direct API calls to external services (Slack, Linear, Airtable, etc.)
- API keys, tokens, or credentials in code
- DynamoDB, PostgreSQL, MongoDB - use D1 instead
- Express, Fastify, Koa - use Hono instead
- External CSS frameworks - use theme variables
- `console.log` in production - use `logger` instead

### CRITICAL: External API Access

**NEVER** ask users for API keys or handle authentication directly. All external service
calls MUST go through `kgoose` (via `useKgoose` hook), which handles authentication automatically.

```tsx
// WRONG - Never do this:
const response = await fetch('https://api.slack.com/...', {
  headers: { 'Authorization': 'Bearer xoxb-...' }  // NO!
})

// RIGHT - Always use useKgoose:
const { invoke } = useKgoose()
const result = await invoke('slack/send_message', {
  channel: '#general',
  text: 'Hello!'
})
```

### If User Asks for Incompatible Tech
Explain the alternative politely:
- "D1 is our database here - it's SQLite-compatible and works similarly to [requested tech]"
- "We use Hono for API routes - it has a similar API to Express"
- "External APIs go through kgoose which handles all authentication"

## Code Patterns

### Creating a Component

```tsx
// src/components/features/ItemList.tsx
import { useKgoose } from '../../hooks/useKgoose'
import { useState, useEffect } from 'react'

interface Item {
  id: string
  name: string
}

interface ItemListProps {
  onItemSelect?: (item: Item) => void
}

export function ItemList({ onItemSelect }: ItemListProps) {
  const { invoke, isLoading, error } = useKgoose<Item[]>()
  const [items, setItems] = useState<Item[]>([])

  const fetchItems = async () => {
    const result = await invoke('service/list-items', {})
    setItems(result || [])
  }

  useEffect(() => {
    fetchItems()
  }, [])

  if (isLoading) return <div>Loading...</div>
  if (error) return <div className="error">{error.message}</div>

  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => onItemSelect?.(item)}>
          {item.name}
        </li>
      ))}
    </ul>
  )
}
```

### Creating an API Route

Add routes to `server/index.ts` before the static file handler:

```typescript
import { Hono } from 'hono'
import { logger } from './lib/logger'
import { NotFoundError, ValidationError } from './lib/errors'

const app = new Hono()

// Add your route
app.get('/api/items', async (c) => {
  logger.info('Fetching items')
  return c.json({ items: [] })
})

app.post('/api/items', async (c) => {
  const body = await c.req.json()

  if (!body.name) {
    throw new ValidationError('Name is required')
  }

  logger.info('Creating item', { name: body.name })
  return c.json({ id: 1, name: body.name }, 201)
})

// Static files must be last
app.get('/*', serveStatic({ root: './' }))
```

### Using the Database (if enabled)

```typescript
// In server-side code only
import { db } from './lib/db'

const users = await db.query<User>('SELECT * FROM users WHERE active = ?', [true])
const user = await db.first<User>('SELECT * FROM users WHERE id = ?', [userId])
const result = await db.execute('INSERT INTO users (name) VALUES (?)', [name])
```

### Using CSS Theme Variables

```css
/* Use variables from theme.css */
.button {
  background: var(--color-primary);
  color: var(--color-background);
  border-radius: var(--radius-md);
  font-family: var(--font-family);
  padding: var(--spacing-sm) var(--spacing-md);
}

.card {
  background: var(--color-surface);
  color: var(--color-text);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  box-shadow: var(--shadow-sm);
}
```

Or in JSX with inline styles:

```tsx
<button style={{
  background: 'var(--color-primary)',
  color: 'var(--color-background)',
  borderRadius: 'var(--radius-md)'
}}>
  Click me
</button>
```

## app.yaml Maintenance (CRITICAL)

When adding new capabilities, you MUST update `app.yaml`:

### Adding an External Service

```yaml
# In app.yaml, add to permissions:
permissions:
  connections: ["existing_service", "new_service"]
  scopes: ["existing.read", "new_service.read", "new_service.write"]
```

### Adding MCP Tool Usage

```yaml
# In app.yaml, add to mcp_tools:
mcp_tools:
  - name: tool_name
    provider: service_name
    required: true
    description: Why this feature needs it
```

**Always tell the user**: "I've added [service] to app.yaml. You may need to approve this permission before the feature will work."

## Testing

### Writing Tests

```typescript
// tests/example.test.ts
import { describe, it, expect } from 'vitest'

describe('Feature', () => {
  it('should work correctly', () => {
    expect(true).toBe(true)
  })
})
```

### Testing Components

```typescript
// tests/components/ItemList.test.tsx
import { render, screen } from '@testing-library/react'
import { ItemList } from '../src/components/features/ItemList'

describe('ItemList', () => {
  it('renders loading state', () => {
    render(<ItemList />)
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })
})
```

### Running Tests

```bash
npm test
```

## Development

### Start dev server
```bash
npm run dev
```

### Build for production
```bash
npm run build
```

### Type checking
```bash
npm run typecheck
```

## Deploy Checklist

Before asking the user to deploy, ensure:

1. [ ] All tests pass (`npm test`)
2. [ ] Build succeeds (`npm run build`)
3. [ ] No TypeScript errors (`npm run typecheck`)
4. [ ] app.yaml is updated with any new permissions/tools
5. [ ] No hardcoded secrets or API keys
6. [ ] Loading and error states are handled in UI

Then the user can deploy with:
```bash
goose-sites deploy dashboard-refresher ./build
```

## Brand Guidelines

Brand: **square**

Available CSS variables (see `src/styles/theme.css`):
- `--color-primary` - Primary brand color
- `--color-secondary` - Secondary color
- `--color-background` - Page background
- `--color-surface` - Card/container background
- `--color-text` - Main text color
- `--color-text-muted` - Secondary text color
- `--color-error` - Error states
- `--color-success` - Success states
- `--font-family` - Brand font stack
- `--radius-sm`, `--radius-md`, `--radius-lg` - Border radii
- `--spacing-xs`, `--spacing-sm`, `--spacing-md`, `--spacing-lg`, `--spacing-xl` - Spacing
- `--shadow-sm`, `--shadow-md` - Box shadows
- `--transition-fast`, `--transition-normal` - Transitions

## Design Guidelines

- **No emojis** - Do not use emojis in the UI, code comments, or user-facing text
- Keep the interface clean and professional
- Use the brand color palette consistently
- Prefer clear, concise labels over icons where possible
