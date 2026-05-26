<script setup lang="ts">
definePageMeta({ layout: false })

const { login, fetchMe, member } = useMemberAuth()
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

onMounted(async () => {
  if (!member.value) await fetchMe()
  if (member.value) router.replace('/member')
})

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await login({ email: email.value, password: password.value })
    await fetchMe()
    router.push('/member')
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Login failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#F0F4F8] flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-[#0F1C30]">Member Login</h1>
        <p class="text-[#2a3f6b] mt-2">Sign in to earn and redeem points</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg p-8 space-y-4">
        <!-- OAuth buttons -->
        <a
          href="/api/member/auth/oauth/line"
          class="flex items-center justify-center gap-3 w-full py-3 px-4 rounded-xl bg-[#06C755] text-white font-medium hover:bg-[#05b34c] transition-colors"
        >
          <Icon name="mdi:line" class="w-6 h-6" />
          Continue with LINE
        </a>

        <a
          href="/api/member/auth/oauth/google"
          class="flex items-center justify-center gap-3 w-full py-3 px-4 rounded-xl bg-white border-2 border-gray-200 text-gray-700 font-medium hover:bg-gray-50 transition-colors"
        >
          <Icon name="flat-color-icons:google" class="w-5 h-5" />
          Continue with Google
        </a>

        <div class="relative my-2">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-200" />
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-3 bg-white text-gray-400">or</span>
          </div>
        </div>

        <!-- Email/password form -->
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div v-if="error" class="p-3 bg-red-50 border border-red-200 text-red-700 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              v-model="email"
              type="email"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] focus:border-transparent"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input
              v-model="password"
              type="password"
              required
              class="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-[#C8D8E8] focus:border-transparent"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#1B2B4B] text-white font-semibold rounded-xl hover:bg-[#2a3f6b] disabled:opacity-50 transition-colors"
          >
            {{ loading ? 'Signing in...' : 'Sign in' }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-500">
          Don't have an account?
          <NuxtLink to="/member/register" class="text-[#1B2B4B] font-medium hover:underline">Register</NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>
