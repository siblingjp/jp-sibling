<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'admin' })

const { showError, showConfirm, showSuccess } = useAlert()
const http = useHttpClient()

const discounts = ref<any[]>([])
const isLoading = ref(false)

async function load() {
  isLoading.value = true
  try {
    const res = await http.get<{ data: any[] }>(API_ENDPOINTS.ADMIN.DISCOUNTS.LIST)
    discounts.value = res.data ?? []
  } catch (e: any) {
    showError(e?.message ?? 'Failed to load')
  } finally {
    isLoading.value = false
  }
}

// ─── Form ────────────────────────────────────────────────────────────────────
const showForm = ref(false)
const editingId = ref<string | null>(null)
const form = reactive({ name: '', kind: 'PERCENT' as 'PERCENT' | 'AMOUNT', value: 0, isActive: true })
const isSaving = ref(false)

function openNew() {
  editingId.value = null
  form.name = ''
  form.kind = 'PERCENT'
  form.value = 0
  form.isActive = true
  showForm.value = true
}

function openEdit(d: any) {
  editingId.value = d.id
  form.name = d.name
  form.kind = d.kind
  form.value = Number(d.value)
  form.isActive = d.isActive
  showForm.value = true
}

async function handleSave() {
  isSaving.value = true
  try {
    if (editingId.value) {
      await http.put(API_ENDPOINTS.ADMIN.DISCOUNTS.UPDATE(editingId.value), { ...form })
      showSuccess('Discount updated')
    } else {
      await http.post(API_ENDPOINTS.ADMIN.DISCOUNTS.CREATE, { ...form })
      showSuccess('Discount created')
    }
    showForm.value = false
    load()
  } catch (e: any) {
    showError(e?.message ?? 'Failed to save')
  } finally {
    isSaving.value = false
  }
}

async function handleDelete(d: any) {
  const ok = await showConfirm({
    title: 'Delete Discount',
    message: `Delete "${d.name}"?`,
    confirmText: 'Delete',
  })
  if (!ok) return
  try {
    await http.delete(API_ENDPOINTS.ADMIN.DISCOUNTS.DELETE(d.id))
    showSuccess('Discount deleted')
    load()
  } catch (e: any) {
    showError(e?.message ?? 'Failed to delete')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Discount Badges</h1>
      <button
        class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
        @click="openNew"
      >
        + New Discount
      </button>
    </div>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">Name</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Type</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Value</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Used</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">Status</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="6" class="text-center py-10 text-gray-400">Loading...</td>
          </tr>
          <tr v-else-if="discounts.length === 0">
            <td colspan="6" class="text-center py-10 text-gray-400">No discounts yet</td>
          </tr>
          <tr
            v-for="d in discounts"
            :key="d.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3 font-medium text-gray-900">{{ d.name }}</td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="d.kind === 'PERCENT' ? 'bg-blue-100 text-blue-700' : 'bg-green-100 text-green-700'"
              >
                {{ d.kind === 'PERCENT' ? '%' : '฿' }}
              </span>
            </td>
            <td class="px-4 py-3 text-center font-semibold text-gray-900">
              {{ d.kind === 'PERCENT' ? `${Number(d.value).toFixed(0)}%` : `฿${Number(d.value).toFixed(0)}` }}
            </td>
            <td class="px-4 py-3 text-center text-gray-500">{{ d._count?.orders ?? 0 }}</td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="d.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ d.isActive ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <button class="text-blue-600 hover:text-blue-800 text-xs font-medium" @click="openEdit(d)">Edit</button>
                <button
                  class="text-xs font-medium"
                  :class="(d._count?.orders ?? 0) > 0 ? 'text-gray-300 cursor-not-allowed' : 'text-red-500 hover:text-red-700'"
                  :disabled="(d._count?.orders ?? 0) > 0"
                  @click="handleDelete(d)"
                >Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Form Modal -->
    <Teleport to="body">
      <div v-if="showForm" class="fixed inset-0 z-50 flex items-center justify-center">
        <div class="absolute inset-0 bg-black/40" @click="showForm = false" />
        <div class="relative bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm space-y-4">
          <h2 class="font-semibold text-gray-900">{{ editingId ? 'Edit Discount' : 'New Discount Badge' }}</h2>

          <div>
            <label class="block text-xs text-gray-500 mb-1">Name <span class="text-red-500">*</span></label>
            <input
              v-model="form.name"
              type="text"
              required
              placeholder="e.g. Staff Discount"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block text-xs text-gray-500 mb-1">Type</label>
              <select
                v-model="form.kind"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="PERCENT">Percent (%)</option>
                <option value="AMOUNT">Amount (฿)</option>
              </select>
            </div>
            <div>
              <label class="block text-xs text-gray-500 mb-1">
                Value {{ form.kind === 'PERCENT' ? '(%)' : '(฿)' }}
              </label>
              <input
                v-model.number="form.value"
                type="number"
                min="0"
                :max="form.kind === 'PERCENT' ? 100 : undefined"
                step="1"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <!-- Preview -->
          <div class="bg-gray-50 rounded-lg px-4 py-2 text-center text-sm text-gray-600">
            <span class="font-semibold text-gray-900">{{ form.name || 'Preview' }}</span>
            {{ ' — ' }}
            <span class="font-semibold text-orange-600">
              {{ form.kind === 'PERCENT' ? `${form.value}% off` : `฿${form.value} off` }}
            </span>
          </div>

          <label class="flex items-center gap-2 cursor-pointer">
            <input v-model="form.isActive" type="checkbox" class="rounded" />
            <span class="text-sm text-gray-700">Active (แสดงใน POS)</span>
          </label>

          <div class="flex gap-3 pt-1">
            <button
              class="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50"
              @click="showForm = false"
            >Cancel</button>
            <button
              class="flex-1 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 disabled:opacity-50"
              :disabled="isSaving || !form.name || form.value <= 0"
              @click="handleSave"
            >{{ isSaving ? 'Saving...' : editingId ? 'Save Changes' : 'Create' }}</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>
