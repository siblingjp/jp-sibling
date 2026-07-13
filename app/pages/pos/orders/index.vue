<script setup lang="ts">
definePageMeta({ layout: 'pos', middleware: 'auth' })

const { showError, showConfirm } = useAlert()

// ─── Daily summary ────────────────────────────────────────────────────────────
const summary = ref<{ totalOrders: number; totalCups: number; totalFoods: number } | null>(null)

async function loadSummary() {
  try {
    const res = await useHttpClient().get<{ data: { totalOrders: number; totalCups: number; totalFoods: number } }>(
      API_ENDPOINTS.ADMIN.DASHBOARD.SUMMARY,
    )
    summary.value = res.data
  } catch {
    // silent
  }
}

const statusFilter = ref<string>('ACTIVE')
const isLoading = ref(false)
const orders = ref<any[]>([])
const slipModal = ref<string | null>(null)

// ─── Payment modal (for unpaid READY→COMPLETED) ──────────────────────────────
const showPaymentModal = ref(false)
const payTargetOrder = ref<any>(null)
const payMethod = ref<'CASH' | 'QR' | 'THAI_HELP' | 'CARD'>('CASH')
const payCash = ref(0)
const payRef = ref('')
const isSavingPayment = ref(false)

const methodLabel: Record<string, string> = {
  CASH: 'เงินสด', QR: 'QR พร้อมเพย์', THAI_HELP: 'โครงการรัฐ', CARD: 'บัตร',
}

const orderTotal = computed(() => Number(payTargetOrder.value?.total ?? 0))
const payChange = computed(() => payMethod.value === 'CASH' ? Math.max(0, payCash.value - orderTotal.value) : 0)
const payValid = computed(() => payMethod.value === 'CASH' ? payCash.value >= orderTotal.value : true)
const quickAmounts = computed(() => {
  const t = orderTotal.value
  return [...new Set([Math.ceil(t / 10) * 10, Math.ceil(t / 20) * 20, Math.ceil(t / 50) * 50, Math.ceil(t / 100) * 100])]
    .filter(v => v >= t).slice(0, 4)
})

function openPaymentForOrder(order: any) {
  payTargetOrder.value = order
  payCash.value = orderTotal.value
  payRef.value = ''
  payMethod.value = 'CASH'
  showPaymentModal.value = true
}

async function savePaymentAndComplete() {
  if (!payValid.value || !payTargetOrder.value) return
  isSavingPayment.value = true
  try {
    const amount = payMethod.value === 'CASH' ? payCash.value : orderTotal.value
    await useHttpClient().post(API_ENDPOINTS.POS.PAYMENTS.CREATE, {
      orderId: payTargetOrder.value.id,
      method: payMethod.value,
      amount,
      transactionRef: payRef.value || undefined,
    })
    await useHttpClient().patch(API_ENDPOINTS.POS.ORDERS.UPDATE(payTargetOrder.value.id), { status: 'COMPLETED' })
    showPaymentModal.value = false
    payTargetOrder.value = null
    await load()
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'บันทึกไม่สำเร็จ')
  } finally {
    isSavingPayment.value = false
  }
}

const statusOptions = [
  { value: 'ACTIVE', label: 'ที่ต้องทำ' },
  { value: 'READY', label: 'พร้อมส่ง' },
  { value: 'COMPLETED', label: 'เสร็จสิ้น' },
  { value: 'OVERDUE', label: 'ตกค้าง' },
  { value: 'SUMMARY', label: 'สรุป' },
]

async function load() {
  if (statusFilter.value === 'SUMMARY') { await loadSummary(); return }
  isLoading.value = true
  try {
    const q = statusFilter.value === 'ACTIVE'
      ? ''
      : statusFilter.value === 'OVERDUE'
        ? '?status=PENDING&status=PREPARING&allDays=true'
        : `?status=${statusFilter.value}`
    const res = await useHttpClient().get<{ data: any[] }>(`${API_ENDPOINTS.POS.ORDERS.LIST}${q}`)
    orders.value = res.data ?? []
  } catch (e: any) {
    showError(e?.message ?? 'Failed to load orders')
  } finally {
    isLoading.value = false
  }
}

