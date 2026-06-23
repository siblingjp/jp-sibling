<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'
import generatePayload from 'promptpay-qr'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()
const { uploadViaPresign } = useUpload()
const { showSuccess, showError } = useAlert()

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

interface CouponUseItem {
  id: string
  isUsed: boolean
  usedAt: string | null
  coupon: {
    id: string
    code: string
    name: string
    discountKind: 'PERCENT' | 'AMOUNT'
    discountValue: string | number
    expiredAt: string | null
  }
}

interface Campaign {
  id: string
  name: string
  description: string | null
  coupons: {
    id: string
    code: string
    name: string
    discountKind: string
    discountValue: string | number
    pointCost: string | number | null
  }[]
}

// ─── Step state (1 = เลือกสินค้า, 2 = ชำระเงิน) ──────────────────────────────
const step = ref<1 | 2>(1)

// ─── Shop status ──────────────────────────────────────────────────────────────
interface ShopStatus {
  isOpen: boolean
  canOrder: boolean
  manualClose: boolean
  nextOpenLabel: string | null
  nextOpenName: string | null
}
const shopStatus = ref<ShopStatus | null>(null)
const showClosedAlert = ref(false)

// ─── State ────────────────────────────────────────────────────────────────────
const products = ref<Product[]>([])
const frequentProducts = ref<Product[]>([])
const cart = ref<CartItem[]>([])
const loading = ref(true)
const placing = ref(false)

// product filter
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

// option modal
const modalProduct = ref<Product | null>(null)
const modalOptions = reactive<Record<string, string[]>>({})
const modalQty = ref(1)

// coupon picker
const myUses = ref<CouponUseItem[]>([])
const campaigns = ref<Campaign[]>([])
const appliedCouponCode = ref('')
const appliedCouponName = ref('')
const appliedCouponDiscount = ref(0)
const showCouponPicker = ref(false)
const couponInput = ref('')
const couponErrors = ref<Record<string, string>>({})
const couponLoading = ref<Record<string, boolean>>({})

// pickup & slip
const pickupTime = ref('')
const orderNote = ref('')
const slipFiles = ref<{ file: File; preview: string }[]>([])
const uploadingSlip = ref(false)
const MAX_SLIPS = 5

// ─── localStorage cart persist ────────────────────────────────────────────────
const CART_KEY = 'member_order_cart'

function saveCartToStorage() {
  try {
    const serializable = cart.value.map(item => ({
      product: item.product,
      quantity: item.quantity,
      selectedOptions: item.selectedOptions,
      note: item.note,
    }))
    localStorage.setItem(CART_KEY, JSON.stringify(serializable))
  } catch { /* storage full หรือ private mode */ }
}

function loadCartFromStorage() {
  try {
    const raw = localStorage.getItem(CART_KEY)
    if (!raw) return
    const parsed: CartItem[] = JSON.parse(raw)
    if (Array.isArray(parsed) && parsed.length > 0) {
      // validate ว่า product ยังอยู่ใน products list (กรองออกถ้า product ถูกลบ)
      const validItems = parsed.filter(item =>
        item.product?.id && item.quantity > 0
      )
      if (validItems.length > 0) cart.value = validItems
    }
  } catch { /* JSON parse error */ }
}

function clearCartStorage() {
  try { localStorage.removeItem(CART_KEY) } catch { /* */ }
}

watch(cart, saveCartToStorage, { deep: true })

// ─── Load data ────────────────────────────────────────────────────────────────
onMounted(async () => {
  try {
    const [pRes, cRes, campRes, statusRes, freqRes] = await Promise.all([
      http.get<{ data: Product[] }>(API_ENDPOINTS.MEMBER.PRODUCTS),
      http.get<{ data: CouponUseItem[] }>(API_ENDPOINTS.MEMBER.COUPONS.LIST),
      http.get<{ data: Campaign[] }>(API_ENDPOINTS.MEMBER.CAMPAIGNS),
      http.get<{ data: ShopStatus }>(API_ENDPOINTS.PUBLIC.LOCATION_STATUS, undefined, { loading: true }),
      http.get<{ data: Product[] }>(API_ENDPOINTS.MEMBER.ORDERS.FREQUENT),
    ])
    products.value = pRes.data ?? []
    myUses.value = (cRes.data ?? []).filter(u => !u.isUsed)
    campaigns.value = campRes.data ?? []
    shopStatus.value = statusRes.data ?? null
    frequentProducts.value = freqRes.data ?? []

    // restore cart หลังโหลด products เสร็จ (เพื่อ validate product ได้)
    loadCartFromStorage()
  } catch {
    // silent
  } finally {
    loading.value = false
  }
})

