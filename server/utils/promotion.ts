import type { Coupon } from '@prisma/client'

export interface BundleCalcItem {
  quantity: number
  product: { categoryId: string }
}

// นับจำนวนชิ้นที่เข้าเงื่อนไขหมวดหมู่ของโปรโมชัน (categoryId null = นับทุกชิ้นในออเดอร์)
export function calcBundleEligibleQty(items: BundleCalcItem[], categoryId: string | null): number {
  return items.reduce((sum, i) => {
    if (categoryId && i.product.categoryId !== categoryId) return sum
    return sum + i.quantity
  }, 0)
}

// ส่วนลดจากโปรโมชันแบบ "ซื้อครบ N ชิ้น ลด X บาท" ซ้ำได้หลายชุดตามจำนวนที่ซื้อ
export function calcBundleDiscount(eligibleQty: number, bundleQty: number, bundleDiscount: number): number {
  if (bundleQty <= 0) return 0
  const bundles = Math.floor(eligibleQty / bundleQty)
  return bundles * bundleDiscount
}

export type AutoApplyCoupon = Coupon & { category: { id: string } | null }

// หาโปรโมชัน auto-apply ที่เงื่อนไขตรงและลดได้มากที่สุด จากโปรโมชันที่ active ทั้งหมด (ใช้ได้ครั้งละ 1 ตัว)
export function pickBestAutoApplyCoupon(
  coupons: AutoApplyCoupon[],
  items: BundleCalcItem[],
  now: Date,
): { coupon: AutoApplyCoupon; discountAmount: number } | null {
  let best: { coupon: AutoApplyCoupon; discountAmount: number } | null = null

  for (const coupon of coupons) {
    if (!coupon.autoApply || !coupon.isActive) continue
    if (coupon.startAt && coupon.startAt > now) continue
    if (coupon.expiredAt && coupon.expiredAt < now) continue
    if (coupon.maxUses !== null && coupon.usedCount >= coupon.maxUses) continue
    if (!coupon.bundleQty || !coupon.bundleDiscount) continue

    const eligibleQty = calcBundleEligibleQty(items, coupon.categoryId)
    const discountAmount = calcBundleDiscount(eligibleQty, coupon.bundleQty, Number(coupon.bundleDiscount))
    if (discountAmount <= 0) continue

    if (!best || discountAmount > best.discountAmount) {
      best = { coupon, discountAmount }
    }
  }

  return best
}
