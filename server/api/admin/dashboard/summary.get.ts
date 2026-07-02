export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { dateFrom, dateTo } = getQuery(event) as { dateFrom?: string; dateTo?: string }

    function bkkDateToRange(dateStr: string): { start: Date; end: Date } {
      const [y, m, d] = dateStr.split('-').map(Number)
      return {
        start: new Date(Date.UTC(y, m - 1, d, -7, 0, 0, 0)),
        end:   new Date(Date.UTC(y, m - 1, d, 16, 59, 59, 999)),
      }
    }

    let start: Date
    let end: Date

    if (dateFrom && dateTo) {
      start = bkkDateToRange(dateFrom).start
      end   = bkkDateToRange(dateTo).end
    } else if (dateFrom) {
      const r = bkkDateToRange(dateFrom)
      start = r.start
      end   = r.end
    } else {
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
        items: { include: { product: { select: { id: true, name: true, category: { select: { slug: true, name: true } } } } } },
        payment: { select: { method: true, amount: true } },
      },
    })

    // ─── Summary ────────────────────────────────────────────────────────────────
    const totalOrders = orders.length
    const totalRevenue = orders.reduce((s, o) => s + Number(o.total), 0)

    let totalCups = 0
    let totalFoods = 0
    let revenueFood = 0
    let revenueDrink = 0
    for (const order of orders) {
      for (const item of order.items) {
        const isFood = item.product.category?.slug === 'foods'
        if (isFood) {
          totalFoods += item.quantity
          revenueFood += Number(item.subtotal)
        } else {
          totalCups += item.quantity
          revenueDrink += Number(item.subtotal)
        }
      }
    }

    // ─── Top products ────────────────────────────────────────────────────────────
    const productMap = new Map<string, { name: string; qty: number; revenue: number; isFood: boolean }>()
    // ─── By category ─────────────────────────────────────────────────────────────
    const categoryMap = new Map<string, { name: string; slug: string; qty: number; revenue: number }>()

    for (const order of orders) {
      for (const item of order.items) {
        const key = item.product.id
        const existing = productMap.get(key)
        if (existing) {
          existing.qty += item.quantity
          existing.revenue += Number(item.subtotal)
        } else {
          productMap.set(key, {
            name: item.product.name,
            qty: item.quantity,
            revenue: Number(item.subtotal),
            isFood: item.product.category?.slug === 'foods',
          })
        }

        const catSlug = item.product.category?.slug ?? 'unknown'
        const catName = item.product.category?.name ?? 'ไม่ระบุ'
        const catExisting = categoryMap.get(catSlug)
        if (catExisting) {
          catExisting.qty += item.quantity
          catExisting.revenue += Number(item.subtotal)
        } else {
          categoryMap.set(catSlug, { name: catName, slug: catSlug, qty: item.quantity, revenue: Number(item.subtotal) })
        }
      }
    }
    const topProducts = [...productMap.entries()]
      .map(([id, v]) => ({ id, ...v }))
      .sort((a, b) => b.qty - a.qty)
      .slice(0, 10)

    const byCategory = [...categoryMap.values()].sort((a, b) => b.revenue - a.revenue)

    // ─── Revenue by payment method ───────────────────────────────────────────────
    const paymentMethodMap: Record<string, number> = {}
    for (const order of orders) {
      if (order.payment) {
        const m = order.payment.method
        paymentMethodMap[m] = (paymentMethodMap[m] ?? 0) + Number(order.total)
      }
    }
    const byPaymentMethod = Object.entries(paymentMethodMap).map(([method, amount]) => ({ method, amount }))

    const todayBKK = new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10)
    return okResponse({
      dateFrom: dateFrom ?? todayBKK,
      dateTo: dateTo ?? dateFrom ?? todayBKK,
      totalOrders,
      totalCups,
      totalFoods,
      totalRevenue,
      revenueFood,
      revenueDrink,
      topProducts,
      byPaymentMethod,
      byCategory,
    })
  } catch (e) {
    handleError(e)
  }
})
