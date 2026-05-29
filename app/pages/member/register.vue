<script setup lang="ts">
definePageMeta({ layout: false })

const { member, fetchMe, login } = useMemberAuth()
const router = useRouter()
const route = useRoute()
const store = useMemberStore()

onMounted(async () => {
  if (!member.value) await fetchMe()
  if (member.value) router.replace('/member')
  if (route.query.email) form.email = String(route.query.email)
})

const form = reactive({
  name: '',
  email: '',
  password: '',
  phone: '',
})
const loading = ref(false)
const error = ref('')

async function handleRegister() {
  error.value = ''
  loading.value = true
  try {
    await store.register({
      name: form.name,
      email: form.email,
      password: form.password,
      phone: form.phone || undefined,
    })
    await fetchMe()
    router.push('/member')
  } catch (e: any) {
    const msg: string = e?.data?.message ?? e?.message ?? ''
    if (msg.includes('PHONE_EXISTS')) {
      try {
        await login({ email: form.email, password: form.password })
        await fetchMe()
        router.push('/member')
      } catch {
        error.value = 'เบอร์โทรนี้มีบัญชีอยู่แล้ว กรุณาเข้าสู่ระบบ'
        router.push(`/member/login?email=${encodeURIComponent(form.email)}`)
      }
      return
    }
    if (msg.includes('already registered') || msg.includes('email')) {
      error.value = 'อีเมลนี้มีบัญชีอยู่แล้ว กรุณาเข้าสู่ระบบ'
    } else {
      error.value = msg || 'สมัครไม่สำเร็จ'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#F0F4F8] flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-[#0F1C30]">สมัครสมาชิก</h1>
        <p class="text-[#2a3f6b] mt-2">สมัครและเริ่มสะสมแต้มได้เลย</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg p-8">
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div v-if="error" class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
            {{ error }}
          </div>

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
            <label class="block text-sm font-medium text-gray-700 mb-1">อีเมล</label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">รหัสผ่าน</label>
            <input
              v-model="form.password"
              type="password"
              required
              minlength="8"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="อย่างน้อย 8 ตัวอักษร"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">เบอร์โทร <span class="text-gray-400">(ไม่บังคับ)</span></label>
            <input
              v-model="form.phone"
              type="tel"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="0812345678"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
          >
            {{ loading ? 'กำลังสมัคร...' : 'สมัครสมาชิก' }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-500 mt-4">
          มีบัญชีอยู่แล้ว?
          <NuxtLink to="/member/login" class="text-[#1B2B4B] font-medium hover:underline">เข้าสู่ระบบ</NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>