const acknowledgingId = ref<string | null>(null)

async function acknowledge(order: any) {
  acknowledgingId.value = order.id
  try {
    await useHttpClient().post(API_ENDPOINTS.POS.ORDERS.ACKNOWLEDGE(order.id))
    await load()
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'ไม่สำเร็จ')
  } finally {
    acknowledgingId.value = null
  }
}

async function updateStatus(order: any, status: string) {
  if (status === 'CANCELLED') {
    const ok = await showConfirm({ title: 'ยกเลิกออเดอร์', message: 'ต้องการยกเลิกออเดอร์นี้?', confirmText: 'ยกเลิกออเดอร์' })
    if (!ok) return
  }
  if (status === 'COMPLETED' && !order.payment) {
    openPaymentForOrder(order)
    return
  }
  try {
    await useHttpClient().patch(API_ENDPOINTS.POS.ORDERS.UPDATE(order.id), { status })
    await load()
  } catch (e: any) {
    showError(e?.message ?? 'Failed to update')
  }
}

const posStore = usePosStore()
const isEditingOrder = ref<string | null>(null)

async function editOrder(order: any) {
  isEditingOrder.value = order.id
  try {
    // load products ถ้ายังไม่มี
    if (posStore.products.length === 0) await posStore.fetchProducts()
    await posStore.loadOrderForEdit(order)
    await navigateTo('/pos')
  } catch (e: any) {
    showError(e?.message ?? 'ไม่สามารถแก้ไขออเดอร์ได้')
  } finally {
    isEditingOrder.value = null
  }
}

watch(statusFilter, load)
onMounted(load)

// auto refresh
const STORAGE_KEY = 'pos:autoRefresh'
const autoRefresh = ref(true)
const refreshInterval = 30
const countdown = ref(refreshInterval)
let interval: ReturnType<typeof setInterval>
let countdownInterval: ReturnType<typeof setInterval>

function startAutoRefresh() {
  countdown.value = refreshInterval
  interval = setInterval(() => { load(); countdown.value = refreshInterval }, refreshInterval * 1000)
  countdownInterval = setInterval(() => { if (countdown.value > 0) countdown.value-- }, 1000)
}

function stopAutoRefresh() {
  clearInterval(interval)
  clearInterval(countdownInterval)
}

function toggleAutoRefresh() {
  autoRefresh.value = !autoRefresh.value
  localStorage.setItem(STORAGE_KEY, String(autoRefresh.value))
  if (autoRefresh.value) startAutoRefresh()
  else stopAutoRefresh()
}

onMounted(() => {
  autoRefresh.value = localStorage.getItem(STORAGE_KEY) !== 'false'
  if (autoRefresh.value) startAutoRefresh()
})
onUnmounted(stopAutoRefresh)

const nextStatus: Record<string, string> = {
  PENDING: 'PREPARING',
  PREPARING: 'READY',
  READY: 'COMPLETED',
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

function formatTime(d: string) {
  const date = new Date(d)
  const todayBKK = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Bangkok' }).format(new Date())
  const dateBKK = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Bangkok' }).format(date)
  const time = date.toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit', timeZone: 'Asia/Bangkok' })
  if (dateBKK !== todayBKK) {
    const dateLabel = date.toLocaleDateString('th-TH', { day: 'numeric', month: 'short', timeZone: 'Asia/Bangkok' })
    return `${dateLabel} ${time}`
  }
  return time
}

function formatPrice(n: number) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

function formatPickupTime(pt: string | null | undefined): string {
  if (!pt) return '-'
  const TZ = 'Asia/Bangkok'
  // format ใหม่: "YYYY-MM-DD HH:MM"
  if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(pt)) {
    const [datePart, timePart] = pt.split(' ')
    const d = new Date(`${datePart}T${timePart}:00+07:00`)
    const todayDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(new Date())
    const dateLabel = new Intl.DateTimeFormat('th-TH', { day: 'numeric', month: 'short', timeZone: TZ }).format(d)
    return datePart !== todayDate ? `${dateLabel} ${timePart} น.` : `${timePart} น.`
  }
  // format เก่า: "HH:MM"
  return `${pt} น.`
}
</script>

