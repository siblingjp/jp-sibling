<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const store = useMemberStore()
const http = useHttpClient()
const { showSuccess, showError } = useAlert()

interface RedeemCoupon {
  id: string
  code: string
  name: string
  description: string | null
  type: string
  discountKind: 'PERCENT' | 'AMOUNT'
  discountValue: number
  pointCost: number
  minTier: string | null
  perMemberLimit: number | null
  expiredAt: string | null
  isActive: boolean
}

interface CouponUse {
  id: string
  isUsed: boolean
  usedAt: string | null
  createdAt: string
  coupon: {
    id: string
    code: string
    name: string
    discountKind: string
    discountValue: number
    pointCost: number | null
  }
}

const coupons = ref<RedeemCoupon[]>([])
const myUses = ref<CouponUse[]>([])
const loading = ref(true)
const redeeming = ref<string | null>(null)
const showHistory = ref(false)

// Countdown state: couponUseId → seconds remaining
const countdowns = ref<Record<string, number>>({})
let countdownTimer: ReturnType<typeof setInterval> | null = null

onMounted(async () => {
  await loadData()
  countdownTimer = setInterval(tickCountdowns, 1000)
})

onUnmounted(() => {
  if (countdownTimer) clearInterval(countdownTimer)
})

async function loadData() {
  loading.value = true
  try {
    const [rewardsRes, usesRes] = await Promise.all([
      http.get<{ data: RedeemCoupon[] }>(API_ENDPOINTS.MEMBER.REWARDS),
      http.get<{ data: CouponUse[] }>(API_ENDPOINTS.MEMBER.COUPONS.LIST),
    ])
    coupons.value = (rewardsRes.data ?? []).filter(c => c.pointCost && c.isActive && c.type === 'POINT_REDEEM')
    myUses.value = usesRes.data ?? []
    initCountdowns()
  } catch {
    // silent
  } finally {
    loading.value = false
  }
}

function initCountdowns() {
  const now = Date.now()
  const THIRTY_MIN = 30 * 60 * 1000
  for (const use of myUses.value) {
    if (!use.isUsed) {
      const elapsed = now - new Date(use.createdAt).getTime()
      const remaining = Math.max(0, Math.floor((THIRTY_MIN - elapsed) / 1000))
      countdowns.value[use.id] = remaining
    }
  }
}

function tickCountdowns() {
  for (const id in countdowns.value) {
    if (countdowns.value[id] > 0) countdowns.value[id]--
  }
}

function formatCountdown(secs: number) {
  const m = Math.floor(secs / 60)
  const s = secs % 60
  return `${m}:${s.toString().padStart(2, '0')}`
}

async function redeemCoupon(coupon: RedeemCoupon) {
  redeeming.value = coupon.id
  try {
    const res = await http.post<{ data: CouponUse }>(API_ENDPOINTS.MEMBER.COUPONS.REDEEM, { couponId: coupon.id })
    store.addPoints(-coupon.pointCost)
    showSuccess(`แลก "${coupon.name}" สำเร็จ! ใช้ได้ภายใน 30 นาที`)
    if (res.data) {
      myUses.value.unshift(res.data)
      countdowns.value[res.data.id] = 30 * 60
    }
  } catch (e: any) {
    showError(e?.data?.message ?? e?.message ?? 'แลกไม่สำเร็จ')
  } finally {
    redeeming.value = null
  }
}

function formatDiscount(c: RedeemCoupon) {
  return c.discountKind === 'PERCENT' ? `${c.discountValue}%` : `฿${Number(c.discountValue).toFixed(0)}`
}

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric' })
}

