import { API_ENDPOINTS } from '~/composables/constants/api'

export type LoyaltyMode = 'POINTS' | 'STAMPS'

export function useLoyaltyMode() {
  const mode = useState<LoyaltyMode | null>('loyaltyMode', () => null)

  async function fetchMode() {
    const http = useHttpClient()
    try {
      const res = await http.get<{ data: { loyaltyMode: LoyaltyMode } }>(API_ENDPOINTS.PUBLIC.LOYALTY_MODE)
      mode.value = res.data?.loyaltyMode ?? 'POINTS'
    } catch {
      mode.value = 'POINTS'
    }
    return mode.value
  }

  return { mode, fetchMode }
}
