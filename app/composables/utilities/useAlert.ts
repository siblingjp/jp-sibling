type AlertType = 'success' | 'error' | 'warning' | 'info'

interface AlertOptions {
  type: AlertType
  message: string
  title?: string
  duration?: number
}

interface ConfirmOptions {
  title?: string
  message: string
  confirmText?: string
  cancelText?: string
}

interface AlertState {
  isVisible: boolean
  options: AlertOptions | null
}

interface ConfirmState {
  isVisible: boolean
  options: ConfirmOptions | null
  resolver: ((value: boolean) => void) | null
}

const alertState = ref<AlertState>({ isVisible: false, options: null })
const confirmState = ref<ConfirmState>({ isVisible: false, options: null, resolver: null })

export function useAlert() {
  function showAlert(options: AlertOptions) {
    alertState.value = { isVisible: true, options }
    if (options.duration !== 0) {
      setTimeout(() => hideAlert(), options.duration ?? 3000)
    }
  }

  function hideAlert() {
    alertState.value = { isVisible: false, options: null }
  }

  function showSuccess(message: string, title?: string) {
    showAlert({ type: 'success', message, title })
  }

  function showError(message: string, title?: string) {
    showAlert({ type: 'error', message, title, duration: 5000 })
  }

  function showWarning(message: string, title?: string) {
    showAlert({ type: 'warning', message, title })
  }

  function showInfo(message: string, title?: string) {
    showAlert({ type: 'info', message, title })
  }

  function showConfirm(options: ConfirmOptions): Promise<boolean> {
    return new Promise((resolve) => {
      confirmState.value = { isVisible: true, options, resolver: resolve }
    })
  }

  function resolveConfirm(result: boolean) {
    confirmState.value.resolver?.(result)
    confirmState.value = { isVisible: false, options: null, resolver: null }
  }

  function confirmDelete(itemName?: string): Promise<boolean> {
    return showConfirm({
      title: 'Confirm Delete',
      message: itemName ? `Delete "${itemName}"? This cannot be undone.` : 'Delete this item? This cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    })
  }

  return {
    alertState: readonly(alertState),
    confirmState: readonly(confirmState),
    showAlert,
    hideAlert,
    showSuccess,
    showError,
    showWarning,
    showInfo,
    showConfirm,
    resolveConfirm,
    confirmDelete,
  }
}
