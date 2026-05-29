export type Tier = 'SILVER' | 'GOLD' | 'VIP'

interface TierConfig {
  label: string
  icon: string
  iconColor: string
  badgeBg: string
  badgeText: string
}

const TIER_CONFIG: Record<Tier, TierConfig> = {
  VIP:    { label: 'VIP',    icon: 'mdi:crown',          iconColor: 'text-purple-500', badgeBg: 'bg-purple-100', badgeText: 'text-purple-700' },
  GOLD:   { label: 'Gold',   icon: 'mdi:star',            iconColor: 'text-yellow-500', badgeBg: 'bg-yellow-100', badgeText: 'text-yellow-700' },
  SILVER: { label: 'Silver', icon: 'mdi:shield-account',  iconColor: 'text-gray-400',   badgeBg: 'bg-gray-100',   badgeText: 'text-gray-600'   },
}

export function useTier(tier: Tier | null | undefined): TierConfig {
  return TIER_CONFIG[tier ?? 'SILVER'] ?? TIER_CONFIG.SILVER
}
