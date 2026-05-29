-- CreateEnum
CREATE TYPE "CouponStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'EXPIRED');

-- DropForeignKey
ALTER TABLE "member_order_item_options" DROP CONSTRAINT IF EXISTS "member_order_item_options_optionId_fkey";
ALTER TABLE "member_order_item_options" DROP CONSTRAINT IF EXISTS "member_order_item_options_orderItemId_fkey";
ALTER TABLE "member_order_items" DROP CONSTRAINT IF EXISTS "member_order_items_orderId_fkey";
ALTER TABLE "member_order_items" DROP CONSTRAINT IF EXISTS "member_order_items_productId_fkey";
ALTER TABLE "member_orders" DROP CONSTRAINT IF EXISTS "member_orders_memberId_fkey";
ALTER TABLE "promotion_uses" DROP CONSTRAINT IF EXISTS "promotion_uses_memberId_fkey";
ALTER TABLE "promotion_uses" DROP CONSTRAINT IF EXISTS "promotion_uses_promotionId_fkey";
ALTER TABLE "votes" DROP CONSTRAINT IF EXISTS "votes_campaignId_fkey";

-- DropIndex
DROP INDEX IF EXISTS "campaigns_slug_key";

-- AlterTable campaigns (content → discount campaign)
ALTER TABLE "campaigns"
  DROP COLUMN IF EXISTS "endsAt",
  DROP COLUMN IF EXISTS "imageUrl",
  DROP COLUMN IF EXISTS "slug",
  DROP COLUMN IF EXISTS "startsAt",
  DROP COLUMN IF EXISTS "status",
  DROP COLUMN IF EXISTS "title",
  ADD COLUMN IF NOT EXISTS "expiredAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "isActive" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS "memberOnly" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "minTier" "Tier",
  ADD COLUMN IF NOT EXISTS "startAt" TIMESTAMP(3);

-- campaigns.name — title ถูก drop แล้ว ต้องเพิ่ม name
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='campaigns' AND column_name='name') THEN
    ALTER TABLE "campaigns" ADD COLUMN "name" TEXT NOT NULL DEFAULT '';
  END IF;
END $$;

-- AlterTable orders
ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "couponCode" TEXT;

-- AlterTable point_logs
ALTER TABLE "point_logs" DROP COLUMN IF EXISTS "memberOrderId";

-- DropTable
DROP TABLE IF EXISTS "member_order_item_options";
DROP TABLE IF EXISTS "member_order_items";
DROP TABLE IF EXISTS "member_orders";
DROP TABLE IF EXISTS "promotion_uses";
DROP TABLE IF EXISTS "promotions";
DROP TABLE IF EXISTS "rewards";
DROP TABLE IF EXISTS "votes";

-- DropEnum
DROP TYPE IF EXISTS "MemberOrderStatus";

-- CreateTable coupons
CREATE TABLE IF NOT EXISTS "coupons" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "discountKind" "DiscountKind" NOT NULL,
    "discountValue" DECIMAL(10,2) NOT NULL,
    "minOrderAmount" DECIMAL(10,2),
    "maxUses" INTEGER,
    "usedCount" INTEGER NOT NULL DEFAULT 0,
    "startAt" TIMESTAMP(3),
    "expiredAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "memberOnly" BOOLEAN NOT NULL DEFAULT false,
    "minTier" "Tier",
    "pointCost" INTEGER,
    "perMemberLimit" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "coupons_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "coupons_code_key" ON "coupons"("code");

-- CreateTable coupon_uses
CREATE TABLE IF NOT EXISTS "coupon_uses" (
    "id" TEXT NOT NULL,
    "isUsed" BOOLEAN NOT NULL DEFAULT false,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "couponId" TEXT NOT NULL,
    "memberId" TEXT,
    "orderId" TEXT,
    CONSTRAINT "coupon_uses_pkey" PRIMARY KEY ("id")
);

-- CreateTable campaign_coupons
CREATE TABLE IF NOT EXISTS "campaign_coupons" (
    "campaignId" TEXT NOT NULL,
    "couponId" TEXT NOT NULL,
    CONSTRAINT "campaign_coupons_pkey" PRIMARY KEY ("campaignId","couponId")
);

-- CreateTable truck_locations
CREATE TABLE IF NOT EXISTS "truck_locations" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "mapUrl" TEXT,
    "openTime" TEXT,
    "closeTime" TEXT,
    "daysOfWeek" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "truck_locations_pkey" PRIMARY KEY ("id")
);

-- CreateTable location_requests
CREATE TABLE IF NOT EXISTS "location_requests" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "voteCount" INTEGER NOT NULL DEFAULT 0,
    "weekYear" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "memberId" TEXT NOT NULL,
    CONSTRAINT "location_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable location_votes
CREATE TABLE IF NOT EXISTS "location_votes" (
    "id" TEXT NOT NULL,
    "weekYear" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "requestId" TEXT NOT NULL,
    "memberId" TEXT NOT NULL,
    CONSTRAINT "location_votes_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX IF NOT EXISTS "location_votes_requestId_memberId_key" ON "location_votes"("requestId", "memberId");
CREATE UNIQUE INDEX IF NOT EXISTS "location_votes_memberId_weekYear_key" ON "location_votes"("memberId", "weekYear");

-- AddForeignKey
ALTER TABLE "coupon_uses" ADD CONSTRAINT "coupon_uses_couponId_fkey" FOREIGN KEY ("couponId") REFERENCES "coupons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "coupon_uses" ADD CONSTRAINT "coupon_uses_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "coupon_uses" ADD CONSTRAINT "coupon_uses_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "campaign_coupons" ADD CONSTRAINT "campaign_coupons_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "campaigns"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "campaign_coupons" ADD CONSTRAINT "campaign_coupons_couponId_fkey" FOREIGN KEY ("couponId") REFERENCES "coupons"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "location_requests" ADD CONSTRAINT "location_requests_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "location_votes" ADD CONSTRAINT "location_votes_requestId_fkey" FOREIGN KEY ("requestId") REFERENCES "location_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "location_votes" ADD CONSTRAINT "location_votes_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
