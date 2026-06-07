-- CreateTable
CREATE TABLE "location_schedules" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "mapUrl" TEXT,
    "openTime" TEXT NOT NULL,
    "closeTime" TEXT NOT NULL,
    "daysOfWeek" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "truckLocationId" TEXT NOT NULL,

    CONSTRAINT "location_schedules_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "location_schedules" ADD CONSTRAINT "location_schedules_truckLocationId_fkey" FOREIGN KEY ("truckLocationId") REFERENCES "truck_locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
