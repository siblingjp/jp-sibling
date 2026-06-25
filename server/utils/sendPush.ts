import { getMessaging } from './firebase'

interface PushPayload {
  title: string
  body: string
  data?: Record<string, string>
}

async function sendPushToTokens(tokens: { token: string; id: string }[], payload: PushPayload, link: string) {
  if (tokens.length === 0) return
  const messaging = getMessaging()
  const response = await messaging.sendEachForMulticast({
    tokens: tokens.map(t => t.token),
    notification: { title: payload.title, body: payload.body },
    data: payload.data ?? {},
    webpush: {
      notification: {
        title: payload.title,
        body: payload.body,
        icon: '/icons/icon-192x192.png',
        badge: '/icons/icon-96x96.png',
      },
      fcmOptions: { link },
    },
  })
  const invalidIds = response.responses
    .map((res, i) => (!res.success && res.error?.code === 'messaging/registration-token-not-registered') ? tokens[i]!.id : null)
    .filter(Boolean) as string[]
  if (invalidIds.length > 0) {
    await prisma.fcmToken.deleteMany({ where: { id: { in: invalidIds } } })
  }
}

export async function sendPushToMember(memberId: string, payload: PushPayload) {
  const tokens = await prisma.fcmToken.findMany({
    where: { memberId },
    select: { token: true, id: true },
  })
  await sendPushToTokens(tokens, payload, payload.data?.url ?? '/member/orders')
}

export async function sendPushToAllStaff(payload: PushPayload) {
  const tokens = await prisma.fcmToken.findMany({
    where: { userId: { not: null } },
    select: { token: true, id: true },
  })
  await sendPushToTokens(tokens, payload, payload.data?.url ?? '/pos/orders')
}
