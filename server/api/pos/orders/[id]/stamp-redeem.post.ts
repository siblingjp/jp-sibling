import { z } from 'zod'

const schema = z.object({
  itemIndex: z.number().int().nonnegative(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const { itemIndex } = validate(schema, await readBody(event))

    const order = await prisma.order.findUnique({
      where: { id },
      include: {
        items: { include: { product: { select: { name: true, isStampEligible: true } } } },
        payment: true,
        member: { select: { id: true, stampCount: true } },
      },
    })
    if (!order) throw notFound('Order')
    if (!['PENDING', 'PREPARING'].includes(order.status)) {
      throw badRequest('สามารถใช้สิทธิ์ได้เฉพาะออเดอร์ที่ยังไม่เสร็จสิ้นเท่านั้น')
    }
    if (order.payment) throw badRequest('ออเดอร์นี้ชำระเงินแล้ว ไม่สามารถใช้สิทธิ์แลกแสตมป์ได้')
    if (!order.member) throw badRequest('ออเดอร์นี้ไม่ได้ผูกกับสมาชิก')
    if (order.freeItemName) throw badRequest('ออเดอร์นี้ใช้สิทธิ์แลกแสตมป์ไปแล้ว')

    const loyaltyMode = await getLoyaltyMode()
    if (loyaltyMode !== 'STAMPS') throw badRequest('ระบบไม่ได้เปิดใช้งานแสตมป์')

    const item = order.items[itemIndex]
    if (!item) throw badRequest('ไม่พบสินค้าที่เลือกแลกฟรี')

    await validateFreeItemRedemption(order.member.id, order.member.stampCount, { price: item.unitPrice })

    const freeItemDiscount = Number(item.unitPrice)
    const newTotal = Math.max(0, Number(order.total) - freeItemDiscount)
    const stampsEligible = calcEligibleCupCount(
      order.items.map((i, idx) => ({
        // แก้วที่แลกฟรีด้วยแสตมป์ไม่นับสะสมแสตมป์เพิ่มอีก 1 หน่วย
        quantity: idx === itemIndex ? i.quantity - 1 : i.quantity,
        product: i.product,
      })),
    )

    const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.order.update({
        where: { id },
        data: {
          total: newTotal,
          freeItemName: item.product.name,
          freeItemDiscount,
          stampsEligible,
        },
        include: {
          items: { include: { options: true, product: { select: { id: true, name: true } } } },
          member: { select: { id: true, name: true, stampCount: true } },
          payment: true,
        },
      })

      await lockStampRedemption(tx, order.member!.id, id)

      return result
    }, { timeout: 15000, maxWait: 5000 })

    return okResponse(updated)
  } catch (e: any) {
    console.error('[pos/orders/:id/stamp-redeem] ERROR:', e?.message, e?.code, e?.meta)
    handleError(e)
  }
})
