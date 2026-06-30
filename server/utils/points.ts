export const POINTS_PER_BAHT = 1 / 25 // ทุก ฿25 = 1 แต้ม
export const BAHT_PER_POINT = 1        // 1 แต้ม = ฿1

export const TIER_MULTIPLIER: Record<string, number> = {
  VIP: 1.5,
  GOLD: 1.25,
  SILVER: 1.0,
}

export function calcPointsEarned(total: number, tier: string): number {
  const multiplier = TIER_MULTIPLIER[tier] ?? 1.0
  return Math.floor(total * POINTS_PER_BAHT * multiplier)
}
