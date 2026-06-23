export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    // นับจำนวนครั้งที่สั่ง product แต่ละตัว จาก order ที่ไม่ถูก cancel
    const items = await prisma.orderItem.findMany({
      where: {
        order: {
          memberId: session.member.id,
          status: { not: 'CANCELLED' },
        },
      },
      select: { productId: true },
    })

    // นับ frequency
    const freq = new Map<string, number>()
    for (const item of items) {
      freq.set(item.productId, (freq.get(item.productId) ?? 0) + 1)
    }

    if (freq.size === 0) return okResponse([])

    // เอา top 5 product id
    const top5 = [...freq.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([id]) => id)

    const products = await prisma.product.findMany({
      where: { id: { in: top5 }, isActive: true },
      include: {
        category: { select: { id: true, name: true, slug: true } },
        optionGroups: {
          orderBy: { sortOrder: 'asc' },
          include: {
            optionGroup: {
              include: {
                options: {
                  where: { isActive: true },
                  orderBy: { sortOrder: 'asc' },
                },
              },
            },
          },
        },
      },
    })

    // sort ตาม frequency เดิม
    const sorted = top5.map(id => products.find(p => p.id === id)).filter(Boolean)

    return okResponse(sorted)
  } catch (e) {
    handleError(e)
  }
})
