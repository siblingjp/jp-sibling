<script setup lang="ts">
const { user } = useAuth()
const http = useHttpClient()

const isOpen = ref(false)
const manualClose = ref(false)
const blockOnlineOrder = ref(false)
const isToggling = ref(false)
const showCloseModal = ref(false)

async function fetchStatus() {
  try {
    const res = await http.get<{ data: { truckLocation: { isOpen: boolean; manualClose: boolean; blockOnlineOrder: boolean } | null } }>('/api/public/home')
    isOpen.value = res.data?.truckLocation?.isOpen ?? false
    manualClose.value = res.data?.truckLocation?.manualClose ?? false
    blockOnlineOrder.value = res.data?.truckLocation?.blockOnlineOrder ?? false
  } catch {
    // silent
  }
}

onMounted(fetchStatus)

async function applyMode(mode: 'close' | 'closeBlock' | 'reset') {
  isToggling.value = true
  try {
    const res = await http.post<{ data: { manualClose: boolean; blockOnlineOrder: boolean } }>(
      API_ENDPOINTS.ADMIN.LOCATION.TOGGLE_OPEN,
      { mode },
    )
    manualClose.value = res.data?.manualClose ?? false
    blockOnlineOrder.value = res.data?.blockOnlineOrder ?? false
    // re-fetch isOpen เพื่อให้ปุ่มสะท้อน timeline จริง
    await fetchStatus()
  } catch {
    // silent
  } finally {
    isToggling.value = false
    showCloseModal.value = false
  }
}
</script>

<template>
  <div class="h-[100dvh] bg-gray-50 flex flex-col overflow-hidden">
    <header class="bg-white border-b border-gray-200 px-3 md:px-6 py-2 md:py-3 flex items-center justify-between flex-shrink-0 gap-2">
      <div class="flex items-center gap-2 md:gap-4 min-w-0">
        <h1 class="text-base font-bold text-gray-900 flex-shrink-0">POS</h1>
        <nav class="flex gap-1">
          <NuxtLink
            to="/pos"
            class="px-5 py-2.5 rounded-lg text-sm font-medium transition-colors whitespace-nowrap"
            :class="$route.path === '/pos' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >สั่งสินค้า</NuxtLink>
          <NuxtLink
            to="/pos/orders"
            class="px-5 py-2.5 rounded-lg text-sm font-medium transition-colors whitespace-nowrap"
            :class="$route.path === '/pos/orders' ? 'bg-blue-600 text-white' : 'text-gray-600 hover:bg-gray-100'"
          >คิวออเดอร์</NuxtLink>
        </nav>
      </div>
      <div class="flex items-center gap-2 md:gap-3 flex-shrink-0">
        <!-- Store status button -->
        <button
          :disabled="isToggling"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors disabled:opacity-60"
          :class="isOpen
            ? 'bg-green-100 text-green-700 hover:bg-green-200'
            : blockOnlineOrder
              ? 'bg-red-100 text-red-600 hover:bg-red-200'
              : 'bg-orange-100 text-orange-600 hover:bg-orange-200'"
          @click="showCloseModal = true"
        >
          <Icon :name="isOpen ? 'mdi:store-check' : blockOnlineOrder ? 'mdi:store-remove' : 'mdi:store-clock'" class="text-base" />
          <span class="hidden sm:inline">
            {{ isOpen ? 'เปิดอยู่' : blockOnlineOrder ? 'ปิดร้าน (ปิดออนไลน์)' : 'ปิดร้าน (รับออนไลน์)' }}
          </span>
        </button>
        <!-- <span class="text-sm text-gray-500 hidden md:inline truncate max-w-[100px] lg:max-w-none">{{ user?.name }}</span> -->
        <NuxtLink to="/admin" class="text-sm text-gray-500 hover:text-gray-900 transition-colors whitespace-nowrap hidden sm:inline">ระบบหลังบ้าน</NuxtLink>
      </div>
    </header>
    <main class="flex-1 overflow-hidden">
      <slot />
    </main>
  </div>

  <!-- Close modal -->
  <Teleport to="body">
    <div v-if="showCloseModal" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="showCloseModal = false" />
      <div class="relative bg-white w-full max-w-sm rounded-2xl shadow-xl p-6 space-y-4">
        <h2 class="text-base font-semibold text-gray-900 text-center">ตั้งค่าสถานะร้าน</h2>
        <p class="text-xs text-gray-400 text-center">การตั้งค่านี้จะ reset อัตโนมัติเมื่อถึง 17:00 น.</p>

        <div class="space-y-2">
          <!-- reset to auto -->
          <button
            class="w-full flex items-center gap-3 px-4 py-3 rounded-xl border-2 transition-colors text-left"
            :class="!manualClose ? 'border-green-500 bg-green-50' : 'border-gray-200 hover:bg-gray-50'"
            :disabled="isToggling"
            @click="applyMode('reset')"
          >
            <Icon name="mdi:store-check" class="text-xl text-green-600 flex-shrink-0" />
            <div>
              <p class="text-sm font-medium text-gray-900">เปิดร้านตาม timeline</p>
              <p class="text-xs text-gray-500">เปิด/ปิดอัตโนมัติ และรับออเดอร์ออนไลน์ตามปกติ</p>
            </div>
            <Icon v-if="!manualClose" name="mdi:check-circle" class="ml-auto text-green-600 text-lg flex-shrink-0" />
          </button>

          <!-- close store, allow online orders -->
          <button
            class="w-full flex items-center gap-3 px-4 py-3 rounded-xl border-2 transition-colors text-left"
            :class="manualClose && !blockOnlineOrder ? 'border-orange-400 bg-orange-50' : 'border-gray-200 hover:bg-gray-50'"
            :disabled="isToggling"
            @click="applyMode('close')"
          >
            <Icon name="mdi:store-off" class="text-xl text-orange-500 flex-shrink-0" />
            <div>
              <p class="text-sm font-medium text-gray-900">ปิดร้าน / เปิดรับออเดอร์ออนไลน์</p>
              <p class="text-xs text-gray-500">ร้านปิด แต่ member ยังสั่งล่วงหน้าได้</p>
            </div>
            <Icon v-if="manualClose && !blockOnlineOrder" name="mdi:check-circle" class="ml-auto text-orange-500 text-lg flex-shrink-0" />
          </button>

          <!-- close store + block online orders -->
          <button
            class="w-full flex items-center gap-3 px-4 py-3 rounded-xl border-2 transition-colors text-left"
            :class="manualClose && blockOnlineOrder ? 'border-red-500 bg-red-50' : 'border-gray-200 hover:bg-gray-50'"
            :disabled="isToggling"
            @click="applyMode('closeBlock')"
          >
            <Icon name="mdi:store-remove" class="text-xl text-red-600 flex-shrink-0" />
            <div>
              <p class="text-sm font-medium text-gray-900">ปิดร้าน / ปิดรับออเดอร์ออนไลน์</p>
              <p class="text-xs text-gray-500">ร้านปิด และไม่รับออเดอร์ออนไลน์ทั้งหมด</p>
            </div>
            <Icon v-if="manualClose && blockOnlineOrder" name="mdi:check-circle" class="ml-auto text-red-600 text-lg flex-shrink-0" />
          </button>
        </div>

        <button
          class="w-full py-2.5 rounded-xl border border-gray-200 text-sm text-gray-500 hover:bg-gray-50"
          @click="showCloseModal = false"
        >ยกเลิก</button>
      </div>
    </div>
  </Teleport>
</template>
