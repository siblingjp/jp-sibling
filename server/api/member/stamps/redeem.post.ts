export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const member = await prisma.member.findUnique({ where: { id: session.member.id } })
    if (!member) throw unauthorized()

    if (member.stampCount < MAX_STAMPS) throw badRequest('สะสมแสตมป์ยังไม่ครบ 10 ดวง')

    const existingPending = await prisma.stampRedemption.findFirst({
      where: { memberId: member.id, status: 'PENDING' },
    })
    if (existingPending) throw badRequest('มีคำขอแลกที่รอดำเนินการอยู่แล้ว')

    const redemption = await prisma.$transaction(async (tx) => {
      // เช็คซ้ำภายใน transaction กันแข่งกันกับคำขอแลกที่ POS หรือแอปพร้อมกัน
      const stillPending = await tx.stampRedemption.findFirst({
        where: { memberId: member.id, status: 'PENDING' },
      })
      if (stillPending) throw badRequest('มีคำขอแลกที่รอดำเนินการอยู่แล้ว')

      const current = await tx.member.findUnique({ where: { id: member.id }, select: { stampCount: true } })
      if (!current || current.stampCount < MAX_STAMPS) throw badRequest('สะสมแสตมป์ยังไม่ครบ 10 ดวง')

      await tx.member.update({ where: { id: member.id }, data: { stampCount: 0 } })
      await tx.stampLog.create({
        data: { memberId: member.id, action: 'REDEEM', amount: -MAX_STAMPS, note: 'ขอแลกฟรีคัพออนไลน์' },
      })
      return tx.stampRedemption.create({ data: { memberId: member.id, status: 'PENDING' } })
    }, { timeout: 10000 })

    return okResponse(redemption)
  } catch (e) {
    handleError(e)
  }
})
