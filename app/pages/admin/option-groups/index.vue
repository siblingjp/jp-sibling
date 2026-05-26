<script setup lang="ts">
import type { OptionGroup } from '~/stores/optionGroups'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const store = useOptionGroupsStore()
const { showSuccess, showError, showConfirm } = useAlert()

async function load() {
  await store.fetchList().catch((e) => showError(e.message))
}

async function handleDelete(group: OptionGroup) {
  const confirmed = await showConfirm({
    title: 'Delete Option Group',
    message: `Delete "${group.name}"? This cannot be undone.`,
    confirmText: 'Delete',
  })
  if (!confirmed) return
  try {
    await store.remove(group.id)
    showSuccess('Option group deleted')
    load()
  } catch (e: unknown) {
    showError(e instanceof Error ? e.message : 'Failed to delete')
  }
}

onMounted(load)

const groups = computed(() => (store.listState.response?.data as OptionGroup[]) ?? [])
const isLoading = computed(() => store.listState.isLoading)
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ตัวเลือกสินค้า</h1>
      <NuxtLink
        to="/admin/option-groups/new"
        class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700"
      >
        + เพิ่มกลุ่มตัวเลือก
      </NuxtLink>
    </div>

    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="text-left px-4 py-3 font-medium text-gray-600">ชื่อกลุ่ม</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">บังคับเลือก</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">เลือกได้หลายอย่าง</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">ตัวเลือก</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สินค้า</th>
            <th class="text-center px-4 py-3 font-medium text-gray-600">สถานะ</th>
            <th class="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          <tr v-if="isLoading">
            <td colspan="7" class="text-center py-10 text-gray-400">กำลังโหลด...</td>
          </tr>
          <tr v-else-if="groups.length === 0">
            <td colspan="7" class="text-center py-10 text-gray-400">ยังไม่มีกลุ่มตัวเลือก</td>
          </tr>
          <tr
            v-for="g in groups"
            :key="g.id"
            class="border-b border-gray-100 hover:bg-gray-50 transition-colors"
          >
            <td class="px-4 py-3 font-medium text-gray-900">{{ g.name }}</td>
            <td class="px-4 py-3 text-center">
              <span v-if="g.required" class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-700">บังคับ</span>
              <span v-else class="text-gray-400 text-xs">ไม่บังคับ</span>
            </td>
            <td class="px-4 py-3 text-center">
              <span v-if="g.multiSelect" class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-700">หลายอย่าง</span>
              <span v-else class="text-gray-400 text-xs">อย่างเดียว</span>
            </td>
            <td class="px-4 py-3 text-center text-gray-600">{{ g.options.length }}</td>
            <td class="px-4 py-3 text-center text-gray-600">{{ g._count?.products ?? 0 }}</td>
            <td class="px-4 py-3 text-center">
              <span
                class="inline-flex px-2 py-0.5 rounded-full text-xs font-medium"
                :class="g.isActive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'"
              >
                {{ g.isActive ? 'ใช้งานอยู่' : 'ปิดใช้งาน' }}
              </span>
            </td>
            <td class="px-4 py-3 text-right">
              <div class="flex justify-end gap-2">
                <NuxtLink
                  :to="`/admin/option-groups/${g.id}/edit`"
                  class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                >
                  แก้ไข
                </NuxtLink>
                <button
                  class="text-red-500 hover:text-red-700 text-xs font-medium"
                  :disabled="(g._count?.products ?? 0) > 0"
                  :class="(g._count?.products ?? 0) > 0 ? 'opacity-40 cursor-not-allowed' : ''"
                  @click="handleDelete(g)"
                >
                  ลบ
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
