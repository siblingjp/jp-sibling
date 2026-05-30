<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'auth' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

type Tier = 'SILVER' | 'GOLD' | 'VIP'
type CouponType = 'POINT_REDEEM' | 'PROMOTION' | 'DISCOUNT'
type BenefitType = 'DISCOUNT' | 'FREE_ITEM'
type DisplayMode = 'image' | 'banner'

interface CouponDetail {
  id: string
  code: string
  name: string
  type: CouponType
  benefitType: BenefitType
  freeItemDescription: string | null
  discountKind: 'PERCENT' | 'AMOUNT'
  discountValue: number
  maxUses: number | null
  usedCount: number
  startAt: string | null
  expiredAt: string | null
  pointCost: number | null
  minOrderAmount: number | null
  minQuantity: number | null
}

interface Campaign {
  id: string
  name: string
  description: string | null
  imageUrl: string | null
  displayMode: DisplayMode | null
  bannerColor: string | null
  startAt: string | null
  expiredAt: string | null
  isActive: boolean
  memberOnly: boolean
  minTier: Tier | null
  coupons: { coupon: CouponDetail }[]
}

// ─── Campaign list + pagination ───────────────────────────────────────────────
const campaigns = ref<Campaign[]>([])
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const totalCount = ref(0)
const totalPages = computed(() => Math.ceil(totalCount.value / pageSize.value))

async function load(page = currentPage.value) {
  isLoading.value = true
  try {
    const res = await http.get<{ data: { data: Campaign[], total: number, page: number, size: number } }>(
      `${API_ENDPOINTS.ADMIN.CAMPAIGNS_DISCOUNT.LIST}?page=${page}&size=${pageSize.value}`,
    )
    campaigns.value = res.data?.data ?? []
    totalCount.value = res.data?.total ?? 0
    currentPage.value = page
  } catch (e: any) {
    showError(e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    isLoading.value = false
  }
}

// ─── Campaign form ─────────────────────────────────────────────────────────────
const showForm = ref(false)
const editingId = ref<string | null>(null)
const isSaving = ref(false)

const form = reactive({
  name: '',
  description: '',
  imageUrl: '',
  displayMode: 'image' as DisplayMode,
  bannerColor: '#1B2B4B',
  startAt: '',
  expiredAt: '',
  isActive: true,
  memberOnly: false,
  minTier: '' as Tier | '',
  couponIds: [] as string[],
})

const dateError = ref('')

watch([() => form.startAt, () => form.expiredAt], () => {
  if (form.startAt && form.expiredAt && new Date(form.startAt) >= new Date(form.expiredAt)) {
    dateError.value = 'วันเริ่มต้นต้องอยู่ก่อนวันสิ้นสุด'
  } else {
    dateError.value = ''
  }
})

const couponDateWarnings = computed(() => {
  if (!form.startAt && !form.expiredAt) return []
  const campStart = form.startAt ? new Date(form.startAt) : null
  const campEnd = form.expiredAt ? new Date(form.expiredAt) : null
  const warnings: string[] = []
  for (const c of selectedCoupons.value) {
    if (campStart && c.expiredAt && new Date(c.expiredAt) < campStart) {
      warnings.push(`${c.code} หมดอายุก่อนแคมเปญเริ่ม`)
    } else if (campEnd && c.startAt && new Date(c.startAt) > campEnd) {
      warnings.push(`${c.code} เริ่มใช้งานหลังแคมเปญสิ้นสุด`)
    }
  }
  return warnings
})

function resetForm() {
  form.name = ''
  form.description = ''
  form.imageUrl = ''
  form.displayMode = 'image'
  form.bannerColor = '#1B2B4B'
  form.startAt = ''
  form.expiredAt = ''
  form.isActive = true
  form.memberOnly = false
  form.minTier = ''
  form.couponIds = []
  dateError.value = ''
}

function openNew() {
  editingId.value = null
  resetForm()
  allCoupons.value = []
  showForm.value = true
}

function openEdit(c: Campaign) {
  editingId.value = c.id
  form.name = c.name
  form.description = c.description ?? ''
  form.imageUrl = c.imageUrl ?? ''
  form.displayMode = c.displayMode ?? 'image'
  form.bannerColor = c.bannerColor ?? '#1B2B4B'
  form.startAt = c.startAt ? c.startAt.slice(0, 16) : ''
  form.expiredAt = c.expiredAt ? c.expiredAt.slice(0, 16) : ''
  form.isActive = c.isActive
  form.memberOnly = c.memberOnly
  form.minTier = c.minTier ?? ''
  form.couponIds = c.coupons.map(cc => cc.coupon.id)
  dateError.value = ''
  // seed allCoupons จาก campaign data ที่มีอยู่แล้ว เพื่อให้ selectedCoupons แสดงได้ทันที
  const existing = c.coupons.map(cc => cc.coupon)
  const existingIds = new Set(existing.map(x => x.id))
  allCoupons.value = [...existing, ...allCoupons.value.filter(x => !existingIds.has(x.id))]
  showForm.value = true
}

async function handleSave() {
  if (dateError.value) return
  if (couponDateWarnings.value.length) {
    showError(couponDateWarnings.value[0])
    return
  }
  isSaving.value = true
  try {
    const body = {
      name: form.name,
      description: form.description || null,
      imageUrl: form.imageUrl || null,
      displayMode: form.displayMode,
      bannerColor: form.bannerColor || null,
      startAt: form.startAt ? new Date(form.startAt).toISOString() : null,
      expiredAt: form.expiredAt ? new Date(form.expiredAt).toISOString() : null,
      isActive: form.isActive,
      memberOnly: form.memberOnly,
      minTier: form.minTier || null,
      couponIds: form.couponIds,
    }
    if (editingId.value) {
      await http.patch(API_ENDPOINTS.ADMIN.CAMPAIGNS_DISCOUNT.UPDATE(editingId.value), body)
      showSuccess('อัปเดตแคมเปญแล้ว')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.CAMPAIGNS_DISCOUNT.CREATE, body)
      showSuccess('สร้างแคมเปญแล้ว')
    }
    showForm.value = false
    load()
  } catch (e: any) {
    showError(e?.message ?? 'บันทึกไม่สำเร็จ')
  } finally {
    isSaving.value = false
  }
}

