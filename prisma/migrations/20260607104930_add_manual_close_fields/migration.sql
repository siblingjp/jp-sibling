-- AlterTable
ALTER TABLE "truck_locations" ADD COLUMN     "blockOnlineOrder" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "manualClose" BOOLEAN NOT NULL DEFAULT false;
