-- AddForeignKey
ALTER TABLE "point_logs" ADD CONSTRAINT "point_logs_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;
