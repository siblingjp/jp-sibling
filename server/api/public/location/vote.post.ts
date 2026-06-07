import { z } from 'zod'

const schema = z.object({ requestId: z.string() })

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized('กรุณาเข้าสู่ระบบก่อนโหวต')

    const { requestId } = validate(schema, await readBody(event))
    const weekYear = getMonthYear()

    const request = await prisma.locationRequest.findFirst({
      where: { id: requestId, isActive: true, weekYear },
    })
    if (!request) throw notFound('ไม่พบคำขอนี้')

    // 1 vote ต่อสมาชิกต่อเดือน (across all requests)
    const alreadyVoted = await prisma.locationVote.findUnique({
      where: { memberId_weekYear: { memberId: session.member.id, weekYear } },
    })
    if (alreadyVoted) throw conflict('คุณโหวตแล้วเดือนนี้')

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

function getMonthYear() {
  const bkk = new Date(new Date().toLocaleString('en-US', { timeZone: 'Asia/Bangkok' }))
  return `${bkk.getFullYear()}-${String(bkk.getMonth() + 1).padStart(2, '0')}`
}
