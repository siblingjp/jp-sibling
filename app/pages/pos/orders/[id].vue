<script setup lang="ts">
definePageMeta({ layout: 'pos', middleware: 'auth' })

const route = useRoute()
const { showError, showConfirm } = useAlert()

const id = route.params.id as string
const isLoading = ref(true)
const isUpdating = ref(false)
const order = ref<any>(null)

const nextStatus: Record<string, string> = {
  PENDING: 'PREPARING',
  PREPARING: 'READY',
  READY: 'COMPLETED',
}

const nextStatusLabel: Record<string, string> = {
  PENDING: 'กำลังทำ',
  PREPARING: 'พร้อมส่ง',
  READY: 'เสร็จสิ้น',
}

const statusBadge: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  PREPARING: 'bg-blue-100 text-blue-700',
  READY: 'bg-green-100 text-green-700',
  COMPLETED: 'bg-gray-100 text-gray-500',
  CANCELLED: 'bg-red-100 text-red-500',
}

const statusLabel: Record<string, string> = {
  PENDING: 'รอดำเนินการ',
  PREPARING: 'กำลังทำ',
  READY: 'พร้อมส่ง',
  COMPLETED: 'เสร็จสิ้น',
  CANCELLED: 'ยกเลิก',
}

async function load() {
  isLoading.value = true
  try {
    const res = await useHttpClient().get<{ data: any }>(API_ENDPOINTS.POS.ORDERS.SHOW(id))
    order.value = res.data
  } catch (e: any) {
    showError(e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    isLoading.value = false
  }
}

async function updateStatus(status: string) {
  if (status === 'CANCELLED') {
    const ok = await showConfirm({ title: 'ยกเลิกออเดอร์', message: 'ต้องการยกเลิกออเดอร์นี้?', confirmText: 'ยกเลิกออเดอร์' })
    if (!ok) return
  }
  isUpdating.value = true
  try {
    await useHttpClient().patch(API_ENDPOINTS.POS.ORDERS.UPDATE(id), { status })
    await load()
  } catch (e: any) {
    showError(e?.message ?? 'อัปเดตสถานะไม่สำเร็จ')
  } finally {
    isUpdating.value = false
  }
}

async function handleNextQueue() {
  if (!order.value || !nextStatus[order.value.status]) return
  const currentStatus = order.value.status
  const toStatus = nextStatus[currentStatus]

  isUpdating.value = true
  try {
    await useHttpClient().patch(API_ENDPOINTS.POS.ORDERS.UPDATE(id), { status: toStatus })

    // find next PREPARING order (for PREPARING→READY case) or next PENDING order
    const nextFilterStatus = currentStatus === 'PENDING' ? 'PREPARING' : 'PREPARING'
    const res = await useHttpClient().get<{ data: any[] }>(`${API_ENDPOINTS.POS.ORDERS.LIST}?status=${nextFilterStatus}`)
    const nextOrders = (res.data ?? []).filter((o: any) => o.id !== id)

    if (nextOrders.length > 0) {
      await navigateTo(`/pos/orders/${nextOrders[0].id}`)
    } else {
      await navigateTo('/pos/orders')
    }
  } catch (e: any) {
    showError(e?.message ?? 'อัปเดตสถานะไม่สำเร็จ')
    isUpdating.value = false
  }
}

function formatTime(d: string) {
  return new Date(d).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' })
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: '2-digit' })
}

function formatPrice(n: number) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

onMounted(load)
</script>

