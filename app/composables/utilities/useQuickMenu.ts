import { QUICK_MENU } from '~/composables/constants/quickMenu'
import type { PosOption } from '~/stores/pos'

export function useQuickMenu() {
  const store = usePosStore()

  // กรองเฉพาะ items ที่หาสินค้าและ options เจอใน store.products จริง
  const resolvedItems = computed(() => {
    return QUICK_MENU.flatMap((item) => {
      const product = store.products.find(p => p.name === item.productName)
      if (!product) return []

      const allOptions = product.optionGroups.flatMap(g => g.optionGroup.options)
      const resolvedOptions: PosOption[] = item.options.flatMap((optName) => {
        const opt = allOptions.find(o => o.name === optName)
        if (!opt) return []
        return [{ optionId: opt.id, name: opt.name, extraPrice: Number(opt.extraPrice) }]
      })

      return [{
        product,
        options: resolvedOptions,
        label: item.label ?? item.productName,
        categoryName: product.category?.name ?? 'อื่นๆ',
      }]
    })
  })

  function addToCart(index: number) {
    const item = resolvedItems.value[index]
    if (!item) return
    store.addToCart(item.product, item.options, '', 1)
  }

  return { resolvedItems, addToCart }
}
