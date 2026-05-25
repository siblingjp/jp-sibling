import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).optional(),
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/).optional(),
  imageUrl: z.string().url().optional().or(z.literal('')),
  isActive: z.boolean().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.category.findUnique({ where: { id } })
    if (!existing) throw notFound('Category')

    if (data.slug && data.slug !== existing.slug) {
      const slugTaken = await prisma.category.findUnique({ where: { slug: data.slug } })
      if (slugTaken) throw conflict('Slug already exists')
    }

    const category = await prisma.category.update({
      where: { id },
      data: { ...data, imageUrl: data.imageUrl || null },
    })

    return okResponse(category)
  } catch (e) {
    handleError(e)
  }
})
