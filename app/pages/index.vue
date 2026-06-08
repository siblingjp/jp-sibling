<script setup lang="ts">
definePageMeta({ layout: 'public' })

const http = useHttpClient()
const { member, fetchMe } = useMemberAuth()

interface HomeData {
  products: { id: string; name: string; imageUrl: string | null; category: { name: string } }[]
  campaigns: { id: string; name: string; description: string | null; imageUrl: string | null; displayMode: string | null; bannerColor: string | null }[]
  truckLocation: { name: string; description: string | null; mapUrl: string | null; openTime: string | null; closeTime: string | null; daysOfWeek: string | null; isOpen: boolean; nextOpenLabel: string | null; nextOpenName: string | null; schedules: { id: string; name: string; openTime: string; closeTime: string; daysOfWeek: string; mapUrl: string | null }[]; activeScheduleId: string | null } | null
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
const showTimeline = ref(false)
const { canInstall, platform, hasNativePrompt, install } = usePwaInstall()
const dismissedBanner = ref(false)

async function copyUrlAndDismiss() {
  await navigator.clipboard.writeText(window.location.href)
  dismissedBanner.value = true
}


const benefits = [
  { icon: 'flat-color-icons:approval', title: 'สะสมแต้ม', desc: 'อัตราแลก 1pt = 1฿' },
  { icon: 'mdi:gift', title: 'แต้มแลกลด', desc: 'ใช้แต้มแลกส่วนลด' },
  { icon: null, image: '/logo-icon-white.png', title: 'สั่งล่วงหน้า', desc: 'ไม่ต้องรอนาน' },
  { icon: 'flat-color-icons:vip', title: 'สิทธิ์ VIP', desc: 'แต้มโบนัสพิเศษ' },
]

onMounted(async () => {
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

// duplicate products for seamless marquee loop
const marqueeProducts = computed(() => {
  const p = data.value?.products ?? []
  return p.length > 0 ? [...p, ...p] : []
})
</script>

<template>
  <div>
    <!-- ─── Truck Location Banner ────────────────────────────────────────── -->
    <section v-if="data?.truckLocation" class="text-white py-4"
      :class="data.truckLocation.isOpen ? 'bg-green-700' : 'bg-[#1B2B4B]'">
      <div class="max-w-4xl mx-auto px-6 flex items-start justify-between gap-4">
        <div class="flex items-start gap-3 min-w-0">
          <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 bg-white/15">
            <Icon :name="data.truckLocation.isOpen ? 'mdi:store-check' : 'mdi:store-clock'" class="text-lg" />
          </div>
          <div class="min-w-0">
            <template v-if="data.truckLocation.isOpen">
              <p class="text-white/60 text-xs font-medium mb-0.5">วันนี้อยู่ที่</p>
              <div class="flex items-center gap-2 flex-wrap">
                <p class="font-bold">{{ data.truckLocation.name }}</p>
                <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-white/20 text-white">เปิดอยู่</span>
              </div>
              <p class="text-white/70 text-sm">{{ data.truckLocation.openTime }}–{{ data.truckLocation.closeTime }}</p>
            </template>
            <template v-else-if="data.truckLocation.nextOpenLabel">
              <div class="flex items-center gap-2 mb-0.5">
                <p class="text-white/60 text-xs font-medium">ร้านจะเปิดอีกครั้ง</p>
                <span class="text-xs px-2 py-0.5 rounded-full font-semibold bg-red-500/80 text-white">ปิดอยู่</span>
              </div>
              <p class="font-bold leading-snug">{{ data.truckLocation.nextOpenLabel }}</p>
              <p class="text-white/70 text-sm truncate">ที่ {{ data.truckLocation.nextOpenName }}</p>
            </template>
            <template v-else>
              <p class="text-white/60 text-xs font-medium mb-0.5">สถานะร้าน</p>
              <p class="font-bold">ปิดอยู่</p>
            </template>
          </div>
        </div>
        <div class="flex flex-col items-end gap-2 flex-shrink-0">
          <a
            v-if="data.truckLocation.mapUrl"
            :href="data.truckLocation.mapUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center gap-1.5 px-4 py-2 bg-white/15 hover:bg-white/25 rounded-xl text-sm font-medium transition-colors"
          >
            <Icon name="mdi:map-marker" class="text-base text-red-300" />
            แผนที่
          </a>
          <button
            v-if="data.truckLocation.schedules?.length"
            class="flex items-center gap-1.5 px-3 py-1.5 bg-white/10 hover:bg-white/20 rounded-xl text-xs font-medium transition-colors text-white/80"
            @click="showTimeline = true"
          >
            <Icon name="mdi:calendar-clock" class="text-sm" />
            ไทม์ไลน์
          </button>
        </div>
      </div>
    </section>

    <SharedLocationTimeline
      v-if="showTimeline && data?.truckLocation"
      :schedules="data.truckLocation.schedules"
      :active-schedule-id="data.truckLocation.activeScheduleId"
      @close="showTimeline = false"
    />

    <!-- ─── Hero ─────────────────────────────────────────────────────────── -->
    <!-- Mobile: 50vh hero + 50vh campaign cards | Desktop: full hero -->
    <div class="md:block">

      <!-- Hero section: 50vh on mobile, 90vh on desktop -->
      <section class="relative overflow-hidden bg-gradient-to-br from-[#F8FAFC] via-[#DDEAF6] to-[#C8D8E8] h-[50vh] md:min-h-[90vh] flex items-center">
        <div class="absolute inset-0 overflow-hidden pointer-events-none">
          <svg class="absolute -bottom-1 left-0 w-full hidden md:block" viewBox="0 0 1440 120" fill="none">
            <path d="M0,60 C360,120 1080,0 1440,60 L1440,120 L0,120 Z" fill="white"/>
          </svg>
          <svg class="absolute top-10 right-[-2rem] opacity-10 w-96 h-96" viewBox="0 0 200 200">
            <circle cx="100" cy="80" r="60" fill="#1B2B4B"/>
            <ellipse cx="100" cy="145" rx="70" ry="15" fill="#1B2B4B"/>
            <path d="M90,20 Q100,0 110,20 Q120,0 130,20" stroke="#1B2B4B" stroke-width="4" fill="none"/>
          </svg>
        </div>
        <div class="relative max-w-4xl mx-auto px-6 py-10 md:py-24 text-center w-full">
          <img src="/logo.jpg" alt="JP Sibling" class="w-20 h-20 md:w-32 md:h-32 mx-auto rounded-full shadow-xl mb-4 md:mb-8 object-cover" />
          <h1 class="text-3xl md:text-6xl font-bold text-[#1B2B4B] leading-tight mb-2 md:mb-4">JP Sibling</h1>
          <p class="text-base md:text-xl text-[#1B2B4B]/70 mb-6 md:mb-10">พบกันทุกเช้า ที่ไหนก็ได้</p>
          <div class="flex flex-col sm:flex-row items-center gap-3 md:gap-4 justify-center">
            <NuxtLink
              to="/member/orders/new"
              class="inline-flex items-center justify-center gap-2 px-6 md:px-8 py-3 md:py-4 bg-[#1B2B4B] text-white font-bold rounded-2xl hover:bg-[#2a3f6b] transition-all shadow-lg hover:-translate-y-0.5 text-sm md:text-base"
            >
              สั่งออนไลน์
              <span v-if="member" class="w-3.5 h-3.5 rounded-full bg-white/40 animate-ping inline-block" />
            </NuxtLink>
            <NuxtLink
              to="/member/register"
              class="inline-flex items-center justify-center gap-2 px-6 md:px-8 py-3 md:py-4 bg-white text-[#1B2B4B] font-bold rounded-2xl border-2 border-[#C8D8E8] hover:bg-[#F0F4F8] transition-all shadow hover:-translate-y-0.5 text-sm md:text-base"
            >
              สมัครสมาชิกฟรี
              <span v-if="!member" class="w-3.5 h-3.5 rounded-full bg-gray-400/60 animate-ping inline-block" />
            </NuxtLink>
          </div>
        </div>
      </section>
    </div>

    <!-- ─── PWA Install Banner ───────────────────────────────────────────── -->
    <Transition name="slide-down">
      <div v-if="canInstall && !dismissedBanner" class="bg-[#1B2B4B]/95 text-white px-4 py-3">
        <div class="max-w-4xl mx-auto flex items-center gap-3">
          <img src="/logo.jpg" alt="" class="w-9 h-9 rounded-full object-cover flex-shrink-0" />

          <!-- Android Chrome / Desktop: native prompt -->
          <template v-if="hasNativePrompt">
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold leading-tight">ติดตั้ง JP Sibling</p>
              <p class="text-xs text-white/60 leading-tight">เพิ่มไปหน้าจอหลักเพื่อใช้งานง่ายขึ้น</p>
            </div>
            <button
              class="px-3 py-1.5 bg-white text-[#1B2B4B] text-xs font-bold rounded-lg flex-shrink-0"
              @click="install"
            >ติดตั้ง</button>
          </template>

          <!-- iOS Safari: manual -->
          <template v-else-if="platform === 'ios-safari'">
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold leading-tight">ติดตั้ง JP Sibling บน iPhone</p>
              <p class="text-xs text-white/60 leading-tight">
                กดปุ่ม <Icon name="mdi:export-variant" class="inline text-sm align-middle" /> แชร์ (Share) แล้วเลือก "เพิ่มไปยังหน้าจอโฮม (Add to Home Screen)"
              </p>
            </div>
          </template>

          <!-- iOS Chrome: ต้องเปิดด้วย Safari -->
          <template v-else-if="platform === 'ios-other'">
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold leading-tight">ติดตั้งผ่าน Safari</p>
              <p class="text-xs text-white/60 leading-tight">Chrome บน iOS ไม่รองรับ — คัดลอกลิงก์แล้วเปิดใน Safari จากนั้นกด "เพิ่มไปยังหน้าจอโฮม"</p>
            </div>
            <button
              class="px-3 py-1.5 bg-white text-[#1B2B4B] text-xs font-bold rounded-lg flex-shrink-0"
              @click="copyUrlAndDismiss"
            >คัดลอกลิงก์</button>
          </template>

          <button class="text-white/50 hover:text-white p-1 flex-shrink-0" @click="dismissedBanner = true">
            <Icon name="mdi:close" class="text-lg" />
          </button>
        </div>
      </div>
    </Transition>

    <!-- ─── Campaigns (desktop full section) ────────────────────────────── -->
    <section v-if="data?.campaigns.length" class="py-6 bg-[#F8FAFC]">
      <div class="max-w-5xl mx-auto px-6">
        <h2 class="text-xl font-bold text-[#1B2B4B] text-center mb-3">โปรโมชัน & แคมเปญ</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <div
            v-for="campaign in data.campaigns"
            :key="campaign.id"
            class="relative rounded-2xl overflow-hidden shadow hover:shadow-lg transition-shadow aspect-video"
          >
            <!-- NEW badge -->
            <div class="absolute top-3 right-3 z-10 flex items-center gap-1 bg-red-500 text-white text-[10px] font-black px-2 py-0.5 rounded-full shadow-lg">
              <span class="w-1.5 h-1.5 rounded-full bg-white animate-ping inline-block" />
              NEW
            </div>

            <!-- image mode -->
            <template v-if="campaign.displayMode !== 'banner'">
              <img
                v-if="campaign.imageUrl"
                :src="campaign.imageUrl"
                :alt="campaign.name"
                class="absolute inset-0 w-full h-full object-cover"
              />
              <div v-else class="absolute inset-0 bg-gradient-to-br from-[#1B2B4B] to-[#2a3f6b]" />
              <!-- <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
              <div class="relative h-full flex flex-col justify-end p-6">
                <h3 class="font-bold text-white text-xl leading-snug">{{ campaign.name }}</h3>
                <p v-if="campaign.description" class="text-white/75 text-sm mt-1">{{ campaign.description }}</p>
              </div> -->
            </template>

            <!-- banner mode -->
            <template v-else>
              <div class="absolute inset-0" :style="`background: ${campaign.bannerColor || '#1B2B4B'}`" />
              <div class="relative h-full flex items-center gap-6 p-6">
                <img v-if="campaign.imageUrl" :src="campaign.imageUrl" class="w-24 h-24 rounded-2xl object-cover border-2 border-white/20 shrink-0" alt="" />
                <div class="flex-1 min-w-0">
                  <p class="text-xs font-semibold text-white/60 uppercase tracking-widest mb-2">โปรโมชัน</p>
                  <h3 class="font-bold text-white text-xl leading-snug">{{ campaign.name }}</h3>
                  <p v-if="campaign.description" class="text-white/75 text-sm mt-2">{{ campaign.description }}</p>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Menu Marquee ─────────────────────────────────────────────────── -->
    <section class="py-4 bg-white overflow-hidden">
      <div class="max-w-5xl mx-auto px-6 mb-4">
        <h2 class="text-xl font-bold text-[#1B2B4B] text-center">เมนูแนะนำ</h2>
      </div>

      <!-- Loading skeleton -->
      <div v-if="!data" class="flex gap-5 px-6">
        <div v-for="i in 5" :key="i" class="flex-shrink-0 w-40 h-52 bg-gray-100 rounded-2xl animate-pulse" />
      </div>

      <!-- Empty -->
      <div v-else-if="!data.products.length" class="text-center text-gray-400 py-8">ยังไม่มีเมนู</div>

      <!-- Marquee -->
      <div v-else class="relative">
        <!-- Fade edges -->
        <div class="absolute left-0 top-0 bottom-0 w-16 bg-gradient-to-r from-white to-transparent z-10 pointer-events-none" />
        <div class="absolute right-0 top-0 bottom-0 w-16 bg-gradient-to-l from-white to-transparent z-10 pointer-events-none" />

        <div class="flex gap-5 marquee-track">
          <div
            v-for="(product, idx) in marqueeProducts"
            :key="`${product.id}-${idx}`"
            class="flex-shrink-0 w-40"
          >
            <div class="bg-[#F8FAFC] rounded-2xl overflow-hidden shadow hover:shadow-md transition-shadow">
              <div class="w-full h-36 bg-[#DDEAF6] flex items-center justify-center overflow-hidden">
                <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="w-full h-full object-cover" />
                <Icon v-else name="flat-color-icons:shop" class="text-5xl" />
              </div>
              <div class="p-3">
                <p class="font-semibold text-[#1B2B4B] text-sm leading-snug line-clamp-2">{{ product.name }}</p>
                <p class="text-xs text-[#1B2B4B]/50 mt-0.5">{{ product.category.name }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Location Voting ──────────────────────────────────────────────── -->
    <section class="py-20 bg-white">
      <div class="max-w-2xl mx-auto px-6">
        <div class="text-center mb-10">
          <h2 class="text-3xl font-bold text-[#1B2B4B] mb-3">อยากให้รถมาจอดที่ไหน?</h2>
          <p class="text-gray-500">เสนอสถานที่และโหวตได้เดือนละ 1 ครั้ง<br>รถจะไปตามที่โหวตสูงสุด!</p>
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
                :disabled="voting || !!myVotedId"
                class="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-semibold transition-all flex-shrink-0 ml-3"
                :class="myVotedId === req.id
                  ? 'bg-[#1B2B4B] text-white'
                  : myVotedId
                    ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                    : 'bg-[#C8D8E8] text-[#1B2B4B] hover:bg-[#b0c8e0]'"
                @click="vote(req.id)"
              >
                <Icon :name="myVotedId === req.id ? 'mdi:check' : 'mdi:thumb-up'" class="text-base" />
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

        <div class="text-center">
          <button
            v-if="!showRequestForm"
            class="px-6 py-3 border-2 border-[#C8D8E8] text-[#1B2B4B] font-semibold rounded-2xl hover:bg-[#F0F4F8] transition-colors"
            @click="showRequestForm = true"
          >+ เสนอสถานที่ใหม่</button>
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
                  :disabled="!requestForm.name || submitting"
                  class="flex-1 py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
                  @click="submitRequest"
                >{{ submitting ? 'กำลังส่ง...' : 'เสนอสถานที่' }}</button>
                <button
                  class="flex-1 py-3 bg-white border border-[#C8D8E8] text-gray-600 font-semibold rounded-xl hover:bg-gray-50 transition-colors"
                  @click="showRequestForm = false"
                >ยกเลิก</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ─── Member Benefits ──────────────────────────────────────────────── -->
    <section class="py-20 bg-[#1B2B4B]">
      <div class="max-w-4xl mx-auto px-6 text-center">
        <h2 class="text-3xl font-bold text-white mb-3">ทำไมต้องสมัครสมาชิก?</h2>
        <p class="text-[#C8D8E8] mb-12">สมัครฟรี ใช้เวลาไม่ถึง 1 นาที</p>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-5 mb-12">
          <div v-for="b in benefits" :key="b.title" class="bg-white/10 rounded-2xl p-5 flex flex-col items-center text-center">
            <img v-if="b.image" :src="b.image" :alt="b.title" class="w-10 h-10 object-contain mb-3" />
            <Icon v-else :name="b.icon!" class="text-4xl mb-3" />
            <p class="font-semibold text-white text-sm">{{ b.title }}</p>
            <p class="text-[#C8D8E8] text-xs mt-1">{{ b.desc }}</p>
          </div>
        </div>
        <NuxtLink
          to="/member/register"
          class="inline-block px-10 py-4 bg-white text-[#1B2B4B] font-bold rounded-2xl hover:bg-[#F0F4F8] transition-all shadow-lg hover:-translate-y-0.5"
        >สมัครสมาชิกฟรี →</NuxtLink>
      </div>
    </section>

    <!-- ─── Footer ───────────────────────────────────────────────────────── -->
    <footer class="bg-[#0F1C30] text-[#C8D8E8] py-10">
      <div class="max-w-4xl mx-auto px-6 text-center space-y-3">
        <img src="/logo.jpg" alt="JP Sibling" class="w-12 h-12 mx-auto rounded-full object-cover opacity-70" />
        <div class="flex justify-center gap-8 text-sm font-medium">
          <a href="https://lin.ee/Yo7V4CO" target="_blank" rel="noopener noreferrer" class="flex items-center gap-1.5 hover:text-white transition-colors">
            <Icon name="mdi:chat" class="text-base" />LINE OA
          </a>
          <a href="https://www.instagram.com/jp.sibling/" target="_blank" rel="noopener noreferrer" class="flex items-center gap-1.5 hover:text-white transition-colors">
            <Icon name="mdi:instagram" class="text-base" />Instagram
          </a>
          <a href="https://www.facebook.com/jp.sibling/" target="_blank" rel="noopener noreferrer" class="flex items-center gap-1.5 hover:text-white transition-colors">
            <Icon name="mdi:facebook" class="text-base" />Facebook
          </a>
        </div>
        <p class="text-xs text-[#C8D8E8]/50">© {{ new Date().getFullYear() }} <NuxtLink to="/admin" class="hover:text-white transition-colors">JP Sibling</NuxtLink> · Coffee Truck · Chiang Mai</p>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.slide-down-enter-active, .slide-down-leave-active { transition: all 0.3s ease; }
.slide-down-enter-from, .slide-down-leave-to { opacity: 0; transform: translateY(-12px); }

/* Auto-scroll marquee */
.marquee-track {
  animation: marquee 30s linear infinite;
  width: max-content;
  padding: 0 1.25rem;
}
.marquee-track:hover {
  animation-play-state: paused;
}

@keyframes marquee {
  0%   { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
</style>