async function handleToggleActive(c: Campaign) {
  try {
    await http.patch(API_ENDPOINTS.ADMIN.CAMPAIGNS_DISCOUNT.UPDATE(c.id), { isActive: !c.isActive })
    showSuccess(c.isActive ? 'ปิดแคมเปญแล้ว' : 'เปิดแคมเปญแล้ว')
    load()
  } catch (e: any) {
    showError(e?.message ?? 'เปลี่ยนสถานะไม่สำเร็จ')
  }
}

async function handleDelete(c: Campaign) {
  const ok = await showConfirm({
    title: 'ลบแคมเปญ',
    message: `ลบแคมเปญ "${c.name}"?`,
    confirmText: 'ลบ',
  })
  if (!ok) return
  try {
    await http.delete(API_ENDPOINTS.ADMIN.CAMPAIGNS_DISCOUNT.DELETE(c.id))
    showSuccess('ลบแคมเปญแล้ว')
    load()
  } catch (e: any) {
    showError(e?.message ?? 'ลบไม่สำเร็จ')
  }
}

// ─── Coupon picker modal ───────────────────────────────────────────────────────
const showCouponPicker = ref(false)
const allCoupons = ref<CouponDetail[]>([])
const couponPickerLoading = ref(false)
const couponSearch = ref('')

const filteredCoupons = computed(() => {
  const q = couponSearch.value.toLowerCase().trim()
  if (!q) return allCoupons.value
  return allCoupons.value.filter(c =>
    c.code.toLowerCase().includes(q) || c.name.toLowerCase().includes(q),
  )
})

const selectedCoupons = computed(() =>
  allCoupons.value.filter(c => form.couponIds.includes(c.id)),
)

