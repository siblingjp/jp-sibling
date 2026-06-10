export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { date } = getQuery(event) as { date?: string }

    // กำหนด date range (UTC+7, รอบ 00:00–23:59 ตามวันที่เลือก)
    let start: Date
    let end: Date

    if (date) {
      // date = "YYYY-MM-DD" (local BKK) → แปลงเป็น UTC
      const [y, m, d] = date.split('-').map(Number)
      // 00:00:00 BKK = UTC-7h
      start = new Date(Date.UTC(y, m - 1, d, -7, 0, 0, 0))
      end   = new Date(Date.UTC(y, m - 1, d, 16, 59, 59, 999))
    } else {
      // วันปัจจุบัน BKK (00:00–23:59)
      const nowBKK = new Date(Date.now() + 7 * 3600000)
      const y = nowBKK.getUTCFullYear()
      const m = nowBKK.getUTCMonth()
      const d = nowBKK.getUTCDate()
      start = new Date(Date.UTC(y, m, d, -7, 0, 0, 0))
      end   = new Date(Date.UTC(y, m, d, 16, 59, 59, 999))
    }

    const where = {
      status: 'COMPLETED' as const,
      createdAt: { gte: start, lte: end },
    }

    const orders = await prisma.order.findMany({
      where,
      include: {
        items: { include: { product: { select: { id: true, name: true } } } },
        payment: { select: { method: true, amount: true } },
      },
    })

    // ─── Summary ────────────────────────────────────────────────────────────────
    const totalOrders = orders.length
    const totalCups = orders.reduce((s, o) => s + o.items.reduce((si, i) => si + i.quantity, 0), 0)
    const totalRevenue = orders.reduce((s, o) => s + Number(o.total), 0)

    // ─── Top products ────────────────────────────────────────────────────────────
    const productMap = new Map<string, { name: string; qty: number; revenue: number }>()
    for (const order of orders) {
      for (const item of order.items) {
        const key = item.product.id
        const existing = productMap.get(key)
        if (existing) {
          existing.qty += item.quantity
          existing.revenue += Number(item.subtotal)
        } else {
          productMap.set(key, { name: item.product.name, qty: item.quantity, revenue: Number(item.subtotal) })
        }
      }
    }
    const topProducts = [...productMap.entries()]
      .map(([id, v]) => ({ id, ...v }))
      .sort((a, b) => b.qty - a.qty)
      .slice(0, 10)

    // ─── Revenue by payment method ───────────────────────────────────────────────
    const paymentMethodMap: Record<string, number> = {}
    for (const order of orders) {
      if (order.payment) {
        const m = order.payment.method
        paymentMethodMap[m] = (paymentMethodMap[m] ?? 0) + Number(order.total)
      }
    }
    const byPaymentMethod = Object.entries(paymentMethodMap).map(([method, amount]) => ({ method, amount }))

    return okResponse({
      date: date ?? new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10),
      totalOrders,
      totalCups,
      totalRevenue,
      topProducts,
      byPaymentMethod,
    })
  } catch (e) {
    handleError(e)
  }
})
