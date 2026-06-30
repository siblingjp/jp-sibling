<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const http = useHttpClient()
const { canInstall, platform, hasNativePrompt, install, dismiss } = usePwaInstall()

async function copyUrlAndDismiss() {
  await navigator.clipboard.writeText(window.location.href)
  dismiss()
}

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
interface Schedule {
  id: string; name: string; openTime: string; closeTime: string; daysOfWeek: string; mapUrl: string | null
}
interface TruckLocation {
  name: string
  description: string | null
  mapUrl: string | null
  openTime: string | null
  closeTime: string | null
  daysOfWeek: string | null
  isOpen: boolean
  canOrder: boolean
  nextOpenLabel: string | null
  nextOpenName: string | null
  schedules: Schedule[]
  activeScheduleId: string | null
}
const truckLocation = ref<TruckLocation | null>(null)
const showTimeline = ref(false)

const isOpen = computed(() => truckLocation.value?.isOpen ?? false)
const canOrder = computed(() => truckLocation.value?.canOrder ?? false)

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
  imageUrl: string | null
  displayMode: string | null
  bannerColor: string | null
  expiredAt: string | null
  memberOnly: boolean
  minTier: string | null
  coupons: CampaignCoupon[]
}

const campaigns = ref<Campaign[]>([])
const expandedCampaign = ref<string | null>(null)
const qrCoupon = ref<CampaignCoupon | null>(null)

// ─── Campaign Popup ───────────────────────────────────────────────────────────
const showCampaignPopup = ref(false)
const popupDismissToday = ref(false)
const POPUP_KEY = 'campaign_popup_dismissed'

function getTodayStr() {
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Bangkok' }).format(new Date())
}

function closeCampaignPopup() {
  if (popupDismissToday.value) {
    localStorage.setItem(POPUP_KEY, getTodayStr())
  }
  showCampaignPopup.value = false
}