function formatDateTime(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const activeUses = computed(() => myUses.value.filter(u => !u.isUsed))
const historyUses = computed(() => myUses.value.filter(u => u.isUsed))

const qrTarget = ref<CouponUse | null>(null)
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-bold text-gray-900">แลกแต้ม</h1>
      <button
        class="flex items-center gap-1 text-sm text-[#1B2B4B] font-medium hover:underline"
        @click="showHistory = !showHistory"
      >
        <Icon name="mdi:history" class="w-4 h-4" />
        ประวัติการแลก
      </button>
    </div>

    <!-- Balance -->
    <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white">
      <p class="text-white/70 text-sm">แต้มของคุณ</p>
      <p class="text-5xl font-bold mt-1">{{ (member?.points ?? 0).toLocaleString() }}</p>
      <p class="text-white/70 text-sm mt-1">แต้มที่มี</p>
    </div>

    <!-- Active redeemed coupons (QR + countdown) -->
    <div v-if="activeUses.length > 0">
      <h2 class="font-semibold text-gray-800 mb-3 flex items-center gap-2">
        <Icon name="mdi:ticket-confirmation" class="text-green-600" />
        คูปองที่แลกแล้ว (ยังไม่ได้ใช้)
      </h2>
      <div class="space-y-3">
        <div v-for="use in activeUses" :key="use.id"
          class="bg-green-50 border border-green-200 rounded-2xl p-4 flex items-center justify-between gap-3">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-bold text-green-700 font-mono">{{ use.coupon.code }}</p>
            <p class="text-sm font-semibold text-gray-800 mt-0.5">{{ use.coupon.name }}</p>
            <p class="text-xs text-gray-400 mt-0.5">แลกเมื่อ {{ formatDateTime(use.createdAt) }}</p>
            <p class="text-xs font-mono font-bold mt-1"
              :class="(countdowns[use.id] ?? 0) < 300 ? 'text-red-600' : 'text-green-700'">
              หมดอายุใน {{ countdowns[use.id] !== undefined ? formatCountdown(countdowns[use.id]) : '–' }}
            </p>
          </div>
          <button
            class="flex flex-col items-center gap-1 px-4 py-3 bg-[#1B2B4B] text-white rounded-xl hover:bg-[#2a3f6b] transition-colors flex-shrink-0"
            @click="qrTarget = use"
          >
            <Icon name="mdi:qrcode" class="text-2xl" />
            <span class="text-xs font-medium">แสดง QR</span>
          </button>
        </div>
      </div>
    </div>

    <!-- History panel -->
    <div v-if="showHistory">
      <h2 class="font-semibold text-gray-800 mb-3">ประวัติการแลกแต้ม</h2>
      <div v-if="historyUses.length === 0" class="text-center py-6 text-gray-400 text-sm">
        ยังไม่มีประวัติ
      </div>
      <div v-else class="space-y-2">
        <div v-for="use in historyUses" :key="use.id"
          class="bg-white rounded-xl shadow p-4 flex items-center justify-between gap-3">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-bold text-gray-700 font-mono">{{ use.coupon.code }}</p>
            <p class="text-xs text-gray-500 truncate">{{ use.coupon.name }}</p>
            <p class="text-xs text-gray-400 mt-0.5">แลกเมื่อ {{ formatDateTime(use.createdAt) }}</p>
          </div>
          <span class="text-xs bg-gray-100 text-gray-500 px-2 py-1 rounded-full font-medium flex-shrink-0">
            ใช้แล้ว
          </span>
        </div>
      </div>
    </div>

    <!-- Coupon catalog -->
    <div>
      <h2 class="font-semibold text-gray-800 mb-3">แลกแต้มเป็นคูปอง</h2>

      <div v-if="loading" class="text-center py-10 text-gray-400">กำลังโหลด...</div>

      <div v-else-if="coupons.length === 0" class="bg-white rounded-2xl shadow p-8 text-center text-gray-400">
        <Icon name="mdi:ticket-off" class="text-5xl mb-2" />
        <p class="text-sm">ยังไม่มีคูปองให้แลกแต้ม</p>
      </div>

      <div v-else class="space-y-3">
        <div
          v-for="coupon in coupons"
          :key="coupon.id"
          class="bg-white rounded-2xl shadow p-5"
          :class="{ 'opacity-50': (member?.points ?? 0) < coupon.pointCost }"
        >
          <div class="flex items-start justify-between gap-3">
            <div class="flex-1">
              <div class="flex items-center gap-2 flex-wrap">
                <span class="text-lg font-bold text-[#1B2B4B]">{{ formatDiscount(coupon) }} ส่วนลด</span>
                <span v-if="coupon.minTier" class="text-xs px-2 py-0.5 rounded-full font-medium"
                  :class="{
                    'bg-purple-100 text-purple-700': coupon.minTier === 'VIP',
                    'bg-yellow-100 text-yellow-700': coupon.minTier === 'GOLD',
                    'bg-gray-100 text-gray-600': coupon.minTier === 'SILVER',
                  }">
                  {{ coupon.minTier }}+
                </span>
              </div>
              <p class="text-sm font-medium text-gray-700 mt-0.5">{{ coupon.name }}</p>
              <p v-if="coupon.description" class="text-xs text-gray-400 mt-0.5">{{ coupon.description }}</p>
              <div class="flex items-center gap-3 mt-2 text-xs text-gray-400">
                <span v-if="coupon.expiredAt">หมดอายุ {{ formatDate(coupon.expiredAt) }}</span>
                <span v-if="coupon.perMemberLimit === 1">ใช้ได้ 1 ครั้ง/คน</span>
              </div>
            </div>
            <div class="text-right flex-shrink-0">
              <p class="text-xl font-bold text-[#2a3f6b]">{{ coupon.pointCost.toLocaleString() }}</p>
              <p class="text-xs text-gray-400 mb-2">แต้ม</p>
              <button
                :disabled="(member?.points ?? 0) < coupon.pointCost || redeeming === coupon.id"
                @click="redeemCoupon(coupon)"
                class="px-4 py-1.5 bg-[#1B2B4B] text-white text-xs font-semibold rounded-lg hover:bg-[#2a3f6b] disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
              >
                {{ redeeming === coupon.id ? '...' : 'แลก' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- QR Modal -->
  <Teleport to="body">
    <div v-if="qrTarget" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="qrTarget = null" />
      <div class="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-xs space-y-4">
        <div class="text-center">
          <p class="font-bold text-gray-900 text-lg">{{ qrTarget.coupon.name }}</p>
          <p class="text-xs font-mono font-bold text-[#2a3f6b] tracking-widest mt-0.5">{{ qrTarget.coupon.code }}</p>
        </div>
        <div class="flex justify-center">
          <div class="bg-white p-3 rounded-xl border-2 border-[#C8D8E8] shadow-sm">
            <img
              :src="`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(qrTarget.id)}&margin=4`"
              :alt="`QR ${qrTarget.coupon.code}`"
              class="w-52 h-52"
            />
          </div>
        </div>
        <div class="text-center space-y-1">
          <p class="text-xs text-gray-400">แสดง QR นี้ให้พนักงานสแกน</p>
          <p class="font-mono font-bold text-sm"
            :class="(countdowns[qrTarget.id] ?? 0) < 300 ? 'text-red-600' : 'text-green-700'">
            หมดอายุใน {{ countdowns[qrTarget.id] !== undefined ? formatCountdown(countdowns[qrTarget.id]) : '–' }}
          </p>
        </div>
        <button
          class="w-full py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200"
          @click="qrTarget = null"
        >ปิด</button>
      </div>
    </div>
  </Teleport>
</template>
