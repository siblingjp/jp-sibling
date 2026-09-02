<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const { showError } = useAlert()
const http = useHttpClient()

// ─── Date filter (default = today BKK) ─────────────────────────────────────
function todayBKK() {
  return new Date(Date.now() + 7 * 3600000).toISOString().slice(0, 10)
}
const dateFrom = ref(todayBKK())
const dateTo = ref(todayBKK())

// ── ป้องกัน dateTo < dateFrom ──────────────────────────────────────────────
watch(dateFrom, (v) => { if (dateTo.value < v) dateTo.value = v })
watch(dateTo, (v) => { if (dateFrom.value > v) dateFrom.value = v })

function setPreset(days: number) {
  const to = todayBKK()
  const from = new Date(Date.now() + 7 * 3600000 - (days - 1) * 86400000).toISOString().slice(0, 10)
  dateFrom.value = from
  dateTo.value = to
}

// ─── Data ────────────────────────────────────────────────────────────────────
interface Summary {
  dateFrom: string
  dateTo: string
  totalOrders: number
  totalCups: number
  totalFoods: number
  totalRevenue: number
  revenueFood: number
  revenueDrink: number
  topProducts: { id: string; name: string; qty: number; revenue: number; isFood: boolean }[]
  byPaymentMethod: { method: string; amount: number }[]
  byCategory: { name: string; slug: string; qty: number; revenue: number }[]
}

const summary = ref<Summary | null>(null)
const isLoading = ref(false)

