<script setup lang="ts">
definePageMeta({ layout: false })

const { member, fetchMe } = useMemberAuth()
const router = useRouter()
const store = useMemberStore()

onMounted(async () => {
  if (!member.value) await fetchMe()
  if (member.value) router.replace('/member')
})
const { showError } = useAlert()

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
    await navigateTo('/member/login')
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Registration failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#F0F4F8] flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-[#0F1C30]">Create Account</h1>
        <p class="text-[#2a3f6b] mt-2">Join us and start earning points</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg p-8">
        <form @submit.prevent="handleRegister" class="space-y-4">
          <div v-if="error" class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
            <input
              v-model="form.name"
              type="text"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="Your name"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input
              v-model="form.password"
              type="password"
              required
              minlength="8"
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8]"
              placeholder="Min 8 characters"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Phone <span class="text-gray-400">(optional)</span></label>
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
            {{ loading ? 'Creating account...' : 'Create Account' }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-500 mt-4">
          Already have an account?
          <NuxtLink to="/member/login" class="text-[#1B2B4B] font-medium hover:underline">Sign in</NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>
