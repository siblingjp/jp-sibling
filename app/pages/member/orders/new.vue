<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()
const { showSuccess, showError } = useAlert()

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

const products = ref<Product[]>([])
const cart = ref<CartItem[]>([])
const loading = ref(true)
const placing = ref(false)

// option modal
const modalProduct = ref<Product | null>(null)
const modalOptions = ref<Record<string, string[]>>({})

onMounted(async () => {
  try {
    const res = await http.get<{ success: boolean; data: Product[] }>(API_ENDPOINTS.POS.PRODUCTS)
    products.value = res.data ?? []
  } catch {
    // silent
  } finally {
    loading.value = false
  }
})

function openModal(product: Product) {
  modalProduct.value = product
  modalOptions.value = {}
  for (const pg of product.optionGroups) {
    if (!pg.optionGroup.multiSelect && pg.optionGroup.required) {
      // auto-select first active option
      const first = pg.optionGroup.options.find(o => o.isActive)
      if (first) modalOptions.value[pg.optionGroup.id] = [first.id]
    } else {
      modalOptions.value[pg.optionGroup.id] = []
    }
  }
}

function toggleOption(groupId: string, optionId: string, multiSelect: boolean) {
  const current = modalOptions.value[groupId] ?? []
  if (multiSelect) {
    if (current.includes(optionId)) {
      modalOptions.value[groupId] = current.filter(id => id !== optionId)
    } else {
      modalOptions.value[groupId] = [...current, optionId]
    }
  } else {
    modalOptions.value[groupId] = [optionId]
  }
}

function confirmModal() {
  if (!modalProduct.value) return
  const product = modalProduct.value

  // validate required groups
  for (const pg of product.optionGroups) {
    const g = pg.optionGroup
    if (g.required && !(modalOptions.value[g.id]?.length > 0)) {
      showError(`Please select an option for "${g.name}"`)
      return
    }
  }

  const selectedOptions: CartItem['selectedOptions'] = []
  for (const pg of product.optionGroups) {
    const g = pg.optionGroup
    for (const optId of (modalOptions.value[g.id] ?? [])) {
      const opt = g.options.find(o => o.id === optId)
      if (opt) selectedOptions.push({ optionId: opt.id, name: opt.name, extraPrice: Number(opt.extraPrice) })
    }
  }

  const existing = cart.value.find(
    c => c.product.id === product.id &&
    JSON.stringify(c.selectedOptions.map(o => o.optionId).sort()) ===
    JSON.stringify(selectedOptions.map(o => o.optionId).sort())
  )

  if (existing) {
    existing.quantity++
  } else {
    cart.value.push({ product, quantity: 1, selectedOptions, note: '' })
  }
  modalProduct.value = null
}

function removeItem(index: number) {
  cart.value.splice(index, 1)
}

const subtotal = computed(() =>
  cart.value.reduce((sum, item) => {
    const base = Number(item.product.price)
    const extra = item.selectedOptions.reduce((s, o) => s + o.extraPrice, 0)
    return sum + (base + extra) * item.quantity
  }, 0)
)

const pointsToRedeem = ref(0)
const maxRedeem = computed(() => Math.min(member.value?.points ?? 0, Math.floor(subtotal.value)))
const total = computed(() => subtotal.value - pointsToRedeem.value)
const pointsEarned = computed(() => {
  const multiplier = member.value?.tier === 'VIP' ? 1.5 : member.value?.tier === 'GOLD' ? 1.25 : 1.0
  return Math.floor((total.value / 10) * multiplier)
})

async function placeOrder() {
  if (cart.value.length === 0) return
  placing.value = true
  try {
    const body = {
      items: cart.value.map(item => ({
        productId: item.product.id,
        quantity: item.quantity,
        options: item.selectedOptions,
        note: item.note || undefined,
      })),
      pointsToRedeem: pointsToRedeem.value,
    }
    const res = await http.post<{ success: boolean; data: { id: string; queueStatus: string; pointsEarned: number } }>(
      API_ENDPOINTS.MEMBER.ORDERS.CREATE,
      body
    )
    if (res.data) {
      showSuccess(`Order placed! Earned ${res.data.pointsEarned} pts`)
      await navigateTo(`/member/orders/${res.data.id}`)
    }
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to place order')
  } finally {
    placing.value = false
  }
}
</script>

