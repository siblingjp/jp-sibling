import { z } from 'zod'

const schema = z.object({
  method: z.enum(['CASH', 'CARD', 'QR', 'THAI_HELP', 'UNSPECIFIED']).default('UNSPECIFIED'),
  amount: z.number().positive(),
  transactionRef: z.string().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.payment.findUnique({
      where: { id },
      include: { order: { select: { total: true } } },
    })
    if (!existing) throw notFound('Payment')

    const total = Number(existing.order.total)
    const change = data.method === 'CASH' ? Math.max(0, data.amount - total) : 0

    if (data.method === 'CASH' && data.amount < total) {
      throw badRequest('Insufficient payment amount')
    }

    const payment = await prisma.payment.update({
      where: { id },
      data: {
        method: data.method,
        amount: data.amount,
        change,
        transactionRef: data.transactionRef ?? null,
      },
    })

    return okResponse(payment)
  } catch (e) {
    handleError(e)
  }
})
