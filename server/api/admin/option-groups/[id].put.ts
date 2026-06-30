import { z } from 'zod'

const optionSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1),
  extraPrice: z.number().min(0).default(0),
  isActive: z.boolean().default(true),
  sortOrder: z.number().int().default(0),
})

const schema = z.object({
  name: z.string().min(1),
  required: z.boolean(),
  multiSelect: z.boolean(),
  isActive: z.boolean(),
  sortOrder: z.number().int().default(0),
  options: z.array(optionSchema).min(1),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.optionGroup.findUnique({ where: { id } })
    if (!existing) throw notFound('Option Group')

    const incomingIds = data.options.filter((o) => o.id).map((o) => o.id!)

    const toRemove = await prisma.option.findMany({
      where: { groupId: id, id: { notIn: incomingIds } },
      select: { id: true },
    })
    const toRemoveIds = toRemove.map(o => o.id)

    if (toRemoveIds.length > 0) {
      await prisma.orderItemOption.deleteMany({ where: { optionId: { in: toRemoveIds } } })
      await prisma.option.deleteMany({ where: { id: { in: toRemoveIds } } })
    }

    await Promise.all(data.options.map(opt =>
      opt.id
        ? prisma.option.update({
            where: { id: opt.id },
            data: { name: opt.name, extraPrice: opt.extraPrice, isActive: opt.isActive, sortOrder: opt.sortOrder },
          })
        : prisma.option.create({
            data: { name: opt.name, extraPrice: opt.extraPrice, isActive: opt.isActive, sortOrder: opt.sortOrder, groupId: id },
          })
    ))

    const group = await prisma.optionGroup.update({
      where: { id },
      data: { name: data.name, required: data.required, multiSelect: data.multiSelect, isActive: data.isActive, sortOrder: data.sortOrder },
      include: { options: { orderBy: [{ sortOrder: 'asc' }] } },
    })

    return okResponse(group)
  } catch (e) {
    handleError(e)
  }
})
