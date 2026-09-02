import { z } from 'zod'

const schema = z.object({
  memberId: z.string(),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { memberId } = validate(schema, await readBody(event))

    const member = await prisma.member.findUnique({ where: { id: memberId } })
    if (!member) throw notFound('Member')

    // ถ้ามีคำขอแลกที่ค้างอยู่จากแอปสมาชิกแล้ว ให้ยืนยันคำขอนั้นแทนการสร้างใหม่
    // (กันแลกซ้ำ/แข่งกันระหว่าง POS กับแอปสมาชิก)
    const existingPending = await prisma.stampRedemption.findFirst({
      where: { memberId: member.id, status: 'PENDING' },
    })

    if (existingPending) {
      const confirmed = await prisma.stampRedemption.updateMany({
        where: { id: existingPending.id, status: 'PENDING' },
        data: { status: 'CONFIRMED', confirmedAt: new Date(), confirmedById: session.user!.id },
      })
      if (confirmed.count === 0) throw badRequest('คำขอนี้ถูกใช้ไปแล้วหรือถูกยกเลิก')
      return okResponse({ id: existingPending.id })
    }

    if (member.stampCount < MAX_STAMPS) throw badRequest('สะสมแสตมป์ยังไม่ครบ 10 ดวง')

    const redemption = await prisma.$transaction(async (tx) => {
      // เช็คซ้ำภายใน transaction กันแข่งกันระหว่างคำขอ POS 2 คำขอพร้อมกัน
      const stillPending = await tx.stampRedemption.findFirst({
        where: { memberId: member.id, status: 'PENDING' },
      })
      if (stillPending) throw badRequest('มีคำขอแลกที่รอดำเนินการอยู่แล้ว กรุณาลองใหม่')

      const current = await tx.member.findUnique({ where: { id: member.id }, select: { stampCount: true } })
      if (!current || current.stampCount < MAX_STAMPS) throw badRequest('สะสมแสตมป์ยังไม่ครบ 10 ดวง')

      await tx.member.update({ where: { id: member.id }, data: { stampCount: 0 } })
      await tx.stampLog.create({
        data: { memberId: member.id, action: 'REDEEM', amount: -MAX_STAMPS, note: 'Redeemed at POS' },
      })
      return tx.stampRedemption.create({
        data: {
          memberId: member.id,
          status: 'CONFIRMED',
          confirmedAt: new Date(),
          confirmedById: session.user!.id,
        },
      })
    }, { timeout: 10000 })

    return okResponse(redemption)
  } catch (e) {
    handleError(e)
  }
})
