import admin from 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID!,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
    privateKey: process.env.FIREBASE_PRIVATE_KEY!.replace(/\\n/g, '\n'),
  }),
})

const tokens = [
  'eipEE8tyFg7qDc-08LznjR:APA91bGDD11JPCVFe0bOiQuqzhoPTEI05_D6HQswN6XFDadEZfvBJiRphT_4iG71pwwXgRn8zdt3HOle62-45CSjB_AfMK8TNTYav3n35fbUBp4fxNRWF3c',
]

for (const token of tokens) {
  console.log('Sending to:', token.slice(0, 20) + '...')
  try {
    const res = await admin.messaging().send({
      token,
      notification: { title: 'ทดสอบ FCM', body: 'ถ้าเห็นข้อความนี้แสดงว่าใช้งานได้แล้ว!' },
      webpush: {
        notification: { icon: '/icons/icon-192x192.png' },
        fcmOptions: { link: 'https://jp-sibling.com/member/orders' },
      },
    })
    console.log('SUCCESS:', res)
  } catch (e: any) {
    console.error('ERROR:', e.message, '\nCode:', e.code)
  }
}
