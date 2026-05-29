-- CreateEnum CouponType
DO $$ BEGIN
  CREATE TYPE "CouponType" AS ENUM ('POINT_REDEEM', 'PROMOTION', 'DISCOUNT');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CreateEnum BenefitType
DO $$ BEGIN
  CREATE TYPE "BenefitType" AS ENUM ('DISCOUNT', 'FREE_ITEM');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Add columns to coupons
ALTER TABLE "coupons"
  ADD COLUMN IF NOT EXISTS "type" "CouponType" NOT NULL DEFAULT 'DISCOUNT',
  ADD COLUMN IF NOT EXISTS "benefitType" "BenefitType" NOT NULL DEFAULT 'DISCOUNT',
  ADD COLUMN IF NOT EXISTS "freeItemDescription" TEXT,
  ADD COLUMN IF NOT EXISTS "minQuantity" INTEGER;
