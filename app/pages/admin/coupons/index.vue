<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'admin', middleware: 'auth' })

const http = useHttpClient()
const { showSuccess, showError, showConfirm } = useAlert()

type DiscountKind = 'PERCENT' | 'AMOUNT'
type Tier = 'SILVER' | 'GOLD' | 'VIP'
type CouponType = 'POINT_REDEEM' | 'PROMOTION' | 'DISCOUNT'
type BenefitType = 'DISCOUNT' | 'FREE_ITEM'

interface Coupon {
  id: string
  code: string
  name: string
  description: string | null
  type: CouponType
  benefitType: BenefitType
  freeItemDescription: string | null
  discountKind: DiscountKind
  discountValue: number
  minOrderAmount: number | null
  minQuantity: number | null
  maxUses: number | null
  startAt: string | null
  expiredAt: string | null
  isActive: boolean
  memberOnly: boolean
  minTier: Tier | null
  pointCost: number | null
  perMemberLimit: number | null
  usedCount: number
}

const coupons = ref<Coupon[]>([])
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const totalCount = ref(0)
const totalPages = computed(() => Math.ceil(totalCount.value / pageSize.value))

async function load(page = currentPage.value) {
  isLoading.value = true
  try {
    const res = await http.get<{ data: { data: Coupon[], total: number, page: number, size: number } }>(
      `${API_ENDPOINTS.ADMIN.COUPONS.LIST}?page=${page}&size=${pageSize.value}`,
    )
    coupons.value = res.data?.data ?? []
    totalCount.value = res.data?.total ?? 0
    currentPage.value = page
  } catch (e: any) {
    showError(e?.message ?? 'โหลดข้อมูลไม่สำเร็จ')
  } finally {
    isLoading.value = false
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────
const showForm = ref(false)
const editingId = ref<string | null>(null)
const isSaving = ref(false)

const form = reactive({
  code: '',
  name: '',
  description: '',
  type: 'DISCOUNT' as CouponType,
  benefitType: 'DISCOUNT' as BenefitType,
  freeItemDescription: '',
  discountKind: 'PERCENT' as DiscountKind,
  discountValue: 0,
  minOrderAmount: null as number | null,
  minQuantity: null as number | null,
  maxUses: null as number | null,
  startAt: '',
  expiredAt: '',
  isActive: true,
  memberOnly: false,
  minTier: '' as Tier | '',
  pointCost: null as number | null,
  perMemberLimit: null as number | null,
})

function resetForm() {
  form.code = ''
  form.name = ''
  form.description = ''
  form.type = 'DISCOUNT'
  form.benefitType = 'DISCOUNT'
  form.freeItemDescription = ''
  form.discountKind = 'PERCENT'
  form.discountValue = 0
  form.minOrderAmount = null
  form.minQuantity = null
  form.maxUses = null
  form.startAt = ''
  form.expiredAt = ''
  form.isActive = true
  form.memberOnly = false
  form.minTier = ''
  form.pointCost = null
  form.perMemberLimit = null
}

function openNew() {
  editingId.value = null
  resetForm()
  showForm.value = true
}

function openEdit(c: Coupon) {
  editingId.value = c.id
  form.code = c.code
  form.name = c.name
  form.description = c.description ?? ''
  form.type = c.type
  form.benefitType = c.benefitType
  form.freeItemDescription = c.freeItemDescription ?? ''
  form.discountKind = c.discountKind
  form.discountValue = Number(c.discountValue)
  form.minOrderAmount = c.minOrderAmount
  form.minQuantity = c.minQuantity
  form.maxUses = c.maxUses
  form.startAt = c.startAt ? c.startAt.slice(0, 16) : ''
  form.expiredAt = c.expiredAt ? c.expiredAt.slice(0, 16) : ''
  form.isActive = c.isActive
  form.memberOnly = c.memberOnly
  form.minTier = c.minTier ?? ''
  form.pointCost = c.pointCost
  form.perMemberLimit = c.perMemberLimit
  showForm.value = true
}

async function handleSave() {
  isSaving.value = true
  try {
    const body: Record<string, any> = {
      code: form.code || undefined,
      name: form.name,
      description: form.description || null,
      type: form.type,
      benefitType: form.benefitType,
      freeItemDescription: form.benefitType === 'FREE_ITEM' ? (form.freeItemDescription || null) : null,
      discountKind: form.discountKind,
      discountValue: form.benefitType === 'FREE_ITEM' ? 0 : Number(form.discountValue),
      minOrderAmount: form.minOrderAmount ? Number(form.minOrderAmount) : null,
      minQuantity: form.minQuantity ? Number(form.minQuantity) : null,
      maxUses: form.maxUses ? Number(form.maxUses) : null,
      startAt: form.startAt ? new Date(form.startAt).toISOString() : null,
      expiredAt: form.expiredAt ? new Date(form.expiredAt).toISOString() : null,
      isActive: form.isActive,
      memberOnly: form.memberOnly,
      minTier: form.minTier || null,
      pointCost: form.type === 'POINT_REDEEM' ? (form.pointCost ? Number(form.pointCost) : null) : null,
      perMemberLimit: form.perMemberLimit ? Number(form.perMemberLimit) : null,
    }
    if (editingId.value) {
      await http.patch(API_ENDPOINTS.ADMIN.COUPONS.UPDATE(editingId.value), body)
      showSuccess('อัปเดตคูปองแล้ว')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.COUPONS.CREATE, body)
      showSuccess('สร้างคูปองแล้ว')
    }
    showForm.value = false
    load()
  } catch (e: any) {
    showError(e?.message ?? 'บันทึกไม่สำเร็จ')
  } finally {
    isSaving.value = false
  }
}

async function handleToggleActive(c: Coupon) {
  try {
    await http.patch(API_ENDPOINTS.ADMIN.COUPONS.UPDATE(c.id), { isActive: !c.isActive })
    showSuccess(c.isActive ? 'ปิดคูปองแล้ว' : 'เปิดคูปองแล้ว')
    load()
  } catch (e: any) {
    showError(e?.message ?? 'เปลี่ยนสถานะไม่สำเร็จ')
  }
}

async function handleDelete(c: Coupon) {
  const ok = await showConfirm({
    title: 'ลบคูปอง',
    message: `ลบคูปอง "${c.name}" (${c.code})?`,
    confirmText: 'ลบ',
  })
  if (!ok) return
  try {
    await http.delete(API_ENDPOINTS.ADMIN.COUPONS.DELETE(c.id))
    showSuccess('ลบคูปองแล้ว')
    load()
  } catch (e: any) {
    showError(e?.message ?? 'ลบไม่สำเร็จ')
  }
}

function formatDate(d: string | null) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}