<template>
  <div class="flex flex-col h-full bg-gray-50">
    <!-- Header -->
    <div class="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
      <button class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-600" @click="navigateTo('/pos/orders')">
        <Icon name="mdi:arrow-left" class="text-xl" />
      </button>
      <h1 class="text-base font-semibold text-gray-900 flex-1">รายละเอียดออเดอร์</h1>
      <button class="p-1.5 rounded-lg hover:bg-gray-100 text-gray-500" @click="load">
        <Icon name="mdi:refresh" class="text-lg" />
      </button>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="flex-1 flex items-center justify-center text-gray-400">กำลังโหลด...</div>

    <!-- Content -->
    <div v-else-if="order" class="flex-1 overflow-y-auto p-4 space-y-4 max-w-lg mx-auto w-full">

      <!-- Queue + Status -->
      <div class="bg-white rounded-2xl shadow-sm p-5">
        <div class="flex items-center justify-between mb-3">
          <div>
            <span class="text-4xl font-bold text-gray-900">#{{ order.queueNo }}</span>
            <p class="text-sm text-gray-400 mt-0.5">{{ formatDate(order.createdAt) }} {{ formatTime(order.createdAt) }}</p>
          </div>
          <span class="inline-flex px-3 py-1 rounded-full text-sm font-semibold" :class="statusBadge[order.status]">
            {{ statusLabel[order.status] ?? order.status }}
          </span>
        </div>

        <!-- Source + Pickup row -->
        <div class="flex items-center gap-3 flex-wrap">
          <span
            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
            :class="order.source === 'ONLINE' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-600'"
          >
            <Icon :name="order.source === 'ONLINE' ? 'mdi:web' : 'mdi:store'" class="text-sm" />
            {{ order.source === 'ONLINE' ? 'Online' : 'POS' }}
          </span>
          <span v-if="order.pickupTime" class="inline-flex items-center gap-1.5 text-xs text-gray-500">
            <Icon name="mdi:clock-outline" class="text-sm" />
            รับ {{ order.pickupTime }}
          </span>
        </div>
      </div>

      <!-- Member -->
      <div v-if="order.member" class="bg-white rounded-2xl shadow-sm p-4 flex items-center gap-3">
        <Icon name="flat-color-icons:businessman" class="text-2xl flex-shrink-0" />
        <div>
          <p class="text-sm font-semibold text-gray-900">{{ order.member.name }}</p>
          <p v-if="order.member.phone" class="text-xs text-gray-400">{{ order.member.phone }}</p>
        </div>
      </div>

      <!-- Items -->
      <div class="bg-white rounded-2xl shadow-sm p-4 space-y-3">
        <h2 class="text-sm font-semibold text-gray-700">รายการ</h2>
        <div v-for="item in order.items" :key="item.id" class="flex justify-between text-sm gap-2">
          <div class="flex-1">
            <p class="font-medium text-gray-800">{{ item.product.name }} <span class="text-gray-400">x{{ item.quantity }}</span></p>
            <p v-if="item.options?.length" class="text-xs text-gray-400 mt-0.5">
              {{ item.options.map((o: any) => o.name).join(', ') }}
            </p>
            <p v-if="item.note" class="text-xs text-orange-500 mt-0.5">{{ item.note }}</p>
          </div>
          <span class="text-gray-600 font-medium whitespace-nowrap">฿{{ formatPrice(item.subtotal) }}</span>
        </div>

        <!-- Note -->
        <p v-if="order.note" class="text-xs text-gray-500 bg-gray-50 px-3 py-2 rounded-lg mt-1">
          <Icon name="mdi:note-text-outline" class="inline-block align-middle mr-1" />{{ order.note }}
        </p>

        <!-- Totals -->
        <div class="border-t border-gray-100 pt-3 space-y-1.5">
          <div class="flex justify-between text-sm text-gray-500">
            <span>ยอดรวม</span><span>฿{{ formatPrice(order.subtotal) }}</span>
          </div>
          <div v-if="Number(order.discount) > 0" class="flex justify-between text-sm text-orange-500">
            <span>ส่วนลด</span><span>-฿{{ formatPrice(order.discount) }}</span>
          </div>
          <div v-if="Number(order.pointsRedeemed) > 0" class="flex justify-between text-sm text-purple-600">
            <span>แลกแต้ม {{ order.pointsRedeemed }} pts</span><span>-฿{{ formatPrice(order.pointsRedeemed) }}</span>
          </div>
          <div class="flex justify-between font-bold text-gray-900">
            <span>รวมทั้งหมด</span><span>฿{{ formatPrice(order.total) }}</span>
          </div>
        </div>
      </div>

      <!-- Payment -->
      <div v-if="order.payment" class="bg-white rounded-2xl shadow-sm p-4 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <Icon name="mdi:cash-check" class="text-xl text-green-600" />
          <span class="text-sm font-medium text-gray-700">ชำระแล้ว</span>
        </div>
        <span class="text-sm text-gray-500">
          {{ ({ CASH: 'เงินสด', QR: 'QR พร้อมเพย์', THAI_HELP: 'ไทยช่วยไทยพลัส', CARD: 'บัตร' } as Record<string,string>)[order.payment.method] ?? order.payment.method }} · ฿{{ formatPrice(order.payment.amount) }}
        </span>
      </div>

      <!-- Slip (online orders) -->
      <div v-if="order.source === 'ONLINE' && order.slipUrl" class="bg-white rounded-2xl shadow-sm p-4">
        <p class="text-xs text-gray-500 mb-2 font-medium">สลิปการโอนเงิน</p>
        <img :src="order.slipUrl" alt="slip" class="w-full rounded-xl object-contain max-h-64" />
        <a :href="order.slipUrl" target="_blank" class="mt-2 block text-center text-xs text-blue-600 hover:underline">เปิดเต็มหน้าจอ</a>
      </div>

      <!-- Actions -->
      <div v-if="nextStatus[order.status] || order.status === 'PENDING'" class="space-y-2 pb-4">
        <!-- Next Queue (primary action) -->
        <button
          v-if="nextStatus[order.status]"
          :disabled="isUpdating"
          class="w-full py-3.5 rounded-xl bg-blue-600 text-white font-semibold text-base hover:bg-blue-700 disabled:opacity-60 transition-colors flex items-center justify-center gap-2"
          @click="handleNextQueue"
        >
          <Icon name="mdi:skip-next" class="text-xl" />
          คิวถัดไป ({{ nextStatusLabel[order.status] }})
        </button>

        <!-- Update status only (without navigating away) -->
        <button
          v-if="nextStatus[order.status]"
          :disabled="isUpdating"
          class="w-full py-2.5 rounded-xl border border-blue-300 text-blue-600 font-medium text-sm hover:bg-blue-50 disabled:opacity-60 transition-colors"
          @click="updateStatus(nextStatus[order.status])"
        >
          → {{ nextStatusLabel[order.status] }} (อยู่หน้านี้)
        </button>

        <!-- Cancel -->
        <button
          v-if="order.status === 'PENDING'"
          :disabled="isUpdating"
          class="w-full py-2.5 rounded-xl border border-red-200 text-red-500 text-sm font-medium hover:bg-red-50 disabled:opacity-60 transition-colors"
          @click="updateStatus('CANCELLED')"
        >
          ยกเลิกออเดอร์
        </button>
      </div>
    </div>

    <div v-else class="flex-1 flex items-center justify-center text-gray-400 text-sm">ไม่พบออเดอร์</div>
  </div>
</template>
