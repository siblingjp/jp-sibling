<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()

// ─── Tier config ─────────────────────────────────────────────────────────────
const tierConfig = computed(() => {
  const t = member.value?.tier ?? 'SILVER'
  const base = useTier(t)
  const next = t === 'SILVER' ? 'Gold' : t === 'GOLD' ? 'VIP' : null
  const nextSpend = t === 'SILVER' ? 2000 : t === 'GOLD' ? 5000 : 0
  return { ...base, next, nextSpend }
})

const totalSpent = computed(() => Number(member.value?.totalSpent ?? 0))
const spendProgress = computed(() => {
  if (!tierConfig.value.next) return 100
  return Math.min((totalSpent.value / tierConfig.value.nextSpend) * 100, 100)
})
const spendRemaining = computed(() => {
  if (!tierConfig.value.next) return 0
  return Math.max(tierConfig.value.nextSpend - totalSpent.value, 0)
})

// ─── Store / Truck location ───────────────────────────────────────────────────
interface TruckLocation {
  name: string
  description: string | null
  mapUrl: string | null
  openTime: string | null
  closeTime: string | null
  daysOfWeek: string | null
}
const truckLocation = ref<TruckLocation | null>(null)

function parseTime(t: string | null) {
  if (!t) return null
  const [h, m] = t.split(':').map(Number)
  return h + (m ?? 0) / 60
}

const isOpen = computed(() => {
  if (!truckLocation.value) return false
  const open = parseTime(truckLocation.value.openTime)
  const close = parseTime(truckLocation.value.closeTime)
  if (open === null || close === null) return false
  const now = new Date()
  const h = now.getHours() + now.getMinutes() / 60
  return h >= open && h < close
})

const storeHoursText = computed(() => {
  if (!truckLocation.value) return ''
  const loc = truckLocation.value
  const parts: string[] = []
  if (loc.daysOfWeek) parts.push(loc.daysOfWeek)
  if (loc.openTime && loc.closeTime) parts.push(`${loc.openTime}–${loc.closeTime}`)
  return parts.join(' ')
})

// ─── Campaigns ────────────────────────────────────────────────────────────────
interface CampaignCoupon {
  id: string
  code: string
  name: string
  description: string | null
  type: string
  discountKind: string
  discountValue: number
  pointCost: number | null
  minTier: string | null
  expiredAt: string | null
}
interface Campaign {
  id: string
  name: string
  description: string | null
  expiredAt: string | null
  memberOnly: boolean
  minTier: string | null
  coupons: CampaignCoupon[]
}

const campaigns = ref<Campaign[]>([])
const expandedCampaign = ref<string | null>(null)

onMounted(async () => {
  try {
    const [campRes, homeRes] = await Promise.all([
      http.get<{ data: Campaign[] }>(API_ENDPOINTS.MEMBER.CAMPAIGNS),
      http.get<{ data: { truckLocation: TruckLocation | null } }>('/api/public/home'),
    ])
    campaigns.value = campRes.data ?? []
    truckLocation.value = homeRes.data?.truckLocation ?? null
  } catch {
    // silent
  }
})

function toggleCampaign(id: string) {
  expandedCampaign.value = expandedCampaign.value === id ? null : id
}

