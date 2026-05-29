import { defineStore } from 'pinia'
import { API_ENDPOINTS } from '~/composables/constants/api'
import { ApiError } from '~/composables/store_models/base'

export interface PosOption {
  optionId: string
  name: string
  extraPrice: number
}

export interface CartItem {
  cartId: string
  productId: string
  productName: string
  unitPrice: number
  quantity: number
  note: string
  options: PosOption[]
  subtotal: number
}

export interface PosProduct {
  id: string
  name: string
  price: number
  imageUrl: string | null
  categoryId: string
  category: { id: string; name: string; slug: string }
  optionGroups: {
    sortOrder: number
    optionGroupId: string
    optionGroup: {
      id: string
      name: string
      required: boolean
      multiSelect: boolean
      options: { id: string; name: string; extraPrice: number }[]
    }
  }[]
}

export interface PosMember {
  id: string
  name: string
  email: string | null
  phone: string | null
  tier: 'SILVER' | 'GOLD' | 'VIP'
  points: number
  profileImage: string | null
}

export interface PosDiscount {
  id: string
  name: string
  kind: 'PERCENT' | 'AMOUNT'
  value: number
}

export interface PosCoupon {
  id: string
  code: string
  name: string
  discountKind: 'PERCENT' | 'AMOUNT'
  discountValue: number
}

