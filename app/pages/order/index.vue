<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'public' })

const http = useHttpClient()
const { showSuccess, showError } = useAlert()
const router = useRouter()
const { member: authedMember, fetchMe } = useMemberAuth()

const checkingSession = ref(true)

// ─── Types ────────────────────────────────────────────────────────────────────
interface Product {
  id: string
  name: string
  price: string | number
  imageUrl: string | null
  category: { id: string; name: string }
  optionGroups: {
    optionGroup: {
      id: string
      name: string
      required: boolean
      multiSelect: boolean
      options: { id: string; name: string; extraPrice: string | number; isActive: boolean }[]
    }
  }[]
}

interface CartItem {
  product: Product
  quantity: number
  selectedOptions: { optionId: string; name: string; extraPrice: number }[]
  note: string
}

// ─── State ────────────────────────────────────────────────────────────────────
const products = ref<Product[]>([])
const cart = ref<CartItem[]>([])
const loading = ref(true)
const placing = ref(false)
const step = ref<1 | 2>(1)

const guestName = ref('')
const paymentMethod = ref<'CASH' | 'CARD' | 'QR' | 'THAI_HELP'>('QR')
const orderNote = ref('')
const pickupTime = ref('')

// ─── Phone lookup (ผูกสมาชิกถ้าเจอ) ────────────────────────────────────────────
interface FoundMember { id: string; name: string; phone: string; tier: string }
const phoneInput = ref('')
const foundMember = ref<FoundMember | null>(null)
const lookingUpMember = ref(false)
const memberLookupError = ref('')

async function lookupMemberByPhone() {
  if (!phoneInput.value.trim()) return
  lookingUpMember.value = true
  memberLookupError.value = ''
  try {
    const res = await http.get<{ data: FoundMember }>(API_ENDPOINTS.PUBLIC.MEMBER_LOOKUP, { phone: phoneInput.value.trim() })
    foundMember.value = res.data
    if (res.data) guestName.value = res.data.name
  } catch (e: any) {
    foundMember.value = null
    memberLookupError.value = e?.data?.message ?? 'ไม่พบสมาชิกจากเบอร์นี้'
  } finally {
    lookingUpMember.value = false
  }
}

function clearFoundMember() {
  foundMember.value = null
  phoneInput.value = ''
  memberLookupError.value = ''
}

// ─── Pickup time options ──────────────────────────────────────────────────────
const TZ = 'Asia/Bangkok'

function formatPickupOption(ms: number): { label: string; value: string } {
  const t = new Date(ms)
  const now = new Date()
  const todayDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(now)
  const tDate = new Intl.DateTimeFormat('en-CA', { timeZone: TZ }).format(t)
  const timeStr = new Intl.DateTimeFormat('th-TH', { hour: '2-digit', minute: '2-digit', timeZone: TZ, hour12: false }).format(t)
  const dateLabel = new Intl.DateTimeFormat('th-TH', { day: 'numeric', month: 'short', timeZone: TZ }).format(t)
  const label = tDate !== todayDate ? `${dateLabel} ${timeStr} น.` : `${timeStr} น.`
  return { label, value: `${tDate} ${timeStr}` }
}

const pickupOptions = computed(() => {
  const now = new Date()
  const options: { label: string; value: string }[] = []
  const startMs = (Math.ceil(now.getTime() / (15 * 60 * 1000)) + 1) * 15 * 60 * 1000
  const endMs = now.getTime() + 16 * 60 * 60 * 1000
  for (let ms = startMs; ms <= endMs; ms += 15 * 60 * 1000) {
    options.push(formatPickupOption(ms))
  }
  return options
})

const search = ref('')
const selectedCategory = ref<string | null>(null)

const categories = computed(() => {
  const map = new Map<string, string>()
  products.value.forEach(p => map.set(p.category.id, p.category.name))
  return Array.from(map.entries()).map(([id, name]) => ({ id, name }))
})

const filteredProducts = computed(() => {
  let list = [...products.value]
  if (selectedCategory.value) list = list.filter(p => p.category.id === selectedCategory.value)
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(p => p.name.toLowerCase().includes(q))
  }
  return list
})

// ─── Option modal ─────────────────────────────────────────────────────────────
const modalProduct = ref<Product | null>(null)
const modalOptions = reactive<Record<string, string[]>>({})
const modalQty = ref(1)
const editingIndex = ref<number | null>(null)

