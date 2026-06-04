<script setup lang="ts">
import type { PosProduct, PosOption, CartItem, PosDiscount } from '~/stores/pos'
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'pos', middleware: 'auth' })

const store = usePosStore()
const { showError, showSuccess } = useAlert()

onMounted(async () => {
  await Promise.all([store.fetchProducts(), store.fetchDiscounts()])
})

// ─── Product Grid ───────────────────────────────────────────────────────────
const FEATURED_ID = '__featured__'
const search = ref('')
const selectedCategory = ref<string | null>(FEATURED_ID)

const hasFeatured = computed(() => store.products.some((p) => p.isFeatured))

const categories = computed(() => {
  const map = new Map<string, string>()
  store.products.forEach((p) => map.set(p.category.id, p.category.name))
  const cats = Array.from(map.entries()).map(([id, name]) => ({ id, name }))
  if (hasFeatured.value) return [{ id: FEATURED_ID, name: '⭐ แนะนำ' }, ...cats]
  return cats
})

const filteredProducts = computed(() => {
  let list = [...store.products]
  if (selectedCategory.value === FEATURED_ID) {
    list = list.filter((p) => p.isFeatured)
  } else if (selectedCategory.value) {
    list = list.filter((p) => p.categoryId === selectedCategory.value)
  }
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter((p) => p.name.toLowerCase().includes(q))
  }
  return list
})

// ─── Mobile tab ──────────────────────────────────────────────────────────────
const mobileTab = ref<'products' | 'cart'>('products')

// ─── Option Modal ────────────────────────────────────────────────────────────
const optionModalProduct = ref<PosProduct | null>(null)
const editingCartId = ref<string | null>(null)

function openProduct(product: PosProduct) {
  if (product.optionGroups.length === 0) {
    store.addToCart(product, [], '', 1)
    mobileTab.value = 'cart'
    return
  }
  optionModalProduct.value = product
  editingCartId.value = null
}

function openEditItem(cartId: string) {
  const item = store.cart.find((i) => i.cartId === cartId)
  if (!item) return
  const product = store.products.find((p) => p.id === item.productId)
  if (!product) return
  optionModalProduct.value = product
  editingCartId.value = cartId
}

function handleOptionConfirm(options: PosOption[], note: string, qty: number) {
  if (!optionModalProduct.value) return
  if (editingCartId.value) {
    store.updateCartItem(editingCartId.value, qty, note, options)
  } else {
    store.addToCart(optionModalProduct.value, options, note, qty)
    mobileTab.value = 'cart'
  }
  optionModalProduct.value = null
  editingCartId.value = null
}

// ─── Member Lookup ───────────────────────────────────────────────────────────
const showMemberSearch = ref(false)
const memberQuery = ref('')
const isLookingUp = ref(false)
const showMemberScanner = ref(false)

async function handleMemberLookup() {
  if (!memberQuery.value.trim()) return
  isLookingUp.value = true
  try {
    await store.lookupMember(memberQuery.value.trim())
    showMemberSearch.value = false
    memberQuery.value = ''
  } catch {
    showError('ไม่พบสมาชิก')
  } finally {
    isLookingUp.value = false
  }
}

function handleMemberScanned(value: string) {
  showMemberScanner.value = false
  memberQuery.value = value
  handleMemberLookup()
}

// ─── Coupon ──────────────────────────────────────────────────────────────────
const showCouponScanner = ref(false)

async function handleApplyCoupon(code: string) {
  try {
    await store.validateAndApplyCoupon(code)
    showSuccess('ใช้คูปองสำเร็จ')
  } catch (e: any) {
    showError(e?.data?.message ?? e?.statusMessage ?? e?.message ?? 'คูปองไม่ถูกต้อง')
  }
}

function handleCouponScanned(value: string) {
  showCouponScanner.value = false
  // ถ้า value เป็น cuid (coupon use id) ให้ scan coupon use แทน
  if (value.length > 20 && !value.includes(' ')) {
    handleCouponUseScan(value.trim())
  } else {
    handleApplyCoupon(value.trim().toUpperCase())
  }
}

