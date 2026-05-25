// Standardized API response format for all endpoints

export interface Pagination {
  page: number
  limit: number
  total: number
  totalPages: number
  hasNext: boolean
  hasPrev: boolean
}

export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  message?: string
  pagination?: Pagination
}

// ─── Success ──────────────────────────────────────────────────────────────────

export function okResponse<T>(data: T, message?: string): ApiResponse<T> {
  return { success: true, data, ...(message && { message }) }
}

export function paginatedResponse<T>(
  data: T[],
  pagination: { page: number; limit: number; total: number },
): ApiResponse<T[]> {
  const totalPages = Math.ceil(pagination.total / pagination.limit)
  return {
    success: true,
    data,
    pagination: {
      ...pagination,
      totalPages,
      hasNext: pagination.page < totalPages,
      hasPrev: pagination.page > 1,
    },
  }
}

// ─── Errors ───────────────────────────────────────────────────────────────────

export function badRequest(message = 'Bad request') {
  return createError({ statusCode: 400, message })
}

export function unauthorized(message = 'Unauthorized') {
  return createError({ statusCode: 401, message })
}

export function forbidden(message = 'Forbidden') {
  return createError({ statusCode: 403, message })
}

export function notFound(message = 'Not found') {
  return createError({ statusCode: 404, message })
}

export function conflict(message = 'Already exists') {
  return createError({ statusCode: 409, message })
}

export function serverError(message = 'Internal server error') {
  return createError({ statusCode: 500, message })
}

// ─── Guard ────────────────────────────────────────────────────────────────────

/** Re-throws H3 errors as-is, wraps unknown errors as 500 */
export function handleError(error: unknown): never {
  if (typeof error === 'object' && error !== null && 'statusCode' in error) {
    throw error
  }
  console.error('[API Error]', error)
  throw serverError()
}
