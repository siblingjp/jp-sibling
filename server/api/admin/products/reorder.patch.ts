import { z } from 'zod'

const schema = z.object({
  orders: z.array(z.object({
    id: z.string(),
    sortOrder: z.number().int().min(0),
  })).min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { orders } = validate(schema, await readBody(event))

    for (const { id, sortOrder } of orders) {
      await prisma.product.update({ where: { id }, data: { sortOrder } })
    }

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse({ updated: orders.length })
  } catch (e) {
    handleError(e)
  }
})
