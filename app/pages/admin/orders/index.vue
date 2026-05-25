<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const { showError } = useAlert()
const http = useHttpClient()

const search = ref('')
const filterStatus = ref('all')
const dateFrom = ref('')
const dateTo = ref('')
const page = ref(1)
const limit = 20

const orders = ref<any[]>([])
const pagination = ref<any>(null)
const isLoading = ref(false)

async function load() {
  isLoading.value = true
  try {
    const params: Record<string, any> = {
      'pagination[page]': page.value,
      'pagination[limit]': limit,
    }
    if (filterStatus.value !== 'all') params['filter[status]'] = filterStatus.value
    if (dateFrom.value) params.dateFrom = dateFrom.value
    if (dateTo.value) params.dateTo = dateTo.value

    const res = await http.get<{ data: any[]; pagination: any }>(API_ENDPOINTS.ADMIN.ORDERS.LIST, params)
    orders.value = res.data ?? []
    pagination.value = res.pagination
  } catch (e: any) {
    showError(e?.message ?? 'Failed to load')
  } finally {
    isLoading.value = false
  }
}

watch([filterStatus, dateFrom, dateTo], () => { page.value = 1; load() })
watch(page, load)
onMounted(load)

const statusBadge: Record<string, string> = {
  PENDING: 'bg-yellow-100 text-yellow-700',
  PREPARING: 'bg-blue-100 text-blue-700',
  READY: 'bg-indigo-100 text-indigo-700',
  COMPLETED: 'bg-green-100 text-green-700',
  CANCELLED: 'bg-red-100 text-red-500',
}

const paymentBadge: Record<string, string> = {
  CASH: 'bg-gray-100 text-gray-600',
  CARD: 'bg-purple-100 text-purple-700',
  QR: 'bg-cyan-100 text-cyan-700',
}

function formatDate(d: string) {
  return new Date(d).toLocaleString('th-TH', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function formatPrice(n: any) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

// summary stats
const totalRevenue = computed(() =>
  orders.value.filter((o) => o.status === 'COMPLETED').reduce((s: number, o: any) => s + Number(o.total), 0),
)
const totalOrders = computed(() => pagination.value?.total ?? 0)
const completedCount = computed(() => orders.value.filter((o) => o.status === 'COMPLETED').length)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Orders</h1>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <select
        v-model="filterStatus"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="all">All Status</option>
        <option value="PENDING">Pending</option>
        <option value="PREPARING">Preparing</option>
        <option value="READY">Ready</option>
        <option value="COMPLETED">Completed</option>
        <option value="CANCELLED">Cancelled</option>
      </select>
      <input
        v-model="dateFrom"
        type="date"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <span class="self-center text-gray-400 text-sm">—</span>
      <input
        v-model="dateTo"
        type="date"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <button
        class="px-3 py-2 text-sm text-gray-500 hover:text-gray-700"
        @click="dateFrom = ''; dateTo = ''"
      >Clear dates</button>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Queue</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Date</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Items</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Member</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Status</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Payment</th>
            <th class="text-right px-4 py-3 font-medium text-gray-600">Total</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="8" class="text-center py-10 text-gray-400">Loading...</td>
          </tr>
          <tr v-else-if="orders.length === 0">
            <td colspan="8" class="text-center py-10 text-gray-400">No orders found</td>
          </tr>
          <tr
            v-for="o in orders"
            :key="o.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3 font-bold text-gray-900">#{{ o.queueNo }}</td>
            <td class="px-4 py-3 text-gray-500 text-xs whitespace-nowrap">{{ formatDate(o.createdAt) }}</td>
            <td class="px-4 py-3 text-gray-600">
              <div class="space-y-0.5">
                <p v-for="item in o.items.slice(0, 2)" :key="item.id" class="text-xs">
                  {{ item.product.name }} x{{ item.quantity }}
                </p>
                <p v-if="o.items.length > 2" class="text-xs text-gray-400">+{{ o.items.length - 2 }} more</p>
              </div>
            </td>
            <td class="px-4 py-3">
              <span v-if="o.member" class="text-xs text-blue-600 font-medium">{{ o.member.name }}</span>
              <span v-else class="text-xs text-gray-400">—</span>
            </td>
            <td class="px-4 py-3 text-center">
              <span class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[o.status]">
                {{ o.status }}
              </span>
            </td>
            <td class="px-4 py-3 text-center">
              <span v-if="o.payment" class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="paymentBadge[o.payment.method]">
                {{ o.payment.method }}
              </span>
              <span v-else class="text-xs text-gray-400">—</span>
            </td>
            <td class="px-4 py-3 text-right font-semibold text-gray-900">฿{{ formatPrice(o.total) }}</td>
            <td class="px-4 py-3 text-right">
              <NuxtLink :to="`/admin/orders/${o.id}`" class="text-blue-600 hover:text-blue-800 text-xs font-medium">
                View
              </NuxtLink>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div v-if="pagination" class="px-4 py-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
        <span>Total {{ pagination.total }} orders</span>
        <div class="flex items-center gap-2">
          <button
            class="px-2 py-1 rounded border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="page <= 1"
            @click="page--"
          >←</button>
          <span>Page {{ pagination.page }} / {{ pagination.totalPages }}</span>
          <button
            class="px-2 py-1 rounded border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="page >= pagination.totalPages"
            @click="page++"
          >→</button>
        </div>
      </div>
    </div>
  </div>
</template>
