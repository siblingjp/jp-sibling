-- CreateEnum
CREATE TYPE "DiscountKind" AS ENUM ('PERCENT', 'AMOUNT');

-- CreateEnum
CREATE TYPE "Tier" AS ENUM ('SILVER', 'GOLD', 'VIP');

-- AlterEnum
ALTER TYPE "PointAction" ADD VALUE 'EXPIRE';

-- AlterTable
ALTER TABLE "member_orders" ADD COLUMN     "discountKind" "DiscountKind",
ADD COLUMN     "discountValue" DECIMAL(10,2),
ADD COLUMN     "pointsEarned" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "pointsRedeemed" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "members" ADD COLUMN     "googleId" TEXT,
ADD COLUMN     "lineUserId" TEXT,
ADD COLUMN     "profileImage" TEXT,
ADD COLUMN     "tier" "Tier" NOT NULL DEFAULT 'SILVER',
ADD COLUMN     "totalSpent" DECIMAL(10,2) NOT NULL DEFAULT 0,
ALTER COLUMN "email" DROP NOT NULL,
ALTER COLUMN "passwordHash" DROP NOT NULL;

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "discountId" TEXT,
ADD COLUMN     "discountKind" "DiscountKind",
ADD COLUMN     "discountValue" DECIMAL(10,2),
ADD COLUMN     "memberId" TEXT,
ADD COLUMN     "pointsEarned" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "pointsRedeemed" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "point_logs" ADD COLUMN     "expiredAt" TIMESTAMP(3),
ADD COLUMN     "memberOrderId" TEXT,
ADD COLUMN     "orderId" TEXT;

-- AlterTable
ALTER TABLE "promotions" DROP COLUMN "discountType",
ADD COLUMN     "discountKind" "DiscountKind" NOT NULL;

-- DropEnum
DROP TYPE "DiscountType";

-- CreateTable
CREATE TABLE "discounts" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "kind" "DiscountKind" NOT NULL,
    "value" DECIMAL(10,2) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "discounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rewards" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "pointCost" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "rewards_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "members_lineUserId_key" ON "members"("lineUserId");

-- CreateIndex
CREATE UNIQUE INDEX "members_googleId_key" ON "members"("googleId");

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_discountId_fkey" FOREIGN KEY ("discountId") REFERENCES "discounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