async function openCouponPicker() {
  couponSearch.value = ''
  showCouponPicker.value = true
  // ถ้ามีข้อมูลครบแล้ว (มากกว่า coupon ที่ select อยู่) ไม่ต้อง fetch ใหม่
  if (allCoupons.value.length > form.couponIds.length) return
  couponPickerLoading.value = true
  try {
    const res = await http.get<{ data: { data: CouponDetail[] } }>(
      `${API_ENDPOINTS.ADMIN.COUPONS.LIST}?size=200`,
    )
    const fetched = res.data?.data ?? []
    const existingIds = new Set(allCoupons.value.map(x => x.id))
    allCoupons.value = [...allCoupons.value, ...fetched.filter(x => !existingIds.has(x.id))]
  } catch {
    // silent
  } finally {
    couponPickerLoading.value = false
  }
}

function toggleCoupon(id: string) {
  const idx = form.couponIds.indexOf(id)
  if (idx === -1) form.couponIds.push(id)
  else form.couponIds.splice(idx, 1)
}

function removeCoupon(id: string) {
  form.couponIds = form.couponIds.filter(i => i !== id)
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
function formatDate(d: string | null) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}

function discountLabel(c: CouponDetail) {
  if (c.benefitType === 'FREE_ITEM') return 'ของแถม'
  return c.discountKind === 'PERCENT'
    ? `${Number(c.discountValue).toFixed(0)}%`
    : `฿${Number(c.discountValue).toFixed(0)}`
}

function couponSubtext(c: CouponDetail) {
  const parts: string[] = []
  if (c.type === 'POINT_REDEEM' && c.pointCost) parts.push(`${c.pointCost} แต้ม`)
  if (c.minOrderAmount) parts.push(`ขั้นต่ำ ฿${Number(c.minOrderAmount).toFixed(0)}`)
  if (c.minQuantity) parts.push(`ขั้นต่ำ ${c.minQuantity} ชิ้น`)
  if (c.benefitType === 'FREE_ITEM' && c.freeItemDescription) parts.push(c.freeItemDescription)
  return parts.join(' · ')
}

function couponUsageLabel(c: CouponDetail) {
  if (c.maxUses === null) return `${c.usedCount} / ∞`
  return `${c.usedCount} / ${c.maxUses}`
}

function couponDateConflict(c: CouponDetail) {
  const campStart = form.startAt ? new Date(form.startAt) : null
  const campEnd = form.expiredAt ? new Date(form.expiredAt) : null
  if (campStart && c.expiredAt && new Date(c.expiredAt) < campStart) return true
  if (campEnd && c.startAt && new Date(c.startAt) > campEnd) return true
  return false
}

const typeColor: Record<CouponType, string> = {
  POINT_REDEEM: 'bg-amber-100 text-amber-700',
  PROMOTION: 'bg-purple-100 text-purple-700',
  DISCOUNT: 'bg-blue-100 text-blue-700',
}
const typeLabel: Record<CouponType, string> = {
  POINT_REDEEM: 'แลกแต้ม',
  PROMOTION: 'โปรโมชัน',
  DISCOUNT: 'ส่วนลด',
}

