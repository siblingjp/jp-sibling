export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const { code } = getQuery(event) as { code?: string }
    const redirectUri = `${getRequestURL(event).origin}/api/member/auth/oauth/google`

    // Step 1: redirect ไป Google
    if (!code) {
      const params = new URLSearchParams({
        client_id: config.oauth.google.clientId,
        redirect_uri: redirectUri,
        response_type: 'code',
        scope: 'openid email profile',
        access_type: 'offline',
        prompt: 'select_account',
      })
      return sendRedirect(event, `https://accounts.google.com/o/oauth2/v2/auth?${params}`)
    }

    // Step 2: exchange code -> token
    const tokenRes = await $fetch<any>('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id: config.oauth.google.clientId,
        client_secret: config.oauth.google.clientSecret,
        redirect_uri: redirectUri,
        grant_type: 'authorization_code',
      }).toString(),
    })

    // Step 3: get user info
    const userInfo = await $fetch<any>('https://www.googleapis.com/oauth2/v3/userinfo', {
      headers: { Authorization: `Bearer ${tokenRes.access_token}` },
    })

    const googleId = userInfo.sub
    const name = userInfo.name
    const email = userInfo.email ?? null
    const profileImage = userInfo.picture ?? null

    // Step 4: upsert — link by googleId ก่อน ถ้าไม่มีลอง link email
    let member = await prisma.member.findUnique({ where: { googleId } })

    if (!member && email) {
      const byEmail = await prisma.member.findUnique({ where: { email } })
      if (byEmail) {
        member = await prisma.member.update({ where: { id: byEmail.id }, data: { googleId, profileImage } })
      }
    }

    if (!member) {
      member = await prisma.member.create({
        data: { googleId, name, email, profileImage },
      })
    } else {
      member = await prisma.member.update({
        where: { id: member.id },
        data: { profileImage },
      })
    }

    if (!member.isActive) throw forbidden('Account is inactive')

    await setUserSession(event, {
      member: { id: member.id, name: member.name, email: member.email, tier: member.tier, points: member.points },
    })

    const redirectTo = member.phone ? '/member' : '/member/complete-profile'
    return sendRedirect(event, redirectTo)
  } catch (e) {
    handleError(e)
  }
})
