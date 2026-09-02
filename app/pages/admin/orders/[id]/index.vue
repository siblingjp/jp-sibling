<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string
const http = useHttpClient()
const { showSuccess, showError } = useAlert()

const { data, error } = await useAsyncData(`admin-order-${id}`, () =>
  http.get<{ data: any }>(API_ENDPOINTS.ADMIN.ORDERS.SHOW(id)),
)

if (error.value) {
  showError('Order not found')
  await navigateTo('/admin/orders')
}

const order = ref<any>(data.value?.data ?? null)

const statusBadge: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  PREPARING: 'bg-blue-100 text-blue-700',
  READY: 'bg-indigo-100 text-indigo-700',
  COMPLETED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-500',
}

const statusLabel: Record<string, string> = {
  PENDING: 'รอดำเนินการ',
  PREPARING: 'กำลังเตรียม',
  READY: 'พร้อมรับ',
  COMPLETED: 'เสร็จสิ้น',
  CANCELLED: 'ยกเลิก',
}

const tierColor: Record<string, string> = {
  SILVER: 'bg-gray-100 text-gray-600',
  GOLD: 'bg-yellow-100 text-yellow-700',
  VIP: 'bg-purple-100 text-purple-700',
}

function formatDate(d: string) {
  return new Date(d).toLocaleString('th-TH', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function formatPrice(n: any) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

const isFinalized = computed(() =>
  order.value?.status === 'COMPLETED' || order.value?.status === 'CANCELLED',
)

const nextStatuses = computed(() => {
  if (!order.value || isFinalized.value) return []
  const s = order.value.status
  const all = ['PENDING', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED']
  return all.filter(x => x !== s && x !== 'RESERVED')
})

const updatingStatus = ref(false)

async function updateStatus(status: string) {
  if (!order.value) return
  updatingStatus.value = true
  try {
    await http.patch(API_ENDPOINTS.ADMIN.ORDERS.UPDATE_STATUS(order.value.id), { status })
    order.value.status = status
    showSuccess(`เปลี่ยนสถานะเป็น "${statusLabel[status]}" แล้ว`)
  } catch (e: any) {
    showError(e?.message ?? 'เปลี่ยนสถานะไม่สำเร็จ')
  } finally {
    updatingStatus.value = false
  }
}
</script>

<template>
  <div v-if="order" class="max-w-3xl">
    <!-- Back + Header -->
    <div class="flex items-center justify-between gap-3 mb-6 flex-wrap">
      <div class="flex items-center gap-3">
        <NuxtLink to="/admin/orders" class="text-gray-400 hover:text-gray-600">← กลับ</NuxtLink>
        <h1 class="text-2xl font-bold text-gray-900">ออเดอร์ #{{ order.queueNo }}</h1>
        <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[order.status]">
          {{ statusLabel[order.status] ?? order.status }}
        </span>
      </div>

      <!-- Status actions -->
      <div v-if="!isFinalized" class="flex items-center gap-2 flex-wrap">
        <button
          v-for="s in nextStatuses"
          :key="s"
          :disabled="updatingStatus"
          class="px-3 py-1.5 text-sm font-medium rounded-lg border transition-colors disabled:opacity-50"
          :class="{
            'border-blue-300 text-blue-700 hover:bg-blue-50': s === 'PREPARING',
            'border-indigo-300 text-indigo-700 hover:bg-indigo-50': s === 'READY',
            'border-green-300 text-green-700 hover:bg-green-50': s === 'COMPLETED',
            'border-red-300 text-red-600 hover:bg-red-50': s === 'CANCELLED',
            'border-gray-300 text-gray-600 hover:bg-gray-50': s === 'PENDING',
          }"
          @click="updateStatus(s)"
        >
          <span v-if="updatingStatus" class="mr-1">...</span>
          {{ statusLabel[s] }}
        </button>
      </div>
      <span v-else class="text-sm text-gray-400">สถานะสุดท้ายแล้ว</span>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Order Info -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Items -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-4">รายการสินค้า</h2>
          <div class="space-y-3">
            <div
              v-for="item in order.items"
              :key="item.id"
              class="flex justify-between gap-3 py-2 border-b border-gray-100 last:border-0"
            >
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">
                  {{ item.product.name }}
                  <span class="text-gray-400 font-normal">x{{ item.quantity }}</span>
                </p>
                <p v-if="item.options.length" class="text-xs text-gray-400 mt-0.5">
                  {{ item.options.map((o: any) => o.name).join(', ') }}
                </p>
                <p v-if="item.note" class="text-xs text-orange-500 mt-0.5">{{ item.note }}</p>
              </div>
              <p class="text-sm font-semibold text-gray-900 whitespace-nowrap">฿{{ formatPrice(item.subtotal) }}</p>
            </div>
          </div>

          <!-- Totals -->
          <div class="mt-4 pt-4 border-t border-gray-100 space-y-1.5 text-sm">
            <div class="flex justify-between text-gray-500">
              <span>ยอดก่อนหักส่วนลด</span><span>฿{{ formatPrice(order.subtotal) }}</span>
            </div>
            <div v-if="Number(order.discount) > 0" class="flex justify-between text-orange-500">
              <span>
                ส่วนลด
                <span v-if="order.discountBadge" class="text-xs">({{ order.discountBadge.name }})</span>
                <span v-else-if="order.discountKind" class="text-xs">
                  ({{ order.discountKind === 'PERCENT' ? `${order.discountValue}%` : `฿${order.discountValue}` }})
                </span>
              </span>
              <span>-฿{{ formatPrice(order.discount) }}</span>
            </div>
            <div v-if="order.pointsRedeemed > 0" class="flex justify-between text-purple-600">
              <span>แลกแต้ม ({{ order.pointsRedeemed }} pts)</span>
              <span>-฿{{ formatPrice(order.pointsRedeemed) }}</span>
            </div>
            <div class="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-100">
              <span>ยอดรวม</span><span>฿{{ formatPrice(order.total) }}</span>
            </div>
          </div>
        </div>

        <!-- Note -->
        <div v-if="order.note" class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-2">หมายเหตุ</h2>
          <p class="text-sm text-gray-600">{{ order.note }}</p>
        </div>
      </div>

      <!-- Side Info -->
      <div class="space-y-6">
        <!-- Payment -->
        <div class="bg-white rounded-xl shadow-sm p-6 space-y-2">
          <h2 class="font-semibold text-gray-900 mb-3">การชำระเงิน</h2>
          <div v-if="order.payment" class="text-sm space-y-2">
            <div class="flex justify-between">
              <span class="text-gray-500">วิธีชำระ</span>
              <span class="font-medium text-gray-900">{{ ({ CASH: 'เงินสด', QR: 'QR พร้อมเพย์', THAI_HELP: 'โครงการรัฐ', CARD: 'บัตร', UNSPECIFIED: 'ไม่ระบุ' } as Record<string,string>)[order.payment.method] ?? order.payment.method }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">จำนวนเงิน</span>
              <span class="font-medium text-gray-900">฿{{ formatPrice(order.payment.amount) }}</span>
            </div>
            <div v-if="Number(order.payment.change) > 0" class="flex justify-between">
              <span class="text-gray-500">เงินทอน</span>
              <span class="font-medium text-green-600">฿{{ formatPrice(order.payment.change) }}</span>
            </div>
            <div v-if="order.payment.transactionRef" class="flex justify-between">
              <span class="text-gray-500">อ้างอิง</span>
              <span class="font-mono text-xs text-gray-600">{{ order.payment.transactionRef }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">เวลาชำระ</span>
              <span class="text-xs text-gray-600">{{ formatDate(order.payment.paidAt) }}</span>
            </div>
          </div>
          <p v-else class="text-sm text-gray-400">ยังไม่ได้ชำระเงิน</p>
        </div>

        <!-- Member -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-3">สมาชิก</h2>
          <div v-if="order.member" class="text-sm space-y-2">
            <div class="flex items-center gap-2">
              <span class="font-medium text-gray-900">{{ order.member.name }}</span>
              <span class="text-xs px-1.5 py-0.5 rounded-full font-medium" :class="tierColor[order.member.tier]">
                {{ order.member.tier }}
              </span>
            </div>
            <p v-if="order.member.phone" class="text-gray-500">{{ order.member.phone }}</p>
            <p v-if="order.member.email" class="text-gray-500 text-xs">{{ order.member.email }}</p>
            <div v-if="order.pointsEarned > 0" class="flex justify-between pt-1 border-t border-gray-100">
              <span class="text-gray-500">แต้มที่ได้รับ</span>
              <span class="font-medium text-green-600">+{{ order.pointsEarned }}</span>
            </div>
            <div v-if="order.pointsRedeemed > 0" class="flex justify-between">
              <span class="text-gray-500">แต้มที่ใช้</span>
              <span class="font-medium text-purple-600">-{{ order.pointsRedeemed }}</span>
            </div>
            <NuxtLink
              :to="`/admin/members/${order.member.id}`"
              class="block text-xs text-blue-600 hover:underline pt-1"
            >ดูโปรไฟล์สมาชิก →</NuxtLink>
          </div>
          <p v-else class="text-sm text-gray-400">ไม่มีสมาชิกที่เชื่อมโยง</p>
        </div>

        <!-- Cashier -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="font-semibold text-gray-900 mb-3">ข้อมูลเพิ่มเติม</h2>
          <div class="text-sm space-y-2">
            <div class="flex justify-between">
              <span class="text-gray-500">แคชเชียร์</span>
              <span class="text-gray-900">{{ order.user?.name ?? '—' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-500">วันที่สร้าง</span>
              <span class="text-xs text-gray-600">{{ formatDate(order.createdAt) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