onMounted(async () => {
  try {
    const [campRes, homeRes] = await Promise.all([
      http.get<{ data: Campaign[] }>(API_ENDPOINTS.MEMBER.CAMPAIGNS),
      http.get<{ data: { truckLocation: TruckLocation | null } }>('/api/public/home'),
    ])
    campaigns.value = campRes.data ?? []
    truckLocation.value = homeRes.data?.truckLocation ?? null

    if (campaigns.value.length > 0) {
      const dismissed = localStorage.getItem(POPUP_KEY)
      if (dismissed !== getTodayStr()) {
        showCampaignPopup.value = true
      }
    }
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
    <!-- PWA Install Banner -->
    <Transition name="slide-down">
      <div v-if="canInstall" class="bg-[#1B2B4B] rounded-2xl p-4 flex items-center gap-3 shadow">
        <img src="/logo.jpg" alt="" class="w-10 h-10 rounded-full object-cover flex-shrink-0" />

        <!-- Android / Desktop: native prompt -->
        <template v-if="hasNativePrompt">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-white leading-tight">ติดตั้งแอปบนหน้าจอ</p>
            <p class="text-xs text-white/60 leading-tight">เปิดได้เร็วขึ้น ใช้งานแบบ app</p>
          </div>
          <button
            class="px-3 py-1.5 bg-white text-[#1B2B4B] text-xs font-bold rounded-lg hover:bg-[#F0F4F8] flex-shrink-0"
            @click="install"
          >ติดตั้ง</button>
        </template>

        <!-- iOS Safari: manual -->
        <template v-else-if="platform === 'ios-safari'">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-white leading-tight">ติดตั้ง JP Sibling บน iPhone</p>
            <p class="text-xs text-white/60 leading-tight">
              กดปุ่ม <Icon name="mdi:export-variant" class="inline text-sm align-middle" /> แชร์ (Share) แล้วเลือก "เพิ่มไปยังหน้าจอโฮม (Add to Home Screen)"
            </p>
          </div>
        </template>

        <!-- iOS Chrome: ต้องเปิดด้วย Safari -->
        <template v-else-if="platform === 'ios-other'">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-white leading-tight">ติดตั้งผ่าน Safari</p>
            <p class="text-xs text-white/60 leading-tight">Chrome บน iOS ไม่รองรับ — คัดลอกลิงก์แล้วเปิดใน Safari จากนั้นกด "เพิ่มไปยังหน้าจอโฮม"</p>
          </div>
          <button
            class="px-3 py-1.5 bg-white text-[#1B2B4B] text-xs font-bold rounded-lg hover:bg-[#F0F4F8] flex-shrink-0"
            @click="copyUrlAndDismiss"
          >คัดลอกลิงก์</button>
        </template>

        <button class="text-white/40 hover:text-white p-1 flex-shrink-0" @click="dismiss">
          <Icon name="mdi:close" class="text-base" />
        </button>
      </div>
    </Transition>

    <!-- Store status -->
    <div v-if="truckLocation" class="bg-white rounded-2xl shadow p-4 flex items-start gap-3">
      <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
        :class="{ 'bg-green-100': isOpen, 'bg-blue-100': !isOpen && canOrder, 'bg-gray-100': !isOpen && !canOrder }">
        <Icon :name="isOpen ? 'mdi:store' : canOrder ? 'mdi:store-clock' : 'mdi:store-off'" class="text-xl"
          :class="{ 'text-green-600': isOpen, 'text-blue-500': !isOpen && canOrder, 'text-gray-400': !isOpen && !canOrder }" />
      </div>
      <div class="flex-1 min-w-0">
        <template v-if="isOpen">
          <p class="text-xs text-gray-400 font-medium mb-0.5">วันนี้อยู่ที่</p>
          <p class="font-semibold text-sm text-green-700">{{ truckLocation.name }} · เปิดอยู่</p>
          <p class="text-xs text-gray-400 truncate">{{ storeHoursText }}</p>
          <p v-if="truckLocation.description" class="text-xs text-gray-400 truncate">{{ truckLocation.description }}</p>
        </template>
        <template v-else-if="canOrder">
          <div class="flex items-center gap-2 mb-0.5">
            <p class="text-xs text-gray-400 font-medium">ร้านปิดอยู่ แต่</p>
            <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-blue-100 text-blue-600">สั่งออนไลน์ได้</span>
          </div>
          <p v-if="truckLocation.nextOpenLabel" class="font-semibold text-sm text-gray-700 leading-snug">เปิดอีกครั้ง {{ truckLocation.nextOpenLabel }}</p>
          <p v-if="truckLocation.nextOpenName" class="text-xs text-gray-400 truncate">ที่ {{ truckLocation.nextOpenName }}</p>
        </template>
        <template v-else-if="truckLocation.nextOpenLabel">
          <div class="flex items-center gap-2 mb-0.5">
            <p class="text-xs text-gray-400 font-medium">ร้านจะเปิดอีกครั้ง</p>
            <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-red-100 text-red-600">ปิดอยู่</span>
          </div>
          <p class="font-semibold text-sm text-gray-700 leading-snug">{{ truckLocation.nextOpenLabel }}</p>
          <p class="text-xs text-gray-400 truncate">ที่ {{ truckLocation.nextOpenName }}</p>
        </template>
        <template v-else>
          <p class="text-xs text-gray-400 font-medium mb-0.5">สถานะร้าน</p>
          <p class="font-semibold text-sm text-gray-500">ปิดอยู่</p>
        </template>
      </div>
      <div class="flex flex-col items-end gap-1.5 flex-shrink-0">
        <a
          v-if="truckLocation.mapUrl"
          :href="truckLocation.mapUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="flex items-center gap-1 text-xs text-[#1B2B4B] font-medium hover:underline"
        >
          <Icon name="mdi:map-marker" class="w-4 h-4 text-red-400" />
          แผนที่
        </a>
        <button
          v-if="truckLocation.schedules?.length"
          class="flex items-center gap-1 text-xs text-gray-400 hover:text-[#1B2B4B] transition-colors"
          @click="showTimeline = true"
        >
          <Icon name="mdi:calendar-clock" class="text-sm" />
          ไทม์ไลน์
        </button>
      </div>
    </div>

    <SharedLocationTimeline
      v-if="showTimeline && truckLocation"
      :schedules="truckLocation.schedules"
      :active-schedule-id="truckLocation.activeScheduleId"
      @close="showTimeline = false"
    />

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
      </div>
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
          <!-- Banner mode header -->
          <button
            v-if="camp.displayMode === 'banner'"
            type="button"
            class="w-full text-left relative flex items-center gap-4 px-4 py-4"
            :style="`background: ${camp.bannerColor || '#1B2B4B'}`"
            @click="toggleCampaign(camp.id)"
          >
            <img v-if="camp.imageUrl" :src="camp.imageUrl" class="w-12 h-12 rounded-xl object-cover shrink-0 border-2 border-white/20" alt="" />
            <div class="flex-1 min-w-0">
              <p class="font-semibold text-white truncate">{{ camp.name }}</p>
              <p v-if="camp.description" class="text-xs text-white/70 mt-0.5 truncate">{{ camp.description }}</p>
              <p v-if="camp.expiredAt" class="text-xs text-white/50 mt-0.5">
                ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'short' }) }}
              </p>
            </div>
            <div class="flex items-center gap-2 ml-2 flex-shrink-0">
              <span class="text-xs bg-white/20 text-white px-2 py-0.5 rounded-full font-medium">{{ camp.coupons.length }} คูปอง</span>
              <Icon :name="expandedCampaign === camp.id ? 'mdi:chevron-up' : 'mdi:chevron-down'" class="w-5 h-5 text-white/70" />
            </div>
          </button>

          <!-- Image mode header -->
          <button
            v-else
            type="button"
            class="w-full text-left"
            @click="toggleCampaign(camp.id)"
          >
            <div v-if="camp.imageUrl" class="relative aspect-video overflow-hidden">
              <img :src="camp.imageUrl" class="w-full h-full object-cover" alt="" />
              <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <div class="absolute bottom-0 left-0 right-0 p-3 flex items-end justify-between">
                <div class="flex-1 min-w-0">
                  <p class="font-semibold text-white truncate">{{ camp.name }}</p>
                  <p v-if="camp.expiredAt" class="text-xs text-white/60 mt-0.5">
                    ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'short' }) }}
                  </p>
                </div>
                <div class="flex items-center gap-1.5 ml-2 flex-shrink-0">
                  <span class="text-xs bg-white/20 text-white px-2 py-0.5 rounded-full font-medium">{{ camp.coupons.length }} คูปอง</span>
                  <Icon :name="expandedCampaign === camp.id ? 'mdi:chevron-up' : 'mdi:chevron-down'" class="w-5 h-5 text-white/70" />
                </div>
              </div>
            </div>
            <div v-else class="flex items-center justify-between p-4">
              <div class="flex-1 min-w-0">
                <p class="font-semibold text-gray-900 truncate">{{ camp.name }}</p>
                <p v-if="camp.description" class="text-xs text-gray-400 mt-0.5 truncate">{{ camp.description }}</p>
                <p v-if="camp.expiredAt" class="text-xs text-gray-400 mt-0.5">
                  ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'short' }) }}
                </p>
              </div>
              <div class="flex items-center gap-2 ml-3 flex-shrink-0">
                <span class="text-xs bg-[#F0F4F8] text-[#1B2B4B] px-2 py-0.5 rounded-full font-medium">{{ camp.coupons.length }} คูปอง</span>
                <Icon :name="expandedCampaign === camp.id ? 'mdi:chevron-up' : 'mdi:chevron-down'" class="w-5 h-5 text-gray-400" />
              </div>
            </div>
          </button>

          <div v-if="expandedCampaign === camp.id" class="border-t border-gray-50 px-4 pb-4 pt-2 space-y-2">
            <div v-if="camp.coupons.length === 0" class="text-xs text-gray-400 text-center py-2">
              ยังไม่มีคูปองในแคมเปญนี้
            </div>
            <div
              v-for="coupon in camp.coupons"
              :key="coupon.id"
              class="flex items-center justify-between bg-[#F0F4F8] rounded-xl px-4 py-3 gap-3"
            >
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-[#1B2B4B] font-mono">{{ coupon.code }}</p>
                <p class="text-xs text-gray-600 truncate">{{ coupon.name }}</p>
                <p v-if="coupon.description" class="text-xs text-gray-400 truncate">{{ coupon.description }}</p>
                <p class="text-sm font-bold text-[#2a3f6b] mt-0.5">{{ formatCouponValue(coupon) }}</p>
                <p v-if="coupon.minTier" class="text-xs text-gray-400">{{ coupon.minTier }}+</p>
              </div>
              <div class="flex-shrink-0 flex flex-col gap-2">
                <button
                  class="flex items-center gap-1 text-xs text-[#1B2B4B] font-semibold border border-[#1B2B4B] px-3 py-2 rounded-lg hover:bg-[#F0F4F8] transition-colors"
                  @click="qrCoupon = coupon"
                >
                  <Icon name="mdi:qrcode" class="w-3.5 h-3.5" />
                  แสดง QR
                </button>
                <NuxtLink
                  :to="`/member/orders/new?coupon=${coupon.code}`"
                  class="flex items-center gap-1 text-xs text-white font-semibold bg-[#1B2B4B] px-3 py-2 rounded-lg hover:bg-[#2a3f6b] transition-colors"
                >
                  <Icon name="mdi:cart-arrow-right" class="w-3.5 h-3.5" />
                  กดใช้
                </NuxtLink>
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
        <img src="/logo-icon-white.png" alt="สั่งกาแฟ" class="w-10 h-10 object-contain mx-auto mb-2" />
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
        <Icon name="mdi:qrcode" class="text-4xl mb-2" />
        <!-- <Icon name="flat-color-icons:qrcode" class="text-4xl mb-2" /> -->
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

  <!-- Campaign Popup -->
  <Transition name="fade">
    <div
      v-if="showCampaignPopup"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
    >
      <!-- Backdrop -->
      <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeCampaignPopup" />

      <!-- Modal -->
      <div class="relative w-full max-w-sm bg-white rounded-3xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col">
        <!-- Header -->
        <div class="bg-gradient-to-r from-[#1B2B4B] to-[#2a3f6b] px-5 py-4 flex items-center justify-between flex-shrink-0">
          <div class="flex items-center gap-2">
            <Icon name="mdi:tag-multiple" class="text-xl text-white" />
            <p class="font-bold text-white">โปรโมชันและแคมเปญ</p>
          </div>
          <button class="text-white/60 hover:text-white transition-colors p-1" @click="closeCampaignPopup">
            <Icon name="mdi:close" class="text-xl" />
          </button>
        </div>

        <!-- Campaign list -->
        <div class="overflow-y-auto flex-1">
          <div
            v-for="camp in campaigns"
            :key="camp.id"
            class="border-b border-gray-100 last:border-0"
          >
            <!-- Image (image mode) -->
            <div v-if="camp.imageUrl && camp.displayMode !== 'banner'" class="relative aspect-video overflow-hidden">
              <img :src="camp.imageUrl" class="w-full h-full object-cover" alt="" />
              <div class="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
              <div class="absolute bottom-0 left-0 right-0 p-4">
                <p class="font-bold text-white text-base leading-tight">{{ camp.name }}</p>
                <p v-if="camp.description" class="text-xs text-white/80 mt-1 leading-relaxed">{{ camp.description }}</p>
                <p v-if="camp.expiredAt" class="text-xs text-white/50 mt-1">
                  ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' }) }}
                </p>
              </div>
            </div>

            <!-- Banner color mode -->
            <div
              v-else
              class="px-4 py-4"
              :style="camp.displayMode === 'banner' ? `background: ${camp.bannerColor || '#1B2B4B'}` : ''"
            >
              <div class="flex items-start gap-3">
                <img v-if="camp.imageUrl" :src="camp.imageUrl" class="w-12 h-12 rounded-xl object-cover flex-shrink-0" alt="" />
                <div class="flex-1 min-w-0">
                  <p class="font-bold text-base leading-tight" :class="camp.displayMode === 'banner' ? 'text-white' : 'text-gray-900'">{{ camp.name }}</p>
                  <p v-if="camp.description" class="text-sm mt-1 leading-relaxed" :class="camp.displayMode === 'banner' ? 'text-white/80' : 'text-gray-600'">{{ camp.description }}</p>
                  <p v-if="camp.expiredAt" class="text-xs mt-1.5" :class="camp.displayMode === 'banner' ? 'text-white/50' : 'text-gray-400'">
                    ถึง {{ new Date(camp.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' }) }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Coupons -->
            <div v-if="camp.coupons.length" class="px-2 pt-3 pb-4 space-y-2">
              <div
                v-for="coupon in camp.coupons"
                :key="coupon.id"
                class="flex items-center justify-between bg-[#F0F4F8] rounded-xl px-4 py-3 gap-3"
              >
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-black text-[#1B2B4B] font-mono tracking-wider">{{ coupon.code }}</p>
                  <p class="text-xs text-gray-500 mt-0.5">{{ coupon.name }}</p>
                  <p class="text-base font-black text-[#2a3f6b] mt-0.5">{{ formatCouponValue(coupon) }}</p>
                </div>
                <div class="flex-shrink-0 flex flex-col gap-2">
                  <button
                    class="flex items-center gap-1 text-xs text-[#1B2B4B] font-semibold border border-[#1B2B4B] px-3 py-2 rounded-lg hover:bg-[#F0F4F8] transition-colors"
                    @click="qrCoupon = coupon"
                  >
                    <Icon name="mdi:qrcode" class="w-3.5 h-3.5" />
                    แสดง QR
                  </button>
                  <NuxtLink
                    :to="`/member/orders/new?coupon=${coupon.code}`"
                    class="flex items-center gap-1 text-xs text-white font-semibold bg-[#1B2B4B] px-3 py-2 rounded-lg hover:bg-[#2a3f6b] transition-colors"
                    @click="closeCampaignPopup"
                  >
                    <Icon name="mdi:cart-arrow-right" class="w-3.5 h-3.5" />
                    กดใช้
                  </NuxtLink>
                </div>
              </div>
            </div>
          </div>

          <!-- How to use -->
          <div class="mx-4">
           <span class="text-xs font-bold text-blue-700 mr-1">วิธีใช้:</span>
          </div>
          <div class="mx-2 mb-4 mt-1 bg-blue-50 rounded-xl px-2 py-2 flex items-center gap-0.5 flex-wrap">
            <span class="text-xs text-blue-600">สั่งออเดอร์</span>
            <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
            <span class="text-xs text-blue-600">เลือกสินค้า</span>
            <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
            <span class="text-xs text-blue-600">กดใช้คูปอง</span>
            <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
            <span class="text-xs text-blue-600">ชำระเงิน</span>
            <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
            <span class="text-xs text-blue-600">รับที่ร้าน</span>
          </div>
        </div>

        <!-- Footer -->
        <div class="px-5 py-4 border-t border-gray-100 flex items-center justify-between gap-3 flex-shrink-0 bg-white">
          <label class="flex items-center gap-2 cursor-pointer select-none">
            <input
              v-model="popupDismissToday"
              type="checkbox"
              class="w-4 h-4 rounded accent-[#1B2B4B] cursor-pointer"
            />
            <span class="text-sm text-gray-500">ไม่ต้องแสดงวันนี้อีก</span>
          </label>
          <button
            class="px-5 py-2 bg-[#1B2B4B] text-white text-sm font-semibold rounded-xl hover:bg-[#2a3f6b] transition-colors"
            @click="closeCampaignPopup"
          >
            ปิด
          </button>
        </div>
      </div>
    </div>
  </Transition>

  <!-- QR Modal สำหรับ campaign coupon -->
  <Teleport to="body">
    <div v-if="qrCoupon" class="fixed inset-0 z-[60] flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="qrCoupon = null" />
      <div class="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-xs space-y-4">
        <div class="text-center">
          <p class="font-bold text-gray-900 text-lg">{{ qrCoupon.name }}</p>
          <p class="text-2xl font-bold text-[#1B2B4B] mt-0.5">{{ formatCouponValue(qrCoupon) }} ส่วนลด</p>
        </div>
        <div class="flex justify-center">
          <div class="bg-white p-3 rounded-xl border-2 border-[#C8D8E8] shadow-sm">
            <img
              :src="`https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(qrCoupon.code)}&margin=4`"
              :alt="`QR ${qrCoupon.code}`"
              class="w-52 h-52"
            />
          </div>
        </div>
        <div class="text-center space-y-1">
          <p class="text-sm font-mono font-bold text-[#2a3f6b] tracking-widest">{{ qrCoupon.code }}</p>
          <p class="text-xs text-gray-400">แสดง QR นี้ให้พนักงานสแกน</p>
        </div>
        <div class="flex gap-2">
          <button
            class="flex-1 py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200"
            @click="qrCoupon = null"
          >ปิด</button>
          <NuxtLink
            :to="`/member/orders/new?coupon=${qrCoupon.code}`"
            class="flex-1 py-2.5 rounded-xl bg-[#1B2B4B] text-white text-sm font-semibold hover:bg-[#2a3f6b] text-center"
            @click="qrCoupon = null"
          >สั่งออเดอร์</NuxtLink>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.slide-down-enter-active, .slide-down-leave-active { transition: all 0.3s ease; }
.slide-down-enter-from, .slide-down-leave-to { opacity: 0; transform: translateY(-12px); }
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
