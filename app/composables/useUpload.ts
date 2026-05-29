interface UploadOptions {
  folder?: string
  onProgress?: (percent: number) => void
}

interface UploadResult {
  key: string
  publicUrl: string
}

export function useUpload() {
  const http = useHttpClient()

  async function uploadViaPresign(file: File, options: UploadOptions = {}): Promise<UploadResult> {
    const { folder = 'uploads' } = options

    const { data } = await http.post<{ data: { signedUrl: string; key: string; publicUrl: string } }>(
      '/api/upload/presign',
      { filename: file.name, contentType: file.type, size: file.size, folder },
    )

    await fetch(data.signedUrl, {
      method: 'PUT',
      body: file,
      headers: { 'Content-Type': file.type },
    }).then((res) => {
      if (!res.ok) throw new Error('S3 upload failed')
    })

    return { key: data.key, publicUrl: data.publicUrl }
  }

  async function uploadDirect(file: File, options: UploadOptions = {}): Promise<UploadResult> {
    const { folder = 'uploads' } = options
    const form = new FormData()
    form.append('file', file)
    form.append('folder', folder)

    const res = await $fetch<{ data: UploadResult }>('/api/upload', {
      method: 'POST',
      body: form,
    })
    return res.data
  }

  return { uploadViaPresign, uploadDirect }
}
