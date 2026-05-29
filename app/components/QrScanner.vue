<script setup lang="ts">
const emit = defineEmits<{
  scanned: [value: string]
  close: []
}>()

const videoRef = ref<HTMLVideoElement | null>(null)
const error = ref('')
const scanning = ref(false)
let stream: MediaStream | null = null
let animFrame: number | null = null

onMounted(() => startCamera())
onUnmounted(() => stopCamera())

async function startCamera() {
  error.value = ''
  scanning.value = true
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'environment' },
    })
    if (videoRef.value) {
      videoRef.value.srcObject = stream
      videoRef.value.play()
      scanLoop()
    }
  } catch {
    error.value = 'ไม่สามารถเปิดกล้องได้ กรุณาอนุญาตการใช้กล้อง'
    scanning.value = false
  }
}

function stopCamera() {
  if (animFrame) cancelAnimationFrame(animFrame)
  stream?.getTracks().forEach((t) => t.stop())
  stream = null
}

async function scanLoop() {
  if (!videoRef.value || videoRef.value.readyState < 2) {
    animFrame = requestAnimationFrame(scanLoop)
    return
  }

  // ใช้ BarcodeDetector API (รองรับใน Chrome/Edge/Android)
  if ('BarcodeDetector' in window) {
    try {
      // @ts-ignore
      const detector = new window.BarcodeDetector({ formats: ['qr_code'] })
      const detect = async () => {
        if (!videoRef.value) return
        try {
          const barcodes = await detector.detect(videoRef.value)
          if (barcodes.length > 0) {
            stopCamera()
            emit('scanned', barcodes[0].rawValue)
            return
          }
        } catch { /* ไม่มี QR ในเฟรมนี้ */ }
        animFrame = requestAnimationFrame(detect)
      }
      detect()
    } catch {
      error.value = 'BarcodeDetector ไม่พร้อมใช้งาน'
    }
  } else {
    // fallback: jsQR via canvas
    try {
      const { default: jsQR } = await import('jsqr')
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')!

      const detect = () => {
        if (!videoRef.value) return
        canvas.width = videoRef.value.videoWidth
        canvas.height = videoRef.value.videoHeight
        ctx.drawImage(videoRef.value, 0, 0)
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        const code = jsQR(imageData.data, canvas.width, canvas.height)
        if (code?.data) {
          stopCamera()
          emit('scanned', code.data)
          return
        }
        animFrame = requestAnimationFrame(detect)
      }
      detect()
    } catch {
      error.value = 'ไม่รองรับการสแกน QR ในเบราว์เซอร์นี้'
    }
  }
}
</script>

<template>
  <div class="flex flex-col items-center gap-4">
    <div v-if="error" class="w-full p-3 bg-red-50 border border-red-200 text-red-600 rounded-lg text-sm text-center">
      {{ error }}
    </div>

    <div class="relative w-full max-w-xs aspect-square bg-black rounded-2xl overflow-hidden">
      <video
        ref="videoRef"
        class="w-full h-full object-cover"
        autoplay
        playsinline
        muted
      />
      <!-- viewfinder overlay -->
      <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="w-48 h-48 relative">
          <span class="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-white rounded-tl-md" />
          <span class="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-white rounded-tr-md" />
          <span class="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-white rounded-bl-md" />
          <span class="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-white rounded-br-md" />
          <!-- scan line animation -->
          <div class="absolute inset-x-0 h-0.5 bg-green-400 animate-scan" />
        </div>
      </div>
    </div>

    <p v-if="scanning && !error" class="text-sm text-gray-500">
      วาง QR Code ให้อยู่ในกรอบ
    </p>

    <button
      class="w-full py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50"
      @click="emit('close')"
    >
      ยกเลิก
    </button>
  </div>
</template>

<style scoped>
@keyframes scan {
  0%   { top: 0; }
  50%  { top: calc(100% - 2px); }
  100% { top: 0; }
}
.animate-scan {
  animation: scan 2s linear infinite;
}
</style>
