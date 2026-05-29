<script setup lang="ts">
import { API_ENDPOINTS } from '~/composables/constants/api'

definePageMeta({ layout: 'public' })

const http = useHttpClient()
const { member, fetchMe } = useMemberAuth()

interface HomeData {
  products: { id: string; name: string; imageUrl: string | null; category: { name: string } }[]
  campaigns: { id: string; title: string; description: string | null; imageUrl: string | null; endsAt: string | null }[]
  truckLocation: { name: string; description: string | null; mapUrl: string | null; openTime: string | null; closeTime: string | null; daysOfWeek: string | null } | null
  topRequests: { id: string; name: string; description: string | null; voteCount: number }[]
}

interface LocationRequest {
  id: string; name: string; description: string | null; voteCount: number
}

const data = ref<HomeData | null>(null)
const allRequests = ref<LocationRequest[]>([])
const myVotedId = ref<string | null>(null)
const showRequestForm = ref(false)
const requestForm = reactive({ name: '', description: '' })
const submitting = ref(false)
const voting = ref(false)
const formError = ref('')
const { showSuccess, showError } = useAlert()

const benefits = [
  { icon: 'flat-color-icons:approval', title: 'สะสมแต้ม', desc: 'ทุก ฿10 = 1 pt' },
  { icon: 'mdi:gift', title: 'แต้มแลกลด', desc: 'ใช้แต้มแลกส่วนลด' },
  { icon: 'flat-color-icons:phone-android', title: 'สั่งล่วงหน้า', desc: 'ไม่ต้องรอนาน' },
  { icon: 'flat-color-icons:vip', title: 'สิทธิ์ VIP', desc: 'แต้มโบนัสพิเศษ' },
]

onMounted(async () => {
  await fetchMe()
  const res = await http.get<{ success: boolean; data: HomeData }>('/api/public/home')
  data.value = res.data ?? null
  allRequests.value = data.value?.topRequests ?? []
})

async function submitRequest() {
  if (!member.value) { await navigateTo('/member/login'); return }
  formError.value = ''
  submitting.value = true
  try {
    await http.post('/api/public/location/request', {
      name: requestForm.name,
      description: requestForm.description || undefined,
    })
    showSuccess('เสนอสถานที่เรียบร้อยแล้ว!')
    requestForm.name = ''
    requestForm.description = ''
    showRequestForm.value = false
    await refreshRequests()
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : 'เกิดข้อผิดพลาด'
  } finally {
    submitting.value = false
  }
}

async function vote(requestId: string) {
  if (!member.value) { await navigateTo('/member/login'); return }
  voting.value = true
  try {
    await http.post('/api/public/location/vote', { requestId })
    myVotedId.value = requestId
    await refreshRequests()
    showSuccess('โหวตเรียบร้อยแล้ว!')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'เกิดข้อผิดพลาด')
  } finally {
    voting.value = false
  }
}

async function refreshRequests() {
  const res = await http.get<{ success: boolean; data: { requests: LocationRequest[] } }>('/api/public/location/requests')
  allRequests.value = res.data?.requests ?? []
}

const maxVotes = computed(() => Math.max(...allRequests.value.map(r => r.voteCount), 1))
</script>