onMounted(() => load())
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold" style="color: #1B2B4B;">แคมเปญส่วนลด</h1>
        <p class="text-sm text-gray-500 mt-0.5">จัดการแคมเปญและคูปองที่รวมอยู่ · {{ totalCount }} รายการ</p>
      </div>
      <button
        class="px-4 py-2.5 text-white text-sm font-semibold rounded-xl shadow hover:opacity-90 transition"
        style="background: #1B2B4B;"
        @click="openNew"
      >
        + สร้างแคมเปญ
      </button>
    </div>

    <!-- Loading / Empty -->
    <div v-if="isLoading" class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">กำลังโหลด...</div>
    <div v-else-if="campaigns.length === 0" class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">
      ยังไม่มีแคมเปญ กด "สร้างแคมเปญ" เพื่อเริ่มต้น
    </div>

    <!-- Campaign Cards -->
    <div v-else class="grid gap-4">
      <div v-for="c in campaigns" :key="c.id" class="bg-white rounded-2xl shadow p-5 flex flex-col gap-3">
        <div class="flex items-start justify-between gap-3">
          <img v-if="c.imageUrl" :src="c.imageUrl" class="w-16 h-16 rounded-xl object-cover shrink-0 border border-gray-100" alt="" />
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <h2 class="font-bold text-gray-900 text-base">{{ c.name }}</h2>
              <span v-if="c.memberOnly" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-purple-100 text-purple-700">เฉพาะสมาชิก</span>
              <span v-if="c.minTier" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-100 text-amber-700">{{ c.minTier }}+</span>
            </div>
            <p v-if="c.description" class="text-sm text-gray-500 mt-0.5">{{ c.description }}</p>
            <div class="flex items-center gap-4 mt-2 text-xs text-gray-400">
              <span>เริ่ม: {{ formatDate(c.startAt) }}</span>
              <span>สิ้นสุด: {{ formatDate(c.expiredAt) }}</span>
              <span class="font-medium" style="color: #2a3f6b;">{{ c.coupons.length }} คูปอง</span>
            </div>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <button
              class="px-3 py-1.5 rounded-full text-xs font-semibold transition hover:opacity-80"
              :class="c.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              @click="handleToggleActive(c)"
            >{{ c.isActive ? 'เปิดอยู่' : 'ปิดอยู่' }}</button>
            <button class="text-sm font-medium text-blue-600 hover:text-blue-800" @click="openEdit(c)">แก้ไข</button>
            <button class="text-sm font-medium text-red-500 hover:text-red-700" @click="handleDelete(c)">ลบ</button>
          </div>
        </div>

        <!-- Coupon list -->
        <div v-if="c.coupons.length > 0" class="grid gap-2">
          <div
            v-for="cc in c.coupons"
            :key="cc.coupon.id"
            class="flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm"
            style="border-color: #C8D8E8; background: #f0f5fa;"
          >
            <span class="font-mono text-xs font-bold px-2 py-0.5 rounded" style="background:#C8D8E8;color:#1B2B4B;">{{ cc.coupon.code }}</span>
            <span class="text-xs px-1.5 py-0.5 rounded-full font-semibold" :class="typeColor[cc.coupon.type]">{{ typeLabel[cc.coupon.type] }}</span>
            <span class="flex-1 min-w-0 text-gray-800 truncate font-medium">{{ cc.coupon.name }}</span>
            <span class="font-bold shrink-0" :class="cc.coupon.discountKind === 'PERCENT' ? 'text-blue-700' : 'text-emerald-700'">
              {{ discountLabel(cc.coupon) }}
            </span>
            <span class="text-xs text-gray-400 shrink-0">{{ couponUsageLabel(cc.coupon) }}</span>
          </div>
        </div>
        <div v-else class="text-xs text-gray-400 italic">ยังไม่มีคูปองในแคมเปญนี้</div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="flex items-center justify-between mt-4 text-sm text-gray-600">
      <span>หน้า {{ currentPage }} จาก {{ totalPages }} ({{ totalCount }} รายการ)</span>
      <div class="flex gap-1">
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          :disabled="currentPage <= 1"
          @click="load(currentPage - 1)"
        >‹ ก่อนหน้า</button>
        <button
          v-for="p in totalPages"
          :key="p"
          class="px-3 py-1.5 rounded-lg border transition"
          :class="p === currentPage ? 'text-white border-transparent font-semibold' : 'border-gray-200 hover:bg-gray-50'"
          :style="p === currentPage ? 'background:#1B2B4B' : ''"
          @click="load(p)"
        >{{ p }}</button>
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          :disabled="currentPage >= totalPages"
          @click="load(currentPage + 1)"
        >ถัดไป ›</button>
      </div>
    </div>

    <!-- Campaign Form Modal -->
    <Teleport to="body">
      <div v-if="showForm" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/50" @click="showForm = false" />
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
          <div class="sticky top-0 bg-white rounded-t-2xl px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h2 class="text-lg font-bold" style="color: #1B2B4B;">
              {{ editingId ? 'แก้ไขแคมเปญ' : 'สร้างแคมเปญใหม่' }}
            </h2>
            <button class="text-gray-400 hover:text-gray-600 text-xl leading-none" @click="showForm = false">&times;</button>
          </div>

          <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Left: Form fields -->
            <form class="space-y-4" @submit.prevent="handleSave">
              <!-- Name -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">ชื่อแคมเปญ <span class="text-red-500">*</span></label>
                <input
                  v-model="form.name"
                  type="text"
                  required
                  placeholder="เช่น แคมเปญช่วงเปิดเทอม"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <!-- Description -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">รายละเอียด</label>
                <textarea
                  v-model="form.description"
                  rows="2"
                  placeholder="รายละเอียดแคมเปญ..."
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                />
              </div>

              <!-- Display Mode -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-2">รูปแบบการแสดง</label>
                <div class="flex gap-2">
                  <button
                    type="button"
                    class="flex-1 py-2 rounded-xl border text-xs font-semibold transition"
                    :class="form.displayMode === 'image'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 text-gray-500 hover:bg-gray-50'"
                    @click="form.displayMode = 'image'"
                  >
                    รูปภาพเป็นหลัก
                  </button>
                  <button
                    type="button"
                    class="flex-1 py-2 rounded-xl border text-xs font-semibold transition"
                    :class="form.displayMode === 'banner'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 text-gray-500 hover:bg-gray-50'"
                    @click="form.displayMode = 'banner'"
                  >
                    แบนเนอร์ + ข้อความ
                  </button>
                </div>
              </div>

              <!-- Image upload -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">รูปภาพแคมเปญ</label>
                <AdminImageUpload v-model="form.imageUrl" folder="campaigns" />
              </div>

              <!-- Banner color (only for banner mode) -->
              <div v-if="form.displayMode === 'banner'">
                <label class="block text-xs font-medium text-gray-500 mb-1">สีพื้นหลัง</label>
                <div class="flex items-center gap-3">
                  <input
                    v-model="form.bannerColor"
                    type="color"
                    class="w-10 h-10 rounded-lg border border-gray-300 cursor-pointer p-0.5"
                  />
                  <input
                    v-model="form.bannerColor"
                    type="text"
                    maxlength="7"
                    placeholder="#1B2B4B"
                    class="flex-1 px-3 py-2 border border-gray-300 rounded-xl text-sm font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <div class="flex gap-1.5">
                    <button
                      v-for="preset in ['#1B2B4B','#7C3AED','#DC2626','#059669','#D97706','#0EA5E9']"
                      :key="preset"
                      type="button"
                      class="w-6 h-6 rounded-full border-2 transition"
                      :style="`background:${preset};border-color:${form.bannerColor===preset?'#3B82F6':'transparent'}`"
                      @click="form.bannerColor = preset"
                    />
                  </div>
                </div>
              </div>

              <!-- Dates -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">วันเริ่มต้น</label>
                  <input
                    v-model="form.startAt"
                    type="datetime-local"
                    class="w-full px-3 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 transition"
                    :class="dateError ? 'border-red-400 focus:ring-red-400' : 'border-gray-300 focus:ring-blue-500'"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">วันสิ้นสุด</label>
                  <input
                    v-model="form.expiredAt"
                    type="datetime-local"
                    class="w-full px-3 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 transition"
                    :class="dateError ? 'border-red-400 focus:ring-red-400' : 'border-gray-300 focus:ring-blue-500'"
                  />
                </div>
              </div>
              <p v-if="dateError" class="text-xs text-red-500 -mt-2">{{ dateError }}</p>

              <!-- Tier -->
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">ระดับสมาชิกขั้นต่ำ</label>
                <select
                  v-model="form.minTier"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">ทุกระดับ</option>
                  <option value="SILVER">Silver</option>
                  <option value="GOLD">Gold</option>
                  <option value="VIP">VIP</option>
                </select>
              </div>

              <!-- Toggles -->
              <div class="flex flex-col gap-2">
                <label class="flex items-center gap-3 cursor-pointer">
                  <div
                    class="relative w-10 h-5 rounded-full transition"
                    :class="form.isActive ? 'bg-green-500' : 'bg-gray-300'"
                    @click="form.isActive = !form.isActive"
                  >
                    <span class="absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform" :class="form.isActive ? 'translate-x-5' : ''" />
                  </div>
                  <span class="text-sm text-gray-700 font-medium">เปิดใช้งานแคมเปญ</span>
                </label>
                <label class="flex items-center gap-3 cursor-pointer">
                  <div
                    class="relative w-10 h-5 rounded-full transition"
                    :class="form.memberOnly ? 'bg-blue-500' : 'bg-gray-300'"
                    @click="form.memberOnly = !form.memberOnly"
                  >
                    <span class="absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform" :class="form.memberOnly ? 'translate-x-5' : ''" />
                  </div>
                  <span class="text-sm text-gray-700 font-medium">เฉพาะสมาชิกเท่านั้น</span>
                </label>
              </div>

              <!-- Coupon Picker -->
              <div>
                <div class="flex items-center justify-between mb-2">
                  <label class="text-xs font-medium text-gray-500">
                    คูปองในแคมเปญ
                    <span v-if="form.couponIds.length > 0" class="ml-1 px-1.5 py-0.5 rounded text-xs font-bold" style="background:#C8D8E8;color:#1B2B4B;">
                      {{ form.couponIds.length }} เลือก
                    </span>
                  </label>
                  <button
                    type="button"
                    class="text-xs font-semibold px-3 py-1.5 rounded-lg transition hover:opacity-80"
                    style="background:#C8D8E8;color:#1B2B4B;"
                    @click="openCouponPicker"
                  >
                    + เลือกคูปอง
                  </button>
                </div>

                <div v-if="couponDateWarnings.length > 0" class="mb-2 space-y-1">
                  <p v-for="w in couponDateWarnings" :key="w" class="text-xs text-orange-600 bg-orange-50 border border-orange-200 rounded-lg px-3 py-1.5">
                    ⚠️ {{ w }}
                  </p>
                </div>

                <div v-if="selectedCoupons.length === 0" class="text-xs text-gray-400 italic py-2">
                  ยังไม่ได้เลือกคูปอง
                </div>
                <div v-else class="space-y-2">
                  <div
                    v-for="c in selectedCoupons"
                    :key="c.id"
                    class="flex gap-3 px-3 py-2.5 rounded-xl border"
                    :class="couponDateConflict(c) ? 'border-orange-300 bg-orange-50' : 'border-gray-200 bg-gray-50'"
                  >
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 flex-wrap">
                        <span class="font-mono text-xs font-bold text-gray-700 bg-gray-200 px-1.5 py-0.5 rounded">{{ c.code }}</span>
                        <span class="text-xs px-1.5 py-0.5 rounded-full font-semibold" :class="typeColor[c.type]">{{ typeLabel[c.type] }}</span>
                        <span class="text-sm font-bold" :class="c.discountKind === 'PERCENT' ? 'text-blue-700' : 'text-emerald-700'">
                          {{ discountLabel(c) }}
                        </span>
                      </div>
                      <p class="text-sm text-gray-800 font-medium mt-0.5 truncate">{{ c.name }}</p>
                      <div class="flex flex-wrap gap-3 mt-1 text-xs text-gray-500">
                        <span>ใช้แล้ว {{ couponUsageLabel(c) }} สิทธิ์</span>
                        <span v-if="couponSubtext(c)">{{ couponSubtext(c) }}</span>
                        <span v-if="c.startAt || c.expiredAt">
                          {{ c.startAt ? formatDate(c.startAt) : 'ไม่จำกัดต้น' }} – {{ c.expiredAt ? formatDate(c.expiredAt) : 'ไม่จำกัดปลาย' }}
                        </span>
                      </div>
                      <p v-if="couponDateConflict(c)" class="text-xs text-orange-600 mt-1">⚠️ ช่วงวันที่ขัดแย้งกับแคมเปญ</p>
                    </div>
                    <button
                      type="button"
                      class="text-gray-400 hover:text-red-500 text-xl leading-none shrink-0 self-start mt-0.5"
                      @click="removeCoupon(c.id)"
                    >×</button>
                  </div>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex gap-3 pt-2">
                <button
                  type="button"
                  class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50 font-medium"
                  @click="showForm = false"
                >ยกเลิก</button>
                <button
                  type="submit"
                  class="flex-1 py-2.5 rounded-xl text-white text-sm font-semibold hover:opacity-90 disabled:opacity-50 transition"
                  style="background: #1B2B4B;"
                  :disabled="isSaving || !form.name || !!dateError || couponDateWarnings.length > 0"
                >
                  {{ isSaving ? 'กำลังบันทึก...' : editingId ? 'บันทึกการเปลี่ยนแปลง' : 'สร้างแคมเปญ' }}
                </button>
              </div>
            </form>

            <!-- Right: Preview -->
            <div class="flex flex-col gap-3">
              <p class="text-xs font-medium text-gray-500">ตัวอย่างการแสดงผล</p>

              <!-- Image mode preview -->
              <div v-if="form.displayMode === 'image'" class="rounded-2xl overflow-hidden border border-gray-200 shadow-sm">
                <div class="relative aspect-video bg-gray-100">
                  <img
                    v-if="form.imageUrl"
                    :src="form.imageUrl"
                    class="w-full h-full object-cover"
                    alt="preview"
                  />
                  <div v-else class="w-full h-full flex items-center justify-center text-gray-400 text-sm">
                    ยังไม่มีรูปภาพ
                  </div>
                  <!-- badges overlay -->
                  <div v-if="form.memberOnly || form.minTier" class="absolute top-2 left-2 flex gap-1">
                    <span v-if="form.memberOnly" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-purple-600 text-white shadow">เฉพาะสมาชิก</span>
                    <span v-if="form.minTier" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-500 text-white shadow">{{ form.minTier }}+</span>
                  </div>
                </div>
                <div class="p-3 bg-white">
                  <p class="font-bold text-gray-900 text-sm">{{ form.name || 'ชื่อแคมเปญ' }}</p>
                  <p v-if="form.description" class="text-xs text-gray-500 mt-0.5 line-clamp-2">{{ form.description }}</p>
                </div>
              </div>

              <!-- Banner mode preview -->
              <div v-else class="rounded-2xl overflow-hidden border border-gray-200 shadow-sm">
                <div
                  class="relative px-5 py-6 flex items-center gap-4"
                  :style="`background: ${form.bannerColor}`"
                >
                  <div v-if="form.imageUrl" class="shrink-0">
                    <img :src="form.imageUrl" class="w-16 h-16 rounded-xl object-cover border-2 border-white/30" alt="" />
                  </div>
                  <div class="flex-1 min-w-0">
                    <div class="flex gap-1.5 mb-1.5 flex-wrap">
                      <span v-if="form.memberOnly" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-white/20 text-white">เฉพาะสมาชิก</span>
                      <span v-if="form.minTier" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-400/80 text-white">{{ form.minTier }}+</span>
                    </div>
                    <p class="font-bold text-white text-base leading-tight">{{ form.name || 'ชื่อแคมเปญ' }}</p>
                    <p v-if="form.description" class="text-white/70 text-xs mt-1 line-clamp-2">{{ form.description }}</p>
                    <p v-if="form.expiredAt" class="text-white/50 text-xs mt-2">สิ้นสุด {{ formatDate(form.expiredAt) }}</p>
                  </div>
                </div>
                <div class="px-4 py-2.5 bg-white text-xs text-gray-400">
                  {{ form.couponIds.length > 0 ? `${form.couponIds.length} คูปอง` : 'ยังไม่มีคูปอง' }}
                </div>
              </div>

              <!-- Mini note -->
              <p class="text-xs text-gray-400 text-center">ตัวอย่างอาจแตกต่างจากหน้าจริงเล็กน้อย</p>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Coupon Picker Modal -->
    <Teleport to="body">
      <div v-if="showCouponPicker" class="fixed inset-0 z-[60] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/60" @click="showCouponPicker = false" />
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg flex flex-col max-h-[85vh]">
          <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <div>
              <h3 class="font-bold text-gray-900">เลือกคูปอง</h3>
              <p class="text-xs text-gray-400 mt-0.5">เลือกได้หลายคูปอง · เลือกแล้ว {{ form.couponIds.length }}</p>
            </div>
            <button class="text-gray-400 hover:text-gray-600 text-xl leading-none" @click="showCouponPicker = false">&times;</button>
          </div>

          <div class="px-5 py-3 border-b border-gray-100">
            <input
              v-model="couponSearch"
              type="text"
              placeholder="ค้นหารหัสหรือชื่อคูปอง..."
              class="w-full px-3 py-2 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div class="flex-1 overflow-y-auto divide-y divide-gray-100">
            <div v-if="couponPickerLoading" class="text-center py-8 text-gray-400 text-sm">กำลังโหลด...</div>
            <div v-else-if="filteredCoupons.length === 0" class="text-center py-8 text-gray-400 text-sm">ไม่พบคูปอง</div>
            <label
              v-for="c in filteredCoupons"
              :key="c.id"
              class="flex items-start gap-3 px-4 py-3 cursor-pointer hover:bg-blue-50/40 transition-colors"
              :class="[
                form.couponIds.includes(c.id) ? 'bg-blue-50' : '',
                couponDateConflict(c) ? 'opacity-60' : '',
              ]"
            >
              <input
                type="checkbox"
                :checked="form.couponIds.includes(c.id)"
                class="w-4 h-4 rounded accent-blue-600 shrink-0 mt-1"
                @change="toggleCoupon(c.id)"
              />
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                  <span class="font-mono text-xs font-bold text-gray-700 bg-gray-100 px-1.5 py-0.5 rounded">{{ c.code }}</span>
                  <span class="text-xs px-1.5 py-0.5 rounded-full font-semibold" :class="typeColor[c.type]">{{ typeLabel[c.type] }}</span>
                  <span class="text-sm font-bold" :class="c.discountKind === 'PERCENT' ? 'text-blue-600' : 'text-emerald-600'">
                    {{ discountLabel(c) }}
                  </span>
                </div>
                <p class="text-sm text-gray-800 font-medium mt-0.5">{{ c.name }}</p>
                <div class="flex flex-wrap gap-3 mt-0.5 text-xs text-gray-400">
                  <span>ใช้แล้ว {{ couponUsageLabel(c) }} สิทธิ์</span>
                  <span v-if="couponSubtext(c)">{{ couponSubtext(c) }}</span>
                  <span v-if="c.startAt || c.expiredAt" :class="couponDateConflict(c) ? 'text-orange-500' : ''">
                    {{ c.startAt ? formatDate(c.startAt) : '—' }} → {{ c.expiredAt ? formatDate(c.expiredAt) : 'ไม่จำกัด' }}
                    <span v-if="couponDateConflict(c)"> ⚠️</span>
                  </span>
                </div>
              </div>
            </label>
          </div>

          <div class="px-5 py-4 border-t border-gray-100 flex justify-end">
            <button
              type="button"
              class="px-6 py-2.5 rounded-xl text-white text-sm font-semibold hover:opacity-90 transition"
              style="background:#1B2B4B;"
              @click="showCouponPicker = false"
            >
              ยืนยัน {{ form.couponIds.length > 0 ? `(${form.couponIds.length})` : '' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
