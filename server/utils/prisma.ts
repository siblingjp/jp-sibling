import { PrismaClient } from '@prisma/client'

const prismaClient = new PrismaClient()

async function withRetry<T>(fn: () => Promise<T>, retries = 5, delayMs = 3000): Promise<T> {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn()
    } catch (e: any) {
      const isConnectionError = e?.message?.includes("Can't reach database") || e?.code === 'P1001' || e?.code === 'P1002'
      if (isConnectionError && i < retries - 1) {
        await new Promise(r => setTimeout(r, delayMs))
        continue
      }
      throw e
    }
  }
  throw new Error('DB retry exhausted')
}

export const prisma = new Proxy(prismaClient, {
  get(target, prop) {
    const value = (target as any)[prop]
    if (typeof value === 'object' && value !== null) {
      return new Proxy(value, {
        get(modelTarget, method) {
          const fn = modelTarget[method]
          if (typeof fn === 'function') {
            return (...args: any[]) => withRetry(() => fn.apply(modelTarget, args))
          }
          return fn
        },
      })
    }
    return value
  },
})
