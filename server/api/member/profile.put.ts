import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  phone: z.string().min(9, 'กรุณากรอกเบอร์โทร'),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const data = validate(schema, await readBody(event))

    const phoneExists = await prisma.member.findFirst({
      where: { phone: data.phone, isActive: true, id: { not: session.member.id } },
    })
    if (phoneExists) throw conflict('PHONE_EXISTS')

    const member = await prisma.member.update({
      where: { id: session.member.id },
      data: { name: data.name, phone: data.phone },
      select: {
        id: true, name: true, email: true, phone: true,
        tier: true, points: true, stampCount: true, totalSpent: true,
        profileImage: true, lineUserId: true, googleId: true,
        createdAt: true,
      },
    })

    await setUserSession(event, {
      ...session,
      member: { ...session.member, name: member.name },
    })

    return okResponse({ ...member, hasPendingStampRedemption: await checkHasPendingStampRedemption(member.id) })
  } catch (e) {
    handleError(e)
  }
})
