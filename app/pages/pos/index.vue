<script setup lang="ts">
import type { PosProduct, PosOption, CartItem, PosDiscount } from '~/stores/pos'

definePageMeta({ layout: 'pos', middleware: 'auth' })

const store = usePosStore()
const { showError, showSuccess } = useAlert()

onMounted(async () => {
  await Promise.all([store.fetchProducts(), store.fetchDiscounts()])
})

// ─── Product Grid ───────────────────────────────────────────────────────────
const search = ref('')
const selectedCategory = ref<string | null>(null)

const categories = computed(() => {
  const map = new Map<string, string>()
  store.products.forEach((p) => map.set(p.category.id, p.category.name))
  return Array.from(map.entries()).map(([id, name]) => ({ id, name }))
})

const filteredProducts = computed(() => {
  let list = [...store.products]
  if (selectedCategory.value) list = list.filter((p) => p.categoryId === selectedCategory.value)
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter((p) => p.name.toLowerCase().includes(q))
  }
  return list
})

// ─── Option Modal ────────────────────────────────────────────────────────────
const optionModalProduct = ref<PosProduct | null>(null)
const editingCartId = ref<string | null>(null)

function openProduct(product: PosProduct) {
  if (product.optionGroups.length === 0) {
    store.addToCart(product, [], '', 1)
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
  }
  optionModalProduct.value = null
  editingCartId.value = null
}

// ─── Member Lookup ───────────────────────────────────────────────────────────
const showMemberSearch = ref(false)
const memberQuery = ref('')
const isLookingUp = ref(false)

async function handleMemberLookup() {
  if (!memberQuery.value.trim()) return
  isLookingUp.value = true
  try {
    await store.lookupMember(memberQuery.value.trim())
    showMemberSearch.value = false
    memberQuery.value = ''
  } catch {
    showError('Member not found')
  } finally {
    isLookingUp.value = false
  }
}

// ─── Checkout ────────────────────────────────────────────────────────────────
const showPayment = ref(false)
const lastOrderQueue = ref<number | null>(null)
const showSuccess2 = ref(false)

async function handleCheckout(method: 'CASH' | 'CARD' | 'QR', amount: number, ref?: string) {
  try {
    const order = await store.checkout(method, amount, ref)
    lastOrderQueue.value = order.queueNo
    showPayment.value = false
    showSuccess2.value = true
    setTimeout(() => { showSuccess2.value = false }, 4000)
  } catch (e: any) {
    showError(e?.message ?? 'Checkout failed')
  }
}
</script>

<template>
  <div class="flex h-full">
    <!-- Product Area -->
    <div class="flex-1 flex flex-col min-w-0 bg-gray-50">
      <!-- Search + Category Filter -->
      <div class="px-4 pt-4 pb-3 bg-white border-b border-gray-200 space-y-3">
        <input
          v-model="search"
          type="text"
          placeholder="Search products..."
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <div class="flex gap-2 overflow-x-auto pb-1">
          <button
            class="px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-colors flex-shrink-0"
            :class="!selectedCategory ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'"
            @click="selectedCategory = null"
          >All</button>
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
        <div v-if="store.isLoadingProducts" class="text-center py-16 text-gray-400">Loading...</div>
        <div v-else-if="filteredProducts.length === 0" class="text-center py-16 text-gray-400 text-sm">No products found</div>
        <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
          <button
            v-for="p in filteredProducts"
            :key="p.id"
            type="button"
            class="bg-white rounded-xl p-3 text-left shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all active:scale-95"
            @click="openProduct(p)"
          >
            <div
              class="w-full aspect-square rounded-lg bg-gray-100 mb-2 overflow-hidden"
            >
              <img v-if="p.imageUrl" :src="p.imageUrl" :alt="p.name" class="w-full h-full object-cover" />
              <div v-else class="w-full h-full flex items-center justify-center text-3xl">☕</div>
            </div>
            <p class="text-sm font-medium text-gray-900 leading-tight truncate">{{ p.name }}</p>
            <p class="text-sm text-blue-600 font-semibold mt-0.5">฿{{ Number(p.price).toFixed(0) }}</p>
            <p v-if="p.optionGroups.length > 0" class="text-xs text-gray-400 mt-0.5">{{ p.optionGroups.length }} options</p>
          </button>
        </div>
      </div>
    </div>

    <!-- Cart Panel -->
    <div class="w-80 xl:w-96 flex-shrink-0 flex flex-col">
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
        @remove-item="store.removeFromCart"
        @edit-item="openEditItem"
        @lookup-member="showMemberSearch = true"
        @clear-member="store.clearMember()"
        @apply-badge="store.applyDiscountBadge"
        @set-percent="store.applyDiscountPercent"
        @set-amount="store.applyDiscountAmount"
        @clear-discount="store.clearDiscount()"
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
      <div class="absolute inset-0 bg-black/40" @click="showMemberSearch = false" />
      <div class="relative bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm space-y-4">
        <h2 class="font-semibold text-gray-900">Lookup Member</h2>
        <input
          v-model="memberQuery"
          type="text"
          placeholder="Phone or email..."
          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          @keyup.enter="handleMemberLookup"
        />
        <div class="flex gap-3">
          <button class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600" @click="showMemberSearch = false">Cancel</button>
          <button
            class="flex-1 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-medium hover:bg-blue-700 disabled:opacity-50"
            :disabled="isLookingUp"
            @click="handleMemberLookup"
          >{{ isLookingUp ? 'Searching...' : 'Search' }}</button>
        </div>
      </div>
    </div>
  </Teleport>

  <!-- Success Toast -->
  <Teleport to="body">
    <Transition name="slide-up">
      <div
        v-if="showSuccess2"
        class="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 bg-green-600 text-white px-6 py-3 rounded-2xl shadow-lg font-semibold text-lg"
      >
        Order #{{ lastOrderQueue }} placed!
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.slide-up-enter-active, .slide-up-leave-active { transition: all 0.3s ease; }
.slide-up-enter-from, .slide-up-leave-to { opacity: 0; transform: translateX(-50%) translateY(20px); }
</style>
