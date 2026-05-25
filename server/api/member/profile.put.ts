import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  phone: z.string().optional().nullable(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const member = await prisma.member.update({
      where: { id: session.member.id },
      data: { name: data.name, phone: data.phone ?? null },
      select: {
        id: true, name: true, email: true, phone: true,
        tier: true, points: true, totalSpent: true,
        profileImage: true, lineUserId: true, googleId: true,
        createdAt: true,
      },
    })

    await setUserSession(event, {
      ...session,
      member: { ...session.member, name: member.name },
    })

    return okResponse(member)
  } catch (e) {
    handleError(e)
  }
})
