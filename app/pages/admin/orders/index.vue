<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const { showSuccess, showError } = useAlert()
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

const statusLabel: Record<string, string> = {
  PENDING: 'รอดำเนินการ',
  PREPARING: 'กำลังเตรียม',
  READY: 'พร้อมรับ',
  COMPLETED: 'เสร็จสิ้น',
  CANCELLED: 'ยกเลิก',
}

const paymentBadge: Record<string, string> = {
  CASH: 'bg-gray-100 text-gray-600',
  CARD: 'bg-purple-100 text-purple-700',
  QR: 'bg-cyan-100 text-cyan-700',
  THAI_HELP: 'bg-orange-100 text-orange-700',
}

const paymentLabel: Record<string, string> = {
  CASH: 'เงินสด',
  CARD: 'บัตร',
  QR: 'QR พร้อมเพย์',
  THAI_HELP: 'ไทยช่วยไทยพลัส',
}

function formatDate(d: string) {
  return new Date(d).toLocaleString('th-TH', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function formatPrice(n: any) {
  return Number(n).toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

const totalOrders = computed(() => pagination.value?.total ?? 0)

const updatingId = ref<string | null>(null)

async function updateStatus(orderId: string, status: string) {
  updatingId.value = orderId
  try {
    await http.patch(API_ENDPOINTS.ADMIN.ORDERS.UPDATE_STATUS(orderId), { status })
    const o = orders.value.find(x => x.id === orderId)
    if (o) o.status = status
    showSuccess(`เปลี่ยนสถานะเป็น "${statusLabel[status]}" แล้ว`)
  } catch (e: any) {
    showError(e?.message ?? 'เปลี่ยนสถานะไม่สำเร็จ')
  } finally {
    updatingId.value = null
  }
}
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-4 md:mb-6">
      <h1 class="text-xl md:text-2xl font-bold text-gray-900">ออเดอร์</h1>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3">
      <select
        v-model="filterStatus"
        class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <option value="all">ทุกสถานะ</option>
        <option value="PENDING">รอดำเนินการ</option>
        <option value="PREPARING">กำลังเตรียม</option>
        <option value="READY">พร้อมรับ</option>
        <option value="COMPLETED">เสร็จสิ้น</option>
        <option value="CANCELLED">ยกเลิก</option>
      </select>
      <div class="flex items-center gap-2 w-full md:w-auto">
        <input
          v-model="dateFrom"
          type="date"
          class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <span class="text-gray-400 text-sm flex-shrink-0">—</span>
        <input
          v-model="dateTo"
          type="date"
          class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <button
        class="text-sm text-gray-500 hover:text-gray-700"
        @click="dateFrom = ''; dateTo = ''"
      >ล้างวันที่</button>
    </div>

    <!-- Mobile: Card list -->
    <div class="md:hidden space-y-3">
      <div v-if="isLoading" class="bg-white rounded-xl shadow-sm p-6 text-center text-gray-400 text-sm">
        กำลังโหลด...
      </div>
      <div v-else-if="orders.length === 0" class="bg-white rounded-xl shadow-sm p-6 text-center text-gray-400 text-sm">
        ไม่พบออเดอร์
      </div>
      <div
        v-for="o in orders"
        :key="o.id"
        class="bg-white rounded-xl shadow-sm p-4 flex flex-col gap-2"
      >
        <div class="flex items-start justify-between">
          <NuxtLink :to="`/admin/orders/${o.id}`" class="flex-1">
            <span class="font-bold text-gray-900 text-base">#{{ o.queueNo }}</span>
            <p class="text-xs text-gray-400 mt-0.5">{{ formatDate(o.createdAt) }}</p>
          </NuxtLink>
          <div class="flex flex-col items-end gap-1">
            <span v-if="o.payment" class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="paymentBadge[o.payment.method]">
              {{ paymentLabel[o.payment.method] ?? o.payment.method }}
            </span>
          </div>
        </div>
        <NuxtLink :to="`/admin/orders/${o.id}`" class="text-xs text-gray-600 space-y-0.5 block">
          <p v-for="item in o.items.slice(0, 3)" :key="item.id">{{ item.product.name }} x{{ item.quantity }}</p>
          <p v-if="o.items.length > 3" class="text-gray-400">+{{ o.items.length - 3 }} รายการ</p>
        </NuxtLink>
        <div class="flex items-center justify-between pt-1 border-t border-gray-100">
          <span v-if="o.member" class="text-xs text-blue-600 font-medium">{{ o.member.name }}</span>
          <span v-else class="text-xs text-gray-400">ไม่มีสมาชิก</span>
          <span class="font-semibold text-gray-900 text-sm">฿{{ formatPrice(o.total) }}</span>
        </div>
        <!-- Status row -->
        <div class="flex items-center justify-between pt-1 border-t border-gray-100">
          <span class="text-xs text-gray-500">สถานะ</span>
          <select
            v-if="o.status !== 'COMPLETED' && o.status !== 'CANCELLED'"
            :value="o.status"
            :disabled="updatingId === o.id"
            class="text-xs font-medium rounded-full px-2 py-0.5 border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-400 disabled:opacity-50"
            :class="statusBadge[o.status]"
            @change="updateStatus(o.id, ($event.target as HTMLSelectElement).value)"
          >
            <option value="PENDING">รอดำเนินการ</option>
            <option value="PREPARING">กำลังเตรียม</option>
            <option value="READY">พร้อมรับ</option>
            <option value="COMPLETED">เสร็จสิ้น</option>
            <option value="CANCELLED">ยกเลิก</option>
          </select>
          <span v-else class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[o.status]">
            {{ statusLabel[o.status] ?? o.status }}
          </span>
        </div>
      </div>
    </div>

    <!-- Desktop: Table -->
    <div class="hidden md:block bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">คิว</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">วันที่</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">รายการ</th>
            <th class="text-left px-4 py-3 font-medium text-gray-600">สมาชิก</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">ชำระเงิน</th>
            <th class="text-right px-4 py-3 font-medium text-gray-600">ยอดรวม</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="8" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
          </tr>
          <tr v-else-if="orders.length === 0">
            <td colspan="8" class="text-center py-10 text-gray-400">ไม่พบออเดอร์</td>
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
              <select
                v-if="o.status !== 'COMPLETED' && o.status !== 'CANCELLED'"
                :value="o.status"
                :disabled="updatingId === o.id"
                class="text-xs font-medium rounded-full px-2 py-0.5 border-0 cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-400 disabled:opacity-50"
                :class="statusBadge[o.status]"
                @change="updateStatus(o.id, ($event.target as HTMLSelectElement).value)"
              >
                <option value="PENDING">รอดำเนินการ</option>
                <option value="PREPARING">กำลังเตรียม</option>
                <option value="READY">พร้อมรับ</option>
                <option value="COMPLETED">เสร็จสิ้น</option>
                <option value="CANCELLED">ยกเลิก</option>
              </select>
              <span v-else class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="statusBadge[o.status]">
                {{ statusLabel[o.status] ?? o.status }}
              </span>
            </td>
            <td class="px-4 py-3 text-center">
              <span v-if="o.payment" class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium" :class="paymentBadge[o.payment.method]">
                {{ paymentLabel[o.payment.method] ?? o.payment.method }}
              </span>
              <span v-else class="text-xs text-gray-400">—</span>
            </td>
            <td class="px-4 py-3 text-right font-semibold text-gray-900">฿{{ formatPrice(o.total) }}</td>
            <td class="px-4 py-3 text-right">
              <NuxtLink :to="`/admin/orders/${o.id}`" class="text-blue-600 hover:text-blue-800 text-xs font-medium">
                ดูรายละเอียด
              </NuxtLink>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div v-if="pagination" class="px-4 py-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
        <span>ทั้งหมด {{ pagination.total }} ออเดอร์</span>
        <div class="flex items-center gap-2">
          <button
            class="px-2 py-1 rounded border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="page <= 1"
            @click="page--"
          >←</button>
          <span>หน้า {{ pagination.page }} / {{ pagination.totalPages }}</span>
          <button
            class="px-2 py-1 rounded border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
            :disabled="page >= pagination.totalPages"
            @click="page++"
          >→</button>
        </div>
      </div>
    </div>

    <!-- Mobile pagination -->
    <div v-if="pagination && pagination.totalPages > 1" class="md:hidden mt-3 flex items-center justify-between text-xs text-gray-500 bg-white rounded-xl shadow-sm px-4 py-3">
      <span>ทั้งหมด {{ pagination.total }} ออเดอร์</span>
      <div class="flex items-center gap-2">
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
          :disabled="page <= 1"
          @click="page--"
        >←</button>
        <span>{{ pagination.page }} / {{ pagination.totalPages }}</span>
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-300 hover:bg-gray-50 disabled:opacity-40"
          :disabled="page >= pagination.totalPages"
          @click="page++"
        >→</button>
      </div>
    </div>
  </div>
</template>
