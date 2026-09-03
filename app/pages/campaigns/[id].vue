<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'public' })

const route = useRoute()
const http = useHttpClient()

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
}

const campaign = ref<Campaign | null>(null)
const loading = ref(true)
const error = ref('')

const campaignId = computed(() => route.params.id as string)

async function loadCampaign(id: string) {
  loading.value = true
  error.value = ''
  try {
    const res = await http.get<{ data: Campaign }>(API_ENDPOINTS.PUBLIC.CAMPAIGNS.SHOW(id))
    campaign.value = res.data ?? null
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'ไม่พบแคมเปญนี้'
  } finally {
    loading.value = false
  }
}

onMounted(() => loadCampaign(campaignId.value))
watch(campaignId, (id) => loadCampaign(id))
</script>

<template>
  <div class="max-w-lg mx-auto px-4 pb-8 pt-4 space-y-5">
    <div class="flex items-center gap-3">
      <NuxtLink to="/" class="text-gray-400 hover:text-gray-600">
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
          </div>

          <p v-if="campaign.description" class="text-sm text-gray-600 leading-relaxed whitespace-pre-line">{{ campaign.description }}</p>

          <p v-if="campaign.expiredAt" class="text-xs text-gray-400">
            สิ้นสุด {{ new Date(campaign.expiredAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' }) }}
          </p>
        </div>
      </div>

      <!-- Member-only notice -->
      <div v-if="campaign.memberOnly" class="bg-purple-50 border border-purple-100 rounded-2xl p-5 flex items-start gap-3">
        <Icon name="mdi:account-star" class="text-xl text-purple-500 flex-shrink-0 mt-0.5" />
        <div>
          <p class="text-sm font-semibold text-purple-800">โปรโมชันนี้สำหรับสมาชิกเท่านั้น</p>
          <p class="text-xs text-purple-600 mt-0.5">สมัครสมาชิกฟรีเพื่อรับสิทธิ์และคูปองในแคมเปญนี้</p>
        </div>
      </div>

      <!-- How to use -->
      <div class="bg-white rounded-2xl shadow p-5">
        <p class="text-sm font-bold text-blue-700 mb-2">วิธีใช้</p>
        <div class="bg-blue-50 rounded-xl px-2 py-2 flex items-center gap-0.5 flex-wrap">
          <span class="text-xs text-blue-600">สั่งออเดอร์</span>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">เลือกสินค้า</span>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">ชำระเงิน</span>
          <Icon name="mdi:chevron-right" class="text-blue-300 text-xs flex-shrink-0" />
          <span class="text-xs text-blue-600">รับที่ร้าน</span>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex flex-col sm:flex-row gap-3">
        <NuxtLink
          v-if="campaign.memberOnly"
          to="/member/register"
          class="flex-1 text-center py-3 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] transition-colors"
        >
          สมัครสมาชิกฟรี
        </NuxtLink>
        <NuxtLink
          to="/order"
          class="flex-1 text-center py-3 border-2 border-[#1B2B4B] text-[#1B2B4B] font-bold rounded-2xl hover:bg-[#F0F4F8] transition-colors"
        >
          สั่งด่วน (ไม่ต้องสมัคร)
        </NuxtLink>
      </div>
    </template>
  </div>
</template>
