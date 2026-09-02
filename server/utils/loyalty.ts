import type { Prisma } from '@prisma/client'

export const MAX_STAMPS = 10

const LOYALTY_MODE_CACHE_KEY = 'settings:loyaltyMode'
export const SETTINGS_SINGLETON_ID = 'singleton'

export async function getLoyaltyMode(): Promise<'POINTS' | 'STAMPS'> {
  const cached = getCache<'POINTS' | 'STAMPS'>(LOYALTY_MODE_CACHE_KEY)
  if (cached) return cached

  // upsert กับ id คงที่ กัน race ที่อาจสร้างแถวซ้ำตอน cache เย็นพร้อมกันหลาย request
  const settings = await prisma.settings.upsert({
    where: { id: SETTINGS_SINGLETON_ID },
    create: { id: SETTINGS_SINGLETON_ID },
    update: {},
  })

  setCache(LOYALTY_MODE_CACHE_KEY, settings.loyaltyMode, 30)
  return settings.loyaltyMode
}

export function invalidateLoyaltyModeCache(): void {
  invalidateCache(LOYALTY_MODE_CACHE_KEY)
}

export function calcEligibleCupCount(items: { quantity: number; product: { isStampEligible: boolean } }[]): number {
  return items.reduce((sum, i) => i.product.isStampEligible ? sum + i.quantity : sum, 0)
}

export function applyStampCap(current: number, cupsEarned: number): { newCount: number; added: number } {
  const newCount = Math.min(MAX_STAMPS, current + cupsEarned)
  return { newCount, added: newCount - current }
}

// เมื่อออเดอร์ POS/admin เสร็จสิ้น (COMPLETED) และมี payment แล้ว: ให้แต้ม/แสตมป์จริง
// (แต้ม/แสตมป์จากออเดอร์ POS จะไม่ถูกให้ตอนสร้างออเดอร์ เพื่อไม่ให้ได้จากออเดอร์ที่ยังไม่จ่ายเงิน)
export async function awardOrderLoyaltyOnComplete(
  tx: Prisma.TransactionClient,
  orderId: string,
  memberId: string,
  stampsEligible: number,
  note: string,
) {
  if (stampsEligible <= 0) return
  const member = await tx.member.findUnique({ where: { id: memberId }, select: { stampCount: true } })
  if (!member) return

  const { newCount, added } = applyStampCap(member.stampCount, stampsEligible)
  if (added > 0) {
    await tx.member.update({ where: { id: memberId }, data: { stampCount: newCount } })
    await tx.stampLog.create({
      data: { memberId, action: 'EARN', amount: added, note, orderId },
    })
  }
}

// เมื่อออเดอร์ถูกยกเลิก: คืนแต้มที่เคยหักไปตอนแลกส่วนลด
// (ไม่ต้องคืนแต้ม/แสตมป์ที่ "จะได้" เพราะทุก source จะได้จริงตอน COMPLETED + มี payment
// เท่านั้น และออเดอร์ที่ยกเลิกได้ต้องยังไม่ถึง COMPLETED เสมอ จึงไม่เคยมีอะไรถูกให้ไปก่อน)
export async function reverseRedeemedPoints(
  tx: Prisma.TransactionClient,
  orderId: string,
  memberId: string,
  pointsRedeemed: number,
) {
  if (pointsRedeemed <= 0) return
  await tx.member.update({ where: { id: memberId }, data: { points: { increment: pointsRedeemed } } })
  await tx.pointLog.create({
    data: { memberId, action: 'ADJUST', amount: pointsRedeemed, note: 'คืนแต้มจากออเดอร์ที่ยกเลิก', orderId },
  })
}
