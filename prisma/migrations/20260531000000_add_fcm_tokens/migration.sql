CREATE TABLE "fcm_tokens" (
  "id" TEXT NOT NULL,
  "token" TEXT NOT NULL,
  "platform" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "memberId" TEXT NOT NULL,

  CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "fcm_tokens_token_key" ON "fcm_tokens"("token");

ALTER TABLE "fcm_tokens" ADD CONSTRAINT "fcm_tokens_memberId_fkey"
  FOREIGN KEY ("memberId") REFERENCES "members"("id") ON DELETE CASCADE ON UPDATE CASCADE;
