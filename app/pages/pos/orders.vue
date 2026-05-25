<script setup lang="ts">
definePageMeta({ layout: 'pos', middleware: 'auth' })

const { showError, showConfirm } = useAlert()

const statusFilter = ref<string>('ACTIVE')
const isLoading = ref(false)
const orders = ref<any[]>([])

const statusOptions = [
  { value: 'ACTIVE', label: 'Active' },
  { value: 'PREPARING', label: 'Preparing' },
  { value: 'READY', label: 'Ready' },
  { value: 'COMPLETED', label: 'Completed' },
]

async function load() {
  isLoading.value = true
  try {
    const q = statusFilter.value === 'ACTIVE' ? '' : `?status=${statusFilter.value}`
    const res = await useHttpClient().get<{ data: any[] }>(`${API_ENDPOINTS.POS.ORDERS.LIST}${q}`)
    orders.value = res.data ?? []
  } catch (e: any) {
    showError(e?.message ?? 'Failed to load orders')
  } finally {
    isLoading.value = false
  }
}

async function updateStatus(id: string, status: string) {
  if (status === 'CANCELLED') {
    const ok = await showConfirm({ title: 'Cancel Order', message: 'Cancel this order?', confirmText: 'Cancel Order' })
    if (!ok) return
  }
  try {
    await useHttpClient().patch(API_ENDPOINTS.POS.ORDERS.UPDATE(id), { status })
    await load()
  } catch (e: any) {
    showError(e?.message ?? 'Failed to update')
  }
}

watch(statusFilter, load)
onMounted(load)

// auto refresh ทุก 30 วินาที
let interval: ReturnType<typeof setInterval>
onMounted(() => { interval = setInterval(load, 30000) })
onUnmounted(() => clearInterval(interval))

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

function formatTime(d: string) {
  return new Date(d).toLocaleTimeString('th-TH', { hour: '2-digit', minute: '2-digit' })
}

function formatPrice(n: number) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}
</script>

<template>
  <div class="flex flex-col h-full bg-gray-50">
    <!-- Header -->
    <div class="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between gap-4">
      <h1 class="text-lg font-semibold text-gray-900">Order Queue</h1>
      <div class="flex items-center gap-3">
        <div class="flex gap-1 bg-gray-100 p-1 rounded-lg">
          <button
            v-for="opt in statusOptions"
            :key="opt.value"
            class="px-3 py-1.5 rounded-md text-xs font-medium transition-colors"
            :class="statusFilter === opt.value ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'"
            @click="statusFilter = opt.value"
          >{{ opt.label }}</button>
        </div>
        <button class="px-3 py-1.5 bg-blue-600 text-white text-xs font-medium rounded-lg hover:bg-blue-700" @click="load">
          Refresh
        </button>
      </div>
    </div>

    <!-- Orders Grid -->
    <div class="flex-1 overflow-y-auto p-6">
      <div v-if="isLoading" class="text-center py-16 text-gray-400">Loading...</div>
      <div v-else-if="orders.length === 0" class="text-center py-16 text-gray-400 text-sm">No orders</div>
      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div
          v-for="order in orders"
          :key="order.id"
          class="bg-white rounded-xl shadow-sm p-4 space-y-3"
        >
          <!-- Queue No & Status -->
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <span class="text-2xl font-bold text-gray-900">#{{ order.queueNo }}</span>
              <span class="text-xs text-gray-400">{{ formatTime(order.createdAt) }}</span>
            </div>
            <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[order.status]">
              {{ order.status }}
            </span>
          </div>

          <!-- Member -->
          <div v-if="order.member" class="text-xs text-blue-600 font-medium">
            👤 {{ order.member.name }}
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

          <!-- Note -->
          <p v-if="order.note" class="text-xs text-gray-500 bg-gray-50 px-2 py-1 rounded">{{ order.note }}</p>

          <!-- Total -->
          <div class="flex justify-between text-sm border-t border-gray-100 pt-2">
            <span class="text-gray-500">Total</span>
            <span class="font-bold text-gray-900">฿{{ formatPrice(order.total) }}</span>
          </div>

          <!-- Actions -->
          <div class="flex gap-2">
            <button
              v-if="nextStatus[order.status]"
              class="flex-1 py-2 rounded-lg bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 transition-colors"
              @click="updateStatus(order.id, nextStatus[order.status])"
            >
              → {{ nextStatus[order.status] }}
            </button>
            <button
              v-if="order.status === 'PENDING'"
              class="px-3 py-2 rounded-lg border border-red-200 text-red-500 text-sm hover:bg-red-50 transition-colors"
              @click="updateStatus(order.id, 'CANCELLED')"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