<template>
  <div>
    <!-- ─── Hero ─────────────────────────────────────────────────────────── -->
    <section class="relative overflow-hidden bg-gradient-to-br from-[#F8FAFC] via-[#DDEAF6] to-[#C8D8E8] min-h-[90vh] flex items-center">
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <svg class="absolute -bottom-1 left-0 w-full" viewBox="0 0 1440 120" fill="none">
          <path d="M0,60 C360,120 1080,0 1440,60 L1440,120 L0,120 Z" fill="white"/>
        </svg>
        <svg class="absolute top-10 right-[-2rem] opacity-10 w-96 h-96" viewBox="0 0 200 200">
          <circle cx="100" cy="80" r="60" fill="#1B2B4B"/>
          <ellipse cx="100" cy="145" rx="70" ry="15" fill="#1B2B4B"/>
          <path d="M90,20 Q100,0 110,20 Q120,0 130,20" stroke="#1B2B4B" stroke-width="4" fill="none"/>
        </svg>
      </div>
      <div class="relative max-w-4xl mx-auto px-6 py-24 text-center">
        <img src="/logo.jpg" alt="Sibling Coffee" class="w-32 h-32 mx-auto rounded-full shadow-xl mb-8 object-cover" />
        <h1 class="text-5xl md:text-6xl font-bold text-[#1B2B4B] leading-tight mb-4">Sibling Coffee</h1>
        <p class="text-xl text-[#1B2B4B]/70 mb-10">พบกันทุกเช้า ที่ไหนก็ได้ ☕</p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <NuxtLink
            to="/member/orders/new"
            class="px-8 py-4 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] transition-all shadow-lg hover:-translate-y-0.5"
          >
            สั่งออนไลน์
          </NuxtLink>
          <NuxtLink
            to="/member/register"
            class="px-8 py-4 bg-white text-[#1B2B4B] font-bold rounded-2xl border-2 border-[#C8D8E8] hover:bg-[#F0F4F8] transition-all shadow hover:-translate-y-0.5"
          >
            สมัครสมาชิกฟรี
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- ─── Truck Location Banner ─────────────────────────────────────────── -->
    <section v-if="data?.truckLocation" class="bg-[#1B2B4B] text-white py-5">
      <div class="max-w-4xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-3">
        <div class="flex items-center gap-3">
          <Icon name="flat-color-icons:globe" class="text-2xl flex-shrink-0" />
          <div>
            <p class="font-bold text-lg">{{ data.truckLocation.name }}</p>
            <p class="text-white/70 text-sm">
              {{ data.truckLocation.daysOfWeek }}
              <span v-if="data.truckLocation.openTime && data.truckLocation.closeTime">
                · {{ data.truckLocation.openTime }}–{{ data.truckLocation.closeTime }}
              </span>
            </p>
          </div>
        </div>
        <a
          v-if="data.truckLocation.mapUrl"
          :href="data.truckLocation.mapUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="px-4 py-2 bg-white/10 hover:bg-white/20 rounded-xl text-sm font-medium transition-colors flex-shrink-0"
        >
          ดูแผนที่ →
        </a>
      </div>
    </section>

    <!-- ─── Menu ──────────────────────────────────────────────────────────── -->
    <section class="py-20 bg-white">
      <div class="max-w-5xl mx-auto px-6">
        <h2 class="text-3xl font-bold text-[#1B2B4B] text-center mb-12">เมนูแนะนำ</h2>
        <div v-if="data?.products.length" class="flex gap-5 overflow-x-auto pb-4 snap-x snap-mandatory">
          <div v-for="product in data.products" :key="product.id" class="flex-shrink-0 w-44 snap-start">
            <div class="bg-[#F8FAFC] rounded-2xl overflow-hidden shadow hover:shadow-md transition-shadow">
              <div class="w-full h-40 bg-[#DDEAF6] flex items-center justify-center overflow-hidden">
                <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="w-full h-full object-cover" />
                <Icon v-else name="flat-color-icons:shop" class="text-5xl" />
              </div>
              <div class="p-3">
                <p class="font-semibold text-[#1B2B4B] text-sm leading-snug">{{ product.name }}</p>
                <p class="text-xs text-[#1B2B4B]/50 mt-0.5">{{ product.category.name }}</p>
              </div>
            </div>
          </div>
        </div>
        <div v-else-if="data" class="text-center text-gray-400 py-8">ยังไม่มีเมนู</div>
        <div v-else class="flex gap-5 overflow-x-auto pb-4">
          <div v-for="i in 4" :key="i" class="flex-shrink-0 w-44 h-56 bg-gray-100 rounded-2xl animate-pulse" />
        </div>
      </div>
    </section>

    <!-- ─── Campaigns ─────────────────────────────────────────────────────── -->
    <section v-if="data?.campaigns.length" class="py-20 bg-[#F8FAFC]">
      <div class="max-w-5xl mx-auto px-6">
        <h2 class="text-3xl font-bold text-[#1B2B4B] text-center mb-12">โปรโมชัน & แคมเปญ</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div
            v-for="campaign in data.campaigns"
            :key="campaign.id"
            class="bg-white rounded-2xl overflow-hidden shadow hover:shadow-lg transition-shadow"
          >
            <div class="h-44 bg-gradient-to-br from-[#C8D8E8] to-[#DDEAF6] flex items-center justify-center overflow-hidden">
              <img v-if="campaign.imageUrl" :src="campaign.imageUrl" :alt="campaign.title" class="w-full h-full object-cover" />
              <Icon v-else name="flat-color-icons:advertising" class="text-6xl" />
            </div>
            <div class="p-5">
              <h3 class="font-bold text-[#1B2B4B] text-lg">{{ campaign.title }}</h3>
              <p v-if="campaign.description" class="text-sm text-gray-500 mt-1">{{ campaign.description }}</p>
              <p v-if="campaign.endsAt" class="text-xs text-amber-600 font-medium mt-2">
                ถึง {{ new Date(campaign.endsAt).toLocaleDateString('th-TH', { day: 'numeric', month: 'long', year: 'numeric' }) }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Location Voting ───────────────────────────────────────────────── -->
    <section class="py-20 bg-white">
      <div class="max-w-2xl mx-auto px-6">
        <div class="text-center mb-10">
          <h2 class="text-3xl font-bold text-[#1B2B4B] mb-3">อยากให้รถมาจอดที่ไหน?</h2>
          <p class="text-gray-500">เสนอสถานที่และโหวตได้สัปดาห์ละ 1 ครั้ง<br>รถจะไปตามที่โหวตสูงสุด!</p>
        </div>

        <div v-if="allRequests.length" class="space-y-3 mb-8">
          <div v-for="(req, i) in allRequests" :key="req.id" class="bg-[#F8FAFC] rounded-2xl p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="flex items-center gap-3 min-w-0">
                <span class="text-lg font-bold text-[#1B2B4B]/30 w-5 flex-shrink-0">{{ i + 1 }}</span>
                <div class="min-w-0">
                  <p class="font-semibold text-[#1B2B4B] truncate">{{ req.name }}</p>
                  <p v-if="req.description" class="text-xs text-gray-400 truncate">{{ req.description }}</p>
                </div>
              </div>
              <button
                @click="vote(req.id)"
                :disabled="voting || !!myVotedId"
                class="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold transition-all flex-shrink-0 ml-3"
                :class="myVotedId === req.id
                  ? 'bg-[#1B2B4B] text-white'
                  : myVotedId
                    ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                    : 'bg-[#C8D8E8] text-[#1B2B4B] hover:bg-[#b0c8e0]'"
              >
                <span>{{ myVotedId === req.id ? '✓' : '👍' }}</span>
                <span>{{ req.voteCount }}</span>
              </button>
            </div>
            <div class="ml-8 h-1.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                class="h-full bg-[#C8D8E8] rounded-full transition-all duration-700"
                :style="{ width: (req.voteCount / maxVotes * 100) + '%' }"
              />
            </div>
          </div>
        </div>
        <div v-else class="text-center text-gray-400 py-8 mb-8">
          ยังไม่มีคำขอสัปดาห์นี้ เป็นคนแรกได้เลย!
        </div>

        <!-- Request form -->
        <div class="text-center">
          <button
            v-if="!showRequestForm"
            @click="showRequestForm = true"
            class="px-6 py-3 border-2 border-[#C8D8E8] text-[#1B2B4B] font-semibold rounded-2xl hover:bg-[#F0F4F8] transition-colors"
          >
            + เสนอสถานที่ใหม่
          </button>
          <div v-else class="bg-[#F8FAFC] rounded-2xl p-6 text-left">
            <h3 class="font-bold text-[#1B2B4B] mb-4">เสนอสถานที่</h3>
            <div v-if="formError" class="mb-3 p-3 bg-red-50 text-red-600 rounded-lg text-sm">{{ formError }}</div>
            <div class="space-y-3">
              <input
                v-model="requestForm.name"
                type="text"
                placeholder="ชื่อสถานที่ เช่น หน้าม.เกษตรฯ ประตู 1"
                class="w-full border border-[#C8D8E8] rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] bg-white text-[#1B2B4B]"
              />
              <textarea
                v-model="requestForm.description"
                rows="2"
                placeholder="รายละเอียดเพิ่มเติม เช่น วัน/เวลาที่อยากให้มา (optional)"
                class="w-full border border-[#C8D8E8] rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] bg-white text-[#1B2B4B] resize-none"
              />
              <div class="flex gap-3">
                <button
                  @click="submitRequest"
                  :disabled="!requestForm.name || submitting"
                  class="flex-1 py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
                >
                  {{ submitting ? 'กำลังส่ง...' : 'เสนอสถานที่' }}
                </button>
                <button
                  @click="showRequestForm = false"
                  class="flex-1 py-3 bg-white border border-[#C8D8E8] text-gray-600 font-semibold rounded-xl hover:bg-gray-50 transition-colors"
                >
                  ยกเลิก
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Member Benefits ───────────────────────────────────────────────── -->
    <section class="py-20 bg-[#1B2B4B]">
      <div class="max-w-4xl mx-auto px-6 text-center">
        <h2 class="text-3xl font-bold text-white mb-3">ทำไมต้องสมัครสมาชิก?</h2>
        <p class="text-[#C8D8E8] mb-12">สมัครฟรี ใช้เวลาไม่ถึง 1 นาที</p>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-5 mb-12">
          <div v-for="b in benefits" :key="b.icon" class="bg-white/10 rounded-2xl p-5">
            <Icon :name="b.icon" class="text-4xl mb-3" />
            <p class="font-semibold text-white text-sm">{{ b.title }}</p>
            <p class="text-[#C8D8E8] text-xs mt-1">{{ b.desc }}</p>
          </div>
        </div>
        <NuxtLink
          to="/member/register"
          class="inline-block px-10 py-4 bg-white text-[#1B2B4B] font-bold rounded-2xl hover:bg-[#F0F4F8] transition-all shadow-lg hover:-translate-y-0.5"
        >
          สมัครสมาชิกฟรี →
        </NuxtLink>
      </div>
    </section>

    <!-- ─── Footer ────────────────────────────────────────────────────────── -->
    <footer class="bg-[#0F1C30] text-[#C8D8E8] py-10">
      <div class="max-w-4xl mx-auto px-6 text-center space-y-3">
        <img src="/logo.jpg" alt="Sibling Coffee" class="w-12 h-12 mx-auto rounded-full object-cover opacity-70" />
        <div class="flex justify-center gap-8 text-sm font-medium">
          <a href="#" class="hover:text-white transition-colors">LINE OA</a>
          <a href="#" class="hover:text-white transition-colors">Instagram</a>
          <a href="#" class="hover:text-white transition-colors">Facebook</a>
        </div>
        <p class="text-xs text-[#C8D8E8]/50">© {{ new Date().getFullYear() }} Sibling Coffee · Food Truck · Bangkok</p>
      </div>
    </footer>
  </div>
</template>
