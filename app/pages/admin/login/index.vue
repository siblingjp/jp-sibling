<script setup lang="ts">
definePageMeta({ layout: false })

const { loggedIn } = useUserSession()
if (loggedIn.value) await navigateTo('/admin')

const store = useAuthStore()
const { showError } = useAlert()

const form = reactive({ email: '', password: '' })
const isLoading = computed(() => store.isLoading)

async function handleSubmit() {
  try {
    await store.login({ email: form.email, password: form.password })
    await navigateTo('/admin')
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Login failed'
    showError(msg)
  }
}
</script>

<template>
  <div class="min-h-screen bg-gray-100 flex items-center justify-center">
    <div class="bg-white rounded-2xl shadow-sm w-full max-w-md p-8">
      <div class="mb-8 text-center">
        <h1 class="text-2xl font-bold text-gray-900">Back Office</h1>
        <p class="text-sm text-gray-500 mt-1">Sign in to your account</p>
      </div>

      <form class="space-y-5" @submit.prevent="handleSubmit">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input
            v-model="form.email"
            type="email"
            required
            autocomplete="email"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="admin@example.com"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
          <input
            v-model="form.password"
            type="password"
            required
            autocomplete="current-password"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="w-full bg-blue-600 text-white py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ isLoading ? 'Signing in...' : 'Sign in' }}
        </button>
      </form>
    </div>
  </div>
</template>