function discountLabel(c: Coupon) {
  if (c.benefitType === 'FREE_ITEM') return 'ของแถม'
  return c.discountKind === 'PERCENT'
    ? `${Number(c.discountValue).toFixed(0)}%`
    : `฿${Number(c.discountValue).toFixed(0)}`
}

const typeLabel: Record<CouponType, string> = {
  POINT_REDEEM: 'แลกแต้ม',
  PROMOTION: 'โปรโมชัน',
  DISCOUNT: 'ส่วนลด',
}

const typeColor: Record<CouponType, string> = {
  POINT_REDEEM: 'bg-amber-100 text-amber-700',
  PROMOTION: 'bg-purple-100 text-purple-700',
  DISCOUNT: 'bg-blue-100 text-blue-700',
}

// When type changes, update defaults
watch(() => form.type, (t) => {
  if (t === 'POINT_REDEEM') { form.memberOnly = true }
  if (t !== 'POINT_REDEEM') { form.pointCost = null }
})

watch(() => form.benefitType, (b) => {
  if (b === 'FREE_ITEM') { form.discountValue = 0 }
})

onMounted(() => load())
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold" style="color: #1B2B4B;">คูปอง</h1>
        <p class="text-sm text-gray-500 mt-0.5">จัดการคูปองส่วนลดทั้งหมด · {{ totalCount }} รายการ</p>
      </div>
      <button
        class="px-4 py-2.5 text-white text-sm font-semibold rounded-xl shadow hover:opacity-90 transition"
        style="background: #1B2B4B;"
        @click="openNew"
      >
        + สร้างคูปอง
      </button>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-2xl shadow overflow-hidden">
      <table class="w-full text-sm">
        <thead style="background: #C8D8E8;">
          <tr>
            <th class="text-left px-5 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">รหัส / ชื่อ</th>
            <th class="text-center px-4 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">ประเภท</th>
            <th class="text-center px-4 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">มูลค่า</th>
            <th class="text-center px-4 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">ใช้แล้ว/สูงสุด</th>
            <th class="text-center px-4 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">หมดอายุ</th>
            <th class="text-center px-4 py-3.5 font-semibold text-xs uppercase tracking-wide" style="color: #1B2B4B;">สถานะ</th>
            <th class="px-4 py-3.5" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="7" class="text-center py-12 text-gray-400">กำลังโหลด...</td>
          </tr>
          <tr v-else-if="coupons.length === 0">
            <td colspan="7" class="text-center py-12 text-gray-400">ยังไม่มีคูปอง</td>
          </tr>
          <tr
            v-for="c in coupons"
            :key="c.id"
            class="border-b border-gray-100 hover:bg-blue-50/40 transition-colors"
          >
            <td class="px-5 py-3.5">
              <div class="flex items-center gap-2 flex-wrap">
                <span class="font-mono text-xs bg-gray-100 px-2 py-0.5 rounded font-semibold text-gray-700">{{ c.code }}</span>
              </div>
              <p class="font-medium text-gray-900 mt-0.5">{{ c.name }}</p>
              <p v-if="c.description" class="text-xs text-gray-400 truncate max-w-xs">{{ c.description }}</p>
            </td>
            <td class="px-4 py-3.5 text-center">
              <span class="inline-flex px-2.5 py-1 rounded-full text-xs font-semibold" :class="typeColor[c.type]">
                {{ typeLabel[c.type] }}
              </span>
              <div v-if="c.benefitType === 'FREE_ITEM'" class="mt-1">
                <span class="text-xs bg-orange-100 text-orange-700 px-2 py-0.5 rounded-full">ของแถม</span>
              </div>
            </td>
            <td class="px-4 py-3.5 text-center font-bold text-gray-900">
              {{ discountLabel(c) }}
              <div v-if="c.type === 'POINT_REDEEM' && c.pointCost" class="text-xs text-amber-600 font-normal mt-0.5">
                {{ c.pointCost }} แต้ม
              </div>
            </td>
            <td class="px-4 py-3.5 text-center text-gray-600">
              {{ c.usedCount }}<span class="text-gray-300"> / </span>{{ c.maxUses ?? '∞' }}
            </td>
            <td class="px-4 py-3.5 text-center text-gray-500 text-xs">
              {{ formatDate(c.expiredAt) }}
            </td>
            <td class="px-4 py-3.5 text-center">
              <button
                class="inline-flex px-2.5 py-1 rounded-full text-xs font-semibold transition hover:opacity-80"
                :class="c.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
                @click="handleToggleActive(c)"
              >
                {{ c.isActive ? 'เปิดอยู่' : 'ปิดอยู่' }}
              </button>
            </td>
            <td class="px-4 py-3.5 text-right">
              <div class="flex justify-end gap-3">
                <button class="text-xs font-medium text-blue-600 hover:text-blue-800" @click="openEdit(c)">แก้ไข</button>
                <button class="text-xs font-medium text-red-500 hover:text-red-700" @click="handleDelete(c)">ลบ</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="flex items-center justify-between mt-4 text-sm text-gray-600">
      <span>หน้า {{ currentPage }} จาก {{ totalPages }} ({{ totalCount }} รายการ)</span>
      <div class="flex gap-1">
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          :disabled="currentPage <= 1"
          @click="load(currentPage - 1)"
        >
          ‹ ก่อนหน้า
        </button>
        <button
          v-for="p in totalPages"
          :key="p"
          class="px-3 py-1.5 rounded-lg border transition"
          :class="p === currentPage
            ? 'text-white border-transparent font-semibold'
            : 'border-gray-200 hover:bg-gray-50'"
          :style="p === currentPage ? 'background: #1B2B4B;' : ''"
          @click="load(p)"
        >
          {{ p }}
        </button>
        <button
          class="px-3 py-1.5 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          :disabled="currentPage >= totalPages"
          @click="load(currentPage + 1)"
        >
          ถัดไป ›
        </button>
      </div>
    </div>

    <!-- Form Modal -->
    <Teleport to="body">
      <div v-if="showForm" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/50" @click="showForm = false" />
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-xl max-h-[90vh] overflow-y-auto">
          <!-- Modal Header -->
          <div class="sticky top-0 bg-white rounded-t-2xl px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h2 class="text-lg font-bold" style="color: #1B2B4B;">
              {{ editingId ? 'แก้ไขคูปอง' : 'สร้างคูปองใหม่' }}
            </h2>
            <button class="text-gray-400 hover:text-gray-600 text-xl leading-none" @click="showForm = false">&times;</button>
          </div>

          <form class="p-6 space-y-4" @submit.prevent="handleSave">
            <!-- Code -->
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-1">รหัสคูปอง <span class="text-gray-400">(ว่างไว้ = auto-gen)</span></label>
              <input
                v-model="form.code"
                type="text"
                placeholder="เช่น SAVE10, WELCOME"
                class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono uppercase"
                @input="form.code = (form.code as string).toUpperCase()"
              />
            </div>

            <!-- Name -->
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-1">ชื่อคูปอง <span class="text-red-500">*</span></label>
              <input
                v-model="form.name"
                type="text"
                required
                placeholder="เช่น คูปองต้อนรับสมาชิกใหม่"
                class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <!-- Coupon Type -->
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-2">ประเภทคูปอง <span class="text-red-500">*</span></label>
              <div class="grid grid-cols-3 gap-2">
                <button
                  v-for="t in (['DISCOUNT', 'PROMOTION', 'POINT_REDEEM'] as CouponType[])"
                  :key="t"
                  type="button"
                  class="py-2 px-3 rounded-xl border-2 text-xs font-semibold transition-all"
                  :class="form.type === t
                    ? 'border-[#1B2B4B] text-[#1B2B4B] bg-[#f0f5fa]'
                    : 'border-gray-200 text-gray-500 hover:border-gray-300'"
                  @click="form.type = t"
                >
                  {{ typeLabel[t] }}
                </button>
              </div>
              <p v-if="form.type === 'POINT_REDEEM'" class="mt-1 text-xs text-amber-600">สำหรับคูปองที่ลูกค้าแลกด้วยแต้ม</p>
              <p v-else-if="form.type === 'PROMOTION'" class="mt-1 text-xs text-purple-600">สำหรับโปรโมชันที่มีเงื่อนไขขั้นต่ำ</p>
              <p v-else class="mt-1 text-xs text-gray-400">ส่วนลดทั่วไป ใส่โค้ดรับส่วนลด</p>
            </div>

            <!-- Description -->
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-1">รายละเอียด</label>
              <textarea
                v-model="form.description"
                rows="2"
                placeholder="รายละเอียดเพิ่มเติม..."
                class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              />
            </div>

            <!-- Benefit Type (PROMOTION only) -->
            <div v-if="form.type === 'PROMOTION'" class="p-3 rounded-xl border border-purple-200 bg-purple-50 space-y-3">
              <p class="text-xs font-semibold text-purple-700">รูปแบบสิทธิประโยชน์</p>
              <div class="flex gap-3">
                <label class="flex items-center gap-2 cursor-pointer">
                  <input v-model="form.benefitType" type="radio" value="DISCOUNT" class="accent-purple-600" />
                  <span class="text-sm text-gray-700">ลดราคา</span>
                </label>
                <label class="flex items-center gap-2 cursor-pointer">
                  <input v-model="form.benefitType" type="radio" value="FREE_ITEM" class="accent-purple-600" />
                  <span class="text-sm text-gray-700">ของแถม</span>
                </label>
              </div>
              <div v-if="form.benefitType === 'FREE_ITEM'">
                <label class="block text-xs font-medium text-gray-500 mb-1">รายละเอียดของแถม <span class="text-red-500">*</span></label>
                <input
                  v-model="form.freeItemDescription"
                  type="text"
                  placeholder="เช่น ซื้อ 2 แถม 1 ขนาด S"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-purple-400"
                />
                <p class="text-xs text-gray-400 mt-1">แคชเชียร์จะเห็นข้อความนี้เมื่อใช้คูปอง</p>
              </div>
              <!-- Promo conditions -->
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">จำนวนขั้นต่ำ (ชิ้น)</label>
                  <input
                    v-model.number="form.minQuantity"
                    type="number"
                    min="1"
                    step="1"
                    placeholder="ไม่จำกัด"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">ยอดขั้นต่ำ (฿)</label>
                  <input
                    v-model.number="form.minOrderAmount"
                    type="number"
                    min="0"
                    step="1"
                    placeholder="ไม่จำกัด"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>

            <!-- Point Cost (POINT_REDEEM only) -->
            <div v-if="form.type === 'POINT_REDEEM'" class="p-3 rounded-xl border border-amber-200 bg-amber-50 space-y-3">
              <p class="text-xs font-semibold text-amber-700">ตั้งค่าแลกแต้ม</p>
              <div class="grid grid-cols-2 gap-3">
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">แต้มที่ต้องใช้ <span class="text-red-500">*</span></label>
                  <input
                    v-model.number="form.pointCost"
                    type="number"
                    min="1"
                    step="1"
                    placeholder="เช่น 100"
                    required
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400"
                  />
                </div>
                <div>
                  <label class="block text-xs font-medium text-gray-500 mb-1">จำกัดต่อคน (ครั้ง)</label>
                  <input
                    v-model.number="form.perMemberLimit"
                    type="number"
                    min="1"
                    step="1"
                    placeholder="ไม่จำกัด"
                    class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-amber-400"
                  />
                </div>
              </div>
            </div>

            <!-- Discount Kind + Value (shown when benefitType != FREE_ITEM) -->
            <div v-if="form.benefitType !== 'FREE_ITEM'" class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">ประเภทส่วนลด</label>
                <select
                  v-model="form.discountKind"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="PERCENT">เปอร์เซ็นต์ (%)</option>
                  <option value="AMOUNT">จำนวนเงิน (฿)</option>
                </select>
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">
                  มูลค่า {{ form.discountKind === 'PERCENT' ? '(%)' : '(฿)' }} <span class="text-red-500">*</span>
                </label>
                <input
                  v-model.number="form.discountValue"
                  type="number"
                  min="0"
                  :max="form.discountKind === 'PERCENT' ? 100 : undefined"
                  step="1"
                  required
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <!-- General conditions (DISCOUNT / non-PROMOTION) -->
            <div v-if="form.type !== 'PROMOTION'" class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">ยอดขั้นต่ำ (฿)</label>
                <input
                  v-model.number="form.minOrderAmount"
                  type="number"
                  min="0"
                  step="1"
                  placeholder="ไม่จำกัด"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">จำนวนสิทธิ์สูงสุด</label>
                <input
                  v-model.number="form.maxUses"
                  type="number"
                  min="1"
                  step="1"
                  placeholder="ไม่จำกัด"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <!-- Max uses for PROMOTION -->
            <div v-if="form.type === 'PROMOTION'" class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">จำนวนสิทธิ์สูงสุด</label>
                <input
                  v-model.number="form.maxUses"
                  type="number"
                  min="1"
                  step="1"
                  placeholder="ไม่จำกัด"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">จำกัดต่อคน (ครั้ง)</label>
                <input
                  v-model.number="form.perMemberLimit"
                  type="number"
                  min="1"
                  step="1"
                  placeholder="ไม่จำกัด"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <!-- Dates -->
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">วันเริ่มต้น</label>
                <input
                  v-model="form.startAt"
                  type="datetime-local"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">วันหมดอายุ</label>
                <input
                  v-model="form.expiredAt"
                  type="datetime-local"
                  class="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

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
            <div class="flex flex-col gap-2 pt-1">
              <label class="flex items-center gap-3 cursor-pointer">
                <div
                  class="relative w-10 h-5 rounded-full transition"
                  :class="form.isActive ? 'bg-green-500' : 'bg-gray-300'"
                  @click="form.isActive = !form.isActive"
                >
                  <span
                    class="absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform"
                    :class="form.isActive ? 'translate-x-5' : ''"
                  />
                </div>
                <span class="text-sm text-gray-700 font-medium">เปิดใช้งานคูปอง</span>
              </label>
              <label class="flex items-center gap-3 cursor-pointer">
                <div
                  class="relative w-10 h-5 rounded-full transition"
                  :class="form.memberOnly ? 'bg-blue-500' : 'bg-gray-300'"
                  @click="form.memberOnly = !form.memberOnly"
                >
                  <span
                    class="absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform"
                    :class="form.memberOnly ? 'translate-x-5' : ''"
                  />
                </div>
                <span class="text-sm text-gray-700 font-medium">เฉพาะสมาชิกเท่านั้น</span>
              </label>
            </div>

            <!-- Actions -->
            <div class="flex gap-3 pt-2">
              <button
                type="button"
                class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50 font-medium"
                @click="showForm = false"
              >
                ยกเลิก
              </button>
              <button
                type="submit"
                class="flex-1 py-2.5 rounded-xl text-white text-sm font-semibold hover:opacity-90 disabled:opacity-50 transition"
                style="background: #1B2B4B;"
                :disabled="isSaving || !form.name"
              >
                {{ isSaving ? 'กำลังบันทึก...' : editingId ? 'บันทึกการเปลี่ยนแปลง' : 'สร้างคูปอง' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>
