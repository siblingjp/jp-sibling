import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'slug must be lowercase letters, numbers, and hyphens'),
  description: z.string().optional(),
  price: z.number().positive(),
  imageUrl: z.string().url().optional().or(z.literal('')),
  categoryId: z.string().cuid(),
  isActive: z.boolean().default(true),
  isStampEligible: z.boolean().default(true),
  optionGroupIds: z.array(z.string()).default([]),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const [slugExists, categoryExists] = await Promise.all([
      prisma.product.findUnique({ where: { slug: data.slug } }),
      prisma.category.findUnique({ where: { id: data.categoryId } }),
    ])

    if (slugExists) throw conflict('Slug already exists')
    if (!categoryExists) throw badRequest('Category not found')

    const { optionGroupIds, ...rest } = data

    const product = await prisma.product.create({
      data: {
        ...rest,
        description: rest.description || null,
        imageUrl: rest.imageUrl || null,
        optionGroups: {
          create: optionGroupIds.map((optionGroupId) => ({ optionGroupId })),
        },
      },
      include: {
        category: { select: { id: true, name: true } },
        optionGroups: { include: { optionGroup: { include: { options: { where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }] } } } } },
      },
    })

    invalidateCache('pos:products')
    invalidateCache('member:products')
    return okResponse(product, 'Product created')
  } catch (e) {
    handleError(e)
  }
})
