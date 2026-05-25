export interface ParsedQuery {
  page: number
  limit: number
  skip: number
  search: string
  filter: Record<string, unknown>
}

const DEFAULT_PAGE = 1
const DEFAULT_LIMIT = 20
const MAX_LIMIT = 100

/**
 * Nitro/h3 ส่ง bracket notation มาเป็น flat keys เช่น
 *   { "pagination[page]": "1", "filter[isActive]": "true" }
 * ฟังก์ชันนี้ unflatten กลับเป็น nested object
 */
function unflattenQuery(flat: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = {}
  for (const [key, value] of Object.entries(flat)) {
    const match = key.match(/^([^\[]+)\[([^\]]+)\]$/)
    if (match && match[1] && match[2]) {
      const parent = match[1]
      const child = match[2]
      if (!result[parent]) result[parent] = {}
      ;(result[parent] as Record<string, unknown>)[child] = value
    } else {
      result[key] = value
    }
  }
  return result
}

export function parseListQuery(rawQuery: Record<string, unknown>): ParsedQuery {
  const query = unflattenQuery(rawQuery)

  const pagination = (query.pagination as Record<string, unknown>) ?? {}
  const page = Math.max(1, Number(pagination.page) || DEFAULT_PAGE)
  const limit = Math.min(MAX_LIMIT, Math.max(1, Number(pagination.limit) || DEFAULT_LIMIT))

  const filter = (query.filter as Record<string, unknown>) ?? {}
  const search = String(query.search ?? '').trim()

  return { page, limit, skip: (page - 1) * limit, search, filter }
}

export function buildWhere(
  parsed: ParsedQuery,
  options: {
    searchFields?: string[]
    booleanFields?: string[]
    exactFields?: string[]
  } = {},
): Record<string, unknown> {
  const where: Record<string, unknown> = {}
  const { searchFields = [], booleanFields = [], exactFields = [] } = options

  if (parsed.search && searchFields.length > 0) {
    where.OR = searchFields.map((field) => ({
      [field]: { contains: parsed.search, mode: 'insensitive' },
    }))
  }

  for (const field of booleanFields) {
    const val = parsed.filter[field]
    if (val === 'true' || val === true) where[field] = true
    else if (val === 'false' || val === false) where[field] = false
  }

  for (const field of exactFields) {
    const val = parsed.filter[field]
    if (val !== undefined && val !== '') {
      where[field] = Array.isArray(val) ? { in: val } : val
    }
  }

  return where
}
