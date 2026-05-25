import { PrismaClient } from '@prisma/client'
import { hash } from 'argon2'

const prisma = new PrismaClient()

async function main() {
  const passwordHash = await hash('admin1234')

  const admin = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Administrator',
      passwordHash,
      role: 'ADMIN',
      isActive: true,
    },
  })

  console.log(`✅ Seed complete — admin user: ${admin.email}`)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(() => prisma.$disconnect())
