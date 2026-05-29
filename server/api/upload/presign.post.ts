import { z } from 'zod'
import { PutObjectCommand } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'
import { randomUUID } from 'crypto'

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
const MAX_SIZE = 5 * 1024 * 1024 // 5 MB

const schema = z.object({
  filename: z.string().min(1),
  contentType: z.string().refine((t) => ALLOWED_TYPES.includes(t), {
    message: 'Only JPEG, PNG, WebP, and GIF are allowed',
  }),
  size: z.number().max(MAX_SIZE, 'File must be under 5 MB'),
  folder: z.string().regex(/^[a-z0-9-/]+$/).optional().default('uploads'),
})

export default defineEventHandler(async (event) => {
  try {
    const session = await getUserSession(event)
    if (!session.user && !session.member) throw unauthorized()

    const body = validate(schema, await readBody(event))
    const config = useRuntimeConfig()

    if (!config.s3.bucket) throw serverError('S3 bucket not configured')

    const ext = body.filename.split('.').pop()?.toLowerCase() ?? 'jpg'
    const key = `${body.folder}/${randomUUID()}.${ext}`

    const command = new PutObjectCommand({
      Bucket: config.s3.bucket,
      Key: key,
      ContentType: body.contentType,
      ContentLength: body.size,
    })

    const signedUrl = await getSignedUrl(getS3Client(), command, { expiresIn: 300 })
    const publicUrl = `https://${config.s3.bucket}.s3.${config.s3.region}.amazonaws.com/${key}`

    return okResponse({ signedUrl, key, publicUrl })
  } catch (e) {
    handleError(e)
  }
})
