<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'member', middleware: 'member' })

const route = useRoute()
const http = useHttpClient()

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
  imageOrientation: string | null
  displayMode: string | null
  bannerColor: string | null
  expiredAt: string | null
  memberOnly: boolean
  minTier: string | null
  coupons: CampaignCoupon[]
}

const campaign = ref<Campaign | null>(null)
const loading = ref(true)
const error = ref('')
const qrCoupon = ref<CampaignCoupon | null>(null)

const campaignId = computed(() => route.params.id as string)

async function loadCampaign(id: string) {
  loading.value = true
  error.value = ''
  try {
    const res = await http.get<{ data: Campaign }>(API_ENDPOINTS.MEMBER.CAMPAIGN_DETAIL(id))
    campaign.value = res.data ?? null
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'ไม่พบแคมเปญนี้'
  } finally {
    loading.value = false
  }
}

onMounted(() => loadCampaign(campaignId.value))
watch(campaignId, (id) => loadCampaign(id))

function formatCouponValue(c: CampaignCoupon) {
  if (c.pointCost) return `${c.pointCost} แต้ม`
  return c.discountKind === 'PERCENT' ? `${c.discountValue}%` : `฿${Number(c.discountValue).toFixed(0)}`
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-5 pb-8">
    <div class="flex items-center gap-3">
      <NuxtLink to="/member" class="text-gray-400 hover:text-gray-600">
        <Icon name="mdi:chevron-left" class="w-6 h-6" />
      </NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">รายละเอียดแคมเปญ</h1>
    </div>

    <div v-if="loading" class="py-16 text-center text-gray-400">กำลังโหลด...</div>
    <div v-else-if="error" class="py-16 text-center text-red-500">{{ error }}</div>

    <template v-else-if="campaign">
      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <!-- Image mode -->
        <div
          v-if="campaign.imageUrl && campaign.displayMode !== 'banner'"
          class="relative overflow-hidden"
          :class="campaign.imageOrientation === 'portrait' ? 'aspect-[3/4]' : 'aspect-video'"
        >
          <img :src="campaign.imageUrl" class="w-full h-full object-cover object-top" alt="" />
        </div>

        <!-- Banner mode -->
        <div
          v-else
          class="px-5 py-6 flex items-center gap-4"
          :style="campaign.displayMode === 'banner' ? `background: ${campaign.bannerColor || '#1B2B4B'}` : ''"
        >
          <img v-if="campaign.imageUrl" :src="campaign.imageUrl" class="w-16 h-16 rounded-xl object-cover shrink-0 border-2 border-white/20" alt="" />
          <p
            class="font-bold text-lg leading-tight"
            :class="campaign.displayMode === 'banner' ? 'text-white' : 'text-gray-900'"
          >{{ campaign.name }}</p>
        </div>

        <div class="p-5 space-y-3">
          <div v-if="campaign.displayMode !== 'banner'" class="flex items-center gap-2 flex-wrap">
            <h2 class="font-bold text-gray-900 text-lg">{{ campaign.name }}</h2>
            <span v-if="campaign.memberOnly" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-purple-100 text-purple-700">เฉพาะสมาชิก</span>
            <span v-if="campaign.minTier" class="px-2 py-0.5 rounded-full text-xs font-semibold bg-amber-100 text-amber-700">{{ campaign.minTier }}+</span>
          </div>

          <p v-if="campaign.description" class="text-sm text-gray-600 leading-relaxed whitespace-pre-line">{{ campaign.description }}</p>

          <p v-if="campaign.expiredAt" class="text-xs text-gray-400">
            สิ้นสุด {{ new Date(campaign.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' }) }}
          </p>
        </div>
      </div>

      <!-- Coupons -->
      <div class="bg-white rounded-2xl shadow overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-50">
          <h2 class="font-semibold text-gray-800">คูปองในแคมเปญนี้</h2>
        </div>
        <div class="p-4 space-y-2">
          <div v-if="campaign.coupons.length === 0" class="text-sm text-gray-400 text-center py-4">
            ยังไม่มีคูปองในแคมเปญนี้
          </div>
          <div
            v-for="coupon in campaign.coupons"
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

      <!-- How to use -->
      <div class="bg-white rounded-2xl shadow p-5">
        <p class="text-sm font-bold text-blue-700 mb-2">วิธีใช้</p>
        <div class="bg-blue-50 rounded-xl px-2 py-2 flex items-center gap-0.5 flex-wrap">
          <span class="text-xs text-blue-600">สั่งออเดอร์</span>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">เลือกสินค้า</span>
          <template v-if="campaign.coupons.length > 0">
            <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
            <span class="text-xs text-blue-600">กดใช้คูปอง</span>
          </template>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">ชำระเงิน</span>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">รับที่ร้าน</span>
        </div>
      </div>
    </template>

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
  </div>
</template>
