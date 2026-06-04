<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const route = useRoute()
const http = useHttpClient()
const { showSuccess, showError } = useAlert()

interface OrderDetail {
  id: string
  queueNo: number
  status: string
  source: string
  subtotal: string | number
  discount: string | number
  total: string | number
  pointsEarned: number
  pointsRedeemed: number
  note: string | null
  createdAt: string
  items: {
    id: string
    quantity: number
    unitPrice: string | number
    subtotal: string | number
    note: string | null
    product: { id: string; name: string; imageUrl: string | null }
    options: { id: string; name: string; extraPrice: string | number }[]
  }[]
}

const order = ref<OrderDetail | null>(null)
const loading = ref(true)
const error = ref('')

const orderId = computed(() => route.params.id as string)

async function loadOrder(id: string) {
  loading.value = true
  error.value = ''
  try {
    const res = await http.get<{ success: boolean; data: OrderDetail }>(
      API_ENDPOINTS.MEMBER.ORDERS.SHOW(id)
    )
    order.value = res.data ?? null
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Failed to load'
  } finally {
    loading.value = false
  }
}

onMounted(() => loadOrder(orderId.value))
watch(orderId, (id) => loadOrder(id))

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

const cancelling = ref(false)

async function cancelOrder() {
  if (!order.value) return
  cancelling.value = true
  try {
    await http.post(API_ENDPOINTS.MEMBER.ORDERS.CANCEL(order.value.id), {})
    order.value.status = 'CANCELLED'
    showSuccess('ยกเลิกออเดอร์แล้ว')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'ยกเลิกไม่สำเร็จ')
  } finally {
    cancelling.value = false
  }
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit',
  })
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <div class="flex items-center gap-3">
      <NuxtLink to="/member/orders" class="text-gray-400 hover:text-gray-600">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">รายละเอียดออเดอร์</h1>
    </div>

    <div v-if="loading" class="py-16 text-center text-gray-400">กำลังโหลด...</div>
    <div v-else-if="error" class="py-16 text-center text-red-500">{{ error }}</div>

    <template v-else-if="order">
      <!-- Status card -->
      <div class="bg-white rounded-2xl shadow p-6">
        <div class="flex items-center justify-between mb-4">
          <div>
            <p class="text-2xl font-black text-gray-900 leading-none">#{{ order.queueNo }}</p>
            <p class="text-xs text-gray-400 font-mono mt-0.5">{{ order.id.slice(-12).toUpperCase() }}</p>
            <p class="text-sm text-gray-500 mt-0.5">{{ formatDate(order.createdAt) }}</p>
          </div>
          <span class="px-3 py-1.5 text-sm font-semibold rounded-full" :class="statusColor[order.status]">
            {{ statusLabel[order.status] }}
          </span>
        </div>

        <!-- Live status for active orders -->
        <div v-if="['PENDING', 'PREPARING', 'READY'].includes(order.status)"
          class="flex items-center gap-3 bg-[#F0F4F8] rounded-xl p-4">
          <div class="w-2 h-2 rounded-full bg-[#1B2B4B] animate-pulse flex-shrink-0" />
          <p class="text-sm text-[#1B2B4B] font-medium">
            <template v-if="order.status === 'PENDING'">รับออเดอร์แล้ว กำลังรอเตรียม</template>
            <template v-else-if="order.status === 'PREPARING'">กำลังเตรียมออเดอร์ของคุณ</template>
            <template v-else-if="order.status === 'READY'">ออเดอร์ของคุณพร้อมรับแล้ว!</template>
          </p>
        </div>

      </div>

      <!-- Items -->
      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-50">
          <h2 class="font-semibold text-gray-800">รายการสินค้า</h2>
        </div>
        <div class="divide-y divide-gray-50">
          <div v-for="item in order.items" :key="item.id" class="px-5 py-4">
            <div class="flex justify-between items-start">
              <div>
                <p class="font-medium text-gray-800">{{ item.quantity }}x {{ item.product.name }}</p>
                <p v-if="item.options.length" class="text-xs text-gray-400 mt-0.5">
                  {{ item.options.map(o => o.name).join(', ') }}
                </p>
                <p v-if="item.note" class="text-xs text-gray-400 mt-0.5 italic">หมายเหตุ: {{ item.note }}</p>
              </div>
              <span class="text-sm font-semibold text-gray-700">฿{{ Number(item.subtotal).toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Summary -->
      <div class="bg-white rounded-2xl shadow p-5 space-y-2.5">
        <div class="flex justify-between text-sm text-gray-500">
          <span>ยอดรวม</span>
          <span>฿{{ Number(order.subtotal).toFixed(2) }}</span>
        </div>
        <div v-if="Number(order.discount) > 0" class="flex justify-between text-sm text-green-600">
          <span>ส่วนลด (แลก {{ order.pointsRedeemed }} แต้ม)</span>
          <span>-฿{{ Number(order.discount).toFixed(2) }}</span>
        </div>
        <div class="flex justify-between font-bold text-gray-900 pt-2 border-t border-gray-100">
          <span>รวมทั้งหมด</span>
          <span>฿{{ Number(order.total).toFixed(2) }}</span>
        </div>
        <div v-if="order.pointsEarned > 0" class="text-xs text-[#1B2B4B] text-right">
          +{{ order.pointsEarned }} แต้มจากออเดอร์นี้
        </div>
      </div>

      <div v-if="order.note" class="bg-white rounded-2xl shadow p-5">
        <p class="text-sm text-gray-500 font-medium mb-1">หมายเหตุ</p>
        <p class="text-gray-700">{{ order.note }}</p>
      </div>
    </template>
  </div>
</template>
