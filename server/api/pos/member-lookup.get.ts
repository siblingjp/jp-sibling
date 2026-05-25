export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const { q } = getQuery(event) as { q?: string }
    if (!q || q.trim().length < 2) throw badRequest('Search query too short')

    const member = await prisma.member.findFirst({
      where: {
        isActive: true,
        OR: [
          { phone: { contains: q.trim() } },
          { email: { contains: q.trim(), mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        tier: true,
        points: true,
        profileImage: true,
      },
    })

    if (!member) throw notFound('Member')

    return okResponse(member)
  } catch (e) {
    handleError(e)
  }
})