function formatCouponValue(c: CampaignCoupon) {
  if (c.pointCost) return `${c.pointCost} แต้ม`
  return c.discountKind === 'PERCENT' ? `${c.discountValue}%` : `฿${Number(c.discountValue).toFixed(0)}`
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-5">
    <!-- Member card -->
    <div class="bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b] rounded-2xl p-6 text-white shadow-lg">
      <div class="flex items-center gap-4 mb-5">
        <div class="w-14 h-14 rounded-full bg-white/20 flex items-center justify-center text-2xl font-bold overflow-hidden flex-shrink-0">
          <img v-if="member?.profileImage" :src="member.profileImage" class="w-full h-full object-cover" />
          <span v-else>{{ member?.name?.[0]?.toUpperCase() }}</span>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-white/70 text-sm">ยินดีต้อนรับกลับ</p>
          <p class="text-xl font-bold truncate">{{ member?.name }}</p>
          <span class="inline-flex items-center gap-1 text-xs px-2.5 py-0.5 rounded-full font-medium mt-0.5"
            :class="[tierConfig.badgeBg, tierConfig.badgeText]">
            <Icon :name="tierConfig.icon" class="w-3.5 h-3.5" :class="tierConfig.iconColor" />
            {{ tierConfig.label }}
          </span>
        </div>
      </div>

      <div class="bg-white/10 rounded-xl p-4">
        <p class="text-white/70 text-sm mb-1">แต้มสะสม</p>
        <p class="text-4xl font-bold">{{ (member?.points ?? 0).toLocaleString() }}</p>
        <p class="text-white/70 text-sm mt-1">1 แต้ม = ฿1 ส่วนลด</p>
      </div>
    </div>

    <!-- Store status -->
    <div v-if="truckLocation" class="bg-white rounded-2xl shadow p-4 flex items-center gap-3">
      <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
        :class="isOpen ? 'bg-green-100' : 'bg-red-100'">
        <Icon :name="isOpen ? 'mdi:store-check' : 'mdi:store-off'" class="text-xl"
          :class="isOpen ? 'text-green-600' : 'text-red-500'" />
      </div>
      <div class="flex-1 min-w-0">
        <p class="font-semibold text-sm" :class="isOpen ? 'text-green-700' : 'text-red-600'">
          {{ truckLocation.name }} · {{ isOpen ? 'เปิดอยู่' : 'ปิดอยู่' }}
        </p>
        <p class="text-xs text-gray-400 truncate">{{ storeHoursText }}</p>
        <p v-if="truckLocation.description" class="text-xs text-gray-400 truncate">{{ truckLocation.description }}</p>
      </div>
      <a
        v-if="truckLocation.mapUrl"
        :href="truckLocation.mapUrl"
        target="_blank"
        rel="noopener noreferrer"
        class="flex items-center gap-1 text-xs text-[#1B2B4B] font-medium hover:underline flex-shrink-0"
      >
        <Icon name="mdi:map-marker" class="w-4 h-4 text-red-400" />
        แผนที่
      </a>
    </div>

    <!-- Tier progress -->
    <div v-if="tierConfig.next" class="bg-white rounded-2xl shadow p-5">
      <div class="flex justify-between items-center mb-2">
        <span class="font-semibold text-gray-700">ความคืบหน้าระดับ</span>
        <span class="text-sm text-gray-500 flex items-center gap-1">
          <Icon :name="tierConfig.icon" class="w-4 h-4" :class="tierConfig.iconColor" />
          {{ tierConfig.label }} → {{ tierConfig.next }}
        </span>
      </div>
      <div class="w-full bg-gray-100 rounded-full h-3 mb-2">
        <div class="h-3 rounded-full bg-[#C8D8E8] transition-all" :style="{ width: spendProgress + '%' }" />
      </div>
      <p class="text-sm text-gray-500">
        ใช้จ่ายอีก ฿{{ spendRemaining.toLocaleString() }} เพื่อเลื่อนระดับเป็น {{ tierConfig.next }}
      </p>
    </div>
    <div v-else class="bg-white rounded-2xl shadow p-5 text-center flex items-center justify-center gap-2">
      <Icon name="mdi:crown" class="text-xl text-purple-500" />
      <p class="text-purple-700 font-semibold">คุณอยู่ในระดับ VIP — ระดับสูงสุดแล้ว!</p>
    </div>

    <!-- Campaigns -->
    <div v-if="campaigns.length > 0">
      <h2 class="font-semibold text-gray-800 mb-3 flex items-center gap-2">
        <Icon name="mdi:tag-multiple" class="text-[#1B2B4B]" />
        โปรโมชันและแคมเปญ
      </h2>
      <div class="space-y-2">
        <div
          v-for="camp in campaigns"
          :key="camp.id"
          class="bg-white rounded-2xl shadow overflow-hidden"
        >
          <button
            type="button"
            class="w-full flex items-center justify-between p-4 text-left"
            @click="toggleCampaign(camp.id)"
          >
            <div class="flex-1 min-w-0">
              <p class="font-semibold text-gray-900 truncate">{{ camp.name }}</p>
              <p v-if="camp.description" class="text-xs text-gray-400 mt-0.5 truncate">{{ camp.description }}</p>
              <p v-if="camp.expiredAt" class="text-xs text-gray-400 mt-0.5">
                ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'short' }) }}
              </p>
            </div>
            <div class="flex items-center gap-2 ml-3 flex-shrink-0">
              <span class="text-xs bg-[#F0F4F8] text-[#1B2B4B] px-2 py-0.5 rounded-full font-medium">
                {{ camp.coupons.length }} คูปอง
              </span>
              <Icon :name="expandedCampaign === camp.id ? 'mdi:chevron-up' : 'mdi:chevron-down'" class="w-5 h-5 text-gray-400" />
            </div>
          </button>

          <div v-if="expandedCampaign === camp.id" class="border-t border-gray-50 px-4 pb-4 pt-2 space-y-2">
            <div v-if="camp.coupons.length === 0" class="text-xs text-gray-400 text-center py-2">
              ยังไม่มีคูปองในแคมเปญนี้
            </div>
            <div
              v-for="coupon in camp.coupons"
              :key="coupon.id"
              class="flex items-center justify-between bg-[#F0F4F8] rounded-xl px-4 py-3"
            >
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-[#1B2B4B] font-mono">{{ coupon.code }}</p>
                <p class="text-xs text-gray-600 truncate">{{ coupon.name }}</p>
                <p v-if="coupon.description" class="text-xs text-gray-400 truncate">{{ coupon.description }}</p>
              </div>
              <div class="ml-3 text-right flex-shrink-0">
                <p class="text-sm font-bold text-[#2a3f6b]">{{ formatCouponValue(coupon) }}</p>
                <p v-if="coupon.minTier" class="text-xs text-gray-400">{{ coupon.minTier }}+</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick actions -->
    <div class="grid grid-cols-2 gap-4">
      <NuxtLink
        to="/member/orders/new"
        class="bg-[#1B2B4B] text-white rounded-2xl p-5 text-center shadow hover:bg-[#2a3f6b] transition-colors"
      >
        <Icon name="flat-color-icons:shop" class="text-4xl mb-2" />
        <p class="font-semibold">สั่งอาหาร</p>
        <p class="text-xs text-[#C8D8E8] mt-0.5">สั่งออนไลน์</p>
      </NuxtLink>

      <NuxtLink
        to="/member/redeem"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="mdi:gift" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">แลกแต้ม</p>
        <p class="text-xs text-gray-500 mt-0.5">ใช้แต้มของคุณ</p>
      </NuxtLink>

      <NuxtLink
        to="/member/points"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="flat-color-icons:bar-chart" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">ประวัติแต้ม</p>
        <p class="text-xs text-gray-500 mt-0.5">บันทึกการได้และแลกแต้ม</p>
      </NuxtLink>

      <NuxtLink
        to="/member/qr"
        class="bg-white rounded-2xl p-5 text-center shadow hover:shadow-md transition-shadow border border-gray-100"
      >
        <Icon name="flat-color-icons:phone-android" class="text-4xl mb-2" />
        <p class="font-semibold text-gray-800">QR ของฉัน</p>
        <p class="text-xs text-gray-500 mt-0.5">แสดงที่เคาน์เตอร์</p>
      </NuxtLink>
    </div>

    <!-- Recent orders shortcut -->
    <NuxtLink
      to="/member/orders"
      class="flex items-center justify-between bg-white rounded-2xl shadow p-5 hover:shadow-md transition-shadow"
    >
      <div>
        <p class="font-semibold text-gray-800">ออเดอร์ของฉัน</p>
        <p class="text-sm text-gray-500">ดูประวัติการสั่ง</p>
      </div>
      <Icon name="mdi:chevron-right" class="w-5 h-5 text-gray-400" />
    </NuxtLink>
  </div>
</template>
