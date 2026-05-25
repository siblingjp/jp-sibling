import type { ZodSchema, ZodError } from 'zod'
import { badRequest } from './response'

/**
 * Validates data against a Zod schema.
 * Throws a 400 error with field-level messages on failure.
 * Returns typed parsed data on success.
 */
export function validate<T>(schema: ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data)
  if (!result.success) {
    const message = formatZodError(result.error)
    throw badRequest(message)
  }
  return result.data
}

function formatZodError(error: ZodError): string {
  return error.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join(', ')
}
