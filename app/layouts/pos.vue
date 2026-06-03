<script setup lang="ts">
const { user } = useAuth()
const http = useHttpClient()

const isOpen = ref<boolean | null>(null)
const isToggling = ref(false)

onMounted(async () => {
  try {
    const res = await http.get<{ data: { truckLocation: { isOpen: boolean } | null } }>('/api/public/home')
    isOpen.value = res.data?.truckLocation?.isOpen ?? false
  } catch {
    isOpen.value = false
  }
})

async function toggleOpen() {
  isToggling.value = true
  try {
    const res = await http.post<{ data: { isOpen: boolean } }>('/api/admin/location/toggle-open')
    isOpen.value = res.data?.isOpen ?? !isOpen.value
  } catch {
    // silent
  } finally {
    isToggling.value = false
  }
}
</script>

<template>
  <div class="h-screen bg-gray-50 flex flex-col overflow-hidden">
    <header class="bg-white border-b border-gray-200 px-3 md:px-6 py-2 md:py-3 flex items-center justify-between flex-shrink-0 gap-2">
      <div class="flex items-center gap-2 md:gap-6 min-w-0">
        <h1 class="text-base font-bold text-gray-900 flex-shrink-0">POS</h1>
        <nav class="flex gap-1">
          <NuxtLink
            to="/pos"
            class="px-2 md:px-3 py-1.5 rounded-lg text-xs md:text-sm font-medium transition-colors whitespace-nowrap"
            :class="$route.path === '/pos' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >สั่งสินค้า</NuxtLink>
          <NuxtLink
            to="/pos/orders"
            class="px-2 md:px-3 py-1.5 rounded-lg text-xs md:text-sm font-medium transition-colors whitespace-nowrap"
            :class="$route.path === '/pos/orders' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >คิวออเดอร์</NuxtLink>
        </nav>
      </div>
      <div class="flex items-center gap-2 md:gap-4 flex-shrink-0">
        <button
          v-if="isOpen !== null"
          :disabled="isToggling"
          class="flex items-center gap-1 md:gap-1.5 px-2 md:px-3 py-1.5 rounded-lg text-xs md:text-sm font-medium transition-colors disabled:opacity-60"
          :class="isOpen ? 'bg-green-100 text-green-700 hover:bg-green-200' : 'bg-red-100 text-red-600 hover:bg-red-200'"
          @click="toggleOpen"
        >
          <Icon :name="isOpen ? 'mdi:store-check' : 'mdi:store-off'" class="text-base" />
          <span class="hidden sm:inline">{{ isOpen ? 'เปิดอยู่' : 'ปิดอยู่' }}</span>
        </button>
        <span class="text-xs md:text-sm text-gray-500 hidden sm:inline truncate max-w-[80px] md:max-w-none">{{ user?.name }}</span>
        <NuxtLink to="/admin" class="text-xs md:text-sm text-gray-500 hover:text-gray-900 transition-colors whitespace-nowrap">หลังบ้าน</NuxtLink>
      </div>
    </header>
    <main class="flex-1 overflow-hidden">
      <slot />
    </main>
  </div>
</template>