<template>
  <div class="max-w-2xl mx-auto space-y-6">
    <div class="flex items-center gap-3">
      <NuxtLink to="/member/orders" class="text-gray-400 hover:text-gray-600">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">New Order</h1>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Product grid -->
      <div class="space-y-3">
        <h2 class="font-semibold text-gray-700">Menu</h2>
        <div v-if="loading" class="text-center py-8 text-gray-400">Loading menu...</div>
        <div v-else class="grid grid-cols-2 gap-3">
          <button
            v-for="product in products"
            :key="product.id"
            @click="openModal(product)"
            class="bg-white rounded-xl shadow p-3 text-left hover:shadow-md hover:ring-2 hover:ring-amber-400 transition-all"
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

      <!-- Cart -->
      <div class="space-y-3">
        <h2 class="font-semibold text-gray-700">Your Order</h2>

        <div v-if="cart.length === 0" class="bg-white rounded-2xl shadow p-8 text-center text-gray-400">
          <Icon name="flat-color-icons:empty-trash" class="text-5xl mb-2" />
          <p class="text-sm">Select items from the menu</p>
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="(item, index) in cart"
            :key="index"
            class="bg-white rounded-xl shadow p-4"
          >
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <p class="font-medium text-gray-800">{{ item.product.name }}</p>
                <p class="text-xs text-gray-400 mt-0.5">
                  {{ item.selectedOptions.map(o => o.name).join(', ') || 'No options' }}
                </p>
              </div>
              <button @click="removeItem(index)" class="text-red-400 hover:text-red-600 ml-2 p-1">
                <Icon name="mdi:close" class="w-4 h-4" />
              </button>
            </div>

            <div class="flex items-center justify-between mt-3">
              <div class="flex items-center gap-2">
                <button
                  @click="item.quantity > 1 ? item.quantity-- : removeItem(index)"
                  class="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 hover:bg-gray-200"
                >-</button>
                <span class="text-sm font-medium w-5 text-center">{{ item.quantity }}</span>
                <button
                  @click="item.quantity++"
                  class="w-7 h-7 rounded-full bg-[#C8D8E8] flex items-center justify-center text-[#2a3f6b] hover:bg-[#b0c8e0]"
                >+</button>
              </div>
              <span class="text-sm font-semibold text-gray-800">
                ฿{{ ((Number(item.product.price) + item.selectedOptions.reduce((s, o) => s + o.extraPrice, 0)) * item.quantity).toFixed(0) }}
              </span>
            </div>
          </div>

          <!-- Point redeem slider -->
          <div v-if="(member?.points ?? 0) > 0" class="bg-[#F0F4F8] rounded-xl p-4">
            <div class="flex justify-between text-sm mb-2">
              <span class="text-[#1B2B4B] font-medium">Use points</span>
              <span class="text-[#2a3f6b]">{{ pointsToRedeem }} pts = -฿{{ pointsToRedeem }}</span>
            </div>
            <input
              v-model.number="pointsToRedeem"
              type="range"
              :min="0"
              :max="maxRedeem"
              :step="10"
              class="w-full accent-[#1B2B4B]"
            />
          </div>

          <!-- Summary -->
          <div class="bg-white rounded-xl shadow p-4 space-y-2">
            <div class="flex justify-between text-sm text-gray-500">
              <span>Subtotal</span>
              <span>฿{{ subtotal.toFixed(2) }}</span>
            </div>
            <div v-if="pointsToRedeem > 0" class="flex justify-between text-sm text-green-600">
              <span>Points discount</span>
              <span>-฿{{ pointsToRedeem }}</span>
            </div>
            <div class="flex justify-between font-bold text-gray-900 pt-2 border-t border-gray-100">
              <span>Total</span>
              <span>฿{{ total.toFixed(2) }}</span>
            </div>
            <div class="text-xs text-[#1B2B4B] text-right">+{{ pointsEarned }} pts will be earned</div>
          </div>

          <button
            :disabled="placing"
            @click="placeOrder"
            class="w-full py-3.5 bg-[#1B2B4B] text-white font-bold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
          >
            {{ placing ? 'Placing Order...' : `Place Order · ฿${total.toFixed(0)}` }}
          </button>
        </div>
      </div>
    </div>

    <!-- Option modal -->
    <Teleport to="body">
      <div v-if="modalProduct" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 p-4">
        <div class="bg-white rounded-2xl w-full max-w-md max-h-[80vh] overflow-y-auto shadow-2xl">
          <div class="p-6 border-b border-gray-100">
            <h3 class="text-lg font-bold text-gray-900">{{ modalProduct.name }}</h3>
            <p class="text-[#2a3f6b] font-semibold mt-1">฿{{ Number(modalProduct.price).toFixed(0) }}</p>
          </div>

          <div class="p-6 space-y-5">
            <div
              v-for="pg in modalProduct.optionGroups"
              :key="pg.optionGroup.id"
            >
              <div class="flex items-center gap-2 mb-3">
                <span class="font-semibold text-gray-800">{{ pg.optionGroup.name }}</span>
                <span v-if="pg.optionGroup.required" class="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">Required</span>
                <span v-if="pg.optionGroup.multiSelect" class="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded-full">Multi</span>
              </div>
              <div class="space-y-2">
                <button
                  v-for="opt in pg.optionGroup.options.filter(o => o.isActive)"
                  :key="opt.id"
                  @click="toggleOption(pg.optionGroup.id, opt.id, pg.optionGroup.multiSelect)"
                  class="w-full flex items-center justify-between px-4 py-3 rounded-xl border-2 transition-colors text-left"
                  :class="modalOptions[pg.optionGroup.id]?.includes(opt.id)
                    ? 'border-[#C8D8E8] border-500 bg-[#F0F4F8]'
                    : 'border-gray-100 bg-white hover:border-gray-200'"
                >
                  <span class="text-sm font-medium text-gray-800">{{ opt.name }}</span>
                  <span class="text-sm text-gray-500">
                    {{ Number(opt.extraPrice) > 0 ? `+฿${Number(opt.extraPrice).toFixed(0)}` : 'Free' }}
                  </span>
                </button>
              </div>
            </div>
          </div>

          <div class="p-6 pt-0 flex gap-3">
            <button
              @click="modalProduct = null"
              class="flex-1 py-3 border border-gray-200 text-gray-700 font-semibold rounded-xl hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              @click="confirmModal"
              class="flex-1 py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b]"
            >
              Add to Order
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
