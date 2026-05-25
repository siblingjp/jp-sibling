import type { Pagination } from '~/server/utils/response'

// ─── Request ──────────────────────────────────────────────────────────────────

export interface ListQuery {
  pagination?: { page?: number; limit?: number }
  filter?: Record<string, unknown>
  search?: string
}

export interface BaseRequest<T = unknown> {
  body?: T
  query?: ListQuery
}

// ─── Response ─────────────────────────────────────────────────────────────────

export interface BaseResponse<T = unknown> {
  success?: boolean
  data?: T
  message?: string
  pagination?: Pagination
  statusCode?: number
  statusMessage?: string
}

// ─── Store State ──────────────────────────────────────────────────────────────

export interface BaseState<T = unknown> {
  isLoading: boolean
  isError: boolean
  isSuccess: boolean
  response: BaseResponse<T>
}

export const initState = <T = unknown>(): BaseState<T> => ({
  isLoading: false,
  isError: false,
  isSuccess: false,
  response: {},
})

export const loadingState = <T = unknown>(): BaseState<T> => ({
  isLoading: true,
  isError: false,
  isSuccess: false,
  response: {},
})

export const successState = <T = unknown>(response: BaseResponse<T>): BaseState<T> => ({
  isLoading: false,
  isError: false,
  isSuccess: true,
  response,
})

export const errorState = <T = unknown>(response: BaseResponse<T>): BaseState<T> => ({
  isLoading: false,
  isError: true,
  isSuccess: false,
  response,
})

// ─── Error class ──────────────────────────────────────────────────────────────

export class ApiError extends Error {
  public statusCode: number
  public response: BaseResponse

  constructor(error: unknown) {
    const e = error as Record<string, unknown>
    const data = (e?.data ?? e) as BaseResponse
    super(data?.message ?? String(e?.statusMessage ?? 'Unknown error'))
    this.statusCode = Number(e?.statusCode ?? 500)
    this.response = data
  }
}