function openModal(product: Product, cartIndex?: number) {
  modalProduct.value = product
  editingIndex.value = cartIndex ?? null
  for (const key of Object.keys(modalOptions)) delete modalOptions[key]

  if (cartIndex !== undefined) {
    const item = cart.value[cartIndex]
    modalQty.value = item.quantity
    for (const pg of product.optionGroups) {
      modalOptions[pg.optionGroup.id] = item.selectedOptions
        .filter(o => pg.optionGroup.options.some(opt => opt.id === o.optionId))
        .map(o => o.optionId)
    }
  } else {
    modalQty.value = 1
    for (const pg of product.optionGroups) {
      if (!pg.optionGroup.multiSelect && pg.optionGroup.required) {
        const first = pg.optionGroup.options.find(o => o.isActive)
        modalOptions[pg.optionGroup.id] = first ? [first.id] : []
      } else {
        modalOptions[pg.optionGroup.id] = []
      }
    }
  }
}

function toggleOption(groupId: string, optionId: string, multiSelect: boolean) {
  const current = modalOptions[groupId] ?? []
  modalOptions[groupId] = multiSelect
    ? (current.includes(optionId) ? current.filter(id => id !== optionId) : [...current, optionId])
    : (current.includes(optionId) ? [] : [optionId])
}

function confirmModal() {
  if (!modalProduct.value) return
  const product = modalProduct.value
  for (const pg of product.optionGroups) {
    const g = pg.optionGroup
    if (g.required && !(modalOptions[g.id]?.length > 0)) {
      showError(`กรุณาเลือก "${g.name}"`)
      return
    }
  }
  const selectedOptions: CartItem['selectedOptions'] = []
  for (const pg of product.optionGroups) {
    for (const optId of (modalOptions[pg.optionGroup.id] ?? [])) {
      const opt = pg.optionGroup.options.find(o => o.id === optId)
      if (opt) selectedOptions.push({ optionId: opt.id, name: opt.name, extraPrice: Number(opt.extraPrice) })
    }
  }
  const qty = modalQty.value

  if (editingIndex.value !== null) {
    cart.value[editingIndex.value] = { ...cart.value[editingIndex.value], selectedOptions, quantity: qty }
  } else {
    const existing = cart.value.find(
      c => c.product.id === product.id &&
      JSON.stringify(c.selectedOptions.map(o => o.optionId).sort()) ===
      JSON.stringify(selectedOptions.map(o => o.optionId).sort())
    )
    if (existing) { existing.quantity += qty }
    else { cart.value.push({ product, quantity: qty, selectedOptions, note: '' }) }
  }
  modalProduct.value = null
  editingIndex.value = null
}

function removeItem(index: number) { cart.value.splice(index, 1) }

// ─── Totals ───────────────────────────────────────────────────────────────────
const subtotal = computed(() =>
  cart.value.reduce((sum, item) => {
    const base = Number(item.product.price)
    const extra = item.selectedOptions.reduce((s, o) => s + o.extraPrice, 0)
    return sum + (base + extra) * item.quantity
  }, 0)
)

const cartCount = computed(() => cart.value.reduce((s, i) => s + i.quantity, 0))

// ─── Load data ────────────────────────────────────────────────────────────────
onMounted(async () => {
  if (!authedMember.value) await fetchMe()
  if (authedMember.value) {
    await router.replace('/member/orders/new')
    return
  }
  checkingSession.value = false

  try {
    const res = await http.get<{ data: Product[] }>(API_ENDPOINTS.PUBLIC.PRODUCTS)
    products.value = res.data ?? []
  } catch {
    // silent
  } finally {
    loading.value = false
  }
})

// ─── Payment labels ───────────────────────────────────────────────────────────
const paymentOptions = [
  { value: 'QR' as const, label: 'QR / โอนเงิน', icon: 'mdi:qrcode' },
  { value: 'CASH' as const, label: 'เงินสด', icon: 'mdi:cash' },
  { value: 'THAI_HELP' as const, label: 'โครงการรัฐ', icon: 'mdi:hand-heart' },
]

// ─── Place order ──────────────────────────────────────────────────────────────
const successData = ref<{ id: string; queueNo: number; total: number } | null>(null)

async function proceedToPayment() {
  if (cartCount.value === 0) return
  if (!guestName.value.trim()) { showError('กรุณาระบุชื่อ'); return }
  if (!pickupTime.value && pickupOptions.value.length > 0) {
    pickupTime.value = pickupOptions.value[0].value
  }
  step.value = 2
}

