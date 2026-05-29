<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const http = useHttpClient()

interface MemberOrder {
  id: string
  status: string
  total: string | number
  pointsEarned: number
  pointsRedeemed: number
  createdAt: string
  items: {
    id: string
    quantity: number
    unitPrice: string | number
    product: { id: string; name: string; imageUrl: string | null }
  }[]
}

const orders = ref<MemberOrder[]>([])
const loading = ref(true)
const refreshing = ref(false)
const error = ref('')
let timer: ReturnType<typeof setInterval> | null = null

async function loadOrders(silent = false) {
  if (!silent) loading.value = true
  else refreshing.value = true
  try {
    const res = await http.get<{ success: boolean; data: MemberOrder[] }>(API_ENDPOINTS.MEMBER.ORDERS.LIST)
    orders.value = res.data ?? []
    error.value = ''
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'โหลดไม่สำเร็จ'
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

onMounted(() => {
  loadOrders()
  timer = setInterval(() => loadOrders(true), 30000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const statusLabel: Record<string, string> = {
  PENDING: 'รอดำเนินการ',
  PREPARING: 'กำลังทำ',
  READY: 'พร้อมรับ',
  COMPLETED: 'เสร็จสิ้น',
  CANCELLED: 'ยกเลิก',
}

const statusColor: Record<string, string> = {
  PENDING: 'bg-gray-100 text-gray-600',
  PREPARING: 'bg-yellow-100 text-yellow-700',
  READY: 'bg-green-100 text-green-700',
  COMPLETED: 'bg-green-50 text-green-600',
  CANCELLED: 'bg-red-100 text-red-700',
}

const statusIcon: Record<string, string> = {
  PENDING: 'mdi:clock-outline',
  PREPARING: 'mdi:fire',
  READY: 'mdi:check-circle',
  COMPLETED: 'mdi:check-all',
  CANCELLED: 'mdi:close-circle',
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-4">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-bold text-gray-900">ออเดอร์ของฉัน</h1>
      <div class="flex items-center gap-2">
        <button
          class="p-2 rounded-xl border border-gray-200 text-gray-500 hover:bg-gray-50 transition-colors"
          :class="{ 'animate-spin': refreshing }"
          :disabled="refreshing"
          @click="loadOrders(true)"
        >
          <Icon name="mdi:refresh" class="w-5 h-5" />
        </button>
        <NuxtLink
          to="/member/orders/new"
          class="px-4 py-2 bg-[#1B2B4B] text-white text-sm font-semibold rounded-xl hover:bg-[#2a3f6b] transition-colors"
        >
          สั่งใหม่
        </NuxtLink>
      </div>
    </div>

    <div v-if="loading" class="py-16 text-center text-gray-400">กำลังโหลด...</div>
    <div v-else-if="error" class="py-16 text-center text-red-500">{{ error }}</div>
    <div v-else-if="orders.length === 0" class="py-16 text-center">
      <Icon name="flat-color-icons:shop" class="text-6xl mb-4" />
      <p class="text-gray-500">ยังไม่มีออเดอร์</p>
      <NuxtLink to="/member/orders/new" class="mt-4 inline-block text-[#1B2B4B] font-medium hover:underline">
        สั่งออเดอร์แรกของคุณ
      </NuxtLink>
    </div>
    <div v-else class="space-y-3">
      <NuxtLink
        v-for="order in orders"
        :key="order.id"
        :to="`/member/orders/${order.id}`"
        class="block bg-white rounded-2xl shadow p-5 hover:shadow-md transition-shadow"
      >
        <div class="flex items-start justify-between mb-3">
          <div>
            <p class="text-sm text-gray-400 font-mono">{{ order.id.slice(-8).toUpperCase() }}</p>
            <p class="text-xs text-gray-400 mt-0.5">{{ formatDate(order.createdAt) }}</p>
          </div>
          <span class="flex items-center gap-1 text-xs font-semibold px-2.5 py-1 rounded-full" :class="statusColor[order.status]">
            <Icon :name="statusIcon[order.status] ?? 'mdi:help-circle'" class="w-3.5 h-3.5" />
            {{ statusLabel[order.status] }}
          </span>
        </div>

        <div class="space-y-1 mb-3">
          <p
            v-for="item in order.items.slice(0, 3)"
            :key="item.id"
            class="text-sm text-gray-700"
          >
            {{ item.quantity }}x {{ item.product.name }}
          </p>
          <p v-if="order.items.length > 3" class="text-xs text-gray-400">
            +{{ order.items.length - 3 }} รายการ
          </p>
        </div>

        <div class="flex items-center justify-between pt-3 border-t border-gray-50">
          <span class="font-bold text-gray-900">฿{{ Number(order.total).toFixed(2) }}</span>
          <span v-if="order.pointsEarned > 0" class="text-xs text-[#1B2B4B] font-medium">
            +{{ order.pointsEarned }} แต้ม
          </span>
        </div>
      </NuxtLink>
    </div>

    <p v-if="!loading && !error" class="text-center text-xs text-gray-400">รีเฟรชอัตโนมัติทุก 30 วินาที</p>
  </div>
</template>