export const usePosStore = defineStore('pos', () => {
  // ─── Products & Discounts ───────────────────────────────────────────────────
  const products = ref<PosProduct[]>([])
  const discounts = ref<PosDiscount[]>([])
  const isLoadingProducts = ref(false)

  async function fetchProducts() {
    isLoadingProducts.value = true
    try {
      const res = await useHttpClient().get<{ data: PosProduct[] }>(API_ENDPOINTS.POS.PRODUCTS)
      products.value = (res.data ?? []).map((p: any) => ({ ...p, price: Number(p.price) }))
    } finally {
      isLoadingProducts.value = false
    }
  }

  async function fetchDiscounts() {
    const res = await useHttpClient().get<{ data: any[] }>(API_ENDPOINTS.POS.DISCOUNTS)
    discounts.value = (res.data ?? []).map((d: any) => ({ ...d, value: Number(d.value) }))
  }

  // ─── Cart ───────────────────────────────────────────────────────────────────
  const cart = ref<CartItem[]>([])

  function calcItemSubtotal(unitPrice: number, qty: number, opts: PosOption[]) {
    const optExtra = opts.reduce((s, o) => s + o.extraPrice, 0)
    return (unitPrice + optExtra) * qty
  }

  function addToCart(product: PosProduct, options: PosOption[], note = '', qty = 1) {
    const cartId = `${Date.now()}-${Math.random()}`
    const unitPrice = Number(product.price)
    cart.value.push({
      cartId,
      productId: product.id,
      productName: product.name,
      unitPrice,
      quantity: qty,
      note,
      options,
      subtotal: calcItemSubtotal(unitPrice, qty, options),
    })
  }

  function updateCartItem(cartId: string, qty: number, note: string, options: PosOption[]) {
    const item = cart.value.find((i) => i.cartId === cartId)
    if (!item) return
    item.quantity = qty
    item.note = note
    item.options = options
    item.subtotal = calcItemSubtotal(item.unitPrice, qty, options)
  }

  function removeFromCart(cartId: string) {
    cart.value = cart.value.filter((i) => i.cartId !== cartId)
  }

  function clearCart() {
    cart.value = []
    member.value = null
    discountMode.value = null
    discountBadge.value = null
    discountPercent.value = 0
    discountAmount.value = 0
    pointsToRedeem.value = 0
    orderNote.value = ''
    appliedCoupon.value = null
    couponDiscount.value = 0
  }

  // ─── Member ─────────────────────────────────────────────────────────────────
  const member = ref<PosMember | null>(null)

  async function lookupMember(q: string) {
    const res = await useHttpClient().get<{ data: PosMember }>(API_ENDPOINTS.POS.MEMBER_LOOKUP, { q })
    member.value = res.data
    return res.data
  }

  function clearMember() {
    member.value = null
    pointsToRedeem.value = 0
  }

  // ─── Discount ───────────────────────────────────────────────────────────────
  const discountMode = ref<'badge' | 'percent' | 'amount' | null>(null)
  const discountBadge = ref<PosDiscount | null>(null)
  const discountPercent = ref(0)
  const discountAmount = ref(0)

  function applyDiscountBadge(badge: PosDiscount) {
    discountMode.value = 'badge'
    discountBadge.value = badge
    discountPercent.value = 0
    discountAmount.value = 0
  }

  function applyDiscountPercent(pct: number) {
    discountMode.value = 'percent'
    discountBadge.value = null
    discountPercent.value = pct
    discountAmount.value = 0
  }

  function applyDiscountAmount(amt: number) {
    discountMode.value = 'amount'
    discountBadge.value = null
    discountPercent.value = 0
    discountAmount.value = amt
  }

  function clearDiscount() {
    discountMode.value = null
    discountBadge.value = null
    discountPercent.value = 0
    discountAmount.value = 0
  }

  // ─── Coupon ─────────────────────────────────────────────────────────────────
  const appliedCoupon = ref<PosCoupon | null>(null)
  const couponDiscount = ref(0)

  async function validateAndApplyCoupon(code: string) {
    const res = await useHttpClient().post<{ data: { coupon: PosCoupon; discountAmount: number } }>(
      API_ENDPOINTS.POS.COUPON_VALIDATE,
      { code, subtotal: subtotal.value, memberId: member.value?.id ?? null },
    )
    appliedCoupon.value = res.data.coupon
    couponDiscount.value = res.data.discountAmount
  }

  function clearCoupon() {
    appliedCoupon.value = null
    couponDiscount.value = 0
  }

  // ─── Points Redeem ──────────────────────────────────────────────────────────
  const pointsToRedeem = ref(0)

  // ─── Order Note ─────────────────────────────────────────────────────────────
  const orderNote = ref('')

  // ─── Computed Totals ────────────────────────────────────────────────────────
  const subtotal = computed(() => cart.value.reduce((s, i) => s + i.subtotal, 0))

  const discountCalc = computed(() => {
    if (!discountMode.value) return 0
    if (discountMode.value === 'badge' && discountBadge.value) {
      return discountBadge.value.kind === 'PERCENT'
        ? Math.round((subtotal.value * discountBadge.value.value) / 100 * 100) / 100
        : Math.min(discountBadge.value.value, subtotal.value)
    }
    if (discountMode.value === 'percent') {
      return Math.round((subtotal.value * discountPercent.value) / 100 * 100) / 100
    }
    return Math.min(discountAmount.value, subtotal.value)
  })

  const maxRedeemable = computed(() => Math.floor(subtotal.value - discountCalc.value - couponDiscount.value))

  const pointsRedeemCapped = computed(() =>
    Math.min(pointsToRedeem.value, member.value?.points ?? 0, maxRedeemable.value),
  )

  const total = computed(() => Math.max(0, subtotal.value - discountCalc.value - couponDiscount.value - pointsRedeemCapped.value))

  // ─── Checkout ───────────────────────────────────────────────────────────────
  const isSubmitting = ref(false)
  const lastOrder = ref<any>(null)

  async function checkout(paymentMethod: 'CASH' | 'CARD' | 'QR', paymentAmount: number, transactionRef?: string) {
    if (cart.value.length === 0) throw new Error('Cart is empty')
    isSubmitting.value = true
    try {
      const orderPayload = {
        note: orderNote.value || undefined,
        memberId: member.value?.id,
        discountKind: discountMode.value === 'badge' && discountBadge.value
          ? discountBadge.value.kind
          : discountMode.value === 'percent' ? 'PERCENT'
          : discountMode.value === 'amount' ? 'AMOUNT'
          : undefined,
        discountValue: discountMode.value === 'badge' && discountBadge.value
          ? discountBadge.value.value
          : discountMode.value === 'percent' ? discountPercent.value
          : discountMode.value === 'amount' ? discountAmount.value
          : undefined,
        discountId: discountBadge.value?.id,
        couponCode: appliedCoupon.value?.code,
        pointsRedeemed: pointsRedeemCapped.value,
        items: cart.value.map((i) => ({
          productId: i.productId,
          quantity: i.quantity,
          note: i.note || undefined,
          options: i.options.map((o) => ({ optionId: o.optionId })),
        })),
      }

      const orderRes = await useHttpClient().post<{ data: any }>(API_ENDPOINTS.POS.ORDERS.CREATE, orderPayload)
      const order = orderRes.data

      await useHttpClient().post(API_ENDPOINTS.POS.PAYMENTS.CREATE, {
        orderId: order.id,
        method: paymentMethod,
        amount: paymentAmount,
        transactionRef,
      })

      lastOrder.value = order
      clearCart()
      return order
    } catch (e) {
      throw new ApiError(e)
    } finally {
      isSubmitting.value = false
    }
  }

  return {
    products: readonly(products),
    discounts: readonly(discounts),
    isLoadingProducts: readonly(isLoadingProducts),
    cart: readonly(cart),
    member: readonly(member),
    discountMode: readonly(discountMode),
    discountBadge: readonly(discountBadge),
    discountPercent: readonly(discountPercent),
    discountAmount: readonly(discountAmount),
    pointsToRedeem,
    orderNote,
    subtotal,
    discountCalc,
    maxRedeemable,
    pointsRedeemCapped,
    total,
    appliedCoupon: readonly(appliedCoupon),
    couponDiscount: readonly(couponDiscount),
    isSubmitting: readonly(isSubmitting),
    lastOrder: readonly(lastOrder),
    fetchProducts,
    fetchDiscounts,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart,
    lookupMember,
    clearMember,
    applyDiscountBadge,
    applyDiscountPercent,
    applyDiscountAmount,
    clearDiscount,
    validateAndApplyCoupon,
    clearCoupon,
    checkout,
  }
})
