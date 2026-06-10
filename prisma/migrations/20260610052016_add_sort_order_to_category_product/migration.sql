-- AlterTable
ALTER TABLE "categories" ADD COLUMN     "sortOrder" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "products" ADD COLUMN     "sortOrder" INTEGER NOT NULL DEFAULT 0;
