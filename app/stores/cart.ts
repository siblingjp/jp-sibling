import { defineStore } from 'pinia'

interface CartItem {
  productId: string
  name: string
  price: number
  quantity: number
  note?: string
}

interface Cart {
  id: string
  items: CartItem[]
  discount: number
}

export const useCartStore = defineStore('cart', () => {
  const carts = ref<Cart[]>([])
  const activeCartId = ref<string | null>(null)

  const activeCart = computed(() =>
    carts.value.find((c) => c.id === activeCartId.value) ?? null,
  )

  function createCart() {
    const id = crypto.randomUUID()
    carts.value.push({ id, items: [], discount: 0 })
    activeCartId.value = id
    return id
  }

  function setActiveCart(id: string) {
    activeCartId.value = id
  }

  function addItem(cartId: string, item: Omit<CartItem, 'quantity'> & { quantity?: number }) {
    const cart = carts.value.find((c) => c.id === cartId)
    if (!cart) return
    const existing = cart.items.find((i) => i.productId === item.productId)
    if (existing) {
      existing.quantity += item.quantity ?? 1
    } else {
      cart.items.push({ ...item, quantity: item.quantity ?? 1 })
    }
  }

  function removeItem(cartId: string, productId: string) {
    const cart = carts.value.find((c) => c.id === cartId)
    if (!cart) return
    cart.items = cart.items.filter((i) => i.productId !== productId)
  }

  function updateQuantity(cartId: string, productId: string, quantity: number) {
    const cart = carts.value.find((c) => c.id === cartId)
    if (!cart) return
    const item = cart.items.find((i) => i.productId === productId)
    if (!item) return
    if (quantity <= 0) {
      removeItem(cartId, productId)
    } else {
      item.quantity = quantity
    }
  }

  function clearCart(cartId: string) {
    const cart = carts.value.find((c) => c.id === cartId)
    if (!cart) return
    cart.items = []
    cart.discount = 0
  }

  function removeCart(cartId: string) {
    carts.value = carts.value.filter((c) => c.id !== cartId)
    if (activeCartId.value === cartId) {
      activeCartId.value = carts.value[0]?.id ?? null
    }
  }

  const cartTotal = (cartId: string) =>
    computed(() => {
      const cart = carts.value.find((c) => c.id === cartId)
      if (!cart) return 0
      const subtotal = cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0)
      return Math.max(0, subtotal - cart.discount)
    })

  return {
    carts,
    activeCartId,
    activeCart,
    createCart,
    setActiveCart,
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
    removeCart,
    cartTotal,
  }
})
