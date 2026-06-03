import { z } from 'zod'

const schema = z.object({
  orderId: z.string(),
  method: z.enum(['CASH', 'CARD', 'QR', 'THAI_HELP']),
  amount: z.number().positive(),
  transactionRef: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const order = await prisma.order.findUnique({
      where: { id: data.orderId },
      include: { payment: true },
    })
    if (!order) throw notFound('Order')
    if (order.status === 'CANCELLED') throw badRequest('Order is cancelled')
    if (order.payment) throw badRequest('Order already paid')

    const total = Number(order.total)
    const change = data.method === 'CASH' ? Math.max(0, data.amount - total) : 0

    if (data.method === 'CASH' && data.amount < total) {
      throw badRequest('Insufficient payment amount')
    }

    const payment = await prisma.$transaction(async (tx) => {
      const created = await tx.payment.create({
        data: {
          orderId: data.orderId,
          method: data.method,
          amount: data.amount,
          change,
          transactionRef: data.transactionRef ?? null,
        },
      })

      // เปลี่ยน status เป็น PREPARING หลังจ่ายเงิน
      await tx.order.update({
        where: { id: data.orderId },
        data: { status: 'PREPARING' },
      })

      return created
    })

    return okResponse(payment)
  } catch (e) {
    handleError(e)
  }
})