async function placeOrder() {
  if (cart.value.length === 0) return
  if (!guestName.value.trim()) { showError('กรุณาระบุชื่อ'); return }

  placing.value = true
  try {
    const res = await http.post<{ data: { id: string; queueNo: number; total: number } }>(
      API_ENDPOINTS.PUBLIC.WEBAPP_ORDER,
      {
        guestName: guestName.value.trim(),
        items: cart.value.map(item => ({
          productId: item.product.id,
          quantity: item.quantity,
          options: item.selectedOptions,
          note: item.note || undefined,
        })),
        note: orderNote.value || undefined,
        pickupTime: pickupTime.value || undefined,
        paymentMethod: paymentMethod.value,
        memberId: foundMember.value?.id,
      }
    )
    if (res.data) {
      successData.value = res.data
      cart.value = []
    }
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'สั่งสินค้าไม่สำเร็จ')
  } finally {
    placing.value = false
  }
}

const steps = [
  { num: 1, label: 'เลือกสินค้า' },
  { num: 2, label: 'ยืนยันออเดอร์' },
]
</script>

<template>
  <div class="max-w-lg mx-auto px-4 pb-28 pt-4">

    <!-- Checking session (avoid flashing guest form before redirect) -->
    <div v-if="checkingSession" class="flex items-center justify-center py-24 text-gray-400">
      <Icon name="mdi:loading" class="text-3xl animate-spin" />
    </div>

    <!-- Success screen -->
    <div v-else-if="successData" class="flex flex-col items-center justify-center py-16 text-center gap-5">
      <div class="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center">
        <Icon name="mdi:check-circle" class="text-5xl text-green-500" />
      </div>
      <div>
        <h2 class="text-xl font-bold text-gray-900">สั่งสำเร็จ!</h2>
        <p class="text-gray-500 mt-1 text-sm">คิวของคุณหมายเลข <span class="font-bold text-gray-900">#{{ successData.queueNo }}</span></p>
        <p class="text-gray-500 text-sm">ยอดทั้งหมด ฿{{ successData.total.toFixed(0) }}</p>
      </div>
      <p class="text-sm text-gray-400">กรุณารอรับสินค้าที่ร้าน</p>
      <div class="flex flex-col sm:flex-row gap-3 w-full max-w-xs">
        <NuxtLink
          to="/"
          class="flex-1 text-center px-6 py-3 border-2 border-[#1B2B4B] text-[#1B2B4B] font-bold rounded-2xl hover:bg-[#F0F4F8] transition-colors"
        >
          เสร็จสิ้น
        </NuxtLink>
        <button
          class="flex-1 px-6 py-3 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] transition-colors"
          @click="successData = null; step = 1; guestName = ''; orderNote = ''; pickupTime = ''; clearFoundMember()"
        >
          สั่งอีกครั้ง
        </button>
      </div>
    </div>

    <template v-else>
      <!-- Header -->
      <div class="flex items-center gap-3 mb-4">
        <button v-if="step === 2" class="text-gray-400 hover:text-gray-600" @click="step = 1">
          <Icon name="mdi:chevron-left" class="w-6 h-6" />
        </button>
        <h1 class="text-xl font-bold text-gray-900">สั่งสินค้า</h1>
      </div>

      <!-- Step indicator -->
      <div class="flex items-center justify-center mb-6 select-none">
        <template v-for="(s, idx) in steps" :key="s.num">
          <div class="flex flex-col items-center gap-1">
            <div
              class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold transition-colors"
              :class="step === s.num
                ? 'bg-[#1B2B4B] text-white shadow-md'
                : step > s.num
                  ? 'bg-[#C8D8E8] text-[#1B2B4B]'
                  : 'bg-gray-100 text-gray-400'"
            >{{ s.num }}</div>
            <span
              class="text-xs font-medium transition-colors"
              :class="step === s.num ? 'text-[#1B2B4B]' : step > s.num ? 'text-[#2a3f6b]' : 'text-gray-400'"
            >{{ s.label }}</span>
          </div>
          <div
            v-if="idx < steps.length - 1"
            class="h-0.5 w-10 mx-1 mb-5 rounded transition-colors"
            :class="step > s.num ? 'bg-[#C8D8E8]' : 'bg-gray-200'"
          />
        </template>
      </div>

      <!-- ── STEP 1: เลือกสินค้า ── -->
      <div v-if="step === 1" class="space-y-4">

        <!-- เบอร์โทร (สมาชิก) -->
        <div class="bg-white rounded-2xl shadow p-4">
          <label class="text-sm font-semibold text-gray-700 mb-2 block">เบอร์โทร (สำหรับสมาชิก ไม่บังคับ)</label>
          <div v-if="!foundMember" class="flex gap-2">
            <input
              v-model="phoneInput"
              type="tel"
              placeholder="กรอกเบอร์โทรเพื่อรับแต้ม/แสตมป์..."
              maxlength="20"
              class="flex-1 border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              @keyup.enter="lookupMemberByPhone"
            />
            <button
              type="button"
              :disabled="lookingUpMember || !phoneInput.trim()"
              class="px-4 py-2.5 bg-[#1B2B4B] text-white text-sm font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-40 transition-colors flex-shrink-0"
              @click="lookupMemberByPhone"
            >{{ lookingUpMember ? '...' : 'ค้นหา' }}</button>
          </div>
          <div v-else class="flex items-center gap-2 p-2.5 rounded-lg bg-green-50 border border-green-200">
            <Icon name="mdi:check-decagram" class="text-green-600 text-lg flex-shrink-0" />
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">{{ foundMember.name }}</p>
              <p class="text-xs text-green-600">เป็นสมาชิก · จะได้รับแต้ม/แสตมป์จากออเดอร์นี้</p>
            </div>
            <button class="text-gray-400 hover:text-red-500 text-lg flex-shrink-0" @click="clearFoundMember">×</button>
          </div>
          <p v-if="memberLookupError" class="text-xs text-red-500 mt-1.5">{{ memberLookupError }}</p>
        </div>

        <!-- ชื่อผู้สั่ง -->
        <div class="bg-white rounded-2xl shadow p-4">
          <label class="text-sm font-semibold text-gray-700 mb-2 block">
            ชื่อผู้สั่ง <span class="text-red-500">*</span>
          </label>
          <input
            v-model="guestName"
            type="text"
            placeholder="ระบุชื่อของคุณ..."
            maxlength="100"
            class="w-full border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
          />
        </div>

        <!-- Search + category -->
        <div class="space-y-2">
          <input
            v-model="search"
            type="text"
            placeholder="ค้นหาเมนู..."
            class="w-full border border-gray-300 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
          />
          <div class="flex gap-2 overflow-x-auto pb-1">
            <button
              class="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap flex-shrink-0 transition-colors"
              :class="!selectedCategory ? 'bg-[#1B2B4B] text-white' : 'bg-gray-100 text-gray-600'"
              @click="selectedCategory = null"
            >ทั้งหมด</button>
            <button
              v-for="cat in categories"
              :key="cat.id"
              class="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap flex-shrink-0 transition-colors"
              :class="selectedCategory === cat.id ? 'bg-[#1B2B4B] text-white' : 'bg-gray-100 text-gray-600'"
              @click="selectedCategory = cat.id"
            >{{ cat.name }}</button>
          </div>
        </div>

        <div v-if="loading" class="text-center py-12 text-gray-400">กำลังโหลดเมนู...</div>
        <div v-else-if="filteredProducts.length === 0" class="text-center py-12 text-gray-400 text-sm">ไม่พบสินค้า</div>
        <div v-else class="grid grid-cols-2 gap-3">
          <button
            v-for="product in filteredProducts"
            :key="product.id"
            type="button"
            class="bg-white rounded-xl shadow p-3 text-left hover:shadow-md hover:ring-2 hover:ring-[#C8D8E8] transition-all active:scale-95"
            @click="openModal(product)"
          >
            <div class="w-full h-24 bg-[#F0F4F8] rounded-lg mb-2 overflow-hidden">
              <img v-if="product.imageUrl" :src="product.imageUrl" class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center">
                <Icon name="flat-color-icons:shop" class="text-4xl" />
              </div>
            </div>
            <p class="text-sm font-semibold text-gray-800 line-clamp-1">{{ product.name }}</p>
            <p class="text-xs text-[#2a3f6b] font-medium mt-0.5">฿{{ Number(product.price).toFixed(0) }}</p>
          </button>
        </div>
      </div>

      <!-- ── STEP 2: ยืนยันออเดอร์ ── -->
      <div v-else-if="step === 2" class="space-y-4">

        <!-- รายการสินค้า -->
        <div class="bg-white rounded-2xl shadow p-4 space-y-3">
          <h2 class="font-semibold text-gray-700 text-sm">รายการที่สั่ง</h2>
          <div
            v-for="(item, index) in cart"
            :key="index"
            class="flex items-start justify-between gap-3 py-2 border-b border-gray-50 last:border-0"
          >
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-800">{{ item.product.name }}</p>
              <p class="text-xs text-gray-400 mt-0.5 truncate">
                {{ item.selectedOptions.map(o => o.name).join(', ') || 'ไม่มีตัวเลือก' }}
              </p>
            </div>
            <div class="flex items-center gap-2 flex-shrink-0">
              <span class="text-xs text-gray-500">x{{ item.quantity }}</span>
              <span class="text-sm font-semibold text-gray-800">
                ฿{{ ((Number(item.product.price) + item.selectedOptions.reduce((s, o) => s + o.extraPrice, 0)) * item.quantity).toFixed(0) }}
              </span>
              <button type="button" class="text-gray-300 hover:text-[#1B2B4B] p-0.5" @click="openModal(item.product, index)">
                <Icon name="mdi:pencil-outline" class="w-4 h-4" />
              </button>
              <button type="button" class="text-gray-300 hover:text-red-500 p-0.5" @click="removeItem(index)">
                <Icon name="mdi:close" class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        <!-- ชื่อผู้รับ -->
        <div class="bg-white rounded-2xl shadow p-4">
          <label class="text-sm font-semibold text-gray-700 mb-2 block">ชื่อผู้รับ</label>
          <p class="text-base font-bold text-gray-900">{{ guestName }}</p>
        </div>

        <!-- ช่องทางชำระ -->
        <div class="bg-white rounded-2xl shadow p-4">
          <p class="text-sm font-semibold text-gray-700 mb-3">ช่องทางชำระเงิน</p>
          <div class="grid grid-cols-3 gap-2">
            <button
              v-for="opt in paymentOptions"
              :key="opt.value"
              type="button"
              class="flex flex-col items-center gap-1.5 p-3 rounded-xl border-2 transition-colors text-sm font-medium"
              :class="paymentMethod === opt.value
                ? 'border-[#1B2B4B] bg-[#F0F4F8] text-[#1B2B4B]'
                : 'border-gray-200 text-gray-600 hover:border-gray-300'"
              @click="paymentMethod = opt.value"
            >
              <Icon :name="opt.icon" class="text-xl" />
              <span class="text-xs text-center leading-tight">{{ opt.label }}</span>
            </button>
          </div>
        </div>

        <!-- เวลารับ -->
        <div class="bg-white rounded-2xl shadow p-4">
          <p class="text-sm font-semibold text-gray-700 mb-2">เวลารับสินค้า (ไม่บังคับ)</p>
          <select
            v-model="pickupTime"
            class="w-full border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
          >
            <option value="">ไม่ระบุ</option>
            <option v-for="t in pickupOptions" :key="t.value" :value="t.value">{{ t.label }}</option>
          </select>
        </div>

        <!-- หมายเหตุ -->
        <div class="bg-white rounded-2xl shadow p-4">
          <p class="text-sm font-semibold text-gray-700 mb-2">หมายเหตุ (ไม่บังคับ)</p>
          <textarea
            v-model="orderNote"
            rows="2"
            placeholder="เช่น ไม่เอาน้ำแข็ง..."
            class="w-full border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] resize-none"
          />
        </div>

        <!-- ยอดรวม -->
        <div class="bg-white rounded-2xl shadow p-4">
          <div class="flex justify-between font-bold text-gray-900 text-base">
            <span>รวมทั้งหมด</span>
            <span>฿{{ subtotal.toFixed(0) }}</span>
          </div>
        </div>

        <!-- ยืนยัน -->
        <button
          :disabled="placing || cart.length === 0"
          class="w-full py-3.5 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors text-base shadow"
          @click="placeOrder"
        >
          {{ placing ? 'กำลังสั่ง...' : 'ยืนยันการสั่ง' }}
        </button>
      </div>
    </template>

    <!-- ── Sticky bottom bar (step 1) ── -->
    <Teleport to="body">
      <div v-if="step === 1 && !successData" class="fixed bottom-0 left-0 right-0 z-40">
        <div class="max-w-lg mx-auto px-4 pb-20 pt-2">
          <div
            class="bg-[#1B2B4B] rounded-2xl shadow-2xl px-5 py-3.5 flex items-center justify-between gap-4 transition-all"
            :class="cartCount === 0 ? 'opacity-60' : 'opacity-100'"
          >
            <div class="flex items-center gap-2.5">
              <div class="relative">
                <Icon name="mdi:cart-outline" class="text-white w-6 h-6" />
                <span
                  v-if="cartCount > 0"
                  class="absolute -top-1.5 -right-1.5 bg-red-500 text-white text-[10px] font-bold w-4 h-4 rounded-full flex items-center justify-center leading-none"
                >{{ cartCount }}</span>
              </div>
              <div>
                <p class="text-[10px] text-[#C8D8E8] leading-tight">{{ cartCount }} รายการ</p>
                <p class="text-white font-bold text-sm leading-tight">฿{{ subtotal.toFixed(0) }}</p>
              </div>
            </div>
            <button
              :disabled="cartCount === 0"
              class="bg-white text-[#1B2B4B] font-bold text-sm px-5 py-2 rounded-xl hover:bg-[#C8D8E8] disabled:opacity-40 disabled:cursor-not-allowed transition-colors flex-shrink-0"
              @click="proceedToPayment"
            >
              ต่อไป →
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Option modal ── -->
    <Teleport to="body">
      <div v-if="modalProduct" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:bg-black/40 sm:p-4">
        <div class="bg-white sm:rounded-2xl w-full sm:max-w-md h-full sm:h-auto sm:max-h-[85vh] overflow-y-auto shadow-2xl flex flex-col">
          <div class="p-6 border-b border-gray-100 flex items-start justify-between gap-2">
            <div>
              <h3 class="text-lg font-bold text-gray-900">{{ modalProduct.name }}</h3>
              <p class="text-[#2a3f6b] font-semibold mt-1">฿{{ Number(modalProduct.price).toFixed(0) }}</p>
            </div>
            <button class="text-gray-400 hover:text-gray-600 text-2xl leading-none flex-shrink-0 mt-0.5" @click="modalProduct = null">×</button>
          </div>
          <div class="p-6 space-y-5 flex-1">
            <div v-for="pg in [...modalProduct.optionGroups].sort((a, b) => Number(b.optionGroup.required) - Number(a.optionGroup.required))" :key="pg.optionGroup.id">
              <div class="flex items-center gap-2 mb-3">
                <span class="font-semibold text-gray-800">{{ pg.optionGroup.name }}</span>
                <span v-if="pg.optionGroup.required" class="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">จำเป็น</span>
                <span v-if="pg.optionGroup.multiSelect" class="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded-full">เลือกได้หลายอย่าง</span>
              </div>
              <div class="space-y-2">
                <button
                  v-for="opt in pg.optionGroup.options.filter(o => o.isActive)"
                  :key="opt.id"
                  type="button"
                  class="w-full flex items-center justify-between px-4 py-3 rounded-xl border-2 transition-colors text-left"
                  :class="modalOptions[pg.optionGroup.id]?.includes(opt.id) ? 'border-[#C8D8E8] bg-[#F0F4F8]' : 'border-gray-100 bg-white hover:border-gray-200'"
                  @click="toggleOption(pg.optionGroup.id, opt.id, pg.optionGroup.multiSelect)"
                >
                  <span class="text-sm font-medium text-gray-800">{{ opt.name }}</span>
                  <span class="text-sm text-gray-500">{{ Number(opt.extraPrice) > 0 ? `+฿${Number(opt.extraPrice).toFixed(0)}` : 'ฟรี' }}</span>
                </button>
              </div>
            </div>
            <div class="flex items-center justify-between pt-2 border-t border-gray-100">
              <span class="text-sm font-semibold text-gray-700">จำนวน</span>
              <div class="flex items-center gap-3">
                <button
                  type="button"
                  class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 hover:bg-gray-200 text-lg font-bold"
                  @click="modalQty > 1 && modalQty--"
                >−</button>
                <span class="text-base font-bold text-gray-900 w-6 text-center">{{ modalQty }}</span>
                <button
                  type="button"
                  class="w-8 h-8 rounded-full bg-[#C8D8E8] flex items-center justify-center text-[#2a3f6b] hover:bg-[#b0c8e0] text-lg font-bold"
                  @click="modalQty++"
                >+</button>
              </div>
            </div>
          </div>
          <div class="p-6 pt-0 flex gap-3 sticky bottom-0 bg-white border-t border-gray-100 sm:border-none sm:static">
            <button @click="modalProduct = null; editingIndex = null" class="flex-1 py-3 border border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50">ยกเลิก</button>
            <button @click="confirmModal" class="flex-1 py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b]">{{ editingIndex !== null ? 'บันทึก' : 'เพิ่มลงออเดอร์' }}</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
