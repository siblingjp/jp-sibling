<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const route = useRoute()
const id = route.params.id as string

const store = useOptionGroupsStore()
const { showSuccess, showError } = useAlert()
const router = useRouter()

const { data, error } = await useAsyncData(`option-group-${id}`, () =>
  useHttpClient().get<{ data: any }>(API_ENDPOINTS.ADMIN.OPTION_GROUPS.SHOW(id)),
)

if (error.value) {
  showError('Option group not found')
  await navigateTo('/admin/option-groups')
}

const group = computed(() => data.value?.data)

const form = reactive({
  name: '',
  required: false,
  multiSelect: false,
  isActive: true,
  sortOrder: 0,
  options: [] as { id?: string; name: string; extraPrice: number; isActive: boolean; sortOrder: number }[],
})

watch(group, (g) => {
  if (!g) return
  form.name = g.name
  form.required = g.required
  form.multiSelect = g.multiSelect
  form.isActive = g.isActive
  form.sortOrder = g.sortOrder
  form.options = g.options.map((o: any) => ({
    id: o.id,
    name: o.name,
    extraPrice: Number(o.extraPrice),
    isActive: o.isActive,
    sortOrder: o.sortOrder,
  }))
}, { immediate: true })

function addOption() {
  form.options.push({ name: '', extraPrice: 0, isActive: true, sortOrder: form.options.length })
}

function removeOption(index: number) {
  if (form.options.length === 1) return
  form.options.splice(index, 1)
}

const isLoading = computed(() => store.formState.isLoading)

async function handleSubmit() {
  try {
    await store.update(id, {
      ...form,
      options: form.options.map((o, i) => ({ ...o, sortOrder: i })),
    })
    showSuccess('Option group updated')
    router.push('/admin/option-groups')
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to update')
  }
}
</script>

<template>
  <div class="max-w-2xl">
    <div class="flex items-center gap-3 mb-6">
      <NuxtLink to="/admin/option-groups" class="text-gray-400 hover:text-gray-600">← Back</NuxtLink>
      <h1 class="text-2xl font-bold text-gray-900">Edit Option Group</h1>
    </div>

    <form v-if="group" class="space-y-6" @submit.prevent="handleSubmit">
      <div class="bg-white rounded-xl shadow-sm p-6 space-y-4">
        <h2 class="font-semibold text-gray-900">Group Settings</h2>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Name <span class="text-red-500">*</span></label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div class="flex gap-6">
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.required" type="checkbox" class="rounded" />
            <span class="text-sm text-gray-700">Required (ต้องเลือก)</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.multiSelect" type="checkbox" class="rounded" />
            <span class="text-sm text-gray-700">Multi-select (เลือกได้หลายอย่าง)</span>
          </label>
          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.isActive" type="checkbox" class="rounded" />
            <span class="text-sm text-gray-700">Active</span>
          </label>
        </div>

        <div class="w-32">
          <label class="block text-sm font-medium text-gray-700 mb-1">Sort Order</label>
          <input
            v-model.number="form.sortOrder"
            type="number"
            min="0"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm p-6 space-y-4">
        <div class="flex items-center justify-between">
          <h2 class="font-semibold text-gray-900">Options</h2>
          <button
            type="button"
            class="text-sm text-blue-600 hover:text-blue-800 font-medium"
            @click="addOption"
          >
            + Add Option
          </button>
        </div>

        <div class="space-y-3">
          <div
            v-for="(opt, i) in form.options"
            :key="opt.id ?? i"
            class="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
          >
            <span class="text-xs text-gray-400 w-5 text-center">{{ i + 1 }}</span>
            <input
              v-model="opt.name"
              type="text"
              required
              placeholder="Option name"
              class="flex-1 px-3 py-1.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <div class="flex items-center gap-1">
              <span class="text-xs text-gray-500">+฿</span>
              <input
                v-model.number="opt.extraPrice"
                type="number"
                min="0"
                step="0.01"
                class="w-20 px-2 py-1.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <label class="flex items-center gap-1 cursor-pointer">
              <input v-model="opt.isActive" type="checkbox" class="rounded" />
              <span class="text-xs text-gray-600">Active</span>
            </label>
            <button
              type="button"
              class="text-red-400 hover:text-red-600 text-lg leading-none"
              :disabled="form.options.length === 1"
              :class="form.options.length === 1 ? 'opacity-30 cursor-not-allowed' : ''"
              @click="removeOption(i)"
            >
              ×
            </button>
          </div>
        </div>
      </div>

      <div class="flex justify-end gap-3">
        <NuxtLink to="/admin/option-groups" class="px-4 py-2 text-sm text-gray-600 hover:text-gray-900">
          Cancel
        </NuxtLink>
        <button
          type="submit"
          :disabled="isLoading"
          class="px-6 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {{ isLoading ? 'Saving...' : 'Save Changes' }}
        </button>
      </div>
    </form>
  </div>
</template>