<template>
  <div class="flex flex-col h-full bg-gray-50">
    <!-- Header -->
    <div class="bg-white border-b border-gray-200 px-3 md:px-6 py-3 flex flex-col gap-2">
      <!-- Row 1: title + refresh -->
      <div class="flex items-center justify-between gap-2">
        <h1 class="text-base font-semibold text-gray-900 flex-shrink-0">คิวออเดอร์</h1>
        <div class="flex items-center gap-2">
          <button class="p-1.5 md:px-3 md:py-1.5 bg-blue-600 text-white text-xs font-medium rounded-lg hover:bg-blue-700 flex items-center gap-1.5" @click="load">
            <Icon name="mdi:refresh" class="text-base" />
            <span class="hidden md:inline">รีเฟรช</span>
          </button>
          <button
            class="p-1.5 md:px-3 md:py-1.5 rounded-lg text-xs font-medium flex items-center gap-1.5 transition-colors"
            :class="autoRefresh ? 'bg-green-100 text-green-700 hover:bg-green-200' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'"
            @click="toggleAutoRefresh"
          >
            <Icon :name="autoRefresh ? 'mdi:autorenew' : 'mdi:autorenew-off'" class="text-base" />
            <span class="hidden sm:inline">{{ autoRefresh ? `auto (${countdown}s)` : 'auto: ปิด' }}</span>
          </button>
        </div>
      </div>
      <!-- Row 2: status filter -->
      <div class="flex gap-1 bg-gray-100 p-1 rounded-lg w-full overflow-x-auto">
        <button
          v-for="opt in statusOptions"
          :key="opt.value"
          class="px-2 md:px-3 py-1.5 rounded-md text-xs font-medium transition-colors whitespace-nowrap"
          :class="statusFilter === opt.value ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'"
          @click="statusFilter = opt.value"
        >{{ opt.label }}</button>
      </div>
    </div>

    <!-- Orders Grid -->
    <div class="flex-1 overflow-y-auto p-6">
      <!-- Summary view -->
      <template v-if="statusFilter === 'SUMMARY'">
        <div v-if="isLoading" class="text-center py-16 text-gray-400">กำลังโหลด...</div>
        <div v-else-if="summary" class="grid grid-cols-2 sm:grid-cols-3 gap-4">
          <div class="bg-white rounded-xl shadow-sm p-5">
            <p class="text-xs text-gray-500 mb-1">ออเดอร์ทั้งหมด</p>
            <p class="text-3xl font-bold text-gray-900">{{ summary.totalOrders }}</p>
          </div>
          <div class="bg-white rounded-xl shadow-sm p-5">
            <p class="text-xs text-gray-500 mb-1">แก้วทั้งหมด</p>
            <p class="text-3xl font-bold text-gray-900">{{ summary.totalCups }} <span class="text-lg font-medium text-gray-400">แก้ว</span></p>
          </div>
          <div v-if="summary.totalFoods > 0" class="bg-white rounded-xl shadow-sm p-5">
            <p class="text-xs text-gray-500 mb-1">อาหารทั้งหมด</p>
            <p class="text-3xl font-bold text-gray-900">{{ summary.totalFoods }} <span class="text-lg font-medium text-gray-400">รายการ</span></p>
          </div>
        </div>
      </template>

      <template v-else>
        <div v-if="isLoading" class="text-center py-16 text-gray-400">กำลังโหลด...</div>
        <div v-else-if="orders.length === 0" class="text-center py-16 text-gray-400 text-sm">ยังไม่มีออเดอร์</div>
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div
          v-for="order in orders"
          :key="order.id"
          class="bg-white rounded-xl shadow-sm p-4 space-y-3 cursor-pointer hover:shadow-md transition-shadow"
          @click="navigateTo(`/pos/orders/${order.id}`)"
        >
          <!-- Queue No & Status -->
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span class="text-2xl font-bold text-gray-900">#{{ order.queueNo }}</span>
              <span class="text-xs text-gray-400">{{ formatTime(order.createdAt) }}</span>
            </div>
            <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[order.status]">
              {{ statusLabel[order.status] ?? order.status }}
            </span>
          </div>

          <!-- Source badge -->
          <div class="flex items-center gap-1.5 flex-wrap">
            <span v-if="order.source === 'ONLINE'" class="text-xs px-1.5 py-0.5 rounded-full bg-purple-100 text-purple-700 font-medium">ออนไลน์</span>
            <span v-else-if="order.source === 'WEBAPP'" class="text-xs px-1.5 py-0.5 rounded-full bg-teal-100 text-teal-700 font-medium">🌐 Web</span>
          </div>

          <!-- Member / Guest name -->
          <div v-if="order.member" class="text-xs text-blue-600 font-medium">
            <Icon name="flat-color-icons:businessman" class="inline-block align-middle" /> {{ order.member.name }}
          </div>
          <div v-else-if="order.guestName" class="text-xs text-teal-600 font-medium">
            <Icon name="mdi:account-outline" class="inline-block align-middle" /> {{ order.guestName }}
          </div>

          <!-- Items -->
          <div class="space-y-1.5">
            <div v-for="item in order.items" :key="item.id" class="text-sm">
              <div class="flex justify-between">
                <span class="font-medium text-gray-800">{{ item.product.name }} x{{ item.quantity }}</span>
                <span class="text-gray-500">฿{{ formatPrice(item.subtotal) }}</span>
              </div>
              <p v-if="item.options.length" class="text-xs text-gray-400 pl-2">
                {{ item.options.map((o: any) => o.name).join(', ') }}
              </p>
              <p v-if="item.note" class="text-xs text-orange-500 pl-2">{{ item.note }}</p>
            </div>
          </div>

          <!-- Pickup time (all orders) -->
          <div v-if="order.pickupTime" class="flex items-center gap-1 text-xs text-indigo-600 font-medium">
            <Icon name="mdi:clock-outline" class="text-sm flex-shrink-0" />
            รับ {{ formatPickupTime(order.pickupTime) }}
          </div>

          <!-- Note -->
          <p v-if="order.note" class="text-xs text-gray-500 bg-gray-50 px-2 py-1 rounded">{{ order.note }}</p>

          <!-- Total + Payment -->
          <div class="flex justify-between text-sm border-t border-gray-100 pt-2">
            <span class="text-gray-500">รวม</span>
            <div class="text-right">
              <span class="font-bold text-gray-900">฿{{ formatPrice(order.total) }}</span>
              <span v-if="order.payment" class="ml-2 text-xs px-1.5 py-0.5 rounded-full bg-green-100 text-green-700 font-medium">
                {{ ({ CASH: 'เงินสด', QR: 'QR', THAI_HELP: 'โครงการรัฐ', CARD: 'บัตร' } as Record<string,string>)[order.payment.method] ?? order.payment.method }}
              </span>
              <span v-else-if="order.status !== 'CANCELLED' && order.source === 'POS'" class="ml-2 text-xs px-1.5 py-0.5 rounded-full bg-orange-100 text-orange-600 font-medium">ค้างชำระ</span>
              <span v-else-if="order.source === 'ONLINE'" class="ml-2 text-xs px-1.5 py-0.5 rounded-full bg-purple-100 text-purple-700 font-medium">QR</span>
              <span v-else-if="order.source === 'WEBAPP'" class="ml-2 text-xs px-1.5 py-0.5 rounded-full bg-teal-100 text-teal-700 font-medium">{{ ({ CASH: 'เงินสด', QR: 'QR', THAI_HELP: 'โครงการรัฐ', CARD: 'บัตร' } as Record<string,string>)[order.payment?.method] ?? 'รอชำระ' }}</span>
            </div>
          </div>

          <!-- Pickup time & slip (ONLINE) -->
          <div v-if="order.source === 'ONLINE'" class="text-xs text-gray-500 bg-gray-50 rounded-lg px-3 py-2 space-y-1.5">
            <div class="flex items-center justify-between">
              <span v-if="order.acknowledgedAt" class="text-green-600 font-medium flex items-center gap-1">
                <Icon name="mdi:check-circle" class="w-3.5 h-3.5" />รับทราบแล้ว
              </span>
            </div>
            <div v-if="order.slipUrls?.length" class="flex gap-1.5 flex-wrap">
              <button
                v-for="(url, i) in order.slipUrls"
                :key="i"
                class="flex items-center gap-1 text-blue-600 font-medium hover:text-blue-800"
                @click.stop="slipModal = url"
              >
                <Icon name="mdi:receipt" class="w-3.5 h-3.5" />
                สลิป{{ order.slipUrls.length > 1 ? ` ${i + 1}` : '' }}
              </button>
            </div>
            <button
              v-else-if="order.slipUrl"
              class="flex items-center gap-1 text-blue-600 font-medium hover:text-blue-800"
              @click.stop="slipModal = order.slipUrl"
            >
              <Icon name="mdi:receipt" class="w-3.5 h-3.5" />ดูสลิป
            </button>
          </div>

          <!-- Actions -->
          <div class="flex gap-2 flex-wrap" @click.stop>
            <!-- ONLINE / WEBAPP PENDING: ปุ่ม กำลังทำ + รับทราบ -->
            <template v-if="(order.source === 'ONLINE' || order.source === 'WEBAPP') && order.status === 'PENDING'">
              <button
                class="flex-1 py-2 rounded-lg bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 transition-colors"
                @click="updateStatus(order, 'PREPARING')"
              >→ กำลังทำ</button>
              <button
                v-if="!order.acknowledgedAt"
                :disabled="acknowledgingId === order.id"
                class="flex-1 py-2 rounded-lg bg-amber-100 text-amber-700 text-sm font-medium hover:bg-amber-200 transition-colors disabled:opacity-50"
                @click="acknowledge(order)"
              >{{ acknowledgingId === order.id ? '...' : 'รับทราบ' }}</button>
            </template>

            <!-- PREPARING: พร้อมส่ง + เสร็จสิ้น -->
            <template v-else-if="order.status === 'PREPARING'">
              <button
                class="flex-1 py-2 rounded-lg bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 transition-colors"
                @click="updateStatus(order, 'READY')"
              >พร้อมส่ง</button>
              <button
                class="flex-1 py-2 rounded-lg bg-green-600 text-white text-sm font-medium hover:bg-green-700 transition-colors"
                @click="updateStatus(order, 'COMPLETED')"
              >เสร็จสิ้น</button>
            </template>

            <!-- อื่นๆ: ปุ่มเดียว next status -->
            <template v-else>
              <button
                v-if="nextStatus[order.status]"
                class="flex-1 py-2 rounded-lg bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 transition-colors"
                @click="updateStatus(order, nextStatus[order.status])"
              >
                → {{ { PENDING: 'กำลังทำ', READY: 'เสร็จสิ้น' }[order.status] || nextStatus[order.status] }}
              </button>
            </template>

            <!-- แก้ไขเมนู (PENDING / PREPARING) -->
            <button
              v-if="order.status === 'PENDING' || order.status === 'PREPARING'"
              :disabled="isEditingOrder === order.id"
              class="px-3 py-2 rounded-lg border border-gray-300 text-gray-600 text-sm hover:bg-gray-50 transition-colors disabled:opacity-50"
              @click="editOrder(order)"
            >{{ isEditingOrder === order.id ? '...' : '✏️ แก้ไขเมนู' }}</button>

            <button
              v-if="order.status === 'PENDING'"
              class="px-3 py-2 rounded-lg border border-red-200 text-red-500 text-sm hover:bg-red-50 transition-colors"
              @click="updateStatus(order, 'CANCELLED')"
            >ยกเลิก</button>
          </div>
        </div>
      </div>
      </template>
    </div>
  </div>

  <!-- Slip preview modal -->
  <Teleport to="body">
    <div v-if="slipModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4" @click.self="slipModal = null">
      <div class="bg-white rounded-2xl shadow-2xl max-w-sm w-full overflow-hidden">
        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100">
          <p class="font-semibold text-gray-800">สลิปการโอนเงิน</p>
          <button class="text-gray-400 hover:text-gray-600 text-2xl leading-none" @click="slipModal = null">×</button>
        </div>
        <div class="p-4">
          <img :src="slipModal" alt="slip" class="w-full rounded-xl object-contain max-h-[70vh]" />
        </div>
        <div class="px-4 pb-4">
          <a
            :href="slipModal"
            target="_blank"
            class="block w-full text-center py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200"
          >เปิดในแท็บใหม่</a>
        </div>
      </div>
    </div>
  </Teleport>

  <!-- Payment modal (unpaid READY→COMPLETED) -->
  <Teleport to="body">
    <div v-if="showPaymentModal" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="showPaymentModal = false; payTargetOrder = null" />
      <div class="relative bg-white w-full max-w-sm rounded-2xl shadow-xl p-6 space-y-5">
        <h2 class="text-lg font-semibold text-gray-900 text-center">ชำระเงินก่อนเสร็จสิ้น</h2>

        <div class="bg-gray-50 rounded-xl py-4 text-center">
          <p class="text-xs text-gray-500 mb-1">ยอดรวม #{{ payTargetOrder?.queueNo }}</p>
          <p class="text-3xl font-bold text-gray-900">฿{{ orderTotal.toFixed(2) }}</p>
        </div>

        <div class="grid grid-cols-2 gap-2">
          <button
            v-for="m in (['CASH', 'QR', 'THAI_HELP', 'CARD'] as const)"
            :key="m"
            type="button"
            class="py-2.5 rounded-lg border text-sm font-medium transition-colors"
            :class="payMethod === m ? 'border-blue-500 bg-blue-50 text-blue-700' : 'border-gray-200 text-gray-600 hover:bg-gray-50'"
            @click="payMethod = m"
          >{{ methodLabel[m] }}</button>
        </div>

        <div v-if="payMethod === 'CASH'" class="space-y-3">
          <div>
            <label class="block text-xs text-gray-500 mb-1">รับเงิน</label>
            <input
              v-model.number="payCash"
              type="number" min="0" step="1"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-center text-lg font-semibold focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div class="flex gap-2">
            <button
              v-for="amt in quickAmounts" :key="amt" type="button"
              class="flex-1 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-sm font-medium transition-colors"
              @click="payCash = amt"
            >฿{{ amt }}</button>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">ทอน</span>
            <span class="font-semibold text-green-600">฿{{ payChange.toFixed(2) }}</span>
          </div>
        </div>

        <div v-else>
          <label class="block text-xs text-gray-500 mb-1">เลขอ้างอิง (ไม่บังคับ)</label>
          <input
            v-model="payRef"
            type="text" placeholder="Transaction ID / Ref no."
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="flex gap-3">
          <button
            type="button"
            class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50"
            @click="showPaymentModal = false; payTargetOrder = null"
          >ยกเลิก</button>
          <button
            type="button"
            class="flex-1 py-2.5 rounded-xl font-semibold text-white transition-colors"
            :class="payValid && !isSavingPayment ? 'bg-green-600 hover:bg-green-700' : 'bg-gray-300 cursor-not-allowed'"
            :disabled="!payValid || isSavingPayment"
            @click="savePaymentAndComplete"
          >{{ isSavingPayment ? 'กำลังบันทึก...' : 'ยืนยัน' }}</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
