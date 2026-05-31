import admin from 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID!,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL!,
    privateKey: process.env.FIREBASE_PRIVATE_KEY!.replace(/\\n/g, '\n'),
  }),
})

const tokens = [
  'e22h0DI6IdB24tYZti3afa:APA91bEnkF9pVYIBuQWL3w0LmV4r3-VQXSboqNfiYdb0yvBakwBRhhCiIR3e6zcy_5-pYN3-DJU2bdDqi2pNIs2RCVp7ZawQrM6Avd4HSAryG41X1WUcCz4',
  'eKbKk7wqYv9VKc7dkQS5q1:APA91bFlp3oVO0wPe4YBvCiE_tdfZVS1CbrVITMOur5w3VWxFebiVceGOqXmfQZ-QYSwOGh3MA4oHpZTPlVvEFaXBFHeeyqOv3nD3OvWY0rIkzbbQQoV6mw',
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
