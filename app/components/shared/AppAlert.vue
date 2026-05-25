<script setup lang="ts">
const { alertState, hideAlert, confirmState, resolveConfirm } = useAlert()

const iconMap = {
  success: '✓',
  error: '✕',
  warning: '⚠',
  info: 'ℹ',
}

const colorMap = {
  success: 'bg-green-50 border-green-200 text-green-800',
  error: 'bg-red-50 border-red-200 text-red-800',
  warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
  info: 'bg-blue-50 border-blue-200 text-blue-800',
}

const iconColorMap = {
  success: 'bg-green-100 text-green-600',
  error: 'bg-red-100 text-red-600',
  warning: 'bg-yellow-100 text-yellow-600',
  info: 'bg-blue-100 text-blue-600',
}
</script>

<template>
  <!-- Toast Alert -->
  <Transition name="slide-down">
    <div
      v-if="alertState.isVisible && alertState.options"
      class="fixed top-4 right-4 z-50 max-w-sm w-full"
    >
      <div
        class="flex items-start gap-3 px-4 py-3 rounded-xl border shadow-lg"
        :class="colorMap[alertState.options.type]"
      >
        <span
          class="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold"
          :class="iconColorMap[alertState.options.type]"
        >
          {{ iconMap[alertState.options.type] }}
        </span>
        <div class="flex-1 min-w-0">
          <p v-if="alertState.options.title" class="font-semibold text-sm">{{ alertState.options.title }}</p>
          <p class="text-sm">{{ alertState.options.message }}</p>
        </div>
        <button class="flex-shrink-0 opacity-60 hover:opacity-100" @click="hideAlert">✕</button>
      </div>
    </div>
  </Transition>

  <!-- Confirm Dialog -->
  <Transition name="fade">
    <div
      v-if="confirmState.isVisible && confirmState.options"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
    >
      <div class="absolute inset-0 bg-black/40" @click="resolveConfirm(false)" />
      <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-sm p-6">
        <h3 class="text-base font-semibold text-gray-900 mb-2">
          {{ confirmState.options.title ?? 'Confirm' }}
        </h3>
        <p class="text-sm text-gray-600 mb-6">{{ confirmState.options.message }}</p>
        <div class="flex gap-3 justify-end">
          <button
            class="px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            @click="resolveConfirm(false)"
          >
            {{ confirmState.options.cancelText ?? 'Cancel' }}
          </button>
          <button
            class="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
            @click="resolveConfirm(true)"
          >
            {{ confirmState.options.confirmText ?? 'Confirm' }}
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.2s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
