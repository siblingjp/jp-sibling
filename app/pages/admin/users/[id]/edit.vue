<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string

const store = useUsersStore()
const { showSuccess, showError } = useAlert()

const form = reactive({
  name: '',
  email: '',
  password: '',
  role: 'STAFF' as 'ADMIN' | 'CASHIER' | 'STAFF',
  isActive: true,
})

const isLoading = computed(() => store.formState.isLoading)

const { data } = await useAsyncData(`user-${id}`, () =>
  useHttpClient().get<{ data: { name: string; email: string; role: 'ADMIN' | 'CASHIER' | 'STAFF'; isActive: boolean } }>(
    `/api/admin/users/${id}`,
  ),
)

watchEffect(() => {
  const u = data.value?.data
  if (!u) return
  form.name = u.name
  form.email = u.email
  form.role = u.role
  form.isActive = u.isActive
})

async function handleSubmit() {
  try {
    const payload: Partial<typeof form> = {
      name: form.name,
      email: form.email,
      role: form.role,
      isActive: form.isActive,
    }
    if (form.password) payload.password = form.password

    await store.update(id, payload)
    showSuccess('User updated')
    await navigateTo('/admin/users')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to update')
  }
}
</script>

<template>
  <div class="max-w-xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/users" class="text-gray-400 hover:text-gray-600">← กลับ</NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">แก้ไขผู้ใช้งาน</h1>
    </div>

    <form class="bg-white rounded-xl shadow-sm p-6 space-y-5" @submit.prevent="handleSubmit">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">ชื่อ <span class="text-red-500">*</span></label>
        <input v-model="form.name" type="text" required class="input" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">อีเมล <span class="text-red-500">*</span></label>
        <input v-model="form.email" type="email" required class="input" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">รหัสผ่านใหม่</label>
        <input v-model="form.password" type="password" minlength="8" class="input" placeholder="เว้นว่างถ้าไม่ต้องการเปลี่ยน" />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">บทบาท <span class="text-red-500">*</span></label>
        <select v-model="form.role" required class="input">
          <option value="ADMIN">Admin</option>
          <option value="CASHIER">Cashier</option>
          <option value="STAFF">Staff</option>
        </select>
      </div>

      <div class="flex items-center gap-3">
        <input id="isActive" v-model="form.isActive" type="checkbox" class="rounded" />
        <label for="isActive" class="text-sm text-gray-700">เปิดใช้งาน</label>
      </div>

      <div class="flex gap-3 pt-2">
        <button type="submit" :disabled="isLoading" class="btn-primary">
          {{ isLoading ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง' }}
        </button>
        <NuxtLink to="/admin/users" class="btn-ghost">ยกเลิก</NuxtLink>
      </div>
    </form>
  </div>
</template>

<style scoped>
.input { @apply w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500; }
.btn-primary { @apply bg-blue-600 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors disabled:opacity-50; }
.btn-ghost { @apply px-5 py-2 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors; }
</style>
