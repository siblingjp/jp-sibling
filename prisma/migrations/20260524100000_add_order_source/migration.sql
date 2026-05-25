-- CreateEnum
CREATE TYPE "OrderSource" AS ENUM ('POS', 'ONLINE');

-- AlterTable
ALTER TABLE "member_orders" ADD COLUMN "source" "OrderSource" NOT NULL DEFAULT 'ONLINE';

-- AlterTable
ALTER TABLE "orders" ADD COLUMN "source" "OrderSource" NOT NULL DEFAULT 'POS';
