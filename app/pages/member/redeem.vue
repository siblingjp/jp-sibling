<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const store = useMemberStore()
const http = useHttpClient()
const { showSuccess, showError } = useAlert()

interface Reward {
  id: string
  name: string
  description: string | null
  pointCost: number
  isActive: boolean
}

const rewards = ref<Reward[]>([])
const loadingRewards = ref(true)
const redeeming = ref(false)

onMounted(async () => {
  try {
    const res = await http.get<{ success: boolean; data: Reward[] }>(API_ENDPOINTS.MEMBER.REWARDS)
    rewards.value = res.data ?? []
  } catch {
    // no rewards configured yet
  } finally {
    loadingRewards.value = false
  }
})

const redeemPoints = ref(0)
const redeemDiscount = computed(() => redeemPoints.value)
const maxRedeem = computed(() => member.value?.points ?? 0)

async function handleRedeem() {
  if (redeemPoints.value <= 0) return
  redeeming.value = true
  try {
    const res = await http.post<{ success: boolean; data: { pointsUsed: number; discount: number; remainingPoints: number } }>(
      API_ENDPOINTS.MEMBER.REDEEM,
      { points: redeemPoints.value }
    )
    if (res.data) {
      store.addPoints(-res.data.pointsUsed)
      redeemPoints.value = 0
      showSuccess(`Redeemed ${res.data.pointsUsed} pts = ฿${res.data.discount} discount!`)
    }
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Redeem failed')
  } finally {
    redeeming.value = false
  }
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <h1 class="text-2xl font-bold text-gray-900">Redeem Points</h1>

    <!-- Balance -->
    <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white">
      <p class="text-white/70 text-sm">Your Balance</p>
      <p class="text-5xl font-bold mt-1">{{ (member?.points ?? 0).toLocaleString() }}</p>
      <p class="text-white/70 text-sm mt-1">points available</p>
    </div>

    <!-- Convert points to discount -->
    <div class="bg-white rounded-2xl shadow p-6 space-y-4">
      <h2 class="font-semibold text-gray-800">Convert to Discount</h2>
      <p class="text-sm text-gray-500">1 point = ฿1 discount, applied instantly to your next in-store visit</p>

      <div>
        <div class="flex justify-between text-sm mb-2">
          <span class="text-gray-600">Points to redeem</span>
          <span class="font-bold text-[#2a3f6b]">{{ redeemPoints }} pts = ฿{{ redeemDiscount }}</span>
        </div>
        <input
          v-model.number="redeemPoints"
          type="range"
          :min="0"
          :max="maxRedeem"
          :step="10"
          class="w-full accent-[#1B2B4B]"
        />
        <div class="flex justify-between text-xs text-gray-400 mt-1">
          <span>0</span>
          <span>{{ maxRedeem }} pts</span>
        </div>
      </div>

      <div class="flex gap-2">
        <button
          v-for="pct in [25, 50, 75, 100]"
          :key="pct"
          @click="redeemPoints = Math.floor(maxRedeem * pct / 100 / 10) * 10"
          class="flex-1 py-1.5 text-sm font-medium rounded-lg bg-[#F0F4F8] text-[#2a3f6b] hover:bg-[#C8D8E8] transition-colors"
        >
          {{ pct }}%
        </button>
      </div>

      <button
        :disabled="redeemPoints <= 0 || redeeming"
        @click="handleRedeem"
        class="w-full py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-40 transition-colors"
      >
        {{ redeeming ? 'Processing...' : `Redeem ${redeemPoints} pts for ฿${redeemDiscount} off` }}
      </button>
    </div>

    <!-- Rewards catalog -->
    <div v-if="!loadingRewards && rewards.length > 0" class="space-y-4">
      <h2 class="font-semibold text-gray-800">Rewards Catalog</h2>
      <div class="grid gap-3">
        <div
          v-for="reward in rewards"
          :key="reward.id"
          class="bg-white rounded-2xl shadow p-5 flex items-center justify-between"
          :class="{ 'opacity-50': (member?.points ?? 0) < reward.pointCost }"
        >
          <div>
            <p class="font-semibold text-gray-800">{{ reward.name }}</p>
            <p v-if="reward.description" class="text-sm text-gray-500 mt-0.5">{{ reward.description }}</p>
          </div>
          <div class="text-right flex-shrink-0 ml-4">
            <p class="font-bold text-[#2a3f6b]">{{ reward.pointCost.toLocaleString() }}</p>
            <p class="text-xs text-gray-400">pts</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
