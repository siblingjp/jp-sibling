-- AlterTable
ALTER TABLE "campaigns" ALTER COLUMN "name" DROP DEFAULT;

-- AlterTable
ALTER TABLE "coupons" ALTER COLUMN "updatedAt" DROP DEFAULT;

-- AlterTable
ALTER TABLE "truck_locations" ADD COLUMN     "isOpen" BOOLEAN NOT NULL DEFAULT false,
ALTER COLUMN "updatedAt" DROP DEFAULT;

-- DropEnum
DROP TYPE "CouponStatus";