// ─── Coupon Use Scan (QR จากหน้า Redeem ของ Member) ──────────────────────────
const showCouponUseScanResult = ref(false)
const couponUseScanResult = ref<{ couponCode: string; couponName: string; discountKind: string; discountValue: number; memberName: string | null } | null>(null)
async function handleCouponUseScan(id: string) {
  try {
    const http = useHttpClient()
    const res = await http.post<{ data: typeof couponUseScanResult.value }>(
      API_ENDPOINTS.POS.COUPON_USE_SCAN(id)
    )
    couponUseScanResult.value = res.data
    showCouponUseScanResult.value = true
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'ไม่สามารถใช้คูปองได้')
  }
}

// ─── Queue Reserve ───────────────────────────────────────────────────────────
async function handleReserveQueue() {
  try {
    await store.reserveQueue()
  } catch {
    showError('ไม่สามารถจองหมายเลขคิวได้')
  }
}

async function handleCancelReserve() {
  // cancel reserved order เป็น CANCELLED แล้ว clear
  if (store.reservedOrderId) {
    try {
      const http = useHttpClient()
      await http.patch(API_ENDPOINTS.POS.ORDERS.UPDATE(store.reservedOrderId), { status: 'CANCELLED' })
    } catch { /* ถ้า cancel ไม่ได้ก็แค่ clear local */ }
  }
  store.clearReservedQueue()
}

// ─── Checkout ────────────────────────────────────────────────────────────────
const showPayment = ref(false)
const lastOrderQueue = ref<number | null>(null)
const lastOrderUnpaid = ref(false)
const showSuccess2 = ref(false)

async function handleCheckout(method: 'CASH' | 'QR' | 'THAI_HELP' | 'UNPAID', amount: number, ref?: string) {
  try {
    const order = await store.checkout(method, amount, ref)
    lastOrderQueue.value = order.queueNo
    lastOrderUnpaid.value = method === 'UNPAID'
    showPayment.value = false
    showSuccess2.value = true
    setTimeout(() => { showSuccess2.value = false }, 4000)
  } catch (e: any) {
    showError(e?.message ?? 'Checkout failed')
  }
}
</script>

