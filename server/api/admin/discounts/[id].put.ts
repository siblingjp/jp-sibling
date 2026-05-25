import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  kind: z.enum(['PERCENT', 'AMOUNT']),
  value: z.number().positive(),
  isActive: z.boolean(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))
    if (data.kind === 'PERCENT' && data.value > 100) throw badRequest('Percent discount cannot exceed 100%')

    const existing = await prisma.discount.findUnique({ where: { id } })
    if (!existing) throw notFound('Discount')

    const discount = await prisma.discount.update({ where: { id }, data })
    return okResponse(discount)
  } catch (e) {
    handleError(e)
  }
})
