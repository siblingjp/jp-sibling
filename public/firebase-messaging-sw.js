importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js')

firebase.initializeApp({
  apiKey: 'AIzaSyC2HRGSnls2Adha3HEUxqR3qv_HPoPhX_c',
  authDomain: 'jp-sibling-5d224.firebaseapp.com',
  projectId: 'jp-sibling-5d224',
  messagingSenderId: '799593395545',
  appId: '1:799593395545:web:478d353bdf4e48e9a44848',
})

const messaging = firebase.messaging()

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {}
  const url = payload.data?.url ?? '/member/orders'

  self.registration.showNotification(title ?? 'Sibling Coffee', {
    body: body ?? '',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-96x96.png',
    data: { url },
  })
})

self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  const url = event.notification.data?.url ?? '/member/orders'
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          client.navigate(url)
          return client.focus()
        }
      }
      return clients.openWindow(url)
    })
  )
})
