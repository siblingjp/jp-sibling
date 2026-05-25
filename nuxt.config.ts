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
  ],

  runtimeConfig: {
    session: {
      password: process.env.NUXT_SESSION_PASSWORD || '',
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
    public: {
      appName: process.env.APP_NAME || 'MyApp',
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

  nitro: {
    experimental: {
      openAPI: true,
    },
  },
  
  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'Sibling Coffee',
      short_name: 'Sibling',
      description: 'Sibling Coffee — Member & Order App',
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
    workbox: {
      // ห้าม cache API routes ทั้งหมด — ป้องกัน stale session/data
      navigateFallback: null,
      globPatterns: ['**/*.{js,css,html,png,jpg,svg,ico,woff,woff2}'],
      runtimeCaching: [
        {
          // Cache static assets (images, fonts) — stale-while-revalidate
          urlPattern: /\.(png|jpg|jpeg|svg|gif|webp|ico|woff|woff2)$/,
          handler: 'StaleWhileRevalidate',
          options: {
            cacheName: 'static-assets',
            expiration: { maxEntries: 100, maxAgeSeconds: 60 * 60 * 24 * 30 },
          },
        },
        {
          // ไม่ cache /api/* เลย — ป้องกัน auth/data ผิดพลาด
          urlPattern: /^\/api\//,
          handler: 'NetworkOnly',
        },
        {
          // ไม่ cache OAuth redirects
          urlPattern: /\/auth\/oauth\//,
          handler: 'NetworkOnly',
        },
      ],
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
