import { z } from 'zod'

const schema = z.object({
  token: z.string().min(1),
  platform: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const { token, platform } = await readValidatedBody(event, schema.parse)

    await prisma.fcmToken.upsert({
      where: { token },
      update: { memberId: session.member.id, platform, updatedAt: new Date() },
      create: { token, platform, memberId: session.member.id },
    })

    return okResponse(null)
  } catch (e) {
    handleError(e)
  }
})
