export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const member = await prisma.member.findUnique({
      where: { id: session.member.id, isActive: true },
      select: {
        id: true, name: true, email: true, phone: true,
        tier: true, points: true, stampCount: true, totalSpent: true,
        profileImage: true, lineUserId: true, googleId: true,
        createdAt: true,
      },
    })
    if (!member) throw unauthorized()

    // ต่ออายุ session ทุกครั้งที่เปิดแอป (rolling session) — ป้องกันการหลุด login
    // ก่อนครบ 30 วันจริง โดยเฉพาะบน iOS ที่ระบบอาจเคลียร์ storage ถ้าไม่ได้เปิดแอปนาน ๆ
    await replaceUserSession(event, {
      ...session,
      member: { ...session.member, points: member.points, tier: member.tier },
    })

    return okResponse({ ...member, hasPendingStampRedemption: await checkHasPendingStampRedemption(member.id) })
  } catch (e) {
    handleError(e)
  }
})
