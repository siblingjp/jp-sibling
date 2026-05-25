import { z } from 'zod'

const schema = z.object({ requestId: z.string() })

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized('กรุณาเข้าสู่ระบบก่อนโหวต')

    const { requestId } = validate(schema, await readBody(event))
    const weekYear = getWeekYear()

    const request = await prisma.locationRequest.findFirst({
      where: { id: requestId, isActive: true, weekYear },
    })
    if (!request) throw notFound('ไม่พบคำขอนี้')

    // 1 vote ต่อสมาชิกต่อสัปดาห์ (across all requests)
    const alreadyVoted = await prisma.locationVote.findUnique({
      where: { memberId_weekYear: { memberId: session.member.id, weekYear } },
    })
    if (alreadyVoted) throw conflict('คุณโหวตแล้วสัปดาห์นี้')

    await prisma.$transaction([
      prisma.locationVote.create({
        data: { requestId, memberId: session.member.id, weekYear },
      }),
      prisma.locationRequest.update({
        where: { id: requestId },
        data: { voteCount: { increment: 1 } },
      }),
    ])

    return okResponse({ voted: true })
  } catch (e) {
    handleError(e)
  }
})

function getWeekYear() {
  const now = new Date()
  const d = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7))
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
  const week = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7)
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, '0')}`
}
