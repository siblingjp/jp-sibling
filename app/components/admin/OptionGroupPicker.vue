<script setup lang="ts">
import type { OptionGroup } from '~/stores/optionGroups'

const props = defineProps<{
  modelValue: string[]
  options: OptionGroup[]
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string[]]
}>()

const search = ref('')
const isOpen = ref(false)
const inputRef = ref<HTMLInputElement>()
const dropdownRef = ref<HTMLDivElement>()

const selected = computed(() =>
  props.modelValue.map((id) => props.options.find((g) => g.id === id)).filter(Boolean) as OptionGroup[],
)

const filtered = computed(() => {
  const q = search.value.toLowerCase().trim()
  return props.options.filter(
    (g) => g.isActive && !props.modelValue.includes(g.id) && (!q || g.name.toLowerCase().includes(q)),
  )
})

function select(group: OptionGroup) {
  emit('update:modelValue', [...props.modelValue, group.id])
  search.value = ''
  inputRef.value?.focus()
}

function remove(id: string) {
  emit('update:modelValue', props.modelValue.filter((v) => v !== id))
}

function onInputFocus() {
  isOpen.value = true
}

function onBlur(e: FocusEvent) {
  if (dropdownRef.value?.contains(e.relatedTarget as Node)) return
  isOpen.value = false
}
</script>

<template>
  <div class="space-y-2">
    <!-- Search input -->
    <div class="relative">
      <input
        ref="inputRef"
        v-model="search"
        type="text"
        placeholder="Search option groups..."
        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
        @focus="onInputFocus"
        @blur="onBlur"
      />

      <!-- Dropdown -->
      <div
        v-if="isOpen && filtered.length > 0"
        ref="dropdownRef"
        tabindex="-1"
        class="absolute z-20 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-56 overflow-y-auto"
      >
        <button
          v-for="g in filtered"
          :key="g.id"
          type="button"
          class="w-full text-left px-3 py-2.5 hover:bg-blue-50 transition-colors"
          @mousedown.prevent="select(g)"
        >
          <p class="text-sm font-medium text-gray-900">{{ g.name }}</p>
          <p class="text-xs text-gray-400">
            {{ g.required ? 'Required' : 'Optional' }} ·
            {{ g.multiSelect ? 'Multi-select' : 'Single' }} ·
            {{ g.options.length }} options
          </p>
        </button>
      </div>

      <div
        v-else-if="isOpen && search && filtered.length === 0"
        class="absolute z-20 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg px-3 py-3 text-sm text-gray-400"
      >
        No results found
      </div>
    </div>

    <!-- Selected cards -->
    <div v-if="selected.length > 0" class="space-y-2">
      <div
        v-for="g in selected"
        :key="g.id"
        class="flex items-center gap-3 px-3 py-2.5 bg-blue-50 border border-blue-200 rounded-lg"
      >
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900">{{ g.name }}</p>
          <p class="text-xs text-gray-500">
            {{ g.required ? 'Required' : 'Optional' }} ·
            {{ g.multiSelect ? 'Multi-select' : 'Single' }} ·
            {{ g.options.length }} options
          </p>
        </div>
        <button
          type="button"
          class="text-gray-400 hover:text-red-500 transition-colors flex-shrink-0 text-lg leading-none"
          @click="remove(g.id)"
        >
          ×
        </button>
      </div>
    </div>

    <p v-else class="text-xs text-gray-400">No option groups selected</p>
  </div>
</template>
