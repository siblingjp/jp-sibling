export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { slug, dateFrom, dateTo } = getQuery(event) as {
      slug?: string
      dateFrom?: string
      dateTo?: string
    }

    if (!slug) throw badRequest('slug is required')

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

    const orderItems = await prisma.orderItem.findMany({
      where: {
        order: {
          status: 'COMPLETED',
          createdAt: { gte: start, lte: end },
        },
        product: {
          category: { slug },
        },
      },
      select: {
        quantity: true,
        subtotal: true,
        product: {
          select: {
            id: true,
            name: true,
            price: true,
            imageUrl: true,
            category: { select: { name: true } },
          },
        },
      },
    })

    const categoryName = orderItems[0]?.product.category?.name ?? slug

    const productMap = new Map<string, { id: string; name: string; price: number; imageUrl: string | null; qty: number; revenue: number }>()
    for (const item of orderItems) {
      const key = item.product.id
      const existing = productMap.get(key)
      if (existing) {
        existing.qty += item.quantity
        existing.revenue += Number(item.subtotal)
      } else {
        productMap.set(key, {
          id: item.product.id,
          name: item.product.name,
          price: Number(item.product.price),
          imageUrl: item.product.imageUrl,
          qty: item.quantity,
          revenue: Number(item.subtotal),
        })
      }
    }

    const products = [...productMap.values()].sort((a, b) => b.qty - a.qty)
    const totalQty = products.reduce((s, p) => s + p.qty, 0)
    const totalRevenue = products.reduce((s, p) => s + p.revenue, 0)

    const todayBKK = new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10)
    return okResponse({
      slug,
      categoryName,
      dateFrom: dateFrom ?? todayBKK,
      dateTo: dateTo ?? dateFrom ?? todayBKK,
      totalQty,
      totalRevenue,
      products,
    })
  } catch (e) {
    handleError(e)
  }
})
