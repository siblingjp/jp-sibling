<template>
  <div v-if="!store.initialized" class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="flex flex-col items-center gap-3 text-gray-400">
      <Icon name="mdi:loading" class="text-4xl animate-spin text-[#1B2B4B]" />
      <p class="text-sm">กำลังโหลด...</p>
    </div>
  </div>
  <div v-else class="min-h-screen bg-gray-50 pb-20">
    <header class="bg-white shadow-sm sticky top-0 z-50">
      <nav class="max-w-2xl mx-auto px-4 h-14 flex items-center justify-between">
        <NuxtLink to="/" class="flex items-center gap-2.5">
          <img src="/logo-text.png" alt="Sibling Coffee" class="h-8 w-auto block sm:hidden" />
          <img src="/logo.jpg" alt="Sibling Coffee" class="hidden sm:block w-8 h-8 rounded-full object-cover" />
          <span class="hidden sm:block font-bold text-[#1B2B4B] text-lg">{{ $config.public.appName }}</span>
        </NuxtLink>
        <button class="text-gray-500 hover:text-red-600 text-sm" @click="handleLogout">ออกจากระบบ</button>
      </nav>
    </header>

    <!-- Notification permission banner (iOS ต้องการ user gesture) -->
    <Transition name="slide-down">
      <div v-if="showNotifBanner" class="bg-[#1B2B4B] px-4 py-3 flex items-center gap-3">
        <Icon name="mdi:bell-ring" class="text-white text-xl flex-shrink-0" />
        <p class="text-white text-sm flex-1">เปิดการแจ้งเตือนเพื่อรับสถานะออเดอร์</p>
        <button
          class="px-3 py-1 bg-white text-[#1B2B4B] text-xs font-bold rounded-lg flex-shrink-0"
          @click="enableNotifications"
        >เปิด</button>
        <button class="text-white/50 hover:text-white p-1 flex-shrink-0" @click="showNotifBanner = false">
          <Icon name="mdi:close" class="text-base" />
        </button>
      </div>
    </Transition>

    <main class="max-w-2xl mx-auto px-4 py-6">
      <slot />
    </main>

    <!-- Bottom nav -->
    <nav class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 z-50">
      <div class="max-w-2xl mx-auto flex">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="flex-1 flex flex-col items-center py-3 gap-1 text-xs transition-colors"
          :class="isActive(item) ? 'text-[#1B2B4B]' : 'text-gray-400 hover:text-gray-600'"
        >
          <Icon :name="item.icon" class="text-2xl" />
          <span class="font-medium">{{ item.label }}</span>
        </NuxtLink>
      </div>
    </nav>
  </div>
</template>

<script setup lang="ts">
const store = useMemberStore()
const { logout } = useMemberAuth()
const router = useRouter()
const { requestAndRegister } = useFcm()

const showNotifBanner = ref(false)

onMounted(() => {
  if (!('Notification' in window)) return
  if (Notification.permission === 'granted') {
    // มี permission แล้ว register token เลยโดยไม่ต้องขอซ้ำ
    requestAndRegister()
  } else if (Notification.permission === 'default') {
    // ยังไม่เคยถาม — แสดง banner ให้กดเพื่อขอผ่าน user gesture
    showNotifBanner.value = true
  }
  // 'denied' → ไม่แสดงอะไร
})

async function enableNotifications() {
  showNotifBanner.value = false
  await requestAndRegister()
}

async function handleLogout() {
  await logout()
  router.push('/')
}

const navItems = [
  { to: '/member', icon: 'flat-color-icons:home', label: 'หน้าแรก', exact: true },
  { to: '/member/orders', icon: 'flat-color-icons:list', label: 'ออเดอร์', exact: false },
  { to: '/member/redeem', icon: 'mdi:gift', label: 'แลกแต้ม', exact: false },
  { to: '/member/coupons', icon: 'mdi:ticket-percent', label: 'คูปอง', exact: false },
  { to: '/member/profile', icon: 'flat-color-icons:businessman', label: 'โปรไฟล์', exact: false },
]

function isActive(item: typeof navItems[number]) {
  const path = useRoute().path
  if (item.exact) return path === item.to
  return path === item.to || path.startsWith(item.to + '/')
}
</script>
