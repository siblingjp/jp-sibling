-- AlterTable
ALTER TABLE "coupons" ADD COLUMN     "autoApply" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "bundleDiscount" DECIMAL(10,2),
ADD COLUMN     "bundleQty" INTEGER,
ADD COLUMN     "categoryId" TEXT;

-- AddForeignKey
ALTER TABLE "coupons" ADD CONSTRAINT "coupons_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
