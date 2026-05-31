import { getMessaging } from './firebase'

interface PushPayload {
  title: string
  body: string
  data?: Record<string, string>
}

export async function sendPushToMember(memberId: string, payload: PushPayload) {
  const tokens = await prisma.fcmToken.findMany({
    where: { memberId },
    select: { token: true, id: true },
  })

  if (tokens.length === 0) return

  const messaging = getMessaging()
  const tokenList = tokens.map((t) => t.token)

  const response = await messaging.sendEachForMulticast({
    tokens: tokenList,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data ?? {},
    webpush: {
      notification: {
        title: payload.title,
        body: payload.body,
        icon: '/icons/icon-192x192.png',
        badge: '/icons/icon-96x96.png',
      },
      fcmOptions: { link: payload.data?.url ?? '/member/orders' },
    },
  })

  // ลบ token ที่ไม่ valid ออก
  const invalidTokenIds: string[] = []
  response.responses.forEach((res, i) => {
    if (!res.success && res.error?.code === 'messaging/registration-token-not-registered') {
      invalidTokenIds.push(tokens[i]!.id)
    }
  })
  if (invalidTokenIds.length > 0) {
    await prisma.fcmToken.deleteMany({ where: { id: { in: invalidTokenIds } } })
  }
}
