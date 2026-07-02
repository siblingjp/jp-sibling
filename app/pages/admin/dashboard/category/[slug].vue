<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const slug = route.params.slug as string
const { showError } = useAlert()
const http = useHttpClient()

// ─── Date filter (sync กับ query string จาก index) ───────────────────────────
function todayBKK() {
  return new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10)
}
const dateFrom = ref((route.query.dateFrom as string) || todayBKK())
const dateTo   = ref((route.query.dateTo   as string) || todayBKK())

// ─── Data ─────────────────────────────────────────────────────────────────────
interface CategoryDetail {
  slug: string
  categoryName: string
  dateFrom: string
  dateTo: string
  totalQty: number
  totalRevenue: number
  products: { id: string; name: string; price: number; imageUrl: string | null; qty: number; revenue: number }[]
}

const detail = ref<CategoryDetail | null>(null)
const isLoading = ref(false)
const categoryName = ref('')

async function load() {
  isLoading.value = true
  try {
    const res = await http.get<{ data: CategoryDetail }>(
      API_ENDPOINTS.ADMIN.DASHBOARD.CATEGORY_DETAIL,
      { slug, dateFrom: dateFrom.value, dateTo: dateTo.value },
    )
    detail.value = res.data
  } catch (e: any) {
    showError(e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    isLoading.value = false
  }
}

watch([dateFrom, dateTo], load)
onMounted(load)

// ─── Helpers ──────────────────────────────────────────────────────────────────
function formatPrice(n: number) {
  return n.toLocaleString('th-TH', { minimumFractionDigits: 2 })
}

function formatDate(d: string) {
  return new Date(d + 'T00:00:00+07:00').toLocaleDateString('th-TH', {
    day: 'numeric', month: 'short', year: 'numeric',
  })
}

const dateLabel = computed(() => {
  if (dateFrom.value === dateTo.value) return formatDate(dateFrom.value)
  return `${formatDate(dateFrom.value)} – ${formatDate(dateTo.value)}`
})

const maxQty = computed(() => Math.max(...(detail.value?.products.map(p => p.qty) ?? [1])))

function setPreset(days: number) {
  const to = todayBKK()
  const from = new Date(Date.now() + 7 * 3600000 - (days - 1) * 86400000).toISOString().slice(0, 10)
  dateFrom.value = from
  dateTo.value = to
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 mb-6">
      <div class="flex items-center gap-3">
        <button
          class="p-2 rounded-lg hover:bg-gray-100 text-gray-500 transition-colors"
          @click="$router.back()"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <div>
          <h1 class="text-xl md:text-2xl font-bold text-gray-900">{{ detail?.categoryName ?? slug }}</h1>
          <p class="text-sm text-gray-400 mt-0.5">{{ dateLabel }}</p>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <!-- Preset buttons -->
        <div class="flex gap-1.5 flex-wrap">
          <button
            v-for="preset in [{ label: 'วันนี้', days: 1 }, { label: '7 วัน', days: 7 }, { label: '30 วัน', days: 30 }]"
            :key="preset.days"
            class="px-3 py-1.5 text-xs font-medium rounded-lg border transition-colors"
            :class="dateFrom === todayBKK() && dateTo === todayBKK() && preset.days === 1
              ? 'bg-blue-600 text-white border-blue-600'
              : dateFrom === new Date(Date.now() + 7*3600000 - (preset.days-1)*86400000).toISOString().slice(0,10) && dateTo === todayBKK() && preset.days > 1
                ? 'bg-blue-600 text-white border-blue-600'
                : 'border-gray-300 text-gray-600 hover:bg-gray-50'"
            @click="setPreset(preset.days)"
          >{{ preset.label }}</button>
        </div>
        <!-- Date range -->
        <div class="flex items-center gap-2">
          <input v-model="dateFrom" type="date" :max="dateTo"
            class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <span class="text-gray-400 text-sm">–</span>
          <input v-model="dateTo" type="date" :min="dateFrom" :max="todayBKK()"
            class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
      </div>
    </div>

    <!-- Loading skeleton -->
    <template v-if="isLoading">
      <div class="grid grid-cols-2 gap-4 mb-6">
        <div v-for="i in 2" :key="i" class="bg-white rounded-xl shadow-sm p-5 animate-pulse">
          <div class="h-3 bg-gray-100 rounded w-1/2 mb-3" />
          <div class="h-8 bg-gray-100 rounded w-2/3" />
        </div>
      </div>
      <div class="bg-white rounded-xl shadow-sm p-5 animate-pulse space-y-3">
        <div v-for="i in 5" :key="i" class="h-10 bg-gray-100 rounded" />
      </div>
    </template>

    <template v-else-if="detail">
      <!-- KPI Cards -->
      <div class="grid grid-cols-2 gap-4 mb-6">
        <div class="bg-white rounded-xl shadow-sm p-5">
          <p class="text-sm text-gray-500 font-medium mb-2">จำนวนรายการ</p>
          <p class="text-3xl font-bold text-gray-900">{{ detail.totalQty.toLocaleString() }}</p>
          <p class="text-xs text-gray-400 mt-1">รายการทั้งหมด</p>
        </div>
        <div class="bg-blue-600 rounded-xl shadow-sm p-5 text-white">
          <p class="text-sm text-blue-100 font-medium mb-2">ยอดขายรวม</p>
          <p class="text-3xl font-bold">฿{{ formatPrice(detail.totalRevenue) }}</p>
          <p class="text-xs text-blue-200 mt-1">{{ detail.products.length }} เมนู</p>
        </div>
      </div>

      <!-- Product list -->
      <div class="bg-white rounded-xl shadow-sm p-5">
        <h2 class="text-sm font-semibold text-gray-700 mb-4">รายการเมนู</h2>

        <div v-if="detail.products.length === 0" class="text-center py-10 text-gray-400 text-sm">
          ยังไม่มีข้อมูล
        </div>

        <div v-else class="space-y-3">
          <div
            v-for="(p, idx) in detail.products"
            :key="p.id"
            class="flex items-center gap-3"
          >
            <!-- Rank -->
            <div
              class="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0"
              :class="idx === 0 ? 'bg-yellow-400 text-white' : idx === 1 ? 'bg-gray-300 text-gray-700' : idx === 2 ? 'bg-amber-600 text-white' : 'bg-gray-100 text-gray-500'"
            >{{ idx + 1 }}</div>

            <!-- Name + bar -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between mb-1">
                <p class="text-sm font-medium text-gray-800 truncate">{{ p.name }}</p>
                <div class="flex items-center gap-3 flex-shrink-0 ml-2">
                  <span class="text-xs text-gray-500">{{ p.qty.toLocaleString() }} รายการ</span>
                  <span class="text-xs font-semibold text-gray-700">฿{{ formatPrice(p.revenue) }}</span>
                </div>
              </div>
              <div class="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                <div
                  class="h-full rounded-full transition-all"
                  :class="idx === 0 ? 'bg-blue-500' : 'bg-blue-300'"
                  :style="{ width: `${Math.round((p.qty / maxQty) * 100)}%` }"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- No data -->
    <div v-else class="text-center py-20 text-gray-400 text-sm">
      ไม่พบข้อมูล
    </div>
  </div>
</template>
