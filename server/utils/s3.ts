import { S3Client } from '@aws-sdk/client-s3'

let _client: S3Client | null = null

export function getS3Client(): S3Client {
  if (_client) return _client
  const config = useRuntimeConfig()
  _client = new S3Client({
    region: config.s3.region,
    credentials: {
      accessKeyId: config.s3.accessKey,
      secretAccessKey: config.s3.accessSecret,
    },
  })
  return _client
}
