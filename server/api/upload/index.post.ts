import { PutObjectCommand } from '@aws-sdk/client-s3'
import { randomUUID } from 'crypto'

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
const MAX_SIZE = 5 * 1024 * 1024 // 5 MB

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user) throw unauthorized()

    const config = useRuntimeConfig()
    if (!config.s3.bucket) throw serverError('S3 bucket not configured')

    const formData = await readMultipartFormData(event)
    if (!formData?.length) throw badRequest('No file provided')

    const filePart = formData.find((p) => p.name === 'file')
    if (!filePart?.data) throw badRequest('Field "file" is required')

    const contentType = filePart.type ?? 'application/octet-stream'
    if (!ALLOWED_TYPES.includes(contentType)) {
      throw badRequest('Only JPEG, PNG, WebP, and GIF are allowed')
    }
    if (filePart.data.byteLength > MAX_SIZE) {
      throw badRequest('File must be under 5 MB')
    }

    const folderPart = formData.find((p) => p.name === 'folder')
    const folder = folderPart?.data?.toString() ?? 'uploads'
    if (!/^[a-z0-9-/]+$/.test(folder)) throw badRequest('Invalid folder name')

    const ext = (filePart.filename ?? 'file').split('.').pop()?.toLowerCase() ?? 'jpg'
    const key = `${folder}/${randomUUID()}.${ext}`

    await getS3Client().send(
      new PutObjectCommand({
        Bucket: config.s3.bucket,
        Key: key,
        Body: filePart.data,
        ContentType: contentType,
      }),
    )

    const publicUrl = `https://${config.s3.bucket}.s3.${config.s3.region}.amazonaws.com/${key}`

    return okResponse({ key, publicUrl })
  } catch (e) {
    handleError(e)
  }
})
