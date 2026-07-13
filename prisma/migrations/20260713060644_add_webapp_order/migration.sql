-- AlterEnum
ALTER TYPE "OrderSource" ADD VALUE 'WEBAPP';

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "guestName" TEXT;
