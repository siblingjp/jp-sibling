-- CreateEnum
CREATE TYPE "LoyaltyMode" AS ENUM ('POINTS', 'STAMPS');

-- CreateEnum
CREATE TYPE "StampAction" AS ENUM ('EARN', 'REDEEM', 'ADJUST');

-- CreateEnum
CREATE TYPE "StampRedemptionStatus" AS ENUM ('PENDING', 'CONFIRMED');

-- AlterTable
ALTER TABLE "members" ADD COLUMN     "stampCount" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "products" ADD COLUMN     "isStampEligible" BOOLEAN NOT NULL DEFAULT true;

-- CreateTable
CREATE TABLE "settings" (
    "id" TEXT NOT NULL,
    "loyaltyMode" "LoyaltyMode" NOT NULL DEFAULT 'POINTS',
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stamp_logs" (
    "id" TEXT NOT NULL,
    "action" "StampAction" NOT NULL,
    "amount" INTEGER NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "memberId" TEXT NOT NULL,
    "orderId" TEXT,

    CONSTRAINT "stamp_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stamp_redemptions" (
    "id" TEXT NOT NULL,
    "status" "StampRedemptionStatus" NOT NULL DEFAULT 'PENDING',
    "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "confirmedAt" TIMESTAMP(3),
    "memberId" TEXT NOT NULL,
    "confirmedById" TEXT,
    "orderId" TEXT,

    CONSTRAINT "stamp_redemptions_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "stamp_logs" ADD CONSTRAINT "stamp_logs_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stamp_logs" ADD CONSTRAINT "stamp_logs_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stamp_redemptions" ADD CONSTRAINT "stamp_redemptions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stamp_redemptions" ADD CONSTRAINT "stamp_redemptions_confirmedById_fkey" FOREIGN KEY ("confirmedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stamp_redemptions" ADD CONSTRAINT "stamp_redemptions_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;
