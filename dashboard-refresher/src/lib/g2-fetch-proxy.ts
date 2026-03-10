/**
 * G2 Fetch Proxy - Transparent fetch interception for G2-hosted apps.
 *
 * This module intercepts all fetch() calls and routes them appropriately:
 * - Same-origin requests → direct fetch (to the app's Cloudflare backend)
 * - External API requests → proxied through G2 parent window
 *
 * This is initialized automatically - app developers just use fetch() normally.
 */

interface G2FetchRequest {
  type: 'cloudflare-fetch-request'
  requestId: string
  url: string
  method: string
  headers?: Record<string, string>
  body?: string
}

interface G2FetchResponse {
  type: 'cloudflare-fetch-response'
  requestId: string
  ok: boolean
  status?: number
  headers?: Record<string, string>
  body?: string
  error?: string
}

// Track pending requests
const pendingRequests = new Map<
  string,
  { resolve: (r: Response) => void; reject: (e: Error) => void }
>()

// Original fetch reference
let originalFetch: typeof fetch | null = null

// Whether proxy is initialized
let initialized = false

/**
 * Handle response messages from G2 parent.
 */
function handleMessage(event: MessageEvent): void {
  const data = event.data as G2FetchResponse
  if (data?.type !== 'cloudflare-fetch-response') return

  const pending = pendingRequests.get(data.requestId)
  if (!pending) return

  pendingRequests.delete(data.requestId)

  if (data.error) {
    pending.reject(new Error(data.error))
    return
  }

  // Reconstruct Response object
  const headers = new Headers(data.headers)
  const response = new Response(data.body, {
    status: data.status ?? 200,
    headers,
  })

  // Add ok property based on status
  Object.defineProperty(response, 'ok', {
    value: data.ok,
    writable: false,
  })

  pending.resolve(response)
}

/**
 * Proxy a fetch request through G2 parent.
 */
async function proxyFetch(url: string, init?: RequestInit): Promise<Response> {
  const requestId = crypto.randomUUID()

  // Extract headers as plain object
  const headers: Record<string, string> = {}
  if (init?.headers) {
    if (init.headers instanceof Headers) {
      init.headers.forEach((value, key) => {
        headers[key] = value
      })
    } else if (Array.isArray(init.headers)) {
      for (const [key, value] of init.headers) {
        headers[key] = value
      }
    } else {
      Object.assign(headers, init.headers)
    }
  }

  // Get body as string
  let body: string | undefined
  if (init?.body) {
    if (typeof init.body === 'string') {
      body = init.body
    } else if (init.body instanceof URLSearchParams) {
      body = init.body.toString()
    } else if (init.body instanceof FormData) {
      // FormData needs special handling - convert to JSON if possible
      const obj: Record<string, string> = {}
      init.body.forEach((value, key) => {
        if (typeof value === 'string') {
          obj[key] = value
        }
      })
      body = JSON.stringify(obj)
      headers['Content-Type'] = 'application/json'
    } else {
      body = String(init.body)
    }
  }

  return new Promise((resolve, reject) => {
    pendingRequests.set(requestId, { resolve, reject })

    const message: G2FetchRequest = {
      type: 'cloudflare-fetch-request',
      requestId,
      url,
      method: init?.method ?? 'GET',
      headers: Object.keys(headers).length > 0 ? headers : undefined,
      body,
    }

    // Send to G2 parent
    window.parent.postMessage(message, '*')

    // Timeout after 60 seconds
    setTimeout(() => {
      if (pendingRequests.has(requestId)) {
        pendingRequests.delete(requestId)
        reject(new Error('Proxy request timed out'))
      }
    }, 60000)
  })
}

/**
 * Intercepted fetch that routes requests appropriately.
 */
async function interceptedFetch(
  input: RequestInfo | URL,
  init?: RequestInit
): Promise<Response> {
  if (!originalFetch) {
    throw new Error('G2 fetch proxy not initialized')
  }

  // Get the URL string
  let url: string
  if (typeof input === 'string') {
    url = input
  } else if (input instanceof URL) {
    url = input.href
  } else {
    url = input.url
  }

  // Parse URL to check origin
  const parsedUrl = new URL(url, window.location.origin)
  const ownOrigin = window.location.origin

  // Same-origin requests go direct
  if (parsedUrl.origin === ownOrigin) {
    return originalFetch(input, init)
  }

  // External requests get proxied through G2
  return proxyFetch(parsedUrl.href, init)
}

/**
 * Initialize the G2 fetch proxy.
 *
 * This is called automatically when the app loads. After initialization,
 * all external fetch() calls will be proxied through G2.
 */
export function initG2FetchProxy(): void {
  if (initialized) {
    return
  }

  // Only initialize if we're in an iframe (hosted in G2)
  if (window.parent === window) {
    // Not in an iframe - running standalone, skip proxy
    return
  }

  // Save original fetch
  originalFetch = window.fetch.bind(window)

  // Replace global fetch
  window.fetch = interceptedFetch

  // Listen for responses from parent
  window.addEventListener('message', handleMessage)

  initialized = true
}

/**
 * Check if we're running inside G2.
 */
export function isInG2(): boolean {
  return window.parent !== window
}
