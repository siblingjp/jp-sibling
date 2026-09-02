import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).optional(),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/).optional(),
  description: z.string().optional().nullable(),
  price: z.number().positive().optional(),
  imageUrl: z.string().url().optional().or(z.literal('')).nullable(),
  categoryId: z.string().cuid().optional(),
  isActive: z.boolean().optional(),
  isFeatured: z.boolean().optional(),
  isStampEligible: z.boolean().optional(),
  optionGroupIds: z.array(z.string()).optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.product.findUnique({ where: { id } })
    if (!existing) throw notFound('Product')

    if (data.slug && data.slug !== existing.slug) {
      const slugTaken = await prisma.product.findUnique({ where: { slug: data.slug } })
      if (slugTaken) throw conflict('Slug already exists')
    }

    if (data.categoryId) {
      const cat = await prisma.category.findUnique({ where: { id: data.categoryId } })
      if (!cat) throw badRequest('Category not found')
    }

    const { optionGroupIds, ...rest } = data

    if (optionGroupIds !== undefined) {
      await prisma.productOptionGroup.deleteMany({ where: { productId: id } })
      if (optionGroupIds.length > 0) {
        await prisma.productOptionGroup.createMany({
          data: optionGroupIds.map((optionGroupId) => ({ productId: id, optionGroupId })),
        })
      }
    }

    const product = await prisma.product.update({
      where: { id },
      data: { ...rest, imageUrl: rest.imageUrl || null },
      include: {
        category: { select: { id: true, name: true } },
        optionGroups: { include: { optionGroup: { include: { options: { where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }] } } } } },
      },
    })

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(product)
  } catch (e) {
    handleError(e)
  }
})
