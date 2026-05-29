<script setup lang="ts">
definePageMeta({ layout: 'member', middleware: 'member' })

const { member } = useMemberAuth()
const store = useMemberStore()
const { showSuccess, showError } = useAlert()

const qrUrl = computed(() =>
  `https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=${encodeURIComponent(member.value?.id ?? '')}&margin=8`
)
const showQr = ref(false)

const editing = ref(false)
const form = reactive({ name: '', phone: '' })
const loading = ref(false)

function startEdit() {
  form.name = member.value?.name ?? ''
  form.phone = member.value?.phone ?? ''
  editing.value = true
}

async function handleSave() {
  loading.value = true
  try {
    await store.updateProfile({ name: form.name, phone: form.phone || undefined })
    editing.value = false
    showSuccess('Profile updated')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Update failed')
  } finally {
    loading.value = false
  }
}

const tierLabel = computed(() => {
  const t = member.value?.tier
  if (t === 'VIP') return 'VIP'
  if (t === 'GOLD') return 'Gold'
  return 'Silver'
})

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('th-TH', { year: 'numeric', month: 'long', day: 'numeric' })
}
</script>

<template>
  <div class="max-w-lg mx-auto space-y-6">
    <h1 class="text-2xl font-bold text-gray-900">โปรไฟล์</h1>

    <!-- Avatar & tier -->
    <div class="bg-white rounded-2xl shadow p-6 flex items-center gap-5">
      <div class="w-20 h-20 rounded-full bg-[#C8D8E8] flex items-center justify-center text-3xl font-bold text-[#2a3f6b] overflow-hidden flex-shrink-0">
        <img v-if="member?.profileImage" :src="member.profileImage" class="w-full h-full object-cover" />
        <span v-else>{{ member?.name?.[0]?.toUpperCase() }}</span>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-xl font-bold text-gray-900 truncate">{{ member?.name }}</p>
        <span
          class="inline-block text-sm font-medium px-3 py-0.5 rounded-full mt-1"
          :class="{
            'bg-purple-100 text-purple-700': member?.tier === 'VIP',
            'bg-yellow-100 text-yellow-700': member?.tier === 'GOLD',
            'bg-gray-100 text-gray-600': member?.tier === 'SILVER',
          }"
        >
          {{ tierLabel }}
        </span>
        <p class="text-sm text-gray-500 mt-1">สมาชิกตั้งแต่ {{ member?.createdAt ? formatDate(member.createdAt) : '-' }}</p>
      </div>
      <button
        class="flex flex-col items-center gap-1 px-3 py-2.5 rounded-xl bg-[#F0F4F8] hover:bg-[#C8D8E8] transition-colors flex-shrink-0"
        @click="showQr = true"
      >
        <Icon name="mdi:qrcode" class="text-2xl text-[#1B2B4B]" />
        <span class="text-xs font-medium text-[#1B2B4B]">QR</span>
      </button>
    </div>

    <!-- Info / edit -->
    <div class="bg-white rounded-2xl shadow p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="font-semibold text-gray-800">ข้อมูลบัญชี</h2>
        <button v-if="!editing" @click="startEdit" class="text-[#1B2B4B] text-sm font-medium hover:underline">แก้ไข</button>
      </div>

      <div v-if="!editing" class="space-y-4">
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">ชื่อ</p>
          <p class="text-gray-800 font-medium mt-0.5">{{ member?.name }}</p>
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">อีเมล</p>
          <p class="text-gray-800 font-medium mt-0.5">{{ member?.email ?? '-' }}</p>
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">เบอร์โทร</p>
          <p class="text-gray-800 font-medium mt-0.5">{{ member?.phone ?? '-' }}</p>
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">บัญชีที่เชื่อมต่อ</p>
          <div class="flex gap-2 mt-1.5">
            <span v-if="member?.lineUserId" class="text-xs px-2 py-1 bg-[#06C755]/10 text-[#06C755] rounded-full font-medium">LINE</span>
            <span v-if="member?.googleId" class="text-xs px-2 py-1 bg-blue-50 text-blue-600 rounded-full font-medium">Google</span>
            <span v-if="member?.email" class="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full font-medium">Email</span>
          </div>
        </div>
      </div>

      <form v-else @submit.prevent="handleSave" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อ</label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">เบอร์โทร</label>
          <input
            v-model="form.phone"
            type="tel"
            class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
            placeholder="0812345678"
          />
        </div>
        <div class="flex gap-3">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 py-2.5 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
          >
            {{ loading ? 'กำลังบันทึก...' : 'บันทึก' }}
          </button>
          <button
            type="button"
            @click="editing = false"
            class="flex-1 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition-colors"
          >
            ยกเลิก
          </button>
        </div>
      </form>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 gap-4">
      <div class="bg-white rounded-2xl shadow p-5 text-center">
        <p class="text-3xl font-bold text-[#1B2B4B]">{{ (member?.points ?? 0).toLocaleString() }}</p>
        <p class="text-sm text-gray-500 mt-1">แต้ม</p>
      </div>
      <div class="bg-white rounded-2xl shadow p-5 text-center">
        <p class="text-3xl font-bold text-green-600">฿{{ Number(member?.totalSpent ?? 0).toLocaleString() }}</p>
        <p class="text-sm text-gray-500 mt-1">ยอดใช้จ่ายรวม</p>
      </div>
    </div>
  </div>

  <!-- QR Modal -->
  <Teleport to="body">
    <div v-if="showQr" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showQr = false" />
      <div class="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-xs space-y-4">
        <div class="text-center">
          <p class="font-bold text-gray-900 text-lg">{{ member?.name }}</p>
          <span class="inline-block text-xs font-medium px-2.5 py-0.5 rounded-full mt-1"
            :class="{
              'bg-purple-100 text-purple-700': member?.tier === 'VIP',
              'bg-yellow-100 text-yellow-700': member?.tier === 'GOLD',
              'bg-gray-100 text-gray-600': member?.tier === 'SILVER',
            }">
            {{ tierLabel }}
          </span>
        </div>
        <div class="flex justify-center">
          <div class="p-3 bg-white rounded-xl border-2 border-[#C8D8E8] shadow-sm">
            <img :src="qrUrl" alt="Member QR" class="w-52 h-52" />
          </div>
        </div>
        <div class="bg-[#F0F4F8] rounded-xl p-3 flex items-center gap-3">
          <Icon name="flat-color-icons:approval" class="text-2xl flex-shrink-0" />
          <div>
            <p class="font-semibold text-[#0F1C30] text-sm">{{ (member?.points ?? 0).toLocaleString() }} pts</p>
            <p class="text-xs text-[#2a3f6b]">แสดงที่เคาน์เตอร์เพื่อสะสมแต้ม</p>
          </div>
        </div>
        <button
          class="w-full py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-medium hover:bg-gray-200"
          @click="showQr = false"
        >ปิด</button>
      </div>
    </div>
  </Teleport>
</template>
