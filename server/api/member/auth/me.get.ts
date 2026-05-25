export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.member) throw unauthorized()

    const member = await prisma.member.findUnique({
      where: { id: session.member.id, isActive: true },
      select: {
        id: true, name: true, email: true, phone: true,
        tier: true, points: true, totalSpent: true,
        profileImage: true, lineUserId: true, googleId: true,
        createdAt: true,
      },
    })
    if (!member) throw unauthorized()

    // sync session ถ้า points เปลี่ยน
    if (member.points !== session.member.points) {
      await setUserSession(event, {
        ...session,
        member: { ...session.member, points: member.points, tier: member.tier },
      })
    }

    return okResponse(member)
  } catch (e) {
    handleError(e)
  }
})