// ─── Product modal ────────────────────────────────────────────────────────────
function openModal(product: Product) {
  modalProduct.value = product
  modalQty.value = 1
  for (const key of Object.keys(modalOptions)) delete modalOptions[key]
  for (const pg of product.optionGroups) {
    if (!pg.optionGroup.multiSelect && pg.optionGroup.required) {
      const first = pg.optionGroup.options.find(o => o.isActive)
      modalOptions[pg.optionGroup.id] = first ? [first.id] : []
    } else {
      modalOptions[pg.optionGroup.id] = []
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
  const existing = cart.value.find(
    c => c.product.id === product.id &&
    JSON.stringify(c.selectedOptions.map(o => o.optionId).sort()) ===
    JSON.stringify(selectedOptions.map(o => o.optionId).sort())
  )
  if (existing) { existing.quantity += qty }
  else { cart.value.push({ product, quantity: qty, selectedOptions, note: '' }) }
  modalProduct.value = null
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

const total = computed(() => Math.max(subtotal.value - appliedCouponDiscount.value, 0))

const pointsEarned = computed(() => {
  const multiplier = member.value?.tier === 'VIP' ? 1.5 : member.value?.tier === 'GOLD' ? 1.25 : 1.0
  return Math.floor((total.value / 10) * multiplier)
})

// ─── Coupon picker ────────────────────────────────────────────────────────────
function calcDiscount(discountKind: string, discountValue: string | number) {
  const v = Number(discountValue)
  return discountKind === 'PERCENT'
    ? Math.min((subtotal.value * v) / 100, subtotal.value)
    : Math.min(v, subtotal.value)
}

async function applyCouponFromPicker(code: string, _name: string, _discountKind: string, _discountValue: string | number) {
  if (couponErrors.value[code] || couponLoading.value[code]) return
  couponLoading.value[code] = true
  try {
    const res = await http.post<{ data: { discountAmount: number; coupon?: { name: string } } }>(API_ENDPOINTS.POS.COUPON_VALIDATE, {
      code,
      subtotal: subtotal.value,
      memberId: member.value?.id ?? null,
    })
    appliedCouponCode.value = code
    appliedCouponName.value = res.data?.coupon?.name ?? code
    appliedCouponDiscount.value = Number(res.data?.discountAmount ?? 0)
    showCouponPicker.value = false
    couponInput.value = ''
  } catch (e: any) {
    couponErrors.value[code] = e?.data?.message ?? 'ไม่สามารถใช้คูปองนี้ได้'
  } finally {
    couponLoading.value[code] = false
  }
}

function clearCoupon() {
  appliedCouponCode.value = ''
  appliedCouponName.value = ''
  appliedCouponDiscount.value = 0
}

async function applyManualCoupon() {
  const code = couponInput.value.trim().toUpperCase()
  if (!code) return
  try {
    const res = await http.post<{ data: { discountAmount: number; coupon?: { name: string } } }>(API_ENDPOINTS.POS.COUPON_VALIDATE, {
      code,
      subtotal: subtotal.value,
      memberId: member.value?.id ?? null,
    })
    appliedCouponCode.value = code
    appliedCouponName.value = res.data?.coupon?.name ?? code
    appliedCouponDiscount.value = Number(res.data?.discountAmount ?? 0)
    showCouponPicker.value = false
  } catch (e: any) {
    showError(e?.data?.message ?? 'คูปองไม่ถูกต้อง')
  }
}

function formatCouponLabel(discountKind: string, discountValue: string | number) {
  return discountKind === 'PERCENT' ? `${Number(discountValue)}%` : `฿${Number(discountValue).toFixed(0)}`
}

// ─── Slip upload ──────────────────────────────────────────────────────────────
function onSlipChange(e: Event) {
  const files = Array.from((e.target as HTMLInputElement).files ?? [])
  for (const file of files) {
    if (slipFiles.value.length >= MAX_SLIPS) break
    slipFiles.value.push({ file, preview: URL.createObjectURL(file) })
  }
  ;(e.target as HTMLInputElement).value = ''
}

function removeSlip(index: number) {
  URL.revokeObjectURL(slipFiles.value[index].preview)
  slipFiles.value.splice(index, 1)
}

// ─── Place order ──────────────────────────────────────────────────────────────
async function placeOrder() {
  if (cart.value.length === 0) return
  if (slipFiles.value.length === 0) { showError('กรุณาแนบสลิปการโอนเงิน'); return }
  if (!pickupTime.value) { showError('กรุณาระบุเวลารับสินค้า'); return }

  placing.value = true
  try {
    uploadingSlip.value = true
    const uploaded = await Promise.all(
      slipFiles.value.map(s => uploadViaPresign(s.file, { folder: 'slips' }))
    )
    uploadingSlip.value = false

    const res = await http.post<{ data: { id: string; pointsEarned: number } }>(
      API_ENDPOINTS.MEMBER.ORDERS.CREATE,
      {
        items: cart.value.map(item => ({
          productId: item.product.id,
          quantity: item.quantity,
          options: item.selectedOptions,
          note: item.note || undefined,
        })),
        note: orderNote.value || undefined,
        couponCode: appliedCouponCode.value || undefined,
        pickupTime: pickupTime.value,
        slipUrls: uploaded.map(u => u.publicUrl),
      }
    )
    if (res.data) {
      clearCartStorage()
      showSuccess(`สั่งสำเร็จ! ได้รับ ${res.data.pointsEarned} แต้ม`)
      await navigateTo(`/member/orders/${res.data.id}`)
    }
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'สั่งสินค้าไม่สำเร็จ')
  } finally {
    placing.value = false
    uploadingSlip.value = false
  }
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

// default pickup = +10 นาทีจากตอนนี้ snap ไปค่าที่ใกล้สุดใน pickupOptions
function getDefaultPickupTime(): string {
  const now = new Date()
  const defaultMs = now.getTime() + 10 * 60 * 1000
  const startMs = (Math.ceil(now.getTime() / (15 * 60 * 1000)) + 1) * 15 * 60 * 1000
  const snapMs = defaultMs < startMs ? startMs : startMs
  return formatPickupOption(snapMs).value
}

// ─── Proceed to payment ───────────────────────────────────────────────────────
async function proceedToPayment() {
  if (cartCount.value === 0) return
  try {
    const res = await http.get<{ data: ShopStatus }>(API_ENDPOINTS.PUBLIC.LOCATION_STATUS, undefined, { loading: true })
    shopStatus.value = res.data ?? null
  } catch { /* ถ้า fetch ไม่ได้ ให้ผ่านไปก่อน */ }

  if (shopStatus.value && !shopStatus.value.canOrder) {
    showClosedAlert.value = true
    return
  }
  step.value = 2
}

// ─── Cart total ───────────────────────────────────────────────────────────────
const cartCount = computed(() => cart.value.reduce((s, i) => s + i.quantity, 0))

// ─── Step labels ──────────────────────────────────────────────────────────────
const steps = [
  { num: 1, label: 'เลือกสินค้า' },
  { num: 2, label: 'ชำระเงิน' },
]

// ─── PromptPay QR dynamic ─────────────────────────────────────────────────────
const PROMPTPAY_NUMBER = '0889523537' // ← เปลี่ยนเป็นเบอร์พร้อมเพย์ของร้านจริง

const qrDataUrl = ref('')

async function generateQR(amount: number) {
  const payload = generatePayload(PROMPTPAY_NUMBER, { amount })
  const QRCode = await import('qrcode')
  qrDataUrl.value = await QRCode.toDataURL(payload, {
    width: 256,
    margin: 2,
    color: { dark: '#1B2B4B', light: '#FFFFFF' },
  })
}

watch(total, (val) => {
  if (step.value === 2) generateQR(val)
}, { immediate: false })

watch(step, (val) => {
  if (val === 2) {
    generateQR(total.value)
    // set default pickup time เมื่อไปหน้าชำระเงิน
    if (!pickupTime.value) pickupTime.value = getDefaultPickupTime()
  }
})

// ─── Deep link banks ──────────────────────────────────────────────────────────
interface BankDeepLink {
  id: string
  name: string
  shortName: string
  color: string
  icon: string
  buildUrl: (amount: string) => string
}

const banks: BankDeepLink[] = [
  {
    id: 'krungthai',
    name: 'กรุงไทย\n(ถุงเงิน)',
    shortName: 'KTB',
    color: '#00A0E3',
    icon: '/images/icon-ktb.jpg',
    buildUrl: (amount) => `ktbiz://promptpay?amount=${amount}&promptpayid=${PROMPTPAY_NUMBER}`,
  },
  {
    id: 'scb',
    name: 'ไทยพาณิชย์\n(SCB Easy)',
    shortName: 'SCB',
    color: '#4E2E7F',
    icon: '/images/icon-scb.jpg',
    buildUrl: (amount) => `scbeasy://promptpay?amount=${amount}&target=${PROMPTPAY_NUMBER}`,
  },
  {
    id: 'bbl',
    name: 'กรุงเทพ\n(Bualuang)',
    shortName: 'BBL',
    color: '#1E3A6E',
    icon: '/images/icon-bbl.png',
    buildUrl: (amount) => `bblmobile://qr?amount=${amount}&ref=${PROMPTPAY_NUMBER}`,
  },
  {
    id: 'kbank',
    name: 'กสิกรไทย\n(K PLUS)',
    shortName: 'KBANK',
    color: '#138F2D',
    icon: '/images/icon-kbank.png',
    buildUrl: (amount) => `kplus://promptpay?amount=${amount}&target=${PROMPTPAY_NUMBER}`,
  },
  {
    id: 'bay',
    name: 'กรุงศรี\n(KMA)',
    shortName: 'KMA',
    color: '#FDB825',
    icon: '/images/icon-kma.png',
    buildUrl: (amount) => `kma://pay?amount=${amount}&promptpay=${PROMPTPAY_NUMBER}`,
  },
  {
    id: 'ttb',
    name: 'ทหารไทย\n(ttb touch)',
    shortName: 'TTB',
    color: '#F47920',
    icon: '/images/icon-ttb.png',
    buildUrl: (amount) => `ttbtouch://promptpay?amount=${amount}&target=${PROMPTPAY_NUMBER}`,
  },
]

function bankUrl(bank: BankDeepLink) {
  return bank.buildUrl(total.value.toFixed(2))
}

// ─── QR download (iOS-safe) ───────────────────────────────────────────────────
function downloadQR() {
  if (!qrDataUrl.value) return
  const img = new Image()
  img.onload = () => {
    const canvas = document.createElement('canvas')
    canvas.width = img.width
    canvas.height = img.height
    canvas.getContext('2d')!.drawImage(img, 0, 0)
    canvas.toBlob((blob) => {
      if (!blob) return
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `qr-promptpay-${total.value.toFixed(0)}.png`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    }, 'image/png')
  }
  img.src = qrDataUrl.value
}
</script>

<template>
  <div class="max-w-lg mx-auto pb-28">
    <!-- ── Header ── -->
    <div class="flex items-center gap-3 mb-4">
      <NuxtLink v-if="step === 1" to="/member/orders" class="text-gray-400 hover:text-gray-600">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </NuxtLink>
      <button v-else class="text-gray-400 hover:text-gray-600" @click="step = 1">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </button>
      <h1 class="text-xl font-bold text-gray-900">สั่งสินค้าใหม่</h1>
    </div>

    <!-- ── Step indicator ── -->
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

    <!-- ════════════════════════════════════════════════════════════
         STEP 1 — เลือกสินค้า
    ════════════════════════════════════════════════════════════════ -->
    <div v-if="step === 1" class="space-y-3">
      <!-- Manual close warning banner -->
      <div v-if="shopStatus?.manualClose && shopStatus?.canOrder" class="flex items-start gap-3 bg-orange-50 border border-orange-200 rounded-xl px-4 py-3 text-sm">
        <Icon name="mdi:store-clock" class="text-orange-500 text-xl flex-shrink-0 mt-0.5" />
        <div>
          <p class="font-medium text-orange-700">ร้านปิดอยู่ในขณะนี้</p>
          <p v-if="shopStatus.nextOpenLabel" class="text-orange-600 text-xs mt-0.5">
            จะเปิดอีกครั้ง {{ shopStatus.nextOpenLabel }}
            <span v-if="shopStatus.nextOpenName"> ที่ {{ shopStatus.nextOpenName }}</span>
          </p>
          <p class="text-orange-500 text-xs mt-0.5">คุณสามารถสั่งล่วงหน้าได้</p>
        </div>
      </div>

      <!-- Cart restored banner -->
      <div v-if="cart.length > 0 && !loading" class="flex items-center gap-3 bg-blue-50 border border-blue-200 rounded-xl px-4 py-3 text-sm">
        <Icon name="mdi:cart-check" class="text-blue-500 text-xl flex-shrink-0" />
        <div class="flex-1 min-w-0">
          <p class="font-medium text-blue-700">มีรายการค้างอยู่ {{ cartCount }} รายการ</p>
          <p class="text-blue-500 text-xs">ระบบบันทึกรายการไว้ให้อัตโนมัติ</p>
        </div>
        <button class="text-blue-400 hover:text-blue-600 text-xs underline flex-shrink-0" @click="cart = []">ล้าง</button>
      </div>

      <!-- สั่งบ่อย -->
      <div v-if="!loading && frequentProducts.length > 0" class="space-y-2">
        <div class="flex items-center gap-2">
          <Icon name="mdi:fire" class="text-orange-500 text-base" />
          <p class="text-sm font-semibold text-gray-700">สั่งบ่อย</p>
        </div>
        <div class="flex gap-2 overflow-x-auto pb-1">
          <button
            v-for="product in frequentProducts"
            :key="product.id"
            type="button"
            class="flex-shrink-0 flex items-center gap-2 bg-white border border-gray-200 rounded-xl px-3 py-2 hover:border-[#C8D8E8] hover:bg-[#F0F4F8] active:scale-95 transition-all shadow-sm"
            @click="openModal(product)"
          >
            <div class="w-9 h-9 rounded-lg overflow-hidden bg-[#F0F4F8] flex-shrink-0">
              <img v-if="product.imageUrl" :src="product.imageUrl" class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center">
                <Icon name="flat-color-icons:shop" class="text-xl" />
              </div>
            </div>
            <div class="text-left min-w-0">
              <p class="text-xs font-semibold text-gray-800 leading-tight line-clamp-1 max-w-[80px]">{{ product.name }}</p>
              <p class="text-[10px] text-[#2a3f6b] font-medium">฿{{ Number(product.price).toFixed(0) }}</p>
            </div>
          </button>
        </div>
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

    <!-- ════════════════════════════════════════════════════════════
         STEP 2 — ชำระเงิน (รวม slip + เวลา)
    ════════════════════════════════════════════════════════════════ -->
    <div v-else-if="step === 2" class="space-y-4">

      <!-- Cart summary -->
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
          </div>
        </div>
      </div>

      <!-- Coupon section -->
      <div class="bg-white rounded-2xl shadow p-4">
        <p class="text-sm font-semibold text-gray-700 mb-2">ส่วนลด / คูปอง</p>
        <div v-if="appliedCouponCode" class="flex items-center justify-between bg-green-50 border border-green-200 rounded-xl p-3">
          <div>
            <p class="text-xs font-bold text-green-700 font-mono">{{ appliedCouponCode }}</p>
            <p class="text-xs text-green-600 mt-0.5">{{ appliedCouponName }}</p>
            <p class="text-xs text-green-600">-฿{{ appliedCouponDiscount.toFixed(2) }}</p>
          </div>
          <button class="text-gray-400 hover:text-red-500 text-xl leading-none p-1" @click="clearCoupon">×</button>
        </div>
        <button
          v-else
          class="w-full py-2.5 rounded-xl border border-dashed border-gray-300 text-sm text-gray-400 hover:text-gray-600 hover:border-gray-400 transition-colors"
          @click="showCouponPicker = true"
        >
          + ใช้โค้ด / คูปอง / แคมเปญ
        </button>
      </div>

      <!-- Note + Pickup time -->
      <div class="bg-white rounded-2xl shadow p-4 space-y-4">
        <div>
          <p class="text-sm font-semibold text-gray-700 mb-2">เวลารับสินค้า <span class="text-red-500">*</span></p>
          <select
            v-model="pickupTime"
            class="w-full border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
          >
            <option value="" disabled>เลือกเวลารับ...</option>
            <option v-for="t in pickupOptions" :key="t.value" :value="t.value">{{ t.label }}</option>
          </select>
          <p class="text-xs text-gray-400 mt-1">ตั้งค่าเริ่มต้น +10 นาที — เปลี่ยนได้ตามต้องการ</p>
        </div>
        <div>
          <p class="text-sm font-semibold text-gray-700 mb-2">หมายเหตุ (ไม่บังคับ)</p>
          <textarea
            v-model="orderNote"
            rows="2"
            placeholder="เช่น ไม่เอาน้ำแข็ง, หวานน้อย..."
            class="w-full border border-gray-300 rounded-xl px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] resize-none"
          />
        </div>
      </div>

      <!-- Total -->
      <div class="bg-white rounded-2xl shadow p-4 space-y-2">
        <div class="flex justify-between text-sm text-gray-500">
          <span>ยอดรวม</span><span>฿{{ subtotal.toFixed(2) }}</span>
        </div>
        <div v-if="appliedCouponDiscount > 0" class="flex justify-between text-sm text-green-600">
          <span>ส่วนลด ({{ appliedCouponName || appliedCouponCode }})</span>
          <span>-฿{{ appliedCouponDiscount.toFixed(2) }}</span>
        </div>
        <div class="flex justify-between font-bold text-gray-900 pt-2 border-t border-gray-100 text-base">
          <span>รวมทั้งหมด</span><span>฿{{ total.toFixed(2) }}</span>
        </div>
        <p class="text-xs text-[#1B2B4B] text-right">+{{ pointsEarned }} แต้มที่จะได้รับ</p>
      </div>

      <!-- ── Payment section ── -->
      <div class="bg-white rounded-2xl shadow p-4 space-y-4">
        <p class="text-sm font-semibold text-gray-700">ชำระเงิน ฿{{ total.toFixed(2) }}</p>

        <!-- QR Code dynamic พร้อมยอด -->
        <div class="flex flex-col items-center gap-2">
          <div v-if="qrDataUrl" class="relative">
            <img
              :src="qrDataUrl"
              alt="QR Code ชำระเงิน"
              class="w-52 h-52 object-contain rounded-xl border border-gray-200"
            />
            <div class="absolute -bottom-2 left-1/2 -translate-x-1/2 bg-[#1B2B4B] text-white text-xs font-bold px-3 py-1 rounded-full whitespace-nowrap shadow">
              ฿{{ total.toFixed(2) }}
            </div>
          </div>
          <div v-else class="w-52 h-52 bg-gray-100 rounded-xl flex items-center justify-center">
            <Icon name="mdi:loading" class="text-3xl text-gray-400 animate-spin" />
          </div>
          <button
            v-if="qrDataUrl"
            type="button"
            class="flex items-center gap-1.5 text-sm text-[#1B2B4B] font-medium hover:underline mt-2"
            @click="downloadQR"
          >
            <Icon name="mdi:download" class="text-base" />
            บันทึก QR Code (พร้อมยอด ฿{{ total.toFixed(2) }})
          </button>
        </div>

        <!-- Divider -->
        <div class="flex items-center gap-3">
          <div class="flex-1 h-px bg-gray-200" />
          <span class="text-xs text-gray-400">หรือเปิดแอปธนาคารโดยตรง</span>
          <div class="flex-1 h-px bg-gray-200" />
        </div>

        <!-- Bank deep link grid -->
        <div class="grid grid-cols-3 gap-2">
          <a
            v-for="bank in banks"
            :key="bank.id"
            :href="bankUrl(bank)"
            class="flex flex-col items-center gap-1.5 rounded-xl border border-gray-200 p-2.5 hover:border-[#C8D8E8] hover:bg-[#F0F4F8] active:scale-95 transition-all"
          >
            <img
              :src="bank.icon"
              :alt="bank.shortName"
              class="w-10 h-10 rounded-full object-cover"
            />
            <span class="text-[10px] text-gray-600 text-center leading-tight whitespace-pre-line">{{ bank.name }}</span>
          </a>
        </div>

        <p class="text-xs text-gray-400 text-center">กดเพื่อเปิดแอปธนาคารพร้อมยอดอัตโนมัติ</p>
      </div>

      <!-- Slip upload -->
      <div class="bg-white rounded-2xl shadow p-4 space-y-3">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-semibold text-gray-700">สลิปการโอนเงิน <span class="text-red-500">*</span></p>
            <p class="text-xs text-red-500">* ไม่คืนเงินทุกกรณี</p>
          </div>
          <span class="text-xs text-gray-400">{{ slipFiles.length }}/{{ MAX_SLIPS }}</span>
        </div>

        <div v-if="slipFiles.length" class="grid grid-cols-3 gap-2">
          <div v-for="(s, i) in slipFiles" :key="i" class="relative aspect-square">
            <img :src="s.preview" class="w-full h-full object-cover rounded-xl border border-gray-200" />
            <button
              type="button"
              class="absolute top-1 right-1 bg-white/90 rounded-full p-0.5 text-red-500 shadow"
              @click="removeSlip(i)"
            >
              <Icon name="mdi:close" class="w-3.5 h-3.5" />
            </button>
          </div>
          <label v-if="slipFiles.length < MAX_SLIPS" class="aspect-square flex items-center justify-center border-2 border-dashed border-gray-300 rounded-xl cursor-pointer hover:border-[#C8D8E8] transition-colors">
            <Icon name="mdi:plus" class="text-2xl text-gray-400" />
            <input type="file" accept="image/*" multiple class="hidden" @change="onSlipChange" />
          </label>
        </div>

        <label v-else class="block cursor-pointer">
          <div class="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-[#C8D8E8] transition-colors">
            <Icon name="mdi:upload" class="text-4xl text-gray-400 mb-2" />
            <p class="text-sm text-gray-500 font-medium">แตะเพื่อแนบสลิป</p>
            <p class="text-xs text-gray-400 mt-1">JPG, PNG, HEIC · สูงสุด {{ MAX_SLIPS }} รูป</p>
          </div>
          <input type="file" accept="image/*" multiple class="hidden" @change="onSlipChange" />
        </label>
      </div>

      <!-- Confirm button -->
      <button
        :disabled="placing"
        class="w-full py-3.5 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors text-base shadow"
        @click="placeOrder"
      >
        {{ uploadingSlip ? 'กำลังอัปโหลดสลิป...' : placing ? 'กำลังสั่ง...' : 'ยืนยันการสั่ง' }}
      </button>
    </div>

    <!-- ════════════════════════════════════════════════════════════
         STICKY BOTTOM BAR (step 1 only)
    ════════════════════════════════════════════════════════════════ -->
    <Teleport to="body">
      <div v-if="step === 1" class="fixed bottom-0 left-0 right-0 z-40 pb-safe">
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
              ชำระเงิน →
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Option modal ── -->
    <Teleport to="body">
      <div v-if="modalProduct" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:bg-black/40 sm:p-4">
        <div class="bg-white sm:rounded-2xl w-full sm:max-w-md h-full sm:h-auto sm:max-h-[85vh] overflow-y-auto shadow-2xl flex flex-col">
          <div class="p-6 border-b border-gray-100">
            <h3 class="text-lg font-bold text-gray-900">{{ modalProduct.name }}</h3>
            <p class="text-[#2a3f6b] font-semibold mt-1">฿{{ Number(modalProduct.price).toFixed(0) }}</p>
          </div>
          <div class="p-6 space-y-5">
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
                  @click="toggleOption(pg.optionGroup.id, opt.id, pg.optionGroup.multiSelect)"
                  class="w-full flex items-center justify-between px-4 py-3 rounded-xl border-2 transition-colors text-left"
                  :class="modalOptions[pg.optionGroup.id]?.includes(opt.id) ? 'border-[#C8D8E8] bg-[#F0F4F8]' : 'border-gray-100 bg-white hover:border-gray-200'"
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
                  class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 hover:bg-gray-200 text-lg font-bold transition-colors"
                  @click="modalQty > 1 && modalQty--"
                >−</button>
                <span class="text-base font-bold text-gray-900 w-6 text-center">{{ modalQty }}</span>
                <button
                  type="button"
                  class="w-8 h-8 rounded-full bg-[#C8D8E8] flex items-center justify-center text-[#2a3f6b] hover:bg-[#b0c8e0] text-lg font-bold transition-colors"
                  @click="modalQty++"
                >+</button>
              </div>
            </div>
          </div>
          <div class="p-6 pt-0 flex gap-3 sm:mt-0 mt-auto sticky bottom-0 bg-white border-t border-gray-100 sm:border-none sm:static">
            <button @click="modalProduct = null" class="flex-1 py-3 border border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50">ยกเลิก</button>
            <button @click="confirmModal" class="flex-1 py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b]">เพิ่มลงออเดอร์</button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Shop closed alert ── -->
    <Teleport to="body">
      <div v-if="showClosedAlert" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden">
          <div class="bg-[#1B2B4B] px-6 py-5 text-center">
            <Icon name="mdi:store-clock" class="text-4xl text-white/80 mb-2" />
            <p class="text-white font-bold text-lg">ร้านปิดอยู่</p>
          </div>
          <div class="px-6 py-5 text-center space-y-2">
            <template v-if="shopStatus?.nextOpenLabel">
              <p class="text-sm text-gray-500">ร้านจะเปิดอีกครั้ง</p>
              <p class="font-bold text-gray-900">{{ shopStatus.nextOpenLabel }}</p>
              <p class="text-sm text-gray-500">ที่ {{ shopStatus.nextOpenName }}</p>
            </template>
            <p v-else class="text-sm text-gray-500">ยังไม่มีกำหนดเปิดในขณะนี้</p>
            <p class="text-xs text-gray-400 pt-1">สามารถสั่งล่วงหน้าได้ภายใน 16 ชั่วโมงข้างหน้า</p>
          </div>
          <div class="px-6 pb-5">
            <button
              class="w-full py-3 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] transition-colors"
              @click="showClosedAlert = false"
            >รับทราบ</button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Coupon / Campaign picker modal ── -->
    <Teleport to="body">
      <div v-if="showCouponPicker" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 p-4">
        <div class="bg-white rounded-2xl w-full max-w-md max-h-[80vh] overflow-y-auto shadow-2xl">
          <div class="p-5 border-b border-gray-100 flex items-center justify-between sticky top-0 bg-white z-10">
            <h3 class="text-lg font-bold text-gray-900">ใช้โค้ด / คูปอง / แคมเปญ</h3>
            <button class="text-gray-400 hover:text-gray-600 text-2xl leading-none" @click="showCouponPicker = false">×</button>
          </div>
          <div class="p-5 space-y-5">
            <div>
              <p class="text-sm font-semibold text-gray-700 mb-2">ใส่รหัสโค้ด</p>
              <div class="flex gap-2">
                <input
                  v-model="couponInput"
                  type="text"
                  placeholder="รหัสคูปอง..."
                  @keyup.enter="applyManualCoupon"
                  class="flex-1 border border-gray-300 rounded-lg px-3 py-2 text-sm uppercase focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
                />
                <button
                  @click="applyManualCoupon"
                  class="px-4 py-2 bg-[#1B2B4B] text-white rounded-lg text-sm font-medium hover:bg-[#2a3f6b]"
                >ใช้</button>
              </div>
            </div>

            <div v-if="myUses.length > 0">
              <p class="text-sm font-semibold text-gray-700 mb-2">คูปองที่แลกแต้มไว้</p>
              <div class="space-y-2">
                <button
                  v-for="u in myUses"
                  :key="u.id"
                  type="button"
                  :disabled="!!couponErrors[u.coupon.code] || couponLoading[u.coupon.code]"
                  class="w-full flex items-center justify-between rounded-xl px-4 py-3 transition-colors text-left border"
                  :class="couponErrors[u.coupon.code]
                    ? 'bg-red-50 border-red-200 opacity-70 cursor-not-allowed'
                    : 'bg-green-50 border-green-200 hover:bg-green-100'"
                  @click="applyCouponFromPicker(u.coupon.code, u.coupon.name, u.coupon.discountKind, u.coupon.discountValue)"
                >
                  <div class="min-w-0">
                    <p class="text-sm font-bold font-mono" :class="couponErrors[u.coupon.code] ? 'text-red-600' : 'text-green-700'">{{ u.coupon.code }}</p>
                    <p class="text-xs text-gray-600">{{ u.coupon.name }}</p>
                    <p v-if="couponErrors[u.coupon.code]" class="text-xs text-red-500 mt-0.5">{{ couponErrors[u.coupon.code] }}</p>
                  </div>
                  <span class="text-sm font-semibold flex-shrink-0 ml-2" :class="couponErrors[u.coupon.code] ? 'text-red-400' : 'text-green-700'">
                    {{ formatCouponLabel(u.coupon.discountKind, u.coupon.discountValue) }}
                  </span>
                </button>
              </div>
            </div>

            <div v-if="campaigns.length > 0">
              <p class="text-sm font-semibold text-gray-700 mb-2">แคมเปญ</p>
              <div class="space-y-3">
                <div v-for="camp in campaigns" :key="camp.id">
                  <p class="text-xs font-semibold text-gray-500 mb-1.5">{{ camp.name }}</p>
                  <div class="space-y-1.5">
                    <button
                      v-for="c in camp.coupons"
                      :key="c.id"
                      type="button"
                      :disabled="!!couponErrors[c.code] || couponLoading[c.code]"
                      class="w-full flex items-center justify-between rounded-xl px-4 py-3 transition-colors text-left border"
                      :class="couponErrors[c.code]
                        ? 'bg-red-50 border-red-200 opacity-70 cursor-not-allowed'
                        : 'bg-[#F0F4F8] border-[#C8D8E8] hover:bg-[#e0ecf5]'"
                      @click="applyCouponFromPicker(c.code, c.name, c.discountKind, c.discountValue)"
                    >
                      <div class="min-w-0">
                        <p class="text-sm font-bold font-mono" :class="couponErrors[c.code] ? 'text-red-600' : 'text-[#1B2B4B]'">{{ c.code }}</p>
                        <p class="text-xs text-gray-600">{{ c.name }}</p>
                        <p v-if="couponErrors[c.code]" class="text-xs text-red-500 mt-0.5">{{ couponErrors[c.code] }}</p>
                      </div>
                      <span class="text-sm font-semibold flex-shrink-0 ml-2" :class="couponErrors[c.code] ? 'text-red-400' : 'text-[#2a3f6b]'">
                        {{ formatCouponLabel(c.discountKind, c.discountValue) }}
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <p v-if="myUses.length === 0 && campaigns.length === 0" class="text-center text-sm text-gray-400 py-4">
              ไม่มีคูปองที่พร้อมใช้งาน
            </p>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
