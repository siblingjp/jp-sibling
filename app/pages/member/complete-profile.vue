<script setup lang="ts">
definePageMeta({ layout: false, middleware: 'member' })

const { member, fetchMe } = useMemberAuth()
const store = useMemberStore()
const { showError } = useAlert()

onMounted(async () => {
  if (!member.value) await fetchMe()
  if (member.value?.phone) navigateTo('/member')
})

const form = reactive({
  name: '',
  phone: '',
})
const loading = ref(false)

watchEffect(() => {
  if (member.value?.name) form.name = member.value.name
})

async function handleSubmit() {
  loading.value = true
  try {
    await store.updateProfile({ name: form.name, phone: form.phone })
    await navigateTo('/member')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'บันทึกข้อมูลไม่สำเร็จ')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#F0F4F8] flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <div class="w-16 h-16 rounded-full bg-[#1B2B4B] flex items-center justify-center mx-auto mb-4">
          <Icon name="mdi:account-check" class="text-white text-3xl" />
        </div>
        <h1 class="text-2xl font-bold text-[#0F1C30]">กรอกข้อมูลเพิ่มเติม</h1>
        <p class="text-[#2a3f6b] mt-2 text-sm">เพื่อให้ระบบสมาชิกทำงานได้สมบูรณ์</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg p-8">
        <form @submit.prevent="handleSubmit" class="space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อ</label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="ชื่อของคุณ"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">เบอร์โทร</label>
            <input
              v-model="form.phone"
              type="tel"
              required
              pattern="[0-9]{9,10}"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="0812345678"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
          >
            {{ loading ? 'กำลังบันทึก...' : 'ยืนยันและเข้าสู่ระบบ' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>
