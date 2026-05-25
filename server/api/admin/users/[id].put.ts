import { z } from 'zod'
import { hash } from 'argon2'

const schema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
  password: z.string().min(8).optional(),
  role: z.enum(['ADMIN', 'CASHIER', 'STAFF']).optional(),
  isActive: z.boolean().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()
    if (session.user.role !== 'ADMIN') throw forbidden()

    const id = getRouterParam(event, 'id')!
    const data = validate(schema, await readBody(event))

    const existing = await prisma.user.findUnique({ where: { id } })
    if (!existing) throw notFound('User')

    if (data.email && data.email !== existing.email) {
      const emailTaken = await prisma.user.findUnique({ where: { email: data.email } })
      if (emailTaken) throw conflict('Email already exists')
    }

    const updateData: Record<string, unknown> = { ...data }
    if (data.password) {
      updateData.passwordHash = await hash(data.password)
      delete updateData.password
    }

    const user = await prisma.user.update({
      where: { id },
      data: updateData,
      select: { id: true, email: true, name: true, role: true, isActive: true, createdAt: true },
    })

    return okResponse(user)
  } catch (e) {
    handleError(e)
  }
})