<template>
  <div class="flex h-full flex-col md:flex-row">

    <!-- Mobile tab bar -->
    <div class="flex md:hidden border-b border-gray-200 bg-white flex-shrink-0">
      <button
        class="flex-1 py-2.5 text-sm font-medium transition-colors flex items-center justify-center gap-1.5"
        :class="mobileTab === 'products' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'"
        @click="mobileTab = 'products'"
      >
        <Icon name="mdi:grid" class="text-base" />สินค้า
      </button>
      <button
        class="flex-1 py-2.5 text-sm font-medium transition-colors flex items-center justify-center gap-1.5 relative"
        :class="mobileTab === 'cart' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-500'"
        @click="mobileTab = 'cart'"
      >
        <Icon name="mdi:cart" class="text-base" />ตะกร้า
        <span v-if="store.cart.length > 0" class="absolute top-1.5 right-[calc(50%-28px)] bg-blue-600 text-white text-[10px] font-bold w-4 h-4 rounded-full flex items-center justify-center">
          {{ store.cart.length }}
        </span>
      </button>
    </div>

    <!-- Product Area -->
    <div class="flex-1 flex flex-col min-w-0 bg-gray-50 min-h-0" :class="mobileTab === 'cart' ? 'hidden md:flex' : 'flex'">
      <!-- Search + Category Filter -->
      <div class="px-4 pt-4 pb-3 bg-white border-b border-gray-200 space-y-3">
        <!-- ยังไม่มีคิวที่จอง -->
        <button
          v-if="!store.reservedQueueNo"
          type="button"
          class="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-semibold hover:bg-indigo-700 active:scale-95 transition-all disabled:opacity-60"
          :disabled="store.isReserving"
          @click="handleReserveQueue"
        >
          <Icon name="mdi:ticket-outline" class="text-lg" />
          {{ store.isReserving ? 'กำลังจอง...' : 'จองหมายเลขคิว' }}
        </button>
        <!-- มีคิวที่จองแล้ว -->
        <div v-else class="flex items-center gap-2 px-3 py-2 rounded-xl bg-indigo-50 border border-indigo-200">
          <Icon name="mdi:ticket-confirmation-outline" class="text-indigo-600 text-lg flex-shrink-0" />
          <span class="text-sm font-semibold text-indigo-700 flex-1">คิวที่จอง: <span class="text-xl font-black">#{{ store.reservedQueueNo }}</span></span>
          <button
            type="button"
            class="text-xs text-red-500 hover:text-red-700 underline flex-shrink-0"
            @click="handleCancelReserve"
          >ยกเลิก</button>
        </div>
        <input
          v-model="search"
          type="text"
          placeholder="ค้นหาสินค้า..."
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <div class="flex gap-2 overflow-x-auto pb-1">
          <button
            class="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors flex-shrink-0"
            :class="selectedCategory === null ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
            @click="selectedCategory = null"
          >ทั้งหมด</button>
          <button
            v-for="cat in categories"
            :key="cat.id"
            class="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors flex-shrink-0"
            :class="selectedCategory === cat.id ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
            @click="selectedCategory = cat.id"
          >{{ cat.name }}</button>
        </div>
      </div>

      <!-- Product Grid -->
      <div class="flex-1 overflow-y-auto p-4">
        <div v-if="store.isLoadingProducts" class="text-center py-16 text-gray-400">กำลังโหลด...</div>
        <div v-else-if="filteredProducts.length === 0" class="text-center py-16 text-gray-400 text-sm">ไม่พบสินค้า</div>
        <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
          <button
            v-for="p in filteredProducts"
            :key="p.id"
            type="button"
            class="bg-white rounded-xl p-3 text-left shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all active:scale-95 relative"
            @click="openProduct(p)"
          >
            <span v-if="p.isFeatured" class="absolute top-2 right-2 text-yellow-400 text-base leading-none">★</span>
            <div class="w-full aspect-square rounded-lg bg-gray-100 mb-2 overflow-hidden">
              <img v-if="p.imageUrl" :src="p.imageUrl" :alt="p.name" class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center">
                <Icon name="flat-color-icons:shop" class="text-4xl" />
              </div>
            </div>
            <p class="text-sm font-medium text-gray-900 leading-tight truncate">{{ p.name }}</p>
            <p class="text-sm text-blue-600 font-semibold mt-0.5">฿{{ Number(p.price).toFixed(0) }}</p>
            <p v-if="p.optionGroups.length > 0" class="text-xs text-gray-400 mt-0.5">{{ p.optionGroups.length }} ตัวเลือก</p>
          </button>
        </div>
      </div>
    </div>

    <!-- Cart Panel -->
    <div class="w-full md:w-80 xl:w-96 flex-shrink-0 flex flex-col min-h-0" :class="mobileTab === 'products' ? 'hidden md:flex' : 'flex'">
      <PosCartPanel
        :cart="store.cart"
        :member="store.member"
        :discount-mode="store.discountMode"
        :discount-badge="store.discountBadge"
        :discount-percent="store.discountPercent"
        :discount-amount="store.discountAmount"
        :discount-calc="store.discountCalc"
        :points-to-redeem="store.pointsToRedeem"
        :points-redeem-capped="store.pointsRedeemCapped"
        :max-redeemable="store.maxRedeemable"
        :subtotal="store.subtotal"
        :total="store.total"
        :discounts="store.discounts"
        :is-submitting="store.isSubmitting"
        :pickup-time="store.pickupTime"
        @update-pickup-time="store.pickupTime = $event"
        @remove-item="store.removeFromCart"
        @edit-item="openEditItem"
        :applied-coupon="store.appliedCoupon"
        :coupon-discount="store.couponDiscount"
        @lookup-member="showMemberSearch = true"
        @clear-member="store.clearMember()"
        @apply-badge="store.applyDiscountBadge"
        @set-percent="store.applyDiscountPercent"
        @set-amount="store.applyDiscountAmount"
        @clear-discount="store.clearDiscount()"
        @apply-coupon="handleApplyCoupon"
        @clear-coupon="store.clearCoupon()"
        @scan-coupon="showCouponScanner = true"
        @update-points-redeem="store.pointsToRedeem = $event"
        @checkout="showPayment = true"
        @badge-created="store.fetchDiscounts()"
      />
    </div>
  </div>

  <!-- Option Modal -->
  <PosOptionModal
    :product="optionModalProduct"
    @confirm="handleOptionConfirm"
    @cancel="optionModalProduct = null"
  />

  <!-- Payment Modal -->
  <PosPaymentModal
    v-if="showPayment"
    :total="store.total"
    :is-submitting="store.isSubmitting"
    @confirm="handleCheckout"
    @cancel="showPayment = false"
  />

  <!-- Member Search Modal -->
  <Teleport to="body">
    <div v-if="showMemberSearch" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="showMemberSearch = false; showMemberScanner = false" />
      <div class="relative bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm space-y-4">
        <h2 class="font-semibold text-gray-900">ค้นหาสมาชิก</h2>
        <div v-if="showMemberScanner">
          <QrScanner @scanned="handleMemberScanned" @close="showMemberScanner = false" />
        </div>
        <template v-else>
          <div class="flex gap-2">
            <input
              v-model="memberQuery"
              type="text"
              placeholder="เบอร์โทรหรืออีเมล..."
              class="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              @keyup.enter="handleMemberLookup"
            />
            <button
              type="button"
              class="px-3 py-2 border border-gray-300 rounded-lg text-gray-500 hover:bg-gray-50"
              title="สแกน QR"
              @click="showMemberScanner = true"
            >
              <Icon name="mdi:qrcode-scan" class="text-base" />
            </button>
          </div>
          <div class="flex gap-3">
            <button class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600" @click="showMemberSearch = false; showMemberScanner = false">ยกเลิก</button>
            <button
              class="flex-1 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 disabled:opacity-50"
              :disabled="isLookingUp"
              @click="handleMemberLookup"
            >{{ isLookingUp ? 'กำลังค้นหา...' : 'ค้นหา' }}</button>
          </div>
        </template>
      </div>
    </div>
  </Teleport>

  <!-- Coupon Scanner Modal -->
  <Teleport to="body">
    <div v-if="showCouponScanner" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="showCouponScanner = false" />
      <div class="relative bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm space-y-4">
        <h2 class="font-semibold text-gray-900">สแกนคูปอง</h2>
        <QrScanner @scanned="handleCouponScanned" @close="showCouponScanner = false" />
      </div>
    </div>
  </Teleport>

  <!-- Coupon Use Scan Result Modal -->
  <Teleport to="body">
    <div v-if="showCouponUseScanResult && couponUseScanResult" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40" @click="showCouponUseScanResult = false" />
      <div class="relative bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm space-y-4">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
            <Icon name="mdi:check" class="text-xl text-green-600" />
          </div>
          <div>
            <p class="font-semibold text-gray-900">ใช้คูปองสำเร็จ</p>
            <p v-if="couponUseScanResult.memberName" class="text-sm text-gray-500">สมาชิก: {{ couponUseScanResult.memberName }}</p>
          </div>
        </div>
        <div class="bg-green-50 border border-green-200 rounded-xl p-4 space-y-1">
          <p class="text-xs text-gray-500">คูปอง</p>
          <p class="font-bold text-green-700 font-mono text-lg">{{ couponUseScanResult.couponCode }}</p>
          <p class="text-sm text-gray-700">{{ couponUseScanResult.couponName }}</p>
          <p class="text-base font-bold text-green-700 mt-1">
            ส่วนลด {{ couponUseScanResult.discountKind === 'PERCENT' ? `${couponUseScanResult.discountValue}%` : `฿${couponUseScanResult.discountValue}` }}
          </p>
        </div>
        <button
          class="w-full py-2.5 rounded-xl bg-gray-900 text-white text-sm font-medium hover:bg-gray-700"
          @click="showCouponUseScanResult = false"
        >ปิด</button>
      </div>
    </div>
  </Teleport>

  <!-- Success Toast -->
  <Teleport to="body">
    <Transition name="slide-up">
      <div
        v-if="showSuccess2"
        class="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 text-white px-6 py-3 rounded-2xl shadow-lg font-semibold text-lg"
        :class="lastOrderUnpaid ? 'bg-orange-500' : 'bg-green-600'"
      >
        {{ lastOrderUnpaid ? `ออเดอร์ #${lastOrderQueue} (ค้างชำระ)` : `ออเดอร์ #${lastOrderQueue} สำเร็จ!` }}
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.slide-up-enter-active, .slide-up-leave-active { transition: all 0.3s ease; }
.slide-up-enter-from, .slide-up-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }
</style>
