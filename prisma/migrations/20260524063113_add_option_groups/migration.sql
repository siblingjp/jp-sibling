-- AlterTable
ALTER TABLE "member_order_items" ADD COLUMN     "note" TEXT;

-- CreateTable
CREATE TABLE "option_groups" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT false,
    "multiSelect" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "option_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "options" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "extraPrice" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "groupId" TEXT NOT NULL,

    CONSTRAINT "options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_option_groups" (
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "productId" TEXT NOT NULL,
    "optionGroupId" TEXT NOT NULL,

    CONSTRAINT "product_option_groups_pkey" PRIMARY KEY ("productId","optionGroupId")
);

-- CreateTable
CREATE TABLE "order_item_options" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "extraPrice" DECIMAL(10,2) NOT NULL,
    "orderItemId" TEXT NOT NULL,
    "optionId" TEXT NOT NULL,

    CONSTRAINT "order_item_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_order_item_options" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "extraPrice" DECIMAL(10,2) NOT NULL,
    "orderItemId" TEXT NOT NULL,
    "optionId" TEXT NOT NULL,

    CONSTRAINT "member_order_item_options_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "options" ADD CONSTRAINT "options_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "option_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_option_groups" ADD CONSTRAINT "product_option_groups_productId_fkey" FOREIGN KEY ("productId") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_option_groups" ADD CONSTRAINT "product_option_groups_optionGroupId_fkey" FOREIGN KEY ("optionGroupId") REFERENCES "option_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_item_options" ADD CONSTRAINT "order_item_options_orderItemId_fkey" FOREIGN KEY ("orderItemId") REFERENCES "order_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_item_options" ADD CONSTRAINT "order_item_options_optionId_fkey" FOREIGN KEY ("optionId") REFERENCES "options"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "member_order_item_options" ADD CONSTRAINT "member_order_item_options_orderItemId_fkey" FOREIGN KEY ("orderItemId") REFERENCES "member_order_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "member_order_item_options" ADD CONSTRAINT "member_order_item_options_optionId_fkey" FOREIGN KEY ("optionId") REFERENCES "options"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
