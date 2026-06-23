import { readFileSync } from 'fs'
const { version } = JSON.parse(readFileSync('./package.json', 'utf-8'))

export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: false },

  future: {
    compatibilityVersion: 4,
  },

  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    'nuxt-auth-utils',
    '@vite-pwa/nuxt',
    '@nuxt/icon',
  ],

  icon: {
    serverBundle: {
      collections: ['flat-color-icons', 'mdi'],
    },
  },

  runtimeConfig: {
    s3: {
      accessKey: process.env.S3_ACCESS_KEY || '',
      accessSecret: process.env.S3_ACCESS_SECRET || '',
      bucket: process.env.S3_BUCKET || '',
      region: process.env.S3_REGION || 'ap-southeast-1',
    },
    session: {
      password: process.env.NUXT_SESSION_PASSWORD || '',
      maxAge: 60 * 60 * 24 * 30, // 30 days
    },
    oauth: {
      line: {
        clientId: process.env.LINE_CHANNEL_ID || '',
        clientSecret: process.env.LINE_CHANNEL_SECRET || '',
      },
      google: {
        clientId: process.env.GG_CLIENT_ID || '',
        clientSecret: process.env.GG_CLIENT_SECRET || '',
      },
    },
    firebase: {
      projectId: process.env.FIREBASE_PROJECT_ID || '',
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
      privateKey: process.env.FIREBASE_PRIVATE_KEY || '',
    },
    public: {
      appName: process.env.APP_NAME || 'MyApp',
      appVersion: version,
      firebaseApiKey: process.env.FIREBASE_API_KEY || '',
      firebaseAuthDomain: process.env.FIREBASE_AUTH_DOMAIN || '',
      firebaseProjectId: process.env.FIREBASE_PROJECT_ID || '',
      firebaseMessagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID || '',
      firebaseAppId: process.env.FIREBASE_APP_ID || '',
      firebaseVapidKey: process.env.FIREBASE_VAPID_KEY || '',
    },
  },

  imports: {
    dirs: [
      'composables',
      'composables/utilities',
      'composables/constants',
      'composables/store_models',
    ],
  },

  router: {
    options: {
      strict: false,
    },
  },

  routeRules: {
    '/member/**': { ssr: false },
  },

  nitro: {
    experimental: {
      openAPI: true,
    },
    imports: {
      dirs: ['server/utils'],
    },
  },
  
  pwa: {
    registerType: 'autoUpdate',
    strategies: 'injectManifest',
    srcDir: new URL('./public', import.meta.url).pathname,
    filename: 'sw.js',
    manifest: {
      name: 'JP Sibling',
      short_name: 'JP Sibling',
      description: 'JP Sibling — Member & Order App',
      theme_color: '#1B2B4B',
      background_color: '#ffffff',
      display: 'standalone',
      orientation: 'portrait',
      scope: '/',
      start_url: '/member',
      icons: [
        { src: '/icons/icon-72x72.png',   sizes: '72x72',   type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-96x96.png',   sizes: '96x96',   type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-128x128.png', sizes: '128x128', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-144x144.png', sizes: '144x144', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-152x152.png', sizes: '152x152', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-192x192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-384x384.png', sizes: '384x384', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
        { src: '/icons/icon-192x192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
        { src: '/icons/icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      ],
    },
    injectManifest: {
      globPatterns: ['**/*.{js,css,html,png,jpg,svg,ico,woff,woff2}'],
    },
    client: {
      installPrompt: true,
    },
    devOptions: {
      enabled: false, // ปิดใน dev เพื่อไม่ให้ service worker interfere กับ HMR
    },
  },

  vite: {
    optimizeDeps: {
      include: []
    }
  },

  typescript: {
    strict: true,
  },
})
