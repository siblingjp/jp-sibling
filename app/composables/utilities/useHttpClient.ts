import type { ListQuery } from '~/composables/store_models/base'

type Method = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

interface RequestOptions {
  method?: Method
  body?: unknown
  query?: Record<string, unknown>
}

/**
 * Converts a nested object to bracket-notation query params.
 * { pagination: { page: 1 }, filter: { isActive: true } }
 * → { 'pagination[page]': '1', 'filter[isActive]': 'true' }
 */
function flattenQuery(
  obj: Record<string, unknown>,
  prefix = '',
): Record<string, string> {
  const result: Record<string, string> = {}
  for (const [key, value] of Object.entries(obj)) {
    const fullKey = prefix ? `${prefix}[${key}]` : key
    if (value !== null && value !== undefined) {
      if (typeof value === 'object' && !Array.isArray(value)) {
        Object.assign(result, flattenQuery(value as Record<string, unknown>, fullKey))
      } else {
        result[fullKey] = String(value)
      }
    }
  }
  return result
}

export function useHttpClient() {
  async function request<T = unknown>(endpoint: string, options: RequestOptions = {}): Promise<T> {
    const { method = 'GET', body, query } = options

    // flattenQuery ใช้เฉพาะ GET query params เท่านั้น ไม่ใช้กับ body
    const flatQuery = query ? flattenQuery(query) : undefined

    return await $fetch<T>(endpoint, {
      method,
      body: body !== undefined ? JSON.parse(JSON.stringify(body)) : undefined,
      query: flatQuery,
      credentials: 'include',
    })
  }

  function get<T = unknown>(endpoint: string, query?: ListQuery) {
    return request<T>(endpoint, { method: 'GET', query: query as Record<string, unknown> })
  }

  function post<T = unknown>(endpoint: string, body?: unknown) {
    return request<T>(endpoint, { method: 'POST', body })
  }

  function put<T = unknown>(endpoint: string, body?: unknown) {
    return request<T>(endpoint, { method: 'PUT', body })
  }

  function patch<T = unknown>(endpoint: string, body?: unknown) {
    return request<T>(endpoint, { method: 'PATCH', body })
  }

  function del<T = unknown>(endpoint: string) {
    return request<T>(endpoint, { method: 'DELETE' })
  }

  return { request, get, post, put, patch, delete: del }
}
