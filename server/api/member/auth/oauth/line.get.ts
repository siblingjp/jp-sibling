export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const { code, state } = getQuery(event) as { code?: string; state?: string }

    // Step 1: redirect ไป LINE
    if (!code) {
      const params = new URLSearchParams({
        response_type: 'code',
        client_id: config.oauth.line.clientId,
        redirect_uri: `${getRequestURL(event).origin}/api/member/auth/oauth/line`,
        scope: 'profile openid email',
        state: 'line_oauth',
      })
      return sendRedirect(event, `https://access.line.me/oauth2/v2.1/authorize?${params}`)
    }

    // Step 2: exchange code -> token
    const tokenRes = await $fetch<any>('https://api.line.me/oauth2/v2.1/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: `${getRequestURL(event).origin}/api/member/auth/oauth/line`,
        client_id: config.oauth.line.clientId,
        client_secret: config.oauth.line.clientSecret,
      }).toString(),
    })

    // Step 3: get profile
    const profile = await $fetch<any>('https://api.line.me/v2/profile', {
      headers: { Authorization: `Bearer ${tokenRes.access_token}` },
    })

    // email อยู่ใน id_token (JWT payload) ไม่ใช่ /v2/profile
    const idTokenPayload = tokenRes.id_token
      ? JSON.parse(Buffer.from(tokenRes.id_token.split('.')[1], 'base64url').toString())
      : null

    const lineUserId = profile.userId
    const name = profile.displayName
    const profileImage = profile.pictureUrl ?? null
    const lineEmail = idTokenPayload?.email ?? null

    // Step 4: upsert member
    let member = await prisma.member.findUnique({ where: { lineUserId } })
    if (!member) {
      member = await prisma.member.create({
        data: { lineUserId, name, profileImage, email: lineEmail },
      })
    } else {
      member = await prisma.member.update({
        where: { id: member.id },
        data: { profileImage, ...(lineEmail && !member.email ? { email: lineEmail } : {}) },
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