async function load() {
  isLoading.value = true
  try {
    const res = await http.get<{ data: Summary }>(API_ENDPOINTS.ADMIN.DASHBOARD.SUMMARY, { dateFrom: dateFrom.value, dateTo: dateTo.value })
    summary.value = res.data
  } catch (e: any) {
    showError(e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    isLoading.value = false
  }
}

watch([dateFrom, dateTo], load)
onMounted(load)

// ─── Helpers ─────────────────────────────────────────────────────────────────
const paymentLabel: Record<string, string> = {
  CASH: 'เงินสด',
  CARD: 'บัตร',
  QR: 'QR พร้อมเพย์',
  THAI_HELP: 'โครงการรัฐ',
  UNSPECIFIED: 'ไม่ระบุ',
}

const paymentColor: Record<string, string> = {
  CASH: 'bg-gray-100 text-gray-700',
  CARD: 'bg-purple-100 text-purple-700',
  QR: 'bg-cyan-100 text-cyan-700',
  THAI_HELP: 'bg-orange-100 text-orange-700',
  UNSPECIFIED: 'bg-gray-100 text-gray-500',
}

const paymentDot: Record<string, string> = {
  CASH: 'bg-gray-400',
  CARD: 'bg-purple-500',
  QR: 'bg-cyan-500',
  THAI_HELP: 'bg-orange-500',
  UNSPECIFIED: 'bg-gray-300',
}

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

const maxQty = computed(() => Math.max(...(summary.value?.topProducts.map((p) => p.qty) ?? [1])))

const totalCategoryRevenue = computed(() =>
  (summary.value?.byCategory ?? []).reduce((s, c) => s + c.revenue, 0),
)

const categoryColors: Record<string, { dot: string; bar: string; badge: string }> = {
  foods:    { dot: 'bg-orange-400', bar: 'bg-orange-400', badge: 'bg-orange-100 text-orange-700' },
  drinks:   { dot: 'bg-blue-400',   bar: 'bg-blue-400',   badge: 'bg-blue-100 text-blue-700' },
  unknown:  { dot: 'bg-gray-400',   bar: 'bg-gray-400',   badge: 'bg-gray-100 text-gray-600' },
}
const fallbackColors = { dot: 'bg-teal-400', bar: 'bg-teal-400', badge: 'bg-teal-100 text-teal-700' }
function catColor(slug: string) { return categoryColors[slug] ?? fallbackColors }

const totalPayment = computed(() =>
  (summary.value?.byPaymentMethod ?? []).reduce((s, m) => s + m.amount, 0),
)
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 mb-6">
      <div>
        <h1 class="text-xl md:text-2xl font-bold text-gray-900">ภาพรวม</h1>
        <p class="text-sm text-gray-400 mt-0.5">{{ dateLabel }}</p>
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
        <!-- Date range inputs -->
        <div class="flex items-center gap-2">
          <input
            v-model="dateFrom"
            type="date"
            :max="dateTo"
            class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <span class="text-gray-400 text-sm">–</span>
          <input
            v-model="dateTo"
            type="date"
            :min="dateFrom"
            :max="todayBKK()"
            class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
      <div v-for="i in 3" :key="i" class="bg-white rounded-xl shadow-sm p-5 animate-pulse">
        <div class="h-3 bg-gray-100 rounded w-1/2 mb-3" />
        <div class="h-8 bg-gray-100 rounded w-2/3" />
      </div>
    </div>

    <template v-else-if="summary">
      <!-- KPI Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <!-- ออเดอร์ -->
        <div class="bg-white rounded-xl shadow-sm p-5">
          <div class="flex items-center justify-between mb-3">
            <p class="text-sm text-gray-500 font-medium">ออเดอร์ทั้งหมด</p>
            <span class="text-2xl">🧾</span>
          </div>
          <p class="text-3xl font-bold text-gray-900">{{ summary.totalOrders.toLocaleString() }}</p>
          <p class="text-xs text-gray-400 mt-1">ออเดอร์ที่เสร็จสิ้น</p>
        </div>

        <!-- แก้ว / รายการ -->
        <div class="bg-white rounded-xl shadow-sm p-5">
          <div class="flex items-center justify-between mb-3">
            <p class="text-sm text-gray-500 font-medium">จำนวนแก้ว</p>
            <span class="text-2xl">☕</span>
          </div>
          <p class="text-3xl font-bold text-gray-900">{{ summary.totalCups.toLocaleString() }} <span class="text-lg font-medium text-gray-400">แก้ว</span></p>
          <p v-if="summary.totalFoods > 0" class="text-sm font-semibold text-gray-700 mt-1">
            + {{ summary.totalFoods.toLocaleString() }} <span class="font-medium text-gray-400">รายการ (อาหาร)</span>
          </p>
        </div>

        <!-- ยอดขาย -->
        <div class="bg-blue-600 rounded-xl shadow-sm p-5 text-white">
          <div class="flex items-center justify-between mb-3">
            <p class="text-sm text-blue-100 font-medium">ยอดขายรวม</p>
            <span class="text-2xl">💰</span>
          </div>
          <p class="text-3xl font-bold">฿{{ formatPrice(summary.totalRevenue) }}</p>
          <div class="mt-2 space-y-0.5">
            <p class="text-xs text-blue-200">เครื่องดื่ม ฿{{ formatPrice(summary.revenueDrink) }}</p>
            <p v-if="summary.revenueFood > 0" class="text-xs text-blue-200">อาหาร ฿{{ formatPrice(summary.revenueFood) }}</p>
          </div>
        </div>
      </div>

      <!-- Bottom section -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

        <!-- สินค้าขายดี (2/3 width) -->
        <div class="lg:col-span-2 bg-white rounded-xl shadow-sm p-5">
          <h2 class="text-sm font-semibold text-gray-700 mb-4">สินค้าขายดี</h2>

          <div v-if="summary.topProducts.length === 0" class="text-center py-8 text-gray-400 text-sm">
            ยังไม่มีข้อมูล
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="(p, idx) in summary.topProducts"
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
                    <span class="text-xs text-gray-500">{{ p.qty }} {{ p.isFood ? 'รายการ' : 'แก้ว' }}</span>
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

        <!-- ยอดแยกตามช่องทาง (1/3 width) -->
        <div class="bg-white rounded-xl shadow-sm p-5">
          <h2 class="text-sm font-semibold text-gray-700 mb-4">ยอดตามช่องทางชำระเงิน</h2>

          <div v-if="summary.byPaymentMethod.length === 0" class="text-center py-8 text-gray-400 text-sm">
            ยังไม่มีข้อมูล
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="m in summary.byPaymentMethod.sort((a,b) => b.amount - a.amount)"
              :key="m.method"
              class="flex items-center gap-3"
            >
              <div class="w-2.5 h-2.5 rounded-full flex-shrink-0" :class="paymentDot[m.method] ?? 'bg-gray-400'" />
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <span
                    class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                    :class="paymentColor[m.method] ?? 'bg-gray-100 text-gray-600'"
                  >{{ paymentLabel[m.method] ?? m.method }}</span>
                  <span class="text-sm font-semibold text-gray-800">฿{{ formatPrice(m.amount) }}</span>
                </div>
                <!-- proportion bar -->
                <div class="h-1 bg-gray-100 rounded-full mt-1.5 overflow-hidden">
                  <div
                    class="h-full rounded-full"
                    :class="paymentDot[m.method] ?? 'bg-gray-400'"
                    :style="{ width: totalPayment > 0 ? `${Math.round((m.amount / totalPayment) * 100)}%` : '0%' }"
                  />
                </div>
              </div>
              <span class="text-xs text-gray-400 flex-shrink-0 w-8 text-right">
                {{ totalPayment > 0 ? Math.round((m.amount / totalPayment) * 100) : 0 }}%
              </span>
            </div>

            <!-- Total -->
            <div class="border-t border-gray-100 pt-3 mt-3 flex items-center justify-between">
              <span class="text-xs text-gray-500 font-medium">รวมทั้งหมด</span>
              <span class="text-sm font-bold text-gray-900">฿{{ formatPrice(totalPayment) }}</span>
            </div>
          </div>
        </div>

      </div>

      <!-- สรุปเมนูแยกตาม Category -->
      <div class="mt-4 bg-white rounded-xl shadow-sm p-5">
        <h2 class="text-sm font-semibold text-gray-700 mb-4">สรุปเมนูแยกตาม Category</h2>

        <div v-if="summary.byCategory.length === 0" class="text-center py-8 text-gray-400 text-sm">
          ยังไม่มีข้อมูล
        </div>

        <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="cat in summary.byCategory"
            :key="cat.slug"
            class="border border-gray-100 rounded-xl p-4 flex flex-col gap-2 cursor-pointer hover:border-blue-300 hover:shadow-sm transition-all"
            @click="$router.push({ path: `/admin/dashboard/category/${cat.slug}`, query: { dateFrom, dateTo } })"
          >
            <!-- Header -->
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <div class="w-2.5 h-2.5 rounded-full flex-shrink-0" :class="catColor(cat.slug).dot" />
                <span
                  class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold"
                  :class="catColor(cat.slug).badge"
                >{{ cat.name }}</span>
              </div>
              <span class="text-xs text-gray-400">
                {{ totalCategoryRevenue > 0 ? Math.round((cat.revenue / totalCategoryRevenue) * 100) : 0 }}%
              </span>
            </div>

            <!-- Stats -->
            <div class="flex items-end justify-between">
              <div>
                <p class="text-2xl font-bold text-gray-900">฿{{ formatPrice(cat.revenue) }}</p>
                <p class="text-xs text-gray-400 mt-0.5">{{ cat.qty.toLocaleString() }} รายการ</p>
              </div>
            </div>

            <!-- Bar -->
            <div class="h-1.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                class="h-full rounded-full transition-all"
                :class="catColor(cat.slug).bar"
                :style="{ width: totalCategoryRevenue > 0 ? `${Math.round((cat.revenue / totalCategoryRevenue) * 100)}%` : '0%' }"
              />
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- No data -->
    <div v-else-if="!isLoading" class="text-center py-20 text-gray-400 text-sm">
      ไม่พบข้อมูล
    </div>
  </div>
</template>
