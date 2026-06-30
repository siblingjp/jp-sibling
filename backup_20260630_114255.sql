--
-- PostgreSQL database dump
--

\restrict UlmqpCyBAhmL5bFJVj1Rb7FqZWXQBVctQw2Vgs0MYCGHZChEdV330mocfzcmwLF

-- Dumped from database version 17.10 (9f6157c)
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO neondb_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: neondb_owner
--

COMMENT ON SCHEMA public IS '';


--
-- Name: BenefitType; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."BenefitType" AS ENUM (
    'DISCOUNT',
    'FREE_ITEM'
);


ALTER TYPE public."BenefitType" OWNER TO neondb_owner;

--
-- Name: ContentStatus; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."ContentStatus" AS ENUM (
    'DRAFT',
    'PUBLISHED',
    'ARCHIVED'
);


ALTER TYPE public."ContentStatus" OWNER TO neondb_owner;

--
-- Name: CouponType; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."CouponType" AS ENUM (
    'POINT_REDEEM',
    'PROMOTION',
    'DISCOUNT'
);


ALTER TYPE public."CouponType" OWNER TO neondb_owner;

--
-- Name: DiscountKind; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."DiscountKind" AS ENUM (
    'PERCENT',
    'AMOUNT'
);


ALTER TYPE public."DiscountKind" OWNER TO neondb_owner;

--
-- Name: OrderSource; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."OrderSource" AS ENUM (
    'POS',
    'ONLINE'
);


ALTER TYPE public."OrderSource" OWNER TO neondb_owner;

--
-- Name: OrderStatus; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."OrderStatus" AS ENUM (
    'PENDING',
    'PREPARING',
    'READY',
    'COMPLETED',
    'CANCELLED',
    'RESERVED'
);


ALTER TYPE public."OrderStatus" OWNER TO neondb_owner;

--
-- Name: PaymentMethod; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."PaymentMethod" AS ENUM (
    'CASH',
    'CARD',
    'QR',
    'THAI_HELP'
);


ALTER TYPE public."PaymentMethod" OWNER TO neondb_owner;

--
-- Name: PointAction; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."PointAction" AS ENUM (
    'EARN',
    'REDEEM',
    'ADJUST',
    'EXPIRE'
);


ALTER TYPE public."PointAction" OWNER TO neondb_owner;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."Role" AS ENUM (
    'ADMIN',
    'CASHIER',
    'STAFF'
);


ALTER TYPE public."Role" OWNER TO neondb_owner;

--
-- Name: Tier; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public."Tier" AS ENUM (
    'SILVER',
    'GOLD',
    'VIP'
);


ALTER TYPE public."Tier" OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO neondb_owner;

--
-- Name: articles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.articles (
    id text NOT NULL,
    title text NOT NULL,
    slug text NOT NULL,
    excerpt text,
    body text NOT NULL,
    "coverImage" text,
    status public."ContentStatus" DEFAULT 'DRAFT'::public."ContentStatus" NOT NULL,
    "publishedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.articles OWNER TO neondb_owner;

--
-- Name: campaign_coupons; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.campaign_coupons (
    "campaignId" text NOT NULL,
    "couponId" text NOT NULL
);


ALTER TABLE public.campaign_coupons OWNER TO neondb_owner;

--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.campaigns (
    id text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "expiredAt" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    "memberOnly" boolean DEFAULT false NOT NULL,
    "minTier" public."Tier",
    "startAt" timestamp(3) without time zone,
    name text NOT NULL,
    "imageUrl" text,
    "bannerColor" text,
    "displayMode" text DEFAULT 'image'::text
);


ALTER TABLE public.campaigns OWNER TO neondb_owner;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.categories (
    id text NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    "imageUrl" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.categories OWNER TO neondb_owner;

--
-- Name: coupon_uses; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.coupon_uses (
    id text NOT NULL,
    "isUsed" boolean DEFAULT false NOT NULL,
    "usedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "couponId" text NOT NULL,
    "memberId" text,
    "orderId" text
);


ALTER TABLE public.coupon_uses OWNER TO neondb_owner;

--
-- Name: coupons; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.coupons (
    id text NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    "discountKind" public."DiscountKind" NOT NULL,
    "discountValue" numeric(10,2) NOT NULL,
    "minOrderAmount" numeric(10,2),
    "maxUses" integer,
    "usedCount" integer DEFAULT 0 NOT NULL,
    "startAt" timestamp(3) without time zone,
    "expiredAt" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    "memberOnly" boolean DEFAULT false NOT NULL,
    "minTier" public."Tier",
    "pointCost" integer,
    "perMemberLimit" integer,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    type public."CouponType" DEFAULT 'DISCOUNT'::public."CouponType" NOT NULL,
    "benefitType" public."BenefitType" DEFAULT 'DISCOUNT'::public."BenefitType" NOT NULL,
    "freeItemDescription" text,
    "minQuantity" integer
);


ALTER TABLE public.coupons OWNER TO neondb_owner;

--
-- Name: discounts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.discounts (
    id text NOT NULL,
    name text NOT NULL,
    kind public."DiscountKind" NOT NULL,
    value numeric(10,2) NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.discounts OWNER TO neondb_owner;

--
-- Name: fcm_tokens; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.fcm_tokens (
    id text NOT NULL,
    token text NOT NULL,
    platform text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "memberId" text NOT NULL
);


ALTER TABLE public.fcm_tokens OWNER TO neondb_owner;

--
-- Name: location_requests; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.location_requests (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "voteCount" integer DEFAULT 0 NOT NULL,
    "weekYear" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "memberId" text NOT NULL
);


ALTER TABLE public.location_requests OWNER TO neondb_owner;

--
-- Name: location_schedules; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.location_schedules (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "mapUrl" text,
    "openTime" text NOT NULL,
    "closeTime" text NOT NULL,
    "daysOfWeek" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "truckLocationId" text NOT NULL
);


ALTER TABLE public.location_schedules OWNER TO neondb_owner;

--
-- Name: location_votes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.location_votes (
    id text NOT NULL,
    "weekYear" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "requestId" text NOT NULL,
    "memberId" text NOT NULL
);


ALTER TABLE public.location_votes OWNER TO neondb_owner;

--
-- Name: members; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.members (
    id text NOT NULL,
    email text,
    "passwordHash" text,
    name text NOT NULL,
    phone text,
    points integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "googleId" text,
    "lineUserId" text,
    "profileImage" text,
    tier public."Tier" DEFAULT 'SILVER'::public."Tier" NOT NULL,
    "totalSpent" numeric(10,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.members OWNER TO neondb_owner;

--
-- Name: option_groups; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.option_groups (
    id text NOT NULL,
    name text NOT NULL,
    required boolean DEFAULT false NOT NULL,
    "multiSelect" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.option_groups OWNER TO neondb_owner;

--
-- Name: options; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.options (
    id text NOT NULL,
    name text NOT NULL,
    "extraPrice" numeric(10,2) DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "groupId" text NOT NULL
);


ALTER TABLE public.options OWNER TO neondb_owner;

--
-- Name: order_item_options; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.order_item_options (
    id text NOT NULL,
    name text NOT NULL,
    "extraPrice" numeric(10,2) NOT NULL,
    "orderItemId" text NOT NULL,
    "optionId" text NOT NULL
);


ALTER TABLE public.order_item_options OWNER TO neondb_owner;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.order_items (
    id text NOT NULL,
    quantity integer NOT NULL,
    "unitPrice" numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    note text,
    "orderId" text NOT NULL,
    "productId" text NOT NULL
);


ALTER TABLE public.order_items OWNER TO neondb_owner;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.orders (
    id text NOT NULL,
    "queueNo" integer NOT NULL,
    status public."OrderStatus" DEFAULT 'PENDING'::public."OrderStatus" NOT NULL,
    note text,
    subtotal numeric(10,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text,
    "discountId" text,
    "discountKind" public."DiscountKind",
    "discountValue" numeric(10,2),
    "memberId" text,
    "pointsEarned" integer DEFAULT 0 NOT NULL,
    "pointsRedeemed" integer DEFAULT 0 NOT NULL,
    source public."OrderSource" DEFAULT 'POS'::public."OrderSource" NOT NULL,
    "couponCode" text,
    "pickupTime" text,
    "slipUrl" text,
    "slipUrls" text[],
    "acknowledgedAt" timestamp(3) without time zone
);


ALTER TABLE public.orders OWNER TO neondb_owner;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.payments (
    id text NOT NULL,
    method public."PaymentMethod" NOT NULL,
    amount numeric(10,2) NOT NULL,
    change numeric(10,2) DEFAULT 0 NOT NULL,
    "transactionRef" text,
    "paidAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "orderId" text NOT NULL
);


ALTER TABLE public.payments OWNER TO neondb_owner;

--
-- Name: point_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.point_logs (
    id text NOT NULL,
    action public."PointAction" NOT NULL,
    amount integer NOT NULL,
    note text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "memberId" text NOT NULL,
    "expiredAt" timestamp(3) without time zone,
    "orderId" text
);


ALTER TABLE public.point_logs OWNER TO neondb_owner;

--
-- Name: product_option_groups; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.product_option_groups (
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "productId" text NOT NULL,
    "optionGroupId" text NOT NULL
);


ALTER TABLE public.product_option_groups OWNER TO neondb_owner;

--
-- Name: products; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.products (
    id text NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    "imageUrl" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "categoryId" text NOT NULL,
    "isFeatured" boolean DEFAULT false NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.products OWNER TO neondb_owner;

--
-- Name: truck_locations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.truck_locations (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "mapUrl" text,
    "openTime" text,
    "closeTime" text,
    "daysOfWeek" text,
    "isActive" boolean DEFAULT true NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "isOpen" boolean DEFAULT false NOT NULL,
    "blockOnlineOrder" boolean DEFAULT false NOT NULL,
    "manualClose" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.truck_locations OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    "passwordHash" text NOT NULL,
    name text NOT NULL,
    role public."Role" DEFAULT 'STAFF'::public."Role" NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1069be79-9ef3-4b25-9db8-de2da7a7d506	3b38016a3eb4800a902f54ed0102a7075d210ec10e764078adda07baae8d9642	2026-05-29 07:45:20.311092+00	20260529000000_add_coupon_campaign_system		\N	2026-05-29 07:45:20.311092+00	0
09259275-6f22-49ee-9c27-1d37a98c8f81	efa4b517f582f52737edadfb7e706c22a91c3af3a8f84f0368ecc0669dc8fa78	\N	20260519043810_jp_db	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 20260519043810_jp_db\n\nDatabase error code: 42710\n\nDatabase error:\nERROR: type "Role" already exists\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42710), message: "type \\"Role\\" already exists", detail: None, hint: None, position: None, where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("typecmds.c"), line: Some(1177), routine: Some("DefineEnum") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="20260519043810_jp_db"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="20260519043810_jp_db"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:260	2026-05-29 07:45:47.957101+00	2026-05-29 07:45:31.165753+00	0
4b9ecccd-ca2c-4c7d-802c-12fa5c12a260	efa4b517f582f52737edadfb7e706c22a91c3af3a8f84f0368ecc0669dc8fa78	2026-05-29 07:45:48.573618+00	20260519043810_jp_db		\N	2026-05-29 07:45:48.573618+00	0
ea281f51-436b-43a5-ae9b-25da3448e65b	007cae0672ee3444a9d65f9476f259e68669ae6d483fd1a1764db06d1c3820bb	2026-05-29 07:45:58.746311+00	20260524063113_add_option_groups		\N	2026-05-29 07:45:58.746311+00	0
180268c1-ed8b-4190-9d2b-72b82619d7cf	8a47723d7704d43f2423e8ff7bd6910f5e3cfa2052a208a755377efef89ef1c2	2026-05-29 07:46:08.904683+00	20260524090000_expand_orders_members_points		\N	2026-05-29 07:46:08.904683+00	0
028a50d0-346a-4813-970e-6bc5fb9a53e8	e4193da709f21a5c64ef161390e4351b17c4066d006c68316b5c981eacfda000	2026-05-29 07:46:19.057114+00	20260524100000_add_order_source		\N	2026-05-29 07:46:19.057114+00	0
61b849fc-0b62-4f19-aa4a-9d4af15f1f83	68bcca8f78001cda04e9e4f0133748de9ceb4103bbb68bc9f01c9cb56c449552	2026-05-29 09:25:32.653974+00	20260529010000_coupon_type_benefit_type		\N	2026-05-29 09:25:32.653974+00	0
29177cb3-bb9a-45d6-af41-7c9048da9c2d	8aff04265ea6aa4ba130b2d5058f00c99af9732dab28a2e4e14c4c056c492a47	2026-05-29 17:22:28.512296+00	20260530000000_add_order_pickup_slip		\N	2026-05-29 17:22:28.512296+00	0
e4f8c2ab-0522-40f4-9ec9-bb47096e16d4	a506be7fb2837448492dfe488351755088237fa7d04c04adce89fc6ea0762cf0	2026-06-07 01:11:53.15663+00	20260607011150_add_location_schedules	\N	\N	2026-06-07 01:11:51.620461+00	1
26c1c063-a883-4f30-a633-0ea84971552a	dd35aa7e4825c924302fd2ae4f78c6d534749d3908fdcfdd8e51768554659ba1	2026-05-29 20:55:31.566902+00	20260529205528_add_truck_location_is_open	\N	\N	2026-05-29 20:55:30.06086+00	1
3643f8a5-fef7-4ba7-a085-a6143429b4ea	6824145a11fd3d4c37491f4b9fc6d525788b5fcc759c1790c1399eb64977cd5c	2026-05-30 03:53:05.960663+00	20260530100000_add_campaign_image_display_mode		\N	2026-05-30 03:53:05.960663+00	0
57d1dec2-ca81-4e87-b9fb-c3283236f269	09224649abc9113cde090c281650ac0646b12b97fbc092cf6945fe596eb6fe1b	2026-05-31 15:44:53.348195+00	20260531000000_add_fcm_tokens	\N	\N	2026-05-31 15:44:51.710808+00	1
bb2052ec-8ab8-4f58-a57c-091a233619ba	050848c8e4cd16ca20fac9c4bcbda8ca623b4efa8e36cf51acfa95926b37b589	2026-06-03 15:05:59.648518+00	20260603150556_add_thai_help_payment	\N	\N	2026-06-03 15:05:58.244555+00	1
be68edfd-0748-4449-b08e-0088ed7dc797	0ae70e6ea36580073885c3dbfabe7a9039da0d2c5ddde558df47b07bc26c178a	2026-06-07 03:30:20.61585+00	20260607033017_add_slip_urls	\N	\N	2026-06-07 03:30:19.18423+00	1
43dc1e92-e99c-484e-a8b8-63de812c8e53	a66855d83ce84509b03b69e0bc38de8395c9621252ffdfde2de0664adb280984	2026-06-04 15:00:56.975514+00	20260604150053_add_reserved_order_status	\N	\N	2026-06-04 15:00:55.341374+00	1
bd8e57d0-5b0d-4184-a777-e39e8df20aea	f815ef1eee90a1557c4fb5b31139d6835d221d8eeb3b1557cbe4764ea48b4fb6	2026-06-04 15:44:10.923592+00	20260604154407_add_product_is_featured	\N	\N	2026-06-04 15:44:09.232123+00	1
14d64628-b7ad-4713-9ca2-caeb3d824279	2058a44025ef7cde69bf34f28066b87b209037de4da7e83b3c3ed7169dfc1791	2026-06-07 04:22:13.524382+00	20260607042210_add_order_acknowledged_at	\N	\N	2026-06-07 04:22:11.982956+00	1
d4c346a6-aab4-4dac-9240-54caa68e5bc2	f66a27e4b99beca188c9cceb6ea54d7469e96386fe4416d64e03e186406b5aea	2026-06-07 10:49:33.704839+00	20260607104930_add_manual_close_fields	\N	\N	2026-06-07 10:49:32.169186+00	1
b6c33682-1bd9-494b-a435-7cca44b7708d	28a4cbae575f83de2c3056ab9ba88ac70187b1e81a1267262476fa3eab91ad9e	2026-06-10 05:20:19.861547+00	20260610052016_add_sort_order_to_category_product	\N	\N	2026-06-10 05:20:18.321181+00	1
\.


--
-- Data for Name: articles; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.articles (id, title, slug, excerpt, body, "coverImage", status, "publishedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: campaign_coupons; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.campaign_coupons ("campaignId", "couponId") FROM stdin;
cmpqratcg00073xe3h8gj2ctu	cmpqn1peh00063xe3a4o4ksef
cmqdu8c0r00013xapfkgzeh7p	cmqdtftgj00003xapk9ugw4la
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.campaigns (id, description, "createdAt", "updatedAt", "expiredAt", "isActive", "memberOnly", "minTier", "startAt", name, "imageUrl", "bannerColor", "displayMode") FROM stdin;
cmpqratcg00073xe3h8gj2ctu	รับส่วนลดทันที 10 บาท	2026-05-29 10:05:43.313	2026-05-30 03:57:39.778	2026-06-05 20:05:00	t	f	\N	2026-05-26 20:05:00	ฉลองเปิดร้าน	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/campaigns/2b37d63b-2d5a-4e6d-8ffb-66c57888a5a5.jpg	#1B2B4B	image
cmqdu8c0r00013xapfkgzeh7p	สั่งออนไลน์ รับส่วนลดทันที 5 บาท\n\nสั่งออนไลน์ ของร้าน JP SIBLING COFFEE ผ่านเว็บแอป jp-sibling.com เพื่อสะสมแต้มใช้ในการแลกส่วนลด หรือ แลกรับสิทธิพิเศษในอนาคตได้อีกมากมาย นอกจากนี้ เมื่อคุณเป็นสมาชิกแล้วทุกการใช้จ่ายของคุณจะได้รับเลเวลอัพแรงค์เพื่อให้ได้รับสิทธิประโยชน์ที่มากขั้นอีกด้วย\n\nตั้งแต่วันนี้ถึง 30 มิถุนายน 2569 (ใช้ได้ 1 สิทธิต่อ 1 Member)	2026-06-14 13:46:28.443	2026-06-14 13:48:06.725	2026-06-30 06:45:00	t	t	\N	2026-06-14 06:45:00	สั่งออนไลน์	\N	#f5692e	banner
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.categories (id, name, slug, "imageUrl", "isActive", "createdAt", "updatedAt", "sortOrder") FROM stdin;
cmpqqm2af00003xvop4gn7372	กาแฟเย็น	iced-coffee	\N	t	2026-05-29 09:46:28.218	2026-06-10 05:36:17.207	0
cmpqqm36o00033xvo1r46v845	มัจฉะ	matcha	\N	t	2026-05-29 09:46:29.664	2026-06-10 05:36:19.982	1
cmpqqm2ys00023xvoxoade8tm	เมนูนม & ชา	milk-drinks	\N	t	2026-05-29 09:46:29.38	2026-06-10 05:36:22.744	2
cmpqqm3gw00043xvoo5oazetj	อิตาเลี่ยน โซดา	italian-soda	\N	t	2026-05-29 09:46:30.033	2026-06-10 05:36:25.449	3
cmpqqm2qw00013xvon33dcoir	เมนูร้อน	hot-drinks	\N	t	2026-05-29 09:46:29.097	2026-06-10 05:36:27.676	4
cmpzo7q3e00003xom8w85pzdb	อาหาร	foods	\N	t	2026-06-04 15:49:15.866	2026-06-10 05:36:30.417	5
\.


--
-- Data for Name: coupon_uses; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.coupon_uses (id, "isUsed", "usedAt", "createdAt", "couponId", "memberId", "orderId") FROM stdin;
cmpr7h3kd00063x4aio3sgwen	f	\N	2026-05-29 17:38:30.349	cmpr7gfuz00023x4axiajolcg	cmpr50gby0000l204k4iyqunq	\N
\.


--
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.coupons (id, code, name, description, "discountKind", "discountValue", "minOrderAmount", "maxUses", "usedCount", "startAt", "expiredAt", "isActive", "memberOnly", "minTier", "pointCost", "perMemberLimit", "createdAt", "updatedAt", type, "benefitType", "freeItemDescription", "minQuantity") FROM stdin;
cmpr7gfuz00023x4axiajolcg	540DB45DD382A4F7	50แต้ม ลด 10บาท	\N	AMOUNT	9.00	\N	\N	2	2026-05-28 17:37:00	2026-05-31 17:37:00	t	t	\N	50	1	2026-05-29 17:37:59.627	2026-05-29 19:43:30.097	POINT_REDEEM	DISCOUNT	\N	\N
cmpqn1peh00063xe3a4o4ksef	C37D57DAF4E86E3E	ฉลองเปิดร้าน	\N	AMOUNT	10.00	\N	\N	0	2026-05-29 01:06:00	2026-05-30 01:06:00	t	t	\N	\N	\N	2026-05-29 08:06:39.834	2026-05-30 04:18:22.192	DISCOUNT	DISCOUNT	\N	\N
cmqdtftgj00003xapk9ugw4la	76FD6CD2387B86D6	สั่งออนไลน์ รับส่วนลดทันที 5 บาท	สั่งออนไลน์ รับส่วนลดทันที 5 บาท\n\nสั่งออนไลน์ ของร้าน JP SIBLING COFFEE ผ่านเว็บแอป jp-sibling.com เพื่อสะสมแต้มใช้ในการแลกส่วนลด หรือ แลกรับสิทธิพิเศษในอนาคตได้อีกมากมาย นอกจากนี้ เมื่อคุณเป็นสมาชิกแล้วทุกการใช้จ่ายของคุณจะได้รับเลเวลอัพแรงค์เพื่อให้ได้รับสิทธิประโยชน์ที่มากขั้นอีกด้วย\n\nตั้งแต่วันนี้ถึง 30 มิถุนายน 2569 (ใช้ได้ 1 สิทธิต่อ 1 Member)	AMOUNT	5.00	30.00	\N	14	2026-06-13 23:24:00	2026-06-29 23:24:00	t	t	\N	\N	1	2026-06-14 13:24:18.019	2026-06-29 23:15:38.14	PROMOTION	DISCOUNT	\N	\N
\.


--
-- Data for Name: discounts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.discounts (id, name, kind, value, "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: fcm_tokens; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.fcm_tokens (id, token, platform, "createdAt", "updatedAt", "memberId") FROM stdin;
cmqvvaulj0001l504pevb3u8v	fz2iaksgKM3RPERQJ-MZyY:APA91bGfIGRaeApdv4ZHbYn-BO1DTuet6-2mZSZRouDALtg8tDGaJsetze0EullsDSOsz2AkQiHalDwtpJ7TVs0R1M3AQJh7MpIow1n5zIU_cZr0bpNriv4	android	2026-06-27 04:36:16.616	2026-06-27 10:03:11.131	cmqomlong0000jo04nvihswtt
cmqixobv40001jl046jla0xij	esFek2RodcqIptO84V_NO8:APA91bHUxz1wyyko5erNPnLbzGghQoxiqpkFDq2STaEWyEBQnl2-e4bBQSK6yD7jwDU6UBNVZ86HPNHVN3VVIrR7TjlvUGmNRBMQPU_BDFwh0nqt05L_jPY	android	2026-06-18 03:21:44.464	2026-06-28 23:38:48.56	cmqg347ir0004l104eaekvvjf
cmqulzltp0001l204a0ocxb4y	fVAbX551bA4r5nXFFAHLaE:APA91bHNOQsuaHxkFoTDotEhDjZIarsFDWka47HJF5LZiwrPN3-a47AzGmWNRusmY0Z-RCJhBvEAHrnsl-zFJ1kwgEkkOhF2J1uxvUlkTK8w2Z_Dn60P7cg	android	2026-06-26 07:27:49.309	2026-06-30 02:47:34.966	cmqkghrt00000l704omhsxuo1
cmqg34jxs000cic04lgv4t2dn	cJZsQJt0Fh0a6OwaRu5nxi:APA91bGs6FVjoxpdGuMadDZpxucDK6dfZslGFqao6jt8lfXMY6hldMFGeP03SX67BoBrIcjcWwTm11-3IDSqJ0kGJYolmXWARCDcoFEMI7zro_IVna0xVgY	android	2026-06-16 03:31:00.977	2026-06-16 08:32:35.948	cmqg347ir0004l104eaekvvjf
cmpusf9jq000al704yil6u6ug	e6UteF3HtL1URvz__AQqG7:APA91bG--ovP9qmsu_OePTIAxCf9rfhi3mlXvP0aLmy39rUtw4agU2xkzYLrfymZtXsKwXfmSku6K0wmQsd6PyvxZTp4sAcGxhxn8QO4X5vozeistKrReeE	ios	2026-06-01 05:48:15.254	2026-06-01 05:48:15.254	cmprr5tw70000l404nwvbr3wm
cmpu583570001ju040marfmbc	fX_qbvFSGP73SDIaKOLa3U:APA91bGc8EVIiDIPebcZODZQ0F8zQH66_UXemm3L1vhjFw9d8QJp29-6Gmss8LSfM6UUb5KXgUuFk42yIaWYHM1dQICcvEi62Y-rIIFe-Oacw23hp4H-SYc	ios	2026-05-31 18:58:49.195	2026-06-01 14:49:27.682	cmpr50gby0000l204k4iyqunq
cmpymnd690001l504ihvva6ad	fQTh6G847XA1UsKhcF7j7y:APA91bEArn_hx7Lr2qikFF6CPrWD85cwW1iTDAXAS1sqi8McSiME901iFy0OF45rlLtr9HUHejxuh_TfvBqnGswYCTDTev5cc02inZN-mZ5bIBpb-y8Vx14	android	2026-06-03 22:17:40.21	2026-06-24 05:38:52.866	cmpqxi3y80000jv042tmuxldv
cmqg6j9aj0001ji04xxydp0t7	fWuB1jvxhnWw3jqbcBmyfN:APA91bFBtVwPXg_kckOovqzH4bFdGluVneeel5tZUu3OQ6o3sOilOR19Fb92Wp0V4f51Tj9His52KaLfjxlXIlLipe_iidqNps1h7dabdnZ7SRjyEICZSdY	ios	2026-06-16 05:06:25.867	2026-06-25 13:24:57.873	cmpr50gby0000l204k4iyqunq
cmqu5o5ix0001js04uu6lxnnr	fMJtkUWlxiAGnMbT2-jEMs:APA91bFoT__06eHok4AwAzRIo8KRvZumNe1mEzkyDBs6Xj2FNdC-JVgbAlqEXE9PLDghtXH1f4ujWGHN_zi7T9bHzo_GhVcR6dYP8aXgrCxvkOxwxjUUKfU	ios	2026-06-25 23:51:01.114	2026-06-25 23:51:01.114	cmqfwfly2000xjv048t8vu8hk
cmqdu332u0001l2044mf4bvve	e22h0DI6IdB24tYZti3afa:APA91bEnkF9pVYIBuQWL3w0LmV4r3-VQXSboqNfiYdb0yvBakwBRhhCiIR3e6zcy_5-pYN3-DJU2bdDqi2pNIs2RCVp7ZawQrM6Avd4HSAryG41X1WUcCz4	ios	2026-06-14 13:42:23.569	2026-06-14 13:48:32.157	cmpr50gby0000l204k4iyqunq
cmpzmn2i90001l804il7ap63i	dPMbQHmMqAJ9id1Fuhyjhc:APA91bHeDr9k60uyU5PRzMX3yho3H5Stg4DOm06EmACVFh_tYGVcw-H8ZA_8jqA3DsOVm5kqY226dn9Zz54lYnc2DjMDp49nDaVkLvQZTeI6GxXu9ouq0u0	ios	2026-06-04 15:05:12.559	2026-06-27 00:08:24.432	cmpzm4vyo0000jv04i6eeh20d
\.


--
-- Data for Name: location_requests; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.location_requests (id, name, description, "voteCount", "weekYear", "isActive", "createdAt", "memberId") FROM stdin;
cmprd951n0001jv04rz0xf902	กาดสามแยกสันทราย	หน้า Meta Mall	2	2026-W22	t	2026-05-29 20:20:16.715	cmpqxi3y80000jv042tmuxldv
\.


--
-- Data for Name: location_schedules; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.location_schedules (id, name, description, "mapUrl", "openTime", "closeTime", "daysOfWeek", "isActive", "sortOrder", "createdAt", "updatedAt", "truckLocationId") FROM stdin;
cmq35wgm800033xofnskeo4ps	หน้าศูนย์นิสสัน (ดอนจั่น)	หน้า ศูนย์ซ่อมสีและตัวถัง บริษัทสยามนิสสันเชียงใหม่ (ดอนจั่น)	https://maps.app.goo.gl/khtRjm71HhGwtYsX7	09:00	13:30	จันทร์,อังคาร,พุธ,พฤหัสบดี,ศุกร์,เสาร์	t	2	2026-06-07 02:27:41.984	2026-06-24 05:28:59.888	cmpr5tcym00003x4anuq9i7rn
cmq35s7ao00013xof7pqr5rdi	ซอยวัดพระเจดีย์ (กาดสามแยก)	หน้าบริษัท เอ็กซา ซีแลม จำกัด (สำนักงานใหญ่)	https://maps.app.goo.gl/jmzsf3k6pz4WQJ3L9	06:00	08:00	จันทร์,อังคาร,พุธ,พฤหัสบดี,ศุกร์,เสาร์	t	1	2026-06-07 02:24:23.279	2026-06-25 13:28:13.195	cmpr5tcym00003x4anuq9i7rn
\.


--
-- Data for Name: location_votes; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.location_votes (id, "weekYear", "createdAt", "requestId", "memberId") FROM stdin;
cmprd99f90003jv04t7jfrprp	2026-W22	2026-05-29 20:20:22.388	cmprd951n0001jv04rz0xf902	cmpqxi3y80000jv042tmuxldv
cmprss3l7000ijt042ettirwz	2026-W22	2026-05-30 03:34:55.53	cmprd951n0001jv04rz0xf902	cmpr50gby0000l204k4iyqunq
\.


--
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.members (id, email, "passwordHash", name, phone, points, "isActive", "createdAt", "updatedAt", "googleId", "lineUserId", "profileImage", tier, "totalSpent") FROM stdin;
cmqa7bt6q0000ju049ed0st5o	khathapk@gmail.com	\N	Khatha PK	0947472069	0	t	2026-06-12 00:42:00.963	2026-06-12 00:42:10.649	107324162135590629184	\N	https://lh3.googleusercontent.com/a/ACg8ocIPLebPm4ylFrZNM61mJ0JxmVlxC4HG1GQHhAaufdp9Uz35eQ=s96-c	SILVER	0.00
cmpr7aq6v00013x4aamvzv0xh	sibling.jp@gmail.com	\N	jp sibling	\N	0	t	2026-05-29 17:33:33.079	2026-05-29 17:33:33.079	104189133825665833714	\N	https://lh3.googleusercontent.com/a/ACg8ocKRLhYLDWHNL9w6Lc43fiIfxOsw-faMAAbAnXHwEiJZv464=s96-c	SILVER	0.00
cmq2kvw1o0002la04o83ql1ye	kwanssp@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$4UQiSNKn/B4GUAt4lA0bEQ$tOWL208wH3IlgBFBc/fhly78SXBy4X0CBVgmnV7BuXM	Kwanssp	0620401452	0	t	2026-06-06 16:39:23.388	2026-06-06 16:39:23.388	\N	\N	\N	SILVER	0.00
cmqg347ir0004l104eaekvvjf	phuwarat.p@gmail.com	\N	Phuwarat Phowutthirat	0889523537	0	t	2026-06-16 03:30:44.883	2026-06-16 03:30:59.227	110791560232185016722	\N	https://lh3.googleusercontent.com/a/ACg8ocKb2QHpbQXjRC_rAtufgHzK-dvMgSuiftNBNXkt2ObQK9mrfoo=s96-c	SILVER	0.00
cmprr5tw70000l404nwvbr3wm	kotchakorn.yot@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$D1FlbOPDVthQbFqOAM/3cw$jAw3kbJ/JUzMbrn8xksfhb0eJ9bAraG9j3TV6DUAk18	กชกร โพวุฒิรัฐ	0956857655	53	t	2026-05-30 02:49:36.919	2026-06-14 14:40:55.57	\N	\N	\N	SILVER	550.00
cmpyq1hor0009jp04pag05amt	meannyaom@hotmail.com	$argon2id$v=19$m=65536,t=3,p=4$BNlu+wrmLIAue+8YMW3fEA$Egw4Mb54CAcDcMFYPr86ielRhsUnxZ/FCwtNHrhfg2k	aommy	\N	0	t	2026-06-03 23:52:38.092	2026-06-03 23:52:38.092	\N	\N	\N	SILVER	0.00
cmpxcpm810000l804ote96h3k	\N	\N	Minkk🖤	0952395254	0	t	2026-06-03 00:51:42.914	2026-06-03 00:51:52.169	\N	Uf73730ebe3dfaaf2758f449a432c5110	https://profile.line-scdn.net/0hPFcNrkIrD2lONx5hurlxFj5nDANtRlZ7ZlNEC3M3Vl4mARs7MllFD3lnUl4gAEE2MFlADyxnWQpCJHgPUGHzXUkHUlhzBkg5a1RIjA	SILVER	0.00
cmq5x4idd0010l804hlnoz3k9	Kanokwan28298@hotmail.com	$argon2id$v=19$m=65536,t=3,p=4$QWpaGoAUNcQKznMveomOGw$+pA5ytYQMTKGVY5k+Ylqp0LNdqRBF4SA2mKxU/xn0qE	Kanokwan	0991349084	0	t	2026-06-09 00:45:19.49	2026-06-09 00:45:19.49	\N	\N	\N	SILVER	0.00
cmpz1i90w0000ib047g3inszr	dome.dao339@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$8zf7aOdhru5kYtioj2BtPw$i3LGmrjVLlJSUbjJZHaI7RsqI27if58wMCSA1Hp1TgU	ปกรณ์	0629469447	0	t	2026-06-04 05:13:35.793	2026-06-04 05:13:35.793	\N	\N	\N	SILVER	0.00
cmqega1g0001cjq04i0l0z1yn	kyotsuakino3567@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$wcunebfSePNxUArV+RtfDA$t2NxO0HGpf3WfqzxQqEuS0eHPQ/lYccj8LQKSuQQB2A	แบงค์	0952191695	0	t	2026-06-15 00:03:39.6	2026-06-15 00:03:39.6	\N	\N	\N	SILVER	0.00
cmpr50gby0000l204k4iyqunq	phurachan.p@gmail.com	\N	James	0979548922	1014	t	2026-05-29 16:29:34.511	2026-06-30 03:24:45.041	110792605654181929675	\N	https://lh3.googleusercontent.com/a/ACg8ocLzx-2N2ybfya9z8I04cnlw2OVVV93pQvg2bwGnIj_1orjtXw=s96-c	SILVER	677.00
cmq034bpi0009jr04rvfh744g	thanikarn35019@gmail.com	\N	Thanikarn_b	0948307411	8	t	2026-06-04 22:46:31.495	2026-06-05 00:43:06.83	\N	U3d14aa1bc04b7f65ccdf0362cc80ee16	https://profile.line-scdn.net/0hDYHhO-zhG3ZlEQWH7ExlSBVBGBxGYEJkGyBVGFgUEU4IIwkkTiNUFgUQFkQPKV4mHnRXFgAVRkBHewYoETAkVhlJEB8lYCx8AXYpQhBMDAc4VAVgPQERdTNEQCM2aBhpFx4sZwB4QCMeKSZQMykQSAJ0TSI_VRVQMUZ3IGAjdfUKE2wjSHdVEFYYQE7b	SILVER	90.00
cmq1np99f000gjo048bks9own	nittayaka009@gmail.com	\N	คำฟิว❤️	0942370037	22	t	2026-06-06 01:10:26.595	2026-06-08 00:58:21.614	\N	Ucd08024767136a667e394671aee86cec	https://profile.line-scdn.net/0hrdbmR1EPLUtPFDOBeLlTdT9ELiFsZXRZYyA2LCkSdHp0Im5Pa3I3LigRJnIgI24bZ3EwJXkScHltVBxpIgklLxlUBggUVi91ancCRD1GdRsZWGhKZhkkLSlnNCwEfRJOHTEVcARKIAkNWWJkYS0faB4XJS91cWlqY0NBHUomQ8ggFloeYnJjLXwddnPx	SILVER	230.00
cmq7hdolg000klb04x9d9hye6	Natsarin_nor@hotmail.com	$argon2id$v=19$m=65536,t=3,p=4$iCRcpoKTjw3EwIvit63fZA$pLHvfm8s2bGHh3DWVU43yrM4MIZHo7oZ3kHGgL9XC4Y	ณัสรินทร์	0838605425	82	t	2026-06-10 03:00:05.956	2026-06-26 03:06:26.167	\N	\N	\N	SILVER	840.00
cmq5b4cnf0000l504eara0rfz	cholthicha1199@gmail.com	\N	🧊• 🅸🅲🅴 •🧊	0960708946	0	t	2026-06-08 14:29:20.524	2026-06-08 14:29:57.808	\N	Ua44f854bb0534cc8ebc402a2ece7f7bc	https://profile.line-scdn.net/0hlX-WZkudM3cALi8Pn-lNSXB-MB0jX2plfhp-FGYqaEY0SnB0ex94RGJ7OEI9GiB0Kkh-EWYrPRciTnxoJU84UGhrLTc0R3VCXC80YX0sGy86TS5-QhgFT3N3EUV2QQ8jRUF6UzwmCQdiTRRcbSE9eXRIai9NYTFlXnlfIQUcXfRvLEQiLUh9ETMnaE--	SILVER	0.00
cmq5wjkiw0000jy04p03a3vql	phatpreya21@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$4TrEcAS2YYZz9/Bbz9KasA$BWjtoPmFPEIhqdUMHZbhKOetG0Y3jxSliND2qq7y/y4	Phatpreya 	\N	14	t	2026-06-09 00:29:02.504	2026-06-16 00:38:03.684	\N	\N	\N	SILVER	150.00
cmqiqhd250000l1049ycrlu3u	auncha6581@gmail.com	\N	AUN✨	0954821889	0	t	2026-06-18 00:00:22.11	2026-06-18 00:00:34.614	\N	Ubfdd928c7df8f4fe50a5c9f58a5dd9f7	https://profile.line-scdn.net/0hk5_CMnS7NBpyOiuAhPdKJAJqN3BRS20IVg4rK0EyangbDSEYWVl8ehVuOilMCXceDAsudU9obH9Qdx1QNR4yeTI9Fm0GYjcaVj0yLAV5AVgqDRUHVxULAixyDFc1cxBNKzkjDBxoCHILehQrCgN4PDVibWFIdzM7I21YTHcIWpkdOENPX1x6fEEzbyLM	SILVER	0.00
cmqiqhmsp0001l104ukcdhhbl	vmark_123@hotmail.com	$argon2id$v=19$m=65536,t=3,p=4$TInqsr221BeT+60fiKcxGw$DNHuBgqU+1snr1SJbpQJbRSjnUIcM1/qYNsUSrdXBW8	Chanunpat	0956916085	27	t	2026-06-18 00:00:34.729	2026-06-30 00:31:04.15	\N	\N	\N	SILVER	315.00
cmq8t9f5v0000l204ne6jf3e3	salinee.pin2530@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$U5p0x76G5B2jtP1yKPREyg$KHB19eVfylQZ654r4+zn0TqhzXgSBfm6gHLM6K7X4io	ปิ่น	0946344240	0	t	2026-06-11 01:20:28.676	2026-06-11 01:20:28.676	\N	\N	\N	SILVER	0.00
cmpzm4vyo0000jv04i6eeh20d	adtthapon87@gmail.com	\N	Na Adtthaporn	0932513105	340	t	2026-06-04 14:51:04.272	2026-06-27 00:53:39.172	110476870873610490202	\N	https://lh3.googleusercontent.com/a/ACg8ocJfkk64oq0iEjiumOIJvbvprXTG1TgpqE8K0ZBRGZ8G4NBP2-py=s96-c	GOLD	3225.00
cmqh9bzp90002jo04a1bozkv8	natsimama@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$mzm41fL3YiYlEeXrRE1DjQ$uRVzbnpKxy8vZyyoqttprfcZ3/30bdwizmEj06hlyGM	Natsima	0867284009	54	t	2026-06-16 23:12:31.87	2026-06-19 00:31:12.125	\N	\N	\N	SILVER	550.00
cmpqxi3y80000jv042tmuxldv	jom.tairut@gmail.com	\N	gung full (som)	0889523537	19	t	2026-05-29 12:59:21.344	2026-06-21 23:32:16.471	100475880588842882978	\N	https://lh3.googleusercontent.com/a/ACg8ocKiKJf5CdwLBWkE6xzMS_RWepiiXBFpIzub0FfEoEu2DCZvqRYlqA=s96-c	SILVER	200.00
cmqfwfly2000xjv048t8vu8hk	aun.rattanawan@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$2W7ItrySVaErlPu8IxOyyg$IehHpUXwXoHrGfw0pUwzoAeAQUQ0adZLg/C9VDxyHR0	Aun.rk	0623086561	100	t	2026-06-16 00:23:39.483	2026-06-26 00:34:09.388	\N	\N	\N	SILVER	1025.00
cmqkghrt00000l704omhsxuo1	varyu.pe@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$vittyYkz0Bt0g73aOBmZEg$LIKK4Sgi8F0hZC6txCtTFszzf1EjSUYat1urSE630ww	ยุพิน สิทธิสาร	0911435409	23	t	2026-06-19 04:56:17.413	2026-06-27 05:09:13.474	106206401988111947523	\N	https://lh3.googleusercontent.com/a/ACg8ocKb_ls8eefBFi5D6fb55W3jAHhOyuPdqDPyE8Mp8DI0JthDdg=s96-c	SILVER	245.00
cmqomlong0000jo04nvihswtt	rapeepun.kf@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$7qOOAaKMXEtiQoZrMEc2OA$O7a8eTMmmL7Ck2aJpRt0LS1hS2uEhqWHsRvvWM9rSoY	เหมียว	0931395946	54	t	2026-06-22 02:58:22.348	2026-06-27 05:09:12.915	112205238096024393107	\N	https://lh3.googleusercontent.com/a/ACg8ocKDn2rpA2hz2ommI-bnAMBLdlbzhAWlX029FrVmO-HYgFA4jz4=s96-c	SILVER	550.00
cmqq8wovn0000lb049v7xgemg	keetrajazz@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$H4xTsB5sDOYxvx3O//ZfYA$j6AU1sVYQwBdRHyg+0cBUXqbkzl2r6G0sH2NbyC95/w	แนน	\N	0	t	2026-06-23 06:10:33.587	2026-06-23 06:10:33.587	\N	\N	\N	SILVER	0.00
cmqq92kxf0000jr047jszj64u	pradthana310526@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$vAo7rY+jUwFtkbljM5j2mw$S/nSTpHRFKBYtA4TOXZGKzhS4ZuMaFJJfBna0M4DFmo	ปรารถนา แซ่คู	0642013419	6	t	2026-06-23 06:15:08.404	2026-06-23 06:18:13.622	\N	\N	\N	SILVER	70.00
cmquj7e1h0008l804r1t3y6ka	tasupa7@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$tfUriVn6nq3FFezAY+3SnA$kYvHD5mjdnfLJ8fTquj/Gk1izMBrdynT6XoNW68tli0	อนุสรณ์ ตาสุภา	0832452495	0	t	2026-06-26 06:09:53.622	2026-06-26 06:09:53.622	\N	\N	\N	SILVER	0.00
cmqzu4sql0000l504bnw2yan4	sarunthornjaikaew@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$nEuwMMe/ZFuIKsaMAROFCg$KuKjjWWZqvjZS4FZIlcEBNrd+iE7+osGo8gpurba6io	Sarunx	0805021211	30	t	2026-06-29 23:14:39.357	2026-06-30 00:30:26.617	\N	\N	\N	SILVER	310.00
cmqlxu95y0000lh04zmipokf0	imomayiii@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$hcN+5jicaSsz4P+wKAToYA$5Ai8WcqBIFcCvuGvSN9y5dW8GQPKg+A6rhxUf/9CGvE	เนตรชนก ปันทะช้าง	0611937611	137	t	2026-06-20 05:49:39.43	2026-06-24 06:01:12.528	109201717756322048472	\N	https://lh3.googleusercontent.com/a/ACg8ocKTKrmjCjlDD0pJHidMGwS3W0D0-oKWrgiycXd8UPghMbAA9T1b=s96-c	SILVER	1395.00
cmqyznxcy0000jo0477ol00sq	jchudaporn6@gmail.com	\N	จ๊ะเอ๋	0611466241	28	t	2026-06-29 09:01:43.715	2026-06-30 00:30:32.584	\N	Uaeecd37918a6dd3d18f70dcc44210f3b	https://profile.line-scdn.net/0hyrlmhWjDJl1BFDfbOPBYYzFEJTdiZX9Pb3RgMnAde210dzFYbXVvaHxGeW97d2cLOHRuPXNBeG1jcmlTMQFtYyx1ZDApQBgNDgsofgdzCyQsUiNDGhcQWQxRAWQ5Qwl0cXULY3ZJHhsXLRZQbRoheDFEPBcgTBVzBENKC0QmSN4uFlEIbHJoO3IdfWX_	SILVER	290.00
cmqhb2kc7000sl704mpvec7wu	congsuk121@gmail.com	\N	Aoy	0618927912	76	t	2026-06-17 00:01:11.287	2026-06-30 00:46:15.309	\N	U7d5e349d1f4e88a1a49e7e04a36f68ff	https://profile.line-scdn.net/0hIDKuh210FmtmDAoFtBVoVRZcFQFFfU95HW5bXVBbTg8MP1g-TjgJD1NfQAxbbwI8SG9aDQAMTVNEYDN6FSkNfiBEQDkrPRc0OTkvdC8ECSMpWzJFShUObC8NLwYcODF1JDgjSSF1KjIARFdBMwEfdCFQA1M7RlRnLVt6PWM-eOgJDmE-S2pYDVUFTVPY	SILVER	830.00
cmpymupkz0000js04v26bxcpp	mintjungtap1@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$rMcGQVeRTXwCLVbhiQHQMg$bcpwsCOXT2wfqQb3mSMjITJDEouFKF7v+A2x/btQ0lw	มิ้น	\N	1310	t	2026-06-03 22:23:22.883	2026-06-30 00:50:17.791	\N	\N	\N	VIP	10230.00
\.


--
-- Data for Name: option_groups; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.option_groups (id, name, required, "multiSelect", "isActive", "sortOrder", "createdAt", "updatedAt") FROM stdin;
cmpraghfn00083xj3mubzcis0	ความเข้มกาแฟ	t	f	t	1	2026-05-29 19:02:00.189	2026-05-29 19:02:00.189
cmprak1wr000c3xj38au25c61	ความหวาน	t	f	t	2	2026-05-29 19:04:44.792	2026-05-29 19:04:44.792
cmpralv7h000h3xj3hrbl5r9s	ช็อตกาแฟ	f	f	t	3	2026-05-29 19:06:11.374	2026-05-29 19:06:11.374
cmpraptea000n3xj3l9yv04bm	เพิ่มเติม	f	f	t	5	2026-05-29 19:09:15.532	2026-05-29 19:09:15.532
cmpran7d3000k3xj3cddg18jm	ประเภท	t	f	t	4	2026-05-29 19:07:13.777	2026-05-31 16:49:40.833
cmq3v6ydv0000js04142zjpoi	ความหวาน2	t	f	t	0	2026-06-07 14:15:41.97	2026-06-07 14:15:41.97
cmqyqzbdb0004l404fiuyewa2	ประเภทข้าวแกง	f	f	t	0	2026-06-29 04:58:38.51	2026-06-29 05:01:48.95
\.


--
-- Data for Name: options; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.options (id, name, "extraPrice", "isActive", "sortOrder", "groupId") FROM stdin;
cmpraghfn00093xj3teu0s9ye	คั่วเข้ม	0.00	t	0	cmpraghfn00083xj3mubzcis0
cmpraghfn000a3xj3le4hn9nj	คั่วกลาง	0.00	t	1	cmpraghfn00083xj3mubzcis0
cmpraghfn000b3xj33nmkm7g2	คั่วอ่อน	0.00	t	2	cmpraghfn00083xj3mubzcis0
cmprak1wr000d3xj3791vuavv	ไม่หวาน 0%	0.00	t	0	cmprak1wr000c3xj38au25c61
cmprak1wr000e3xj3e60lzs1w	หวานน้อย 50%	0.00	t	1	cmprak1wr000c3xj38au25c61
cmprak1ws000f3xj35gi3varl	หวานปกติ 100%	0.00	t	2	cmprak1wr000c3xj38au25c61
cmprak1ws000g3xj3pdboyhw3	หวานมาก 120%	0.00	t	3	cmprak1wr000c3xj38au25c61
cmpralv7i000i3xj32dj8ylsa	ลดช็อต	0.00	t	0	cmpralv7h000h3xj3hrbl5r9s
cmpralv7i000j3xj3b1u9nwyo	เพิ่มช็อต	10.00	t	1	cmpralv7h000h3xj3hrbl5r9s
cmpraptea000o3xj3zfahd2f7	แยกน้ำแข็ง	0.00	t	0	cmpraptea000n3xj3l9yv04bm
cmpran7d3000l3xj3w4zm611l	เย็น	0.00	t	0	cmpran7d3000k3xj3cddg18jm
cmpran7d3000m3xj3znj3klm9	ปั่น	10.00	t	1	cmpran7d3000k3xj3cddg18jm
cmq3v6ydv0001js04mbuyt8in	หวานปกติ 100%	0.00	t	0	cmq3v6ydv0000js04142zjpoi
cmq3v6ydv0002js04x855n4v7	หวานมาก 120%	0.00	t	1	cmq3v6ydv0000js04142zjpoi
cmq3v6ydv0003js04d5qnva0d	หวานม๊วกๆ 150%	0.00	t	2	cmq3v6ydv0000js04142zjpoi
cmqyqzbdb0005l404zjd2oixn	กับข้าว(อย่างเดียว)	0.00	t	0	cmqyqzbdb0004l404fiuyewa2
cmqyqzbdb0006l404gcgxtrke	ข้าวราดแกง 1 อย่าง	5.00	t	1	cmqyqzbdb0004l404fiuyewa2
cmqyr3ea0000hl40491y3rszk	ข้าวราดแกง 2 อย่าง	10.00	t	2	cmqyqzbdb0004l404fiuyewa2
\.


--
-- Data for Name: order_item_options; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.order_item_options (id, name, "extraPrice", "orderItemId", "optionId") FROM stdin;
cmprbxrj800043xv176j6kv2k	ปั่น	10.00	cmprbxrj800023xv182e420ba	cmpran7d3000m3xj3znj3klm9
cmprrzj450005jt04mosme8z4	หวานปกติ 100%	0.00	cmprrzj450003jt04b65kr8ei	cmprak1ws000f3xj35gi3varl
cmprsdg5p000cjt047ypth7az	หวานปกติ 100%	0.00	cmprsdg5p000ajt04zn31drgf	cmprak1ws000f3xj35gi3varl
cmprsdg5p000djt04gkht40ei	ลดช็อต	0.00	cmprsdg5p000ajt04zn31drgf	cmpralv7i000i3xj32dj8ylsa
cmprsdg5p000ejt04foklfkk3	แยกน้ำแข็ง	0.00	cmprsdg5p000ajt04zn31drgf	cmpraptea000o3xj3zfahd2f7
cmptyhvzb0004l804ou7b8fzy	หวานน้อย 50%	0.00	cmptyhvzb0002l804ovotqzk2	cmprak1wr000e3xj3e60lzs1w
cmptyhvzb0005l804d18iagx9	ลดช็อต	0.00	cmptyhvzb0002l804ovotqzk2	cmpralv7i000i3xj32dj8ylsa
cmpu4czuy000cjy04kobggysz	หวานปกติ 100%	0.00	cmpu4czuy000ajy04ry3rsmpp	cmprak1ws000f3xj35gi3varl
cmpu4czuy000djy049hyrdb49	เย็น	0.00	cmpu4czuy000ajy04ry3rsmpp	cmpran7d3000l3xj3w4zm611l
cmpu4laht000mjy04ckiolbpb	หวานปกติ 100%	0.00	cmpu4laht000kjy04wn9pwa46	cmprak1ws000f3xj35gi3varl
cmpu59edy0004l804qxfbkshk	ไม่หวาน 0%	0.00	cmpu59edy0002l804kmlteay5	cmprak1wr000d3xj3791vuavv
cmpu59edy0005l804wcvw64mm	ลดช็อต	0.00	cmpu59edy0002l804kmlteay5	cmpralv7i000i3xj32dj8ylsa
cmpuscer10004l704b5ng9hi7	คั่วเข้ม	0.00	cmpuscer10002l7040cb4vlud	cmpraghfn00093xj3teu0s9ye
cmpuscer10005l704qxk1c90k	หวานน้อย 50%	0.00	cmpuscer10002l7040cb4vlud	cmprak1wr000e3xj3e60lzs1w
cmpuscer10006l7043b3yr753	เย็น	0.00	cmpuscer10002l7040cb4vlud	cmpran7d3000l3xj3w4zm611l
cmpushqhb000fl704a70xhoah	หวานปกติ 100%	0.00	cmpushqhb000dl704t2gsr0b7	cmprak1ws000f3xj35gi3varl
cmpushqhb000gl7040nk5wlaj	เย็น	0.00	cmpushqhb000dl704t2gsr0b7	cmpran7d3000l3xj3w4zm611l
cmpw7kynv0005js04nux83g4y	หวานปกติ 100%	0.00	cmpw7kynv0003js04xkoezyc4	cmprak1ws000f3xj35gi3varl
cmpw7kynv0006js04t8rxgovt	เย็น	0.00	cmpw7kynv0003js04xkoezyc4	cmpran7d3000l3xj3w4zm611l
cmpw7kynv0009js040ugj2ale	หวานน้อย 50%	0.00	cmpw7kynv0007js04vrk7tr98	cmprak1wr000e3xj3e60lzs1w
cmpw7kynv000ajs04nfuj0c3x	เย็น	0.00	cmpw7kynv0007js04vrk7tr98	cmpran7d3000l3xj3w4zm611l
cmpw7kynv000djs04uiubkdm9	หวานปกติ 100%	0.00	cmpw7kynv000bjs041u7myr4n	cmprak1ws000f3xj35gi3varl
cmpw7kynv000ejs04enigug0f	เย็น	0.00	cmpw7kynv000bjs041u7myr4n	cmpran7d3000l3xj3w4zm611l
cmpw7lkgv000mjs04gujtdu85	คั่วเข้ม	0.00	cmpw7lkgv000kjs04ez4dpxla	cmpraghfn00093xj3teu0s9ye
cmpw7lkgv000njs04hfzts3fh	ไม่หวาน 0%	0.00	cmpw7lkgv000kjs04ez4dpxla	cmprak1wr000d3xj3791vuavv
cmpw7m0j0000vjs04wesqaued	หวานปกติ 100%	0.00	cmpw7m0j0000tjs049b8vcsu5	cmprak1ws000f3xj35gi3varl
cmpw7m0j0000wjs04rfcuzuvs	เย็น	0.00	cmpw7m0j0000tjs049b8vcsu5	cmpran7d3000l3xj3w4zm611l
cmpw7okso0014js04r73r20io	คั่วกลาง	0.00	cmpw7okso0012js04rhp22xaj	cmpraghfn000a3xj3le4hn9nj
cmpw7okso0015js04v8hfez6t	ไม่หวาน 0%	0.00	cmpw7okso0012js04rhp22xaj	cmprak1wr000d3xj3791vuavv
cmpw7okso0018js04re3xi8se	ไม่หวาน 0%	0.00	cmpw7okso0016js04jimdqmvn	cmprak1wr000d3xj3791vuavv
cmpw7okso0019js0408utzia5	เย็น	0.00	cmpw7okso0016js04jimdqmvn	cmpran7d3000l3xj3w4zm611l
cmpw7okso001cjs04k7ludbew	หวานน้อย 50%	0.00	cmpw7okso001ajs041976vufy	cmprak1wr000e3xj3e60lzs1w
cmpw7okso001djs04szuapopz	เย็น	0.00	cmpw7okso001ajs041976vufy	cmpran7d3000l3xj3w4zm611l
cmpw7okso001gjs047f1xfy2t	หวานปกติ 100%	0.00	cmpw7okso001ejs048y1fonrs	cmprak1ws000f3xj35gi3varl
cmpw7okso001hjs046yk0mh6i	เย็น	0.00	cmpw7okso001ejs048y1fonrs	cmpran7d3000l3xj3w4zm611l
cmpw7p6f3001pjs04k6bq25v3	หวานปกติ 100%	0.00	cmpw7p6f3001njs04szoxwixl	cmprak1ws000f3xj35gi3varl
cmpw7p6f3001sjs042lbhsdpe	หวานปกติ 100%	0.00	cmpw7p6f3001qjs04rlnnt8fp	cmprak1ws000f3xj35gi3varl
cmpw7p6f3001tjs047gckwufa	เย็น	0.00	cmpw7p6f3001qjs04rlnnt8fp	cmpran7d3000l3xj3w4zm611l
cmpw7p6f3001wjs04j0s8vmau	หวานปกติ 100%	0.00	cmpw7p6f3001ujs04j1mvg15r	cmprak1ws000f3xj35gi3varl
cmpw7p6f3001xjs04uy8z9ymh	เย็น	0.00	cmpw7p6f3001ujs04j1mvg15r	cmpran7d3000l3xj3w4zm611l
cmpw7u75d0025js04vx1cwwnb	คั่วเข้ม	0.00	cmpw7u75d0023js04vzqzu6el	cmpraghfn00093xj3teu0s9ye
cmpw7u75d0026js04hpqrleid	ไม่หวาน 0%	0.00	cmpw7u75d0023js04vzqzu6el	cmprak1wr000d3xj3791vuavv
cmpw7u75d0029js047onududs	คั่วเข้ม	0.00	cmpw7u75d0027js04zfuujnku	cmpraghfn00093xj3teu0s9ye
cmpw7u75d002ajs04qxftorif	หวานน้อย 50%	0.00	cmpw7u75d0027js04zfuujnku	cmprak1wr000e3xj3e60lzs1w
cmpw7u75d002bjs04sdg4m20l	เย็น	0.00	cmpw7u75d0027js04zfuujnku	cmpran7d3000l3xj3w4zm611l
cmpw7u75d002ejs04sonte2el	หวานปกติ 100%	0.00	cmpw7u75d002cjs04a0vk5ab4	cmprak1ws000f3xj35gi3varl
cmpw7u75d002fjs04rm37sa3q	เย็น	0.00	cmpw7u75d002cjs04a0vk5ab4	cmpran7d3000l3xj3w4zm611l
cmpw7u75d002ijs04lwm211mt	หวานปกติ 100%	0.00	cmpw7u75d002gjs042rik6vnt	cmprak1ws000f3xj35gi3varl
cmpw7u75d002ljs04i8u0xzlq	หวานน้อย 50%	0.00	cmpw7u75d002jjs043zlvugrl	cmprak1wr000e3xj3e60lzs1w
cmpw7u75d002ojs04097dl5di	ไม่หวาน 0%	0.00	cmpw7u75d002mjs0411r70a32	cmprak1wr000d3xj3791vuavv
cmpw7u75d002rjs04kop8z3qg	คั่วเข้ม	0.00	cmpw7u75d002pjs04jrtro6it	cmpraghfn00093xj3teu0s9ye
cmpw7wuk2002zjs04nl5o1tz6	หวานน้อย 50%	0.00	cmpw7wuk2002xjs04wxge3jcy	cmprak1wr000e3xj3e60lzs1w
cmpw7wuk20032js0429j4cea6	หวานปกติ 100%	0.00	cmpw7wuk20030js0415k1r4ed	cmprak1ws000f3xj35gi3varl
cmpw7wuk20035js04fm15m8k2	หวานน้อย 50%	0.00	cmpw7wuk20033js04cen3l23x	cmprak1wr000e3xj3e60lzs1w
cmpw7wuk20036js04hn7vpim2	เย็น	0.00	cmpw7wuk20033js04cen3l23x	cmpran7d3000l3xj3w4zm611l
cmpw7yf7n003gjs04r40106vu	หวานปกติ 100%	0.00	cmpw7yf7n003ejs04yxmc8mhm	cmprak1ws000f3xj35gi3varl
cmpw7yf7n003hjs04cfx1lwo6	เย็น	0.00	cmpw7yf7n003ejs04yxmc8mhm	cmpran7d3000l3xj3w4zm611l
cmpw82lzi0005l40400x8efjk	หวานปกติ 100%	0.00	cmpw82lzi0003l404xqzh41u7	cmprak1ws000f3xj35gi3varl
cmpw82lzi0006l404wrt61e55	เย็น	0.00	cmpw82lzi0003l404xqzh41u7	cmpran7d3000l3xj3w4zm611l
cmpw82lzi0009l404vizardmb	คั่วเข้ม	0.00	cmpw82lzi0007l404xz43xuia	cmpraghfn00093xj3teu0s9ye
cmpw82lzi000al404qscukwcg	หวานน้อย 50%	0.00	cmpw82lzi0007l404xz43xuia	cmprak1wr000e3xj3e60lzs1w
cmpw82lzi000bl404vo2ttghm	เย็น	0.00	cmpw82lzi0007l404xz43xuia	cmpran7d3000l3xj3w4zm611l
cmpw82lzi000el404zof1ixhm	คั่วเข้ม	0.00	cmpw82lzi000cl404yutx7vaa	cmpraghfn00093xj3teu0s9ye
cmpw82lzi000fl4040tnbd80j	หวานปกติ 100%	0.00	cmpw82lzi000cl404yutx7vaa	cmprak1ws000f3xj35gi3varl
cmpw82lzi000gl4044fe1pekw	เย็น	0.00	cmpw82lzi000cl404yutx7vaa	cmpran7d3000l3xj3w4zm611l
cmpy6et8w00053xoz1jvz9v84	ไม่หวาน 0%	0.00	cmpy6et8w00033xoz3poil5ir	cmprak1wr000d3xj3791vuavv
cmpy7dhzs00053xil675siaem	ไม่หวาน 0%	0.00	cmpy7dhzs00033xilb5fyocpr	cmprak1wr000d3xj3791vuavv
cmpy8rgim0004l504k8oo4f3p	หวานน้อย 50%	0.00	cmpy8rgim0002l504sps6da39	cmprak1wr000e3xj3e60lzs1w
cmpy8t5ah000dl504eun6gbf0	หวานน้อย 50%	0.00	cmpy8t5ah000bl504v9379crc	cmprak1wr000e3xj3e60lzs1w
cmpy8vdjy0004jo04708qf47y	หวานปกติ 100%	0.00	cmpy8vdjy0002jo042ivcyjyy	cmprak1ws000f3xj35gi3varl
cmpy8vdjy0005jo042jgt36wz	ลดช็อต	0.00	cmpy8vdjy0002jo042ivcyjyy	cmpralv7i000i3xj32dj8ylsa
cmpy8vdjy0008jo04d4odf9qj	หวานน้อย 50%	0.00	cmpy8vdjy0006jo04dfndqlv8	cmprak1wr000e3xj3e60lzs1w
cmpy8vdjy0009jo04tdzkycrw	เย็น	0.00	cmpy8vdjy0006jo04dfndqlv8	cmpran7d3000l3xj3w4zm611l
cmpy8wk4t0005kw0433oi8wr3	หวานน้อย 50%	0.00	cmpy8wk4t0003kw04wb3k3ey0	cmprak1wr000e3xj3e60lzs1w
cmpy8wk4t0006kw042gz71h96	เพิ่มช็อต	10.00	cmpy8wk4t0003kw04wb3k3ey0	cmpralv7i000j3xj3b1u9nwyo
cmpy8wk4t0007kw048e9e39uv	เย็น	0.00	cmpy8wk4t0003kw04wb3k3ey0	cmpran7d3000l3xj3w4zm611l
cmpy9bomr0004js049un808wf	หวานน้อย 50%	0.00	cmpy9bomr0002js04nnszm1e8	cmprak1wr000e3xj3e60lzs1w
cmpy9bomr0005js049j7ts34c	เพิ่มช็อต	10.00	cmpy9bomr0002js04nnszm1e8	cmpralv7i000j3xj3b1u9nwyo
cmpy9bomr0006js0417cj2o4u	เย็น	0.00	cmpy9bomr0002js04nnszm1e8	cmpran7d3000l3xj3w4zm611l
cmpya51gh0009jr04k813vsms	หวานน้อย 50%	0.00	cmpya51gh0007jr04dx7fuz8g	cmprak1wr000e3xj3e60lzs1w
cmpyn85rq0004jo04mycedjpq	คั่วเข้ม	0.00	cmpyn85rp0002jo04yar6fixb	cmpraghfn00093xj3teu0s9ye
cmpyn85rq0005jo047ldlve09	แยกน้ำแข็ง	0.00	cmpyn85rp0002jo04yar6fixb	cmpraptea000o3xj3zfahd2f7
cmpyn85rq0008jo04yf9nxxae	หวานปกติ 100%	0.00	cmpyn85rq0006jo040lbyy3sf	cmprak1ws000f3xj35gi3varl
cmpyn85rq0009jo04mpsct738	แยกน้ำแข็ง	0.00	cmpyn85rq0006jo040lbyy3sf	cmpraptea000o3xj3zfahd2f7
cmpyn85rq000cjo047xjejlod	ไม่หวาน 0%	0.00	cmpyn85rq000ajo04wepbsjnp	cmprak1wr000d3xj3791vuavv
cmpyn85rq000djo049idae0i3	แยกน้ำแข็ง	0.00	cmpyn85rq000ajo04wepbsjnp	cmpraptea000o3xj3zfahd2f7
cmpyo24f70005k305aasonpun	คั่วเข้ม	0.00	cmpyo24f70003k305hihscakl	cmpraghfn00093xj3teu0s9ye
cmpyo24f70006k3059xnspdiq	หวานน้อย 50%	0.00	cmpyo24f70003k305hihscakl	cmprak1wr000e3xj3e60lzs1w
cmpyo24f70007k3056n3pjkfq	เย็น	0.00	cmpyo24f70003k305hihscakl	cmpran7d3000l3xj3w4zm611l
cmpyo3c3f000fk3055mjl3zvu	คั่วกลาง	0.00	cmpyo3c3f000dk3050o8imkvn	cmpraghfn000a3xj3le4hn9nj
cmpyo3c3f000gk305ilnyudzw	ไม่หวาน 0%	0.00	cmpyo3c3f000dk3050o8imkvn	cmprak1wr000d3xj3791vuavv
cmpyo3c3g000jk305dr6si8fu	คั่วอ่อน	0.00	cmpyo3c3f000hk305f45zcp7m	cmpraghfn000b3xj33nmkm7g2
cmpyo3c3g000kk3056qx97ay8	หวานน้อย 50%	0.00	cmpyo3c3f000hk305f45zcp7m	cmprak1wr000e3xj3e60lzs1w
cmpyo5o8m000rk3055m9q9c7m	คั่วเข้ม	0.00	cmpyo5o8m000pk3056m5ovl9z	cmpraghfn00093xj3teu0s9ye
cmpyo5o8m000sk3055s6meoap	ไม่หวาน 0%	0.00	cmpyo5o8m000pk3056m5ovl9z	cmprak1wr000d3xj3791vuavv
cmpyo5o8m000tk305idhk1ne5	เย็น	0.00	cmpyo5o8m000pk3056m5ovl9z	cmpran7d3000l3xj3w4zm611l
cmpyo8l420005l7049y30heyk	คั่วเข้ม	0.00	cmpyo8l420003l7048to7kczd	cmpraghfn00093xj3teu0s9ye
cmpyo8l420006l7044otesov9	หวานปกติ 100%	0.00	cmpyo8l420003l7048to7kczd	cmprak1ws000f3xj35gi3varl
cmpyo8l420007l7043dpu0n5k	เย็น	0.00	cmpyo8l420003l7048to7kczd	cmpran7d3000l3xj3w4zm611l
cmpyos7o4000fl704kmasy76p	คั่วกลาง	0.00	cmpyos7o4000dl7047qsvo16e	cmpraghfn000a3xj3le4hn9nj
cmpyos7o4000gl704k5gtpwyn	ไม่หวาน 0%	0.00	cmpyos7o4000dl7047qsvo16e	cmprak1wr000d3xj3791vuavv
cmpyov4k20004ju04om6v50ps	คั่วเข้ม	0.00	cmpyov4k20002ju047tsszw3l	cmpraghfn00093xj3teu0s9ye
cmpyov4k20005ju04q42ys6sm	แยกน้ำแข็ง	0.00	cmpyov4k20002ju047tsszw3l	cmpraptea000o3xj3zfahd2f7
cmpyov4k20008ju04iymaq9ig	คั่วกลาง	0.00	cmpyov4k20006ju0404q0r2zt	cmpraghfn000a3xj3le4hn9nj
cmpyov4k20009ju04esf643c6	หวานปกติ 100%	0.00	cmpyov4k20006ju0404q0r2zt	cmprak1ws000f3xj35gi3varl
cmpyov4k2000aju0498a9n9la	เย็น	0.00	cmpyov4k20006ju0404q0r2zt	cmpran7d3000l3xj3w4zm611l
cmpypdxlc000ol704re8blaff	ไม่หวาน 0%	0.00	cmpypdxlc000ml704b24436ra	cmprak1wr000d3xj3791vuavv
cmpypdxlc000pl704v25wss1w	เย็น	0.00	cmpypdxlc000ml704b24436ra	cmpran7d3000l3xj3w4zm611l
cmpypoacr0005jp04telwsbke	หวานปกติ 100%	0.00	cmpypoacr0003jp04knb9f2f6	cmprak1ws000f3xj35gi3varl
cmpypoacr0006jp0420jhimr0	เย็น	0.00	cmpypoacr0003jp04knb9f2f6	cmpran7d3000l3xj3w4zm611l
cmpypw91f000xl70454txemwq	คั่วเข้ม	0.00	cmpypw91f000vl7048g8allsr	cmpraghfn00093xj3teu0s9ye
cmpypw91f000yl7043l3bbdf0	ไม่หวาน 0%	0.00	cmpypw91f000vl7048g8allsr	cmprak1wr000d3xj3791vuavv
cmpyqb4gh0017l704z9us7zhe	หวานปกติ 100%	0.00	cmpyqb4gh0015l704exmipkim	cmprak1ws000f3xj35gi3varl
cmpyqb4gh0018l704lo9zl3c2	เย็น	0.00	cmpyqb4gh0015l704exmipkim	cmpran7d3000l3xj3w4zm611l
cmpyqtxgz000fjp04vy057236	หวานน้อย 50%	0.00	cmpyqtxgz000djp04mh30da2x	cmprak1wr000e3xj3e60lzs1w
cmpyqtxgz000ijp04ifdekt3y	หวานปกติ 100%	0.00	cmpyqtxgz000gjp045l40eb6e	cmprak1ws000f3xj35gi3varl
cmpyqtxgz000jjp04bnu7g0kz	เย็น	0.00	cmpyqtxgz000gjp045l40eb6e	cmpran7d3000l3xj3w4zm611l
cmpyqzle8001gl704myg5n4zp	คั่วกลาง	0.00	cmpyqzle8001el704rl1l86ie	cmpraghfn000a3xj3le4hn9nj
cmpyr4lyz000rjp04mai7oatr	ไม่หวาน 0%	0.00	cmpyr4lyz000pjp04loheho5y	cmprak1wr000d3xj3791vuavv
cmpyrbegh001ol7042qe0bnkv	หวานน้อย 50%	0.00	cmpyrbegh001ml704yhgpheqq	cmprak1wr000e3xj3e60lzs1w
cmpyrbegh001pl704zrjrqvlr	เย็น	0.00	cmpyrbegh001ml704yhgpheqq	cmpran7d3000l3xj3w4zm611l
cmpyrcbrw001xl704frj95m4a	คั่วกลาง	0.00	cmpyrcbrw001vl7040hiaet9d	cmpraghfn000a3xj3le4hn9nj
cmpyrcbrw001yl704tpznkpqe	แยกน้ำแข็ง	0.00	cmpyrcbrw001vl7040hiaet9d	cmpraptea000o3xj3zfahd2f7
cmpyrgxvn000zjp045qiejbj5	หวานปกติ 100%	0.00	cmpyrgxvn000xjp04xl8lco5f	cmprak1ws000f3xj35gi3varl
cmpyrgxvn0010jp04d6mjq1jq	เย็น	0.00	cmpyrgxvn000xjp04xl8lco5f	cmpran7d3000l3xj3w4zm611l
cmpyrlxmq0018jp04him5kd8c	คั่วเข้ม	0.00	cmpyrlxmq0016jp047tejmw7i	cmpraghfn00093xj3teu0s9ye
cmpyrlxmq0019jp04m96zltsr	ไม่หวาน 0%	0.00	cmpyrlxmq0016jp047tejmw7i	cmprak1wr000d3xj3791vuavv
cmpyrs9ta001hjp04r0lsf2ls	คั่วอ่อน	0.00	cmpyrs9ta001fjp04ef5brz2r	cmpraghfn000b3xj33nmkm7g2
cmpyrwc2j0026l704nu05ibaz	หวานปกติ 100%	0.00	cmpyrwc2j0024l70482nanxnd	cmprak1ws000f3xj35gi3varl
cmpyrwtfj002el70425i4wtep	หวานน้อย 50%	0.00	cmpyrwtfj002cl704txhi01se	cmprak1wr000e3xj3e60lzs1w
cmpyrwtfj002fl7043plk8nzo	เย็น	0.00	cmpyrwtfj002cl704txhi01se	cmpran7d3000l3xj3w4zm611l
cmpyrycrd002nl704ntioo2ov	หวานน้อย 50%	0.00	cmpyrycrd002ll7044m5sy2gf	cmprak1wr000e3xj3e60lzs1w
cmpyrycrd002ol704xmiu60wv	เย็น	0.00	cmpyrycrd002ll7044m5sy2gf	cmpran7d3000l3xj3w4zm611l
cmpyrycrd002rl704sv2x94hu	หวานปกติ 100%	0.00	cmpyrycrd002pl704kqviv14h	cmprak1ws000f3xj35gi3varl
cmpyrycrd002sl704p0ndyl4d	เย็น	0.00	cmpyrycrd002pl704kqviv14h	cmpran7d3000l3xj3w4zm611l
cmpys032k001pjp042u6p32tt	หวานปกติ 100%	0.00	cmpys032k001njp04x92fkyqk	cmprak1ws000f3xj35gi3varl
cmpys032k001qjp04xotujq7e	เย็น	0.00	cmpys032k001njp04x92fkyqk	cmpran7d3000l3xj3w4zm611l
cmpys7hzy001yjp04k8vnzlz9	หวานปกติ 100%	0.00	cmpys7hzy001wjp048keyo24k	cmprak1ws000f3xj35gi3varl
cmpysbcsg0026jp04vlulicxf	คั่วกลาง	0.00	cmpysbcsg0024jp04hc5suy64	cmpraghfn000a3xj3le4hn9nj
cmpysnmna002ejp045a37vlv4	ไม่หวาน 0%	0.00	cmpysnmna002cjp04cpb07hrs	cmprak1wr000d3xj3791vuavv
cmpyteetj0004l104z54cwe6u	คั่วกลาง	0.00	cmpyteetj0002l1049xi0n15g	cmpraghfn000a3xj3le4hn9nj
cmpyteetj0005l104hckdgaky	หวานน้อย 50%	0.00	cmpyteetj0002l1049xi0n15g	cmprak1wr000e3xj3e60lzs1w
cmpyu5ney0004le04wgzmhrrl	หวานปกติ 100%	0.00	cmpyu5ney0002le04afw1xzwz	cmprak1ws000f3xj35gi3varl
cmpyu5ney0005le04qn5bnsoy	เย็น	0.00	cmpyu5ney0002le04afw1xzwz	cmpran7d3000l3xj3w4zm611l
cmpz5e57p0005jl04kg0yhcnv	หวานปกติ 100%	0.00	cmpz5e57p0003jl04s1rzwwi5	cmprak1ws000f3xj35gi3varl
cmpz5e57p0006jl04xkq76whf	เย็น	0.00	cmpz5e57p0003jl04s1rzwwi5	cmpran7d3000l3xj3w4zm611l
cmpzn0ahk00053xmgmvpfyl4j	หวานน้อย 50%	0.00	cmpzn0ahk00033xmgbvxl857i	cmprak1wr000e3xj3e60lzs1w
cmpzn18t00006l80420gy27wn	คั่วเข้ม	0.00	cmpzn18t00004l804h8y1nmj1	cmpraghfn00093xj3teu0s9ye
cmpzn18t00007l804stnxgxd7	ไม่หวาน 0%	0.00	cmpzn18t00004l804h8y1nmj1	cmprak1wr000d3xj3791vuavv
cmpzn18t00008l804lo1jw46j	แยกน้ำแข็ง	0.00	cmpzn18t00004l804h8y1nmj1	cmpraptea000o3xj3zfahd2f7
cmpzn18t0000bl804u4o30lnw	คั่วกลาง	0.00	cmpzn18t00009l8042glg7ahw	cmpraghfn000a3xj3le4hn9nj
cmpzn18t0000cl8047tcrx6fk	ไม่หวาน 0%	0.00	cmpzn18t00009l8042glg7ahw	cmprak1wr000d3xj3791vuavv
cmpzn18t0000dl8046i9t3j8m	แยกน้ำแข็ง	0.00	cmpzn18t00009l8042glg7ahw	cmpraptea000o3xj3zfahd2f7
cmpzn18t0000gl804j4ufk929	คั่วกลาง	0.00	cmpzn18t0000el804f6cg2dll	cmpraghfn000a3xj3le4hn9nj
cmpzn18t0000hl804olw8nsy8	หวานน้อย 50%	0.00	cmpzn18t0000el804f6cg2dll	cmprak1wr000e3xj3e60lzs1w
cmpzn18t0000il804kxyavfus	แยกน้ำแข็ง	0.00	cmpzn18t0000el804f6cg2dll	cmpraptea000o3xj3zfahd2f7
cmpzn18t0000ll804bfom5e6n	คั่วอ่อน	0.00	cmpzn18t0000jl8049md5pw0i	cmpraghfn000b3xj33nmkm7g2
cmpzn18t0000ml804wyavil8q	ไม่หวาน 0%	0.00	cmpzn18t0000jl8049md5pw0i	cmprak1wr000d3xj3791vuavv
cmpzn18t0000nl804mnjkx81a	แยกน้ำแข็ง	0.00	cmpzn18t0000jl8049md5pw0i	cmpraptea000o3xj3zfahd2f7
cmpzn18t0000ql804x1xtpgic	หวานน้อย 50%	0.00	cmpzn18t0000ol804z6acpnyq	cmprak1wr000e3xj3e60lzs1w
cmpzn18t0000rl804346ox1gp	เย็น	0.00	cmpzn18t0000ol804z6acpnyq	cmpran7d3000l3xj3w4zm611l
cmpzn18t0000sl804zd61erin	แยกน้ำแข็ง	0.00	cmpzn18t0000ol804z6acpnyq	cmpraptea000o3xj3zfahd2f7
cmpzogna500083xom7mo0zqen	คั่วเข้ม	0.00	cmpzogna500063xomqt790dli	cmpraghfn00093xj3teu0s9ye
cmpzogna500093xom4jijfu6t	หวานน้อย 50%	0.00	cmpzogna500063xomqt790dli	cmprak1wr000e3xj3e60lzs1w
cmpzpakgw000f3xomgtggwgew	ไม่หวาน 0%	0.00	cmpzpakgw000d3xomnw5dg5jv	cmprak1wr000d3xj3791vuavv
cmpzpklg2000n3xom26v5pyjn	ไม่หวาน 0%	0.00	cmpzpklg2000l3xoml7t9c7j6	cmprak1wr000d3xj3791vuavv
cmpzpklg2000q3xomo131pzrk	คั่วเข้ม	0.00	cmpzpklg2000o3xom3lre4527	cmpraghfn00093xj3teu0s9ye
cmpzpklg2000r3xomyzkx0xkj	หวานน้อย 50%	0.00	cmpzpklg2000o3xom3lre4527	cmprak1wr000e3xj3e60lzs1w
cmq01tb4k0004jl044gtei01h	คั่วเข้ม	0.00	cmq01tb4k0002jl04se86clby	cmpraghfn00093xj3teu0s9ye
cmq01tb4k0005jl04drypd998	หวานปกติ 100%	0.00	cmq01tb4k0002jl04se86clby	cmprak1ws000f3xj35gi3varl
cmq01tb4k0006jl046l0j72dl	เย็น	0.00	cmq01tb4k0002jl04se86clby	cmpran7d3000l3xj3w4zm611l
cmq01tb4k0007jl04wzmj9j42	แยกน้ำแข็ง	0.00	cmq01tb4k0002jl04se86clby	cmpraptea000o3xj3zfahd2f7
cmq01tb4k000ajl04eru91fuz	คั่วเข้ม	0.00	cmq01tb4k0008jl04le832hsa	cmpraghfn00093xj3teu0s9ye
cmq01tb4k000bjl04ii2u7pfg	แยกน้ำแข็ง	0.00	cmq01tb4k0008jl04le832hsa	cmpraptea000o3xj3zfahd2f7
cmq01tb4k000ejl04i3p7crhn	หวานน้อย 50%	0.00	cmq01tb4k000cjl04eymlhawf	cmprak1wr000e3xj3e60lzs1w
cmq01tb4k000fjl04tgvz7fg1	แยกน้ำแข็ง	0.00	cmq01tb4k000cjl04eymlhawf	cmpraptea000o3xj3zfahd2f7
cmq033frk0004jr04uaqmzyq8	ไม่หวาน 0%	0.00	cmq033frk0002jr040edvhwcr	cmprak1wr000d3xj3791vuavv
cmq033frk0005jr04xcplb8gc	แยกน้ำแข็ง	0.00	cmq033frk0002jr040edvhwcr	cmpraptea000o3xj3zfahd2f7
cmq03iklh000djm04rftqrcwb	คั่วเข้ม	0.00	cmq03iklh000bjm0419lofrsc	cmpraghfn00093xj3teu0s9ye
cmq03iklh000ejm0479hi021h	หวานน้อย 50%	0.00	cmq03iklh000bjm0419lofrsc	cmprak1wr000e3xj3e60lzs1w
cmq03iklh000fjm044hxgiavd	เย็น	0.00	cmq03iklh000bjm0419lofrsc	cmpran7d3000l3xj3w4zm611l
cmq03mjdo0005js04h5l4wduu	หวานปกติ 100%	0.00	cmq03mjdo0003js04owfd21iw	cmprak1ws000f3xj35gi3varl
cmq03mjdo0006js04jnlfsd6v	เย็น	0.00	cmq03mjdo0003js04owfd21iw	cmpran7d3000l3xj3w4zm611l
cmq03wruo000bjs04dvz6e4it	หวานน้อย 50%	0.00	cmq03wruo0009js04n1vjh2m7	cmprak1wr000e3xj3e60lzs1w
cmq03wruo000cjs04fdcxg4mj	เย็น	0.00	cmq03wruo0009js04n1vjh2m7	cmpran7d3000l3xj3w4zm611l
cmq03wruo000fjs04n8xfadb9	คั่วเข้ม	0.00	cmq03wruo000djs04na7ubbxe	cmpraghfn00093xj3teu0s9ye
cmq03wruo000gjs04w1eb41ac	ไม่หวาน 0%	0.00	cmq03wruo000djs04na7ubbxe	cmprak1wr000d3xj3791vuavv
cmq03wruo000hjs046l9vpz3r	เย็น	0.00	cmq03wruo000djs04na7ubbxe	cmpran7d3000l3xj3w4zm611l
cmq04h8b80005ju04s393rw5x	หวานน้อย 50%	0.00	cmq04h8b70003ju04k661z3un	cmprak1wr000e3xj3e60lzs1w
cmq04h8b80006ju04ynkwgqro	เย็น	0.00	cmq04h8b70003ju04k661z3un	cmpran7d3000l3xj3w4zm611l
cmq05anbr0005l70498f2a4k0	คั่วกลาง	0.00	cmq05anbr0003l7046nw0svem	cmpraghfn000a3xj3le4hn9nj
cmq05anbr0006l704blbqyto6	ไม่หวาน 0%	0.00	cmq05anbr0003l7046nw0svem	cmprak1wr000d3xj3791vuavv
cmq05kjxf000dl70412229czm	หวานปกติ 100%	0.00	cmq05kjxf000bl70460etr54y	cmprak1ws000f3xj35gi3varl
cmq05kjxf000el704gu6cxozy	เย็น	0.00	cmq05kjxf000bl70460etr54y	cmpran7d3000l3xj3w4zm611l
cmq05kjxg000hl704rr6b50mh	หวานน้อย 50%	0.00	cmq05kjxf000fl7049dwo8pw3	cmprak1wr000e3xj3e60lzs1w
cmq05kjxg000il704aoi2kwg8	เย็น	0.00	cmq05kjxf000fl7049dwo8pw3	cmpran7d3000l3xj3w4zm611l
cmq05vhyr000ql7045hrotydu	หวานน้อย 50%	0.00	cmq05vhyr000ol7049rfr2ukf	cmprak1wr000e3xj3e60lzs1w
cmq05vhyr000rl704lc7r0j54	เย็น	0.00	cmq05vhyr000ol7049rfr2ukf	cmpran7d3000l3xj3w4zm611l
cmq05vhyr000ul704kbeo3w30	หวานน้อย 50%	0.00	cmq05vhyr000sl704kw82ehl1	cmprak1wr000e3xj3e60lzs1w
cmq0607ve0006lb042q1iqv3h	หวานน้อย 50%	0.00	cmq0607ve0004lb040pb6797v	cmprak1wr000e3xj3e60lzs1w
cmq0607ve0007lb04zkgzc48z	เย็น	0.00	cmq0607ve0004lb040pb6797v	cmpran7d3000l3xj3w4zm611l
cmq067se3000mlb04895p3i5k	หวานน้อย 50%	0.00	cmq067se3000klb04bb7ex6qb	cmprak1wr000e3xj3e60lzs1w
cmq067se4000nlb04v14sp7r5	เย็น	0.00	cmq067se3000klb04bb7ex6qb	cmpran7d3000l3xj3w4zm611l
cmq06hfeb0005jo04w0n8l1gx	คั่วกลาง	0.00	cmq06hfea0003jo04wk1e0iir	cmpraghfn000a3xj3le4hn9nj
cmq06hfeb0006jo04od9kpe1b	หวานน้อย 50%	0.00	cmq06hfea0003jo04wk1e0iir	cmprak1wr000e3xj3e60lzs1w
cmq06mcev000gjo04pnmsw2rh	คั่วอ่อน	0.00	cmq06mcev000ejo042vqhbnej	cmpraghfn000b3xj33nmkm7g2
cmq06mcev000hjo04dhxmbcay	ไม่หวาน 0%	0.00	cmq06mcev000ejo042vqhbnej	cmprak1wr000d3xj3791vuavv
cmq06mcev000ijo04mjgf0iww	แยกน้ำแข็ง	0.00	cmq06mcev000ejo042vqhbnej	cmpraptea000o3xj3zfahd2f7
cmq06py4l000qjo04zs1wxx4g	คั่วอ่อน	0.00	cmq06py4l000ojo049bygdgb8	cmpraghfn000b3xj33nmkm7g2
cmq06py4l000tjo045756vp1x	คั่วเข้ม	0.00	cmq06py4l000rjo04hsp2ss79	cmpraghfn00093xj3teu0s9ye
cmq06py4l000ujo04fdf8y4y2	ไม่หวาน 0%	0.00	cmq06py4l000rjo04hsp2ss79	cmprak1wr000d3xj3791vuavv
cmq06py4l000vjo04c2cx5xqp	แยกน้ำแข็ง	0.00	cmq06py4l000rjo04hsp2ss79	cmpraptea000o3xj3zfahd2f7
cmq06s9yk0011jo04mgg2ub37	คั่วเข้ม	0.00	cmq06s9yk000zjo04solwdpuv	cmpraghfn00093xj3teu0s9ye
cmq06vtv40004jr05nbzuauno	หวานปกติ 100%	0.00	cmq06vtv40002jr05acjd1pzu	cmprak1ws000f3xj35gi3varl
cmq0749p7000djr05ti66kmmg	คั่วเข้ม	0.00	cmq0749p7000bjr05xuww3fhe	cmpraghfn00093xj3teu0s9ye
cmq0749p7000ejr05815oakki	ไม่หวาน 0%	0.00	cmq0749p7000bjr05xuww3fhe	cmprak1wr000d3xj3791vuavv
cmq07bqty0017jo04v25nci46	หวานน้อย 50%	0.00	cmq07bqty0015jo044aa5xsl7	cmprak1wr000e3xj3e60lzs1w
cmq07bqty0018jo04eqyxb43y	เย็น	0.00	cmq07bqty0015jo044aa5xsl7	cmpran7d3000l3xj3w4zm611l
cmq07g3zc001ijo04au1wfr27	คั่วอ่อน	0.00	cmq07g3zc001gjo0447z3s8gn	cmpraghfn000b3xj33nmkm7g2
cmq07g3zc001jjo04ilgi5f4g	ไม่หวาน 0%	0.00	cmq07g3zc001gjo0447z3s8gn	cmprak1wr000d3xj3791vuavv
cmq07g3zc001kjo04av8hlxya	แยกน้ำแข็ง	0.00	cmq07g3zc001gjo0447z3s8gn	cmpraptea000o3xj3zfahd2f7
cmq07k7dh001sjo04zfzr7n0k	หวานน้อย 50%	0.00	cmq07k7dh001qjo04fr101f7g	cmprak1wr000e3xj3e60lzs1w
cmq07k7dh001tjo04tbfmeiyx	เย็น	0.00	cmq07k7dh001qjo04fr101f7g	cmpran7d3000l3xj3w4zm611l
cmq07rlws0023jo04jylx2yf6	คั่วกลาง	0.00	cmq07rlws0021jo04chsw6x89	cmpraghfn000a3xj3le4hn9nj
cmq07x6jn002bjo04veibq87f	คั่วเข้ม	0.00	cmq07x6jn0029jo04dnpdpuq2	cmpraghfn00093xj3teu0s9ye
cmq07x6jn002cjo04tgtss82w	ไม่หวาน 0%	0.00	cmq07x6jn0029jo04dnpdpuq2	cmprak1wr000d3xj3791vuavv
cmq0ba49w0005jr045hw591bl	คั่วกลาง	0.00	cmq0ba49w0003jr04ug7fpu21	cmpraghfn000a3xj3le4hn9nj
cmq0ba49w0006jr046l2yszsh	หวานน้อย 50%	0.00	cmq0ba49w0003jr04ug7fpu21	cmprak1wr000e3xj3e60lzs1w
cmq0by3100005jl04bgg9zl8k	คั่วเข้ม	0.00	cmq0by3100003jl0492lfevjm	cmpraghfn00093xj3teu0s9ye
cmq0by3100006jl0406cucdn9	ไม่หวาน 0%	0.00	cmq0by3100003jl0492lfevjm	cmprak1wr000d3xj3791vuavv
cmq0d7qmy0005ju04vsxya0fm	หวานปกติ 100%	0.00	cmq0d7qmy0003ju04qnqf3skc	cmprak1ws000f3xj35gi3varl
cmq0d7qmy0006ju048p098knz	เย็น	0.00	cmq0d7qmy0003ju04qnqf3skc	cmpran7d3000l3xj3w4zm611l
cmq0d7qmy0009ju0480po2e53	หวานปกติ 100%	0.00	cmq0d7qmy0007ju046kgh1ryl	cmprak1ws000f3xj35gi3varl
cmq0d7qmy000aju0460xaehil	เย็น	0.00	cmq0d7qmy0007ju046kgh1ryl	cmpran7d3000l3xj3w4zm611l
cmq0ha3nd0005ie04pqrhbthy	หวานน้อย 50%	0.00	cmq0ha3nc0003ie04vd5n7i5l	cmprak1wr000e3xj3e60lzs1w
cmq0ha3nd0006ie04z4itvnk7	เย็น	0.00	cmq0ha3nc0003ie04vd5n7i5l	cmpran7d3000l3xj3w4zm611l
cmq0hb97i000eie048pdvq6uw	หวานน้อย 50%	0.00	cmq0hb97i000cie04on61e33p	cmprak1wr000e3xj3e60lzs1w
cmq0hb97i000fie04ut2vrzzi	เย็น	0.00	cmq0hb97i000cie04on61e33p	cmpran7d3000l3xj3w4zm611l
cmq0htz860005i304wmo2xj8o	หวานน้อย 50%	0.00	cmq0htz860003i304w75fqyh0	cmprak1wr000e3xj3e60lzs1w
cmq0htz860006i304przdm5ix	เย็น	0.00	cmq0htz860003i304w75fqyh0	cmpran7d3000l3xj3w4zm611l
cmq0htz860009i304eboe8cf3	หวานน้อย 50%	0.00	cmq0htz860007i3047uxtdz6k	cmprak1wr000e3xj3e60lzs1w
cmq0i1ep70005jp04jxsny2an	คั่วเข้ม	0.00	cmq0i1ep70003jp04nbgpihet	cmpraghfn00093xj3teu0s9ye
cmq0i1ep70006jp0476z22xjy	หวานน้อย 50%	0.00	cmq0i1ep70003jp04nbgpihet	cmprak1wr000e3xj3e60lzs1w
cmq0i1ep70007jp04ixcr4jon	เย็น	0.00	cmq0i1ep70003jp04nbgpihet	cmpran7d3000l3xj3w4zm611l
cmq0igi48000hjp04cdf48usc	ไม่หวาน 0%	0.00	cmq0igi48000fjp048n4rsvgi	cmprak1wr000d3xj3791vuavv
cmq0igi48000ijp04527arv36	เย็น	0.00	cmq0igi48000fjp048n4rsvgi	cmpran7d3000l3xj3w4zm611l
cmq0jchhy0005lg04qz4ynf7a	คั่วเข้ม	0.00	cmq0jchhy0003lg04aflwbklr	cmpraghfn00093xj3teu0s9ye
cmq0jchhy0006lg04zgj4b4u9	ไม่หวาน 0%	0.00	cmq0jchhy0003lg04aflwbklr	cmprak1wr000d3xj3791vuavv
cmq114w100004jm04kld9xg7z	ไม่หวาน 0%	0.00	cmq114w100002jm04b25jpy9e	cmprak1wr000d3xj3791vuavv
cmq114w100005jm040d73xas3	แยกน้ำแข็ง	0.00	cmq114w100002jm04b25jpy9e	cmpraptea000o3xj3zfahd2f7
cmq114w100008jm04cz569ndw	คั่วกลาง	0.00	cmq114w100006jm04r8wehcoh	cmpraghfn000a3xj3le4hn9nj
cmq114w100009jm04tlr3te0m	ไม่หวาน 0%	0.00	cmq114w100006jm04r8wehcoh	cmprak1wr000d3xj3791vuavv
cmq114w10000ajm04385znx8x	แยกน้ำแข็ง	0.00	cmq114w100006jm04r8wehcoh	cmpraptea000o3xj3zfahd2f7
cmq1hwe640004kv04uiqd3hes	หวานปกติ 100%	0.00	cmq1hwe640002kv046r50d3fx	cmprak1ws000f3xj35gi3varl
cmq1hwe640005kv041ry1r6ed	เย็น	0.00	cmq1hwe640002kv046r50d3fx	cmpran7d3000l3xj3w4zm611l
cmq1hwe640008kv04a02565g3	หวานปกติ 100%	0.00	cmq1hwe640006kv043byvl4i3	cmprak1ws000f3xj35gi3varl
cmq1hwe640009kv04rybdmo9s	เย็น	0.00	cmq1hwe640006kv043byvl4i3	cmpran7d3000l3xj3w4zm611l
cmq1irpg10004js048g3d5cg0	คั่วเข้ม	0.00	cmq1irpg10002js048u5q1g9w	cmpraghfn00093xj3teu0s9ye
cmq1j7ldf0005ld0416ns180b	คั่วเข้ม	0.00	cmq1j7ldf0003ld0491swac80	cmpraghfn00093xj3teu0s9ye
cmq1j7ldf0006ld04vm5fobzd	หวานปกติ 100%	0.00	cmq1j7ldf0003ld0491swac80	cmprak1ws000f3xj35gi3varl
cmq1j7ldf0007ld044q5bhwt7	เย็น	0.00	cmq1j7ldf0003ld0491swac80	cmpran7d3000l3xj3w4zm611l
cmq1j8ao1000dld04rix49txc	คั่วเข้ม	0.00	cmq1j8ao1000bld04dk2xeyxz	cmpraghfn00093xj3teu0s9ye
cmq1j8ao1000eld040yo4pnzi	ไม่หวาน 0%	0.00	cmq1j8ao1000bld04dk2xeyxz	cmprak1wr000d3xj3791vuavv
cmq1j8vfb000kld048zf3xv9t	หวานปกติ 100%	0.00	cmq1j8vfb000ild04wjgs155l	cmprak1ws000f3xj35gi3varl
cmq1j8vfb000lld0439opvepy	เย็น	0.00	cmq1j8vfb000ild04wjgs155l	cmpran7d3000l3xj3w4zm611l
cmq1j9ert000qld04qvde4kv8	คั่วเข้ม	0.00	cmq1j9ert000old04zgs3qaai	cmpraghfn00093xj3teu0s9ye
cmq1j9ert000rld04owjkjqki	หวานน้อย 50%	0.00	cmq1j9ert000old04zgs3qaai	cmprak1wr000e3xj3e60lzs1w
cmq1j9ert000sld044plauf58	เย็น	0.00	cmq1j9ert000old04zgs3qaai	cmpran7d3000l3xj3w4zm611l
cmq1j9uqy0011ld04bi3dddc1	คั่วเข้ม	0.00	cmq1j9uqy000zld048b7qzhao	cmpraghfn00093xj3teu0s9ye
cmq1j9uqy0012ld04xfkump9n	หวานน้อย 50%	0.00	cmq1j9uqy000zld048b7qzhao	cmprak1wr000e3xj3e60lzs1w
cmq1j9uqy0013ld046fnrhfvp	เย็น	0.00	cmq1j9uqy000zld048b7qzhao	cmpran7d3000l3xj3w4zm611l
cmq1jnwq40004le04l66xydp6	คั่วเข้ม	0.00	cmq1jnwq30002le04l0lubatj	cmpraghfn00093xj3teu0s9ye
cmq1jso1p0004l404exuvzgfh	ไม่หวาน 0%	0.00	cmq1jso1p0002l4048eee2z5l	cmprak1wr000d3xj3791vuavv
cmq1jso1p0005l40405lfj1iw	เย็น	0.00	cmq1jso1p0002l4048eee2z5l	cmpran7d3000l3xj3w4zm611l
cmq1jso1p0006l404psnxopkg	แยกน้ำแข็ง	0.00	cmq1jso1p0002l4048eee2z5l	cmpraptea000o3xj3zfahd2f7
cmq1kht9f000gl404u5pvhjbt	คั่วเข้ม	0.00	cmq1kht9f000el404godth3gh	cmpraghfn00093xj3teu0s9ye
cmq1kht9f000jl404sts9ammp	คั่วเข้ม	0.00	cmq1kht9f000hl404pq5ok58e	cmpraghfn00093xj3teu0s9ye
cmq1kht9f000kl404m6eae5mv	หวานปกติ 100%	0.00	cmq1kht9f000hl404pq5ok58e	cmprak1ws000f3xj35gi3varl
cmq1kht9f000ll404d9np6niy	เย็น	0.00	cmq1kht9f000hl404pq5ok58e	cmpran7d3000l3xj3w4zm611l
cmq1kl0fx000ul404izaecypj	คั่วเข้ม	0.00	cmq1kl0fw000sl404dumtswg0	cmpraghfn00093xj3teu0s9ye
cmq1kl0fx000vl4047hq9aekz	ไม่หวาน 0%	0.00	cmq1kl0fw000sl404dumtswg0	cmprak1wr000d3xj3791vuavv
cmq1kl0fx000yl4043a2lzmjr	หวานปกติ 100%	0.00	cmq1kl0fx000wl404762kpa7r	cmprak1ws000f3xj35gi3varl
cmq1kyktl0014l4041p6wblka	คั่วเข้ม	0.00	cmq1kyktk0012l404orhdzrvd	cmpraghfn00093xj3teu0s9ye
cmq1kyktl0015l404iqpv3uj6	ไม่หวาน 0%	0.00	cmq1kyktk0012l404orhdzrvd	cmprak1wr000d3xj3791vuavv
cmq1lea480005l204pp4t6tt3	หวานน้อย 50%	0.00	cmq1lea480003l2047ogthylz	cmprak1wr000e3xj3e60lzs1w
cmq1lea480006l2041jqm6qh2	เย็น	0.00	cmq1lea480003l2047ogthylz	cmpran7d3000l3xj3w4zm611l
cmq1lq2qp001fl404x158nnjt	หวานปกติ 100%	0.00	cmq1lq2qo001dl404noy9zfmf	cmprak1ws000f3xj35gi3varl
cmq1lq2qp001gl404wvc2306z	เย็น	0.00	cmq1lq2qo001dl404noy9zfmf	cmpran7d3000l3xj3w4zm611l
cmq1lvzx6000el204y4ft96ic	หวานปกติ 100%	0.00	cmq1lvzx6000cl204mn0jadyp	cmprak1ws000f3xj35gi3varl
cmq1lvzx6000fl204x739k4s0	เย็น	0.00	cmq1lvzx6000cl204mn0jadyp	cmpran7d3000l3xj3w4zm611l
cmq1m42o4000nl204b493iwdu	คั่วอ่อน	0.00	cmq1m42o4000ll204mzf4iz20	cmpraghfn000b3xj33nmkm7g2
cmq1m42o4000ql204w1t5ikri	คั่วเข้ม	0.00	cmq1m42o4000ol2045rzhw37v	cmpraghfn00093xj3teu0s9ye
cmq1m42o4000rl204ct2mbb8q	ไม่หวาน 0%	0.00	cmq1m42o4000ol2045rzhw37v	cmprak1wr000d3xj3791vuavv
cmq1m42o4000sl204i8pf73ih	แยกน้ำแข็ง	0.00	cmq1m42o4000ol2045rzhw37v	cmpraptea000o3xj3zfahd2f7
cmq1m42o4000vl204b2p0zf22	หวานปกติ 100%	0.00	cmq1m42o4000tl204uptwtuys	cmprak1ws000f3xj35gi3varl
cmq1m59t80020l404vsm9i4h2	คั่วเข้ม	0.00	cmq1m59t8001yl404pf6jwhuy	cmpraghfn00093xj3teu0s9ye
cmq1m59t80021l404g5occwok	ไม่หวาน 0%	0.00	cmq1m59t8001yl404pf6jwhuy	cmprak1wr000d3xj3791vuavv
cmq7gxwrn000yl404mv6n3etx	เย็น	0.00	cmq7gxwrn000vl404rpiyxurv	cmpran7d3000l3xj3w4zm611l
cmq1misa60013l204lhy8wnoi	หวานปกติ 100%	0.00	cmq1misa60011l204xya6tdb3	cmprak1ws000f3xj35gi3varl
cmq1misa60014l204d92ivhm8	เย็น	0.00	cmq1misa60011l204xya6tdb3	cmpran7d3000l3xj3w4zm611l
cmq1mn2u9001el204clo4mi19	คั่วเข้ม	0.00	cmq1mn2u8001cl204h9czu6st	cmpraghfn00093xj3teu0s9ye
cmq1mpf8r0028l404j3s8ejh4	หวานน้อย 50%	0.00	cmq1mpf8r0026l404dygmxg3d	cmprak1wr000e3xj3e60lzs1w
cmq1mpf8r0029l404whkxpzq8	เย็น	0.00	cmq1mpf8r0026l404dygmxg3d	cmpran7d3000l3xj3w4zm611l
cmq1mpf8s002cl404zably2z2	หวานปกติ 100%	0.00	cmq1mpf8r002al404fgyykxy3	cmprak1ws000f3xj35gi3varl
cmq1mpf8s002dl4040enh4ba5	เย็น	0.00	cmq1mpf8r002al404fgyykxy3	cmpran7d3000l3xj3w4zm611l
cmq1mui5z001ml204f66bryna	คั่วเข้ม	0.00	cmq1mui5z001kl204kxqs86m4	cmpraghfn00093xj3teu0s9ye
cmq1mui5z001nl204r81zjtpm	ไม่หวาน 0%	0.00	cmq1mui5z001kl204kxqs86m4	cmprak1wr000d3xj3791vuavv
cmq1mui5z001ql204xseh712a	คั่วอ่อน	0.00	cmq1mui5z001ol204mtzuh9bf	cmpraghfn000b3xj33nmkm7g2
cmq1mui5z001rl2048d7fj2po	ไม่หวาน 0%	0.00	cmq1mui5z001ol204mtzuh9bf	cmprak1wr000d3xj3791vuavv
cmq1mv31j001xl204zm5cq3c6	หวานน้อย 50%	0.00	cmq1mv31j001vl204bpqko3af	cmprak1wr000e3xj3e60lzs1w
cmq1mv31j001yl2044b7pggli	เย็น	0.00	cmq1mv31j001vl204bpqko3af	cmpran7d3000l3xj3w4zm611l
cmq1n0lod0026l204k5fxsynw	หวานปกติ 100%	0.00	cmq1n0lod0024l2045ubivcg3	cmprak1ws000f3xj35gi3varl
cmq1n0lod0027l204baofz8sk	เย็น	0.00	cmq1n0lod0024l2045ubivcg3	cmpran7d3000l3xj3w4zm611l
cmq1n4m220007jo047cx7fwbg	คั่วเข้ม	0.00	cmq1n4m220005jo04qcqubt8n	cmpraghfn00093xj3teu0s9ye
cmq1n4m220008jo04xcgnzlhm	หวานน้อย 50%	0.00	cmq1n4m220005jo04qcqubt8n	cmprak1wr000e3xj3e60lzs1w
cmq1n4m220009jo04xsdriht9	เย็น	0.00	cmq1n4m220005jo04qcqubt8n	cmpran7d3000l3xj3w4zm611l
cmq1n86930005jq04ibr6lbax	คั่วเข้ม	0.00	cmq1n86930003jq040qdpx5ma	cmpraghfn00093xj3teu0s9ye
cmq1n86930006jq04q4pl7s2n	ไม่หวาน 0%	0.00	cmq1n86930003jq040qdpx5ma	cmprak1wr000d3xj3791vuavv
cmq1n86930007jq04ilr3s1z6	เย็น	0.00	cmq1n86930003jq040qdpx5ma	cmpran7d3000l3xj3w4zm611l
cmq1nwp670004jo04juqpll8t	หวานน้อย 50%	0.00	cmq1nwp670002jo04lrajiuv1	cmprak1wr000e3xj3e60lzs1w
cmq1nwp670005jo04zzw8uvm9	เย็น	0.00	cmq1nwp670002jo04lrajiuv1	cmpran7d3000l3xj3w4zm611l
cmq1nwp670008jo04p68r5cnv	คั่วกลาง	0.00	cmq1nwp670006jo04rdktph98	cmpraghfn000a3xj3le4hn9nj
cmq1nwp67000bjo04fcuog8ja	หวานปกติ 100%	0.00	cmq1nwp670009jo046e6v12a1	cmprak1ws000f3xj35gi3varl
cmq1nwp67000cjo0457iw1lps	เย็น	0.00	cmq1nwp670009jo046e6v12a1	cmpran7d3000l3xj3w4zm611l
cmq3wooeu0005l804grmkifzu	คั่วเข้ม	0.00	cmq3wooeu0003l804100i2v6a	cmpraghfn00093xj3teu0s9ye
cmq3wooeu0006l804o7rzsllp	ไม่หวาน 0%	0.00	cmq3wooeu0003l804100i2v6a	cmprak1wr000d3xj3791vuavv
cmq3wooeu0009l804zmwq3c1y	หวานน้อย 50%	0.00	cmq3wooeu0007l804va4l86iw	cmprak1wr000e3xj3e60lzs1w
cmq3wpg2n0005l204d93ykv96	หวานน้อย 50%	0.00	cmq3wpg2n0003l204rwedz68r	cmprak1wr000e3xj3e60lzs1w
cmq3wy7o1000bl2046y8ylixl	หวานน้อย 50%	0.00	cmq3wy7o10009l204tbwoyw1b	cmprak1wr000e3xj3e60lzs1w
cmq3wyfme000hl204u4dkl9nz	หวานปกติ 100%	0.00	cmq3wyfme000fl204vgxg58gr	cmprak1ws000f3xj35gi3varl
cmq3x00a80005kz043rg10s30	หวานปกติ 100%	0.00	cmq3x00a70003kz04wc2xltdf	cmprak1ws000f3xj35gi3varl
cmq3x337z000dkz04ytleioby	คั่วเข้ม	0.00	cmq3x337z000bkz043ckwi52i	cmpraghfn00093xj3teu0s9ye
cmq3x337z000ekz04883mch96	ไม่หวาน 0%	0.00	cmq3x337z000bkz043ckwi52i	cmprak1wr000d3xj3791vuavv
cmq3yelhs0005ky04p37826nh	หวานน้อย 50%	0.00	cmq3yelhs0003ky04a3kx1cwa	cmprak1wr000e3xj3e60lzs1w
cmq3yf3qi0005l704rf581lac	หวานปกติ 100%	0.00	cmq3yf3qi0003l704mb7w4d3q	cmprak1ws000f3xj35gi3varl
cmq3yqbr70004jl04v6q1z31u	ไม่หวาน 0%	0.00	cmq3yqbr70002jl04s8zb468p	cmprak1wr000d3xj3791vuavv
cmq3yvmtu000al704rcvfdonc	หวานปกติ 100%	0.00	cmq3yvmtu0008l704avz79gxz	cmprak1ws000f3xj35gi3varl
cmq4c2r220004jr04lzvzcix0	คั่วกลาง	0.00	cmq4c2r220002jr041lx860rn	cmpraghfn000a3xj3le4hn9nj
cmq4c2r220005jr04lcynx87j	ไม่หวาน 0%	0.00	cmq4c2r220002jr041lx860rn	cmprak1wr000d3xj3791vuavv
cmq4c2r220006jr04d9qbvo4c	แยกน้ำแข็ง	0.00	cmq4c2r220002jr041lx860rn	cmpraptea000o3xj3zfahd2f7
cmq4c5k7f0004lh04e5bojejq	คั่วกลาง	0.00	cmq4c5k7f0002lh0435xa796h	cmpraghfn000a3xj3le4hn9nj
cmq4c5k7f0005lh04lalbbwnc	หวานน้อย 50%	0.00	cmq4c5k7f0002lh0435xa796h	cmprak1wr000e3xj3e60lzs1w
cmq4c5k7f0006lh044ydq66gs	แยกน้ำแข็ง	0.00	cmq4c5k7f0002lh0435xa796h	cmpraptea000o3xj3zfahd2f7
cmq4cnb2x0004k004rps0v95d	หวานปกติ 100%	0.00	cmq4cnb2x0002k00468mv7x2q	cmprak1ws000f3xj35gi3varl
cmq4cnb2x0005k004p09dgirw	เย็น	0.00	cmq4cnb2x0002k00468mv7x2q	cmpran7d3000l3xj3w4zm611l
cmq4cnb2x0006k004t88amzgs	แยกน้ำแข็ง	0.00	cmq4cnb2x0002k00468mv7x2q	cmpraptea000o3xj3zfahd2f7
cmq4cnb2x0009k004yqlcvoz7	ไม่หวาน 0%	0.00	cmq4cnb2x0007k004mbfpgbkw	cmprak1wr000d3xj3791vuavv
cmq4cnb2x000ak0043owipvbo	แยกน้ำแข็ง	0.00	cmq4cnb2x0007k004mbfpgbkw	cmpraptea000o3xj3zfahd2f7
cmq4dqtc40007jp04ag9jktlg	หวานน้อย 50%	0.00	cmq4dqtc40005jp04knhtxrfh	cmprak1wr000e3xj3e60lzs1w
cmq4dxpsc0004js04gl6b4yjc	คั่วเข้ม	0.00	cmq4dxpsc0002js04241pwb11	cmpraghfn00093xj3teu0s9ye
cmq4dxpsc0005js04kvb8ysun	ไม่หวาน 0%	0.00	cmq4dxpsc0002js04241pwb11	cmprak1wr000d3xj3791vuavv
cmq4dxpsc0006js04adt1h29m	แยกน้ำแข็ง	0.00	cmq4dxpsc0002js04241pwb11	cmpraptea000o3xj3zfahd2f7
cmq4e0y6y0006jr04qvwo1ouw	คั่วเข้ม	0.00	cmq4e0y6y0004jr04i7733juy	cmpraghfn00093xj3teu0s9ye
cmq4e0y6y0007jr04excymwg0	หวานปกติ 100%	0.00	cmq4e0y6y0004jr04i7733juy	cmq3v6ydv0001js04mbuyt8in
cmq4e0y6y000ajr043zib7j8n	คั่วเข้ม	0.00	cmq4e0y6y0008jr04r3q9zeyk	cmpraghfn00093xj3teu0s9ye
cmq4e0y6y000bjr04zerhekeb	แยกน้ำแข็ง	0.00	cmq4e0y6y0008jr04r3q9zeyk	cmpraptea000o3xj3zfahd2f7
cmq4e0y6y000cjr0434as6at8	หวานปกติ 100%	0.00	cmq4e0y6y0008jr04r3q9zeyk	cmq3v6ydv0001js04mbuyt8in
cmq4e0y6y000fjr04rebj1daj	หวานปกติ 100%	0.00	cmq4e0y6y000djr04m1b9wvgt	cmprak1ws000f3xj35gi3varl
cmq4e0y6y000gjr04avjxiafe	เย็น	0.00	cmq4e0y6y000djr04m1b9wvgt	cmpran7d3000l3xj3w4zm611l
cmq4e0y6y000hjr047newge7b	แยกน้ำแข็ง	0.00	cmq4e0y6y000djr04m1b9wvgt	cmpraptea000o3xj3zfahd2f7
cmq4e0ybg000ojr04xsguiicq	หวานมาก 120%	0.00	cmq4e0ybg000mjr04yiliob05	cmprak1ws000g3xj3pdboyhw3
cmq4e0ybg000pjr04ggsivffr	เย็น	0.00	cmq4e0ybg000mjr04yiliob05	cmpran7d3000l3xj3w4zm611l
cmq4edy7z000djy04dz5yb4ke	หวานน้อย 50%	0.00	cmq4edy7z000bjy04inbgnt8y	cmprak1wr000e3xj3e60lzs1w
cmq4fo7i90005l804ld1qovf3	คั่วเข้ม	0.00	cmq4fo7i90003l804h5u17v07	cmpraghfn00093xj3teu0s9ye
cmq4fo7i90006l804cciirnlx	ไม่หวาน 0%	0.00	cmq4fo7i90003l804h5u17v07	cmprak1wr000d3xj3791vuavv
cmq4fo7i90009l804du3zeq30	หวานปกติ 100%	0.00	cmq4fo7i90007l804zn9i02zr	cmprak1ws000f3xj35gi3varl
cmq4fw1q60009l1047ni0bujh	คั่วเข้ม	0.00	cmq4fw1q50007l104rarln1yw	cmpraghfn00093xj3teu0s9ye
cmq4fw1q6000al104t9ivzhod	ไม่หวาน 0%	0.00	cmq4fw1q50007l104rarln1yw	cmprak1wr000d3xj3791vuavv
cmq4fw1q6000dl10493c3jdvf	หวานน้อย 50%	0.00	cmq4fw1q6000bl104kifyyj24	cmprak1wr000e3xj3e60lzs1w
cmq4fw1q6000el10429ce369g	เย็น	0.00	cmq4fw1q6000bl104kifyyj24	cmpran7d3000l3xj3w4zm611l
cmq4fy94z000hl8043z9ftq59	หวานปกติ 100%	0.00	cmq4fy94z000fl8049i5pz6kt	cmprak1ws000f3xj35gi3varl
cmq4fzln3000pl804p4hvnpml	คั่วอ่อน	0.00	cmq4fzln3000nl8043pt06bxw	cmpraghfn000b3xj33nmkm7g2
cmq4fzln3000ql804as78dbhn	ไม่หวาน 0%	0.00	cmq4fzln3000nl8043pt06bxw	cmprak1wr000d3xj3791vuavv
cmq4fzln3000rl80437727dhw	แยกน้ำแข็ง	0.00	cmq4fzln3000nl8043pt06bxw	cmpraptea000o3xj3zfahd2f7
cmq4gbnu10005l804pkbfxy2s	หวานน้อย 50%	0.00	cmq4gbnu10003l8049xtjiun7	cmprak1wr000e3xj3e60lzs1w
cmq4gf3ua000cl8042oh7ql5d	หวานปกติ 100%	0.00	cmq4gf3ua000al804lgx6z1zs	cmprak1ws000f3xj35gi3varl
cmq4gf3ua000dl8047l7qo80j	เย็น	0.00	cmq4gf3ua000al804lgx6z1zs	cmpran7d3000l3xj3w4zm611l
cmq4gf3ua000el804iexgko4l	แยกน้ำแข็ง	0.00	cmq4gf3ua000al804lgx6z1zs	cmpraptea000o3xj3zfahd2f7
cmq4ghtop000nl804b150es63	หวานปกติ 100%	0.00	cmq4ghtop000ll804rbfmmpfp	cmprak1ws000f3xj35gi3varl
cmq4gxnwk000ljr04mluuoo24	คั่วกลาง	0.00	cmq4gxnwk000jjr04povappd2	cmpraghfn000a3xj3le4hn9nj
cmq4gxnwk000mjr04ip00skg8	หวานน้อย 50%	0.00	cmq4gxnwk000jjr04povappd2	cmprak1wr000e3xj3e60lzs1w
cmq4h76r40005jm04jd7uybk1	หวานปกติ 100%	0.00	cmq4h76r40003jm04r83z389q	cmprak1ws000f3xj35gi3varl
cmq4h76r40006jm0440j271a1	เย็น	0.00	cmq4h76r40003jm04r83z389q	cmpran7d3000l3xj3w4zm611l
cmq4h76r50009jm04c29wtqzy	หวานปกติ 100%	0.00	cmq4h76r40007jm046eplsmaa	cmprak1ws000f3xj35gi3varl
cmq4h8bqe000ujr04vmmubyl6	หวานน้อย 50%	0.00	cmq4h8bqe000sjr04lhcmzeft	cmprak1wr000e3xj3e60lzs1w
cmq4h8bqe000vjr04ne012o40	เย็น	0.00	cmq4h8bqe000sjr04lhcmzeft	cmpran7d3000l3xj3w4zm611l
cmq4h8s2m0011jr04vc6gkfz5	คั่วกลาง	0.00	cmq4h8s2l000zjr04wmpq2lft	cmpraghfn000a3xj3le4hn9nj
cmq4h8s2m0012jr04t3mb0767	ไม่หวาน 0%	0.00	cmq4h8s2l000zjr04wmpq2lft	cmprak1wr000d3xj3791vuavv
cmq4hafzg000fjm044vcj8mgj	คั่วเข้ม	0.00	cmq4hafzg000djm04sume1n01	cmpraghfn00093xj3teu0s9ye
cmq4higvo0018jr04hnjgj8ig	หวานปกติ 100%	0.00	cmq4higvo0016jr04qnn5723g	cmprak1ws000f3xj35gi3varl
cmq4hkci6001gjr04cbphdy1z	คั่วเข้ม	0.00	cmq4hkci6001ejr04rc03pip9	cmpraghfn00093xj3teu0s9ye
cmq4hkci6001hjr04j8pplnq5	ไม่หวาน 0%	0.00	cmq4hkci6001ejr04rc03pip9	cmprak1wr000d3xj3791vuavv
cmq4hkci6001kjr042bxpo570	หวานปกติ 100%	0.00	cmq4hkci6001ijr04hpc3j904	cmq3v6ydv0001js04mbuyt8in
cmq4hkzmq000ljm041xlny2eu	หวานปกติ 100%	0.00	cmq4hkzmq000jjm042ev3t90t	cmprak1ws000f3xj35gi3varl
cmq4hsyic000tjm04y5rcxd0s	คั่วเข้ม	0.00	cmq4hsyic000rjm04eqa8r2ec	cmpraghfn00093xj3teu0s9ye
cmq4hsyic000ujm04y8fo0s0m	ไม่หวาน 0%	0.00	cmq4hsyic000rjm04eqa8r2ec	cmprak1wr000d3xj3791vuavv
cmq4hsyic000xjm04tx70zv4r	คั่วกลาง	0.00	cmq4hsyic000vjm04vkk3i120	cmpraghfn000a3xj3le4hn9nj
cmq4hsyic000yjm04qvvih4sj	หวานปกติ 100%	0.00	cmq4hsyic000vjm04vkk3i120	cmq3v6ydv0001js04mbuyt8in
cmq4icdtm0005ju04c72j3y4n	คั่วกลาง	0.00	cmq4icdtm0003ju04a3898cli	cmpraghfn000a3xj3le4hn9nj
cmq4icdtm0006ju04z7prhepd	หวานปกติ 100%	0.00	cmq4icdtm0003ju04a3898cli	cmq3v6ydv0001js04mbuyt8in
cmq4kw2vb0005ju04f89xrbe0	หวานปกติ 100%	0.00	cmq4kw2vb0003ju040caaa6ih	cmprak1ws000f3xj35gi3varl
cmq4le8uk0005kz043qamn1wa	หวานน้อย 50%	0.00	cmq4le8uj0003kz04f7jl8spu	cmprak1wr000e3xj3e60lzs1w
cmq4ltlyo0005lh048sddq5ol	คั่วกลาง	0.00	cmq4ltlyo0003lh04o63tmo9l	cmpraghfn000a3xj3le4hn9nj
cmq4ltlyo0006lh04h47bm96x	ไม่หวาน 0%	0.00	cmq4ltlyo0003lh04o63tmo9l	cmprak1wr000d3xj3791vuavv
cmq4mqvuc0005l204ulbxe60w	คั่วกลาง	0.00	cmq4mqvuc0003l204ucaa8bbh	cmpraghfn000a3xj3le4hn9nj
cmq4mqvuc0006l2044nl071cs	หวานน้อย 50%	0.00	cmq4mqvuc0003l204ucaa8bbh	cmprak1wr000e3xj3e60lzs1w
cmq4qav2q0005ju04gy2w0yat	หวานปกติ 100%	0.00	cmq4qav2q0003ju042qbhm3jn	cmprak1ws000f3xj35gi3varl
cmq4qav2q0006ju040pn32diu	เย็น	0.00	cmq4qav2q0003ju042qbhm3jn	cmpran7d3000l3xj3w4zm611l
cmq4qqx500005jy04vb9j6kec	หวานปกติ 100%	0.00	cmq4qqx500003jy047iejgd4l	cmprak1ws000f3xj35gi3varl
cmq4qqx500006jy040nelr3n4	เย็น	0.00	cmq4qqx500003jy047iejgd4l	cmpran7d3000l3xj3w4zm611l
cmq4qqx500009jy04uwrqnwkc	หวานปกติ 100%	0.00	cmq4qqx500007jy04lt8buk1g	cmprak1ws000f3xj35gi3varl
cmq4qqx50000ajy049f9z7105	เย็น	0.00	cmq4qqx500007jy04lt8buk1g	cmpran7d3000l3xj3w4zm611l
cmq4qrh3i000gjy04y4tquyux	หวานมาก 120%	0.00	cmq4qrh3i000ejy04oppfw6ng	cmprak1ws000g3xj3pdboyhw3
cmq4qrh3i000hjy04s26rou9f	เย็น	0.00	cmq4qrh3i000ejy04oppfw6ng	cmpran7d3000l3xj3w4zm611l
cmq4qrh3i000kjy04br1j666r	หวานปกติ 100%	0.00	cmq4qrh3i000ijy04mahuzlue	cmprak1ws000f3xj35gi3varl
cmq4qrh3i000ljy046hql9bm2	เย็น	0.00	cmq4qrh3i000ijy04mahuzlue	cmpran7d3000l3xj3w4zm611l
cmq4qvttb0005js042hndlg6y	หวานปกติ 100%	0.00	cmq4qvttb0003js04u54wr2zb	cmprak1ws000f3xj35gi3varl
cmq4qwk6s000bjs04pjr14ven	เย็น	0.00	cmq4qwk6s0009js04uqxv63fb	cmpran7d3000l3xj3w4zm611l
cmq4ri5830005l204fy1alrnt	คั่วเข้ม	0.00	cmq4ri5830003l204bwn6a4h1	cmpraghfn00093xj3teu0s9ye
cmq4ri5830006l204f3co9beh	หวานปกติ 100%	0.00	cmq4ri5830003l204bwn6a4h1	cmq3v6ydv0001js04mbuyt8in
cmq4ruj2g0005ju046t6wk75m	หวานปกติ 100%	0.00	cmq4ruj2g0003ju041alk7vxd	cmq3v6ydv0001js04mbuyt8in
cmq4szpi50005jl04ifklacih	คั่วกลาง	0.00	cmq4szpi50003jl04eymfmwae	cmpraghfn000a3xj3le4hn9nj
cmq4szpi50006jl0460yzh89x	ไม่หวาน 0%	0.00	cmq4szpi50003jl04eymfmwae	cmprak1wr000d3xj3791vuavv
cmq5s9aoe0004ju04in67cn5z	ไม่หวาน 0%	0.00	cmq5s9aoe0002ju04dywyj3in	cmprak1wr000d3xj3791vuavv
cmq5s9aoe0005ju04dvvrmv7q	แยกน้ำแข็ง	0.00	cmq5s9aoe0002ju04dywyj3in	cmpraptea000o3xj3zfahd2f7
cmq5s9aof0008ju047p8w7jvq	คั่วอ่อน	0.00	cmq5s9aoe0006ju041t99m87r	cmpraghfn000b3xj33nmkm7g2
cmq5s9aof0009ju040udxozas	ไม่หวาน 0%	0.00	cmq5s9aoe0006ju041t99m87r	cmprak1wr000d3xj3791vuavv
cmq5s9aof000aju047vc3temc	แยกน้ำแข็ง	0.00	cmq5s9aoe0006ju041t99m87r	cmpraptea000o3xj3zfahd2f7
cmq5t5rru0004l504bvzt0pe0	คั่วกลาง	0.00	cmq5t5rru0002l50425zxp0g8	cmpraghfn000a3xj3le4hn9nj
cmq5t5rru0005l504fkxud4m6	ไม่หวาน 0%	0.00	cmq5t5rru0002l50425zxp0g8	cmprak1wr000d3xj3791vuavv
cmq5t5rru0008l504u37piuso	คั่วกลาง	0.00	cmq5t5rru0006l504ywqlpvrj	cmpraghfn000a3xj3le4hn9nj
cmq5t5rru0009l504qw34vqir	หวานน้อย 50%	0.00	cmq5t5rru0006l504ywqlpvrj	cmprak1wr000e3xj3e60lzs1w
cmq5tg4i2000hl5042pegwghk	คั่วเข้ม	0.00	cmq5tg4i2000fl50486kzuq5k	cmpraghfn00093xj3teu0s9ye
cmq5tg4i2000il504wuu2i0t3	ไม่หวาน 0%	0.00	cmq5tg4i2000fl50486kzuq5k	cmprak1wr000d3xj3791vuavv
cmq5tg4i2000jl5047vi253ro	แยกน้ำแข็ง	0.00	cmq5tg4i2000fl50486kzuq5k	cmpraptea000o3xj3zfahd2f7
cmq5tjcm10005jr04o45pie2l	หวานมาก 120%	0.00	cmq5tjcm10003jr04x7smdqtt	cmprak1ws000g3xj3pdboyhw3
cmq5tjcm10006jr04raz3ukyr	เย็น	0.00	cmq5tjcm10003jr04x7smdqtt	cmpran7d3000l3xj3w4zm611l
cmq5tkrk30004jm04psfqqqhg	หวานปกติ 100%	0.00	cmq5tkrk30002jm04eqypkwr9	cmprak1ws000f3xj35gi3varl
cmq5tkrk30005jm04pyi0mxui	เย็น	0.00	cmq5tkrk30002jm04eqypkwr9	cmpran7d3000l3xj3w4zm611l
cmq5tq5lu0004l804bysnxv5j	หวานน้อย 50%	0.00	cmq5tq5lu0002l8040vhduzau	cmprak1wr000e3xj3e60lzs1w
cmq5tq5lu0007l8043os6ed4s	ไม่หวาน 0%	0.00	cmq5tq5lu0005l8045fk6st1a	cmprak1wr000d3xj3791vuavv
cmq5tq5lu000al804kniahtsy	หวานน้อย 50%	0.00	cmq5tq5lu0008l804eb0dszyz	cmprak1wr000e3xj3e60lzs1w
cmq5tq5lu000bl80458obxpjl	เย็น	0.00	cmq5tq5lu0008l804eb0dszyz	cmpran7d3000l3xj3w4zm611l
cmq5tq5lu000cl804hgmb64rk	แยกน้ำแข็ง	0.00	cmq5tq5lu0008l804eb0dszyz	cmpraptea000o3xj3zfahd2f7
cmq5uph800006kz04hhl4l2yy	หวานปกติ 100%	0.00	cmq5uph800004kz04xvsywiz7	cmprak1ws000f3xj35gi3varl
cmq5uph800007kz04s5xup1x4	เย็น	0.00	cmq5uph800004kz04xvsywiz7	cmpran7d3000l3xj3w4zm611l
cmq5uph800008kz04mnbqz2ju	แยกน้ำแข็ง	0.00	cmq5uph800004kz04xvsywiz7	cmpraptea000o3xj3zfahd2f7
cmq5uph80000bkz043m44hm0s	หวานน้อย 50%	0.00	cmq5uph800009kz043ucc7o2e	cmprak1wr000e3xj3e60lzs1w
cmq5uph80000ckz04m2hco3co	เย็น	0.00	cmq5uph800009kz043ucc7o2e	cmpran7d3000l3xj3w4zm611l
cmq5uph80000dkz0401kxgdsj	แยกน้ำแข็ง	0.00	cmq5uph800009kz043ucc7o2e	cmpraptea000o3xj3zfahd2f7
cmq5utfg00005ks04akov82e2	คั่วเข้ม	0.00	cmq5utfg00003ks0478qhx41s	cmpraghfn00093xj3teu0s9ye
cmq5utfg00006ks0422674glr	ไม่หวาน 0%	0.00	cmq5utfg00003ks0478qhx41s	cmprak1wr000d3xj3791vuavv
cmq5utfg00009ks04ldal3vxw	หวานปกติ 100%	0.00	cmq5utfg00007ks04dxzhswq6	cmq3v6ydv0001js04mbuyt8in
cmq5vfhdn0004le04nu25e9lp	คั่วเข้ม	0.00	cmq5vfhdn0002le04h3kukmyo	cmpraghfn00093xj3teu0s9ye
cmq5vfhdn0005le04jxu1z0zs	ไม่หวาน 0%	0.00	cmq5vfhdn0002le04h3kukmyo	cmprak1wr000d3xj3791vuavv
cmq5vfvir000ele04raeukl4j	คั่วเข้ม	0.00	cmq5vfvir000cle04j2bhhjtn	cmpraghfn00093xj3teu0s9ye
cmq5vfvir000fle04v0fzvu0i	ไม่หวาน 0%	0.00	cmq5vfvir000cle04j2bhhjtn	cmprak1wr000d3xj3791vuavv
cmq5vh6uz0004jm04toaac71q	หวานน้อย 50%	0.00	cmq5vh6uz0002jm04v2fue43i	cmprak1wr000e3xj3e60lzs1w
cmq5vh6uz0007jm044j1xb4ds	ไม่หวาน 0%	0.00	cmq5vh6uz0005jm04yepo2pir	cmprak1wr000d3xj3791vuavv
cmq5vh6uz0008jm04ygbyoo9v	เย็น	0.00	cmq5vh6uz0005jm04yepo2pir	cmpran7d3000l3xj3w4zm611l
cmq5vk5h0000hjm04qoemmn1q	คั่วเข้ม	0.00	cmq5vk5gz000fjm04qpftg6uz	cmpraghfn00093xj3teu0s9ye
cmq5vk5h0000ijm04xad0qlgz	ไม่หวาน 0%	0.00	cmq5vk5gz000fjm04qpftg6uz	cmprak1wr000d3xj3791vuavv
cmq5vo5no0005jr04hykho0ho	หวานปกติ 100%	0.00	cmq5vo5no0003jr04o3i90sw3	cmprak1ws000f3xj35gi3varl
cmq5vs9zv0005kv04xfic53uo	หวานน้อย 50%	0.00	cmq5vs9zv0003kv04sfsbf89q	cmprak1wr000e3xj3e60lzs1w
cmq5vs9zv0006kv04qtfevlh4	เย็น	0.00	cmq5vs9zv0003kv04sfsbf89q	cmpran7d3000l3xj3w4zm611l
cmq5vzgkt000ekv04mg4dvjha	คั่วเข้ม	0.00	cmq5vzgkt000ckv04qtikgaml	cmpraghfn00093xj3teu0s9ye
cmq5vzgkt000fkv0473ig01zt	ไม่หวาน 0%	0.00	cmq5vzgkt000ckv04qtikgaml	cmprak1wr000d3xj3791vuavv
cmq5wlg1i0006jy046sfrjkki	หวานน้อย 50%	0.00	cmq5wlg1i0004jy04v7l2ktub	cmprak1wr000e3xj3e60lzs1w
cmq5wlg1i0007jy043zhqcuak	เย็น	0.00	cmq5wlg1i0004jy04v7l2ktub	cmpran7d3000l3xj3w4zm611l
cmq5wlg1i000ajy04eapsr0z2	คั่วเข้ม	0.00	cmq5wlg1i0008jy04gp3g5vtr	cmpraghfn00093xj3teu0s9ye
cmq5wlg1i000bjy04ww6vzh98	ไม่หวาน 0%	0.00	cmq5wlg1i0008jy04gp3g5vtr	cmprak1wr000d3xj3791vuavv
cmq5wlg1i000cjy04v78m6spa	แยกน้ำแข็ง	0.00	cmq5wlg1i0008jy04gp3g5vtr	cmpraptea000o3xj3zfahd2f7
cmq5wlg1i000fjy04zq5lor4l	คั่วกลาง	0.00	cmq5wlg1i000djy04qq5btow2	cmpraghfn000a3xj3le4hn9nj
cmq5wlg1i000gjy045lf9y715	หวานปกติ 100%	0.00	cmq5wlg1i000djy04qq5btow2	cmq3v6ydv0001js04mbuyt8in
cmq5wnwgd000ojy046ryh0shr	คั่วเข้ม	0.00	cmq5wnwgd000mjy04x5etr6rt	cmpraghfn00093xj3teu0s9ye
cmq5wnwgd000pjy04bcjkp492	หวานปกติ 100%	0.00	cmq5wnwgd000mjy04x5etr6rt	cmq3v6ydv0001js04mbuyt8in
cmq5wnwgd000sjy04j2lqvfjb	หวานปกติ 100%	0.00	cmq5wnwgd000qjy047k2q0avv	cmprak1ws000f3xj35gi3varl
cmq5wnwgd000tjy043qxf5zvv	เย็น	0.00	cmq5wnwgd000qjy047k2q0avv	cmpran7d3000l3xj3w4zm611l
cmq5x84b10017jy0499lvki7y	คั่วกลาง	0.00	cmq5x84b10015jy04rkll50z3	cmpraghfn000a3xj3le4hn9nj
cmq5x84b10018jy04epwvh10v	หวานปกติ 100%	0.00	cmq5x84b10015jy04rkll50z3	cmq3v6ydv0001js04mbuyt8in
cmq5x8ymb0005jo04tx4mlf8r	คั่วกลาง	0.00	cmq5x8ymb0003jo04al7j74p9	cmpraghfn000a3xj3le4hn9nj
cmq5x8ymb0006jo04lq9w04rh	หวานน้อย 50%	0.00	cmq5x8ymb0003jo04al7j74p9	cmprak1wr000e3xj3e60lzs1w
cmq5x9gq0000cjo04m3vwqj2u	คั่วเข้ม	0.00	cmq5x9gq0000ajo04fxvw9pll	cmpraghfn00093xj3teu0s9ye
cmq5x9gq0000djo04lwmw2hse	ไม่หวาน 0%	0.00	cmq5x9gq0000ajo04fxvw9pll	cmprak1wr000d3xj3791vuavv
cmqisj5tl001xl704gtj3ed5f	หวานปกติ 100%	0.00	cmqisj5tl001vl704ofycywaa	cmprak1ws000f3xj35gi3varl
cmqiv04280007ji04e6p6860u	หวานน้อย 50%	0.00	cmqiv04280005ji04sw9b5pvp	cmprak1wr000e3xj3e60lzs1w
cmqiv04290008ji04y7fs161k	เย็น	0.00	cmqiv04280005ji04sw9b5pvp	cmpran7d3000l3xj3w4zm611l
cmqiv5xlz0005i804daiv2dmu	คั่วเข้ม	0.00	cmqiv5xly0003i804zwxgn6i3	cmpraghfn00093xj3teu0s9ye
cmqiv5xlz0006i804a32j2xhh	ไม่หวาน 0%	0.00	cmqiv5xly0003i804zwxgn6i3	cmprak1wr000d3xj3791vuavv
cmqivzsta0005jy04ecmvhtdb	หวานน้อย 50%	0.00	cmqivzsta0003jy04s4o5abqi	cmprak1wr000e3xj3e60lzs1w
cmqivzsta0008jy042lzvciar	หวานน้อย 50%	0.00	cmqivzsta0006jy04ezjkh9mv	cmprak1wr000e3xj3e60lzs1w
cmqivzsta0009jy04cohrk1nw	เย็น	0.00	cmqivzsta0006jy04ezjkh9mv	cmpran7d3000l3xj3w4zm611l
cmqiw7z4e0005i204agiu96az	คั่วอ่อน	0.00	cmqiw7z4e0003i204rsgvfqdi	cmpraghfn000b3xj33nmkm7g2
cmqiw7z4e0006i204wsykbl11	หวานน้อย 50%	0.00	cmqiw7z4e0003i204rsgvfqdi	cmprak1wr000e3xj3e60lzs1w
cmqiw7z4e0009i204taogiz0o	คั่วกลาง	0.00	cmqiw7z4e0007i2043f1jge84	cmpraghfn000a3xj3le4hn9nj
cmqiw7z4e000ai204im59ggil	ไม่หวาน 0%	0.00	cmqiw7z4e0007i2043f1jge84	cmprak1wr000d3xj3791vuavv
cmqiw7z4e000bi204z2e1yx71	แยกน้ำแข็ง	0.00	cmqiw7z4e0007i2043f1jge84	cmpraptea000o3xj3zfahd2f7
cmqiw7z4e000ei204lfly9eea	หวานปกติ 100%	0.00	cmqiw7z4e000ci204x7zewwtm	cmprak1ws000f3xj35gi3varl
cmqiw7z4e000hi2040ahhijqk	คั่วเข้ม	0.00	cmqiw7z4e000fi2043jzwoj2l	cmpraghfn00093xj3teu0s9ye
cmqiw7z4f000ii20402reyc3r	ไม่หวาน 0%	0.00	cmqiw7z4e000fi2043jzwoj2l	cmprak1wr000d3xj3791vuavv
cmqiw7z4f000li204jn8ghid4	คั่วกลาง	0.00	cmqiw7z4f000ji2042ervl7rq	cmpraghfn000a3xj3le4hn9nj
cmqiw7z4f000mi204o1vj6e3c	ไม่หวาน 0%	0.00	cmqiw7z4f000ji2042ervl7rq	cmprak1wr000d3xj3791vuavv
cmqiw7z4f000pi2041w42shli	หวานน้อย 50%	0.00	cmqiw7z4f000ni204d9e6x7ta	cmprak1wr000e3xj3e60lzs1w
cmqiwt0mu0005l704u2nwmhft	หวานน้อย 50%	0.00	cmqiwt0mu0003l704kclys5pd	cmprak1wr000e3xj3e60lzs1w
cmqiwyfui0005js04j3w2a8ft	หวานน้อย 50%	0.00	cmqiwyfui0003js040iq4ozag	cmprak1wr000e3xj3e60lzs1w
cmqixfehj000gjs04tp136knq	คั่วกลาง	0.00	cmqixfehj000ejs04pmctn90q	cmpraghfn000a3xj3le4hn9nj
cmqixfehj000hjs044kffkrrr	หวานปกติ 100%	0.00	cmqixfehj000ejs04pmctn90q	cmq3v6ydv0001js04mbuyt8in
cmqj03pk40005l5049xjgdfl8	หวานปกติ 100%	0.00	cmqj03pk40003l504n7wbyfxz	cmprak1ws000f3xj35gi3varl
cmqj03pk40008l504zwcvar1d	คั่วเข้ม	0.00	cmqj03pk40006l504u6bc8syg	cmpraghfn00093xj3teu0s9ye
cmqj03pk40009l50484tsur6k	หวานปกติ 100%	0.00	cmqj03pk40006l504u6bc8syg	cmq3v6ydv0001js04mbuyt8in
cmqj0sewv0003il04e3ecp2ki	หวานปกติ 100%	0.00	cmqj0sewv0001il04i7yh09xg	cmprak1ws000f3xj35gi3varl
cmqj0sewv0004il041q4a1oc0	เย็น	0.00	cmqj0sewv0001il04i7yh09xg	cmpran7d3000l3xj3w4zm611l
cmqj126pd000bla04f9e4oizc	เย็น	0.00	cmqj126pd0009la04wsx99sxt	cmpran7d3000l3xj3w4zm611l
cmqj1bzri0005la04guz6uot9	หวานน้อย 50%	0.00	cmqj1bzri0003la04yqco8exj	cmprak1wr000e3xj3e60lzs1w
cmqj1bzri0006la04id7yz0v0	เย็น	0.00	cmqj1bzri0003la04yqco8exj	cmpran7d3000l3xj3w4zm611l
cmqj1bzri0009la04wjt25yqk	หวานปกติ 100%	0.00	cmqj1bzri0007la04a9hz35qy	cmprak1ws000f3xj35gi3varl
cmqj1bzri000ala045uki5x2e	เย็น	0.00	cmqj1bzri0007la04a9hz35qy	cmpran7d3000l3xj3w4zm611l
cmqj1s5wz0005jy049bz853h1	หวานปกติ 100%	0.00	cmqj1s5wz0003jy04xp6841zj	cmprak1ws000f3xj35gi3varl
cmqj1s5wz0006jy04h9y1b6gj	เย็น	0.00	cmqj1s5wz0003jy04xp6841zj	cmpran7d3000l3xj3w4zm611l
cmqj5utke0005jy04uex1qm0k	หวานปกติ 100%	0.00	cmqj5utke0003jy04lxex9pob	cmprak1ws000f3xj35gi3varl
cmqj5utke0006jy0403swn00u	เย็น	0.00	cmqj5utke0003jy04lxex9pob	cmpran7d3000l3xj3w4zm611l
cmqj5va36000ejy04qqtuypo0	คั่วเข้ม	0.00	cmqj5va36000cjy04mm8fs5u3	cmpraghfn00093xj3teu0s9ye
cmqj5va36000fjy044ifkyhmp	ไม่หวาน 0%	0.00	cmqj5va36000cjy04mm8fs5u3	cmprak1wr000d3xj3791vuavv
cmqk4r47y0004ky04hlo0jpfu	คั่วเข้ม	0.00	cmqk4r47y0002ky04ihb28c19	cmpraghfn00093xj3teu0s9ye
cmqk4r47y0005ky04kg8yi9j3	หวานปกติ 100%	0.00	cmqk4r47y0002ky04ihb28c19	cmq3v6ydv0001js04mbuyt8in
cmqk4r47z0008ky045fowr3rm	หวานน้อย 50%	0.00	cmqk4r47z0006ky04nvogictz	cmprak1wr000e3xj3e60lzs1w
cmqk4r47z000bky04h5m79acc	คั่วอ่อน	0.00	cmqk4r47z0009ky0483g2ti3t	cmpraghfn000b3xj33nmkm7g2
cmqk4r47z000cky04w4n2x2ln	ไม่หวาน 0%	0.00	cmqk4r47z0009ky0483g2ti3t	cmprak1wr000d3xj3791vuavv
cmqk4r47z000gky04qo3zib5v	คั่วเข้ม	0.00	cmqk4r47z000eky04q7daqqdt	cmpraghfn00093xj3teu0s9ye
cmqk5ltex0007jo04su71midk	คั่วกลาง	0.00	cmqk5ltex0005jo04cbulcggd	cmpraghfn000a3xj3le4hn9nj
cmqk5ltex0008jo04u3cohvy0	หวานปกติ 100%	0.00	cmqk5ltex0005jo04cbulcggd	cmq3v6ydv0001js04mbuyt8in
cmqk5ltex000bjo04ku8u7cl4	คั่วเข้ม	0.00	cmqk5ltex0009jo04xdwfx0vz	cmpraghfn00093xj3teu0s9ye
cmqk5ltex000cjo04mgs24h11	ไม่หวาน 0%	0.00	cmqk5ltex0009jo04xdwfx0vz	cmprak1wr000d3xj3791vuavv
cmqk5u11m000pjo04dyg3benh	คั่วเข้ม	0.00	cmqk5u11m000njo04rfx46qzq	cmpraghfn00093xj3teu0s9ye
cmq5wp4nu000fl8045qmz1zaj	คั่วอ่อน	0.00	cmq5wp4nu000dl804j9p3czd7	cmpraghfn000b3xj33nmkm7g2
cmq5wp4nu000gl8042dvcjisd	ไม่หวาน 0%	0.00	cmq5wp4nu000dl804j9p3czd7	cmprak1wr000d3xj3791vuavv
cmq5wswte000ol804o3mz8oa6	คั่วกลาง	0.00	cmq5wswte000ml80492rostnf	cmpraghfn000a3xj3le4hn9nj
cmq5wswte000pl804l0qzav4j	หวานน้อย 50%	0.00	cmq5wswte000ml80492rostnf	cmprak1wr000e3xj3e60lzs1w
cmq5x06rn000zjy049qky8ozw	หวานน้อย 50%	0.00	cmq5x06rn000xjy04q2ji7enc	cmprak1wr000e3xj3e60lzs1w
cmq5xnr2n001ijy04byg0u2m0	คั่วกลาง	0.00	cmq5xnr2n001gjy045sdb9em1	cmpraghfn000a3xj3le4hn9nj
cmq5zubfh0005ld04ovm8lu8b	หวานน้อย 50%	0.00	cmq5zubfh0003ld043qkmr5u5	cmprak1wr000e3xj3e60lzs1w
cmq5zubfh0006ld04hcnv8auo	เย็น	0.00	cmq5zubfh0003ld043qkmr5u5	cmpran7d3000l3xj3w4zm611l
cmq5zwq1u0005l404b5qodqrx	หวานมาก 120%	0.00	cmq5zwq1u0003l404y9zbovfi	cmprak1ws000g3xj3pdboyhw3
cmq5zwq1u0006l404p3jwqwxf	เย็น	0.00	cmq5zwq1u0003l404y9zbovfi	cmpran7d3000l3xj3w4zm611l
cmq5zyjne000el40434gcp7vx	หวานปกติ 100%	0.00	cmq5zyjnd000cl404nle2iwey	cmprak1ws000f3xj35gi3varl
cmq60oago0005jl04zn2xcn9i	หวานน้อย 50%	0.00	cmq60oagn0003jl04ubhholt2	cmprak1wr000e3xj3e60lzs1w
cmq60oago0006jl044q05102k	เย็น	0.00	cmq60oagn0003jl04ubhholt2	cmpran7d3000l3xj3w4zm611l
cmq60ukbb0005jp04wv0cz9ro	คั่วกลาง	0.00	cmq60ukbb0003jp04lg0nbdj4	cmpraghfn000a3xj3le4hn9nj
cmq60ukbb0006jp043jzha5jv	หวานน้อย 50%	0.00	cmq60ukbb0003jp04lg0nbdj4	cmprak1wr000e3xj3e60lzs1w
cmq60ukbb0009jp04laibvmyk	หวานน้อย 50%	0.00	cmq60ukbb0007jp04mmwz7z5p	cmprak1wr000e3xj3e60lzs1w
cmq60ukbb000cjp04qd7lqt35	หวานปกติ 100%	0.00	cmq60ukbb000ajp04elslik63	cmprak1ws000f3xj35gi3varl
cmq60ukbb000djp04vqfjy3je	เย็น	0.00	cmq60ukbb000ajp04elslik63	cmpran7d3000l3xj3w4zm611l
cmq610y3s0005js043fy7c4hq	หวานน้อย 50%	0.00	cmq610y3s0003js04p3kapf1u	cmprak1wr000e3xj3e60lzs1w
cmq610y3s0006js04zcipr6yd	เย็น	0.00	cmq610y3s0003js04p3kapf1u	cmpran7d3000l3xj3w4zm611l
cmq610y3s0009js04sn7xkw2p	คั่วเข้ม	0.00	cmq610y3s0007js04k3fc7gb5	cmpraghfn00093xj3teu0s9ye
cmq610y3s000ajs04t2k88gc7	ไม่หวาน 0%	0.00	cmq610y3s0007js04k3fc7gb5	cmprak1wr000d3xj3791vuavv
cmq618yr40005jv04o7sbezej	คั่วกลาง	0.00	cmq618yr40003jv047tba81t0	cmpraghfn000a3xj3le4hn9nj
cmq618yr50006jv04ezpinzh3	ไม่หวาน 0%	0.00	cmq618yr40003jv047tba81t0	cmprak1wr000d3xj3791vuavv
cmq61cze5000ejv04h6nki69j	หวานปกติ 100%	0.00	cmq61cze5000cjv04giujxz7o	cmprak1ws000f3xj35gi3varl
cmq61cze5000fjv04jzw8bath	เย็น	0.00	cmq61cze5000cjv04giujxz7o	cmpran7d3000l3xj3w4zm611l
cmq61cze5000ijv04lg7pnloa	หวานน้อย 50%	0.00	cmq61cze5000gjv04whcpjd3c	cmprak1wr000e3xj3e60lzs1w
cmq61cze5000jjv04r7gs5sio	เย็น	0.00	cmq61cze5000gjv04whcpjd3c	cmpran7d3000l3xj3w4zm611l
cmq61cze5000mjv04swg6a4j6	หวานน้อย 50%	0.00	cmq61cze5000kjv0436623dqc	cmprak1wr000e3xj3e60lzs1w
cmq61cze5000njv041f3tc37j	เย็น	0.00	cmq61cze5000kjv0436623dqc	cmpran7d3000l3xj3w4zm611l
cmq61kwhi000njp04rzi48xmf	หวานปกติ 100%	0.00	cmq61kwhi000ljp048q7uw3dw	cmprak1ws000f3xj35gi3varl
cmq61kwhi000ojp04tgsqdjvx	เย็น	0.00	cmq61kwhi000ljp048q7uw3dw	cmpran7d3000l3xj3w4zm611l
cmq61kwhi000rjp047gfiwfjq	หวานปกติ 100%	0.00	cmq61kwhi000pjp04rlms11rd	cmprak1ws000f3xj35gi3varl
cmq61kwhi000sjp04myvb9fnn	เย็น	0.00	cmq61kwhi000pjp04rlms11rd	cmpran7d3000l3xj3w4zm611l
cmq61kwhi000vjp04k7ah3oyq	หวานปกติ 100%	0.00	cmq61kwhi000tjp04zibs1q0c	cmprak1ws000f3xj35gi3varl
cmq61kwhi000wjp047ckshsrf	เย็น	0.00	cmq61kwhi000tjp04zibs1q0c	cmpran7d3000l3xj3w4zm611l
cmq62bn1c0005l704zs5dokms	คั่วกลาง	0.00	cmq62bn1c0003l704dztsaol0	cmpraghfn000a3xj3le4hn9nj
cmq62bn1c0006l704tq659qkn	หวานปกติ 100%	0.00	cmq62bn1c0003l704dztsaol0	cmq3v6ydv0001js04mbuyt8in
cmq62bn1c0009l704awqm6kpy	หวานปกติ 100%	0.00	cmq62bn1c0007l704lcwehw9d	cmprak1ws000f3xj35gi3varl
cmq62drkr0005ji04tiawuuiz	หวานปกติ 100%	0.00	cmq62drkr0003ji0426w9sb64	cmprak1ws000f3xj35gi3varl
cmq62drkr0006ji04uudxpuk3	เย็น	0.00	cmq62drkr0003ji0426w9sb64	cmpran7d3000l3xj3w4zm611l
cmq63eerb0005l404fa1rm601	คั่วเข้ม	0.00	cmq63eerb0003l404feljd7hu	cmpraghfn00093xj3teu0s9ye
cmq63eerb0006l404unph2hcq	ไม่หวาน 0%	0.00	cmq63eerb0003l404feljd7hu	cmprak1wr000d3xj3791vuavv
cmq63em2m000cl404yr9akd3r	ไม่หวาน 0%	0.00	cmq63em2m000al404o55n3xai	cmprak1wr000d3xj3791vuavv
cmq67fyce0005k004khauln31	คั่วเข้ม	0.00	cmq67fyce0003k0040g40v2zz	cmpraghfn00093xj3teu0s9ye
cmq67fyce0006k004qch120k4	หวานปกติ 100%	0.00	cmq67fyce0003k0040g40v2zz	cmq3v6ydv0001js04mbuyt8in
cmq67fyce0009k004t13auaj1	หวานปกติ 100%	0.00	cmq67fyce0007k004s49ry856	cmprak1ws000f3xj35gi3varl
cmq67fyce000ak0044aw8l19k	เย็น	0.00	cmq67fyce0007k004s49ry856	cmpran7d3000l3xj3w4zm611l
cmq77yrth0004ju04ozzxp8ac	หวานปกติ 100%	0.00	cmq77yrth0002ju04mrya04b6	cmprak1ws000f3xj35gi3varl
cmq77yrth0005ju045vftewwz	เย็น	0.00	cmq77yrth0002ju04mrya04b6	cmpran7d3000l3xj3w4zm611l
cmq77yrth0006ju04razchmdx	แยกน้ำแข็ง	0.00	cmq77yrth0002ju04mrya04b6	cmpraptea000o3xj3zfahd2f7
cmq77yrth0009ju049atfkefh	ไม่หวาน 0%	0.00	cmq77yrth0007ju040kzbl5kf	cmprak1wr000d3xj3791vuavv
cmq77yrth000cju043wsx54f4	คั่วอ่อน	0.00	cmq77yrth000aju04fwo2xmql	cmpraghfn000b3xj33nmkm7g2
cmq77yrth000dju047y5l09og	ไม่หวาน 0%	0.00	cmq77yrth000aju04fwo2xmql	cmprak1wr000d3xj3791vuavv
cmq78vwei0005js04d8dymw3f	หวานมาก 120%	0.00	cmq78vwei0003js04bcy0v0g8	cmprak1ws000g3xj3pdboyhw3
cmq78vwei0006js04tq498775	เย็น	0.00	cmq78vwei0003js04bcy0v0g8	cmpran7d3000l3xj3w4zm611l
cmq78wz8v0005l504178pfxmz	หวานน้อย 50%	0.00	cmq78wz8v0003l5042gep21aw	cmprak1wr000e3xj3e60lzs1w
cmq78wz8v0006l504u8pytyut	เย็น	0.00	cmq78wz8v0003l5042gep21aw	cmpran7d3000l3xj3w4zm611l
cmq78x7iv000cl5040c5nt9om	หวานปกติ 100%	0.00	cmq78x7iv000al504f4ep8u0f	cmprak1ws000f3xj35gi3varl
cmq78x7iv000dl504a5tgc3ot	เย็น	0.00	cmq78x7iv000al504f4ep8u0f	cmpran7d3000l3xj3w4zm611l
cmq78xijx000jl504frtn6qz2	หวานน้อย 50%	0.00	cmq78xijx000hl504efpb2jo6	cmprak1wr000e3xj3e60lzs1w
cmq78xijx000kl504d62coqp5	เย็น	0.00	cmq78xijx000hl504efpb2jo6	cmpran7d3000l3xj3w4zm611l
cmq78xvav000ql5043gjgedoz	ไม่หวาน 0%	0.00	cmq78xvav000ol5048w74hri4	cmprak1wr000d3xj3791vuavv
cmq78xvav000rl504f7en360r	เพิ่มช็อต	10.00	cmq78xvav000ol5048w74hri4	cmpralv7i000j3xj3b1u9nwyo
cmq793pjd0005jp042sbcqzjk	หวานน้อย 50%	0.00	cmq793pjd0003jp046cyq4l04	cmprak1wr000e3xj3e60lzs1w
cmq7a4ak40004jv04d9srkjci	คั่วเข้ม	0.00	cmq7a4ak40002jv04spsl0b4v	cmpraghfn00093xj3teu0s9ye
cmq7a4ak40005jv04jwom6fgr	ไม่หวาน 0%	0.00	cmq7a4ak40002jv04spsl0b4v	cmprak1wr000d3xj3791vuavv
cmq7a4ak40008jv04jlutcg4q	หวานปกติ 100%	0.00	cmq7a4ak40006jv045uhhq5dw	cmprak1ws000f3xj35gi3varl
cmq7a7d9t0005l204j373g08i	คั่วเข้ม	0.00	cmq7a7d9t0003l204omhlv6pa	cmpraghfn00093xj3teu0s9ye
cmq7a7d9u0006l204alerbzv6	ไม่หวาน 0%	0.00	cmq7a7d9t0003l204omhlv6pa	cmprak1wr000d3xj3791vuavv
cmq7asad80008jx04q83wuhjm	ไม่หวาน 0%	0.00	cmq7asad80006jx04xaca4mc8	cmprak1wr000d3xj3791vuavv
cmq7asad80009jx04jyzziquj	เย็น	0.00	cmq7asad80006jx04xaca4mc8	cmpran7d3000l3xj3w4zm611l
cmq7ayit00004l504dkywqlbm	หวานน้อย 50%	0.00	cmq7ayit00002l504whr3k1ge	cmprak1wr000e3xj3e60lzs1w
cmq7ayit00005l504kdppnr2n	เย็น	0.00	cmq7ayit00002l504whr3k1ge	cmpran7d3000l3xj3w4zm611l
cmq7b7csl000ijx048hjlcfva	หวานปกติ 100%	0.00	cmq7b7csl000gjx04nkkcbze5	cmprak1ws000f3xj35gi3varl
cmq7b9zbl000el50432rjq9iw	หวานน้อย 50%	0.00	cmq7b9zbk000cl504ybo2rtqc	cmprak1wr000e3xj3e60lzs1w
cmq7b9zbl000fl504i4iebz6f	เย็น	0.00	cmq7b9zbk000cl504ybo2rtqc	cmpran7d3000l3xj3w4zm611l
cmq7bagqh000ll5041z08ssmy	หวานน้อย 50%	0.00	cmq7bagqh000jl504z24qkw1g	cmprak1wr000e3xj3e60lzs1w
cmq7bagqh000ml50431p41nuu	เย็น	0.00	cmq7bagqh000jl504z24qkw1g	cmpran7d3000l3xj3w4zm611l
cmq7bcr6l0008l404auwy71tt	หวานปกติ 100%	0.00	cmq7bcr6l0006l404v128gasu	cmprak1ws000f3xj35gi3varl
cmq7bcr6l0009l404w7hawxf2	เย็น	0.00	cmq7bcr6l0006l404v128gasu	cmpran7d3000l3xj3w4zm611l
cmq7bhu83000sl504mzyen0xh	คั่วเข้ม	0.00	cmq7bhu83000ql504fstl3xmh	cmpraghfn00093xj3teu0s9ye
cmq7bhu83000tl504ajj3etn6	ไม่หวาน 0%	0.00	cmq7bhu83000ql504fstl3xmh	cmprak1wr000d3xj3791vuavv
cmq7bokil0013l5043iynd0ag	หวานปกติ 100%	0.00	cmq7bokil0011l504n9f1oaoh	cmq3v6ydv0001js04mbuyt8in
cmq7bve06001bl504m16yz7nv	คั่วเข้ม	0.00	cmq7bve060019l5043hncmjys	cmpraghfn00093xj3teu0s9ye
cmq7bve06001cl504mgrxotzv	ไม่หวาน 0%	0.00	cmq7bve060019l5043hncmjys	cmprak1wr000d3xj3791vuavv
cmq7c3rsp000qjx04d4u365a2	หวานปกติ 100%	0.00	cmq7c3rsp000ojx04kj1m694k	cmprak1ws000f3xj35gi3varl
cmq7c4qve001il504b7zauexh	คั่วอ่อน	0.00	cmq7c4qve001gl504833yzdgc	cmpraghfn000b3xj33nmkm7g2
cmq7c4qve001jl504jgyvz4w5	ไม่หวาน 0%	0.00	cmq7c4qve001gl504833yzdgc	cmprak1wr000d3xj3791vuavv
cmq7c6ksj001rl504sqdvql5j	หวานน้อย 50%	0.00	cmq7c6ksj001pl504df2skcws	cmprak1wr000e3xj3e60lzs1w
cmq7c6ksj001ul5049ulpmwaa	คั่วเข้ม	0.00	cmq7c6ksj001sl504qabjvooi	cmpraghfn00093xj3teu0s9ye
cmq7c6ksj001vl5046j1jpsbv	ไม่หวาน 0%	0.00	cmq7c6ksj001sl504qabjvooi	cmprak1wr000d3xj3791vuavv
cmq7c6ksj001wl5046l3b6cs2	แยกน้ำแข็ง	0.00	cmq7c6ksj001sl504qabjvooi	cmpraptea000o3xj3zfahd2f7
cmq7c6ksj001zl504b6w48p8q	หวานปกติ 100%	0.00	cmq7c6ksj001xl504t0f1b23t	cmq3v6ydv0001js04mbuyt8in
cmq7cb7aq000yjx04n5a05anz	คั่วเข้ม	0.00	cmq7cb7aq000wjx04w52xj1tn	cmpraghfn00093xj3teu0s9ye
cmq7cb7aq000zjx04th5hi9a0	หวานปกติ 100%	0.00	cmq7cb7aq000wjx04w52xj1tn	cmq3v6ydv0001js04mbuyt8in
cmq7ceuj00015jx04emvngjs0	หวานปกติ 100%	0.00	cmq7ceuj00013jx044zvpur2b	cmprak1ws000f3xj35gi3varl
cmq7cg2d50027l504cwbr6l4x	หวานปกติ 100%	0.00	cmq7cg2d50025l504ib0w9rsf	cmprak1ws000f3xj35gi3varl
cmq7cpoul002dl5048q49u3u7	หวานปกติ 100%	0.00	cmq7cpoul002bl504w09a8vi3	cmprak1ws000f3xj35gi3varl
cmq7csl4l001djx040p5zp8bw	คั่วกลาง	0.00	cmq7csl4l001bjx04ueavg9rs	cmpraghfn000a3xj3le4hn9nj
cmq7csl4l001ejx04ktr419d0	หวานปกติ 100%	0.00	cmq7csl4l001bjx04ueavg9rs	cmq3v6ydv0001js04mbuyt8in
cmq7csl4l001hjx04cy8ykke4	หวานปกติ 100%	0.00	cmq7csl4l001fjx040zju67f8	cmprak1ws000f3xj35gi3varl
cmq7csl4l001ijx04xgqoc1ym	เย็น	0.00	cmq7csl4l001fjx040zju67f8	cmpran7d3000l3xj3w4zm611l
cmq7cy4he002pl504q0m11l8t	คั่วกลาง	0.00	cmq7cy4he002nl504bm0mhmxf	cmpraghfn000a3xj3le4hn9nj
cmq7cy4he002ql504osxu1qh7	หวานปกติ 100%	0.00	cmq7cy4he002nl504bm0mhmxf	cmq3v6ydv0001js04mbuyt8in
cmq7f4sgv0005l5044zk10k7a	หวานปกติ 100%	0.00	cmq7f4sgv0003l5045xxgweib	cmprak1ws000f3xj35gi3varl
cmq7f4sgv0006l504gg4el7sd	เย็น	0.00	cmq7f4sgv0003l5045xxgweib	cmpran7d3000l3xj3w4zm611l
cmq7f4sgv0009l504bzuf3tzs	หวานปกติ 100%	0.00	cmq7f4sgv0007l5046jcjtszb	cmprak1ws000f3xj35gi3varl
cmq7faodz0005i904tz3q7nme	หวานน้อย 50%	0.00	cmq7faodz0003i904eb63ts4c	cmprak1wr000e3xj3e60lzs1w
cmq7faodz0006i90468wjfk50	เย็น	0.00	cmq7faodz0003i904eb63ts4c	cmpran7d3000l3xj3w4zm611l
cmq7faodz0009i904frxebh4z	หวานปกติ 100%	0.00	cmq7faodz0007i904c1suz75v	cmprak1ws000f3xj35gi3varl
cmq7gifyr0005l404ytv8p2qq	คั่วเข้ม	0.00	cmq7gifyr0003l404qyudbthh	cmpraghfn00093xj3teu0s9ye
cmq7gifyr0006l404k6ndah9u	ไม่หวาน 0%	0.00	cmq7gifyr0003l404qyudbthh	cmprak1wr000d3xj3791vuavv
cmq7gisgv000el4041p1oqu8i	คั่วเข้ม	0.00	cmq7gisgv000cl404nj9i2ox1	cmpraghfn00093xj3teu0s9ye
cmq7gisgv000fl404php9s7w2	ไม่หวาน 0%	0.00	cmq7gisgv000cl404nj9i2ox1	cmprak1wr000d3xj3791vuavv
cmq7gx6lk000nl404yoo5yyrh	คั่วกลาง	0.00	cmq7gx6lk000ll40470n69071	cmpraghfn000a3xj3le4hn9nj
cmq7gx6lk000ol404on4xkosy	ไม่หวาน 0%	0.00	cmq7gx6lk000ll40470n69071	cmprak1wr000d3xj3791vuavv
cmq7gx6lk000rl404fidv39l2	หวานน้อย 50%	0.00	cmq7gx6lk000pl4045wgpa4ik	cmprak1wr000e3xj3e60lzs1w
cmq7gxwrn000xl404txamiua9	หวานน้อย 50%	0.00	cmq7gxwrn000vl404rpiyxurv	cmprak1wr000e3xj3e60lzs1w
cmq7gxwrn0011l404ysr3oi5b	หวานปกติ 100%	0.00	cmq7gxwrn000zl404akegm5qf	cmprak1ws000f3xj35gi3varl
cmq7gxwrn0012l4049x9hgbn2	เย็น	0.00	cmq7gxwrn000zl404akegm5qf	cmpran7d3000l3xj3w4zm611l
cmq7h2whm0005lb040igs4ag3	คั่วเข้ม	0.00	cmq7h2whm0003lb047hyojs3r	cmpraghfn00093xj3teu0s9ye
cmq7h2whm0006lb04fpabojks	ไม่หวาน 0%	0.00	cmq7h2whm0003lb047hyojs3r	cmprak1wr000d3xj3791vuavv
cmq7h8xl8000glb04x12dyy0l	คั่วเข้ม	0.00	cmq7h8xl8000elb04vk47ume7	cmpraghfn00093xj3teu0s9ye
cmq7h8xl8000hlb04ions40me	หวานน้อย 50%	0.00	cmq7h8xl8000elb04vk47ume7	cmprak1wr000e3xj3e60lzs1w
cmq7hau7h0018l404q6e94m45	หวานปกติ 100%	0.00	cmq7hau7h0016l404apr8yy7r	cmprak1ws000f3xj35gi3varl
cmq7hau7h0019l404fq2q9b3l	เย็น	0.00	cmq7hau7h0016l404apr8yy7r	cmpran7d3000l3xj3w4zm611l
cmqiwx8kr000gl704la89lja9	หวานปกติ 100%	0.00	cmqiwx8kr000el704yud4mn5o	cmprak1ws000f3xj35gi3varl
cmqj0tusn000ail04syx4fwcj	หวานปกติ 100%	0.00	cmqj0tusn0008il042wp98ufo	cmq3v6ydv0001js04mbuyt8in
cmqk4rtrq000pky04hqo2j07y	หวานมาก 120%	0.00	cmqk4rtrq000nky04i365xde7	cmprak1ws000g3xj3pdboyhw3
cmqk4rtrq000qky04br4aj902	เย็น	0.00	cmqk4rtrq000nky04i365xde7	cmpran7d3000l3xj3w4zm611l
cmqkbflu4000ijl045gxsnnv6	หวานปกติ 100%	0.00	cmqkbflu4000gjl04l6a07qko	cmprak1ws000f3xj35gi3varl
cmq7hzn720005jx04nvb1qmt1	ไม่หวาน 0%	0.00	cmq7hzn720003jx042g2msm3p	cmprak1wr000d3xj3791vuavv
cmq7hzn720006jx04hzqumzb1	เย็น	0.00	cmq7hzn720003jx042g2msm3p	cmpran7d3000l3xj3w4zm611l
cmq7hzn720009jx04j85bardz	หวานปกติ 100%	0.00	cmq7hzn720007jx04vh9tr06n	cmprak1ws000f3xj35gi3varl
cmq7hzn72000ajx04in3wpcbk	เย็น	0.00	cmq7hzn720007jx04vh9tr06n	cmpran7d3000l3xj3w4zm611l
cmqkbflu4000jjl04yisey5rw	เย็น	0.00	cmqkbflu4000gjl04l6a07qko	cmpran7d3000l3xj3w4zm611l
cmqkbflu4000mjl04b8ge3w52	คั่วกลาง	0.00	cmqkbflu4000kjl043wwelkgv	cmpraghfn000a3xj3le4hn9nj
cmqkbflu4000pjl04zl2vc0dg	คั่วกลาง	0.00	cmqkbflu4000njl04y50uh4jk	cmpraghfn000a3xj3le4hn9nj
cmqkbflu4000qjl04kzgks0cv	ไม่หวาน 0%	0.00	cmqkbflu4000njl04y50uh4jk	cmprak1wr000d3xj3791vuavv
cmq7janpb000f3xjtefll9ori	หวานน้อย 50%	0.00	cmq7janpb000d3xjt314q8i2w	cmprak1wr000e3xj3e60lzs1w
cmq7janpb000g3xjteho1e9q3	ปั่น	10.00	cmq7janpb000d3xjt314q8i2w	cmpran7d3000m3xj3znj3klm9
cmq7lhpbt0005ie04rkcn0olm	ไม่หวาน 0%	0.00	cmq7lhpbt0003ie041qvyepmi	cmprak1wr000d3xj3791vuavv
cmq7lhpbt0006ie04idqknb0q	เย็น	0.00	cmq7lhpbt0003ie041qvyepmi	cmpran7d3000l3xj3w4zm611l
cmq7lnnpr0003l4042mwqzurw	หวานปกติ 100%	0.00	cmq7lnnpr0001l404r51avyc9	cmprak1ws000f3xj35gi3varl
cmq7lnnpr0006l404apkj1csu	คั่วกลาง	0.00	cmq7lnnpr0004l404hc8caaq9	cmpraghfn000a3xj3le4hn9nj
cmq7lnnpr0007l404kmjf2i22	ไม่หวาน 0%	0.00	cmq7lnnpr0004l404hc8caaq9	cmprak1wr000d3xj3791vuavv
cmq7lnnpr000al404yhwj5bwt	หวานน้อย 50%	0.00	cmq7lnnpr0008l404wr6kxffy	cmprak1wr000e3xj3e60lzs1w
cmq7lnnpr000dl4047ybs1mk0	หวานปกติ 100%	0.00	cmq7lnnpr000bl40424anubmz	cmprak1ws000f3xj35gi3varl
cmq7lnnpr000el404u9efep5l	เย็น	0.00	cmq7lnnpr000bl40424anubmz	cmpran7d3000l3xj3w4zm611l
cmq7mbhri0009la0445gmv4lz	หวานปกติ 100%	0.00	cmq7mbhri0007la04tbhdp6od	cmq3v6ydv0001js04mbuyt8in
cmq7mf1n4000hla04rw1kg9mx	หวานน้อย 50%	0.00	cmq7mf1n4000fla0423jnlj68	cmprak1wr000e3xj3e60lzs1w
cmq7mf1n4000ila04tbs7y8ig	เย็น	0.00	cmq7mf1n4000fla0423jnlj68	cmpran7d3000l3xj3w4zm611l
cmq7mjt2a0005jr04s28ria8v	คั่วกลาง	0.00	cmq7mjt2a0003jr04lp2690gt	cmpraghfn000a3xj3le4hn9nj
cmq7mjt2a0006jr04ud2wkfyi	หวานปกติ 100%	0.00	cmq7mjt2a0003jr04lp2690gt	cmprak1ws000f3xj35gi3varl
cmq7mjt2a0009jr04vzf1ofta	หวานปกติ 100%	0.00	cmq7mjt2a0007jr048v6nvwum	cmprak1ws000f3xj35gi3varl
cmq7mjt2a000ajr04a4pbb9fg	เย็น	0.00	cmq7mjt2a0007jr048v6nvwum	cmpran7d3000l3xj3w4zm611l
cmq7mkear000gjr04lbnjf0td	หวานน้อย 50%	0.00	cmq7mkear000ejr04zi3db1v1	cmprak1wr000e3xj3e60lzs1w
cmq7msmeq0005jy04hnq7jfld	หวานน้อย 50%	0.00	cmq7msmeq0003jy042wuhu21v	cmprak1wr000e3xj3e60lzs1w
cmq7msmeq0006jy042yh1nth6	เย็น	0.00	cmq7msmeq0003jy042wuhu21v	cmpran7d3000l3xj3w4zm611l
cmq7msmeq0009jy04sidggrrx	หวานมาก 120%	0.00	cmq7msmeq0007jy0419gax114	cmprak1ws000g3xj3pdboyhw3
cmq7nrx8e0005l104n9xqwpgs	หวานน้อย 50%	0.00	cmq7nrx8e0003l104pebgbkc2	cmprak1wr000e3xj3e60lzs1w
cmq7nrx8e0008l1048bdx1lr8	หวานน้อย 50%	0.00	cmq7nrx8e0006l104bns2jz6r	cmprak1wr000e3xj3e60lzs1w
cmq7nsx2m0005l504ana2s2gr	หวานน้อย 50%	0.00	cmq7nsx2l0003l504dxf5djxy	cmprak1wr000e3xj3e60lzs1w
cmq7nsx2m0006l504e5br3a30	เย็น	0.00	cmq7nsx2l0003l504dxf5djxy	cmpran7d3000l3xj3w4zm611l
cmq7nsx2m0009l5047j2ma4u9	หวานปกติ 100%	0.00	cmq7nsx2m0007l504ptcwo0b4	cmprak1ws000f3xj35gi3varl
cmq7nsx2m000al5048eua1fdc	เย็น	0.00	cmq7nsx2m0007l504ptcwo0b4	cmpran7d3000l3xj3w4zm611l
cmq7ntbey000il5043xbxjmb0	คั่วกลาง	0.00	cmq7ntbey000gl504ia4gtofi	cmpraghfn000a3xj3le4hn9nj
cmq7ntbey000jl504hnjpsazv	ไม่หวาน 0%	0.00	cmq7ntbey000gl504ia4gtofi	cmprak1wr000d3xj3791vuavv
cmq7nxaav000gl104x3homsyq	คั่วเข้ม	0.00	cmq7nxaav000el104zxiubb51	cmpraghfn00093xj3teu0s9ye
cmq7nxaav000hl104kusn31hi	ไม่หวาน 0%	0.00	cmq7nxaav000el104zxiubb51	cmprak1wr000d3xj3791vuavv
cmq7o16oh000rl504eh974u7u	หวานน้อย 50%	0.00	cmq7o16oh000pl504tu81oo3q	cmprak1wr000e3xj3e60lzs1w
cmq8nljlp0004k504ypsy19wi	ไม่หวาน 0%	0.00	cmq8nljlp0002k5048zzwr1mf	cmprak1wr000d3xj3791vuavv
cmq8nljlp0007k504x0jz8xli	คั่วอ่อน	0.00	cmq8nljlp0005k5041k0nsq9l	cmpraghfn000b3xj33nmkm7g2
cmq8nljlp0008k504eqvi1ice	ไม่หวาน 0%	0.00	cmq8nljlp0005k5041k0nsq9l	cmprak1wr000d3xj3791vuavv
cmq8nljlp000bk504j8vzlmzn	หวานปกติ 100%	0.00	cmq8nljlp0009k5049mszim4t	cmprak1ws000f3xj35gi3varl
cmq8nljlp000ck5049ancz4ej	เย็น	0.00	cmq8nljlp0009k5049mszim4t	cmpran7d3000l3xj3w4zm611l
cmq8nljlp000fk504kh3lhbx5	เย็น	0.00	cmq8nljlp000dk504euwrl1rp	cmpran7d3000l3xj3w4zm611l
cmqljgn1c0008l2047zsmul9w	คั่วเข้ม	0.00	cmqljgn1c0006l204qkicyzu0	cmpraghfn00093xj3teu0s9ye
cmq8nljlp000ik5049wyvciu7	หวานปกติ 100%	0.00	cmq8nljlp000gk504e4obetly	cmprak1ws000f3xj35gi3varl
cmq8nljlq000jk504ycn9uurb	เย็น	0.00	cmq8nljlp000gk504e4obetly	cmpran7d3000l3xj3w4zm611l
cmq8nljlq000mk504v0yu2s17	หวานน้อย 50%	0.00	cmq8nljlq000kk504xagfsarr	cmprak1wr000e3xj3e60lzs1w
cmq8nljlq000nk504ebswxcpw	เย็น	0.00	cmq8nljlq000kk504xagfsarr	cmpran7d3000l3xj3w4zm611l
cmq8okvww0004jv043t2d84xl	แยกน้ำแข็ง	0.00	cmq8okvww0002jv04ddvulcop	cmpraptea000o3xj3zfahd2f7
cmq8okvww0005jv04u26r5nyb	หวานปกติ 100%	0.00	cmq8okvww0002jv04ddvulcop	cmq3v6ydv0001js04mbuyt8in
cmq8okvww0008jv0401ouqxew	คั่วกลาง	0.00	cmq8okvww0006jv04c8zer634	cmpraghfn000a3xj3le4hn9nj
cmq8okvww0009jv042t713bi4	ไม่หวาน 0%	0.00	cmq8okvww0006jv04c8zer634	cmprak1wr000d3xj3791vuavv
cmq8okvww000cjv04z1h265kg	คั่วกลาง	0.00	cmq8okvww000ajv04bmywlw5e	cmpraghfn000a3xj3le4hn9nj
cmq8okvww000djv04s9qvi77j	หวานน้อย 50%	0.00	cmq8okvww000ajv04bmywlw5e	cmprak1wr000e3xj3e60lzs1w
cmq8okvww000ejv04iirt6ny8	แยกน้ำแข็ง	0.00	cmq8okvww000ajv04bmywlw5e	cmpraptea000o3xj3zfahd2f7
cmq8okvww000hjv04q17vw2e5	หวานน้อย 50%	0.00	cmq8okvww000fjv04w7bq3iw6	cmprak1wr000e3xj3e60lzs1w
cmq8okvww000ijv04gs2krjui	เย็น	0.00	cmq8okvww000fjv04w7bq3iw6	cmpran7d3000l3xj3w4zm611l
cmq8okvww000jjv04jkfz6s9c	แยกน้ำแข็ง	0.00	cmq8okvww000fjv04w7bq3iw6	cmpraptea000o3xj3zfahd2f7
cmq8ovw370004k304pxh8991x	หวานน้อย 50%	0.00	cmq8ovw370002k304zt6wxbcs	cmprak1wr000e3xj3e60lzs1w
cmq8ovw370005k3048zmzb9p2	เพิ่มช็อต	10.00	cmq8ovw370002k304zt6wxbcs	cmpralv7i000j3xj3b1u9nwyo
cmq8ovw370006k304b8rc7muz	เย็น	0.00	cmq8ovw370002k304zt6wxbcs	cmpran7d3000l3xj3w4zm611l
cmq8ovw370007k304xpu5wzr8	แยกน้ำแข็ง	0.00	cmq8ovw370002k304zt6wxbcs	cmpraptea000o3xj3zfahd2f7
cmq8pnnoi0005ih04gvgsn3hl	คั่วเข้ม	0.00	cmq8pnnoi0003ih04t9njc3bt	cmpraghfn00093xj3teu0s9ye
cmq8pnnoi0006ih04g2bspyua	ไม่หวาน 0%	0.00	cmq8pnnoi0003ih04t9njc3bt	cmprak1wr000d3xj3791vuavv
cmq8pnnoi0009ih04wsfeafpg	หวานปกติ 100%	0.00	cmq8pnnoi0007ih04o8k2dfw9	cmprak1ws000f3xj35gi3varl
cmq8prlhk0004js04jm8wzdc7	คั่วเข้ม	0.00	cmq8prlhk0002js04k4rxxhzq	cmpraghfn00093xj3teu0s9ye
cmq8prlhk0005js04a4r4trgl	ไม่หวาน 0%	0.00	cmq8prlhk0002js04k4rxxhzq	cmprak1wr000d3xj3791vuavv
cmq8qbbiz0005i804aiokjsff	คั่วเข้ม	0.00	cmq8qbbiz0003i804iyidqut0	cmpraghfn00093xj3teu0s9ye
cmq8qbbiz0006i804whkrhlyw	ไม่หวาน 0%	0.00	cmq8qbbiz0003i804iyidqut0	cmprak1wr000d3xj3791vuavv
cmq8qbnil000ei804ebkddwo2	ไม่หวาน 0%	0.00	cmq8qbnil000ci804mnhbinug	cmprak1wr000d3xj3791vuavv
cmq8qbnil000fi804gi2ziti8	เพิ่มช็อต	10.00	cmq8qbnil000ci804mnhbinug	cmpralv7i000j3xj3b1u9nwyo
cmq8qcmk4000oi804z3sntp82	คั่วเข้ม	0.00	cmq8qcmk4000mi804tprjqxrh	cmpraghfn00093xj3teu0s9ye
cmq8qcmk4000pi8047l1s8e7u	ไม่หวาน 0%	0.00	cmq8qcmk4000mi804tprjqxrh	cmprak1wr000d3xj3791vuavv
cmq8qji0m0005i604lvs4757x	หวานปกติ 100%	0.00	cmq8qji0m0003i604hz87urxj	cmprak1ws000f3xj35gi3varl
cmq8qji0m0006i604gdh76nf6	เย็น	0.00	cmq8qji0m0003i604hz87urxj	cmpran7d3000l3xj3w4zm611l
cmq8qny5x000ei604glj1j6w0	หวานน้อย 50%	0.00	cmq8qny5x000ci604zgzl1jd5	cmprak1wr000e3xj3e60lzs1w
cmq8qny5x000fi604s6osef01	เย็น	0.00	cmq8qny5x000ci604zgzl1jd5	cmpran7d3000l3xj3w4zm611l
cmq8r28ci0004jo04b1f344o0	หวานน้อย 50%	0.00	cmq8r28ci0002jo04up5iwwpp	cmprak1wr000e3xj3e60lzs1w
cmq8r28ci0005jo04mnezrqr5	เย็น	0.00	cmq8r28ci0002jo04up5iwwpp	cmpran7d3000l3xj3w4zm611l
cmq8rbxw4000ejo04p0v44o3n	หวานน้อย 50%	0.00	cmq8rbxw4000cjo04je8cdpfj	cmprak1wr000e3xj3e60lzs1w
cmq8rbxw4000fjo04vnag4jax	เย็น	0.00	cmq8rbxw4000cjo04je8cdpfj	cmpran7d3000l3xj3w4zm611l
cmq8rbxw4000ijo04fgkihemu	คั่วเข้ม	0.00	cmq8rbxw4000gjo04e2f8polf	cmpraghfn00093xj3teu0s9ye
cmq8rbxw4000jjo048nvfmyk4	ไม่หวาน 0%	0.00	cmq8rbxw4000gjo04e2f8polf	cmprak1wr000d3xj3791vuavv
cmq8rbxw4000kjo045xsy9bo4	แยกน้ำแข็ง	0.00	cmq8rbxw4000gjo04e2f8polf	cmpraptea000o3xj3zfahd2f7
cmq8rcyq0000qjo0499b9zkog	คั่วกลาง	0.00	cmq8rcypz000ojo04cnczoefl	cmpraghfn000a3xj3le4hn9nj
cmq8rcyq0000rjo04saxuldtq	ไม่หวาน 0%	0.00	cmq8rcypz000ojo04cnczoefl	cmprak1wr000d3xj3791vuavv
cmq8rcyq0000sjo0491pim2d3	แยกน้ำแข็ง	0.00	cmq8rcypz000ojo04cnczoefl	cmpraptea000o3xj3zfahd2f7
cmq8rmcgi0007l204k7uwv9dy	หวานน้อย 50%	0.00	cmq8rmcgi0005l204gtufx548	cmprak1wr000e3xj3e60lzs1w
cmq8rmcgi0008l2044od9hx3e	เย็น	0.00	cmq8rmcgi0005l204gtufx548	cmpran7d3000l3xj3w4zm611l
cmq8rn7ag000vi6046eqg6iy3	คั่วเข้ม	0.00	cmq8rn7ag000ti604r31lc73d	cmpraghfn00093xj3teu0s9ye
cmq8rn7ag000wi604p5vnjtws	หวานปกติ 100%	0.00	cmq8rn7ag000ti604r31lc73d	cmq3v6ydv0001js04mbuyt8in
cmq8rns440010jo04f0uj5coj	คั่วเข้ม	0.00	cmq8rns44000yjo04fur3dhmv	cmpraghfn00093xj3teu0s9ye
cmq8rns440011jo04zcg27zme	ไม่หวาน 0%	0.00	cmq8rns44000yjo04fur3dhmv	cmprak1wr000d3xj3791vuavv
cmq8rns440012jo04vnsswjw6	แยกน้ำแข็ง	0.00	cmq8rns44000yjo04fur3dhmv	cmpraptea000o3xj3zfahd2f7
cmq8ry5kw0012i60455ompfs8	หวานน้อย 50%	0.00	cmq8ry5kw0010i604selrtwwy	cmprak1wr000e3xj3e60lzs1w
cmq8ry5kw0013i60489fehviz	เย็น	0.00	cmq8ry5kw0010i604selrtwwy	cmpran7d3000l3xj3w4zm611l
cmq8rybua0019i604myisun70	หวานปกติ 100%	0.00	cmq8rybua0017i6040l1m3vkc	cmprak1ws000f3xj35gi3varl
cmq8s3ukb0005l104f1xqatcr	หวานปกติ 100%	0.00	cmq8s3ukb0003l1043791cace	cmprak1ws000f3xj35gi3varl
cmq8s3ukb0006l10477hgtji6	เย็น	0.00	cmq8s3ukb0003l1043791cace	cmpran7d3000l3xj3w4zm611l
cmq8sbfk2000kl104zu34aa9c	หวานปกติ 100%	0.00	cmq8sbfk2000il1041gw6hgj4	cmprak1ws000f3xj35gi3varl
cmq8sbfk2000ll1045ar92nbw	เย็น	0.00	cmq8sbfk2000il1041gw6hgj4	cmpran7d3000l3xj3w4zm611l
cmqk5qumb0004l20436tjpq21	หวานปกติ 100%	0.00	cmqk5qumb0002l204e8q6dt41	cmprak1ws000f3xj35gi3varl
cmqk5qumb0005l204n1pzj4qm	แยกน้ำแข็ง	0.00	cmqk5qumb0002l204e8q6dt41	cmpraptea000o3xj3zfahd2f7
cmq8sjv70000zl104jd09605p	คั่วกลาง	0.00	cmq8sjv70000xl104d09gwo8e	cmpraghfn000a3xj3le4hn9nj
cmq8vjo4w0005js04embhkudl	คั่วเข้ม	0.00	cmq8vjo4w0003js04x3jbx1w5	cmpraghfn00093xj3teu0s9ye
cmq8vo54e0005jx049s0o1v7z	หวานมาก 120%	0.00	cmq8vo54e0003jx04kw7legq0	cmprak1ws000g3xj3pdboyhw3
cmq8vo54e0006jx044c8k7f35	เย็น	0.00	cmq8vo54e0003jx04kw7legq0	cmpran7d3000l3xj3w4zm611l
cmq8vojuw000cjx04xk07qudg	หวานปกติ 100%	0.00	cmq8vojuw000ajx04bs9oujar	cmprak1ws000f3xj35gi3varl
cmq8vojuw000djx04c5uacdc8	เย็น	0.00	cmq8vojuw000ajx04bs9oujar	cmpran7d3000l3xj3w4zm611l
cmq8voquw000jjx04yeza21x4	คั่วเข้ม	0.00	cmq8voquw000hjx04y3q1j5jj	cmpraghfn00093xj3teu0s9ye
cmq8voquw000kjx0401spc832	ไม่หวาน 0%	0.00	cmq8voquw000hjx04y3q1j5jj	cmprak1wr000d3xj3791vuavv
cmq8vuj1e000qjx04kjrglzpb	คั่วเข้ม	0.00	cmq8vuj1e000ojx04fxt9l5gy	cmpraghfn00093xj3teu0s9ye
cmq8vuj1e000rjx04zu36xqyj	ไม่หวาน 0%	0.00	cmq8vuj1e000ojx04fxt9l5gy	cmprak1wr000d3xj3791vuavv
cmq8vzsb70005kt04ifas675l	คั่วเข้ม	0.00	cmq8vzsb60003kt04x4e9tk69	cmpraghfn00093xj3teu0s9ye
cmq8vzsb70006kt048u93a0pr	ไม่หวาน 0%	0.00	cmq8vzsb60003kt04x4e9tk69	cmprak1wr000d3xj3791vuavv
cmq8vzsb70007kt04jfjjs1kz	เพิ่มช็อต	10.00	cmq8vzsb60003kt04x4e9tk69	cmpralv7i000j3xj3b1u9nwyo
cmq8vzsb7000akt047ka9ot3i	หวานน้อย 50%	0.00	cmq8vzsb70008kt04akjvr7jw	cmprak1wr000e3xj3e60lzs1w
cmq8vzsb7000bkt04lae04qyo	เพิ่มช็อต	10.00	cmq8vzsb70008kt04akjvr7jw	cmpralv7i000j3xj3b1u9nwyo
cmq8vzsb7000ckt04sdkme745	เย็น	0.00	cmq8vzsb70008kt04akjvr7jw	cmpran7d3000l3xj3w4zm611l
cmq8vzsb7000fkt048km1yigo	หวานปกติ 100%	0.00	cmq8vzsb7000dkt045d1enck0	cmprak1ws000f3xj35gi3varl
cmq8vzsb7000gkt040epu4nvt	เย็น	0.00	cmq8vzsb7000dkt045d1enck0	cmpran7d3000l3xj3w4zm611l
cmq8widpi0005jn04vu8qogxf	หวานน้อย 50%	0.00	cmq8widpi0003jn04mhhhxkvv	cmprak1wr000e3xj3e60lzs1w
cmq8widpi0008jn040c3nftz0	หวานน้อย 50%	0.00	cmq8widpi0006jn04hhrb47f5	cmprak1wr000e3xj3e60lzs1w
cmq8widpi0009jn04kx1bjagi	เย็น	0.00	cmq8widpi0006jn04hhrb47f5	cmpran7d3000l3xj3w4zm611l
cmq8wkfs7000hjn04x9ii2wzi	คั่วกลาง	0.00	cmq8wkfs7000fjn04hsgth2ni	cmpraghfn000a3xj3le4hn9nj
cmq8wkfs7000ijn04eo5l7vj5	หวานน้อย 50%	0.00	cmq8wkfs7000fjn04hsgth2ni	cmprak1wr000e3xj3e60lzs1w
cmq8wkfs7000ljn04nsdwms0w	หวานน้อย 50%	0.00	cmq8wkfs7000jjn04tvoe69u5	cmprak1wr000e3xj3e60lzs1w
cmq8wtc0v000tjn04l1c8reji	คั่วกลาง	0.00	cmq8wtc0v000rjn04xju5affs	cmpraghfn000a3xj3le4hn9nj
cmq8wtc0v000ujn046z6eja17	หวานน้อย 50%	0.00	cmq8wtc0v000rjn04xju5affs	cmprak1wr000e3xj3e60lzs1w
cmq8xx7x70005l104x5lyh8sn	คั่วกลาง	0.00	cmq8xx7x70003l104u5cm40m6	cmpraghfn000a3xj3le4hn9nj
cmq8xx7x70006l104euqivvdl	ไม่หวาน 0%	0.00	cmq8xx7x70003l104u5cm40m6	cmprak1wr000d3xj3791vuavv
cmq8y8txt000dl104xi7khps1	หวานปกติ 100%	0.00	cmq8y8txt000bl104ow81scdl	cmprak1ws000f3xj35gi3varl
cmq8y8txt000gl104155gjpio	คั่วกลาง	0.00	cmq8y8txt000el104wxj7eicf	cmpraghfn000a3xj3le4hn9nj
cmq8y8txt000hl104oiod78cf	ไม่หวาน 0%	0.00	cmq8y8txt000el104wxj7eicf	cmprak1wr000d3xj3791vuavv
cmq8y8txt000kl104cyhcydlj	หวานน้อย 50%	0.00	cmq8y8txt000il104j1t8kimp	cmprak1wr000e3xj3e60lzs1w
cmq92k7200005jl04qwryn48x	หวานปกติ 100%	0.00	cmq92k7200003jl04su2lej8o	cmprak1ws000f3xj35gi3varl
cmq92k7200006jl04zxsd1sdg	เย็น	0.00	cmq92k7200003jl04su2lej8o	cmpran7d3000l3xj3w4zm611l
cmq92lzws000cjl04wyiuy3au	หวานปกติ 100%	0.00	cmq92lzws000ajl04y3nxblhj	cmprak1ws000f3xj35gi3varl
cmq92lzws000djl04mhuoghry	เย็น	0.00	cmq92lzws000ajl04y3nxblhj	cmpran7d3000l3xj3w4zm611l
cmq92lzws000gjl0413j0hms2	หวานน้อย 50%	0.00	cmq92lzws000ejl04vmd60ebg	cmprak1wr000e3xj3e60lzs1w
cmq92lzws000jjl04f6t5j7cy	คั่วกลาง	0.00	cmq92lzws000hjl04s6h6x95e	cmpraghfn000a3xj3le4hn9nj
cmq92lzws000kjl04os4xp017	หวานปกติ 100%	0.00	cmq92lzws000hjl04s6h6x95e	cmprak1ws000f3xj35gi3varl
cmq93ntbk0005jy04hbfcn80i	คั่วเข้ม	0.00	cmq93ntbk0003jy04bxcxft9p	cmpraghfn00093xj3teu0s9ye
cmq93ntbk0006jy04t0nrzyu0	ไม่หวาน 0%	0.00	cmq93ntbk0003jy04bxcxft9p	cmprak1wr000d3xj3791vuavv
cmq93ntbk0009jy04vz62d6fb	หวานปกติ 100%	0.00	cmq93ntbk0007jy049qvdrduv	cmprak1ws000f3xj35gi3varl
cmq93ntbk000ajy04dz924yhu	เย็น	0.00	cmq93ntbk0007jy049qvdrduv	cmpran7d3000l3xj3w4zm611l
cmq93ntbl000djy04l7sa7ty4	คั่วเข้ม	0.00	cmq93ntbk000bjy04i1mgvv1r	cmpraghfn00093xj3teu0s9ye
cmq93ntbl000ejy040hlot08s	ไม่หวาน 0%	0.00	cmq93ntbk000bjy04i1mgvv1r	cmprak1wr000d3xj3791vuavv
cmq93ntbl000hjy04jlj3ozpe	หวานปกติ 100%	0.00	cmq93ntbl000fjy04o7phtu8q	cmprak1ws000f3xj35gi3varl
cmq93ntbl000ijy04qxe8mgdz	เย็น	0.00	cmq93ntbl000fjy04o7phtu8q	cmpran7d3000l3xj3w4zm611l
cmq95z0oq0005jf04nk8gxdmg	หวานปกติ 100%	0.00	cmq95z0oq0003jf04yhzks9a0	cmprak1ws000f3xj35gi3varl
cmq95z0oq0006jf0496qgicwd	เย็น	0.00	cmq95z0oq0003jf04yhzks9a0	cmpran7d3000l3xj3w4zm611l
cmqa7hftw0006ju04dkt5wte0	คั่วเข้ม	0.00	cmqa7hftw0004ju0470gfu69e	cmpraghfn00093xj3teu0s9ye
cmqa7hftw0007ju04hkaful1i	ไม่หวาน 0%	0.00	cmqa7hftw0004ju0470gfu69e	cmprak1wr000d3xj3791vuavv
cmqa7hxla000fju043dpl1l5w	คั่วกลาง	0.00	cmqa7hxla000dju047ec7hadt	cmpraghfn000a3xj3le4hn9nj
cmqa7hxla000gju04iyb78sl5	หวานน้อย 50%	0.00	cmqa7hxla000dju047ec7hadt	cmprak1wr000e3xj3e60lzs1w
cmqa7k8bs0005ic04h3lzk4bf	คั่วเข้ม	0.00	cmqa7k8bs0003ic04uwggy53m	cmpraghfn00093xj3teu0s9ye
cmqa7k8bs0006ic04bayr6p5u	ไม่หวาน 0%	0.00	cmqa7k8bs0003ic04uwggy53m	cmprak1wr000d3xj3791vuavv
cmqa7o7xd000mju046fyvkq9i	หวานปกติ 100%	0.00	cmqa7o7xd000kju04shs6d1qj	cmprak1ws000f3xj35gi3varl
cmqa7o7xd000pju046otufz4b	หวานปกติ 100%	0.00	cmqa7o7xd000nju04z5ugdxq7	cmprak1ws000f3xj35gi3varl
cmqa7o7xd000qju04x9nq796f	เย็น	0.00	cmqa7o7xd000nju04z5ugdxq7	cmpran7d3000l3xj3w4zm611l
cmqa88zjs0005la04f3blv47q	คั่วกลาง	0.00	cmqa88zjs0003la04q2anl5wl	cmpraghfn000a3xj3le4hn9nj
cmqa88zjs0006la043eypgcyl	หวานน้อย 50%	0.00	cmqa88zjs0003la04q2anl5wl	cmprak1wr000e3xj3e60lzs1w
cmqa88zjs0009la04fav54hbw	คั่วกลาง	0.00	cmqa88zjs0007la044iviyf7s	cmpraghfn000a3xj3le4hn9nj
cmqa88zjs000ala0493nxzzk6	หวานปกติ 100%	0.00	cmqa88zjs0007la044iviyf7s	cmq3v6ydv0001js04mbuyt8in
cmqa94h6c0005i904ilc7sask	คั่วเข้ม	0.00	cmqa94h6c0003i904o4qfc66n	cmpraghfn00093xj3teu0s9ye
cmqa94h6c0006i9042yxy4e4x	ไม่หวาน 0%	0.00	cmqa94h6c0003i904o4qfc66n	cmprak1wr000d3xj3791vuavv
cmqa96bl10005l804nopu7fh9	คั่วอ่อน	0.00	cmqa96bl10003l804rr71ss26	cmpraghfn000b3xj33nmkm7g2
cmqa96bl10006l804fkixq699	หวานปกติ 100%	0.00	cmqa96bl10003l804rr71ss26	cmq3v6ydv0001js04mbuyt8in
cmqa9l9hl0005la04qlz24pm8	หวานปกติ 100%	0.00	cmqa9l9hl0003la04q6ynce8f	cmprak1ws000f3xj35gi3varl
cmqa9s7vd000el8045ntrz8wr	คั่วกลาง	0.00	cmqa9s7vd000cl804qi0rjxi1	cmpraghfn000a3xj3le4hn9nj
cmqa9s7vd000fl804bhm6h7w0	ไม่หวาน 0%	0.00	cmqa9s7vd000cl804qi0rjxi1	cmprak1wr000d3xj3791vuavv
cmqk5tdqv000ijo04osnjj787	คั่วเข้ม	0.00	cmqk5tdqv000gjo046qx2wush	cmpraghfn00093xj3teu0s9ye
cmqa9x3do000ml804wvt0km0x	คั่วกลาง	0.00	cmqa9x3do000kl804khucikea	cmpraghfn000a3xj3le4hn9nj
cmqa9x3do000nl804ir353kre	ไม่หวาน 0%	0.00	cmqa9x3do000kl804khucikea	cmprak1wr000d3xj3791vuavv
cmqaa58vu000pla04a44puq0h	หวานน้อย 50%	0.00	cmqaa58vu000nla04o5hc34ug	cmprak1wr000e3xj3e60lzs1w
cmqaa58vu000qla04ucpitx0f	เย็น	0.00	cmqaa58vu000nla04o5hc34ug	cmpran7d3000l3xj3w4zm611l
cmqaa5r3f000wl804d7y2q8rd	คั่วเข้ม	0.00	cmqaa5r3f000ul804rek3qnvr	cmpraghfn00093xj3teu0s9ye
cmqaa5r3f000xl804022lej8z	ไม่หวาน 0%	0.00	cmqaa5r3f000ul804rek3qnvr	cmprak1wr000d3xj3791vuavv
cmqaa6ttv0013l804gyjwr26c	คั่วกลาง	0.00	cmqaa6ttu0011l804bowjwwi2	cmpraghfn000a3xj3le4hn9nj
cmqaa6ttv0014l804c14wyblt	หวานน้อย 50%	0.00	cmqaa6ttu0011l804bowjwwi2	cmprak1wr000e3xj3e60lzs1w
cmqaa6ttv0017l804pmryqm2m	หวานน้อย 50%	0.00	cmqaa6ttv0015l8040z1xvtgc	cmprak1wr000e3xj3e60lzs1w
cmqaa6ttv001al804m8v8odj0	หวานน้อย 50%	0.00	cmqaa6ttv0018l804lui1zl3f	cmprak1wr000e3xj3e60lzs1w
cmqaa6ttv001bl804fl23k0j7	เย็น	0.00	cmqaa6ttv0018l804lui1zl3f	cmpran7d3000l3xj3w4zm611l
cmqaa98d3000xla04d6edrkuh	หวานปกติ 100%	0.00	cmqaa98d2000vla04vjdkeh2i	cmprak1ws000f3xj35gi3varl
cmqaan28g0005ky04j98h54h7	คั่วเข้ม	0.00	cmqaan28g0003ky04lajdowfq	cmpraghfn00093xj3teu0s9ye
cmqaan28g0006ky04si8mp7bz	หวานปกติ 100%	0.00	cmqaan28g0003ky04lajdowfq	cmq3v6ydv0001js04mbuyt8in
cmqacvntk0005k004cvq37242	หวานน้อย 50%	0.00	cmqacvntj0003k004hrao4xzv	cmprak1wr000e3xj3e60lzs1w
cmqacvntk0006k004obycd7iy	เย็น	0.00	cmqacvntj0003k004hrao4xzv	cmpran7d3000l3xj3w4zm611l
cmqacvntk0009k004fyi1m8o7	หวานปกติ 100%	0.00	cmqacvntk0007k004a0jtzmql	cmq3v6ydv0001js04mbuyt8in
cmqae0r1z0005l404nn5vg0v4	หวานปกติ 100%	0.00	cmqae0r1z0003l404a83vncfc	cmprak1ws000f3xj35gi3varl
cmqae0r1z0006l404zhc8rzje	เย็น	0.00	cmqae0r1z0003l404a83vncfc	cmpran7d3000l3xj3w4zm611l
cmqae26dv0005l504piz82hto	คั่วเข้ม	0.00	cmqae26dv0003l504w79xpmxk	cmpraghfn00093xj3teu0s9ye
cmqae26dv0006l5041xhhb3wl	ไม่หวาน 0%	0.00	cmqae26dv0003l504w79xpmxk	cmprak1wr000d3xj3791vuavv
cmqae4s3p000el50432m92jxa	หวานปกติ 100%	0.00	cmqae4s3p000cl504du0hrplz	cmprak1ws000f3xj35gi3varl
cmqae4s3p000fl504tz5hgeto	เย็น	0.00	cmqae4s3p000cl504du0hrplz	cmpran7d3000l3xj3w4zm611l
cmqaee63v000el404i7c07q64	หวานน้อย 50%	0.00	cmqaee63v000cl404l9a71eht	cmprak1wr000e3xj3e60lzs1w
cmqaehamv000ml4049b4mevc7	หวานน้อย 50%	0.00	cmqaehamv000kl4045l11lxkj	cmprak1wr000e3xj3e60lzs1w
cmqaehamv000nl404ms113op5	เย็น	0.00	cmqaehamv000kl4045l11lxkj	cmpran7d3000l3xj3w4zm611l
cmqaffjas0005l504gz789nhz	หวานปกติ 100%	0.00	cmqaffjas0003l504mry5t925	cmprak1ws000f3xj35gi3varl
cmqaffjas0006l5049r1hkk1v	เย็น	0.00	cmqaffjas0003l504mry5t925	cmpran7d3000l3xj3w4zm611l
cmqaib4eu0005l204tgs3dt35	หวานปกติ 100%	0.00	cmqaib4eu0003l204w00z9dab	cmprak1ws000f3xj35gi3varl
cmqaib4eu0006l204y2yxznob	เย็น	0.00	cmqaib4eu0003l204w00z9dab	cmpran7d3000l3xj3w4zm611l
cmqaice7v0005l704f13wbfid	คั่วกลาง	0.00	cmqaice7v0003l704cytrgry5	cmpraghfn000a3xj3le4hn9nj
cmqaice7v0006l704c2ncvdji	หวานปกติ 100%	0.00	cmqaice7v0003l704cytrgry5	cmq3v6ydv0001js04mbuyt8in
cmqaipwww0005ib04ttjufm4o	หวานน้อย 50%	0.00	cmqaipwww0003ib04s0z1jdgh	cmprak1wr000e3xj3e60lzs1w
cmqaipwww0006ib04bftov6h2	เย็น	0.00	cmqaipwww0003ib04s0z1jdgh	cmpran7d3000l3xj3w4zm611l
cmqaiqg54000cib040zlauyjo	หวานน้อย 50%	0.00	cmqaiqg54000aib04mzxzv88v	cmprak1wr000e3xj3e60lzs1w
cmqair9hn000iib04056ylhsr	หวานปกติ 100%	0.00	cmqair9hn000gib04iwqir1th	cmprak1ws000f3xj35gi3varl
cmqaj4e6f0009ky04r9fgixe5	คั่วเข้ม	0.00	cmqaj4e6e0007ky04iif1reyc	cmpraghfn00093xj3teu0s9ye
cmqaj4e6f000aky04h597y3at	ไม่หวาน 0%	0.00	cmqaj4e6e0007ky04iif1reyc	cmprak1wr000d3xj3791vuavv
cmqaj4e6f000dky04oxup6eg3	หวานปกติ 100%	0.00	cmqaj4e6f000bky04jg9bbeoh	cmprak1ws000f3xj35gi3varl
cmqaj4e6f000eky04jenoc4o0	เย็น	0.00	cmqaj4e6f000bky04jg9bbeoh	cmpran7d3000l3xj3w4zm611l
cmqajkqki0007i804gnjjamq2	คั่วเข้ม	0.00	cmqajkqki0005i804r8uxw6mb	cmpraghfn00093xj3teu0s9ye
cmqajkqki0008i804b0c52jti	ไม่หวาน 0%	0.00	cmqajkqki0005i804r8uxw6mb	cmprak1wr000d3xj3791vuavv
cmqajq74g0005ld04bpov4gwt	หวานปกติ 100%	0.00	cmqajq74g0003ld04fqe99q6z	cmq3v6ydv0001js04mbuyt8in
cmqajq74g0008ld0434qejsvm	หวานปกติ 100%	0.00	cmqajq74g0006ld04lbr1s6w2	cmprak1ws000f3xj35gi3varl
cmqajq74g0009ld04k6jvrgpe	ปั่น	10.00	cmqajq74g0006ld04lbr1s6w2	cmpran7d3000m3xj3znj3klm9
cmqajq74g000cld04ma2zlzaz	หวานน้อย 50%	0.00	cmqajq74g000ald044j4dyv7i	cmprak1wr000e3xj3e60lzs1w
cmqajq74g000dld048rfa9jn4	เย็น	0.00	cmqajq74g000ald044j4dyv7i	cmpran7d3000l3xj3w4zm611l
cmqajq74g000gld04p4ti6kqd	หวานน้อย 50%	0.00	cmqajq74g000eld04n7y89de9	cmprak1wr000e3xj3e60lzs1w
cmqdv1n69000p3xap9l7dvv1v	หวานปกติ 100%	0.00	cmqdv1n69000n3xaplesekuyw	cmprak1ws000f3xj35gi3varl
cmqdv4b94000u3xaphidz6pyo	หวานปกติ 100%	0.00	cmqdv4b94000s3xapublsfx15	cmprak1ws000f3xj35gi3varl
cmqdw3eni0003jv04spadg1bt	หวานน้อย 50%	0.00	cmqdw3eni0001jv04ixt79zcf	cmprak1wr000e3xj3e60lzs1w
cmqdw3eni0004jv04w8bvyuje	เย็น	0.00	cmqdw3eni0001jv04ixt79zcf	cmpran7d3000l3xj3w4zm611l
cmqdw5v990004lb0447pxv2w5	คั่วเข้ม	0.00	cmqdw5v990002lb040gsjc9kw	cmpraghfn00093xj3teu0s9ye
cmqdw5v990005lb046lghbq8f	หวานปกติ 100%	0.00	cmqdw5v990002lb040gsjc9kw	cmq3v6ydv0001js04mbuyt8in
cmqee26ja0005i005jvggavo7	หวานมาก 120%	0.00	cmqee26ja0003i0050obohixh	cmprak1ws000g3xj3pdboyhw3
cmqeev0u00004l704rj2st5ib	คั่วอ่อน	0.00	cmqeev0u00002l704yghohhip	cmpraghfn000b3xj33nmkm7g2
cmqeev0u00005l7043q4ofb63	ไม่หวาน 0%	0.00	cmqeev0u00002l704yghohhip	cmprak1wr000d3xj3791vuavv
cmqeev0u00008l7041md5yb4r	คั่วเข้ม	0.00	cmqeev0u00006l7043wk6ei9j	cmpraghfn00093xj3teu0s9ye
cmqeev0u00009l70457vq53wt	หวานปกติ 100%	0.00	cmqeev0u00006l7043wk6ei9j	cmq3v6ydv0001js04mbuyt8in
cmqeev0u0000cl704m8rzaqcq	หวานน้อย 50%	0.00	cmqeev0u0000al7047qj9w9j1	cmprak1wr000e3xj3e60lzs1w
cmqeev0u0000dl7042yslem7d	เย็น	0.00	cmqeev0u0000al7047qj9w9j1	cmpran7d3000l3xj3w4zm611l
cmqeev0u0000gl704pxsm0til	หวานน้อย 50%	0.00	cmqeev0u0000el704ni5ps1zy	cmprak1wr000e3xj3e60lzs1w
cmqeev0u0000hl704h034brhp	เย็น	0.00	cmqeev0u0000el704ni5ps1zy	cmpran7d3000l3xj3w4zm611l
cmqefljuh000rl7041pmhtb4o	ไม่หวาน 0%	0.00	cmqefljuh000pl704pkei6pe9	cmprak1wr000d3xj3791vuavv
cmqefljuh000sl7046hn4x5hq	เพิ่มช็อต	10.00	cmqefljuh000pl704pkei6pe9	cmpralv7i000j3xj3b1u9nwyo
cmqefmr0t000kjq04cxfoqnvc	คั่วเข้ม	0.00	cmqefmr0t000ijq044055ln09	cmpraghfn00093xj3teu0s9ye
cmqefmr0t000ljq049j5wgpgk	หวานปกติ 100%	0.00	cmqefmr0t000ijq044055ln09	cmq3v6ydv0001js04mbuyt8in
cmqefu4fg000ujq04kyttpc7f	หวานน้อย 50%	0.00	cmqefu4fg000sjq04u0lenu19	cmprak1wr000e3xj3e60lzs1w
cmqefz0ah0010l704u4mn8mik	หวานปกติ 100%	0.00	cmqefz0ah000yl704x0tgiu2k	cmprak1ws000f3xj35gi3varl
cmqefz0ah0011l7040lpefn66	เย็น	0.00	cmqefz0ah000yl704x0tgiu2k	cmpran7d3000l3xj3w4zm611l
cmqefz0ah0014l704kv69gguq	คั่วเข้ม	0.00	cmqefz0ah0012l704eyadolal	cmpraghfn00093xj3teu0s9ye
cmqefz0ah0015l704eqg4ihfy	ไม่หวาน 0%	0.00	cmqefz0ah0012l704eyadolal	cmprak1wr000d3xj3791vuavv
cmqeg6svc0010jq04zb02pg4l	หวานปกติ 100%	0.00	cmqeg6svc000yjq04jursp7ej	cmprak1ws000f3xj35gi3varl
cmqeg6svc0011jq04r12mdedc	เย็น	0.00	cmqeg6svc000yjq04jursp7ej	cmpran7d3000l3xj3w4zm611l
cmqeg8tsi0017jq047yiml6k5	หวานปกติ 100%	0.00	cmqeg8tsi0015jq0414reonof	cmprak1ws000f3xj35gi3varl
cmqeg8tsi0018jq04inmh7ukc	เย็น	0.00	cmqeg8tsi0015jq0414reonof	cmpran7d3000l3xj3w4zm611l
cmqegd94j0005ju04hrv2dgf0	หวานน้อย 50%	0.00	cmqegd94j0003ju04of0h4y6z	cmprak1wr000e3xj3e60lzs1w
cmqegd94j0006ju04qeh06rq4	เย็น	0.00	cmqegd94j0003ju04of0h4y6z	cmpran7d3000l3xj3w4zm611l
cmqege2tl0005l404upbj2aan	หวานน้อย 50%	0.00	cmqege2tl0003l404uo3yo0p4	cmprak1wr000e3xj3e60lzs1w
cmqege2tl0006l404ixr4jlk3	เย็น	0.00	cmqege2tl0003l404uo3yo0p4	cmpran7d3000l3xj3w4zm611l
cmqegeddl000bl404tpq7jvwt	คั่วกลาง	0.00	cmqegeddl0009l404m75uoceb	cmpraghfn000a3xj3le4hn9nj
cmqegeddl000cl404sj83kugn	ไม่หวาน 0%	0.00	cmqegeddl0009l404m75uoceb	cmprak1wr000d3xj3791vuavv
cmqegeddl000fl4044irmm20e	หวานน้อย 50%	0.00	cmqegeddl000dl404ddp8114f	cmprak1wr000e3xj3e60lzs1w
cmqegeddl000gl404aalkcc9r	เย็น	0.00	cmqegeddl000dl404ddp8114f	cmpran7d3000l3xj3w4zm611l
cmqeglb080005l2040ni5co1a	หวานปกติ 100%	0.00	cmqeglb080003l204v28egsyd	cmprak1ws000f3xj35gi3varl
cmqeglb080006l204r6au6m4z	เย็น	0.00	cmqeglb080003l204v28egsyd	cmpran7d3000l3xj3w4zm611l
cmqeglb080009l20477pvpa1i	หวานปกติ 100%	0.00	cmqeglb080007l204b7wfbosw	cmprak1ws000f3xj35gi3varl
cmqeglb08000al204v39ec1c0	เย็น	0.00	cmqeglb080007l204b7wfbosw	cmpran7d3000l3xj3w4zm611l
cmqegmynv000fl204q1ck1vrg	หวานมาก 120%	0.00	cmqegmynv000dl2046jbnhf3n	cmprak1ws000g3xj3pdboyhw3
cmqegmynv000gl204urv06vq0	เย็น	0.00	cmqegmynv000dl2046jbnhf3n	cmpran7d3000l3xj3w4zm611l
cmqegowpi000iju046e4c7wte	คั่วเข้ม	0.00	cmqegowpi000gju045r5bpnn6	cmpraghfn00093xj3teu0s9ye
cmqegowpi000jju04uxiukkcx	ไม่หวาน 0%	0.00	cmqegowpi000gju045r5bpnn6	cmprak1wr000d3xj3791vuavv
cmqegowpi000kju04elp8ly7m	เพิ่มช็อต	10.00	cmqegowpi000gju045r5bpnn6	cmpralv7i000j3xj3b1u9nwyo
cmqegrqdc000uju042cwjkz3g	หวานปกติ 100%	0.00	cmqegrqdc000sju04xj3x5yhd	cmq3v6ydv0001js04mbuyt8in
cmqegvt7g001bl70438wvrgcx	คั่วกลาง	0.00	cmqegvt7g0019l7044vhoh76o	cmpraghfn000a3xj3le4hn9nj
cmqegvt7g001cl704vm2o3995	ไม่หวาน 0%	0.00	cmqegvt7g0019l7044vhoh76o	cmprak1wr000d3xj3791vuavv
cmqegvt7g001dl704h8twxvr6	แยกน้ำแข็ง	0.00	cmqegvt7g0019l7044vhoh76o	cmpraptea000o3xj3zfahd2f7
cmqegvt7g001gl704wjpguugb	คั่วกลาง	0.00	cmqegvt7g001el704ssc145fy	cmpraghfn000a3xj3le4hn9nj
cmqegvt7g001hl70437ax32qy	หวานน้อย 50%	0.00	cmqegvt7g001el704ssc145fy	cmprak1wr000e3xj3e60lzs1w
cmqegvt7g001il70463n6y5p7	แยกน้ำแข็ง	0.00	cmqegvt7g001el704ssc145fy	cmpraptea000o3xj3zfahd2f7
cmqeh2whf0004l504z80ay580	หวานปกติ 100%	0.00	cmqeh2whf0002l504g4pt39rv	cmprak1ws000f3xj35gi3varl
cmqeh2whf0005l504kwadsiwq	เย็น	0.00	cmqeh2whf0002l504g4pt39rv	cmpran7d3000l3xj3w4zm611l
cmqeh5dnu000rl204gq4tkgd8	คั่วเข้ม	0.00	cmqeh5dnu000pl204wbmnzo4k	cmpraghfn00093xj3teu0s9ye
cmqeh5dnu000sl204k07xyj68	ไม่หวาน 0%	0.00	cmqeh5dnu000pl204wbmnzo4k	cmprak1wr000d3xj3791vuavv
cmqeh5r50000dl504e967hqcl	คั่วอ่อน	0.00	cmqeh5r50000bl5046u89cixd	cmpraghfn000b3xj33nmkm7g2
cmqeh5r50000el5046ximazpf	หวานปกติ 100%	0.00	cmqeh5r50000bl5046u89cixd	cmq3v6ydv0001js04mbuyt8in
cmqeh636w000nl504kj5m1zo1	หวานน้อย 50%	0.00	cmqeh636w000ll504cylbzloi	cmprak1wr000e3xj3e60lzs1w
cmqeh8n5o0010l204qot7n6yv	หวานปกติ 100%	0.00	cmqeh8n5o000yl2049kjr1iy1	cmprak1ws000f3xj35gi3varl
cmqeh8n5o0011l204611r9kub	เย็น	0.00	cmqeh8n5o000yl2049kjr1iy1	cmpran7d3000l3xj3w4zm611l
cmqehp0h4002al7048hczxyp2	คั่วกลาง	0.00	cmqehp0h40028l704b0uhqgfx	cmpraghfn000a3xj3le4hn9nj
cmqehp0h4002bl7040tdopeq1	ไม่หวาน 0%	0.00	cmqehp0h40028l704b0uhqgfx	cmprak1wr000d3xj3791vuavv
cmqk5tdqv000jjo04ai3su2ac	ไม่หวาน 0%	0.00	cmqk5tdqv000gjo046qx2wush	cmprak1wr000d3xj3791vuavv
cmqk5z6j50005jp04iyq5zrq3	หวานปกติ 100%	0.00	cmqk5z6j50003jp04sxw0nq33	cmprak1ws000f3xj35gi3varl
cmqehszu2002hl704skcd84sr	หวานปกติ 100%	0.00	cmqehszu2002fl704tp3jpbd7	cmprak1ws000f3xj35gi3varl
cmqehszu2002il704h7ug19ji	แยกน้ำแข็ง	0.00	cmqehszu2002fl704tp3jpbd7	cmpraptea000o3xj3zfahd2f7
cmqehwfio0006i304w3rjgvnf	คั่วเข้ม	0.00	cmqehwfio0004i304z3es6k93	cmpraghfn00093xj3teu0s9ye
cmqehwfio0007i304a7f45alw	หวานปกติ 100%	0.00	cmqehwfio0004i304z3es6k93	cmq3v6ydv0001js04mbuyt8in
cmqk65vn80005l7048t9xmxh5	หวานน้อย 50%	0.00	cmqk65vn80003l7045zxdhv6x	cmprak1wr000e3xj3e60lzs1w
cmqk65vn80006l704idjo8r7p	เย็น	0.00	cmqk65vn80003l7045zxdhv6x	cmpran7d3000l3xj3w4zm611l
cmqk68npo0005k4042d00g2ww	หวานน้อย 50%	0.00	cmqk68npo0003k404s9t5dmtq	cmprak1wr000e3xj3e60lzs1w
cmqk6blov0004la04jxql5ywg	คั่วกลาง	0.00	cmqk6blov0002la04czivg6nm	cmpraghfn000a3xj3le4hn9nj
cmqk6blov0005la048doqh2oq	หวานน้อย 50%	0.00	cmqk6blov0002la04czivg6nm	cmprak1wr000e3xj3e60lzs1w
cmqk6blov0006la04mos8192z	แยกน้ำแข็ง	0.00	cmqk6blov0002la04czivg6nm	cmpraptea000o3xj3zfahd2f7
cmqk6cn84000ela0404znb5qc	หวานน้อย 50%	0.00	cmqk6cn84000cla0452zyn0ah	cmprak1wr000e3xj3e60lzs1w
cmqljgn1c0009l20402usxp52	ไม่หวาน 0%	0.00	cmqljgn1c0006l204qkicyzu0	cmprak1wr000d3xj3791vuavv
cmqljgn1c000cl204224bdj8f	คั่วเข้ม	0.00	cmqljgn1c000al204up0tc0s4	cmpraghfn00093xj3teu0s9ye
cmqljgn1c000dl2040s3o76yd	หวานปกติ 100%	0.00	cmqljgn1c000al204up0tc0s4	cmq3v6ydv0001js04mbuyt8in
cmqljgn1c000gl204rncjqvoe	หวานน้อย 50%	0.00	cmqljgn1c000el204t0sv6gfb	cmprak1wr000e3xj3e60lzs1w
cmqljgn1c000hl2044ljkd02j	เย็น	0.00	cmqljgn1c000el204t0sv6gfb	cmpran7d3000l3xj3w4zm611l
cmqljgn1c000kl2045edm03g1	หวานปกติ 100%	0.00	cmqljgn1c000il204oa1i0qno	cmprak1ws000f3xj35gi3varl
cmqljgn1c000ll204ugfjaudu	เย็น	0.00	cmqljgn1c000il204oa1i0qno	cmpran7d3000l3xj3w4zm611l
cmqljrnd5000vl204aqjd5bkm	หวานมาก 120%	0.00	cmqljrnd5000tl204axfqmdgc	cmprak1ws000g3xj3pdboyhw3
cmqljrnd5000wl204gkqeppff	เย็น	0.00	cmqljrnd5000tl204axfqmdgc	cmpran7d3000l3xj3w4zm611l
cmqlksw6u000ejs04n2z6u9mj	คั่วกลาง	0.00	cmqlksw6u000cjs049khfras9	cmpraghfn000a3xj3le4hn9nj
cmqlksw6u000fjs041gf83y6v	หวานปกติ 100%	0.00	cmqlksw6u000cjs049khfras9	cmq3v6ydv0001js04mbuyt8in
cmqlksw6u000ijs04d5zvl3j0	คั่วเข้ม	0.00	cmqlksw6u000gjs04n1xtsmrs	cmpraghfn00093xj3teu0s9ye
cmqlksw6u000jjs040uyb7pln	ไม่หวาน 0%	0.00	cmqlksw6u000gjs04n1xtsmrs	cmprak1wr000d3xj3791vuavv
cmqlktqce0005l404y8z9wjpp	คั่วเข้ม	0.00	cmqlktqce0003l4049y56tlze	cmpraghfn00093xj3teu0s9ye
cmqlktqce0006l404nbnho1kv	ไม่หวาน 0%	0.00	cmqlktqce0003l4049y56tlze	cmprak1wr000d3xj3791vuavv
cmqlkxlik000pjs04ps5zio2y	หวานปกติ 100%	0.00	cmqlkxlik000njs0400wa5clf	cmprak1ws000f3xj35gi3varl
cmqlkxlik000qjs04d0v3580h	เย็น	0.00	cmqlkxlik000njs0400wa5clf	cmpran7d3000l3xj3w4zm611l
cmqllq1uj0026js049vjs56hf	คั่วเข้ม	0.00	cmqllq1ui0024js04aaqscchd	cmpraghfn00093xj3teu0s9ye
cmqllq1uj0027js04lbaj1t52	ไม่หวาน 0%	0.00	cmqllq1ui0024js04aaqscchd	cmprak1wr000d3xj3791vuavv
cmqllr38q0015l4045989f9sg	หวานน้อย 50%	0.00	cmqllr38q0013l404msl9iind	cmprak1wr000e3xj3e60lzs1w
cmqlltt0i001bl404jam20ler	หวานปกติ 100%	0.00	cmqlltt0i0019l404uxzs3x4p	cmprak1ws000f3xj35gi3varl
cmqllzdgh002djs04pva63sf8	หวานน้อย 50%	0.00	cmqllzdgh002bjs049a7zgb1u	cmprak1wr000e3xj3e60lzs1w
cmqlma3hg0005l504znvxalyl	หวานน้อย 50%	0.00	cmqlma3hg0003l504ws6xmz87	cmprak1wr000e3xj3e60lzs1w
cmqlma3hg0006l504kwokyg4w	เย็น	0.00	cmqlma3hg0003l504ws6xmz87	cmpran7d3000l3xj3w4zm611l
cmqlmbdat000dl504rm8297x2	คั่วเข้ม	0.00	cmqlmbdat000bl5048qz97jcf	cmpraghfn00093xj3teu0s9ye
cmqlmbdat000el504g7z67iw1	หวานปกติ 100%	0.00	cmqlmbdat000bl5048qz97jcf	cmq3v6ydv0001js04mbuyt8in
cmqlmh9vv0022l4042tyy0ob8	หวานน้อย 50%	0.00	cmqlmh9vv0020l4042rhsub2y	cmprak1wr000e3xj3e60lzs1w
cmqlmmlg80003l7042d8lmsgn	คั่วเข้ม	0.00	cmqlmmlg80001l704rkm0oo33	cmpraghfn00093xj3teu0s9ye
cmqlmmlg80004l704002xvafo	ไม่หวาน 0%	0.00	cmqlmmlg80001l704rkm0oo33	cmprak1wr000d3xj3791vuavv
cmqlmzkq5000nl504lssmzgl0	คั่วอ่อน	0.00	cmqlmzkq5000ll504nykztz1d	cmpraghfn000b3xj33nmkm7g2
cmqlmzkq5000ol504cdpy97a6	ไม่หวาน 0%	0.00	cmqlmzkq5000ll504nykztz1d	cmprak1wr000d3xj3791vuavv
cmqlmzkq5000rl5042nafoia8	หวานปกติ 100%	0.00	cmqlmzkq5000pl504ymd2gcwo	cmprak1ws000f3xj35gi3varl
cmqln2msy0011l5046ghqfnwn	หวานปกติ 100%	0.00	cmqln2msy000zl5041kzqknhn	cmprak1ws000f3xj35gi3varl
cmqln2msy0012l504hr7wf4gc	เย็น	0.00	cmqln2msy000zl5041kzqknhn	cmpran7d3000l3xj3w4zm611l
cmqlnazqr0005je04pxn54gjd	หวานปกติ 100%	0.00	cmqlnazqr0003je04wx2d800i	cmprak1ws000f3xj35gi3varl
cmqlrm6bc000gjp049pdt7rps	หวานปกติ 100%	0.00	cmqlrm6bc000ejp04ffmhm4fe	cmq3v6ydv0001js04mbuyt8in
cmqlrngve0003jx04pam5z7ta	หวานปกติ 100%	0.00	cmqlrngve0001jx04y5jotj9m	cmprak1ws000f3xj35gi3varl
cmqlrngve0004jx042lkasagx	เย็น	0.00	cmqlrngve0001jx04y5jotj9m	cmpran7d3000l3xj3w4zm611l
cmqlskn6o0005l704azat7fvg	คั่วเข้ม	0.00	cmqlskn6o0003l70468zobgxr	cmpraghfn00093xj3teu0s9ye
cmqlskn6o0006l704xtkq2kyu	ไม่หวาน 0%	0.00	cmqlskn6o0003l70468zobgxr	cmprak1wr000d3xj3791vuavv
cmqehk0ni0021l704k4s2dk42	คั่วเข้ม	0.00	cmqehk0ni001zl704mz87r46n	cmpraghfn00093xj3teu0s9ye
cmqehk0ni0022l704g5z7lvnl	ไม่หวาน 0%	0.00	cmqehk0ni001zl704mz87r46n	cmprak1wr000d3xj3791vuavv
cmqehnp01000xl50445gkn9lw	หวานมาก 120%	0.00	cmqehnp01000vl504r66ie4qy	cmprak1ws000g3xj3pdboyhw3
cmqehnp01000yl504f7xd0ge0	เย็น	0.00	cmqehnp01000vl504r66ie4qy	cmpran7d3000l3xj3w4zm611l
cmqehohi10016l504unfg1yfz	หวานน้อย 50%	0.00	cmqehohi10014l504wvcjpocr	cmprak1wr000e3xj3e60lzs1w
cmqehohi10017l504eeqwfwpx	เย็น	0.00	cmqehohi10014l504wvcjpocr	cmpran7d3000l3xj3w4zm611l
cmqehz0ar002pl70491u1oh3x	หวานน้อย 50%	0.00	cmqehz0ar002nl704cm2oryfc	cmprak1wr000e3xj3e60lzs1w
cmqehz0ar002ql7041ut8dune	เย็น	0.00	cmqehz0ar002nl704cm2oryfc	cmpran7d3000l3xj3w4zm611l
cmqei0bdj002yl70472v88kki	คั่วกลาง	0.00	cmqei0bdj002wl704ilzrnfsy	cmpraghfn000a3xj3le4hn9nj
cmqei0bdj002zl7047u5mrhje	หวานปกติ 100%	0.00	cmqei0bdj002wl704ilzrnfsy	cmq3v6ydv0001js04mbuyt8in
cmqei2gsk000gi304n2r9jzsz	หวานน้อย 50%	0.00	cmqei2gsj000ei3041sjvyqux	cmprak1wr000e3xj3e60lzs1w
cmqei2gsk000hi304y9dxg8qg	เย็น	0.00	cmqei2gsj000ei3041sjvyqux	cmpran7d3000l3xj3w4zm611l
cmqekpxv00005lb04nb6luip3	คั่วเข้ม	0.00	cmqekpxv00003lb04s9v43w8h	cmpraghfn00093xj3teu0s9ye
cmqekpxv00006lb04ghrz0f9z	หวานปกติ 100%	0.00	cmqekpxv00003lb04s9v43w8h	cmq3v6ydv0001js04mbuyt8in
cmqekqlft000elb04wl537bth	หวานปกติ 100%	0.00	cmqekqlft000clb04j7f24zhe	cmprak1ws000f3xj35gi3varl
cmqekqlft000flb04lmf04415	เย็น	0.00	cmqekqlft000clb04j7f24zhe	cmpran7d3000l3xj3w4zm611l
cmqekrmxr000nlb045fm03m80	หวานน้อย 50%	0.00	cmqekrmxr000llb04n85ha5jk	cmprak1wr000e3xj3e60lzs1w
cmqekrmxr000qlb04uas434nx	หวานน้อย 50%	0.00	cmqekrmxr000olb046w1b1aym	cmprak1wr000e3xj3e60lzs1w
cmqekv7060005lb04s37ga5kw	หวานน้อย 50%	0.00	cmqekv7060003lb04ey8xz7az	cmprak1wr000e3xj3e60lzs1w
cmqel2y52000ylb04hwuo6i06	คั่วเข้ม	0.00	cmqel2y52000wlb048hxqw2g2	cmpraghfn00093xj3teu0s9ye
cmqel2y52000zlb041zp7hjns	หวานปกติ 100%	0.00	cmqel2y52000wlb048hxqw2g2	cmq3v6ydv0001js04mbuyt8in
cmqel3f9c0017lb04paszsna5	คั่วเข้ม	0.00	cmqel3f9c0015lb041zemnyqd	cmpraghfn00093xj3teu0s9ye
cmqel3f9c0018lb040kinvkg1	ไม่หวาน 0%	0.00	cmqel3f9c0015lb041zemnyqd	cmprak1wr000d3xj3791vuavv
cmqel4u95001glb04hornx1rb	หวานน้อย 50%	0.00	cmqel4u94001elb04blmha5f7	cmprak1wr000e3xj3e60lzs1w
cmqel4u95001hlb043xr62w7x	เย็น	0.00	cmqel4u94001elb04blmha5f7	cmpran7d3000l3xj3w4zm611l
cmqel6vrh000blb044thm5s6w	คั่วกลาง	0.00	cmqel6vrh0009lb041gzx9a8x	cmpraghfn000a3xj3le4hn9nj
cmqel6vrh000clb04kwldl7ic	หวานปกติ 100%	0.00	cmqel6vrh0009lb041gzx9a8x	cmq3v6ydv0001js04mbuyt8in
cmqel7l3o001plb04xeo65rwn	หวานน้อย 50%	0.00	cmqel7l3o001nlb04dm0zapb1	cmprak1wr000e3xj3e60lzs1w
cmqel7l3o001qlb04169vvy09	เย็น	0.00	cmqel7l3o001nlb04dm0zapb1	cmpran7d3000l3xj3w4zm611l
cmqemetdn0005l204wwqc5fg2	คั่วกลาง	0.00	cmqemetdm0003l204v2u3bspc	cmpraghfn000a3xj3le4hn9nj
cmqemetdn0006l204c1k0ofhe	ไม่หวาน 0%	0.00	cmqemetdm0003l204v2u3bspc	cmprak1wr000d3xj3791vuavv
cmqemetdn0009l2043vci5uix	หวานปกติ 100%	0.00	cmqemetdn0007l204yru6y87n	cmprak1ws000f3xj35gi3varl
cmqemetdn000al2041ifydcae	เย็น	0.00	cmqemetdn0007l204yru6y87n	cmpran7d3000l3xj3w4zm611l
cmqeopz470005ih04p2pt2dgd	หวานน้อย 50%	0.00	cmqeopz470003ih0419d44a2d	cmprak1wr000e3xj3e60lzs1w
cmqeopz470006ih042j7w2pmd	เย็น	0.00	cmqeopz470003ih0419d44a2d	cmpran7d3000l3xj3w4zm611l
cmqeopz470009ih044owp5x9f	หวานปกติ 100%	0.00	cmqeopz470007ih04te96dp2s	cmprak1ws000f3xj35gi3varl
cmqeopz47000aih04onh43ks9	เย็น	0.00	cmqeopz470007ih04te96dp2s	cmpran7d3000l3xj3w4zm611l
cmqep5dbb000bl4041zbmxwkm	หวานน้อย 50%	0.00	cmqep5dbb0009l404if8wdyj0	cmprak1wr000e3xj3e60lzs1w
cmqep5dbb000cl404yz7segci	เย็น	0.00	cmqep5dbb0009l404if8wdyj0	cmpran7d3000l3xj3w4zm611l
cmqeq5v3i0005ib04ovvi8aq0	หวานปกติ 100%	0.00	cmqeq5v3h0003ib044ndkue2g	cmprak1ws000f3xj35gi3varl
cmqerio620005i504sjaxwbyh	หวานน้อย 50%	0.00	cmqerio620003i504au3p5wy3	cmprak1wr000e3xj3e60lzs1w
cmqerio620006i504ibb931te	เย็น	0.00	cmqerio620003i504au3p5wy3	cmpran7d3000l3xj3w4zm611l
cmqerio620009i504dit9n6rx	หวานปกติ 100%	0.00	cmqerio620007i5047dsay7o2	cmprak1ws000f3xj35gi3varl
cmqerozpe0005la043by57bke	คั่วเข้ม	0.00	cmqerozpe0003la04dkv28bmn	cmpraghfn00093xj3teu0s9ye
cmqerozpe0006la046ezw4vyh	หวานปกติ 100%	0.00	cmqerozpe0003la04dkv28bmn	cmq3v6ydv0001js04mbuyt8in
cmqerozpe0009la04f8n8afzc	หวานปกติ 100%	0.00	cmqerozpe0007la042xw7lv0k	cmprak1ws000f3xj35gi3varl
cmqerozpe000ala04pumaqok7	เย็น	0.00	cmqerozpe0007la042xw7lv0k	cmpran7d3000l3xj3w4zm611l
cmqfsqq750004ld04r1fmy0m0	คั่วอ่อน	0.00	cmqfsqq750002ld04qcasrb04	cmpraghfn000b3xj33nmkm7g2
cmqfsqq750005ld04e5iyfjo0	ไม่หวาน 0%	0.00	cmqfsqq750002ld04qcasrb04	cmprak1wr000d3xj3791vuavv
cmqfsqq750008ld049sgc0gl6	ไม่หวาน 0%	0.00	cmqfsqq750006ld049eryqg3g	cmprak1wr000d3xj3791vuavv
cmqfsqq75000bld04vgp4xmjv	หวานปกติ 100%	0.00	cmqfsqq750009ld04ojap6fku	cmprak1ws000f3xj35gi3varl
cmqfsqq75000cld041xynn29g	เย็น	0.00	cmqfsqq750009ld04ojap6fku	cmpran7d3000l3xj3w4zm611l
cmqfsqq75000fld04dqfexu5o	คั่วเข้ม	0.00	cmqfsqq75000dld049oza7sls	cmpraghfn00093xj3teu0s9ye
cmqfsqq75000gld040t0a88kc	หวานปกติ 100%	0.00	cmqfsqq75000dld049oza7sls	cmq3v6ydv0001js04mbuyt8in
cmqfsqq76000jld04m119ofhm	หวานน้อย 50%	0.00	cmqfsqq76000hld04okvlmo6h	cmprak1wr000e3xj3e60lzs1w
cmqfsqq76000kld04i5uniqbv	เย็น	0.00	cmqfsqq76000hld04okvlmo6h	cmpran7d3000l3xj3w4zm611l
cmqftvv5r0004ld04o0w3dc5c	หวานปกติ 100%	0.00	cmqftvv5r0002ld04iio5vqtu	cmprak1ws000f3xj35gi3varl
cmqftvv5r0005ld04wvjxp067	เย็น	0.00	cmqftvv5r0002ld04iio5vqtu	cmpran7d3000l3xj3w4zm611l
cmqftvv5r0006ld043u4usmjw	แยกน้ำแข็ง	0.00	cmqftvv5r0002ld04iio5vqtu	cmpraptea000o3xj3zfahd2f7
cmqftvv5r0009ld04zfiqtgyj	คั่วเข้ม	0.00	cmqftvv5r0007ld049b4qijgp	cmpraghfn00093xj3teu0s9ye
cmqftvv5r000ald04s1uikn6j	ไม่หวาน 0%	0.00	cmqftvv5r0007ld049b4qijgp	cmprak1wr000d3xj3791vuavv
cmqftvv5r000bld04i9tf3wh6	แยกน้ำแข็ง	0.00	cmqftvv5r0007ld049b4qijgp	cmpraptea000o3xj3zfahd2f7
cmqftvv5r000eld04gu4hh3z2	หวานปกติ 100%	0.00	cmqftvv5r000cld04ykbrbbb6	cmprak1ws000f3xj35gi3varl
cmqftvv5r000fld0494sfykeb	เย็น	0.00	cmqftvv5r000cld04ykbrbbb6	cmpran7d3000l3xj3w4zm611l
cmqftvv5r000gld04gfrqekrk	แยกน้ำแข็ง	0.00	cmqftvv5r000cld04ykbrbbb6	cmpraptea000o3xj3zfahd2f7
cmqftvv5r000jld04qg7gybos	คั่วกลาง	0.00	cmqftvv5r000hld04gx052gpf	cmpraghfn000a3xj3le4hn9nj
cmqftvv5r000kld043628ib13	ไม่หวาน 0%	0.00	cmqftvv5r000hld04gx052gpf	cmprak1wr000d3xj3791vuavv
cmqftvv5r000lld04qo5wk26w	แยกน้ำแข็ง	0.00	cmqftvv5r000hld04gx052gpf	cmpraptea000o3xj3zfahd2f7
cmqftvv5r000old04q0mbv1uj	คั่วกลาง	0.00	cmqftvv5r000mld04bg7kwctr	cmpraghfn000a3xj3le4hn9nj
cmqftvv5r000pld041mvl00hd	หวานน้อย 50%	0.00	cmqftvv5r000mld04bg7kwctr	cmprak1wr000e3xj3e60lzs1w
cmqftvv5r000sld04aqt7q1ww	คั่วเข้ม	0.00	cmqftvv5r000qld0416mwglrr	cmpraghfn00093xj3teu0s9ye
cmqftvv5r000tld04q6kgtfuf	ไม่หวาน 0%	0.00	cmqftvv5r000qld0416mwglrr	cmprak1wr000d3xj3791vuavv
cmqfud7nf0012ld04lszgbzjm	หวานมาก 120%	0.00	cmqfud7nf0010ld04uovbir90	cmprak1ws000g3xj3pdboyhw3
cmqfud7nf0013ld04jpf6hzji	เย็น	0.00	cmqfud7nf0010ld04uovbir90	cmpran7d3000l3xj3w4zm611l
cmqfuyyrc0007l804ab3b9c5n	คั่วเข้ม	0.00	cmqfuyyrc0005l804qt5hu9z5	cmpraghfn00093xj3teu0s9ye
cmqfuyyrc0008l804b2z1dxo9	ไม่หวาน 0%	0.00	cmqfuyyrc0005l804qt5hu9z5	cmprak1wr000d3xj3791vuavv
cmqfuyyrc000bl804wdyn8bln	คั่วกลาง	0.00	cmqfuyyrc0009l804s7iuxy5g	cmpraghfn000a3xj3le4hn9nj
cmqfuyyrc000cl804k4ofcgp5	หวานปกติ 100%	0.00	cmqfuyyrc0009l804s7iuxy5g	cmq3v6ydv0001js04mbuyt8in
cmqfvbu550005ks047jinlp2a	คั่วเข้ม	0.00	cmqfvbu550003ks04ktlf7fxm	cmpraghfn00093xj3teu0s9ye
cmqfvbu550006ks04fy5envq4	ไม่หวาน 0%	0.00	cmqfvbu550003ks04ktlf7fxm	cmprak1wr000d3xj3791vuavv
cmqfvcak9000dks04gggtbt8r	คั่วกลาง	0.00	cmqfvcak9000bks04a31zcg27	cmpraghfn000a3xj3le4hn9nj
cmqfvcak9000eks04npg804gx	ไม่หวาน 0%	0.00	cmqfvcak9000bks04a31zcg27	cmprak1wr000d3xj3791vuavv
cmqfvh4rl000nks0404ko7i3n	หวานปกติ 100%	0.00	cmqfvh4rl000lks043mc4yvy4	cmprak1ws000f3xj35gi3varl
cmqfvh4rl000oks04mn8m5ghc	เย็น	0.00	cmqfvh4rl000lks043mc4yvy4	cmpran7d3000l3xj3w4zm611l
cmqfvi9rs0005jv04ebbji8y2	คั่วเข้ม	0.00	cmqfvi9rs0003jv04qjzxh1my	cmpraghfn00093xj3teu0s9ye
cmqfvi9rs0006jv04feivmuxz	ไม่หวาน 0%	0.00	cmqfvi9rs0003jv04qjzxh1my	cmprak1wr000d3xj3791vuavv
cmqfvsiw8000cjv04os0pxo87	หวานน้อย 50%	0.00	cmqfvsiw8000ajv0474ifzzck	cmprak1wr000e3xj3e60lzs1w
cmqfvsiw8000djv04e1xb78s0	เย็น	0.00	cmqfvsiw8000ajv0474ifzzck	cmpran7d3000l3xj3w4zm611l
cmqfw2cld000ljv047c4byu6i	หวานปกติ 100%	0.00	cmqfw2cld000jjv04bo6m6zdi	cmq3v6ydv0001js04mbuyt8in
cmqfw96qm000tjv04oxl5ys1k	หวานน้อย 50%	0.00	cmqfw96qm000rjv04e01zbyzp	cmprak1wr000e3xj3e60lzs1w
cmqfw96qm000ujv04gz27v79u	เย็น	0.00	cmqfw96qm000rjv04e01zbyzp	cmpran7d3000l3xj3w4zm611l
cmqfwds850005l4047dw4864o	หวานปกติ 100%	0.00	cmqfwds850003l404vkp4p6ta	cmprak1ws000f3xj35gi3varl
cmqfwio8o000cl404t2pa84ok	คั่วเข้ม	0.00	cmqfwio8o000al4043ye078wm	cmpraghfn00093xj3teu0s9ye
cmqfwio8o000dl404p0fd7zoe	ไม่หวาน 0%	0.00	cmqfwio8o000al4043ye078wm	cmprak1wr000d3xj3791vuavv
cmqfwio8o000el404oas2xl42	แยกน้ำแข็ง	0.00	cmqfwio8o000al4043ye078wm	cmpraptea000o3xj3zfahd2f7
cmqfwuju30013jv045tk82ygd	หวานน้อย 50%	0.00	cmqfwuju30011jv04m5u6gzau	cmprak1wr000e3xj3e60lzs1w
cmqfwuju30014jv048o3wuczu	เย็น	0.00	cmqfwuju30011jv04m5u6gzau	cmpran7d3000l3xj3w4zm611l
cmqfx13wb000nl404q1sgorsn	คั่วเข้ม	0.00	cmqfx13wb000ll404fs5qgdtq	cmpraghfn00093xj3teu0s9ye
cmqfx13wb000ol404vwhoizlb	หวานปกติ 100%	0.00	cmqfx13wb000ll404fs5qgdtq	cmq3v6ydv0001js04mbuyt8in
cmqfx1kkg000ul404ywz00w98	หวานปกติ 100%	0.00	cmqfx1kkg000sl404y277nm3f	cmprak1ws000f3xj35gi3varl
cmqfx1kkg000vl404rxt5pcyk	เย็น	0.00	cmqfx1kkg000sl404y277nm3f	cmpran7d3000l3xj3w4zm611l
cmqfxayic0005jp04abs8jeog	หวานปกติ 100%	0.00	cmqfxayic0003jp04iahs8m7q	cmprak1ws000f3xj35gi3varl
cmqg0d9w00005jo04uupgvxs6	คั่วเข้ม	0.00	cmqg0d9w00003jo04xldx9v97	cmpraghfn00093xj3teu0s9ye
cmqg0d9w00006jo049l2x1btl	ไม่หวาน 0%	0.00	cmqg0d9w00003jo04xldx9v97	cmprak1wr000d3xj3791vuavv
cmqg16zzg0005la04vb3x44w0	คั่วเข้ม	0.00	cmqg16zzf0003la0439395y36	cmpraghfn00093xj3teu0s9ye
cmqg16zzg0006la04zcob1boq	ไม่หวาน 0%	0.00	cmqg16zzf0003la0439395y36	cmprak1wr000d3xj3791vuavv
cmqg2ip9m000f3xzgftwtgumb	คั่วเข้ม	0.00	cmqg2ip9m000d3xzgf54xkssp	cmpraghfn00093xj3teu0s9ye
cmqg2ip9m000g3xzg9m5ww2fw	ไม่หวาน 0%	0.00	cmqg2ip9m000d3xzgf54xkssp	cmprak1wr000d3xj3791vuavv
cmqg2sz0x0005ic048ec301hc	คั่วกลาง	0.00	cmqg2sz0x0003ic04e4i1tqbj	cmpraghfn000a3xj3le4hn9nj
cmqg2sz0x0006ic04ivaeh94d	ไม่หวาน 0%	0.00	cmqg2sz0x0003ic04e4i1tqbj	cmprak1wr000d3xj3791vuavv
cmqg2sz0x0009ic045qvr367u	คั่วอ่อน	0.00	cmqg2sz0x0007ic048jd1uzpi	cmpraghfn000b3xj33nmkm7g2
cmqg2sz0x000aic04e9xj7fbf	หวานน้อย 50%	0.00	cmqg2sz0x0007ic048jd1uzpi	cmprak1wr000e3xj3e60lzs1w
cmqg3mdnz000y3xzgdzto1uuq	คั่วเข้ม	0.00	cmqg3mdnz000w3xzgt146lzst	cmpraghfn00093xj3teu0s9ye
cmqg3mdnz000z3xzggsa5wpfp	ไม่หวาน 0%	0.00	cmqg3mdnz000w3xzgt146lzst	cmprak1wr000d3xj3791vuavv
cmqg6xrh40005l8048pyoq0m7	คั่วอ่อน	0.00	cmqg6xrh40003l804i1rtn9sw	cmpraghfn000b3xj33nmkm7g2
cmqg6xrh40006l804rgiq4ovz	หวานปกติ 100%	0.00	cmqg6xrh40003l804i1rtn9sw	cmq3v6ydv0001js04mbuyt8in
cmqg70do0000cl8048f6m4psz	หวานปกติ 100%	0.00	cmqg70do0000al80422alkp28	cmprak1ws000f3xj35gi3varl
cmqg7bbm40005le046chj2c5v	หวานปกติ 100%	0.00	cmqg7bbm40003le04ooxllxho	cmq3v6ydv0001js04mbuyt8in
cmqg8o3ow0005k004bfvz50og	หวานน้อย 50%	0.00	cmqg8o3ow0003k004eaatyk1u	cmprak1wr000e3xj3e60lzs1w
cmqg8pwmb000dk004ip05gmfu	หวานน้อย 50%	0.00	cmqg8pwmb000bk004g4bkz2yq	cmprak1wr000e3xj3e60lzs1w
cmqg8pwmb000ek004nmx8a15m	เย็น	0.00	cmqg8pwmb000bk004g4bkz2yq	cmpran7d3000l3xj3w4zm611l
cmqg8w2n00005jg04r6vmvcml	หวานน้อย 50%	0.00	cmqg8w2n00003jg045vo40mzv	cmprak1wr000e3xj3e60lzs1w
cmqg8w2n00006jg04p0occslj	เย็น	0.00	cmqg8w2n00003jg045vo40mzv	cmpran7d3000l3xj3w4zm611l
cmqg93l3h000ejg044t8g3nfe	หวานปกติ 100%	0.00	cmqg93l3h000cjg04d3dmdr2t	cmprak1ws000f3xj35gi3varl
cmqg93l3h000fjg04j6el37s4	เย็น	0.00	cmqg93l3h000cjg04d3dmdr2t	cmpran7d3000l3xj3w4zm611l
cmqg9m8wk0005l204zo93yefm	หวานปกติ 100%	0.00	cmqg9m8wk0003l204k3onceim	cmprak1ws000f3xj35gi3varl
cmqg9m8wk0006l20406rqttm3	เย็น	0.00	cmqg9m8wk0003l204k3onceim	cmpran7d3000l3xj3w4zm611l
cmqh8wax00005jv04aitfdmzj	หวานปกติ 100%	0.00	cmqh8wax00003jv04n6tkj4tb	cmprak1ws000f3xj35gi3varl
cmqh8wax00006jv042s98yf3a	เย็น	0.00	cmqh8wax00003jv04n6tkj4tb	cmpran7d3000l3xj3w4zm611l
cmqh8wmrw000cjv04chb5t3ie	หวานมาก 120%	0.00	cmqh8wmrw000ajv04u1oxx6ba	cmprak1ws000g3xj3pdboyhw3
cmqh8wmrw000djv04lt1ytmnu	เย็น	0.00	cmqh8wmrw000ajv04u1oxx6ba	cmpran7d3000l3xj3w4zm611l
cmqh935b80004l804x8t55tzk	คั่วอ่อน	0.00	cmqh935b80002l804txf4y137	cmpraghfn000b3xj33nmkm7g2
cmqh935b80005l804y1e806nz	ไม่หวาน 0%	0.00	cmqh935b80002l804txf4y137	cmprak1wr000d3xj3791vuavv
cmqh935b80008l804oqvqj9ag	ไม่หวาน 0%	0.00	cmqh935b80006l80428mabp00	cmprak1wr000d3xj3791vuavv
cmqh935b80009l8049pda87j8	เย็น	0.00	cmqh935b80006l80428mabp00	cmpran7d3000l3xj3w4zm611l
cmqh9eh620004jp04pbqu6dot	คั่วเข้ม	0.00	cmqh9eh620002jp04xbp5jgrx	cmpraghfn00093xj3teu0s9ye
cmqh9eh620005jp04uudt4z5u	หวานปกติ 100%	0.00	cmqh9eh620002jp04xbp5jgrx	cmq3v6ydv0001js04mbuyt8in
cmqh9eh620008jp048sgqr3nc	หวานน้อย 50%	0.00	cmqh9eh620006jp04lylsf3ig	cmprak1wr000e3xj3e60lzs1w
cmqh9ho0j000hjp04oec95zr9	คั่วกลาง	0.00	cmqh9ho0j000fjp04sxpqie5e	cmpraghfn000a3xj3le4hn9nj
cmqh9ho0j000ijp047dd5biod	หวานน้อย 50%	0.00	cmqh9ho0j000fjp04sxpqie5e	cmprak1wr000e3xj3e60lzs1w
cmqh9ho0j000jjp043d2ved3h	แยกน้ำแข็ง	0.00	cmqh9ho0j000fjp04sxpqie5e	cmpraptea000o3xj3zfahd2f7
cmqh9ho0j000mjp04q7ystk2p	คั่วกลาง	0.00	cmqh9ho0j000kjp04igh75djm	cmpraghfn000a3xj3le4hn9nj
cmqh9ho0j000njp04sbvgvcei	ไม่หวาน 0%	0.00	cmqh9ho0j000kjp04igh75djm	cmprak1wr000d3xj3791vuavv
cmqh9ho0j000ojp04dl8nptbm	แยกน้ำแข็ง	0.00	cmqh9ho0j000kjp04igh75djm	cmpraptea000o3xj3zfahd2f7
cmqh9ho0j000rjp04xdzhj0aa	คั่วกลาง	0.00	cmqh9ho0j000pjp04d0faguga	cmpraghfn000a3xj3le4hn9nj
cmqh9ho0j000sjp04a0ul709i	ไม่หวาน 0%	0.00	cmqh9ho0j000pjp04d0faguga	cmprak1wr000d3xj3791vuavv
cmqh9ho0j000vjp04kt8rb4nn	คั่วเข้ม	0.00	cmqh9ho0j000tjp04ura0naeo	cmpraghfn00093xj3teu0s9ye
cmqh9ho0j000wjp04ec3pnprb	ไม่หวาน 0%	0.00	cmqh9ho0j000tjp04ura0naeo	cmprak1wr000d3xj3791vuavv
cmqh9ho0j000zjp04zpf1l4ab	หวานปกติ 100%	0.00	cmqh9ho0j000xjp044cz1khti	cmprak1ws000f3xj35gi3varl
cmqh9ho0j0010jp04ak4z3d7t	เย็น	0.00	cmqh9ho0j000xjp044cz1khti	cmpran7d3000l3xj3w4zm611l
cmqh9vl920005jp04djzpvqfr	คั่วเข้ม	0.00	cmqh9vl920003jp042w9xrqd8	cmpraghfn00093xj3teu0s9ye
cmqh9vl920006jp04c3ukswvh	ไม่หวาน 0%	0.00	cmqh9vl920003jp042w9xrqd8	cmprak1wr000d3xj3791vuavv
cmqh9vl920009jp04tltkxyyo	คั่วกลาง	0.00	cmqh9vl920007jp04nax6k0u7	cmpraghfn000a3xj3le4hn9nj
cmqh9vl92000ajp04x5n2a7n9	หวานปกติ 100%	0.00	cmqh9vl920007jp04nax6k0u7	cmq3v6ydv0001js04mbuyt8in
cmqhaf3ao0005la046sn4rvja	คั่วเข้ม	0.00	cmqhaf3ao0003la04kl004nkd	cmpraghfn00093xj3teu0s9ye
cmqhaf3ao0006la04gh3aldeo	ไม่หวาน 0%	0.00	cmqhaf3ao0003la04kl004nkd	cmprak1wr000d3xj3791vuavv
cmqhaoj8s0004l704l9ug09ns	คั่วอ่อน	0.00	cmqhaoj8s0002l704s4hl7jhi	cmpraghfn000b3xj33nmkm7g2
cmqhaoj8s0005l704d38wk8dd	ไม่หวาน 0%	0.00	cmqhaoj8s0002l704s4hl7jhi	cmprak1wr000d3xj3791vuavv
cmqhapsqa0005kz041veyw5fj	หวานน้อย 50%	0.00	cmqhapsqa0003kz0459o5rh8p	cmprak1wr000e3xj3e60lzs1w
cmqhaun1j000el704dgtwwha9	หวานน้อย 50%	0.00	cmqhaun1j000cl7048ua0mg6o	cmprak1wr000e3xj3e60lzs1w
cmqhb1lml000ela04ckha5fh5	คั่วเข้ม	0.00	cmqhb1lml000cla04vjr4p5n9	cmpraghfn00093xj3teu0s9ye
cmqhb1lml000fla044qz8t9lc	ไม่หวาน 0%	0.00	cmqhb1lml000cla04vjr4p5n9	cmprak1wr000d3xj3791vuavv
cmqhb2h2t000nl704iy4224oi	หวานน้อย 50%	0.00	cmqhb2h2t000ll704sjdeb5d3	cmprak1wr000e3xj3e60lzs1w
cmqhb2h2t000ol704naob3gpt	เย็น	0.00	cmqhb2h2t000ll704sjdeb5d3	cmpran7d3000l3xj3w4zm611l
cmqhb64x1000ekz048ta47e2m	หวานน้อย 50%	0.00	cmqhb64x1000ckz041ntz3w8g	cmprak1wr000e3xj3e60lzs1w
cmqhb64x1000fkz04xt1mp78j	เย็น	0.00	cmqhb64x1000ckz041ntz3w8g	cmpran7d3000l3xj3w4zm611l
cmqhb97pr0004jr049g7fvpbm	หวานปกติ 100%	0.00	cmqhb97pr0002jr04jw8phjcj	cmprak1ws000f3xj35gi3varl
cmqhbas6u000fjr04z6agb0j4	หวานน้อย 50%	0.00	cmqhbas6u000djr043talrgz4	cmprak1wr000e3xj3e60lzs1w
cmqhbas6u000gjr04ld5xt6yv	เย็น	0.00	cmqhbas6u000djr043talrgz4	cmpran7d3000l3xj3w4zm611l
cmqhbbzdo000ojr04jc29bclg	หวานปกติ 100%	0.00	cmqhbbzdo000mjr04rjgs1xhh	cmq3v6ydv0001js04mbuyt8in
cmqhbcv6a000nla04m12abvw3	คั่วเข้ม	0.00	cmqhbcv6a000lla04d2zxuamv	cmpraghfn00093xj3teu0s9ye
cmqhbcv6a000ola04poa0s9xb	หวานปกติ 100%	0.00	cmqhbcv6a000lla04d2zxuamv	cmq3v6ydv0001js04mbuyt8in
cmqhbejlf000wla046o4cn5jo	หวานน้อย 50%	0.00	cmqhbejle000ula04clxnaume	cmprak1wr000e3xj3e60lzs1w
cmqhbshph0005jv04sgibaceu	คั่วอ่อน	0.00	cmqhbshph0003jv048nr9nwbh	cmpraghfn000b3xj33nmkm7g2
cmqhbshph0006jv04fqsn837o	ไม่หวาน 0%	0.00	cmqhbshph0003jv048nr9nwbh	cmprak1wr000d3xj3791vuavv
cmqhbyltz0014la04e9jx54dw	หวานน้อย 50%	0.00	cmqhbyltz0012la04f25bgq64	cmprak1wr000e3xj3e60lzs1w
cmqhc7c29000cjv04ts95ji0z	หวานน้อย 50%	0.00	cmqhc7c29000ajv0413k7k1lz	cmprak1wr000e3xj3e60lzs1w
cmqhc7c29000djv04wltwmxiv	เย็น	0.00	cmqhc7c29000ajv0413k7k1lz	cmpran7d3000l3xj3w4zm611l
cmqhcltl70007kz04oeoll4g1	หวานปกติ 100%	0.00	cmqhcltl70005kz0496i4ckvx	cmprak1ws000f3xj35gi3varl
cmqhcpdm6000ljv04penzjt01	คั่วเข้ม	0.00	cmqhcpdm6000jjv044w0fi14n	cmpraghfn00093xj3teu0s9ye
cmqhcpdm7000mjv04h6fkae0v	หวานปกติ 100%	0.00	cmqhcpdm6000jjv044w0fi14n	cmq3v6ydv0001js04mbuyt8in
cmqhcrws3000ujv048wkpfbnk	คั่วกลาง	0.00	cmqhcrws3000sjv04x8ck4wk4	cmpraghfn000a3xj3le4hn9nj
cmqhcrws3000vjv04ah5n3xe2	ไม่หวาน 0%	0.00	cmqhcrws3000sjv04x8ck4wk4	cmprak1wr000d3xj3791vuavv
cmqhcun7e000fkz048i2jw5nv	หวานปกติ 100%	0.00	cmqhcun7e000dkz046qen5wzy	cmprak1ws000f3xj35gi3varl
cmqhd5r8y0005jm04w5gwffow	คั่วกลาง	0.00	cmqhd5r8y0003jm04j0aqm1p8	cmpraghfn000a3xj3le4hn9nj
cmqhd5r8y0006jm048ybeqmmt	ไม่หวาน 0%	0.00	cmqhd5r8y0003jm04j0aqm1p8	cmprak1wr000d3xj3791vuavv
cmqhfuqx50005jo04mt22lg6j	คั่วเข้ม	0.00	cmqhfuqx50003jo04uu2waoyi	cmpraghfn00093xj3teu0s9ye
cmqhfuqx50006jo04nkck54sk	ไม่หวาน 0%	0.00	cmqhfuqx50003jo04uu2waoyi	cmprak1wr000d3xj3791vuavv
cmqhfuqx50009jo04ns95tstl	หวานน้อย 50%	0.00	cmqhfuqx50007jo04n97ie2y2	cmprak1wr000e3xj3e60lzs1w
cmqhfuqx5000ajo04lrj6vd2x	เย็น	0.00	cmqhfuqx50007jo04n97ie2y2	cmpran7d3000l3xj3w4zm611l
cmqhg0ox90005l504jky28zlv	คั่วกลาง	0.00	cmqhg0ox90003l504u76qifky	cmpraghfn000a3xj3le4hn9nj
cmqhg0ox90006l504d27ehou6	หวานน้อย 50%	0.00	cmqhg0ox90003l504u76qifky	cmprak1wr000e3xj3e60lzs1w
cmqhg1n0u000cl504av4vg7oh	หวานน้อย 50%	0.00	cmqhg1n0u000al504j6i2ucqz	cmprak1wr000e3xj3e60lzs1w
cmqhg1n0u000dl504txko6jb7	เย็น	0.00	cmqhg1n0u000al504j6i2ucqz	cmpran7d3000l3xj3w4zm611l
cmqhg1n0u000gl50453rpk3xm	หวานปกติ 100%	0.00	cmqhg1n0u000el504vqwnbner	cmprak1ws000f3xj35gi3varl
cmqhi0sfq0005k0040umfd33y	คั่วเข้ม	0.00	cmqhi0sfq0003k0040k8uvg7x	cmpraghfn00093xj3teu0s9ye
cmqhi0sfq0006k004eql5o7gr	หวานน้อย 50%	0.00	cmqhi0sfq0003k0040k8uvg7x	cmprak1wr000e3xj3e60lzs1w
cmqhi0sfq0009k004kkbasxfm	หวานปกติ 100%	0.00	cmqhi0sfq0007k004uj5yu31n	cmprak1ws000f3xj35gi3varl
cmqhi0sfq000ak0043dpz9na6	เย็น	0.00	cmqhi0sfq0007k004uj5yu31n	cmpran7d3000l3xj3w4zm611l
cmqhl0ww20005lf04bzoovshe	หวานปกติ 100%	0.00	cmqhl0ww20003lf04v9uond56	cmprak1ws000f3xj35gi3varl
cmqhl0ww20006lf04sf6mo8v4	เย็น	0.00	cmqhl0ww20003lf04v9uond56	cmpran7d3000l3xj3w4zm611l
cmqhm46sx0005l10463kdgs8f	หวานน้อย 50%	0.00	cmqhm46sw0003l10404ufhmnl	cmprak1wr000e3xj3e60lzs1w
cmqhm46sx0006l104ihlyek4l	เย็น	0.00	cmqhm46sw0003l10404ufhmnl	cmpran7d3000l3xj3w4zm611l
cmqhm4yl3000cl104buaascgo	คั่วกลาง	0.00	cmqhm4yl3000al1042fbvcvzf	cmpraghfn000a3xj3le4hn9nj
cmqhm4yl3000dl1045nwzklxz	หวานปกติ 100%	0.00	cmqhm4yl3000al1042fbvcvzf	cmq3v6ydv0001js04mbuyt8in
cmqhmf4g4000jl104b3a4e3ix	หวานปกติ 100%	0.00	cmqhmf4g4000hl104h6bdho2a	cmq3v6ydv0001js04mbuyt8in
cmqhmhit10005l804h5b8jeja	หวานน้อย 50%	0.00	cmqhmhit10003l804bpiksvry	cmprak1wr000e3xj3e60lzs1w
cmqhmhit10006l804wqp6b2sa	เย็น	0.00	cmqhmhit10003l804bpiksvry	cmpran7d3000l3xj3w4zm611l
cmqhmhit10009l804fnxfk4m4	คั่วเข้ม	0.00	cmqhmhit10007l804w8u5zfjf	cmpraghfn00093xj3teu0s9ye
cmqhmhit1000al8043qmbhwwx	ไม่หวาน 0%	0.00	cmqhmhit10007l804w8u5zfjf	cmprak1wr000d3xj3791vuavv
cmqhmpg0q000il804wsnuuel0	หวานปกติ 100%	0.00	cmqhmpg0q000gl8045kxa29wp	cmprak1ws000f3xj35gi3varl
cmqhmppyq000ol8046wjpm3f5	หวานปกติ 100%	0.00	cmqhmppyq000ml8046idna3qk	cmprak1ws000f3xj35gi3varl
cmqhn1met000yl8043ph50g34	คั่วกลาง	0.00	cmqhn1met000wl804odytc90g	cmpraghfn000a3xj3le4hn9nj
cmqhn1met000zl804r0ojfuap	ไม่หวาน 0%	0.00	cmqhn1met000wl804odytc90g	cmprak1wr000d3xj3791vuavv
cmqhn1met0012l804staeh10w	หวานปกติ 100%	0.00	cmqhn1met0010l804bhh9gbq0	cmprak1ws000f3xj35gi3varl
cmqhn1met0015l8046rk5qtci	หวานน้อย 50%	0.00	cmqhn1met0013l804pnsbw9yj	cmprak1wr000e3xj3e60lzs1w
cmqhn2e8m000tl1043zpbs38z	หวานปกติ 100%	0.00	cmqhn2e8m000rl1047iv1mj0h	cmprak1ws000f3xj35gi3varl
cmqhn2e8m000ul104rjrz4hqh	เย็น	0.00	cmqhn2e8m000rl1047iv1mj0h	cmpran7d3000l3xj3w4zm611l
cmqhn2e8m000xl104axch5cnw	หวานน้อย 50%	0.00	cmqhn2e8m000vl104wgvrdmex	cmprak1wr000e3xj3e60lzs1w
cmqhn2e8m000yl104i2ajro6d	เย็น	0.00	cmqhn2e8m000vl104wgvrdmex	cmpran7d3000l3xj3w4zm611l
cmqinyyyb0004jy048hsphl9u	คั่วอ่อน	0.00	cmqinyyyb0002jy044nlcxm5w	cmpraghfn000b3xj33nmkm7g2
cmqinyyyb0005jy047hs6noun	ไม่หวาน 0%	0.00	cmqinyyyb0002jy044nlcxm5w	cmprak1wr000d3xj3791vuavv
cmqinyyyb0008jy04vifbxhlc	หวานปกติ 100%	0.00	cmqinyyyb0006jy04zsq3m4au	cmprak1ws000f3xj35gi3varl
cmqinyyyb0009jy04hc7qx9da	เย็น	0.00	cmqinyyyb0006jy04zsq3m4au	cmpran7d3000l3xj3w4zm611l
cmqinyyyb000cjy04fyck1cia	คั่วเข้ม	0.00	cmqinyyyb000ajy048ane04kh	cmpraghfn00093xj3teu0s9ye
cmqinyyyb000djy04xw3b6scf	หวานปกติ 100%	0.00	cmqinyyyb000ajy048ane04kh	cmq3v6ydv0001js04mbuyt8in
cmqinyyyb000gjy04qscdteeg	หวานน้อย 50%	0.00	cmqinyyyb000ejy04pmrm92ot	cmprak1wr000e3xj3e60lzs1w
cmqinyyyb000hjy040mxbwj9r	เย็น	0.00	cmqinyyyb000ejy04pmrm92ot	cmpran7d3000l3xj3w4zm611l
cmqiov38g0005l4044p24hrfn	คั่วเข้ม	0.00	cmqiov38g0003l404r8ft3yxt	cmpraghfn00093xj3teu0s9ye
cmqiov38g0006l404o16d7j6z	หวานปกติ 100%	0.00	cmqiov38g0003l404r8ft3yxt	cmprak1ws000f3xj35gi3varl
cmqiovbkk000cl404937c3okh	หวานมาก 120%	0.00	cmqiovbkk000al4047o5lyinp	cmprak1ws000g3xj3pdboyhw3
cmqiovbkk000dl404wp1e1fjn	เย็น	0.00	cmqiovbkk000al4047o5lyinp	cmpran7d3000l3xj3w4zm611l
cmqiptf510004l804p0d7d1ou	คั่วอ่อน	0.00	cmqiptf510002l80472h5b34s	cmpraghfn000b3xj33nmkm7g2
cmqiptf510005l8046tkluooa	ไม่หวาน 0%	0.00	cmqiptf510002l80472h5b34s	cmprak1wr000d3xj3791vuavv
cmqipw8mg0004lb04wdl22pnh	หวานปกติ 100%	0.00	cmqipw8mg0002lb04a6cghnat	cmprak1ws000f3xj35gi3varl
cmqipw8mg0005lb04nmmaq050	แยกน้ำแข็ง	0.00	cmqipw8mg0002lb04a6cghnat	cmpraptea000o3xj3zfahd2f7
cmqipzgaz000dlb040v2fshoo	หวานน้อย 50%	0.00	cmqipzgaz000blb042r5a1j7q	cmprak1wr000e3xj3e60lzs1w
cmqipzgaz000elb04h2aaw05q	เย็น	0.00	cmqipzgaz000blb042r5a1j7q	cmpran7d3000l3xj3w4zm611l
cmqiqeil8000plb04f559d0mj	คั่วเข้ม	0.00	cmqiqeil8000nlb04xpie7yed	cmpraghfn00093xj3teu0s9ye
cmqiqeil8000qlb0402anagij	ไม่หวาน 0%	0.00	cmqiqeil8000nlb04xpie7yed	cmprak1wr000d3xj3791vuavv
cmqk5u11m000qjo04cpq5nxqm	ไม่หวาน 0%	0.00	cmqk5u11m000njo04rfx46qzq	cmprak1wr000d3xj3791vuavv
cmqk63hou000bjp0461vnwllj	คั่วกลาง	0.00	cmqk63hot0009jp047rhw2dgz	cmpraghfn000a3xj3le4hn9nj
cmqk63hou000cjp04qgqsfyke	หวานปกติ 100%	0.00	cmqk63hot0009jp047rhw2dgz	cmq3v6ydv0001js04mbuyt8in
cmqk63hou000fjp04iyhe1g37	หวานปกติ 100%	0.00	cmqk63hou000djp04z89o7dej	cmprak1ws000f3xj35gi3varl
cmqk649d9000ljp04hedfowcx	คั่วกลาง	0.00	cmqk649d9000jjp044fsmqfs8	cmpraghfn000a3xj3le4hn9nj
cmqk649d9000mjp043loqywqy	หวานปกติ 100%	0.00	cmqk649d9000jjp044fsmqfs8	cmq3v6ydv0001js04mbuyt8in
cmqk6ntea000pla04zmfjfufw	หวานน้อย 50%	0.00	cmqk6ntea000nla04ttvyw250	cmprak1wr000e3xj3e60lzs1w
cmqk6ntea000qla04aq802ma2	เย็น	0.00	cmqk6ntea000nla04ttvyw250	cmpran7d3000l3xj3w4zm611l
cmqk6pw5a0012la04ky861cta	หวานน้อย 50%	0.00	cmqk6pw5a0010la04g97ri84s	cmprak1wr000e3xj3e60lzs1w
cmqk6pw5a0013la04nkm1ntwu	เย็น	0.00	cmqk6pw5a0010la04g97ri84s	cmpran7d3000l3xj3w4zm611l
cmqk6pw5a0014la04koy5segq	แยกน้ำแข็ง	0.00	cmqk6pw5a0010la04g97ri84s	cmpraptea000o3xj3zfahd2f7
cmqlk4vhi0004l304l7tx7469	คั่วเข้ม	0.00	cmqlk4vhi0002l304w4yu0rps	cmpraghfn00093xj3teu0s9ye
cmqlk4vhi0005l304nf0p0gi8	ไม่หวาน 0%	0.00	cmqlk4vhi0002l304w4yu0rps	cmprak1wr000d3xj3791vuavv
cmqlk4vhi0006l304fsuxv1vr	แยกน้ำแข็ง	0.00	cmqlk4vhi0002l304w4yu0rps	cmpraptea000o3xj3zfahd2f7
cmqlk4vhi0009l304q3hqfad8	คั่วกลาง	0.00	cmqlk4vhi0007l304sxhsmp5z	cmpraghfn000a3xj3le4hn9nj
cmqlk4vhi000al304eo1gurx8	ไม่หวาน 0%	0.00	cmqlk4vhi0007l304sxhsmp5z	cmprak1wr000d3xj3791vuavv
cmqlk4vhi000bl304gqzo809j	แยกน้ำแข็ง	0.00	cmqlk4vhi0007l304sxhsmp5z	cmpraptea000o3xj3zfahd2f7
cmqlk4vhi000el304sewwi4sm	คั่วกลาง	0.00	cmqlk4vhi000cl304r59lswsk	cmpraghfn000a3xj3le4hn9nj
cmqlk4vhi000fl304kyb3avam	หวานน้อย 50%	0.00	cmqlk4vhi000cl304r59lswsk	cmprak1wr000e3xj3e60lzs1w
cmqlk4vhi000gl304ua4lqwq6	แยกน้ำแข็ง	0.00	cmqlk4vhi000cl304r59lswsk	cmpraptea000o3xj3zfahd2f7
cmqlkrcmk0007js04nctsj1qn	ไม่หวาน 0%	0.00	cmqlkrcmk0005js04dfzgt97e	cmprak1wr000d3xj3791vuavv
cmqlkrcmk0008js04q3hsd6q3	เย็น	0.00	cmqlkrcmk0005js04dfzgt97e	cmpran7d3000l3xj3w4zm611l
cmqllcz5c0016js04tkmew6pd	หวานปกติ 100%	0.00	cmqllcz5c0014js041lvbpr5m	cmprak1ws000f3xj35gi3varl
cmqllcz5c0019js04y4lbojhy	คั่วเข้ม	0.00	cmqllcz5c0017js044cko4dgs	cmpraghfn00093xj3teu0s9ye
cmqllcz5c001ajs04nu256qqa	ไม่หวาน 0%	0.00	cmqllcz5c0017js044cko4dgs	cmprak1wr000d3xj3791vuavv
cmqlllkbn001ijs04009h8eyu	หวานปกติ 100%	0.00	cmqlllkbn001gjs04456qodb3	cmprak1ws000f3xj35gi3varl
cmqlllkbn001jjs04x5o9hg05	เย็น	0.00	cmqlllkbn001gjs04456qodb3	cmpran7d3000l3xj3w4zm611l
cmqllo09h001njs04oiboz5pu	หวานน้อย 50%	0.00	cmqllo09h001ljs04sfr2o6kk	cmprak1wr000e3xj3e60lzs1w
cmqllo09h001ojs04r5aenf69	เพิ่มช็อต	10.00	cmqllo09h001ljs04sfr2o6kk	cmpralv7i000j3xj3b1u9nwyo
cmqllo09h001pjs04dspo666s	เย็น	0.00	cmqllo09h001ljs04sfr2o6kk	cmpran7d3000l3xj3w4zm611l
cmqlloogx001ujs04oe2d5hbb	หวานน้อย 50%	0.00	cmqlloogx001sjs0492wy08ln	cmprak1wr000e3xj3e60lzs1w
cmqlloogx001vjs04bwzis14u	เย็น	0.00	cmqlloogx001sjs0492wy08ln	cmpran7d3000l3xj3w4zm611l
cmqllpdsf000pl4047r2612tu	หวานปกติ 100%	0.00	cmqllpdsf000nl404h9sn7738	cmprak1ws000f3xj35gi3varl
cmqllpdsf000ql40408aycxmu	เย็น	0.00	cmqllpdsf000nl404h9sn7738	cmpran7d3000l3xj3w4zm611l
cmqllptqx000vl404rinrfo69	หวานน้อย 50%	0.00	cmqllptqx000tl404ndmgde3g	cmprak1wr000e3xj3e60lzs1w
cmqllptqx000wl404ei1hyaal	เย็น	0.00	cmqllptqx000tl404ndmgde3g	cmpran7d3000l3xj3w4zm611l
cmqlmd8vp001pl404ljpgx1yc	หวานน้อย 50%	0.00	cmqlmd8vp001nl404vwd0nvzt	cmprak1wr000e3xj3e60lzs1w
cmqlmfqg7001vl40495gec75q	คั่วอ่อน	0.00	cmqlmfqg7001tl404bgs6e5gx	cmpraghfn000b3xj33nmkm7g2
cmqlmfqg7001wl404xyf61w95	ไม่หวาน 0%	0.00	cmqlmfqg7001tl404bgs6e5gx	cmprak1wr000d3xj3791vuavv
cmqlmkzfk000pjy04dfno3xh9	คั่วเข้ม	0.00	cmqlmkzfk000njy04gj5dqf0o	cmpraghfn00093xj3teu0s9ye
cmqlmkzfk000qjy042mk7iidx	ไม่หวาน 0%	0.00	cmqlmkzfk000njy04gj5dqf0o	cmprak1wr000d3xj3791vuavv
cmqlmpczi000zjy04ont1byl5	หวานน้อย 50%	0.00	cmqlmpczi000xjy040y4arieg	cmprak1wr000e3xj3e60lzs1w
cmqlmqxpb0026l404wp26ufrb	คั่วเข้ม	0.00	cmqlmqxpb0024l40435d8awt1	cmpraghfn00093xj3teu0s9ye
cmqlmqxpb0027l404trkmylrs	หวานปกติ 100%	0.00	cmqlmqxpb0024l40435d8awt1	cmq3v6ydv0001js04mbuyt8in
cmqlmqxpb002al4040l00t8oh	หวานน้อย 50%	0.00	cmqlmqxpb0028l40484kueme3	cmprak1wr000e3xj3e60lzs1w
cmqlqa33v0005l704879c532z	หวานปกติ 100%	0.00	cmqlqa33v0003l7044a928rgi	cmprak1ws000f3xj35gi3varl
cmqlqa33v0006l704pb94229t	เย็น	0.00	cmqlqa33v0003l7044a928rgi	cmpran7d3000l3xj3w4zm611l
cmqlqajdd000el704sep9kifh	หวานปกติ 100%	0.00	cmqlqajdd000cl704dkh3b1bp	cmprak1ws000f3xj35gi3varl
cmqlqajdd000fl704fzpx5ya5	เย็น	0.00	cmqlqajdd000cl704dkh3b1bp	cmpran7d3000l3xj3w4zm611l
cmqlr5cd5000cl7045qvtdrwd	หวานปกติ 100%	0.00	cmqlr5cd5000al704dyj1x7je	cmprak1ws000f3xj35gi3varl
cmqlr5cd5000dl704barcnqae	เย็น	0.00	cmqlr5cd5000al704dyj1x7je	cmpran7d3000l3xj3w4zm611l
cmqlr6idy0003jm04jo9v0p1l	คั่วกลาง	0.00	cmqlr6idy0001jm041zzcuczl	cmpraghfn000a3xj3le4hn9nj
cmqlr6idy0004jm04s8rcta6o	หวานปกติ 100%	0.00	cmqlr6idy0001jm041zzcuczl	cmq3v6ydv0001js04mbuyt8in
cmqls3v66000ajx04ubbiu3q9	หวานปกติ 100%	0.00	cmqls3v660008jx0422n70b57	cmprak1ws000f3xj35gi3varl
cmqls3v66000bjx04jy28yngc	เย็น	0.00	cmqls3v660008jx0422n70b57	cmpran7d3000l3xj3w4zm611l
cmqiqib4d0006l1047sb84f01	ไม่หวาน 0%	0.00	cmqiqib4d0004l1040ky59b8q	cmprak1wr000d3xj3791vuavv
cmqiqib4d0007l1049e80vy1n	เย็น	0.00	cmqiqib4d0004l1040ky59b8q	cmpran7d3000l3xj3w4zm611l
cmqiqnbci0007l304yps1zlr0	หวานน้อย 50%	0.00	cmqiqnbci0005l304opgcyop1	cmprak1wr000e3xj3e60lzs1w
cmqiqnbci0008l304494mzd61	เย็น	0.00	cmqiqnbci0005l304opgcyop1	cmpran7d3000l3xj3w4zm611l
cmqiqnt3e000el304e9tqfd1d	คั่วกลาง	0.00	cmqiqnt3e000cl304tawt9wdz	cmpraghfn000a3xj3le4hn9nj
cmqiqnt3e000fl30494kyvh3p	หวานน้อย 50%	0.00	cmqiqnt3e000cl304tawt9wdz	cmprak1wr000e3xj3e60lzs1w
cmqiqqkb4000bl104dmbl6403	คั่วเข้ม	0.00	cmqiqqkb40009l1041umz5dy3	cmpraghfn00093xj3teu0s9ye
cmqiqqkb4000cl104n7uv04ux	ไม่หวาน 0%	0.00	cmqiqqkb40009l1041umz5dy3	cmprak1wr000d3xj3791vuavv
cmqiqqkb4000fl1041otgma5l	หวานปกติ 100%	0.00	cmqiqqkb4000dl104lqjnzjnf	cmprak1ws000f3xj35gi3varl
cmqiqqkb4000gl104gqwx5zjo	เย็น	0.00	cmqiqqkb4000dl104lqjnzjnf	cmpran7d3000l3xj3w4zm611l
cmqiqrrhh000ml104q1i2wo8w	หวานน้อย 50%	0.00	cmqiqrrhh000kl104a2bxr1br	cmprak1wr000e3xj3e60lzs1w
cmqiqrrhh000nl10451jqa4ls	เย็น	0.00	cmqiqrrhh000kl104a2bxr1br	cmpran7d3000l3xj3w4zm611l
cmqiqu26i000vl104g5mk84i6	หวานน้อย 50%	0.00	cmqiqu26i000tl104lvia1tbh	cmprak1wr000e3xj3e60lzs1w
cmqirk8u6000sl104f0jgn1f7	หวานปกติ 100%	0.00	cmqirk8u6000ql1042hw1m6on	cmprak1ws000f3xj35gi3varl
cmqirk8u6000tl1044w5g8m07	เย็น	0.00	cmqirk8u6000ql1042hw1m6on	cmpran7d3000l3xj3w4zm611l
cmqiroem90005l70430n5303y	คั่วกลาง	0.00	cmqiroem90003l704zb4kb5rh	cmpraghfn000a3xj3le4hn9nj
cmqiroem90006l70473firzrk	หวานน้อย 50%	0.00	cmqiroem90003l704zb4kb5rh	cmprak1wr000e3xj3e60lzs1w
cmqirqr8f000cl704o7bjgci1	คั่วเข้ม	0.00	cmqirqr8f000al704q67ttuyc	cmpraghfn00093xj3teu0s9ye
cmqirqr8f000dl704em24te6j	หวานปกติ 100%	0.00	cmqirqr8f000al704q67ttuyc	cmq3v6ydv0001js04mbuyt8in
cmqiru9ka000jl704tk4ahx2b	หวานน้อย 50%	0.00	cmqiru9k9000hl704p3rlywdr	cmprak1wr000e3xj3e60lzs1w
cmqirw55o000rl704i3gniyta	คั่วเข้ม	0.00	cmqirw55o000pl7044tvkk7hj	cmpraghfn00093xj3teu0s9ye
cmqiryjwp0011l104c3cgm9hg	หวานน้อย 50%	0.00	cmqiryjwp000zl104wl1j7fey	cmprak1wr000e3xj3e60lzs1w
cmqk6pmaw000wla04wp5e9wwa	หวานน้อย 50%	0.00	cmqk6pmav000ula049vsk7vn5	cmprak1wr000e3xj3e60lzs1w
cmqk6ww8h001ela0492hw47a1	หวานน้อย 50%	0.00	cmqk6ww8h001cla048nn7opd6	cmprak1wr000e3xj3e60lzs1w
cmqk6ww8h001hla048l8ynanr	คั่วเข้ม	0.00	cmqk6ww8h001fla04ckuvi5fo	cmpraghfn00093xj3teu0s9ye
cmqk6ww8h001ila04mx8edv3i	หวานปกติ 100%	0.00	cmqk6ww8h001fla04ckuvi5fo	cmq3v6ydv0001js04mbuyt8in
cmqis77xu001il70427oc5wil	หวานน้อย 50%	0.00	cmqis77xu001gl704qn0q0d76	cmprak1wr000e3xj3e60lzs1w
cmqis77xu001ll7045xplmieg	หวานปกติ 100%	0.00	cmqis77xu001jl704bs0j49ta	cmprak1ws000f3xj35gi3varl
cmqis77xu001ol704jvy4rn9i	หวานปกติ 100%	0.00	cmqis77xu001ml704tttjcotc	cmprak1ws000f3xj35gi3varl
cmqis77xu001rl704isbhbp6b	หวานปกติ 100%	0.00	cmqis77xu001pl704qerneyiw	cmprak1ws000f3xj35gi3varl
cmqk6ww8h001lla046gpt2gek	หวานน้อย 50%	0.00	cmqk6ww8h001jla049c6ko161	cmprak1wr000e3xj3e60lzs1w
cmqk734is0007l4047qfp2g0p	คั่วเข้ม	0.00	cmqk734is0005l404u1sjqr80	cmpraghfn00093xj3teu0s9ye
cmqk734is0008l404c9hhvd4z	ไม่หวาน 0%	0.00	cmqk734is0005l404u1sjqr80	cmprak1wr000d3xj3791vuavv
cmqk784u8001tla04ofyfr2as	หวานปกติ 100%	0.00	cmqk784u8001rla04juocc47l	cmprak1ws000f3xj35gi3varl
cmqk784u8001ula043phtvclv	เย็น	0.00	cmqk784u8001rla04juocc47l	cmpran7d3000l3xj3w4zm611l
cmqk7o75v0024la04hv71szhy	หวานน้อย 50%	0.00	cmqk7o75v0022la04fjx6lvh9	cmprak1wr000e3xj3e60lzs1w
cmqk7o75v0025la045spwaifi	เย็น	0.00	cmqk7o75v0022la04fjx6lvh9	cmpran7d3000l3xj3w4zm611l
cmqk7u1m90005le04kz9ayv76	คั่วกลาง	0.00	cmqk7u1m90003le0481z7wrfv	cmpraghfn000a3xj3le4hn9nj
cmqk7u1m90006le04cfk2vy0r	ไม่หวาน 0%	0.00	cmqk7u1m90003le0481z7wrfv	cmprak1wr000d3xj3791vuavv
cmqkao9rg0005ji04tk8eeoa9	คั่วกลาง	0.00	cmqkao9rg0003ji04p548ue0a	cmpraghfn000a3xj3le4hn9nj
cmqkao9rg0006ji04b4qgxqde	หวานน้อย 50%	0.00	cmqkao9rg0003ji04p548ue0a	cmprak1wr000e3xj3e60lzs1w
cmqkao9rh0009ji042c4vih28	หวานน้อย 50%	0.00	cmqkao9rg0007ji04elew8qzk	cmprak1wr000e3xj3e60lzs1w
cmqkao9rh000aji04m5yeyxt9	เย็น	0.00	cmqkao9rg0007ji04elew8qzk	cmpran7d3000l3xj3w4zm611l
cmqkbe5pn0005jl0492qzisnu	คั่วอ่อน	0.00	cmqkbe5pn0003jl04hra3nsx8	cmpraghfn000b3xj33nmkm7g2
cmqkbe5pn0006jl04nn79l4pg	หวานน้อย 50%	0.00	cmqkbe5pn0003jl04hra3nsx8	cmprak1wr000e3xj3e60lzs1w
cmqkbe5pn0009jl049zbnj2fe	คั่วกลาง	0.00	cmqkbe5pn0007jl04xdu7la69	cmpraghfn000a3xj3le4hn9nj
cmqkbe5pn000ajl048lsxhoj1	ไม่หวาน 0%	0.00	cmqkbe5pn0007jl04xdu7la69	cmprak1wr000d3xj3791vuavv
cmqkc1g6a0005jv04lccg0xdi	หวานปกติ 100%	0.00	cmqkc1g6a0003jv04ipatrxae	cmq3v6ydv0001js04mbuyt8in
cmqkc1g6a0008jv04ukcfc7bb	หวานปกติ 100%	0.00	cmqkc1g6a0006jv040uo2kzww	cmq3v6ydv0001js04mbuyt8in
cmqkcrmxg0005jr0478je7yr1	คั่วอ่อน	0.00	cmqkcrmxg0003jr04fg1kjclt	cmpraghfn000b3xj33nmkm7g2
cmqkcrmxg0006jr04wi2orfc1	ไม่หวาน 0%	0.00	cmqkcrmxg0003jr04fg1kjclt	cmprak1wr000d3xj3791vuavv
cmqkdsmbl0005jl04byqrxxdr	คั่วกลาง	0.00	cmqkdsmbl0003jl04dj9lq8wo	cmpraghfn000a3xj3le4hn9nj
cmqkdsmbl0006jl04e9lw63br	ไม่หวาน 0%	0.00	cmqkdsmbl0003jl04dj9lq8wo	cmprak1wr000d3xj3791vuavv
cmqkdzuo0000cjl04d0mm5x5f	หวานปกติ 100%	0.00	cmqkdzuo0000ajl041y4io2p3	cmprak1ws000f3xj35gi3varl
cmqkek0jl0005lb04hgh2l04i	หวานน้อย 50%	0.00	cmqkek0jl0003lb049yek3178	cmprak1wr000e3xj3e60lzs1w
cmqkfxl2s0005jo04qsf6m02v	หวานปกติ 100%	0.00	cmqkfxl2s0003jo04d02s5d1g	cmq3v6ydv0001js04mbuyt8in
cmqkfxl2s0009jo04fhsmnofr	เย็น	0.00	cmqkfxl2s0007jo04ixg8i0qv	cmpran7d3000l3xj3w4zm611l
cmqljgn1c0004l204h9xcxbza	คั่วอ่อน	0.00	cmqljgn1c0002l204vpthsf64	cmpraghfn000b3xj33nmkm7g2
cmqljgn1c0005l204p9settrv	ไม่หวาน 0%	0.00	cmqljgn1c0002l204vpthsf64	cmprak1wr000d3xj3791vuavv
cmqlsth53000al20461sj1vrv	คั่วอ่อน	0.00	cmqlsth530008l20428kz7bzo	cmpraghfn000b3xj33nmkm7g2
cmqlsth53000bl204g3l4cky5	ไม่หวาน 0%	0.00	cmqlsth530008l20428kz7bzo	cmprak1wr000d3xj3791vuavv
cmqlvchv00005l3046unfgx2v	คั่วกลาง	0.00	cmqlvchv00003l304vs1qmwv9	cmpraghfn000a3xj3le4hn9nj
cmqlvchv00006l304nwp9j8a4	หวานปกติ 100%	0.00	cmqlvchv00003l304vs1qmwv9	cmq3v6ydv0001js04mbuyt8in
cmqlvd2iz000cl30417u4ml13	เย็น	0.00	cmqlvd2iz000al30475faj2pr	cmpran7d3000l3xj3w4zm611l
cmqlx9uh00005lb044ex73xrq	คั่วกลาง	0.00	cmqlx9uh00003lb04br12hky1	cmpraghfn000a3xj3le4hn9nj
cmqlx9uh00006lb04psgnq9b7	หวานปกติ 100%	0.00	cmqlx9uh00003lb04br12hky1	cmq3v6ydv0001js04mbuyt8in
cmqlxaajc000elb0476u1wrw8	คั่วกลาง	0.00	cmqlxaajc000clb041fco1j31	cmpraghfn000a3xj3le4hn9nj
cmqlxaajc000flb04izybmufs	ไม่หวาน 0%	0.00	cmqlxaajc000clb041fco1j31	cmprak1wr000d3xj3791vuavv
cmqlxaajc000ilb0498ndtmv1	คั่วอ่อน	0.00	cmqlxaajc000glb04aymo48y9	cmpraghfn000b3xj33nmkm7g2
cmqlxaajc000jlb04lt5d206o	ไม่หวาน 0%	0.00	cmqlxaajc000glb04aymo48y9	cmprak1wr000d3xj3791vuavv
cmqlxrvkn0005jo042zyessth	หวานน้อย 50%	0.00	cmqlxrvkn0003jo04c7ztk92i	cmprak1wr000e3xj3e60lzs1w
cmqlxrvkn0008jo042fdk36ih	คั่วอ่อน	0.00	cmqlxrvkn0006jo04ofxd5imh	cmpraghfn000b3xj33nmkm7g2
cmqlxrvkn0009jo0424juigyo	ไม่หวาน 0%	0.00	cmqlxrvkn0006jo04ofxd5imh	cmprak1wr000d3xj3791vuavv
cmqlxrvkn000cjo04w2023iwx	คั่วกลาง	0.00	cmqlxrvkn000ajo04a3u41x1o	cmpraghfn000a3xj3le4hn9nj
cmqlxrvkn000djo04myjlxauv	ไม่หวาน 0%	0.00	cmqlxrvkn000ajo04a3u41x1o	cmprak1wr000d3xj3791vuavv
cmqlxrvkn000gjo04fl03vmin	หวานปกติ 100%	0.00	cmqlxrvkn000ejo04q9nz2j66	cmprak1ws000f3xj35gi3varl
cmqlxrvkn000hjo04qqahb2c6	เย็น	0.00	cmqlxrvkn000ejo04q9nz2j66	cmpran7d3000l3xj3w4zm611l
cmqlxrvkn000kjo04jspt4pmi	หวานน้อย 50%	0.00	cmqlxrvkn000ijo04tgp4t65s	cmprak1wr000e3xj3e60lzs1w
cmqlxrvkn000njo04gzmcs2lg	หวานปกติ 100%	0.00	cmqlxrvkn000ljo04u0fwgwxs	cmq3v6ydv0001js04mbuyt8in
cmqlyzdpf0005jv04l1odkq81	คั่วเข้ม	0.00	cmqlyzdpf0003jv047un3bnbg	cmpraghfn00093xj3teu0s9ye
cmqlyzdpf0006jv04ypocxsii	ไม่หวาน 0%	0.00	cmqlyzdpf0003jv047un3bnbg	cmprak1wr000d3xj3791vuavv
cmqlz8ese000ejv047xg0kqn0	หวานปกติ 100%	0.00	cmqlz8ese000cjv04hr5pqlao	cmprak1ws000f3xj35gi3varl
cmqlz8ese000fjv04k4ybbm9b	เย็น	0.00	cmqlz8ese000cjv04hr5pqlao	cmpran7d3000l3xj3w4zm611l
cmqlz8voc000njv0434phpu7n	หวานปกติ 100%	0.00	cmqlz8voc000ljv04q2azelc2	cmprak1ws000f3xj35gi3varl
cmqlz8voc000ojv04pzrx9rsw	เย็น	0.00	cmqlz8voc000ljv04q2azelc2	cmpran7d3000l3xj3w4zm611l
cmqm1ht720005l104ks032zub	คั่วอ่อน	0.00	cmqm1ht720003l104l8j241r7	cmpraghfn000b3xj33nmkm7g2
cmqm1ht720006l104958y31bw	ไม่หวาน 0%	0.00	cmqm1ht720003l104l8j241r7	cmprak1wr000d3xj3791vuavv
cmqm1i687000el104o5d5mjri	หวานปกติ 100%	0.00	cmqm1i687000cl104fep5cana	cmprak1ws000f3xj35gi3varl
cmqm1i687000fl104j3ibl6p9	เย็น	0.00	cmqm1i687000cl104fep5cana	cmpran7d3000l3xj3w4zm611l
cmqof8n1e0004l404bpwmg5tn	คั่วกลาง	0.00	cmqof8n1e0002l404pgeu3eq7	cmpraghfn000a3xj3le4hn9nj
cmqof8n1e0005l404hodffei2	ไม่หวาน 0%	0.00	cmqof8n1e0002l404pgeu3eq7	cmprak1wr000d3xj3791vuavv
cmqofkfiy0009jr049j97f4bf	หวานปกติ 100%	0.00	cmqofkfiy0007jr049z37yis6	cmprak1ws000f3xj35gi3varl
cmqoflmyx000gjr04a11mlxtq	คั่วอ่อน	0.00	cmqoflmyx000ejr04w86vut9e	cmpraghfn000b3xj33nmkm7g2
cmqoflmyx000hjr04shzcysyl	ไม่หวาน 0%	0.00	cmqoflmyx000ejr04w86vut9e	cmprak1wr000d3xj3791vuavv
cmqofxpsj0004l204axszkedo	คั่วเข้ม	0.00	cmqofxpsj0002l20492oguwbc	cmpraghfn00093xj3teu0s9ye
cmqofxpsj0005l204sufsh2yn	ไม่หวาน 0%	0.00	cmqofxpsj0002l20492oguwbc	cmprak1wr000d3xj3791vuavv
cmqofxpsj0006l2045059owwd	แยกน้ำแข็ง	0.00	cmqofxpsj0002l20492oguwbc	cmpraptea000o3xj3zfahd2f7
cmqofz20u0005jy044mjsw4ry	หวานปกติ 100%	0.00	cmqofz20u0003jy04jqluw1rk	cmprak1ws000f3xj35gi3varl
cmqofz20u0006jy04o1rbw9q8	เย็น	0.00	cmqofz20u0003jy04jqluw1rk	cmpran7d3000l3xj3w4zm611l
cmqofz20u0009jy04dy5gfxd6	หวานปกติ 100%	0.00	cmqofz20u0007jy04rmrzewla	cmprak1ws000f3xj35gi3varl
cmqofz20u000ajy04s4ak3jp6	เย็น	0.00	cmqofz20u0007jy04rmrzewla	cmpran7d3000l3xj3w4zm611l
cmqofzkj6000gjy04x1bqvmr4	หวานน้อย 50%	0.00	cmqofzkj6000ejy041vkfgaij	cmprak1wr000e3xj3e60lzs1w
cmqofzkj6000hjy04en02jex8	เย็น	0.00	cmqofzkj6000ejy041vkfgaij	cmpran7d3000l3xj3w4zm611l
cmqofzkj6000ijy042dobgteq	แยกน้ำแข็ง	0.00	cmqofzkj6000ejy041vkfgaij	cmpraptea000o3xj3zfahd2f7
cmqog4lo2000fl204c3qo0y1w	คั่วเข้ม	0.00	cmqog4lo2000dl204fqf1iy1q	cmpraghfn00093xj3teu0s9ye
cmqog4lo2000gl2049013d12z	ไม่หวาน 0%	0.00	cmqog4lo2000dl204fqf1iy1q	cmprak1wr000d3xj3791vuavv
cmqog7a1v000wjy04q5hroaam	คั่วเข้ม	0.00	cmqog7a1v000ujy04jdam7z21	cmpraghfn00093xj3teu0s9ye
cmqog7a1v000xjy04msimen7m	ไม่หวาน 0%	0.00	cmqog7a1v000ujy04jdam7z21	cmprak1wr000d3xj3791vuavv
cmqogat78000ol204m4zb371h	หวานปกติ 100%	0.00	cmqogat78000ml204ec7v1wd4	cmprak1ws000f3xj35gi3varl
cmqogb5rr000ul204o0oynogz	หวานปกติ 100%	0.00	cmqogb5rr000sl204925iqzu2	cmprak1ws000f3xj35gi3varl
cmqoggnri0013jy043xg75323	หวานน้อย 50%	0.00	cmqoggnri0011jy04tnu4xbyx	cmprak1wr000e3xj3e60lzs1w
cmqoggnri0014jy04ligpj83x	เย็น	0.00	cmqoggnri0011jy04tnu4xbyx	cmpran7d3000l3xj3w4zm611l
cmqogh0g6001ajy04s1mg7gur	หวานปกติ 100%	0.00	cmqogh0g60018jy0492e21fsv	cmprak1ws000f3xj35gi3varl
cmqogh0g6001bjy04ltbaeal0	เย็น	0.00	cmqogh0g60018jy0492e21fsv	cmpran7d3000l3xj3w4zm611l
cmqoghbpx0016l204s3rqz5zo	หวานน้อย 50%	0.00	cmqoghbpx0014l2042y8ct2v9	cmprak1wr000e3xj3e60lzs1w
cmqogndw2001hjy04uvakgpnj	หวานปกติ 100%	0.00	cmqogndw1001fjy04xq9c04cl	cmprak1ws000f3xj35gi3varl
cmqogndw2001ijy04fgzav9gx	เย็น	0.00	cmqogndw1001fjy04xq9c04cl	cmpran7d3000l3xj3w4zm611l
cmqogqhau001el204k8fr5q4x	หวานน้อย 50%	0.00	cmqogqhau001cl204mnxj9mrn	cmprak1wr000e3xj3e60lzs1w
cmqogqhau001fl204rv14nh9i	เย็น	0.00	cmqogqhau001cl204mnxj9mrn	cmpran7d3000l3xj3w4zm611l
cmqoh0zo4001pl2040n8to9y1	คั่วเข้ม	0.00	cmqoh0zo4001nl204bxq9146y	cmpraghfn00093xj3teu0s9ye
cmqoh0zo4001ql2041bpebe3e	ไม่หวาน 0%	0.00	cmqoh0zo4001nl204bxq9146y	cmprak1wr000d3xj3791vuavv
cmqoh0zo4001tl204rgpzets4	คั่วกลาง	0.00	cmqoh0zo4001rl204f2rbi2a5	cmpraghfn000a3xj3le4hn9nj
cmqoh0zo4001ul204tcxivw19	หวานน้อย 50%	0.00	cmqoh0zo4001rl204f2rbi2a5	cmprak1wr000e3xj3e60lzs1w
cmqoh0zo4001xl20488b1sglz	คั่วกลาง	0.00	cmqoh0zo4001vl204vt55w56v	cmpraghfn000a3xj3le4hn9nj
cmqoh0zo4001yl204sxmj9pie	ไม่หวาน 0%	0.00	cmqoh0zo4001vl204vt55w56v	cmprak1wr000d3xj3791vuavv
cmqoh4aav0023l204wzee4urn	ไม่หวาน 0%	0.00	cmqoh4aav0021l204m7n0eax9	cmprak1wr000d3xj3791vuavv
cmqoh4aav0024l204ztg3kqo5	เย็น	0.00	cmqoh4aav0021l204m7n0eax9	cmpran7d3000l3xj3w4zm611l
cmqoh5bly0004l504jh8yk97l	หวานน้อย 50%	0.00	cmqoh5bly0002l504l2nhjn79	cmprak1wr000e3xj3e60lzs1w
cmqoh5bly0005l504reanl6rd	เย็น	0.00	cmqoh5bly0002l504l2nhjn79	cmpran7d3000l3xj3w4zm611l
cmqoh9e6r001qjy04sv3964jn	คั่วกลาง	0.00	cmqoh9e6r001ojy04z6u0usvz	cmpraghfn000a3xj3le4hn9nj
cmqohj8mt002dl204jw0ok6fj	หวานน้อย 50%	0.00	cmqohj8mt002bl2046yj9kbla	cmprak1wr000e3xj3e60lzs1w
cmqohlvah002jl204j8wqad3v	หวานน้อย 50%	0.00	cmqohlvah002hl204tda1hqp7	cmprak1wr000e3xj3e60lzs1w
cmqohlvah002kl2043qlmo006	เย็น	0.00	cmqohlvah002hl204tda1hqp7	cmpran7d3000l3xj3w4zm611l
cmqohs7610020jy04v1ignie8	หวานปกติ 100%	0.00	cmqohs761001yjy04z9wt4iu3	cmprak1ws000f3xj35gi3varl
cmqohs7610023jy04qd1g1jz1	หวานปกติ 100%	0.00	cmqohs7610021jy04rop1yao6	cmprak1ws000f3xj35gi3varl
cmqohsaa30029jy0450uq6dvd	คั่วกลาง	0.00	cmqohsaa30027jy04otgy3xfy	cmpraghfn000a3xj3le4hn9nj
cmqohsaa3002ajy04viir9ouv	ไม่หวาน 0%	0.00	cmqohsaa30027jy04otgy3xfy	cmprak1wr000d3xj3791vuavv
cmqohu9cz0034l204zut3xgit	คั่วเข้ม	0.00	cmqohu9cz0032l204l6yfyc4e	cmpraghfn00093xj3teu0s9ye
cmqohu9cz0035l204uyzr3ba0	ไม่หวาน 0%	0.00	cmqohu9cz0032l204l6yfyc4e	cmprak1wr000d3xj3791vuavv
cmqohzq2c002gjy04orltwupd	หวานน้อย 50%	0.00	cmqohzq2c002ejy04tw1edbnl	cmprak1wr000e3xj3e60lzs1w
cmqohzq2c002hjy04gk4j019b	เย็น	0.00	cmqohzq2c002ejy04tw1edbnl	cmpran7d3000l3xj3w4zm611l
cmqoi2yrw003jl204rc349x57	คั่วกลาง	0.00	cmqoi2yrw003hl204duto3tvd	cmpraghfn000a3xj3le4hn9nj
cmqoi2yrw003kl204dnoyzr7r	หวานน้อย 50%	0.00	cmqoi2yrw003hl204duto3tvd	cmprak1wr000e3xj3e60lzs1w
cmqoi6ryr002pjy04s4azrmpd	คั่วกลาง	0.00	cmqoi6ryr002njy046j8vw5lz	cmpraghfn000a3xj3le4hn9nj
cmqoi6ryr002qjy04q85td9fe	ไม่หวาน 0%	0.00	cmqoi6ryr002njy046j8vw5lz	cmprak1wr000d3xj3791vuavv
cmqoi6xvk002wjy04uj7i52mu	หวานปกติ 100%	0.00	cmqoi6xvk002ujy04c9i4w4f3	cmprak1ws000f3xj35gi3varl
cmqoiau65003sl204p0pjouqn	หวานน้อย 50%	0.00	cmqoiau65003ql204w95sya5o	cmprak1wr000e3xj3e60lzs1w
cmqoiau65003vl204hu71b53u	คั่วเข้ม	0.00	cmqoiau65003tl2041c4l3kf1	cmpraghfn00093xj3teu0s9ye
cmqoiau65003wl2048xvugq9n	หวานปกติ 100%	0.00	cmqoiau65003tl2041c4l3kf1	cmq3v6ydv0001js04mbuyt8in
cmqolg4s80005ju04jiu7qdto	หวานปกติ 100%	0.00	cmqolg4s80003ju040c72nafz	cmprak1ws000f3xj35gi3varl
cmqolg4s80006ju04jc40riig	เย็น	0.00	cmqolg4s80003ju040c72nafz	cmpran7d3000l3xj3w4zm611l
cmqolg4s80009ju04idu7gy9c	คั่วเข้ม	0.00	cmqolg4s80007ju045008zlr9	cmpraghfn00093xj3teu0s9ye
cmqolg4s8000aju04pq8jxene	ไม่หวาน 0%	0.00	cmqolg4s80007ju045008zlr9	cmprak1wr000d3xj3791vuavv
cmqolg4s8000dju04e3305shw	หวานน้อย 50%	0.00	cmqolg4s8000bju045ttmwzef	cmprak1wr000e3xj3e60lzs1w
cmqolg4s8000eju04j20igofq	เย็น	0.00	cmqolg4s8000bju045ttmwzef	cmpran7d3000l3xj3w4zm611l
cmqolni4u000mju04m4jex8yo	คั่วอ่อน	0.00	cmqolni4u000kju04sv2auj8z	cmpraghfn000b3xj33nmkm7g2
cmqolni4u000nju04gd1t6k2d	หวานน้อย 50%	0.00	cmqolni4u000kju04sv2auj8z	cmprak1wr000e3xj3e60lzs1w
cmqolni4u000qju04xwimosch	หวานปกติ 100%	0.00	cmqolni4u000oju04timqzfvb	cmprak1ws000f3xj35gi3varl
cmqolni4u000rju04dpjq5i87	เย็น	0.00	cmqolni4u000oju04timqzfvb	cmpran7d3000l3xj3w4zm611l
cmqolqeql0005jv04duvuzkkt	หวานน้อย 50%	0.00	cmqolqeql0003jv044i2s22s2	cmprak1wr000e3xj3e60lzs1w
cmqolqeql0006jv04ze17ic0a	เย็น	0.00	cmqolqeql0003jv044i2s22s2	cmpran7d3000l3xj3w4zm611l
cmqomfj200005ji047ltnyhfo	หวานปกติ 100%	0.00	cmqomfj1z0003ji047zyngy6j	cmprak1ws000f3xj35gi3varl
cmqomg06u000bji04zkm22r7g	คั่วกลาง	0.00	cmqomg06u0009ji04ivzij5uc	cmpraghfn000a3xj3le4hn9nj
cmqomg06u000cji04yfrhnig1	หวานปกติ 100%	0.00	cmqomg06u0009ji04ivzij5uc	cmq3v6ydv0001js04mbuyt8in
cmqomppaf0007jo04x2tjxvx9	เย็น	0.00	cmqomppaf0005jo04j21r96gl	cmpran7d3000l3xj3w4zm611l
cmqomqyni0005l704s5m37rt8	หวานปกติ 100%	0.00	cmqomqyni0003l7045bpmb4ni	cmprak1ws000f3xj35gi3varl
cmqomqyni0006l704l1zs2t2p	เย็น	0.00	cmqomqyni0003l7045bpmb4ni	cmpran7d3000l3xj3w4zm611l
cmqomvxq70006jo047lpygwuu	คั่วอ่อน	0.00	cmqomvxq70004jo047lrzqa6u	cmpraghfn000b3xj33nmkm7g2
cmqomvxq70007jo047a2obo63	ไม่หวาน 0%	0.00	cmqomvxq70004jo047lrzqa6u	cmprak1wr000d3xj3791vuavv
cmqomwyo5000djo048omlxuhk	คั่วอ่อน	0.00	cmqomwyo5000bjo04pjr7ji82	cmpraghfn000b3xj33nmkm7g2
cmqomwyo5000ejo042t4gzzhf	ไม่หวาน 0%	0.00	cmqomwyo5000bjo04pjr7ji82	cmprak1wr000d3xj3791vuavv
cmqomwyo5000hjo046tr92jd2	หวานน้อย 50%	0.00	cmqomwyo5000fjo0459k41ktl	cmprak1wr000e3xj3e60lzs1w
cmqomwyo5000ijo04zjrrr0ef	เย็น	0.00	cmqomwyo5000fjo0459k41ktl	cmpran7d3000l3xj3w4zm611l
cmqonxvbd0003k004rhnu9igu	หวานน้อย 50%	0.00	cmqonxvbd0001k004ix8ov7kw	cmprak1wr000e3xj3e60lzs1w
cmqonxvbd0006k004wy056uw4	หวานน้อย 50%	0.00	cmqonxvbd0004k004frxe3fhu	cmprak1wr000e3xj3e60lzs1w
cmqonxvbd0007k004vj3d18su	เย็น	0.00	cmqonxvbd0004k004frxe3fhu	cmpran7d3000l3xj3w4zm611l
cmqopb9bl0005l404iccq4w39	คั่วกลาง	0.00	cmqopb9bl0003l404ryws78t9	cmpraghfn000a3xj3le4hn9nj
cmqopb9bl0006l404xs60cafn	ไม่หวาน 0%	0.00	cmqopb9bl0003l404ryws78t9	cmprak1wr000d3xj3791vuavv
cmqopvfwu0005jr04362b5vqr	คั่วเข้ม	0.00	cmqopvfwu0003jr04a88hbqy8	cmpraghfn00093xj3teu0s9ye
cmqopvfwu0006jr043cg9xz9t	ไม่หวาน 0%	0.00	cmqopvfwu0003jr04a88hbqy8	cmprak1wr000d3xj3791vuavv
cmqoqdbyr0005l104drn4qrw5	หวานมาก 120%	0.00	cmqoqdbyr0003l104hu9g1iwn	cmprak1ws000g3xj3pdboyhw3
cmqoqdbyr0006l104nwr2rgmq	เย็น	0.00	cmqoqdbyr0003l104hu9g1iwn	cmpran7d3000l3xj3w4zm611l
cmqoqjxkv0005lg04j9c8v38v	หวานปกติ 100%	0.00	cmqoqjxkv0003lg04me9s9rwd	cmprak1ws000f3xj35gi3varl
cmqoqjxkv0008lg049tzaj8if	คั่วเข้ม	0.00	cmqoqjxkv0006lg04383gzjds	cmpraghfn00093xj3teu0s9ye
cmqoqjxkv0009lg04pjvd5vma	หวานปกติ 100%	0.00	cmqoqjxkv0006lg04383gzjds	cmq3v6ydv0001js04mbuyt8in
cmqorsvzv000glg04h2odkwnj	หวานปกติ 100%	0.00	cmqorsvzv000elg045sdv0ohu	cmprak1ws000f3xj35gi3varl
cmqorsvzv000hlg04tnmnqjeh	เย็น	0.00	cmqorsvzv000elg045sdv0ohu	cmpran7d3000l3xj3w4zm611l
cmqorsvzv000klg04d5ja4146	คั่วกลาง	0.00	cmqorsvzv000ilg043arioyyp	cmpraghfn000a3xj3le4hn9nj
cmqorsvzv000llg042r2peoom	ไม่หวาน 0%	0.00	cmqorsvzv000ilg043arioyyp	cmprak1wr000d3xj3791vuavv
cmqorsvzv000olg048c38xxpv	หวานน้อย 50%	0.00	cmqorsvzv000mlg049xvq0ast	cmprak1wr000e3xj3e60lzs1w
cmqorsvzv000plg04y0yym8ud	เย็น	0.00	cmqorsvzv000mlg049xvq0ast	cmpran7d3000l3xj3w4zm611l
cmqorun5b0005k004l8igucjr	หวานปกติ 100%	0.00	cmqorun5b0003k0045ye6qtao	cmprak1ws000f3xj35gi3varl
cmqorun5b0008k004vshr23wf	หวานปกติ 100%	0.00	cmqorun5b0006k004g3ibcudp	cmprak1ws000f3xj35gi3varl
cmqos3npl000gk004twxu12bs	หวานน้อย 50%	0.00	cmqos3npl000ek004aktqdw5o	cmprak1wr000e3xj3e60lzs1w
cmqos3npl000hk004o4gyxt3x	เย็น	0.00	cmqos3npl000ek004aktqdw5o	cmpran7d3000l3xj3w4zm611l
cmqoszbez0005kz04abv1dtrg	หวานปกติ 100%	0.00	cmqoszbez0003kz04xjn2rb4c	cmprak1ws000f3xj35gi3varl
cmqoszbez0006kz04jytjaia2	เย็น	0.00	cmqoszbez0003kz04xjn2rb4c	cmpran7d3000l3xj3w4zm611l
cmqou0n830005la044zzug367	หวานปกติ 100%	0.00	cmqou0n820003la0423jdz1du	cmprak1ws000f3xj35gi3varl
cmqou0n830006la042azyn5ov	เย็น	0.00	cmqou0n820003la0423jdz1du	cmpran7d3000l3xj3w4zm611l
cmqou6iwd0005jf04rj1cjkfx	คั่วเข้ม	0.00	cmqou6iwd0003jf049i5oyf11	cmpraghfn00093xj3teu0s9ye
cmqou6iwd0006jf04s89s8sta	ไม่หวาน 0%	0.00	cmqou6iwd0003jf049i5oyf11	cmprak1wr000d3xj3791vuavv
cmqou89t0000cjf04cc0jmqnm	หวานปกติ 100%	0.00	cmqou89t0000ajf04eqnx331t	cmq3v6ydv0001js04mbuyt8in
cmqpui11w0005lb04vfxnja3h	หวานมาก 120%	0.00	cmqpui11v0003lb0455oa5qr1	cmprak1ws000g3xj3pdboyhw3
cmqpui11w0006lb0461znmhi3	เย็น	0.00	cmqpui11v0003lb0455oa5qr1	cmpran7d3000l3xj3w4zm611l
cmqpuz63t000clb04b47koxrg	คั่วเข้ม	0.00	cmqpuz63t000alb04jf549qju	cmpraghfn00093xj3teu0s9ye
cmqpuz63t000dlb04eb4lmkas	ไม่หวาน 0%	0.00	cmqpuz63t000alb04jf549qju	cmprak1wr000d3xj3791vuavv
cmqpuz63t000glb04x65esemj	คั่วกลาง	0.00	cmqpuz63t000elb04oh5ikipq	cmpraghfn000a3xj3le4hn9nj
cmqpuz63t000hlb0479pchr7q	หวานปกติ 100%	0.00	cmqpuz63t000elb04oh5ikipq	cmq3v6ydv0001js04mbuyt8in
cmqpv35yi0004kz04g2yy2ko0	คั่วอ่อน	0.00	cmqpv35yh0002kz048qx15akt	cmpraghfn000b3xj33nmkm7g2
cmqpv35yi0005kz049bredk8r	ไม่หวาน 0%	0.00	cmqpv35yh0002kz048qx15akt	cmprak1wr000d3xj3791vuavv
cmqpv35yi0008kz04xetq8jbb	คั่วเข้ม	0.00	cmqpv35yi0006kz048lted6sy	cmpraghfn00093xj3teu0s9ye
cmqpv35yi0009kz04psja16n8	ไม่หวาน 0%	0.00	cmqpv35yi0006kz048lted6sy	cmprak1wr000d3xj3791vuavv
cmqpv35yi000ckz044ckemkt5	หวานปกติ 100%	0.00	cmqpv35yi000akz04waqz628o	cmprak1ws000f3xj35gi3varl
cmqpv35yi000dkz04dgpj7zey	เย็น	0.00	cmqpv35yi000akz04waqz628o	cmpran7d3000l3xj3w4zm611l
cmqpvj6ag0005kt04w26gohv6	คั่วเข้ม	0.00	cmqpvj6ag0003kt04k4wziuez	cmpraghfn00093xj3teu0s9ye
cmqpvj6ag0006kt04a9bkd03e	ไม่หวาน 0%	0.00	cmqpvj6ag0003kt04k4wziuez	cmprak1wr000d3xj3791vuavv
cmqpvkgad000ckt04t6n1du7w	หวานน้อย 50%	0.00	cmqpvkgac000akt04j8858tt1	cmprak1wr000e3xj3e60lzs1w
cmqpvkgad000dkt04tgkxq4tj	เย็น	0.00	cmqpvkgac000akt04j8858tt1	cmpran7d3000l3xj3w4zm611l
cmqpvkgad000ekt04hx96ydad	แยกน้ำแข็ง	0.00	cmqpvkgac000akt04j8858tt1	cmpraptea000o3xj3zfahd2f7
cmqpvrsq60004kz04f8bwsgl5	คั่วเข้ม	0.00	cmqpvrsq60002kz04u7q838cg	cmpraghfn00093xj3teu0s9ye
cmqpvrsq60005kz048ikokgkg	ไม่หวาน 0%	0.00	cmqpvrsq60002kz04u7q838cg	cmprak1wr000d3xj3791vuavv
cmqpvrsq60006kz04wz32kmf8	แยกน้ำแข็ง	0.00	cmqpvrsq60002kz04u7q838cg	cmpraptea000o3xj3zfahd2f7
cmqpw0j0b000djl04wfx0lmlh	คั่วเข้ม	0.00	cmqpw0j0b000bjl045sffln92	cmpraghfn00093xj3teu0s9ye
cmqpw0j0b000ejl048i5kmeja	ไม่หวาน 0%	0.00	cmqpw0j0b000bjl045sffln92	cmprak1wr000d3xj3791vuavv
cmqpw0j0c000hjl04dr0jqm7s	หวานปกติ 100%	0.00	cmqpw0j0b000fjl04tbaqtrue	cmprak1ws000f3xj35gi3varl
cmqpw1p81000njl04eu2im45n	หวานน้อย 50%	0.00	cmqpw1p81000ljl04zwokviij	cmprak1wr000e3xj3e60lzs1w
cmqpw1p81000ojl041ef1ujkg	เย็น	0.00	cmqpw1p81000ljl04zwokviij	cmpran7d3000l3xj3w4zm611l
cmqpwcagz0005ld04i30jzwgn	คั่วเข้ม	0.00	cmqpwcagz0003ld04wkvx7ik5	cmpraghfn00093xj3teu0s9ye
cmqpwcagz0006ld04yzj47qm1	ไม่หวาน 0%	0.00	cmqpwcagz0003ld04wkvx7ik5	cmprak1wr000d3xj3791vuavv
cmqpwcq4d000cld048a4r2dpv	หวานปกติ 100%	0.00	cmqpwcq4d000ald04zzvhmt5a	cmprak1ws000f3xj35gi3varl
cmqpwertx000lld04sdwnc6ky	หวานน้อย 50%	0.00	cmqpwertx000jld0465hj0qvt	cmprak1wr000e3xj3e60lzs1w
cmqpwertx000mld04xrj2wzv0	เย็น	0.00	cmqpwertx000jld0465hj0qvt	cmpran7d3000l3xj3w4zm611l
cmqpwgjw20005jf04p714y57u	หวานปกติ 100%	0.00	cmqpwgjw20003jf04m9xbuw6b	cmq3v6ydv0001js04mbuyt8in
cmqpwq1rp0005jx04d7d34a3s	คั่วเข้ม	0.00	cmqpwq1rp0003jx044ddfeeq1	cmpraghfn00093xj3teu0s9ye
cmqpww1ap000bjf04ycv9hpu3	คั่วเข้ม	0.00	cmqpww1ap0009jf04tike10wg	cmpraghfn00093xj3teu0s9ye
cmqpww1ap000cjf04hzp6o28l	หวานปกติ 100%	0.00	cmqpww1ap0009jf04tike10wg	cmq3v6ydv0001js04mbuyt8in
cmqpx6f0b000ljx0423rhvs9y	หวานปกติ 100%	0.00	cmqpx6f0b000jjx04s72etnko	cmprak1ws000f3xj35gi3varl
cmqpxbqpu000mjf04ug94h567	หวานน้อย 50%	0.00	cmqpxbqpu000kjf04l56vk1jl	cmprak1wr000e3xj3e60lzs1w
cmqpxbqpu000njf04ko7fp3l3	เย็น	0.00	cmqpxbqpu000kjf04l56vk1jl	cmpran7d3000l3xj3w4zm611l
cmqpxfghs000zjf04d6kb8ubb	คั่วเข้ม	0.00	cmqpxfghs000xjf042p5pn1x1	cmpraghfn00093xj3teu0s9ye
cmqpxfghs0010jf04rmxt05yl	ไม่หวาน 0%	0.00	cmqpxfghs000xjf042p5pn1x1	cmprak1wr000d3xj3791vuavv
cmqpxhdgw000rjx04z38q0p14	หวานปกติ 100%	0.00	cmqpxhdgw000pjx04d33mlc02	cmprak1ws000f3xj35gi3varl
cmqpxj6dt0011jx049936y2z8	คั่วกลาง	0.00	cmqpxj6dt000zjx04iqeas099	cmpraghfn000a3xj3le4hn9nj
cmqpxj6dt0012jx04wjhi903a	ไม่หวาน 0%	0.00	cmqpxj6dt000zjx04iqeas099	cmprak1wr000d3xj3791vuavv
cmqpzldaf0005l404jyxuy6ug	หวานน้อย 50%	0.00	cmqpzldaf0003l404ke4xnswb	cmprak1wr000e3xj3e60lzs1w
cmqpzln7o0005kt04m8c810yg	คั่วเข้ม	0.00	cmqpzln7o0003kt04sucyl6ik	cmpraghfn00093xj3teu0s9ye
cmqpzln7o0006kt041pkz1fz6	ไม่หวาน 0%	0.00	cmqpzln7o0003kt04sucyl6ik	cmprak1wr000d3xj3791vuavv
cmqq03ztn000gkt04r5uy56u4	หวานน้อย 50%	0.00	cmqq03ztn000ekt041ry4uoba	cmprak1wr000e3xj3e60lzs1w
cmqq03ztn000hkt04ypb28yf2	เย็น	0.00	cmqq03ztn000ekt041ry4uoba	cmpran7d3000l3xj3w4zm611l
cmqq03ztn000kkt04bumdjadv	หวานน้อย 50%	0.00	cmqq03ztn000ikt04zo61m9jd	cmprak1wr000e3xj3e60lzs1w
cmqq2zqf30005jo04ee4xjyl1	คั่วกลาง	0.00	cmqq2zqf30003jo04hotkm6mx	cmpraghfn000a3xj3le4hn9nj
cmqq2zqf30006jo04xwyevn9b	ไม่หวาน 0%	0.00	cmqq2zqf30003jo04hotkm6mx	cmprak1wr000d3xj3791vuavv
cmqq2zqf30009jo044qvnxyfs	คั่วอ่อน	0.00	cmqq2zqf30007jo04m7mznu4a	cmpraghfn000b3xj33nmkm7g2
cmqq2zqf3000ajo04q2b78svd	หวานน้อย 50%	0.00	cmqq2zqf30007jo04m7mznu4a	cmprak1wr000e3xj3e60lzs1w
cmqq307kw000ijo047o6aowor	หวานน้อย 50%	0.00	cmqq307kw000gjo04v63gn8hj	cmprak1wr000e3xj3e60lzs1w
cmqq307kw000jjo04jdmpzn14	เย็น	0.00	cmqq307kw000gjo04v63gn8hj	cmpran7d3000l3xj3w4zm611l
cmqq307kw000mjo0446bncnj7	หวานน้อย 50%	0.00	cmqq307kw000kjo04ripob30p	cmprak1wr000e3xj3e60lzs1w
cmqq307kw000njo049no12pmo	เย็น	0.00	cmqq307kw000kjo04ripob30p	cmpran7d3000l3xj3w4zm611l
cmqq319mc000vjo04aunm9czm	หวานปกติ 100%	0.00	cmqq319mc000tjo04wrcigdhm	cmprak1ws000f3xj35gi3varl
cmqq319mc000wjo04kksy7qtb	เย็น	0.00	cmqq319mc000tjo04wrcigdhm	cmpran7d3000l3xj3w4zm611l
cmqq6nk7g0004l204njc6truo	คั่วกลาง	0.00	cmqq6nk7g0002l204s31ady4w	cmpraghfn000a3xj3le4hn9nj
cmqq6nk7g0005l204ltqyskew	หวานปกติ 100%	0.00	cmqq6nk7g0002l204s31ady4w	cmq3v6ydv0001js04mbuyt8in
cmqq6nk7g0008l204tw0wpdyv	คั่วเข้ม	0.00	cmqq6nk7g0006l204mlby15il	cmpraghfn00093xj3teu0s9ye
cmqq6nk7g0009l204armovlu9	หวานปกติ 100%	0.00	cmqq6nk7g0006l204mlby15il	cmq3v6ydv0001js04mbuyt8in
cmqq6obyz0005i304tgdtbr9d	คั่วเข้ม	0.00	cmqq6obyz0003i3046ivikgrt	cmpraghfn00093xj3teu0s9ye
cmqq6rct5000bi304fkvt0ixm	เย็น	0.00	cmqq6rct50009i304chsfns67	cmpran7d3000l3xj3w4zm611l
cmqq6wdo90005jy044zkt9nti	หวานปกติ 100%	0.00	cmqq6wdo90003jy04cqhzo87i	cmprak1ws000f3xj35gi3varl
cmqq6wdo90006jy04qrp2qcrd	เย็น	0.00	cmqq6wdo90003jy04cqhzo87i	cmpran7d3000l3xj3w4zm611l
cmqq7lils0004lb04kt434i45	หวานน้อย 50%	0.00	cmqq7lils0002lb0475jhn1ue	cmprak1wr000e3xj3e60lzs1w
cmqq7lils0007lb04ze6pgjcg	หวานน้อย 50%	0.00	cmqq7lils0005lb04xoif6zka	cmprak1wr000e3xj3e60lzs1w
cmqq7lils0008lb04nv3501sy	เย็น	0.00	cmqq7lils0005lb04xoif6zka	cmpran7d3000l3xj3w4zm611l
cmqq7lils000blb047nd2wor3	หวานปกติ 100%	0.00	cmqq7lils0009lb0472h8t0aa	cmprak1ws000f3xj35gi3varl
cmqq7lils000clb04e2xvs9o3	เย็น	0.00	cmqq7lils0009lb0472h8t0aa	cmpran7d3000l3xj3w4zm611l
cmqq8x3770006lb04zt3m239f	หวานปกติ 100%	0.00	cmqq8x3770004lb04dkk8byt6	cmq3v6ydv0001js04mbuyt8in
cmqq93f4r0003lb048j3uk5nw	คั่วกลาง	0.00	cmqq93f4r0001lb0477ey5vgg	cmpraghfn000a3xj3le4hn9nj
cmqq93f4r0004lb04v0rre5nz	หวานปกติ 100%	0.00	cmqq93f4r0001lb0477ey5vgg	cmq3v6ydv0001js04mbuyt8in
cmqq93f4r0007lb04lf3jhigj	หวานปกติ 100%	0.00	cmqq93f4r0005lb04ctcu5doc	cmprak1ws000f3xj35gi3varl
cmqq93f4r0008lb041ck0ha40	เย็น	0.00	cmqq93f4r0005lb04ctcu5doc	cmpran7d3000l3xj3w4zm611l
cmqq965hy000jlb04e45fjryi	หวานมาก 120%	0.00	cmqq965hy000hlb048fs18j6d	cmprak1ws000g3xj3pdboyhw3
cmqq9c6me000mlb04hn0fybp9	คั่วเข้ม	0.00	cmqq9c6me000klb04z8nt3zzm	cmpraghfn00093xj3teu0s9ye
cmqq9c6me000nlb04o8n2j5uk	ไม่หวาน 0%	0.00	cmqq9c6me000klb04z8nt3zzm	cmprak1wr000d3xj3791vuavv
cmqq9l067000slb0460mw9vxs	หวานปกติ 100%	0.00	cmqq9l067000qlb04lip4i0n1	cmq3v6ydv0001js04mbuyt8in
cmqq9mgw7000tlb04ec1n0vty	หวานปกติ 100%	0.00	cmqq9mgw7000rlb04jtxxi6uh	cmprak1ws000f3xj35gi3varl
cmqq9mgw7000ulb047rgd5luc	เย็น	0.00	cmqq9mgw7000rlb04jtxxi6uh	cmpran7d3000l3xj3w4zm611l
cmqra6zq80004jo04vw2gi8pj	คั่วอ่อน	0.00	cmqra6zq80002jo04fct0jcdf	cmpraghfn000b3xj33nmkm7g2
cmqra6zq80005jo04y60hwqi1	ไม่หวาน 0%	0.00	cmqra6zq80002jo04fct0jcdf	cmprak1wr000d3xj3791vuavv
cmqra8rjw000ejo046dt95m86	ไม่หวาน 0%	0.00	cmqra8rjw000cjo043kl5a1gu	cmprak1wr000d3xj3791vuavv
cmqracpcf0005l404ga7j2s4a	คั่วเข้ม	0.00	cmqracpce0003l404r1leil9s	cmpraghfn00093xj3teu0s9ye
cmqracpcf0006l404xlrp0jdc	ไม่หวาน 0%	0.00	cmqracpce0003l404r1leil9s	cmprak1wr000d3xj3791vuavv
cmqracpcf0009l404mfiolx73	คั่วเข้ม	0.00	cmqracpcf0007l404l26eb38f	cmpraghfn00093xj3teu0s9ye
cmqracpcf000al404393wtja7	หวานปกติ 100%	0.00	cmqracpcf0007l404l26eb38f	cmq3v6ydv0001js04mbuyt8in
cmqram8hx0005kz04zftilson	หวานปกติ 100%	0.00	cmqram8hw0003kz04xpj86e9d	cmprak1ws000f3xj35gi3varl
cmqram8hx0006kz04s1smxhzg	เย็น	0.00	cmqram8hw0003kz04xpj86e9d	cmpran7d3000l3xj3w4zm611l
cmqraodev000ekz04ozq3yws7	หวานน้อย 50%	0.00	cmqraodev000ckz04bticf1vt	cmprak1wr000e3xj3e60lzs1w
cmqraodev000fkz04xlebwg1f	เย็น	0.00	cmqraodev000ckz04bticf1vt	cmpran7d3000l3xj3w4zm611l
cmqraodev000ikz04j6r4evsz	ไม่หวาน 0%	0.00	cmqraodev000gkz04oheoutfu	cmprak1wr000d3xj3791vuavv
cmqraodev000jkz0482wtl544	เย็น	0.00	cmqraodev000gkz04oheoutfu	cmpran7d3000l3xj3w4zm611l
cmqravt500004jr044kcczvrh	คั่วเข้ม	0.00	cmqravt500002jr04gdqk50v8	cmpraghfn00093xj3teu0s9ye
cmqravt500005jr04ocn93355	ไม่หวาน 0%	0.00	cmqravt500002jr04gdqk50v8	cmprak1wr000d3xj3791vuavv
cmqravt500006jr048lb1ifr4	แยกน้ำแข็ง	0.00	cmqravt500002jr04gdqk50v8	cmpraptea000o3xj3zfahd2f7
cmqrax84w000fjr04kwztgswg	หวานมาก 120%	0.00	cmqrax84w000djr04nwbn0csg	cmprak1ws000g3xj3pdboyhw3
cmqrax84w000gjr04xxaxgzeu	เย็น	0.00	cmqrax84w000djr04nwbn0csg	cmpran7d3000l3xj3w4zm611l
cmqrb1gbh0005l4041zfieak7	คั่วเข้ม	0.00	cmqrb1gbh0003l404uz9i1qic	cmpraghfn00093xj3teu0s9ye
cmqrb1gbh0006l404v6t2mmzx	ไม่หวาน 0%	0.00	cmqrb1gbh0003l404uz9i1qic	cmprak1wr000d3xj3791vuavv
cmqrbb9zw0005jo04p8xtxpth	คั่วเข้ม	0.00	cmqrbb9zw0003jo04ebkwzl4d	cmpraghfn00093xj3teu0s9ye
cmqrbb9zw0006jo04y6u4di4g	ไม่หวาน 0%	0.00	cmqrbb9zw0003jo04ebkwzl4d	cmprak1wr000d3xj3791vuavv
cmqrbjawh000gl404vqshpdon	หวานน้อย 50%	0.00	cmqrbjawh000el404w4x3o51t	cmprak1wr000e3xj3e60lzs1w
cmqrbjawh000hl404fod7z91h	เย็น	0.00	cmqrbjawh000el404w4x3o51t	cmpran7d3000l3xj3w4zm611l
cmqrbjawh000il40444bwnbx4	เพิ่มช็อต	10.00	cmqrbjawh000el404w4x3o51t	cmpralv7i000j3xj3b1u9nwyo
cmqrbthbi000ojo045vts77ty	คั่วเข้ม	0.00	cmqrbthbi000mjo04f2pmue61	cmpraghfn00093xj3teu0s9ye
cmqrbthbi000pjo04jmw5dhca	ไม่หวาน 0%	0.00	cmqrbthbi000mjo04f2pmue61	cmprak1wr000d3xj3791vuavv
cmqrc0lok000xjo04dhefosk8	หวานน้อย 50%	0.00	cmqrc0lok000vjo046tr2ergn	cmprak1wr000e3xj3e60lzs1w
cmqrc41nl0004i304kxsom0mv	คั่วเข้ม	0.00	cmqrc41nl0002i304pzm1kijd	cmpraghfn00093xj3teu0s9ye
cmqrc41nl0005i30457dj4f7t	ไม่หวาน 0%	0.00	cmqrc41nl0002i304pzm1kijd	cmprak1wr000d3xj3791vuavv
cmqrc5jtf000ei304n7gz9gmp	หวานน้อย 50%	0.00	cmqrc5jtf000ci304dcsj2n5n	cmprak1wr000e3xj3e60lzs1w
cmqrc65f80005l2045e5e1edm	คั่วเข้ม	0.00	cmqrc65f80003l204jvtfbwh2	cmpraghfn00093xj3teu0s9ye
cmqrc65f80006l204emwdsymi	ไม่หวาน 0%	0.00	cmqrc65f80003l204jvtfbwh2	cmprak1wr000d3xj3791vuavv
cmqrc8fgt0004jm04w386uqbk	หวานน้อย 50%	0.00	cmqrc8fgt0002jm043btumumu	cmprak1wr000e3xj3e60lzs1w
cmqrc8fgt0005jm044fiiutlo	เย็น	0.00	cmqrc8fgt0002jm043btumumu	cmpran7d3000l3xj3w4zm611l
cmqrcl5ls0005ic047rbljd9c	คั่วเข้ม	0.00	cmqrcl5ls0003ic047npgspw2	cmpraghfn00093xj3teu0s9ye
cmqrcl5ls0006ic04qb7stzuu	ไม่หวาน 0%	0.00	cmqrcl5ls0003ic047npgspw2	cmprak1wr000d3xj3791vuavv
cmqrcp8x5000iic04fax9o2gf	หวานปกติ 100%	0.00	cmqrcp8x5000gic04y004h4m4	cmprak1ws000f3xj35gi3varl
cmqrcy4e50017jo04we4ja9xj	หวานปกติ 100%	0.00	cmqrcy4e50015jo04y5nbe2w4	cmprak1ws000f3xj35gi3varl
cmqrcy789001djo04198vl2fw	คั่วเข้ม	0.00	cmqrcy789001bjo04kpmaen0t	cmpraghfn00093xj3teu0s9ye
cmqrd263c0005jy0466w4fqc8	คั่วกลาง	0.00	cmqrd263c0003jy04qf72p7z5	cmpraghfn000a3xj3le4hn9nj
cmqrd263c0006jy04tats2tm2	ไม่หวาน 0%	0.00	cmqrd263c0003jy04qf72p7z5	cmprak1wr000d3xj3791vuavv
cmqrf1mnw0005ld04urrrvbb3	หวานปกติ 100%	0.00	cmqrf1mnw0003ld04nqa5sv7p	cmq3v6ydv0001js04mbuyt8in
cmqrf2wze000fld04lhx3ihb3	หวานปกติ 100%	0.00	cmqrf2wze000dld04edbtx87q	cmprak1ws000f3xj35gi3varl
cmqrf47jx000lld04jh9bvfaf	หวานน้อย 50%	0.00	cmqrf47jx000jld04uppsgd2r	cmprak1wr000e3xj3e60lzs1w
cmqrf47jx000mld04jtv0wej5	เย็น	0.00	cmqrf47jx000jld04uppsgd2r	cmpran7d3000l3xj3w4zm611l
cmqrfrglq0005l104vrjaxswh	หวานน้อย 50%	0.00	cmqrfrglq0003l104t1higna1	cmprak1wr000e3xj3e60lzs1w
cmqrg9nsl0005ie04dh0lxqaf	คั่วอ่อน	0.00	cmqrg9nsl0003ie04yoe38dkf	cmpraghfn000b3xj33nmkm7g2
cmqrg9nsl0006ie0456i4v39g	หวานน้อย 50%	0.00	cmqrg9nsl0003ie04yoe38dkf	cmprak1wr000e3xj3e60lzs1w
cmqrg9nsl0009ie04w80b39e0	หวานน้อย 50%	0.00	cmqrg9nsl0007ie04vwgu7tk1	cmprak1wr000e3xj3e60lzs1w
cmqrg9nsl000aie04a2tcpwem	เย็น	0.00	cmqrg9nsl0007ie04vwgu7tk1	cmpran7d3000l3xj3w4zm611l
cmqrgvum70007kz04mintl5bm	คั่วกลาง	0.00	cmqrgvum70005kz04ztc9jwa3	cmpraghfn000a3xj3le4hn9nj
cmqrgvum70008kz04615sp1v3	หวานน้อย 50%	0.00	cmqrgvum70005kz04ztc9jwa3	cmprak1wr000e3xj3e60lzs1w
cmqrgwl12000fkz040kwfq4xx	คั่วกลาง	0.00	cmqrgwl12000dkz0433yzzbe5	cmpraghfn000a3xj3le4hn9nj
cmqrgwl12000gkz0432bwtkqs	หวานน้อย 50%	0.00	cmqrgwl12000dkz0433yzzbe5	cmprak1wr000e3xj3e60lzs1w
cmqrh9pt6000fl504vcz4lu4f	เย็น	0.00	cmqrh9pt6000dl504fixjts0u	cmpran7d3000l3xj3w4zm611l
cmqrhb1fd000nl5042wom93vv	คั่วกลาง	0.00	cmqrhb1fd000ll5047gvs236s	cmpraghfn000a3xj3le4hn9nj
cmqrhb1fd000ol504mq2god3x	หวานน้อย 50%	0.00	cmqrhb1fd000ll5047gvs236s	cmprak1wr000e3xj3e60lzs1w
cmqrlnkzv0004lb04k5mkgdg4	คั่วเข้ม	0.00	cmqrlnkzv0002lb04uxzxbdfb	cmpraghfn00093xj3teu0s9ye
cmqrlnkzv0005lb04v3h2ngxe	หวานปกติ 100%	0.00	cmqrlnkzv0002lb04uxzxbdfb	cmq3v6ydv0001js04mbuyt8in
cmqrlnkzv0008lb04jxg9be7w	คั่วกลาง	0.00	cmqrlnkzv0006lb043t3en7sa	cmpraghfn000a3xj3le4hn9nj
cmqrlnkzv0009lb04quox919z	หวานปกติ 100%	0.00	cmqrlnkzv0006lb043t3en7sa	cmq3v6ydv0001js04mbuyt8in
cmqrlubpn0003ic04ucshvhe7	เย็น	0.00	cmqrlubpn0001ic04p35rmycr	cmpran7d3000l3xj3w4zm611l
cmqrm6gsz000ilb04ez4netcv	ไม่หวาน 0%	0.00	cmqrm6gsz000glb043tktle4t	cmprak1wr000d3xj3791vuavv
cmqrm6gsz000jlb04hwzplgv8	เย็น	0.00	cmqrm6gsz000glb043tktle4t	cmpran7d3000l3xj3w4zm611l
cmqrm6t1p000rlb04f4p609op	คั่วกลาง	0.00	cmqrm6t1o000plb04o0lyuqqq	cmpraghfn000a3xj3le4hn9nj
cmqrm6t1p000slb04cext84e9	หวานปกติ 100%	0.00	cmqrm6t1o000plb04o0lyuqqq	cmq3v6ydv0001js04mbuyt8in
cmqrmngr0000zlb04aquq1ftn	หวานปกติ 100%	0.00	cmqrmngr0000xlb04smqkle4n	cmprak1ws000f3xj35gi3varl
cmqrmngr00010lb04nx2ywyd3	เย็น	0.00	cmqrmngr0000xlb04smqkle4n	cmpran7d3000l3xj3w4zm611l
cmqrmngr00011lb04oiqdzh99	แยกน้ำแข็ง	0.00	cmqrmngr0000xlb04smqkle4n	cmpraptea000o3xj3zfahd2f7
cmqrmngr00014lb04oxebwtb3	หวานน้อย 50%	0.00	cmqrmngr00012lb045cgcosfh	cmprak1wr000e3xj3e60lzs1w
cmqrmngr00015lb04cw7pln3o	เย็น	0.00	cmqrmngr00012lb045cgcosfh	cmpran7d3000l3xj3w4zm611l
cmqrmngr00018lb04uj6r829a	คั่วกลาง	0.00	cmqrmngr00016lb04m6duzh3k	cmpraghfn000a3xj3le4hn9nj
cmqrmngr00019lb0455w4qthh	ไม่หวาน 0%	0.00	cmqrmngr00016lb04m6duzh3k	cmprak1wr000d3xj3791vuavv
cmqrmngr0001clb042yhb5a4q	หวานน้อย 50%	0.00	cmqrmngr0001alb04rqjm9gah	cmprak1wr000e3xj3e60lzs1w
cmqrnimbr0005jj04jloimytk	หวานปกติ 100%	0.00	cmqrnimbr0003jj04f9bf7czt	cmprak1ws000f3xj35gi3varl
cmqrnimbr0008jj04fubdh1eh	หวานน้อย 50%	0.00	cmqrnimbr0006jj04xgqzu94b	cmprak1wr000e3xj3e60lzs1w
cmqrnimbr000bjj04o9h0accm	หวานปกติ 100%	0.00	cmqrnimbr0009jj04mmiulop1	cmprak1ws000f3xj35gi3varl
cmqsopgjq0004l4045r838acw	คั่วอ่อน	0.00	cmqsopgjq0002l404fw7vhvu6	cmpraghfn000b3xj33nmkm7g2
cmqsopgjq0005l4043pps6xxf	ไม่หวาน 0%	0.00	cmqsopgjq0002l404fw7vhvu6	cmprak1wr000d3xj3791vuavv
cmqsopgjq0008l404pilc7dgc	ไม่หวาน 0%	0.00	cmqsopgjq0006l404dkltwmz7	cmprak1wr000d3xj3791vuavv
cmqsopgjq0009l404j6fjooad	เย็น	0.00	cmqsopgjq0006l404dkltwmz7	cmpran7d3000l3xj3w4zm611l
cmqsopgjq000cl404otwsv28q	หวานน้อย 50%	0.00	cmqsopgjq000al404wa1w9qsu	cmprak1wr000e3xj3e60lzs1w
cmqsopgjq000dl404hrwkqd4z	เย็น	0.00	cmqsopgjq000al404wa1w9qsu	cmpran7d3000l3xj3w4zm611l
cmqspagr00004jr04fzipxbcf	คั่วเข้ม	0.00	cmqspagr00002jr048q5snby8	cmpraghfn00093xj3teu0s9ye
cmqspagr00005jr04jelibevn	หวานปกติ 100%	0.00	cmqspagr00002jr048q5snby8	cmq3v6ydv0001js04mbuyt8in
cmqspu3px0005l704aykkf4n4	คั่วเข้ม	0.00	cmqspu3px0003l704tw8dv6mz	cmpraghfn00093xj3teu0s9ye
cmqspu3px0006l704uf845cov	ไม่หวาน 0%	0.00	cmqspu3px0003l704tw8dv6mz	cmprak1wr000d3xj3791vuavv
cmqspu3px0009l7045l30z9m8	หวานปกติ 100%	0.00	cmqspu3px0007l704usogy67u	cmprak1ws000f3xj35gi3varl
cmqspwbaz0008js04l958awy5	คั่วกลาง	0.00	cmqspwbay0006js04qr96w2zt	cmpraghfn000a3xj3le4hn9nj
cmqspwbaz0009js04un3tpdm3	ไม่หวาน 0%	0.00	cmqspwbay0006js04qr96w2zt	cmprak1wr000d3xj3791vuavv
cmqspwbaz000ajs04fnucgrc0	แยกน้ำแข็ง	0.00	cmqspwbay0006js04qr96w2zt	cmpraptea000o3xj3zfahd2f7
cmqspwbaz000djs04v0vqd6s1	คั่วกลาง	0.00	cmqspwbaz000bjs04uzu5uzuy	cmpraghfn000a3xj3le4hn9nj
cmqspwbaz000ejs04f9enhci2	หวานน้อย 50%	0.00	cmqspwbaz000bjs04uzu5uzuy	cmprak1wr000e3xj3e60lzs1w
cmqspwbaz000fjs04yj9rlr1r	แยกน้ำแข็ง	0.00	cmqspwbaz000bjs04uzu5uzuy	cmpraptea000o3xj3zfahd2f7
cmqspwbaz000ijs04n3i3fs2q	คั่วเข้ม	0.00	cmqspwbaz000gjs04r7k116w2	cmpraghfn00093xj3teu0s9ye
cmqspwbaz000jjs04qsqeo73z	แยกน้ำแข็ง	0.00	cmqspwbaz000gjs04r7k116w2	cmpraptea000o3xj3zfahd2f7
cmqspwbaz000kjs04x38ragox	หวานปกติ 100%	0.00	cmqspwbaz000gjs04r7k116w2	cmq3v6ydv0001js04mbuyt8in
cmqspwbaz000njs04njrje4ir	หวานน้อย 50%	0.00	cmqspwbaz000ljs04qoydumqh	cmprak1wr000e3xj3e60lzs1w
cmqspwbaz000ojs04vgotgm1s	แยกน้ำแข็ง	0.00	cmqspwbaz000ljs04qoydumqh	cmpraptea000o3xj3zfahd2f7
cmqsqb9re0004l504jq04y09u	ไม่หวาน 0%	0.00	cmqsqb9re0002l504vu8fw6un	cmprak1wr000d3xj3791vuavv
cmqsqb9re0005l504hv12gf9n	แยกน้ำแข็ง	0.00	cmqsqb9re0002l504vu8fw6un	cmpraptea000o3xj3zfahd2f7
cmqsqccav0005jv04okgu8inq	หวานปกติ 100%	0.00	cmqsqccav0003jv04aqmof1ds	cmprak1ws000f3xj35gi3varl
cmqsqccav0008jv04t4owc0k6	หวานปกติ 100%	0.00	cmqsqccav0006jv04faxnow2l	cmprak1ws000f3xj35gi3varl
cmqsqcot5000ejv04msrkhl17	หวานน้อย 50%	0.00	cmqsqcot5000cjv04qnqhjcjk	cmprak1wr000e3xj3e60lzs1w
cmqsqcot5000fjv04hpgkybnt	เย็น	0.00	cmqsqcot5000cjv04qnqhjcjk	cmpran7d3000l3xj3w4zm611l
cmqsqcot5000gjv04wen9qjzw	แยกน้ำแข็ง	0.00	cmqsqcot5000cjv04qnqhjcjk	cmpraptea000o3xj3zfahd2f7
cmqsql12w000xjs04os9u1lcr	หวานมาก 120%	0.00	cmqsql12w000vjs04i1ehi38d	cmprak1ws000g3xj3pdboyhw3
cmqsql12w000yjs04berd03i5	เย็น	0.00	cmqsql12w000vjs04i1ehi38d	cmpran7d3000l3xj3w4zm611l
cmqsqnrgy000ojv04zg75c65k	คั่วเข้ม	0.00	cmqsqnrgy000mjv049tn4ymg5	cmpraghfn00093xj3teu0s9ye
cmqsqnrgy000pjv045sd4bnkq	ไม่หวาน 0%	0.00	cmqsqnrgy000mjv049tn4ymg5	cmprak1wr000d3xj3791vuavv
cmqsqpxl50010jv04dyu52oef	หวานน้อย 50%	0.00	cmqsqpxl5000yjv04k75do8p4	cmprak1wr000e3xj3e60lzs1w
cmqsqpxl50011jv045eq8js4a	เย็น	0.00	cmqsqpxl5000yjv04k75do8p4	cmpran7d3000l3xj3w4zm611l
cmqsqs6uo0018jv04aluxpoua	คั่วเข้ม	0.00	cmqsqs6uo0016jv0411thh8jy	cmpraghfn00093xj3teu0s9ye
cmqsqs6uo0019jv04cmvcuga3	ไม่หวาน 0%	0.00	cmqsqs6uo0016jv0411thh8jy	cmprak1wr000d3xj3791vuavv
cmqsqxi1s001fjv043y0rgmnn	คั่วเข้ม	0.00	cmqsqxi1s001djv0456d48r7j	cmpraghfn00093xj3teu0s9ye
cmqsqxi1s001gjv047o4s896f	ไม่หวาน 0%	0.00	cmqsqxi1s001djv0456d48r7j	cmprak1wr000d3xj3791vuavv
cmqsqzvh20018js04uviouvc9	หวานปกติ 100%	0.00	cmqsqzvh10016js04u9og9bji	cmq3v6ydv0001js04mbuyt8in
cmqsr2w4q001ejs049fiynut9	หวานน้อย 50%	0.00	cmqsr2w4q001cjs0419qvh5si	cmprak1wr000e3xj3e60lzs1w
cmqsr4y70001mjv048495hj0w	คั่วเข้ม	0.00	cmqsr4y70001kjv049739narm	cmpraghfn00093xj3teu0s9ye
cmqsr4y70001njv04c3uexpg9	หวานปกติ 100%	0.00	cmqsr4y70001kjv049739narm	cmq3v6ydv0001js04mbuyt8in
cmqsraqs9001vjs04dz3wdtx9	คั่วกลาง	0.00	cmqsraqs9001tjs042vjys8t0	cmpraghfn000a3xj3le4hn9nj
cmqsrwzrq0004l504cwvs3ipz	หวานน้อย 50%	0.00	cmqsrwzrq0002l50464i6ndm4	cmprak1wr000e3xj3e60lzs1w
cmqsrwzrq0005l5042u8lj32b	เย็น	0.00	cmqsrwzrq0002l50464i6ndm4	cmpran7d3000l3xj3w4zm611l
cmqsrxt81002fjs04v685897h	หวานปกติ 100%	0.00	cmqsrxt81002djs04c6skmv1i	cmprak1ws000f3xj35gi3varl
cmqss6unk002pjs04ma2ykli5	หวานน้อย 50%	0.00	cmqss6unk002njs04q7gcu6no	cmprak1wr000e3xj3e60lzs1w
cmqss6unk002sjs04mkseub10	หวานปกติ 100%	0.00	cmqss6unk002qjs04tkrgh41n	cmprak1ws000f3xj35gi3varl
cmqssend50032js04e60kcyn5	คั่วกลาง	0.00	cmqssend50030js048snj4fet	cmpraghfn000a3xj3le4hn9nj
cmqssend50033js04spdbbrbr	ไม่หวาน 0%	0.00	cmqssend50030js048snj4fet	cmprak1wr000d3xj3791vuavv
cmqsujg810005jp04fodau7a4	หวานน้อย 50%	0.00	cmqsujg810003jp04hssmyq7z	cmprak1wr000e3xj3e60lzs1w
cmqsujg810006jp04uwlrfhi0	เย็น	0.00	cmqsujg810003jp04hssmyq7z	cmpran7d3000l3xj3w4zm611l
cmqsvh2wd0005ic04mglbl2gv	หวานน้อย 50%	0.00	cmqsvh2wd0003ic047xto4tx2	cmprak1wr000e3xj3e60lzs1w
cmqsvh63a000bic04z64olenm	หวานน้อย 50%	0.00	cmqsvh63a0009ic04iutosk05	cmprak1wr000e3xj3e60lzs1w
cmqsvhfat000hic04p6gi8hu1	คั่วกลาง	0.00	cmqsvhfat000fic0494gqecsi	cmpraghfn000a3xj3le4hn9nj
cmqsvhfat000iic04zsrp6eov	ไม่หวาน 0%	0.00	cmqsvhfat000fic0494gqecsi	cmprak1wr000d3xj3791vuavv
cmqswad3b0003l704h3kkgjfx	หวานปกติ 100%	0.00	cmqswad3b0001l7040i4tupnv	cmprak1ws000f3xj35gi3varl
cmqswad3b0004l7043xyekdm1	เย็น	0.00	cmqswad3b0001l7040i4tupnv	cmpran7d3000l3xj3w4zm611l
cmqswgblk0003ju04azshwo5e	หวานน้อย 50%	0.00	cmqswgblj0001ju04chq7mio9	cmprak1wr000e3xj3e60lzs1w
cmqswgblk0004ju04xy7tpgo7	เย็น	0.00	cmqswgblj0001ju04chq7mio9	cmpran7d3000l3xj3w4zm611l
cmqswgblk0007ju040nw998gi	คั่วเข้ม	0.00	cmqswgblk0005ju043obsqt48	cmpraghfn00093xj3teu0s9ye
cmqswgblk000aju04qbv0l0o1	หวานปกติ 100%	0.00	cmqswgblk0008ju04d7ti6qrv	cmq3v6ydv0001js04mbuyt8in
cmqswgblk000bju04o9ib353z	เย็น	0.00	cmqswgblk0008ju04d7ti6qrv	cmpran7d3000l3xj3w4zm611l
cmqsx6mqv0005kv04940txqw4	หวานน้อย 50%	0.00	cmqsx6mqv0003kv04fit6ooux	cmprak1wr000e3xj3e60lzs1w
cmqsx6mqv0006kv04bu3oobqd	เย็น	0.00	cmqsx6mqv0003kv04fit6ooux	cmpran7d3000l3xj3w4zm611l
cmqsymgxl0005le04mguwopnb	เย็น	0.00	cmqsymgxl0003le0439z9t5tn	cmpran7d3000l3xj3w4zm611l
cmqsziijv0005ld04q8rv88h9	หวานปกติ 100%	0.00	cmqsziijv0003ld048pal6x84	cmprak1ws000f3xj35gi3varl
cmqsziijv0008ld04yv3zbw45	หวานปกติ 100%	0.00	cmqsziijv0006ld04yu6j0ptj	cmprak1ws000f3xj35gi3varl
cmqsziijv000bld046w970gk9	หวานปกติ 100%	0.00	cmqsziijv0009ld04392cnp80	cmprak1ws000f3xj35gi3varl
cmqt160cf0004l5046j2ejl3k	คั่วกลาง	0.00	cmqt160cf0002l504f8y62l1u	cmpraghfn000a3xj3le4hn9nj
cmqt160cf0005l504swjiyl08	หวานปกติ 100%	0.00	cmqt160cf0002l504f8y62l1u	cmq3v6ydv0001js04mbuyt8in
cmqt1clfd0005l704fy1wue3o	คั่วกลาง	0.00	cmqt1clfd0003l70470aqe3li	cmpraghfn000a3xj3le4hn9nj
cmqt1clfd0006l704yds5xr40	หวานปกติ 100%	0.00	cmqt1clfd0003l70470aqe3li	cmq3v6ydv0001js04mbuyt8in
cmqt3j7kp0005jp047zn70qkp	หวานน้อย 50%	0.00	cmqt3j7kp0003jp0432d5eyib	cmprak1wr000e3xj3e60lzs1w
cmqt3z3n8000fl504hvg8leev	หวานน้อย 50%	0.00	cmqt3z3n8000dl5049fvrqyi6	cmprak1wr000e3xj3e60lzs1w
cmqt3z3n8000il504n0vidi6n	คั่วเข้ม	0.00	cmqt3z3n8000gl504shr2qooo	cmpraghfn00093xj3teu0s9ye
cmqt3z3n8000jl504fqjzv6cl	ไม่หวาน 0%	0.00	cmqt3z3n8000gl504shr2qooo	cmprak1wr000d3xj3791vuavv
cmqtj9p2j00043xqfeiyguwr6	หวานปกติ 100%	0.00	cmqtj9p2j00023xqf6jkwjsi1	cmprak1ws000f3xj35gi3varl
cmqtj9p2j00053xqfbvu0iyk2	เย็น	0.00	cmqtj9p2j00023xqf6jkwjsi1	cmpran7d3000l3xj3w4zm611l
cmqu54za30005kz04rdas5fre	หวานปกติ 100%	0.00	cmqu54za30003kz04hyng1v09	cmprak1ws000f3xj35gi3varl
cmqu54za30006kz04a6f1qe7w	เย็น	0.00	cmqu54za30003kz04hyng1v09	cmpran7d3000l3xj3w4zm611l
cmqu54za30009kz04dacsu1we	คั่วกลาง	0.00	cmqu54za30007kz04qicd1jya	cmpraghfn000a3xj3le4hn9nj
cmqu54za3000akz04dlue3tsj	หวานปกติ 100%	0.00	cmqu54za30007kz04qicd1jya	cmq3v6ydv0001js04mbuyt8in
cmqu5bmn80004js04j10a6z36	คั่วอ่อน	0.00	cmqu5bmn80002js044t308s7x	cmpraghfn000b3xj33nmkm7g2
cmqu5bmn80005js04oedefkr1	ไม่หวาน 0%	0.00	cmqu5bmn80002js044t308s7x	cmprak1wr000d3xj3791vuavv
cmqu5ov4b0004l204uygc8af8	คั่วเข้ม	0.00	cmqu5ov4b0002l204qeni6scf	cmpraghfn00093xj3teu0s9ye
cmqu5ov4b0005l204tfln8wkl	แยกน้ำแข็ง	0.00	cmqu5ov4b0002l204qeni6scf	cmpraptea000o3xj3zfahd2f7
cmqu5ov4b0006l204fq3d0lvi	หวานปกติ 100%	0.00	cmqu5ov4b0002l204qeni6scf	cmq3v6ydv0001js04mbuyt8in
cmqu5ov4b0009l204mc50ndxu	คั่วกลาง	0.00	cmqu5ov4b0007l204bgldxdq7	cmpraghfn000a3xj3le4hn9nj
cmqu5ov4b000al204kk1fpxn4	ไม่หวาน 0%	0.00	cmqu5ov4b0007l204bgldxdq7	cmprak1wr000d3xj3791vuavv
cmqu5ov4b000bl204htegmhfe	แยกน้ำแข็ง	0.00	cmqu5ov4b0007l204bgldxdq7	cmpraptea000o3xj3zfahd2f7
cmqu5ov4b000el2049mn8b89j	คั่วกลาง	0.00	cmqu5ov4b000cl2041urtx3f1	cmpraghfn000a3xj3le4hn9nj
cmqu5ov4b000fl204g0ypzgrz	หวานน้อย 50%	0.00	cmqu5ov4b000cl2041urtx3f1	cmprak1wr000e3xj3e60lzs1w
cmqu5ov4b000gl204zlihp677	แยกน้ำแข็ง	0.00	cmqu5ov4b000cl2041urtx3f1	cmpraptea000o3xj3zfahd2f7
cmqu5ov4b000jl204jaavrlw0	หวานน้อย 50%	0.00	cmqu5ov4b000hl2049f0zd7cd	cmprak1wr000e3xj3e60lzs1w
cmqu5ov4b000kl204rbaf3maq	เย็น	0.00	cmqu5ov4b000hl2049f0zd7cd	cmpran7d3000l3xj3w4zm611l
cmqu5ov4b000ll204tr1u0q9l	แยกน้ำแข็ง	0.00	cmqu5ov4b000hl2049f0zd7cd	cmpraptea000o3xj3zfahd2f7
cmqu5ov4b000ol204htz92rt1	หวานปกติ 100%	0.00	cmqu5ov4b000ml204xxre32pf	cmprak1ws000f3xj35gi3varl
cmqu5u99y0005le04ii5gf4j9	หวานมาก 120%	0.00	cmqu5u99y0003le04rz39mqtx	cmprak1ws000g3xj3pdboyhw3
cmqu5u99y0006le04d086g42d	เย็น	0.00	cmqu5u99y0003le04rz39mqtx	cmpran7d3000l3xj3w4zm611l
cmqu5wd1z001tl204oux4rbyv	คั่วเข้ม	0.00	cmqu5wd1z001rl204xbcct8jz	cmpraghfn00093xj3teu0s9ye
cmqu5wd1z001ul204suip2257	ไม่หวาน 0%	0.00	cmqu5wd1z001rl204xbcct8jz	cmprak1wr000d3xj3791vuavv
cmqu5z3xg0020l204dn6gbvxe	หวานน้อย 50%	0.00	cmqu5z3xg001yl2043ip74ybx	cmprak1wr000e3xj3e60lzs1w
cmqu60x7w0026l2041k0if9mm	หวานปกติ 100%	0.00	cmqu60x7w0024l204ymvcf4pm	cmprak1ws000f3xj35gi3varl
cmqu60x7x0029l204ujqu13x0	หวานปกติ 100%	0.00	cmqu60x7w0027l204ekus8n08	cmprak1ws000f3xj35gi3varl
cmqu5ov4b000pl204pr2q7e5k	เย็น	0.00	cmqu5ov4b000ml204xxre32pf	cmpran7d3000l3xj3w4zm611l
cmqu5ph4u000xl2043f5qusbo	คั่วเข้ม	0.00	cmqu5ph4u000vl204ug0u4068	cmpraghfn00093xj3teu0s9ye
cmqu5ph4u000yl204btd9yfgc	แยกน้ำแข็ง	0.00	cmqu5ph4u000vl204ug0u4068	cmpraptea000o3xj3zfahd2f7
cmqu5ph4u000zl204pk8oed2e	หวานปกติ 100%	0.00	cmqu5ph4u000vl204ug0u4068	cmq3v6ydv0001js04mbuyt8in
cmqu5ph4u0012l204i8gqhzzf	คั่วกลาง	0.00	cmqu5ph4u0010l204wlovgzq0	cmpraghfn000a3xj3le4hn9nj
cmqu5ph4u0013l204wdoz5y9f	ไม่หวาน 0%	0.00	cmqu5ph4u0010l204wlovgzq0	cmprak1wr000d3xj3791vuavv
cmqu5ph4u0014l204xps10ji1	แยกน้ำแข็ง	0.00	cmqu5ph4u0010l204wlovgzq0	cmpraptea000o3xj3zfahd2f7
cmqu5ph4u0017l20414s5d4d9	คั่วกลาง	0.00	cmqu5ph4u0015l204sj3rarst	cmpraghfn000a3xj3le4hn9nj
cmqu5ph4u0018l2043x2smwr4	หวานน้อย 50%	0.00	cmqu5ph4u0015l204sj3rarst	cmprak1wr000e3xj3e60lzs1w
cmqu5ph4u0019l204dnqqd7ss	แยกน้ำแข็ง	0.00	cmqu5ph4u0015l204sj3rarst	cmpraptea000o3xj3zfahd2f7
cmqu5ph4u001cl204lkawv8mn	หวานน้อย 50%	0.00	cmqu5ph4u001al204in11saoh	cmprak1wr000e3xj3e60lzs1w
cmqu5ph4u001dl204go9zudm8	เย็น	0.00	cmqu5ph4u001al204in11saoh	cmpran7d3000l3xj3w4zm611l
cmqu5ph4u001el204d1cejk6a	แยกน้ำแข็ง	0.00	cmqu5ph4u001al204in11saoh	cmpraptea000o3xj3zfahd2f7
cmqu5ph4u001hl204xb9w2kg7	หวานปกติ 100%	0.00	cmqu5ph4u001fl2048kcl7vpw	cmprak1ws000f3xj35gi3varl
cmqu5ph4u001il204b7s01p1i	เย็น	0.00	cmqu5ph4u001fl2048kcl7vpw	cmpran7d3000l3xj3w4zm611l
cmqu675xn0004jl04varwpu8s	คั่วเข้ม	0.00	cmqu675xn0002jl04yqblxhff	cmpraghfn00093xj3teu0s9ye
cmqu675xn0005jl0416bylyyk	ไม่หวาน 0%	0.00	cmqu675xn0002jl04yqblxhff	cmprak1wr000d3xj3791vuavv
cmqu675xn0006jl04hiwxzgo1	แยกน้ำแข็ง	0.00	cmqu675xn0002jl04yqblxhff	cmpraptea000o3xj3zfahd2f7
cmqu69t7f002nl2045ecw70uj	หวานปกติ 100%	0.00	cmqu69t7f002ll204j4eoitbk	cmprak1ws000f3xj35gi3varl
cmqu6a3pw002tl204ykeq3u7u	หวานน้อย 50%	0.00	cmqu6a3pw002rl204zxn8mgo1	cmprak1wr000e3xj3e60lzs1w
cmqu6hkvd000ql805bex9jh4q	คั่วเข้ม	0.00	cmqu6hkvd000ol805f5m2zpx9	cmpraghfn00093xj3teu0s9ye
cmqu6hkvd000rl805qewz0clo	ไม่หวาน 0%	0.00	cmqu6hkvd000ol805f5m2zpx9	cmprak1wr000d3xj3791vuavv
cmqu6lort000hle041pyf1uke	หวานปกติ 100%	0.00	cmqu6lort000fle04z44xv22v	cmq3v6ydv0001js04mbuyt8in
cmqu6niaf000ple04u1bwqu7i	คั่วเข้ม	0.00	cmqu6niaf000nle04cl599s5q	cmpraghfn00093xj3teu0s9ye
cmqu6niaf000qle0418l0gmac	ไม่หวาน 0%	0.00	cmqu6niaf000nle04cl599s5q	cmprak1wr000d3xj3791vuavv
cmqu6seyg0034l204nai9xmyc	คั่วเข้ม	0.00	cmqu6seyg0032l2044upw658e	cmpraghfn00093xj3teu0s9ye
cmqu6seyg0035l2043zo3yxo3	หวานปกติ 100%	0.00	cmqu6seyg0032l2044upw658e	cmq3v6ydv0001js04mbuyt8in
cmqu6seyg0038l204crxui42b	หวานน้อย 50%	0.00	cmqu6seyg0036l204tylooxt6	cmprak1wr000e3xj3e60lzs1w
cmqu6frwa000dl805kh4jx31m	คั่วกลาง	0.00	cmqu6frwa000bl805ilv3b9rn	cmpraghfn000a3xj3le4hn9nj
cmqu6frwa000el8050xsww8d7	ไม่หวาน 0%	0.00	cmqu6frwa000bl805ilv3b9rn	cmprak1wr000d3xj3791vuavv
cmqu7d0h20005ld04hqtsuiiw	คั่วเข้ม	0.00	cmqu7d0h20003ld04m0djlmol	cmpraghfn00093xj3teu0s9ye
cmqu7jpdz000bld04bo3lucwx	คั่วเข้ม	0.00	cmqu7jpdz0009ld04m3au717s	cmpraghfn00093xj3teu0s9ye
cmqu7jpdz000cld04miwn3srd	ไม่หวาน 0%	0.00	cmqu7jpdz0009ld04m3au717s	cmprak1wr000d3xj3791vuavv
cmqu7mptc000ild043n22cu03	หวานปกติ 100%	0.00	cmqu7mptc000gld04nh7ddgui	cmprak1ws000f3xj35gi3varl
cmqu7vtwl000sld04seuim9kh	หวานน้อย 50%	0.00	cmqu7vtwl000qld04wxx40dna	cmprak1wr000e3xj3e60lzs1w
cmqu7vtwl000tld04jr63ukpe	เย็น	0.00	cmqu7vtwl000qld04wxx40dna	cmpran7d3000l3xj3w4zm611l
cmqu7w23g0010ld04de7vnsgo	หวานน้อย 50%	0.00	cmqu7w23g000yld044bqe9hlx	cmprak1wr000e3xj3e60lzs1w
cmqu7wiio0016ld04901dtpu9	คั่วกลาง	0.00	cmqu7wiio0014ld04uj2fcg7v	cmpraghfn000a3xj3le4hn9nj
cmqu7wiio0017ld04tm1v7u0p	ไม่หวาน 0%	0.00	cmqu7wiio0014ld04uj2fcg7v	cmprak1wr000d3xj3791vuavv
cmqu80m830018le04gwt0bjdx	หวานปกติ 100%	0.00	cmqu80m830016le04r8j2a8oz	cmprak1ws000f3xj35gi3varl
cmqubd48a0005l7041rzs1jua	หวานน้อย 50%	0.00	cmqubd48a0003l704qbdvqjlk	cmprak1wr000e3xj3e60lzs1w
cmqubd48a0008l7046gw60ste	หวานน้อย 50%	0.00	cmqubd48a0006l7048qrb2snu	cmprak1wr000e3xj3e60lzs1w
cmqubd48b0009l704vnuaydj8	เย็น	0.00	cmqubd48a0006l7048qrb2snu	cmpran7d3000l3xj3w4zm611l
cmqubgzgi000fl704b4orzwan	หวานปกติ 100%	0.00	cmqubgzgi000dl704mtbyva6b	cmprak1ws000f3xj35gi3varl
cmqubgzgi000gl704o7slpvho	เย็น	0.00	cmqubgzgi000dl704mtbyva6b	cmpran7d3000l3xj3w4zm611l
cmqubgzgi000jl704sjhcwiqy	หวานปกติ 100%	0.00	cmqubgzgi000hl704h6lmh2gf	cmprak1ws000f3xj35gi3varl
cmqubgzgi000kl70480ggcred	เย็น	0.00	cmqubgzgi000hl704h6lmh2gf	cmpran7d3000l3xj3w4zm611l
cmqubqvo1000ul704hwt3phrz	คั่วกลาง	0.00	cmqubqvo1000sl704qy3g3x5f	cmpraghfn000a3xj3le4hn9nj
cmqubqvo1000vl704qsmdaxyt	หวานน้อย 50%	0.00	cmqubqvo1000sl704qy3g3x5f	cmprak1wr000e3xj3e60lzs1w
cmquc8umj0006ju042evao1x3	คั่วอ่อน	0.00	cmquc8umj0004ju040nrvx4rs	cmpraghfn000b3xj33nmkm7g2
cmquc8umj0007ju04cjfktuxp	หวานน้อย 50%	0.00	cmquc8umj0004ju040nrvx4rs	cmprak1wr000e3xj3e60lzs1w
cmquc8umj000aju04cjs7ajwl	คั่วกลาง	0.00	cmquc8umj0008ju04i6r2nm7x	cmpraghfn000a3xj3le4hn9nj
cmquc8umj000bju042c6n3bdc	ไม่หวาน 0%	0.00	cmquc8umj0008ju04i6r2nm7x	cmprak1wr000d3xj3791vuavv
cmquc8umj000cju04u2l4uoea	แยกน้ำแข็ง	0.00	cmquc8umj0008ju04i6r2nm7x	cmpraptea000o3xj3zfahd2f7
cmquc8umj000fju04vfy06bjl	หวานน้อย 50%	0.00	cmquc8umj000dju042w93kgl7	cmprak1wr000e3xj3e60lzs1w
cmquc8umj000gju0491hkztqf	เย็น	0.00	cmquc8umj000dju042w93kgl7	cmpran7d3000l3xj3w4zm611l
cmquczn5n0005jp04f3se8dds	หวานน้อย 50%	0.00	cmquczn5m0003jp04zsk42x8z	cmprak1wr000e3xj3e60lzs1w
cmquczn5n0006jp04uz3m65d3	เย็น	0.00	cmquczn5m0003jp04zsk42x8z	cmpran7d3000l3xj3w4zm611l
cmquczn5n0009jp048te98d3h	หวานน้อย 50%	0.00	cmquczn5n0007jp04virg0v1i	cmprak1wr000e3xj3e60lzs1w
cmquczn5n000ajp0401csm84p	เย็น	0.00	cmquczn5n0007jp04virg0v1i	cmpran7d3000l3xj3w4zm611l
cmquf4zs60005l704kzf7b3w4	หวานน้อย 50%	0.00	cmquf4zs60003l704yuik6w0c	cmprak1wr000e3xj3e60lzs1w
cmquf4zs60006l704ajmerrs3	เย็น	0.00	cmquf4zs60003l704yuik6w0c	cmpran7d3000l3xj3w4zm611l
cmqugvw1e0005ky04aav34hxf	หวานปกติ 100%	0.00	cmqugvw1e0003ky049l3abcio	cmprak1ws000f3xj35gi3varl
cmquh8biu000dky04ob6isuvn	คั่วเข้ม	0.00	cmquh8biu000bky04fvwim5is	cmpraghfn00093xj3teu0s9ye
cmquh8biu000eky04kv4mebvj	ไม่หวาน 0%	0.00	cmquh8biu000bky04fvwim5is	cmprak1wr000d3xj3791vuavv
cmquhvspz0005kz04cxjvpgbs	เย็น	0.00	cmquhvspy0003kz04eg648bjy	cmpran7d3000l3xj3w4zm611l
cmquhvspz0008kz04f4n7oc1q	คั่วกลาง	0.00	cmquhvspz0006kz048iiosbjt	cmpraghfn000a3xj3le4hn9nj
cmquhvspz0009kz042eg121w6	หวานปกติ 100%	0.00	cmquhvspz0006kz048iiosbjt	cmq3v6ydv0001js04mbuyt8in
cmquiehyl0005l8048f7buhia	หวานน้อย 50%	0.00	cmquiehyl0003l804nk1c7tsr	cmprak1wr000e3xj3e60lzs1w
cmquismqe0005l40473dkqdi8	หวานน้อย 50%	0.00	cmquismqe0003l4041n4ac6yb	cmprak1wr000e3xj3e60lzs1w
cmquismqe0006l404716fnt74	เย็น	0.00	cmquismqe0003l4041n4ac6yb	cmpran7d3000l3xj3w4zm611l
cmqvkh56r0007jr04uxet2y11	คั่วเข้ม	0.00	cmqvkh56r0005jr04fmxxcsl9	cmpraghfn00093xj3teu0s9ye
cmqvkh56r0008jr04ze9tqog2	ไม่หวาน 0%	0.00	cmqvkh56r0005jr04fmxxcsl9	cmprak1wr000d3xj3791vuavv
cmqvkh56r000bjr04emsgcv45	คั่วกลาง	0.00	cmqvkh56r0009jr04dowgxhq5	cmpraghfn000a3xj3le4hn9nj
cmqvkh56r000cjr04kbby9lrt	หวานปกติ 100%	0.00	cmqvkh56r0009jr04dowgxhq5	cmq3v6ydv0001js04mbuyt8in
cmqvkhuen0005l904m6nyv8zl	คั่วเข้ม	0.00	cmqvkhuen0003l9049wp5uth7	cmpraghfn00093xj3teu0s9ye
cmqvkhuen0006l904uwo3orn6	หวานปกติ 100%	0.00	cmqvkhuen0003l9049wp5uth7	cmq3v6ydv0001js04mbuyt8in
cmqvlh5e20004kt04veil87c6	หวานน้อย 50%	0.00	cmqvlh5e20002kt04ndjcopea	cmprak1wr000e3xj3e60lzs1w
cmqvlh5e20005kt049wm48rgd	เย็น	0.00	cmqvlh5e20002kt04ndjcopea	cmpran7d3000l3xj3w4zm611l
cmqvlj8mi0003jm04gxzg6lhr	คั่วอ่อน	0.00	cmqvlj8mi0001jm04eq7j6ajo	cmpraghfn000b3xj33nmkm7g2
cmqvlj8mi0004jm043z3u76cn	ไม่หวาน 0%	0.00	cmqvlj8mi0001jm04eq7j6ajo	cmprak1wr000d3xj3791vuavv
cmqvlj8mi0007jm04fx67ae2l	หวานปกติ 100%	0.00	cmqvlj8mi0005jm0419k63rkt	cmprak1ws000f3xj35gi3varl
cmqvlj8mi0008jm04xjko89ub	เย็น	0.00	cmqvlj8mi0005jm0419k63rkt	cmpran7d3000l3xj3w4zm611l
cmqvlj8mi000bjm04mpwrd0my	หวานน้อย 50%	0.00	cmqvlj8mi0009jm04j4jhnkvx	cmprak1wr000e3xj3e60lzs1w
cmqvlj8mi000cjm04v0bf6igl	เย็น	0.00	cmqvlj8mi0009jm04j4jhnkvx	cmpran7d3000l3xj3w4zm611l
cmqvlln5v0005l504zyr9xzjz	หวานปกติ 100%	0.00	cmqvlln5v0003l504jvox60de	cmq3v6ydv0001js04mbuyt8in
cmqvlob4k0005ky04qy4owtu7	คั่วเข้ม	0.00	cmqvlob4k0003ky047tyd9sgs	cmpraghfn00093xj3teu0s9ye
cmqvlob4k0006ky04y2df70fd	ไม่หวาน 0%	0.00	cmqvlob4k0003ky047tyd9sgs	cmprak1wr000d3xj3791vuavv
cmqvlob4l0009ky04l5wgc9zw	หวานปกติ 100%	0.00	cmqvlob4l0007ky04gs87regh	cmprak1ws000f3xj35gi3varl
cmqvlob4l000cky04ep3979iz	หวานปกติ 100%	0.00	cmqvlob4l000aky04a0giphv8	cmprak1ws000f3xj35gi3varl
cmqvlow8u0005js04qj57zjnt	คั่วเข้ม	0.00	cmqvlow8u0003js0499lew2ji	cmpraghfn00093xj3teu0s9ye
cmqvlow8u0006js04jnavczoq	ไม่หวาน 0%	0.00	cmqvlow8u0003js0499lew2ji	cmprak1wr000d3xj3791vuavv
cmqvlp9nr000iky04s2p7pyv1	หวานน้อย 50%	0.00	cmqvlp9nq000gky04tvc35bxm	cmprak1wr000e3xj3e60lzs1w
cmqvlp9nr000jky04dfv8piwt	เย็น	0.00	cmqvlp9nq000gky04tvc35bxm	cmpran7d3000l3xj3w4zm611l
cmqvlpbtz000pky04vmkydxub	หวานปกติ 100%	0.00	cmqvlpbty000nky04sls4iufu	cmprak1ws000f3xj35gi3varl
cmqvlpbtz000qky04t7kfs9gz	แยกน้ำแข็ง	0.00	cmqvlpbty000nky04sls4iufu	cmpraptea000o3xj3zfahd2f7
cmqvlt1kf000yky04we08i6yj	หวานปกติ 100%	0.00	cmqvlt1kf000wky04g37le17d	cmprak1ws000f3xj35gi3varl
cmqvlt1kf000zky04a979cp3w	เย็น	0.00	cmqvlt1kf000wky04g37le17d	cmpran7d3000l3xj3w4zm611l
cmqvlt1kf0010ky04e7fhhmsy	แยกน้ำแข็ง	0.00	cmqvlt1kf000wky04g37le17d	cmpraptea000o3xj3zfahd2f7
cmqvlt1kf0013ky0444txfxfl	คั่วกลาง	0.00	cmqvlt1kf0011ky04ulfjkbji	cmpraghfn000a3xj3le4hn9nj
cmqvlt1kf0014ky040449t0nt	ไม่หวาน 0%	0.00	cmqvlt1kf0011ky04ulfjkbji	cmprak1wr000d3xj3791vuavv
cmqvlt1kf0015ky04ng8sn7az	แยกน้ำแข็ง	0.00	cmqvlt1kf0011ky04ulfjkbji	cmpraptea000o3xj3zfahd2f7
cmqvlwhwv000djs04i0t51hu6	หวานปกติ 100%	0.00	cmqvlwhwv000bjs048jih32a6	cmprak1ws000f3xj35gi3varl
cmqvlwhwv000ejs04w0fdulev	เย็น	0.00	cmqvlwhwv000bjs048jih32a6	cmpran7d3000l3xj3w4zm611l
cmqvm8ttk000njs04083hhvcm	คั่วเข้ม	0.00	cmqvm8ttk000ljs04whfjcang	cmpraghfn00093xj3teu0s9ye
cmqvme3ch000bl504fuxph93f	หวานน้อย 50%	0.00	cmqvme3ch0009l504glraacj6	cmprak1wr000e3xj3e60lzs1w
cmqvme3ch000cl504bwgfzwsh	เย็น	0.00	cmqvme3ch0009l504glraacj6	cmpran7d3000l3xj3w4zm611l
cmqvmin8p0004l804evxk76oq	หวานปกติ 100%	0.00	cmqvmin8p0002l804w179hygh	cmq3v6ydv0001js04mbuyt8in
cmqvmsyb7000kl504fj5y6s80	หวานน้อย 50%	0.00	cmqvmsyb7000il504u5z7xuce	cmprak1wr000e3xj3e60lzs1w
cmqvmwj5p000xl5045e8a5tis	หวานน้อย 50%	0.00	cmqvmwj5p000vl504pz82fwh7	cmprak1wr000e3xj3e60lzs1w
cmqvmwj5p0010l5047djidxnm	หวานปกติ 100%	0.00	cmqvmwj5p000yl504bx34v343	cmq3v6ydv0001js04mbuyt8in
cmqvmwj5p0013l504t3uxwawl	หวานปกติ 100%	0.00	cmqvmwj5p0011l504covelbif	cmprak1ws000f3xj35gi3varl
cmqvmyrne001bl504muc5dh38	หวานน้อย 50%	0.00	cmqvmyrne0019l504ihkef79v	cmprak1wr000e3xj3e60lzs1w
cmqvn46sw000zjs04kzyzigbh	คั่วเข้ม	0.00	cmqvn46sw000xjs040td4v9ij	cmpraghfn00093xj3teu0s9ye
cmqvn46sw0010js04blo67tej	หวานปกติ 100%	0.00	cmqvn46sw000xjs040td4v9ij	cmq3v6ydv0001js04mbuyt8in
cmqvn92xz001jl504ob3hq2fb	หวานปกติ 100%	0.00	cmqvn92xz001hl5049chmlz50	cmprak1ws000f3xj35gi3varl
cmqvpsalm0005if04dsg1dnqs	คั่วเข้ม	0.00	cmqvpsalm0003if04mds1y25p	cmpraghfn00093xj3teu0s9ye
cmqvpsalm0006if04q5cezb2v	ไม่หวาน 0%	0.00	cmqvpsalm0003if04mds1y25p	cmprak1wr000d3xj3791vuavv
cmqvpsltp000cif04ylrhwo2q	หวานน้อย 50%	0.00	cmqvpsltp000aif045080prdg	cmprak1wr000e3xj3e60lzs1w
cmqvpsltq000fif04af36tn2h	หวานน้อย 50%	0.00	cmqvpsltp000dif04sccl26ne	cmprak1wr000e3xj3e60lzs1w
cmqvpuzmx0005l404u2qcv0ng	คั่วเข้ม	0.00	cmqvpuzmx0003l4048nr08t2y	cmpraghfn00093xj3teu0s9ye
cmqvpuzmx0006l404zxdv9czj	หวานน้อย 50%	0.00	cmqvpuzmx0003l4048nr08t2y	cmprak1wr000e3xj3e60lzs1w
cmqvpuzmx0009l404zcu5bljg	หวานน้อย 50%	0.00	cmqvpuzmx0007l4041dvt3tqo	cmprak1wr000e3xj3e60lzs1w
cmqvq5iib000rif04c5t98mp5	หวานปกติ 100%	0.00	cmqvq5iib000pif045ksqbtze	cmprak1ws000f3xj35gi3varl
cmqvq5iib000sif04vpl6ok04	เย็น	0.00	cmqvq5iib000pif045ksqbtze	cmpran7d3000l3xj3w4zm611l
cmqvqneye0005jp04inl6qjkq	หวานปกติ 100%	0.00	cmqvqneye0003jp047hgw8zb7	cmprak1ws000f3xj35gi3varl
cmqvqzqb2000djp0442zo2q59	คั่วกลาง	0.00	cmqvqzqb2000bjp04kgkenzw2	cmpraghfn000a3xj3le4hn9nj
cmqvqzqb2000ejp04i8yrtets	ไม่หวาน 0%	0.00	cmqvqzqb2000bjp04kgkenzw2	cmprak1wr000d3xj3791vuavv
cmqvvczoc0004l1043f2qr7kp	คั่วกลาง	0.00	cmqvvczoc0002l1041e70v5qb	cmpraghfn000a3xj3le4hn9nj
cmqvvczoc0005l1043uqe9i1p	หวานปกติ 100%	0.00	cmqvvczoc0002l1041e70v5qb	cmq3v6ydv0001js04mbuyt8in
cmqvwf0p70003lb04ujducw5d	เย็น	0.00	cmqvwf0p70001lb04h0rpwxhc	cmpran7d3000l3xj3w4zm611l
cmqyf83fy0004jo04th8t81pn	คั่วอ่อน	0.00	cmqyf83fy0002jo04vnwbfd7y	cmpraghfn000b3xj33nmkm7g2
cmqyf83fy0005jo043akaynvh	ไม่หวาน 0%	0.00	cmqyf83fy0002jo04vnwbfd7y	cmprak1wr000d3xj3791vuavv
cmqyf83fy0008jo0490srfkcd	หวานปกติ 100%	0.00	cmqyf83fy0006jo04nzhp0ki5	cmprak1ws000f3xj35gi3varl
cmqyf83fy0009jo04rkn2vt9i	เย็น	0.00	cmqyf83fy0006jo04nzhp0ki5	cmpran7d3000l3xj3w4zm611l
cmqyf83fz000cjo046mheiiie	หวานปกติ 100%	0.00	cmqyf83fz000ajo04ls5f6nnm	cmprak1ws000f3xj35gi3varl
cmqyf83fz000djo04fvhd7gq1	เย็น	0.00	cmqyf83fz000ajo04ls5f6nnm	cmpran7d3000l3xj3w4zm611l
cmqyfm4qb0005jl048eq9u5mg	คั่วเข้ม	0.00	cmqyfm4qb0003jl04ziquzuoo	cmpraghfn00093xj3teu0s9ye
cmqyfm4qb0006jl042yxx1vgz	ไม่หวาน 0%	0.00	cmqyfm4qb0003jl04ziquzuoo	cmprak1wr000d3xj3791vuavv
cmqyfrmqz0004jl04kouzpqi4	คั่วเข้ม	0.00	cmqyfrmqz0002jl04koczs19c	cmpraghfn00093xj3teu0s9ye
cmqyfrmqz0005jl04ponsbwcf	ไม่หวาน 0%	0.00	cmqyfrmqz0002jl04koczs19c	cmprak1wr000d3xj3791vuavv
cmqyfrmqz0006jl047kbibaxl	แยกน้ำแข็ง	0.00	cmqyfrmqz0002jl04koczs19c	cmpraptea000o3xj3zfahd2f7
cmqyfuauz000ejl04e44uye15	หวานปกติ 100%	0.00	cmqyfuauz000cjl04evpsrci8	cmprak1ws000f3xj35gi3varl
cmqyfuauz000fjl041o8btjoy	เย็น	0.00	cmqyfuauz000cjl04evpsrci8	cmpran7d3000l3xj3w4zm611l
cmqyg31jy0005lb04sowg2pur	หวานน้อย 50%	0.00	cmqyg31jy0003lb04608s4x4v	cmprak1wr000e3xj3e60lzs1w
cmqyg5nbi000gjl04aguib8cf	ไม่หวาน 0%	0.00	cmqyg5nbi000ejl04909o2cax	cmprak1wr000d3xj3791vuavv
cmqyg5nbi000hjl04l8sn9ahb	เพิ่มช็อต	10.00	cmqyg5nbi000ejl04909o2cax	cmpralv7i000j3xj3b1u9nwyo
cmqyg5tjt000njl046gwq5ga2	คั่วเข้ม	0.00	cmqyg5tjs000ljl04gze8deae	cmpraghfn00093xj3teu0s9ye
cmqyg5tjt000ojl041z9b0wdc	ไม่หวาน 0%	0.00	cmqyg5tjs000ljl04gze8deae	cmprak1wr000d3xj3791vuavv
cmqyg7p85000wjl04nppluc08	หวานมาก 120%	0.00	cmqyg7p85000ujl044dl8u3h6	cmprak1ws000g3xj3pdboyhw3
cmqyg7p85000xjl04ske2994g	เย็น	0.00	cmqyg7p85000ujl044dl8u3h6	cmpran7d3000l3xj3w4zm611l
cmqygs0l50019jl04wzb9mvb3	คั่วเข้ม	0.00	cmqygs0l50017jl04oq3dettl	cmpraghfn00093xj3teu0s9ye
cmqyh0nsh0005jx04r7lavy0r	หวานปกติ 100%	0.00	cmqyh0nsh0003jx04jii1hktv	cmq3v6ydv0001js04mbuyt8in
cmqyhje5a000fjx047gfsctkx	หวานปกติ 100%	0.00	cmqyhje5a000djx04t5bx7kit	cmq3v6ydv0001js04mbuyt8in
cmqyhva8r000ajl047h1elmhc	คั่วกลาง	0.00	cmqyhva8r0008jl04ax23g8qt	cmpraghfn000a3xj3le4hn9nj
cmqyhva8r000bjl048ia1n34z	หวานมาก 120%	0.00	cmqyhva8r0008jl04ax23g8qt	cmq3v6ydv0002js04x855n4v7
cmqyhwqe2000njx04d44hg2k8	คั่วเข้ม	0.00	cmqyhwqe2000ljx04qyc9w0bt	cmpraghfn00093xj3teu0s9ye
cmqyhwqe2000ojx0460hh8d75	หวานน้อย 50%	0.00	cmqyhwqe2000ljx04qyc9w0bt	cmprak1wr000e3xj3e60lzs1w
cmqyi1rza000hjl040hwvlq2w	คั่วเข้ม	0.00	cmqyi1rza000fjl04f79oobht	cmpraghfn00093xj3teu0s9ye
cmqyi1rza000ijl04qybg26t2	หวานปกติ 100%	0.00	cmqyi1rza000fjl04f79oobht	cmq3v6ydv0001js04mbuyt8in
cmqyi7tyh0012jx0413zwfz5j	หวานปกติ 100%	0.00	cmqyi7tyh0010jx0496hkvvgv	cmprak1ws000f3xj35gi3varl
cmqyl4dx50005l204g70wppd3	หวานน้อย 50%	0.00	cmqyl4dx50003l204z5yalb3z	cmprak1wr000e3xj3e60lzs1w
cmqyl59i8000bl204thi120zr	หวานน้อย 50%	0.00	cmqyl59i80009l204uc9208om	cmprak1wr000e3xj3e60lzs1w
cmqyl59i8000el204zlgrj4id	หวานน้อย 50%	0.00	cmqyl59i8000cl2049cevofzb	cmprak1wr000e3xj3e60lzs1w
cmqylepfg000ml2044e1euk6w	ไม่หวาน 0%	0.00	cmqylepfg000kl2041t41nv5b	cmprak1wr000d3xj3791vuavv
cmqylepfg000nl2049nx297nq	เย็น	0.00	cmqylepfg000kl2041t41nv5b	cmpran7d3000l3xj3w4zm611l
cmqyma7980005l804v44m51gg	คั่วกลาง	0.00	cmqyma7970003l804e5mz4jqg	cmpraghfn000a3xj3le4hn9nj
cmqyma7980006l80412jo4jms	ไม่หวาน 0%	0.00	cmqyma7970003l804e5mz4jqg	cmprak1wr000d3xj3791vuavv
cmqynbmy60005jm04qee1ge2f	หวานน้อย 50%	0.00	cmqynbmy60003jm04om8j1zy8	cmprak1wr000e3xj3e60lzs1w
cmqynbmy60006jm04hkuzzxi5	เย็น	0.00	cmqynbmy60003jm04om8j1zy8	cmpran7d3000l3xj3w4zm611l
cmqynlxtc0005l704l7prc22g	คั่วเข้ม	0.00	cmqynlxtc0003l704o5hgblv7	cmpraghfn00093xj3teu0s9ye
cmqynlxtc0006l704wllb4pl8	หวานปกติ 100%	0.00	cmqynlxtc0003l704o5hgblv7	cmprak1ws000f3xj35gi3varl
cmqynlxtc0009l704cq859hlq	หวานปกติ 100%	0.00	cmqynlxtc0007l704bkkp7we5	cmprak1ws000f3xj35gi3varl
cmqynlxtc000al704vpkp3ow3	เย็น	0.00	cmqynlxtc0007l704bkkp7we5	cmpran7d3000l3xj3w4zm611l
cmqynlxtc000dl704rcg3bdx4	คั่วเข้ม	0.00	cmqynlxtc000bl704s97ui9q4	cmpraghfn00093xj3teu0s9ye
cmqynlxtc000el704c750za0i	ไม่หวาน 0%	0.00	cmqynlxtc000bl704s97ui9q4	cmprak1wr000d3xj3791vuavv
cmqynlxtc000hl704eilwrn1m	คั่วเข้ม	0.00	cmqynlxtc000fl704zpudja8y	cmpraghfn00093xj3teu0s9ye
cmqynlxtc000il704xi85jhm3	หวานปกติ 100%	0.00	cmqynlxtc000fl704zpudja8y	cmq3v6ydv0001js04mbuyt8in
cmqynx3nr000ejm046okgpnpw	หวานน้อย 50%	0.00	cmqynx3nq000cjm0439n357io	cmprak1wr000e3xj3e60lzs1w
cmqynx3nr000fjm04xehqknyv	เย็น	0.00	cmqynx3nq000cjm0439n357io	cmpran7d3000l3xj3w4zm611l
cmqyqzxsi000cl404jl3nbval	หวานปกติ 100%	0.00	cmqyqzxsi000al404tb6qk8b8	cmprak1ws000f3xj35gi3varl
cmqyqzxsi000dl40476vhdys3	เย็น	0.00	cmqyqzxsi000al404tb6qk8b8	cmpran7d3000l3xj3w4zm611l
cmqyr7p970005l704d011ej1a	ข้าวราดแกง 2 อย่าง	10.00	cmqyr7p970003l704hiwgnjav	cmqyr3ea0000hl40491y3rszk
cmqyr7w4n000bl704stgni5iv	ข้าวราดแกง 1 อย่าง	5.00	cmqyr7w4m0009l704v15ms4xi	cmqyqzbdb0006l404gcgxtrke
cmqyr806q000hl704z3mnt9bn	กับข้าว(อย่างเดียว)	0.00	cmqyr806q000fl70443yj14fs	cmqyqzbdb0005l404zjd2oixn
cmqzu62160004jn04xjb0khm2	หวานน้อย 50%	0.00	cmqzu62160002jn04ph9yaue7	cmprak1wr000e3xj3e60lzs1w
cmqzu62160007jn04o0osn231	หวานน้อย 50%	0.00	cmqzu62160005jn04rpemyusv	cmprak1wr000e3xj3e60lzs1w
cmqzu6216000ajn049njgia82	เย็น	0.00	cmqzu62160008jn04mfvijhi9	cmpran7d3000l3xj3w4zm611l
cmqzu6216000djn04q49rus9s	คั่วเข้ม	0.00	cmqzu6216000bjn04i8c7tzop	cmpraghfn00093xj3teu0s9ye
cmqzu6216000ejn04bccwj3qm	หวานปกติ 100%	0.00	cmqzu6216000bjn04i8c7tzop	cmq3v6ydv0001js04mbuyt8in
cmqzu88gj000mjn04y9chtxmx	คั่วอ่อน	0.00	cmqzu88gj000kjn04quxs19bs	cmpraghfn000b3xj33nmkm7g2
cmqzu88gj000njn04bxoex6uf	ไม่หวาน 0%	0.00	cmqzu88gj000kjn04quxs19bs	cmprak1wr000d3xj3791vuavv
cmqzunybb0005l5047575cw4i	คั่วเข้ม	0.00	cmqzunybb0003l504l10vq4fn	cmpraghfn00093xj3teu0s9ye
cmqzunybb0006l504gw6vjmba	แยกน้ำแข็ง	0.00	cmqzunybb0003l504l10vq4fn	cmpraptea000o3xj3zfahd2f7
cmqzunybb0007l504m76k25wc	หวานปกติ 100%	0.00	cmqzunybb0003l504l10vq4fn	cmq3v6ydv0001js04mbuyt8in
cmqzunybb000al504jka2jji9	หวานน้อย 50%	0.00	cmqzunybb0008l504twtyp287	cmprak1wr000e3xj3e60lzs1w
cmqzunybb000bl504fnf2plsu	เย็น	0.00	cmqzunybb0008l504twtyp287	cmpran7d3000l3xj3w4zm611l
cmqzunybb000cl504gcohzybn	แยกน้ำแข็ง	0.00	cmqzunybb0008l504twtyp287	cmpraptea000o3xj3zfahd2f7
cmqzunybc000fl504of1lah6l	หวานปกติ 100%	0.00	cmqzunybb000dl504o8lxsvz8	cmprak1ws000f3xj35gi3varl
cmqzunybc000gl50411xzjxp5	เย็น	0.00	cmqzunybb000dl504o8lxsvz8	cmpran7d3000l3xj3w4zm611l
cmqzunybc000hl504mx2gajcl	แยกน้ำแข็ง	0.00	cmqzunybb000dl504o8lxsvz8	cmpraptea000o3xj3zfahd2f7
cmqzunybc000kl504q5chhw3a	คั่วเข้ม	0.00	cmqzunybc000il504alc4myaa	cmpraghfn00093xj3teu0s9ye
cmqzunybc000ll504bmz5c386	ลดช็อต	0.00	cmqzunybc000il504alc4myaa	cmpralv7i000i3xj32dj8ylsa
cmqzunybc000ml504g2fq4zov	แยกน้ำแข็ง	0.00	cmqzunybc000il504alc4myaa	cmpraptea000o3xj3zfahd2f7
cmqzunybc000nl504661arkuk	หวานปกติ 100%	0.00	cmqzunybc000il504alc4myaa	cmq3v6ydv0001js04mbuyt8in
cmqzva6ev0005l704tk7k28wo	หวานปกติ 100%	0.00	cmqzva6ev0003l704voqgwyqv	cmq3v6ydv0001js04mbuyt8in
cmqzva6ev0008l704t2mwy14u	คั่วเข้ม	0.00	cmqzva6ev0006l704qormwcj0	cmpraghfn00093xj3teu0s9ye
cmqzva6ev0009l704whlao83a	ไม่หวาน 0%	0.00	cmqzva6ev0006l704qormwcj0	cmprak1wr000d3xj3791vuavv
cmqzvnxad000el704n6xy9cmr	คั่วเข้ม	0.00	cmqzvnxad000cl7049qfljism	cmpraghfn00093xj3teu0s9ye
cmqzvnxad000fl704t4iwazsd	หวานปกติ 100%	0.00	cmqzvnxad000cl7049qfljism	cmq3v6ydv0001js04mbuyt8in
cmqzvoicx0005l404kuqj7kfb	คั่วเข้ม	0.00	cmqzvoicx0003l404lvguqdm7	cmpraghfn00093xj3teu0s9ye
cmqzvoicx0006l404a9y7igj6	ไม่หวาน 0%	0.00	cmqzvoicx0003l404lvguqdm7	cmprak1wr000d3xj3791vuavv
cmqzvoicx0007l404jehteqk5	แยกน้ำแข็ง	0.00	cmqzvoicx0003l404lvguqdm7	cmpraptea000o3xj3zfahd2f7
cmqzvoicx000al404nl0coskj	คั่วเข้ม	0.00	cmqzvoicx0008l4048dsdhm60	cmpraghfn00093xj3teu0s9ye
cmqzvoicx000bl404tf47222e	ไม่หวาน 0%	0.00	cmqzvoicx0008l4048dsdhm60	cmprak1wr000d3xj3791vuavv
cmqzvrvnp0004k1041c7xyw8p	คั่วกลาง	0.00	cmqzvrvnp0002k104ln1dj1we	cmpraghfn000a3xj3le4hn9nj
cmqzvrvnp0005k10476u3ubfx	ไม่หวาน 0%	0.00	cmqzvrvnp0002k104ln1dj1we	cmprak1wr000d3xj3791vuavv
cmqzvtoh20005ib04kgmm6unp	หวานปกติ 100%	0.00	cmqzvtoh20003ib04izfjy97h	cmprak1ws000f3xj35gi3varl
cmqzvtoh20008ib044jxv3isw	หวานปกติ 100%	0.00	cmqzvtoh20006ib04g9j70r7g	cmprak1ws000f3xj35gi3varl
cmqzvua1b000eib04qcewlrb7	หวานมาก 120%	0.00	cmqzvua1b000cib04vzu5l1m9	cmprak1ws000g3xj3pdboyhw3
cmqzvua1b000fib04clxqvql3	เย็น	0.00	cmqzvua1b000cib04vzu5l1m9	cmpran7d3000l3xj3w4zm611l
cmqzw02l10004l204v875u3jp	คั่วเข้ม	0.00	cmqzw02l10002l204eqjp0v1a	cmpraghfn00093xj3teu0s9ye
cmqzw02l10005l204ro6apg4u	ไม่หวาน 0%	0.00	cmqzw02l10002l204eqjp0v1a	cmprak1wr000d3xj3791vuavv
cmqzw02l10006l204gr8qx9j8	แยกน้ำแข็ง	0.00	cmqzw02l10002l204eqjp0v1a	cmpraptea000o3xj3zfahd2f7
cmqzw0kco0004ju04mrozl31f	หวานน้อย 50%	0.00	cmqzw0kco0002ju04qjeys6bs	cmprak1wr000e3xj3e60lzs1w
cmqzw0kco0005ju04as8n21fr	เย็น	0.00	cmqzw0kco0002ju04qjeys6bs	cmpran7d3000l3xj3w4zm611l
cmqzw141o000fl204kflxk7ya	หวานปกติ 100%	0.00	cmqzw141o000dl204ykjl85by	cmprak1ws000f3xj35gi3varl
cmqzw141o000gl204akj0jkmu	เย็น	0.00	cmqzw141o000dl204ykjl85by	cmpran7d3000l3xj3w4zm611l
cmqzwlqo50004l2049s6380a9	คั่วกลาง	0.00	cmqzwlqo50002l204spgexr18	cmpraghfn000a3xj3le4hn9nj
cmqzwlqo50005l204v8pvm7zg	หวานน้อย 50%	0.00	cmqzwlqo50002l204spgexr18	cmprak1wr000e3xj3e60lzs1w
cmqzwtdpv000el20429cs53t3	คั่วเข้ม	0.00	cmqzwtdpv000cl204w2fwy49z	cmpraghfn00093xj3teu0s9ye
cmqzwtdpv000fl204hz5mt19v	ไม่หวาน 0%	0.00	cmqzwtdpv000cl204w2fwy49z	cmprak1wr000d3xj3791vuavv
cmqzwty7s000ll20430cevx7r	คั่วเข้ม	0.00	cmqzwty7s000jl204m9spy4qj	cmpraghfn00093xj3teu0s9ye
cmqzwuqoe000vl2046i8zp6o3	คั่วเข้ม	0.00	cmqzwuqoe000tl204fj0agg63	cmpraghfn00093xj3teu0s9ye
cmqzwuqoe000wl204lzfkjdip	หวานน้อย 50%	0.00	cmqzwuqoe000tl204fj0agg63	cmprak1wr000e3xj3e60lzs1w
cmqzwuvzo0012l204vgn4otie	หวานน้อย 50%	0.00	cmqzwuvzo0010l204zln9oth9	cmprak1wr000e3xj3e60lzs1w
cmqzx16gl001el20428ol9ovy	คั่วกลาง	0.00	cmqzx16gl001cl204s3j5yyzv	cmpraghfn000a3xj3le4hn9nj
cmqzx16gl001fl204iz0xkz7n	หวานปกติ 100%	0.00	cmqzx16gl001cl204s3j5yyzv	cmq3v6ydv0001js04mbuyt8in
cmqzx77x10009jv04vd5n5fu5	หวานปกติ 100%	0.00	cmqzx77x10007jv043w31spda	cmprak1ws000f3xj35gi3varl
cmqzxbcx6001rl2042y7cnlde	คั่วเข้ม	0.00	cmqzxbcx6001pl2041hd18w58	cmpraghfn00093xj3teu0s9ye
cmqzxbcx6001sl204gkbmtlqx	ไม่หวาน 0%	0.00	cmqzxbcx6001pl2041hd18w58	cmprak1wr000d3xj3791vuavv
cmqzxgkla0020l2041p3db0fz	คั่วเข้ม	0.00	cmqzxgkla001yl204b4ewpl0a	cmpraghfn00093xj3teu0s9ye
cmqzxgkla0021l20408tymav1	หวานน้อย 50%	0.00	cmqzxgkla001yl204b4ewpl0a	cmprak1wr000e3xj3e60lzs1w
cmqzxim3y0029l2041z30r9ze	หวานปกติ 100%	0.00	cmqzxim3y0027l2043jrf22q6	cmprak1ws000f3xj35gi3varl
cmqzxk1dy000jjv04k3enrlq7	คั่วเข้ม	0.00	cmqzxk1dy000hjv0416jp1qcv	cmpraghfn00093xj3teu0s9ye
cmqzzyl1j0005l504gvmloxfv	หวานน้อย 50%	0.00	cmqzzyl1j0003l504v1j2ww37	cmprak1wr000e3xj3e60lzs1w
cmqzzyl1j0006l504z4acypfd	เย็น	0.00	cmqzzyl1j0003l504v1j2ww37	cmpran7d3000l3xj3w4zm611l
cmr005g1o000el504r5e1iuwt	คั่วเข้ม	0.00	cmr005g1o000cl504u39e8qtb	cmpraghfn00093xj3teu0s9ye
cmr005g1o000fl5041cs0tsup	ไม่หวาน 0%	0.00	cmr005g1o000cl504u39e8qtb	cmprak1wr000d3xj3791vuavv
cmr00nkfb0005jr04hclg59d6	หวานปกติ 100%	0.00	cmr00nkfb0003jr042rp7wse7	cmprak1ws000f3xj35gi3varl
cmr00nkfb0006jr04vofruqv5	เย็น	0.00	cmr00nkfb0003jr042rp7wse7	cmpran7d3000l3xj3w4zm611l
cmr00nkfb0009jr04gzle3zbv	หวานปกติ 100%	0.00	cmr00nkfb0007jr04xaul66vg	cmq3v6ydv0001js04mbuyt8in
cmr00nqhc000fjr04j6jp7q9g	คั่วอ่อน	0.00	cmr00nqhc000djr04g44ll0q2	cmpraghfn000b3xj33nmkm7g2
cmr00nqhc000gjr0410yn5xjn	ไม่หวาน 0%	0.00	cmr00nqhc000djr04g44ll0q2	cmprak1wr000d3xj3791vuavv
cmr00oysw000mjr04wvjvz3i5	หวานน้อย 50%	0.00	cmr00oysw000kjr046qwuqyam	cmprak1wr000e3xj3e60lzs1w
cmr00oysw000njr04i5bo0ve2	เย็น	0.00	cmr00oysw000kjr046qwuqyam	cmpran7d3000l3xj3w4zm611l
cmr00oysw000qjr04y5nhyoux	หวานปกติ 100%	0.00	cmr00oysw000ojr04nmu0cuck	cmprak1ws000f3xj35gi3varl
cmr00oysw000rjr046teuu0v6	เย็น	0.00	cmr00oysw000ojr04nmu0cuck	cmpran7d3000l3xj3w4zm611l
cmr00oysw000sjr04k2rs5k96	แยกน้ำแข็ง	0.00	cmr00oysw000ojr04nmu0cuck	cmpraptea000o3xj3zfahd2f7
cmr00u9g20005l704weq6qym8	หวานปกติ 100%	0.00	cmr00u9g20003l704b5ughbex	cmq3v6ydv0001js04mbuyt8in
cmr00u9g20006l704li2dubu2	เย็น	0.00	cmr00u9g20003l704b5ughbex	cmpran7d3000l3xj3w4zm611l
cmr00umwc000cl704507sf283	คั่วเข้ม	0.00	cmr00umwc000al704qlvt2wt8	cmpraghfn00093xj3teu0s9ye
cmr00umwc000dl7042htprca9	ไม่หวาน 0%	0.00	cmr00umwc000al704qlvt2wt8	cmprak1wr000d3xj3791vuavv
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.order_items (id, quantity, "unitPrice", subtotal, note, "orderId", "productId") FROM stdin;
cmqzu62160002jn04ph9yaue7	1	40.00	40.00	\N	cmqzu62160000jn04v7d8urqd	cmpqqmd4h002g3xvorpy8wab0
cmpr9cgwi00053xj3ut5xcs2a	1	40.00	40.00	\N	cmpr9cgwi00033xj31qufevei	cmpqqm4cx000a3xvo6ij5ksrm
cmprbxrj800023xv182e420ba	2	45.00	90.00	\N	cmprbxrj600003xv1wn5cwg4q	cmpqqmhq9003k3xvoadvnhwjy
cmprrzj450003jt04b65kr8ei	1	40.00	40.00	\N	cmprrzj440001jt04g0o4pnfx	cmpqqmd4h002g3xvorpy8wab0
cmprsdg5p000ajt04zn31drgf	1	40.00	40.00	\N	cmprsdg5p0008jt04skruj31p	cmpqqm65m000q3xvow1n8n4d2
cmptyhvzb0002l804ovotqzk2	1	40.00	40.00	\N	cmptyhvzb0000l804ucmfskuf	cmpqqm65m000q3xvow1n8n4d2
cmpu4czuy000ajy04ry3rsmpp	1	45.00	45.00	\N	cmpu4czuy0008jy048skwpqw7	cmpqqm89400183xvo7b2i3mk9
cmpu4laht000kjy04wn9pwa46	1	40.00	40.00	\N	cmpu4laht000ijy042ikyqdnr	cmpqqm6di000s3xvog0defnci
cmpu59edy0002l804kmlteay5	1	40.00	40.00	\N	cmpu59edy0000l804bjfgmfz2	cmpqqm6di000s3xvog0defnci
cmpuscer10002l7040cb4vlud	1	40.00	40.00	\N	cmpuscer10000l704jawwp0xs	cmprepa050001jp04hcbe0l2v
cmpushqhb000dl704t2gsr0b7	1	35.00	35.00	\N	cmpushqhb000bl704j4943lbl	cmpqqma23001o3xvoooy0q9ws
cmpw7kynv0003js04xkoezyc4	1	35.00	35.00	\N	cmpw7kynu0001js043af1n07i	cmpqqm8iy001a3xvodugp204w
cmpw7kynv0007js04vrk7tr98	1	35.00	35.00	\N	cmpw7kynu0001js043af1n07i	cmpqqm9eg001i3xvoqq2p0pcl
cmpw7kynv000bjs041u7myr4n	1	35.00	35.00	\N	cmpw7kynu0001js043af1n07i	cmpqqma23001o3xvoooy0q9ws
cmpw7lkgv000kjs04ez4dpxla	4	35.00	140.00	\N	cmpw7lkgv000ijs04hyofli3c	cmpqqm4l9000c3xvojqoj1yyt
cmpw7m0j0000tjs049b8vcsu5	1	35.00	35.00	\N	cmpw7m0j0000rjs04ayicm4w3	cmpqqm8iy001a3xvodugp204w
cmpw7okso0012js04rhp22xaj	3	35.00	105.00	\N	cmpw7okso0010js04oxd0l2ja	cmpqqm4l9000c3xvojqoj1yyt
cmpw7okso0016js04jimdqmvn	1	40.00	40.00	\N	cmpw7okso0010js04oxd0l2ja	cmpqqm81900163xvo5msxvp3a
cmpw7okso001ajs041976vufy	1	40.00	40.00	\N	cmpw7okso0010js04oxd0l2ja	cmpqqm81900163xvo5msxvp3a
cmpw7okso001ejs048y1fonrs	1	35.00	35.00	\N	cmpw7okso0010js04oxd0l2ja	cmpqqm8iy001a3xvodugp204w
cmpw7p6f3001njs04szoxwixl	1	30.00	30.00	\N	cmpw7p6f3001ljs0493v3ovqi	cmpqqm8qt001c3xvom39q1hsv
cmpw7p6f3001qjs04rlnnt8fp	2	35.00	70.00	\N	cmpw7p6f3001ljs0493v3ovqi	cmpqqm9eg001i3xvoqq2p0pcl
cmpw7p6f3001ujs04j1mvg15r	1	35.00	35.00	\N	cmpw7p6f3001ljs0493v3ovqi	cmpqqm8iy001a3xvodugp204w
cmpw7u75d0023js04vzqzu6el	1	35.00	35.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqm4l9000c3xvojqoj1yyt
cmpw7u75d0027js04zfuujnku	2	40.00	80.00	\N	cmpw7u75d0021js04vam6tebi	cmprepa050001jp04hcbe0l2v
cmpw7u75d002cjs04a0vk5ab4	1	40.00	40.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqm81900163xvo5msxvp3a
cmpw7u75d002gjs042rik6vnt	1	40.00	40.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqm3ot00063xvoeortkzib
cmpw7u75d002jjs043zlvugrl	1	40.00	40.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqmd4h002g3xvorpy8wab0
cmpw7u75d002mjs0411r70a32	1	35.00	35.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqmc1300263xvodgeiz5il
cmpw7u75d002pjs04jrtro6it	3	40.00	120.00	\N	cmpw7u75d0021js04vam6tebi	cmpqqm4t7000e3xvoazlktde5
cmpw7wuk2002xjs04wxge3jcy	1	40.00	40.00	\N	cmpw7wuk2002vjs04gnhdu0p7	cmpqqm3ot00063xvoeortkzib
cmpw7wuk20030js0415k1r4ed	1	40.00	40.00	\N	cmpw7wuk2002vjs04gnhdu0p7	cmpqqm3ot00063xvoeortkzib
cmpw7wuk20033js04cen3l23x	1	35.00	35.00	\N	cmpw7wuk2002vjs04gnhdu0p7	cmpqqm8iy001a3xvodugp204w
cmpw7wuk20037js04hxgt1w1o	1	45.00	45.00	มัทฉะลาเต้น้ำผึ้งเพิ่มหวาน	cmpw7wuk2002vjs04gnhdu0p7	cmpqqmdcc002i3xvo4phz7u97
cmpw7yf7n003djs045suzp4kk	1	45.00	45.00	คนละครึ่งรวม 2 แก้ว 80 บาท	cmpw7yf7n003bjs044xfq7m6y	cmpqqmblb00223xvok0kay89v
cmpw7yf7n003ejs04yxmc8mhm	1	35.00	35.00	\N	cmpw7yf7n003bjs044xfq7m6y	cmpqqm8iy001a3xvodugp204w
cmpw82lzi0003l404xqzh41u7	2	40.00	80.00	\N	cmpw82lzi0001l4041sqpnwip	cmpqqm45100083xvoo43pm2fa
cmpw82lzi0007l404xz43xuia	1	40.00	40.00	\N	cmpw82lzi0001l4041sqpnwip	cmprepa050001jp04hcbe0l2v
cmpw82lzi000cl404yutx7vaa	1	40.00	40.00	\N	cmpw82lzi0001l4041sqpnwip	cmprepa050001jp04hcbe0l2v
cmpy6et8w00033xoz3poil5ir	1	40.00	40.00	\N	cmpy6et8w00013xozwek9fuyg	cmpqqm6di000s3xvog0defnci
cmpy7dhzs00033xilb5fyocpr	1	40.00	40.00	\N	cmpy7dhzs00013xilojuzzw97	cmpqqm6di000s3xvog0defnci
cmpy8rgim0002l504sps6da39	1	40.00	40.00	\N	cmpy8rgim0000l504nzvht0rq	cmpqqmd4h002g3xvorpy8wab0
cmpy8rgim0005l5041x6nauui	1	45.00	45.00	\N	cmpy8rgim0000l504nzvht0rq	cmpqqmbdf00203xvoi39rfzmh
cmpy8t5ah000bl504v9379crc	1	40.00	40.00	\N	cmpy8t5ah0009l504125vt8kh	cmpqqm65m000q3xvow1n8n4d2
cmpy8vdjy0002jo042ivcyjyy	1	40.00	40.00	\N	cmpy8vdjy0000jo04autj6aeq	cmpqqm6di000s3xvog0defnci
cmpy8vdjy0006jo04dfndqlv8	1	40.00	40.00	\N	cmpy8vdjy0000jo04autj6aeq	cmpqqm81900163xvo5msxvp3a
cmpy8wk4t0003kw04wb3k3ey0	1	50.00	50.00	\N	cmpy8wk4t0001kw049zwbalm2	cmpqqm45100083xvoo43pm2fa
cmpy9bomr0002js04nnszm1e8	1	50.00	50.00	\N	cmpy9bomr0000js04wg0jzabt	cmpqqm4cx000a3xvo6ij5ksrm
cmpya2icv0002jr04xq2yrc4h	1	45.00	45.00	\N	cmpya2icv0000jr0483dlbk03	cmpqqmdk7002k3xvoo1d970sf
cmpya51gh0007jr04dx7fuz8g	1	35.00	35.00	\N	cmpya51gg0005jr04o2x1r012	cmpqqm8yp001e3xvolh59nlvx
cmpyn85rp0002jo04yar6fixb	2	40.00	80.00	\N	cmpyn85rp0000jo046amu4tk5	cmpqqm58z000i3xvo7kzkzfoh
cmpyn85rq0006jo040lbyy3sf	1	40.00	40.00	\N	cmpyn85rp0000jo046amu4tk5	cmpqqmd4h002g3xvorpy8wab0
cmpyn85rq000ajo04wepbsjnp	1	35.00	35.00	\N	cmpyn85rp0000jo046amu4tk5	cmpqqmc1300263xvodgeiz5il
cmpyo24f70003k305hihscakl	1	40.00	40.00	\N	cmpyo24f70001k305w69f14oy	cmprepa050001jp04hcbe0l2v
cmpyo3c3f000dk3050o8imkvn	1	35.00	35.00	\N	cmpyo3c3f000bk305hw58ra46	cmpqqm4l9000c3xvojqoj1yyt
cmpyo3c3f000hk305f45zcp7m	1	35.00	35.00	\N	cmpyo3c3f000bk305hw58ra46	cmpqqm4l9000c3xvojqoj1yyt
cmpyo5o8m000pk3056m5ovl9z	1	40.00	40.00	\N	cmpyo5o8l000nk3059zpmxlnp	cmprepa050001jp04hcbe0l2v
cmpyo8l420003l7048to7kczd	1	40.00	40.00	\N	cmpyo8l420001l7047zs7wc5q	cmprepa050001jp04hcbe0l2v
cmpyos7o4000dl7047qsvo16e	5	35.00	175.00	\N	cmpyos7o4000bl704y8zsr9oh	cmpqqm4l9000c3xvojqoj1yyt
cmpyov4k20002ju047tsszw3l	2	40.00	80.00	\N	cmpyov4k10000ju04ecmvai9z	cmpqqm4t7000e3xvoazlktde5
cmpyov4k20006ju0404q0r2zt	1	40.00	40.00	\N	cmpyov4k10000ju04ecmvai9z	cmprepa050001jp04hcbe0l2v
cmpypdxlc000ml704b24436ra	1	40.00	40.00	\N	cmpypdxlc000kl704e97b6jei	cmpqqm45100083xvoo43pm2fa
cmpypoacr0003jp04knb9f2f6	1	35.00	35.00	\N	cmpypoacr0001jp04t0pvmpi1	cmpqqm8iy001a3xvodugp204w
cmpypw91f000vl7048g8allsr	1	35.00	35.00	\N	cmpypw91f000tl704gdmnje6v	cmpqqm4l9000c3xvojqoj1yyt
cmpypw91f000zl704rgsdsyua	1	45.00	45.00	\N	cmpypw91f000tl704gdmnje6v	cmpqqmdk7002k3xvoo1d970sf
cmpyqb4gh0015l704exmipkim	1	40.00	40.00	\N	cmpyqb4gh0013l704wwxhlkqm	cmpqqm4cx000a3xvo6ij5ksrm
cmpyqtxgz000djp04mh30da2x	1	40.00	40.00	\N	cmpyqtxgz000bjp043qd3fs2w	cmpqqm65m000q3xvow1n8n4d2
cmpyqtxgz000gjp045l40eb6e	1	40.00	40.00	\N	cmpyqtxgz000bjp043qd3fs2w	cmpqqm45100083xvoo43pm2fa
cmpyqzle8001el704rl1l86ie	1	40.00	40.00	\N	cmpyqzle8001cl704f58q896q	cmpqqm4t7000e3xvoazlktde5
cmpyr4lyz000pjp04loheho5y	1	40.00	40.00	\N	cmpyr4lyz000njp04kl5c34rf	cmpqqm65m000q3xvow1n8n4d2
cmpyrbegh001ml704yhgpheqq	1	40.00	40.00	\N	cmpyrbegh001kl7043gsxxdbo	cmpqqm45100083xvoo43pm2fa
cmpyrcbrw001vl7040hiaet9d	1	40.00	40.00	\N	cmpyrcbrw001tl704mobwy8li	cmpqqm513000g3xvo0iex8rrm
cmpyrgxvn000xjp04xl8lco5f	1	40.00	40.00	\N	cmpyrgxvn000vjp04i8fcma6t	cmpqqm81900163xvo5msxvp3a
cmpyrlxmq0016jp047tejmw7i	1	35.00	35.00	\N	cmpyrlxmq0014jp04zv6o6vyo	cmpqqm4l9000c3xvojqoj1yyt
cmpyrs9ta001fjp04ef5brz2r	1	40.00	40.00	\N	cmpyrs9ta001djp048hjxvets	cmpqqm5gv000k3xvoc025780c
cmpyrwc2j0024l70482nanxnd	1	40.00	40.00	\N	cmpyrwc2j0022l704v5dgi4oj	cmpqqm3ot00063xvoeortkzib
cmpyrwtfj002cl704txhi01se	1	35.00	35.00	\N	cmpyrwtfj002al704z6n4zdkd	cmpqqm9eg001i3xvoqq2p0pcl
cmpyrycrd002ll7044m5sy2gf	1	35.00	35.00	\N	cmpyrycrc002jl704kz47w8tu	cmpqqm8iy001a3xvodugp204w
cmpyrycrd002pl704kqviv14h	1	35.00	35.00	\N	cmpyrycrc002jl704kz47w8tu	cmpqqm8iy001a3xvodugp204w
cmpys032k001njp04x92fkyqk	1	35.00	35.00	\N	cmpys032k001ljp04k6gxtkvp	cmpqqm8iy001a3xvodugp204w
cmpys7hzy001wjp048keyo24k	1	40.00	40.00	\N	cmpys7hzy001ujp0408t8disi	cmpqqmd4h002g3xvorpy8wab0
cmpysbcsg0024jp04hc5suy64	1	30.00	30.00	\N	cmpysbcsg0022jp04s2ddn7ae	cmpqqm6v9000w3xvoupr8eicc
cmpysnmna002cjp04cpb07hrs	1	35.00	35.00	\N	cmpysnmna002ajp04yccow010	cmpqqmc1300263xvodgeiz5il
cmpyteetj0002l1049xi0n15g	2	35.00	70.00	\N	cmpyteetj0000l1043odzmbbb	cmpqqm4l9000c3xvojqoj1yyt
cmpyu5ney0002le04afw1xzwz	1	40.00	40.00	\N	cmpyu5ney0000le049vr4ux0k	cmpqqm45100083xvoo43pm2fa
cmpz5e57p0003jl04s1rzwwi5	1	40.00	40.00	\N	cmpz5e57o0001jl04ndjnr903	cmpqqm45100083xvoo43pm2fa
cmpzn0ahk00033xmgbvxl857i	1	40.00	40.00	\N	cmpzmzky600013xmgkcxly408	cmpqqm3ot00063xvoeortkzib
cmpzn18t00004l804h8y1nmj1	2	35.00	70.00	\N	cmpzn18t00002l804go4cusjg	cmpqqm4l9000c3xvojqoj1yyt
cmpzn18t00009l8042glg7ahw	2	35.00	70.00	\N	cmpzn18t00002l804go4cusjg	cmpqqm4l9000c3xvojqoj1yyt
cmpzn18t0000el804f6cg2dll	1	35.00	35.00	\N	cmpzn18t00002l804go4cusjg	cmpqqm4l9000c3xvojqoj1yyt
cmpzn18t0000jl8049md5pw0i	1	35.00	35.00	\N	cmpzn18t00002l804go4cusjg	cmpqqm4l9000c3xvojqoj1yyt
cmpzn18t0000ol804z6acpnyq	1	40.00	40.00	\N	cmpzn18t00002l804go4cusjg	cmpqqm45100083xvoo43pm2fa
cmpzogna500063xomqt790dli	1	35.00	35.00	\N	cmpzog3ud00043xomnrqdbumq	cmpqqm4l9000c3xvojqoj1yyt
cmpzpakgw000d3xomnw5dg5jv	1	40.00	40.00	\N	cmpzpakgw000b3xomrs2wflil	cmpqqm6di000s3xvog0defnci
cmpzpklg2000l3xoml7t9c7j6	1	40.00	40.00	\N	cmpzpklg2000j3xom2mmu1dqy	cmpqqmd4h002g3xvorpy8wab0
cmpzpklg2000o3xom3lre4527	1	35.00	35.00	\N	cmpzpklg2000j3xom2mmu1dqy	cmpqqm4l9000c3xvojqoj1yyt
cmq01tb4k0002jl04se86clby	2	40.00	80.00	\N	cmq01tb4k0000jl04nnio0hsl	cmprepa050001jp04hcbe0l2v
cmq01tb4k0008jl04le832hsa	1	40.00	40.00	\N	cmq01tb4k0000jl04nnio0hsl	cmpqqm4t7000e3xvoazlktde5
cmq01tb4k000cjl04eymlhawf	1	40.00	40.00	\N	cmq01tb4k0000jl04nnio0hsl	cmpqqm3ot00063xvoeortkzib
cmq033frk0002jr040edvhwcr	1	35.00	35.00	\N	cmq033frk0000jr047ttf5sut	cmpqqmc1300263xvodgeiz5il
cmq038s7a0002jm04eabl8luc	1	45.00	45.00	\N	cmq038s7a0000jm04iq6s93xw	cmpqqmds2002m3xvosfq01877
cmq03iklh000bjm0419lofrsc	1	40.00	40.00	7:00	cmq03iklh0009jm04pktdyhzg	cmprepa050001jp04hcbe0l2v
cmq03mjdo0003js04owfd21iw	1	40.00	40.00	M 7:00	cmq03mjdo0001js046gquc8s7	cmpqqm45100083xvoo43pm2fa
cmq03wruo0009js04n1vjh2m7	1	40.00	40.00	\N	cmq03wruo0007js04bw9vmhxi	cmpqqm45100083xvoo43pm2fa
cmq03wruo000djs04na7ubbxe	1	40.00	40.00	\N	cmq03wruo0007js04bw9vmhxi	cmprepa050001jp04hcbe0l2v
cmq03wruo000ijs04yacn6ye3	1	40.00	40.00	\N	cmq03wruo0007js04bw9vmhxi	cmpqqmcwl002e3xvoh9uib930
cmq04h8b70003ju04k661z3un	1	35.00	35.00	\N	cmq04h8b70001ju04pccgl4gt	cmpqqm9eg001i3xvoqq2p0pcl
cmq05anbr0003l7046nw0svem	1	35.00	35.00	\N	cmq05anbr0001l704v6czg26f	cmpqqm4l9000c3xvojqoj1yyt
cmq05anbr0007l704r3g0dnt1	1	40.00	40.00	\N	cmq05anbr0001l704v6czg26f	cmpqqmcwl002e3xvoh9uib930
cmq05kjxf000bl70460etr54y	1	35.00	35.00	\N	cmq05ihph0009l704llnb4lzg	cmpqqm9eg001i3xvoqq2p0pcl
cmq05kjxf000fl7049dwo8pw3	1	35.00	35.00	\N	cmq05ihph0009l704llnb4lzg	cmpqqm9eg001i3xvoqq2p0pcl
cmq05vhyr000ol7049rfr2ukf	1	35.00	35.00	\N	cmq05vhyr000ml704lqvmx7bk	cmpqqm9eg001i3xvoqq2p0pcl
cmq05vhyr000sl704kw82ehl1	1	40.00	40.00	\N	cmq05vhyr000ml704lqvmx7bk	cmpqqm6di000s3xvog0defnci
cmq0607ve0004lb040pb6797v	1	40.00	40.00	\N	cmq0607ve0002lb04kfq5p2wx	cmpqqm45100083xvoo43pm2fa
cmq067se3000klb04bb7ex6qb	1	35.00	35.00	\N	cmq067dfz000ilb04tgxt3io3	cmpqqm8iy001a3xvodugp204w
cmq06hfea0003jo04wk1e0iir	1	35.00	35.00	\N	cmq06gy610001jo04h607cspg	cmpqqm4l9000c3xvojqoj1yyt
cmq06mcev000ejo042vqhbnej	1	35.00	35.00	\N	cmq06lryv000cjo04e58gsuuf	cmpqqm4l9000c3xvojqoj1yyt
cmq06py4l000ojo049bygdgb8	1	40.00	40.00	\N	cmq06nwi5000mjo04ikgif5bj	cmpqqm4t7000e3xvoazlktde5
cmq06py4l000rjo04hsp2ss79	1	35.00	35.00	\N	cmq06nwi5000mjo04ikgif5bj	cmpqqm4l9000c3xvojqoj1yyt
cmq06s9yk000zjo04solwdpuv	1	40.00	40.00	\N	cmq06rx27000xjo047rfbe81p	cmpqqm4t7000e3xvoazlktde5
cmq06vtv40002jr05acjd1pzu	1	40.00	40.00	\N	cmq06vtv40000jr05g818s0kz	cmpqqm3ot00063xvoeortkzib
cmq0749p7000bjr05xuww3fhe	1	35.00	35.00	\N	cmq073zum0009jr05vxdzhzv5	cmpqqm4l9000c3xvojqoj1yyt
cmq07bqty0015jo044aa5xsl7	1	35.00	35.00	\N	cmq07bqty0013jo04g8slvrk2	cmpqqm9eg001i3xvoqq2p0pcl
cmq07g3zc001gjo0447z3s8gn	1	35.00	35.00	\N	cmq07g3zc001ejo04te5eo8ju	cmpqqm4l9000c3xvojqoj1yyt
cmq07k7dh001qjo04fr101f7g	1	35.00	35.00	\N	cmq07k7dh001ojo0465kqkk6i	cmpqqm9eg001i3xvoqq2p0pcl
cmq07rlws0021jo04chsw6x89	1	40.00	40.00	\N	cmq07r6oe001zjo042d28rh4p	cmpqqm4t7000e3xvoazlktde5
cmq07x6jn0029jo04dnpdpuq2	1	35.00	35.00	\N	cmq07x6jn0027jo04lt807js4	cmpqqm4l9000c3xvojqoj1yyt
cmq0ba49w0003jr04ug7fpu21	1	35.00	35.00	\N	cmq0ba49w0001jr04jq89n3d4	cmpqqm4l9000c3xvojqoj1yyt
cmq0bailt0003jy04uz3ml9vz	1	40.00	40.00	\N	cmq0bailt0001jy04hajcs2nw	cmpqqmcwl002e3xvoh9uib930
cmq0by3100003jl0492lfevjm	2	35.00	70.00	\N	cmq0by3100001jl04ifb8prdv	cmpqqm4l9000c3xvojqoj1yyt
cmq0d7qmy0003ju04qnqf3skc	2	35.00	70.00	\N	cmq0d7qmy0001ju04pjqyfrj3	cmpqqm8iy001a3xvodugp204w
cmq0d7qmy0007ju046kgh1ryl	1	35.00	35.00	ฟรี	cmq0d7qmy0001ju04pjqyfrj3	cmpqqm8iy001a3xvodugp204w
cmq0h2ywf0003l704h88mc0ea	1	40.00	40.00	\N	cmq0h2ywf0001l704pg7taii4	cmpqqmcwl002e3xvoh9uib930
cmq0ha3nc0003ie04vd5n7i5l	1	35.00	35.00	\N	cmq0ha3nc0001ie04mwbcjwgr	cmpqqm8iy001a3xvodugp204w
cmq0hb97i000cie04on61e33p	1	35.00	35.00	\N	cmq0hb97i000aie04sfghxxh7	cmpqqm8iy001a3xvodugp204w
cmq0htz860003i304w75fqyh0	1	40.00	40.00	\N	cmq0htz850001i304o34f88yg	cmpqqm45100083xvoo43pm2fa
cmq0htz860007i3047uxtdz6k	1	40.00	40.00	\N	cmq0htz850001i304o34f88yg	cmpqqm3ot00063xvoeortkzib
cmq0i1ep70003jp04nbgpihet	1	40.00	40.00	\N	cmq0i1ep70001jp04elz0ssov	cmprepa050001jp04hcbe0l2v
cmq0igi48000fjp048n4rsvgi	1	35.00	35.00	ใส่แค่นม	cmq0igi48000djp04rdw0zwcc	cmpqqm9eg001i3xvoqq2p0pcl
cmq0jchhy0003lg04aflwbklr	1	35.00	35.00	\N	cmq0jchhy0001lg0410mvw1dc	cmpqqm4l9000c3xvojqoj1yyt
cmq114w100002jm04b25jpy9e	1	35.00	35.00	\N	cmq114w0z0000jm041r0x2r0z	cmpqqmc1300263xvodgeiz5il
cmq114w100006jm04r8wehcoh	2	35.00	70.00	\N	cmq114w0z0000jm041r0x2r0z	cmpqqm4l9000c3xvojqoj1yyt
cmq1hwe640002kv046r50d3fx	1	40.00	40.00	\N	cmq1hwe630000kv04klzp66w9	cmpqqm4cx000a3xvo6ij5ksrm
cmq1hwe640006kv043byvl4i3	1	40.00	40.00	\N	cmq1hwe630000kv04klzp66w9	cmpqqm81900163xvo5msxvp3a
cmq1irpg10002js048u5q1g9w	1	40.00	40.00	\N	cmq1irpg10000js04s9dnm156	cmpqqm4t7000e3xvoazlktde5
cmq1j7ldf0003ld0491swac80	1	40.00	40.00	\N	cmq1j7ldf0001ld0482lb9ucg	cmprepa050001jp04hcbe0l2v
cmq1j8ao1000bld04dk2xeyxz	1	35.00	35.00	\N	cmq1j8ao00009ld04wcuv55yt	cmpqqm4l9000c3xvojqoj1yyt
cmq1j8vfb000ild04wjgs155l	1	40.00	40.00	\N	cmq1j8vfb000gld0449sxklto	cmpqqm4cx000a3xvo6ij5ksrm
cmq1j9ert000old04zgs3qaai	1	40.00	40.00	\N	cmq1j9ers000mld04kspv7ko2	cmprepa050001jp04hcbe0l2v
cmq1j9uqy000zld048b7qzhao	1	40.00	40.00	\N	cmq1j9uqy000xld04w80mmdcz	cmprepa050001jp04hcbe0l2v
cmq1jnwq30002le04l0lubatj	1	40.00	40.00	\N	cmq1jnwq30000le04w68is4ju	cmpqqm4t7000e3xvoazlktde5
cmq1jso1p0002l4048eee2z5l	1	40.00	40.00	\N	cmq1jso1p0000l4047yyu3xai	cmpqqmaps001u3xvo1w0msnzw
cmq1kht9f000el404godth3gh	1	40.00	40.00	\N	cmq1kht9f000cl4043ymardtx	cmpqqm5gv000k3xvoc025780c
cmq1kht9f000hl404pq5ok58e	1	40.00	40.00	\N	cmq1kht9f000cl4043ymardtx	cmprepa050001jp04hcbe0l2v
cmq1kl0fw000sl404dumtswg0	1	35.00	35.00	\N	cmq1kl0fw000ql404r76egg3h	cmpqqm4l9000c3xvojqoj1yyt
cmq1kl0fx000wl404762kpa7r	1	40.00	40.00	\N	cmq1kl0fw000ql404r76egg3h	cmpqqm6di000s3xvog0defnci
cmq1kyktk0012l404orhdzrvd	1	35.00	35.00	\N	cmq1kyktk0010l40474k7ctj8	cmpqqm4l9000c3xvojqoj1yyt
cmq1lea480003l2047ogthylz	1	35.00	35.00	\N	cmq1lea470001l204i4ox1gsn	cmpqqm8iy001a3xvodugp204w
cmq1lq2qo001dl404noy9zfmf	1	35.00	35.00	\N	cmq1lq2qo001bl404bl5pkfn4	cmpqqm8iy001a3xvodugp204w
cmq1lvzx6000cl204mn0jadyp	1	40.00	40.00	\N	cmq1lvzx5000al2048bv968a6	cmpqqm45100083xvoo43pm2fa
cmq1m42o4000ll204mzf4iz20	1	40.00	40.00	\N	cmq1m42o4000jl204j4s39q5s	cmpqqm513000g3xvo0iex8rrm
cmq1m42o4000ol2045rzhw37v	1	35.00	35.00	\N	cmq1m42o4000jl204j4s39q5s	cmpqqm4l9000c3xvojqoj1yyt
cmq1m42o4000tl204uptwtuys	1	40.00	40.00	\N	cmq1m42o4000jl204j4s39q5s	cmpqqm6di000s3xvog0defnci
cmq1m59t8001yl404pf6jwhuy	1	35.00	35.00	\N	cmq1m59t8001wl404cp5rvrv4	cmpqqm4l9000c3xvojqoj1yyt
cmq1misa60011l204xya6tdb3	1	40.00	40.00	\N	cmq1misa5000zl2040ytnni9b	cmpqqm45100083xvoo43pm2fa
cmq1mj2du0018l204tiak6ije	1	40.00	40.00	\N	cmq1mj2du0016l2045jfr7hzq	cmpqqmcwl002e3xvoh9uib930
cmq1mn2u8001cl204h9czu6st	1	40.00	40.00	\N	cmq1mn2u8001al204x09owya7	cmpqqm513000g3xvo0iex8rrm
cmq1mpf8r0026l404dygmxg3d	1	35.00	35.00	\N	cmq1mpf8r0024l404a7y95h31	cmpqqm9eg001i3xvoqq2p0pcl
cmq1mpf8r002al404fgyykxy3	1	40.00	40.00	\N	cmq1mpf8r0024l404a7y95h31	cmpqqm81900163xvo5msxvp3a
cmq1mui5z001kl204kxqs86m4	1	35.00	35.00	\N	cmq1mui5y001il204llon795b	cmpqqm4l9000c3xvojqoj1yyt
cmq1mui5z001ol204mtzuh9bf	1	35.00	35.00	\N	cmq1mui5y001il204llon795b	cmpqqm4l9000c3xvojqoj1yyt
cmq1mv31j001vl204bpqko3af	1	35.00	35.00	\N	cmq1mv31j001tl204cjjqo7x9	cmpqqm9eg001i3xvoqq2p0pcl
cmq1n0lod0024l2045ubivcg3	1	40.00	40.00	\N	cmq1n0lod0022l2049b7xbprz	cmpqqm4cx000a3xvo6ij5ksrm
cmq1n4m220005jo04qcqubt8n	1	40.00	40.00	\N	cmq1n4m220003jo04vsbqigyr	cmprepa050001jp04hcbe0l2v
cmq1n86930003jq040qdpx5ma	1	40.00	40.00	\N	cmq1n86930001jq043dalfd09	cmprepa050001jp04hcbe0l2v
cmq1nwp670002jo04lrajiuv1	1	40.00	40.00	\N	cmq1nwp660000jo04uxfhdmgv	cmpqqm45100083xvoo43pm2fa
cmq1nwp670006jo04rdktph98	1	40.00	40.00	\N	cmq1nwp660000jo04uxfhdmgv	cmpqqm5gv000k3xvoc025780c
cmq1nwp670009jo046e6v12a1	1	35.00	35.00	\N	cmq1nwp660000jo04uxfhdmgv	cmpqqm8iy001a3xvodugp204w
cmq3wooeu0003l804100i2v6a	1	35.00	35.00	\N	cmq3wooeu0001l804kuzr342f	cmpqqm4l9000c3xvojqoj1yyt
cmq3wooeu0007l804va4l86iw	1	40.00	40.00	\N	cmq3wooeu0001l804kuzr342f	cmpqqmd4h002g3xvorpy8wab0
cmq3wpg2n0003l204rwedz68r	1	35.00	35.00	\N	cmq3wpg2n0001l204du6dqifh	cmpqqm9eg001i3xvoqq2p0pcl
cmq3wy7o10009l204tbwoyw1b	1	40.00	40.00	\N	cmq3wy7o10007l2041cmko7n2	cmpqqm3ot00063xvoeortkzib
cmq3wyfme000fl204vgxg58gr	1	40.00	40.00	\N	cmq3wyfme000dl204cw9ubkay	cmpqqm81900163xvo5msxvp3a
cmq3x00a70003kz04wc2xltdf	1	40.00	40.00	\N	cmq3wznuq0001kz04nurdd92v	cmpqqm45100083xvoo43pm2fa
cmq3x337z000bkz043ckwi52i	1	35.00	35.00	ขอก่อน 4 ทุ่ม	cmq3x337z0009kz04qtt5vqh5	cmpqqm4l9000c3xvojqoj1yyt
cmq3xp7o0000nl204f5li6dlx	1	40.00	40.00	\N	cmq3xp7o0000ll2044708f1tg	cmpqqm3ot00063xvoeortkzib
cmq3yelhs0003ky04a3kx1cwa	1	40.00	40.00	\N	cmq3yelhs0001ky04x9894lxr	cmpqqm65m000q3xvow1n8n4d2
cmq3yf3qi0003l704mb7w4d3q	1	40.00	40.00	\N	cmq3yf3qi0001l7048ncz3zgv	cmpqqm45100083xvoo43pm2fa
cmq3yqbr70002jl04s8zb468p	1	40.00	40.00	\N	cmq3yqbr70000jl04h71kd5ar	cmpqqm6di000s3xvog0defnci
cmq3yvmtu0008l704avz79gxz	1	40.00	40.00	\N	cmq3yvmtt0006l7040e6z8zvt	cmpqqm6di000s3xvog0defnci
cmq4c2r220002jr041lx860rn	2	35.00	70.00	\N	cmq4c2r220000jr04to75lb55	cmpqqm4l9000c3xvojqoj1yyt
cmq4c5k7f0002lh0435xa796h	1	35.00	35.00	\N	cmq4c5k7f0000lh04ajcehru4	cmpqqm4l9000c3xvojqoj1yyt
cmq4cnb2x0002k00468mv7x2q	1	35.00	35.00	\N	cmq4cnb2x0000k004gb57z98x	cmpqqm9eg001i3xvoqq2p0pcl
cmq4cnb2x0007k004mbfpgbkw	1	35.00	35.00	\N	cmq4cnb2x0000k004gb57z98x	cmpqqmc1300263xvodgeiz5il
cmq4dqtc40005jp04knhtxrfh	1	40.00	40.00	\N	cmq4dqtc40003jp04g9zzivy3	cmprepa050001jp04hcbe0l2v
cmq4dxpsc0002js04241pwb11	1	35.00	35.00	\N	cmq4dxpsb0000js046idgljfp	cmpqqm4l9000c3xvojqoj1yyt
cmq4e0y6y0004jr04i7733juy	1	40.00	40.00	\N	cmq4e0y6y0002jr0467ohj7al	cmpqqm4t7000e3xvoazlktde5
cmq4e0y6y0008jr04r3q9zeyk	1	40.00	40.00	\N	cmq4e0y6y0002jr0467ohj7al	cmpqqm4t7000e3xvoazlktde5
cmq4e0y6y000djr04m1b9wvgt	1	35.00	35.00	\N	cmq4e0y6y0002jr0467ohj7al	cmpqqm9eg001i3xvoqq2p0pcl
cmq4e0ybg000mjr04yiliob05	1	40.00	40.00	\N	cmq4e00xp0001jr04f35am9hd	cmpqqm45100083xvoo43pm2fa
cmq4edy7z000bjy04inbgnt8y	1	40.00	40.00	\N	cmq4edy7y0009jy04i0t03bky	cmpqqm3ot00063xvoeortkzib
cmq4fo7i90003l804h5u17v07	1	35.00	35.00	\N	cmq4fo7i90001l8044c2puwxv	cmpqqm4l9000c3xvojqoj1yyt
cmq4fo7i90007l804zn9i02zr	1	40.00	40.00	\N	cmq4fo7i90001l8044c2puwxv	cmpqqmd4h002g3xvorpy8wab0
cmq4fw1q50007l104rarln1yw	1	35.00	35.00	\N	cmq4fw1q50005l104068el22r	cmpqqm4l9000c3xvojqoj1yyt
cmq4fw1q6000bl104kifyyj24	1	40.00	40.00	\N	cmq4fw1q50005l104068el22r	cmpqqm45100083xvoo43pm2fa
cmq4fy94z000fl8049i5pz6kt	1	40.00	40.00	\N	cmq4fy94z000dl804mlz2mjya	cmpqqm81900163xvo5msxvp3a
cmq4fy94z000il8042szv9ib4	1	15.00	15.00	\N	cmq4fy94z000dl804mlz2mjya	cmpzoaia200023xomsj6ohdvb
cmq4fzln3000nl8043pt06bxw	1	35.00	35.00	\N	cmq4fzln2000ll804nx62g2xm	cmpqqm4l9000c3xvojqoj1yyt
cmq4gbnu10003l8049xtjiun7	1	35.00	35.00	\N	cmq4gbnu10001l804r9xduqb6	cmpqqm8iy001a3xvodugp204w
cmq4gf3ua000al804lgx6z1zs	1	35.00	35.00	\N	cmq4gf3u90008l804xk3zzlrl	cmpqqm8iy001a3xvodugp204w
cmq4ghtop000ll804rbfmmpfp	1	35.00	35.00	\N	cmq4ghtop000jl804muis7cqj	cmpqqm8iy001a3xvodugp204w
cmq4gxnwk000jjr04povappd2	1	35.00	35.00	น้ำ50%	cmq4gxnwk000hjr04o12yoq3c	cmpqqm4l9000c3xvojqoj1yyt
cmq4h76r40003jm04r83z389q	1	35.00	35.00	\N	cmq4h76r40001jm04oo5oc8e8	cmpqqm9eg001i3xvoqq2p0pcl
cmq4h76r40007jm046eplsmaa	1	35.00	35.00	\N	cmq4h76r40001jm04oo5oc8e8	cmpqqm96k001g3xvoeknbidid
cmq4h8bqe000sjr04lhcmzeft	1	35.00	35.00	หวาน 25%	cmq4h8bqd000qjr04ew4yaae6	cmpqqm9eg001i3xvoqq2p0pcl
cmq4h8s2l000zjr04wmpq2lft	1	35.00	35.00	ไม่เอาน้ำแข็ง	cmq4h8s2l000xjr04g1of1a1o	cmpqqm4l9000c3xvojqoj1yyt
cmq4hafzg000djm04sume1n01	1	40.00	40.00	\N	cmq4hafzg000bjm04jajidhn8	cmpqqm4t7000e3xvoazlktde5
cmq4higvo0016jr04qnn5723g	1	35.00	35.00	\N	cmq4higvo0014jr04o4iqz9ly	cmpqqm9eg001i3xvoqq2p0pcl
cmq4hkci6001ejr04rc03pip9	1	35.00	35.00	\N	cmq4hkci6001cjr04f2h1z5bm	cmpqqm4l9000c3xvojqoj1yyt
cmq4hkci6001ijr04hpc3j904	1	40.00	40.00	\N	cmq4hkci6001cjr04f2h1z5bm	cmpqqmcwl002e3xvoh9uib930
cmq4hkzmq000jjm042ev3t90t	1	40.00	40.00	\N	cmq4hkzmq000hjm04614meh8y	cmpqqm45100083xvoo43pm2fa
cmq4hsyic000rjm04eqa8r2ec	1	35.00	35.00	\N	cmq4hsyic000pjm04dm1d7iit	cmpqqm4l9000c3xvojqoj1yyt
cmq4hsyic000vjm04vkk3i120	1	40.00	40.00	\N	cmq4hsyic000pjm04dm1d7iit	cmpqqm4t7000e3xvoazlktde5
cmq4icdtm0003ju04a3898cli	1	40.00	40.00	\N	cmq4icdtm0001ju0434ur99pq	cmpqqm5gv000k3xvoc025780c
cmq4kw2vb0003ju040caaa6ih	1	40.00	40.00	\N	cmq4kw2vb0001ju04vlhvrfda	cmprepa050001jp04hcbe0l2v
cmq4le8uj0003kz04f7jl8spu	1	35.00	35.00	\N	cmq4le8uj0001kz04j4b5prfc	cmpqqm9eg001i3xvoqq2p0pcl
cmq4ltlyo0003lh04o63tmo9l	2	35.00	70.00	\N	cmq4ltlyo0001lh04zrbmpbvc	cmpqqm4l9000c3xvojqoj1yyt
cmq4mqvuc0003l204ucaa8bbh	1	35.00	35.00	\N	cmq4mqvuc0001l204btmo78mb	cmpqqm4l9000c3xvojqoj1yyt
cmq4qav2q0003ju042qbhm3jn	1	40.00	40.00	\N	cmq4qav2q0001ju04oo3ddg46	cmprepa050001jp04hcbe0l2v
cmq4qqx500003jy047iejgd4l	1	35.00	35.00	\N	cmq4qqx4z0001jy04971t6ffv	cmpqqm9eg001i3xvoqq2p0pcl
cmq4qqx500007jy04lt8buk1g	1	40.00	40.00	\N	cmq4qqx4z0001jy04971t6ffv	cmpqqm81900163xvo5msxvp3a
cmq4qrh3i000ejy04oppfw6ng	1	40.00	40.00	\N	cmq4qrh3i000cjy04rkdrszaa	cmprepa050001jp04hcbe0l2v
cmq4qrh3i000ijy04mahuzlue	1	40.00	40.00	\N	cmq4qrh3i000cjy04rkdrszaa	cmprepa050001jp04hcbe0l2v
cmq4qvttb0003js04u54wr2zb	1	35.00	35.00	\N	cmq4qvttb0001js04s9aqx1c0	cmpqqm8iy001a3xvodugp204w
cmq4qwk6s0009js04uqxv63fb	1	35.00	35.00	\N	cmq4qwk6s0007js04xliroekn	cmpqqmhie003i3xvoybyvebt7
cmq4rhdk50003jp04slcq55tl	1	15.00	15.00	\N	cmq4rhdk50001jp04ti7p9qtu	cmpzoaia200023xomsj6ohdvb
cmq4ri5830003l204bwn6a4h1	1	40.00	40.00	\N	cmq4ri5820001l204oupvmwdh	cmpqqm4t7000e3xvoazlktde5
cmq4ruj2g0003ju041alk7vxd	1	40.00	40.00	\N	cmq4ruj2g0001ju04vpivgkfz	cmpqqmcgu002a3xvog83kbby5
cmq4szpi50003jl04eymfmwae	1	35.00	35.00	\N	cmq4szpi50001jl04lyf1l0by	cmpqqm4l9000c3xvojqoj1yyt
cmq5s9aoe0002ju04dywyj3in	1	35.00	35.00	\N	cmq5s9aoe0000ju04scxlmgnf	cmpqqmc1300263xvodgeiz5il
cmq5s9aoe0006ju041t99m87r	1	35.00	35.00	\N	cmq5s9aoe0000ju04scxlmgnf	cmpqqm4l9000c3xvojqoj1yyt
cmq5t5rru0002l50425zxp0g8	2	35.00	70.00	\N	cmq5t5rru0000l5042bio6uw7	cmpqqm4l9000c3xvojqoj1yyt
cmq5t5rru0006l504ywqlpvrj	1	35.00	35.00	\N	cmq5t5rru0000l5042bio6uw7	cmpqqm4l9000c3xvojqoj1yyt
cmq5tg4i2000fl50486kzuq5k	1	35.00	35.00	\N	cmq5tg4i1000dl5049cs206m7	cmpqqm4l9000c3xvojqoj1yyt
cmq5tjcm10003jr04x7smdqtt	1	40.00	40.00	พี่m	cmq5tjcm10001jr04vqmxbfqh	cmpqqm4cx000a3xvo6ij5ksrm
cmq5tkrk30002jm04eqypkwr9	2	35.00	70.00	\N	cmq5tkrk30000jm04v7eptx56	cmpqqm9eg001i3xvoqq2p0pcl
cmq5tq5lu0002l8040vhduzau	1	40.00	40.00	\N	cmq5tq5lt0000l804kevidzil	cmpqqm6di000s3xvog0defnci
cmq5tq5lu0005l8045fk6st1a	1	35.00	35.00	\N	cmq5tq5lt0000l804kevidzil	cmpqqmc1300263xvodgeiz5il
cmq5tq5lu0008l804eb0dszyz	1	40.00	40.00	\N	cmq5tq5lt0000l804kevidzil	cmpqqm45100083xvoo43pm2fa
cmq5uph800004kz04xvsywiz7	1	40.00	40.00	\N	cmq5uph800002kz04l96olp0d	cmpqqm81900163xvo5msxvp3a
cmq5uph800009kz043ucc7o2e	1	35.00	35.00	\N	cmq5uph800002kz04l96olp0d	cmpqqm9eg001i3xvoqq2p0pcl
cmq5utfg00003ks0478qhx41s	1	35.00	35.00	\N	cmq5utffz0001ks04exp6ucot	cmpqqm4l9000c3xvojqoj1yyt
cmq5utfg00007ks04dxzhswq6	1	45.00	45.00	\N	cmq5utffz0001ks04exp6ucot	cmpqqmdk7002k3xvoo1d970sf
cmq5vfhdn0002le04h3kukmyo	1	35.00	35.00	\N	cmq5vfhdn0000le04nau7i8rb	cmpqqm4l9000c3xvojqoj1yyt
cmq5vfvir000cle04j2bhhjtn	1	35.00	35.00	\N	cmq5vfvir000ale048otfzs36	cmpqqm4l9000c3xvojqoj1yyt
cmq5vh6uz0002jm04v2fue43i	1	40.00	40.00	\N	cmq5vh6uy0000jm0420zqs4qq	cmpqqm3ot00063xvoeortkzib
cmq5vh6uz0005jm04yepo2pir	1	40.00	40.00	\N	cmq5vh6uy0000jm0420zqs4qq	cmprepa050001jp04hcbe0l2v
cmq5vk5gz000fjm04qpftg6uz	1	35.00	35.00	\N	cmq5vk5gz000djm04olj3rzqp	cmpqqm4l9000c3xvojqoj1yyt
cmq5vo5no0003jr04o3i90sw3	1	40.00	40.00	\N	cmq5vo5no0001jr04zvj1gkgc	cmpqqmd4h002g3xvorpy8wab0
cmq5vs9zv0003kv04sfsbf89q	1	35.00	35.00	\N	cmq5vs9zv0001kv042knvlzqz	cmpqqm8iy001a3xvodugp204w
cmq5vzgkt000ckv04qtikgaml	1	35.00	35.00	\N	cmq5vzgks000akv04rurmz5c8	cmpqqm4l9000c3xvojqoj1yyt
cmq5wlg1i0004jy04v7l2ktub	1	40.00	40.00	ใส่แก้วเอามาเอง	cmq5wlg1i0002jy04yvyhdr45	cmpqqm45100083xvoo43pm2fa
cmq5wlg1i0008jy04gp3g5vtr	1	35.00	35.00	\N	cmq5wlg1i0002jy04yvyhdr45	cmpqqm4l9000c3xvojqoj1yyt
cmq5wlg1i000djy04qq5btow2	1	40.00	40.00	\N	cmq5wlg1i0002jy04yvyhdr45	cmpqqm4t7000e3xvoazlktde5
cmq5wnwgd000mjy04x5etr6rt	1	40.00	40.00	\N	cmq5wnwgd000kjy04a6rzb1ug	cmpqqm58z000i3xvo7kzkzfoh
cmq5wnwgd000qjy047k2q0avv	1	35.00	35.00	\N	cmq5wnwgd000kjy04a6rzb1ug	cmpqqma9x001q3xvo0d6239vc
cmq5wp4nu000dl804j9p3czd7	1	35.00	35.00	ไม่เอาน้ำแข็ง	cmq5wp4nu000bl804wnl9yh39	cmpqqm4l9000c3xvojqoj1yyt
cmq5wswte000ml80492rostnf	1	35.00	35.00	\N	cmq5wswte000kl80438byq14d	cmpqqm4l9000c3xvojqoj1yyt
cmq5x06rn000xjy04q2ji7enc	1	35.00	35.00	\N	cmq5x06rn000vjy0446row018	cmpqqm9eg001i3xvoqq2p0pcl
cmq5x84b10015jy04rkll50z3	1	40.00	40.00	\N	cmq5x7s000013jy04wp6i0z7g	cmpqqm4t7000e3xvoazlktde5
cmq5x8ymb0003jo04al7j74p9	1	35.00	35.00	\N	cmq5x8ymb0001jo04ogbf5o5l	cmpqqm4l9000c3xvojqoj1yyt
cmq5x9gq0000ajo04fxvw9pll	1	35.00	35.00	\N	cmq5x9gq00008jo048nn42gga	cmpqqm4l9000c3xvojqoj1yyt
cmq5xnr2n001gjy045sdb9em1	1	30.00	30.00	\N	cmq5xnr2n001ejy04lmlsjpn7	cmpqqm6v9000w3xvoupr8eicc
cmq5zubfh0003ld043qkmr5u5	1	40.00	40.00	\N	cmq5zubfg0001ld04q02sryj9	cmprepa050001jp04hcbe0l2v
cmq5zwq1u0003l404y9zbovfi	1	40.00	40.00	\N	cmq5zwq1u0001l4046acqex6c	cmprepa050001jp04hcbe0l2v
cmq5zyjnd000cl404nle2iwey	1	40.00	40.00	\N	cmq5zyjnd000al404ywy1lt9w	cmpqqm3ot00063xvoeortkzib
cmq60oagn0003jl04ubhholt2	1	40.00	40.00	\N	cmq60oagn0001jl04n10m83xh	cmprepa050001jp04hcbe0l2v
cmq60ukbb0003jp04lg0nbdj4	1	35.00	35.00	\N	cmq60ukbb0001jp040a2njvi2	cmpqqm4l9000c3xvojqoj1yyt
cmq60ukbb0007jp04mmwz7z5p	1	40.00	40.00	\N	cmq60ukbb0001jp040a2njvi2	cmpqqm3ot00063xvoeortkzib
cmq60ukbb000ajp04elslik63	1	40.00	40.00	\N	cmq60ukbb0001jp040a2njvi2	cmprepa050001jp04hcbe0l2v
cmq610y3s0003js04p3kapf1u	1	40.00	40.00	\N	cmq610y3r0001js04tu34r85g	cmpqqm45100083xvoo43pm2fa
cmq610y3s0007js04k3fc7gb5	1	35.00	35.00	\N	cmq610y3r0001js04tu34r85g	cmpqqm4l9000c3xvojqoj1yyt
cmq618yr40003jv047tba81t0	1	35.00	35.00	\N	cmq618yr40001jv04f6hefwyp	cmpqqm4l9000c3xvojqoj1yyt
cmq61cze5000cjv04giujxz7o	1	40.00	40.00	\N	cmq61cze5000ajv04bwsz3vgl	cmprepa050001jp04hcbe0l2v
cmq61cze5000gjv04whcpjd3c	1	35.00	35.00	\N	cmq61cze5000ajv04bwsz3vgl	cmpqqm8iy001a3xvodugp204w
cmq61cze5000kjv0436623dqc	1	35.00	35.00	\N	cmq61cze5000ajv04bwsz3vgl	cmpqqm9eg001i3xvoqq2p0pcl
cmq61kwhi000ljp048q7uw3dw	1	40.00	40.00	\N	cmq61kwhi000jjp04savbjmxm	cmprepa050001jp04hcbe0l2v
cmq61kwhi000pjp04rlms11rd	1	40.00	40.00	\N	cmq61kwhi000jjp04savbjmxm	cmpqqm81900163xvo5msxvp3a
cmq61kwhi000tjp04zibs1q0c	1	40.00	40.00	\N	cmq61kwhi000jjp04savbjmxm	cmpqqm45100083xvoo43pm2fa
cmq62bn1c0003l704dztsaol0	1	40.00	40.00	\N	cmq62bn1c0001l704jul62js8	cmpqqm4t7000e3xvoazlktde5
cmq62bn1c0007l704lcwehw9d	1	40.00	40.00	\N	cmq62bn1c0001l704jul62js8	cmpqqmd4h002g3xvorpy8wab0
cmq62drkr0003ji0426w9sb64	1	35.00	35.00	\N	cmq62drkr0001ji041l91k2p8	cmpqqma9x001q3xvo0d6239vc
cmq63eerb0003l404feljd7hu	1	35.00	35.00	\N	cmq63eera0001l404hii1ktqi	cmpqqm4l9000c3xvojqoj1yyt
cmq63em2m000al404o55n3xai	1	35.00	35.00	\N	cmq63em2m0008l4045ifhngap	cmpqqmc1300263xvodgeiz5il
cmq67fyce0003k0040g40v2zz	1	40.00	40.00	\N	cmq67fyce0001k004zyndmnxk	cmpqqm4t7000e3xvoazlktde5
cmq67fyce0007k004s49ry856	3	35.00	105.00	\N	cmq67fyce0001k004zyndmnxk	cmpqqm8iy001a3xvodugp204w
cmq77yrth0002ju04mrya04b6	1	40.00	40.00	\N	cmq77yrtg0000ju04tahgagvy	cmpqqm81900163xvo5msxvp3a
cmq77yrth0007ju040kzbl5kf	1	35.00	35.00	\N	cmq77yrtg0000ju04tahgagvy	cmpqqmc1300263xvodgeiz5il
cmq77yrth000aju04fwo2xmql	1	35.00	35.00	\N	cmq77yrtg0000ju04tahgagvy	cmpqqm4l9000c3xvojqoj1yyt
cmq78vwei0003js04bcy0v0g8	1	40.00	40.00	\N	cmq78vwei0001js04n826opn2	cmprepa050001jp04hcbe0l2v
cmq78wz8v0003l5042gep21aw	1	35.00	35.00	\N	cmq78wz8v0001l504of56r07u	cmpqqm9eg001i3xvoqq2p0pcl
cmq78x7iv000al504f4ep8u0f	1	40.00	40.00	\N	cmq78x7iv0008l5044n7pamfj	cmpqqm81900163xvo5msxvp3a
cmq78xijx000hl504efpb2jo6	1	35.00	35.00	\N	cmq78xijx000fl504gy8sg7lf	cmpqqm9eg001i3xvoqq2p0pcl
cmq78xvav000ol5048w74hri4	1	50.00	50.00	\N	cmq78xvav000ml5044mi07d75	cmpqqm3ot00063xvoeortkzib
cmq793pjd0003jp046cyq4l04	1	40.00	40.00	โมส	cmq793pjd0001jp04levxg68p	cmpqqm3ot00063xvoeortkzib
cmq7a4ak40002jv04spsl0b4v	1	35.00	35.00	\N	cmq7a4ak30000jv04bxzlkgs2	cmpqqm4l9000c3xvojqoj1yyt
cmq7a4ak40006jv045uhhq5dw	1	40.00	40.00	\N	cmq7a4ak30000jv04bxzlkgs2	cmpqqmd4h002g3xvorpy8wab0
cmq7a7d9t0003l204omhlv6pa	1	35.00	35.00	\N	cmq7a7d9t0001l204l2kj4957	cmpqqm4l9000c3xvojqoj1yyt
cmq7asad80006jx04xaca4mc8	1	40.00	40.00	\N	cmq7asad70004jx04a8njafgl	cmprepa050001jp04hcbe0l2v
cmq7ayit00002l504whr3k1ge	1	35.00	35.00	\N	cmq7ayit00000l504ki72wer9	cmpqqm9eg001i3xvoqq2p0pcl
cmq7b7csl000gjx04nkkcbze5	1	40.00	40.00	\N	cmq7b7csl000ejx04lnfihuwh	cmpqqm81900163xvo5msxvp3a
cmq7b9zbk000cl504ybo2rtqc	1	35.00	35.00	\N	cmq7b9zbk000al504o0id4j6t	cmpqqm8iy001a3xvodugp204w
cmq7bagqh000jl504z24qkw1g	1	40.00	40.00	\N	cmq7bagqh000hl5047ml1sw8i	cmpqqm4cx000a3xvo6ij5ksrm
cmq7bcr6l0006l404v128gasu	1	40.00	40.00	\N	cmq7bcr6l0004l4046p8u67e1	cmpqqm81900163xvo5msxvp3a
cmq7bhu83000ql504fstl3xmh	1	35.00	35.00	\N	cmq7bhu83000ol5047kuqj32x	cmpqqm4l9000c3xvojqoj1yyt
cmq7bokil0011l504n9f1oaoh	1	45.00	45.00	\N	cmq7bokil000zl504zhgbtz8c	cmpqqmdk7002k3xvoo1d970sf
cmq7bve060019l5043hncmjys	1	35.00	35.00	\N	cmq7bve060017l504zo89izjv	cmpqqm4l9000c3xvojqoj1yyt
cmq7c3rsp000ojx04kj1m694k	1	40.00	40.00	\N	cmq7c3rsp000mjx04hv5wi089	cmpqqm45100083xvoo43pm2fa
cmq7c4qve001gl504833yzdgc	1	35.00	35.00	ไม่เอาน้ำแข็ง	cmq7c4qve001el504quna1zfp	cmpqqm4l9000c3xvojqoj1yyt
cmq7c6ksj001pl504df2skcws	1	40.00	40.00	\N	cmq7c6ksj001nl504w7mewddo	cmpqqmd4h002g3xvorpy8wab0
cmq7c6ksj001sl504qabjvooi	1	35.00	35.00	\N	cmq7c6ksj001nl504w7mewddo	cmpqqm4l9000c3xvojqoj1yyt
cmq7c6ksj001xl504t0f1b23t	1	40.00	40.00	\N	cmq7c6ksj001nl504w7mewddo	cmpqqmcwl002e3xvoh9uib930
cmq7cb7aq000wjx04w52xj1tn	1	40.00	40.00	\N	cmq7cb7aq000ujx04vwpsbm06	cmpqqm4t7000e3xvoazlktde5
cmq7ceuj00013jx044zvpur2b	1	40.00	40.00	\N	cmq7ceuj00011jx04fb5vqojj	cmpqqmd4h002g3xvorpy8wab0
cmq7csl4l001bjx04ueavg9rs	1	40.00	40.00	\N	cmq7csl4l0019jx044amxrush	cmpqqm5gv000k3xvoc025780c
cmq7csl4l001fjx040zju67f8	1	35.00	35.00	\N	cmq7csl4l0019jx044amxrush	cmpqqm8iy001a3xvodugp204w
cmqzu62160005jn04rpemyusv	1	35.00	35.00	\N	cmqzu62160000jn04v7d8urqd	cmpqqm96k001g3xvoeknbidid
cmqzu62160008jn04mfvijhi9	1	35.00	35.00	\N	cmqzu62160000jn04v7d8urqd	cmpqqmhah003g3xvocqzdccbj
cmqzu6216000bjn04i8c7tzop	1	40.00	40.00	\N	cmqzu62160000jn04v7d8urqd	cmpqqm4t7000e3xvoazlktde5
cmqzwlqo50002l204spgexr18	1	35.00	35.00	\N	cmqzwlqo40000l2046fbrbgqb	cmpqqm4l9000c3xvojqoj1yyt
cmqzwty7s000jl204m9spy4qj	1	40.00	40.00	\N	cmqzwty7s000hl204nk415prf	cmpqqm4t7000e3xvoazlktde5
cmqzwuqoe000tl204fj0agg63	2	35.00	70.00	\N	cmqzwuqoe000rl204d3zt5ock	cmpqqm4l9000c3xvojqoj1yyt
cmqzwuvzo0010l204zln9oth9	1	40.00	40.00	\N	cmqzwuvzo000yl204m20n58yv	cmpqqm3ot00063xvoeortkzib
cmqzx16gl001cl204s3j5yyzv	1	40.00	40.00	\N	cmqzx16gl001al204t63ek0jx	cmpqqm513000g3xvo0iex8rrm
cmqzx77x10007jv043w31spda	1	40.00	40.00	\N	cmqzx77x10005jv04241e0lrn	cmpqqm3ot00063xvoeortkzib
cmqzxbcx6001pl2041hd18w58	1	35.00	35.00	\N	cmqzxbcx6001nl204abmhwnti	cmpqqm4l9000c3xvojqoj1yyt
cmqzxgkla001yl204b4ewpl0a	1	35.00	35.00	\N	cmqzxgkla001wl204k7ppbu3t	cmpqqm4l9000c3xvojqoj1yyt
cmqzxim3y0027l2043jrf22q6	1	30.00	30.00	\N	cmqzxim3x0025l204cqx361h5	cmpqqm8qt001c3xvom39q1hsv
cmqzxk1dy000hjv0416jp1qcv	1	40.00	40.00	\N	cmqzxk1dy000fjv044mvfouyo	cmpqqm4t7000e3xvoazlktde5
cmq7cg2d50025l504ib0w9rsf	1	35.00	35.00	\N	cmq7cg2d50023l504ap9eyhtw	cmpqqm8yp001e3xvolh59nlvx
cmq7cpoul002bl504w09a8vi3	1	35.00	35.00	\N	cmq7cpoul0029l504cspijlew	cmpqqm9eg001i3xvoqq2p0pcl
cmq7cy4he002nl504bm0mhmxf	1	40.00	40.00	\N	cmq7cy4hd002ll504gkgj43x7	cmpqqm4t7000e3xvoazlktde5
cmq7f4sgv0003l5045xxgweib	1	35.00	35.00	\N	cmq7f4sgv0001l504ta16mwbs	cmpqqma23001o3xvoooy0q9ws
cmq7f4sgv0007l5046jcjtszb	1	40.00	40.00	\N	cmq7f4sgv0001l504ta16mwbs	cmpqqmd4h002g3xvorpy8wab0
cmq7faodz0003i904eb63ts4c	1	40.00	40.00	\N	cmq7faodz0001i904csl3bg2w	cmprepa050001jp04hcbe0l2v
cmq7faodz0007i904c1suz75v	1	40.00	40.00	\N	cmq7faodz0001i904csl3bg2w	cmpqqm3ot00063xvoeortkzib
cmq7gifyr0003l404qyudbthh	1	35.00	35.00	\N	cmq7gifyr0001l404dwdralsk	cmpqqm4l9000c3xvojqoj1yyt
cmq7gisgv000cl404nj9i2ox1	1	35.00	35.00	\N	cmq7gisgv000al404qfkmrjx3	cmpqqm4l9000c3xvojqoj1yyt
cmq7gx6lk000ll40470n69071	1	35.00	35.00	\N	cmq7gx6lk000jl4046rd8gzaw	cmpqqm4l9000c3xvojqoj1yyt
cmq7gx6lk000pl4045wgpa4ik	1	40.00	40.00	กลาง	cmq7gx6lk000jl4046rd8gzaw	cmpqqm3ot00063xvoeortkzib
cmq7gxwrn000vl404rpiyxurv	1	40.00	40.00	\N	cmq7gxwrn000tl404ga1qa4j9	cmpqqm81900163xvo5msxvp3a
cmq7gxwrn000zl404akegm5qf	1	35.00	35.00	\N	cmq7gxwrn000tl404ga1qa4j9	cmpqqm8iy001a3xvodugp204w
cmq7h2whm0003lb047hyojs3r	1	35.00	35.00	\N	cmq7h2whm0001lb04t5dtediw	cmpqqm4l9000c3xvojqoj1yyt
cmq7h8xl8000elb04vk47ume7	1	35.00	35.00	\N	cmq7h8xl7000clb046p73sm3v	cmpqqm4l9000c3xvojqoj1yyt
cmq7hau7h0016l404apr8yy7r	1	35.00	35.00	\N	cmq7hau7h0014l404wy9fcjc2	cmpqqm8iy001a3xvodugp204w
cmq7hzn720003jx042g2msm3p	1	45.00	45.00	\N	cmq7hzn710001jx04ckv06qyg	cmpqqm89400183xvo7b2i3mk9
cmq7hzn720007jx04vh9tr06n	1	40.00	40.00	\N	cmq7hzn710001jx04ckv06qyg	cmprepa050001jp04hcbe0l2v
cmq7janpb000d3xjt314q8i2w	1	50.00	50.00	ทดสอบโปรแกรม 2	cmq7j0f3e00013xjtcb3vgfda	cmpqqm45100083xvoo43pm2fa
cmq7k1ws10003jv04qi430w7f	1	30.00	30.00	\N	cmq7k1ws10001jv04torizare	cmpqqm7c800103xvol1ftobf3
cmq7lhpbt0003ie041qvyepmi	1	40.00	40.00	\N	cmq7lhpbt0001ie04bpctbj88	cmpqqm45100083xvoo43pm2fa
cmq7lnnpr0001l404r51avyc9	1	40.00	40.00	\N	cmq7hgfzy0000k00428coxwvj	cmpqqm65m000q3xvow1n8n4d2
cmq7lnnpr0004l404hc8caaq9	1	35.00	35.00	\N	cmq7hgfzy0000k00428coxwvj	cmpqqm4l9000c3xvojqoj1yyt
cmq7lnnpr0008l404wr6kxffy	1	40.00	40.00	\N	cmq7hgfzy0000k00428coxwvj	cmpqqm3ot00063xvoeortkzib
cmq7lnnpr000bl40424anubmz	1	40.00	40.00	\N	cmq7hgfzy0000k00428coxwvj	cmpqqm81900163xvo5msxvp3a
cmq7mbhri0007la04tbhdp6od	1	45.00	45.00	\N	cmq7mb23t0005la04zcuigdic	cmpqqmbdf00203xvoi39rfzmh
cmq7mf1n4000fla0423jnlj68	1	40.00	40.00	\N	cmq7mf1n4000dla04oc09ngst	cmpqqm81900163xvo5msxvp3a
cmq7mjt2a0003jr04lp2690gt	1	35.00	35.00	\N	cmq7mjt2a0001jr04lxq5g0sk	cmpqqm4l9000c3xvojqoj1yyt
cmq7mjt2a0007jr048v6nvwum	1	40.00	40.00	\N	cmq7mjt2a0001jr04lxq5g0sk	cmpqqm45100083xvoo43pm2fa
cmq7mkear000ejr04zi3db1v1	1	40.00	40.00	\N	cmq7mkear000cjr043vwpfrm7	cmpqqm65m000q3xvow1n8n4d2
cmq7msmeq0003jy042wuhu21v	1	35.00	35.00	\N	cmq7msmeq0001jy04wvfdb2jd	cmpqqm8iy001a3xvodugp204w
cmq7msmeq0007jy0419gax114	1	35.00	35.00	\N	cmq7msmeq0001jy04wvfdb2jd	cmpqqm8yp001e3xvolh59nlvx
cmq7nrx8e0003l104pebgbkc2	1	40.00	40.00	\N	cmq7nrx8e0001l104ydbdftuo	cmpqqmd4h002g3xvorpy8wab0
cmq7nrx8e0006l104bns2jz6r	1	35.00	35.00	\N	cmq7nrx8e0001l104ydbdftuo	cmpqqm9u8001m3xvo3u2d61ub
cmq7nsx2l0003l504dxf5djxy	1	35.00	35.00	\N	cmq7nsx2l0001l504kejmwuq9	cmpqqm8iy001a3xvodugp204w
cmq7nsx2m0007l504ptcwo0b4	1	35.00	35.00	\N	cmq7nsx2l0001l504kejmwuq9	cmpqqm8iy001a3xvodugp204w
cmq7ntbey000gl504ia4gtofi	1	35.00	35.00	\N	cmq7ntbex000el504b7x1w3xu	cmpqqm4l9000c3xvojqoj1yyt
cmq7nxaav000el104zxiubb51	2	35.00	70.00	\N	cmq7nxaav000cl104dtxiupwb	cmpqqm4l9000c3xvojqoj1yyt
cmq7o16oh000pl504tu81oo3q	2	30.00	60.00	\N	cmq7o16oh000nl504n8fzjyqn	cmpqqm8qt001c3xvom39q1hsv
cmq8nljlp0002k5048zzwr1mf	1	35.00	35.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqmc1300263xvodgeiz5il
cmq8nljlp0005k5041k0nsq9l	1	35.00	35.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqm4l9000c3xvojqoj1yyt
cmq8nljlp0009k5049mszim4t	1	40.00	40.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqm4cx000a3xvo6ij5ksrm
cmq8nljlp000dk504euwrl1rp	1	35.00	35.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqmhq9003k3xvoadvnhwjy
cmq8nljlp000gk504e4obetly	1	35.00	35.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqm9eg001i3xvoqq2p0pcl
cmq8nljlq000kk504xagfsarr	1	35.00	35.00	\N	cmq8nljlp0000k504ybgamm2p	cmpqqm9eg001i3xvoqq2p0pcl
cmq8okvww0002jv04ddvulcop	1	40.00	40.00	\N	cmq8okvwv0000jv04zuzsd30a	cmpqqmcwl002e3xvoh9uib930
cmq8okvww0006jv04c8zer634	1	35.00	35.00	\N	cmq8okvwv0000jv04zuzsd30a	cmpqqm4l9000c3xvojqoj1yyt
cmq8okvww000ajv04bmywlw5e	2	35.00	70.00	\N	cmq8okvwv0000jv04zuzsd30a	cmpqqm4l9000c3xvojqoj1yyt
cmq8okvww000fjv04w7bq3iw6	1	35.00	35.00	\N	cmq8okvwv0000jv04zuzsd30a	cmpqqm8iy001a3xvodugp204w
cmq8ovw370002k304zt6wxbcs	1	50.00	50.00	\N	cmq8ovw360000k3042klqx77h	cmpqqm4cx000a3xvo6ij5ksrm
cmq8pnnoi0003ih04t9njc3bt	1	35.00	35.00	\N	cmq8pnnoh0001ih04vfrf667z	cmpqqm4l9000c3xvojqoj1yyt
cmq8pnnoi0007ih04o8k2dfw9	1	40.00	40.00	\N	cmq8pnnoh0001ih04vfrf667z	cmpqqmd4h002g3xvorpy8wab0
cmq8prlhk0002js04k4rxxhzq	2	35.00	70.00	\N	cmq8prlhj0000js04teqhwo8p	cmpqqm4l9000c3xvojqoj1yyt
cmq8qbbiz0003i804iyidqut0	1	35.00	35.00	\N	cmq8qbbiz0001i804b6ytk86t	cmpqqm4l9000c3xvojqoj1yyt
cmq8qbbiz0007i8040fswhpjm	1	15.00	15.00	\N	cmq8qbbiz0001i804b6ytk86t	cmpzoaia200023xomsj6ohdvb
cmq8qbnil000ci804mnhbinug	1	50.00	50.00	\N	cmq8qbnil000ai804jju7b3bw	cmpqqm3ot00063xvoeortkzib
cmq8qcmk4000mi804tprjqxrh	1	35.00	35.00	\N	cmq8qcmk4000ki804tm3s43hq	cmpqqm4l9000c3xvojqoj1yyt
cmq8qji0m0003i604hz87urxj	1	40.00	40.00	\N	cmq8qji0m0001i604ek4v1oc6	cmpqqm81900163xvo5msxvp3a
cmq8qny5x000ci604zgzl1jd5	1	35.00	35.00	\N	cmq8qny5w000ai6043947j4he	cmpqqm8iy001a3xvodugp204w
cmq8qw644000li604xs7zbmof	1	15.00	15.00	\N	cmq8qw643000ji604v14hsfnl	cmpzoaia200023xomsj6ohdvb
cmq8r28ci0002jo04up5iwwpp	1	35.00	35.00	\N	cmq8r28ci0000jo04dib4mjur	cmpqqm9eg001i3xvoqq2p0pcl
cmq8rbxw4000cjo04je8cdpfj	1	40.00	40.00	\N	cmq8rbxw4000ajo04dvpwz0gn	cmpqqm45100083xvoo43pm2fa
cmq8rbxw4000gjo04e2f8polf	1	35.00	35.00	\N	cmq8rbxw4000ajo04dvpwz0gn	cmpqqm4l9000c3xvojqoj1yyt
cmq8rcypz000ojo04cnczoefl	1	35.00	35.00	\N	cmq8rcypz000mjo04f7zb2b33	cmpqqm4l9000c3xvojqoj1yyt
cmq8rmcgi0005l204gtufx548	1	40.00	40.00	\N	cmq8rmcgi0003l204t5vw9rqd	cmpqqm4cx000a3xvo6ij5ksrm
cmq8rn7ag000ti604r31lc73d	1	40.00	40.00	\N	cmq8rn7af000ri604030l04to	cmpqqm4t7000e3xvoazlktde5
cmq8rns44000yjo04fur3dhmv	1	35.00	35.00	\N	cmq8rns44000wjo0412zihgag	cmpqqm4l9000c3xvojqoj1yyt
cmq8ry5kw0010i604selrtwwy	1	35.00	35.00	\N	cmq8ry5kv000yi604keu3rl3q	cmpqqm8iy001a3xvodugp204w
cmq8rybua0017i6040l1m3vkc	1	40.00	40.00	\N	cmq8rybua0015i604tyb0tc3v	cmpqqm3ot00063xvoeortkzib
cmq8s3ukb0003l1043791cace	2	35.00	70.00	\N	cmq8s3ukb0001l1048336hs11	cmpqqm9eg001i3xvoqq2p0pcl
cmq8sbfk2000il1041gw6hgj4	1	40.00	40.00	\N	cmq8sbfk2000gl104lyzfkcoa	cmpqqm81900163xvo5msxvp3a
cmq8sjv70000wl104z3l6g64b	1	15.00	15.00	\N	cmq8sdqca000pl1049qo5sjve	cmpzoaia200023xomsj6ohdvb
cmq8sjv70000xl104d09gwo8e	1	30.00	30.00	\N	cmq8sdqca000pl1049qo5sjve	cmpu4u2520001l4045ganc8z4
cmq8vjo4w0003js04x3jbx1w5	1	30.00	30.00	\N	cmq8vjo4w0001js04ql4nlf36	cmpu4u2520001l4045ganc8z4
cmq8vo54e0003jx04kw7legq0	1	40.00	40.00	\N	cmq8vo54e0001jx04ogew8vi3	cmprepa050001jp04hcbe0l2v
cmq8vojuw000ajx04bs9oujar	2	40.00	80.00	\N	cmq8vojuw0008jx04lx39g917	cmprepa050001jp04hcbe0l2v
cmq8voquw000hjx04y3q1j5jj	1	35.00	35.00	\N	cmq8voquw000fjx0442s3nl96	cmpqqm4l9000c3xvojqoj1yyt
cmq8vuj1e000ojx04fxt9l5gy	1	35.00	35.00	\N	cmq8vuj1d000mjx04g8t3g0bz	cmpqqm4l9000c3xvojqoj1yyt
cmq8vzsb60003kt04x4e9tk69	1	45.00	45.00	\N	cmq8vzsb60001kt04lfbscle2	cmpqqm4l9000c3xvojqoj1yyt
cmq8vzsb70008kt04akjvr7jw	1	50.00	50.00	\N	cmq8vzsb60001kt04lfbscle2	cmprepa050001jp04hcbe0l2v
cmq8vzsb7000dkt045d1enck0	1	35.00	35.00	\N	cmq8vzsb60001kt04lfbscle2	cmpqqm8iy001a3xvodugp204w
cmq8widpi0003jn04mhhhxkvv	1	40.00	40.00	\N	cmq8widpi0001jn04ij5wkjif	cmpqqm3ot00063xvoeortkzib
cmq8widpi0006jn04hhrb47f5	1	40.00	40.00	\N	cmq8widpi0001jn04ij5wkjif	cmprepa050001jp04hcbe0l2v
cmq8wkfs7000fjn04hsgth2ni	1	35.00	35.00	\N	cmq8wkfs7000djn04ewp2bq2o	cmpqqm4l9000c3xvojqoj1yyt
cmq8wkfs7000jjn04tvoe69u5	1	40.00	40.00	\N	cmq8wkfs7000djn04ewp2bq2o	cmpqqmd4h002g3xvorpy8wab0
cmq8wtc0v000rjn04xju5affs	1	35.00	35.00	\N	cmq8wtc0v000pjn04lvb0nzgm	cmpqqm4l9000c3xvojqoj1yyt
cmq8xx7x70003l104u5cm40m6	1	35.00	35.00	\N	cmq8xx7x70001l104wenrsc6n	cmpqqm4l9000c3xvojqoj1yyt
cmq8y8txt000bl104ow81scdl	2	40.00	80.00	\N	cmq8y8txt0009l104g3kq58gy	cmpqqmd4h002g3xvorpy8wab0
cmq8y8txt000el104wxj7eicf	1	35.00	35.00	\N	cmq8y8txt0009l104g3kq58gy	cmpqqm4l9000c3xvojqoj1yyt
cmq8y8txt000il104j1t8kimp	1	40.00	40.00	\N	cmq8y8txt0009l104g3kq58gy	cmpqqm3ot00063xvoeortkzib
cmq92k7200003jl04su2lej8o	1	40.00	40.00	\N	cmq92k7200001jl04dnymjlps	cmprepa050001jp04hcbe0l2v
cmq92lzws000ajl04y3nxblhj	1	40.00	40.00	\N	cmq92lzws0008jl04n2h4ugql	cmprepa050001jp04hcbe0l2v
cmq92lzws000ejl04vmd60ebg	1	40.00	40.00	\N	cmq92lzws0008jl04n2h4ugql	cmpqqm3ot00063xvoeortkzib
cmq92lzws000hjl04s6h6x95e	1	35.00	35.00	\N	cmq92lzws0008jl04n2h4ugql	cmpqqm4l9000c3xvojqoj1yyt
cmq93ntbk0003jy04bxcxft9p	1	35.00	35.00	\N	cmq93ntbk0001jy049azdpsb7	cmpqqm4l9000c3xvojqoj1yyt
cmq93ntbk0007jy049qvdrduv	1	35.00	35.00	\N	cmq93ntbk0001jy049azdpsb7	cmpqqm8iy001a3xvodugp204w
cmq93ntbk000bjy04i1mgvv1r	1	35.00	35.00	\N	cmq93ntbk0001jy049azdpsb7	cmpqqm4l9000c3xvojqoj1yyt
cmq93ntbl000fjy04o7phtu8q	1	40.00	40.00	\N	cmq93ntbk0001jy049azdpsb7	cmprepa050001jp04hcbe0l2v
cmq95z0oq0003jf04yhzks9a0	1	40.00	40.00	\N	cmq95z0oq0001jf04djb6mrz9	cmpqqm4cx000a3xvo6ij5ksrm
cmqa7hftw0004ju0470gfu69e	1	35.00	35.00	\N	cmqa7hftw0002ju04khs7s5dj	cmpqqm4l9000c3xvojqoj1yyt
cmqa7hxla000dju047ec7hadt	1	35.00	35.00	\N	cmqa7hxla000bju04wq3kip3e	cmpqqm4l9000c3xvojqoj1yyt
cmqa7k8bs0003ic04uwggy53m	1	35.00	35.00	\N	cmqa7k8bs0001ic04v9ygvtrp	cmpqqm4l9000c3xvojqoj1yyt
cmqa7o7xd000kju04shs6d1qj	1	40.00	40.00	\N	cmqa7o7xd000iju0430igs9dj	cmpqqm3ot00063xvoeortkzib
cmqa7o7xd000nju04z5ugdxq7	1	45.00	45.00	\N	cmqa7o7xd000iju0430igs9dj	cmpqqm89400183xvo7b2i3mk9
cmqa88zjs0003la04q2anl5wl	1	35.00	35.00	\N	cmqa88zjs0001la04wa3kh58q	cmpqqm4l9000c3xvojqoj1yyt
cmqa88zjs0007la044iviyf7s	1	40.00	40.00	\N	cmqa88zjs0001la04wa3kh58q	cmpqqm4t7000e3xvoazlktde5
cmqa94h6c0003i904o4qfc66n	1	35.00	35.00	\N	cmqa94h6c0001i904lt9wwjga	cmpqqm4l9000c3xvojqoj1yyt
cmqa96bl10003l804rr71ss26	1	40.00	40.00	\N	cmqa96bl10001l804va9b3q4r	cmpqqm513000g3xvo0iex8rrm
cmqa9l9hl0003la04q6ynce8f	1	35.00	35.00	\N	cmqa9l9hl0001la04a6pmhncp	cmpqqm8iy001a3xvodugp204w
cmqa9s7vd000cl804qi0rjxi1	2	35.00	70.00	\N	cmqa9s7vd000al8041vwp2yyz	cmpqqm4l9000c3xvojqoj1yyt
cmqa9s7vd000gl804xswhk89q	1	25.00	25.00	\N	cmqa9s7vd000al8041vwp2yyz	cmq7m4l080001la04q94r0qzv
cmqa9x3do000kl804khucikea	1	35.00	35.00	\N	cmqa9v70q0009la04pmobcmr4	cmpqqm4l9000c3xvojqoj1yyt
cmqa9x3do000ol8046devx6bv	1	15.00	15.00	\N	cmqa9v70q0009la04pmobcmr4	cmpzoaia200023xomsj6ohdvb
cmqaa58vu000nla04o5hc34ug	1	40.00	40.00	\N	cmqaa4j24000gla04xzk07cnf	cmprepa050001jp04hcbe0l2v
cmqaa58vu000rla041n1sx3v9	1	15.00	15.00	\N	cmqaa4j24000gla04xzk07cnf	cmpzoaia200023xomsj6ohdvb
cmqaa5r3f000ul804rek3qnvr	1	35.00	35.00	\N	cmqaa5r3f000sl804yp50p1rz	cmpqqm4l9000c3xvojqoj1yyt
cmqaa6ttu0011l804bowjwwi2	1	35.00	35.00	\N	cmqaa6ttu000zl8041q45llcp	cmpqqm4l9000c3xvojqoj1yyt
cmqaa6ttv0015l8040z1xvtgc	1	40.00	40.00	\N	cmqaa6ttu000zl8041q45llcp	cmpqqm3ot00063xvoeortkzib
cmqaa6ttv0018l804lui1zl3f	1	40.00	40.00	\N	cmqaa6ttu000zl8041q45llcp	cmprepa050001jp04hcbe0l2v
cmqaa98d2000vla04vjdkeh2i	1	40.00	40.00	\N	cmqaa98d2000tla04wc4t4p8z	cmpqqm3ot00063xvoeortkzib
cmqaan28g0003ky04lajdowfq	1	40.00	40.00	\N	cmqaan28g0001ky04ffhfqjts	cmpqqm4t7000e3xvoazlktde5
cmqacvntj0003k004hrao4xzv	2	35.00	70.00	\N	cmqacvntj0001k004mj7x6j09	cmpqqm8iy001a3xvodugp204w
cmqacvntk0007k004a0jtzmql	1	45.00	45.00	\N	cmqacvntj0001k004mj7x6j09	cmpqqmblb00223xvok0kay89v
cmqae0r1z0003l404a83vncfc	2	40.00	80.00	\N	cmqae0r1z0001l404odmfvjp1	cmprepa050001jp04hcbe0l2v
cmqae26dv0003l504w79xpmxk	1	35.00	35.00	\N	cmqae26dv0001l50425g2bpi8	cmpqqm4l9000c3xvojqoj1yyt
cmqae4s3p000cl504du0hrplz	1	40.00	40.00	\N	cmqae4s3p000al5040pbitj8g	cmpqqm45100083xvoo43pm2fa
cmqaee63v000cl404l9a71eht	1	35.00	35.00	\N	cmqaee63v000al404x9r7buaz	cmpqqm9eg001i3xvoqq2p0pcl
cmqaehamv000kl4045l11lxkj	1	40.00	40.00	\N	cmqaehamu000il404helckqir	cmpqqm45100083xvoo43pm2fa
cmqaffjas0003l504mry5t925	1	40.00	40.00	\N	cmqaffjas0001l504xksxb12w	cmprepa050001jp04hcbe0l2v
cmqafp3gw0003kt04s2m2i61j	1	15.00	15.00	\N	cmqafp3gv0001kt04r4sfhpd1	cmpzoaia200023xomsj6ohdvb
cmqaib4eu0003l204w00z9dab	1	35.00	35.00	\N	cmqaib4eu0001l204jyly2ubl	cmpqqm8iy001a3xvodugp204w
cmqaice7v0003l704cytrgry5	1	40.00	40.00	\N	cmqaice7v0001l704dbrp72ta	cmpqqm4t7000e3xvoazlktde5
cmqaipwww0003ib04s0z1jdgh	1	40.00	40.00	\N	cmqaipwww0001ib04f1k6jjk6	cmprepa050001jp04hcbe0l2v
cmqaiqg54000aib04mzxzv88v	1	40.00	40.00	\N	cmqaiqg540008ib044sa8hid1	cmprepa050001jp04hcbe0l2v
cmqair9hn000gib04iwqir1th	1	40.00	40.00	\N	cmqair9hn000eib04n5wcyswl	cmpqqm3ot00063xvoeortkzib
cmqaj4e6e0007ky04iif1reyc	2	35.00	70.00	\N	cmqaj4e6e0005ky04ggvve583	cmpqqm4l9000c3xvojqoj1yyt
cmqaj4e6f000bky04jg9bbeoh	1	35.00	35.00	\N	cmqaj4e6e0005ky04ggvve583	cmpqqm8iy001a3xvodugp204w
cmqajkqki0005i804r8uxw6mb	1	35.00	35.00	\N	cmqajkqkh0003i804v79h5ant	cmpqqm4l9000c3xvojqoj1yyt
cmqajq74g0003ld04fqe99q6z	1	45.00	45.00	\N	cmqajq74g0001ld043b4b6ouz	cmpqqmdk7002k3xvoo1d970sf
cmqajq74g0006ld04lbr1s6w2	2	45.00	90.00	\N	cmqajq74g0001ld043b4b6ouz	cmpqqm8iy001a3xvodugp204w
cmqajq74g000ald044j4dyv7i	1	35.00	35.00	\N	cmqajq74g0001ld043b4b6ouz	cmpqqm8iy001a3xvodugp204w
cmqajq74g000eld04n7y89de9	1	30.00	30.00	\N	cmqajq74g0001ld043b4b6ouz	cmpqqm8qt001c3xvom39q1hsv
cmqdv1n69000n3xaplesekuyw	1	40.00	40.00	\N	cmqduj93f00023xapgmz8rijc	cmpqqm3ot00063xvoeortkzib
cmqdv4b94000s3xapublsfx15	1	40.00	40.00	\N	cmqdv4b93000q3xapzueyweuf	cmpqqm3ot00063xvoeortkzib
cmqdw3eni0001jv04ixt79zcf	1	35.00	35.00	\N	cmqdw2koa0004kz04d6aywjbj	cmpqqma23001o3xvoooy0q9ws
cmqdw5v990002lb040gsjc9kw	1	40.00	40.00	\N	cmqdw5v990000lb04g5ikfk4d	cmpqqm4t7000e3xvoazlktde5
cmqee26ja0003i0050obohixh	1	40.00	40.00	รับ 7 โมง	cmqee26ja0001i005b85yae0i	cmpqqm3ot00063xvoeortkzib
cmqeev0u00002l704yghohhip	1	35.00	35.00	\N	cmqeev0u00000l704f78yugzj	cmpqqm4l9000c3xvojqoj1yyt
cmqeev0u00006l7043wk6ei9j	1	40.00	40.00	\N	cmqeev0u00000l704f78yugzj	cmpqqm4t7000e3xvoazlktde5
cmqeev0u0000al7047qj9w9j1	1	40.00	40.00	\N	cmqeev0u00000l704f78yugzj	cmprepa050001jp04hcbe0l2v
cmqeev0u0000el704ni5ps1zy	1	35.00	35.00	\N	cmqeev0u00000l704f78yugzj	cmpqqm9eg001i3xvoqq2p0pcl
cmqeev0u0000il704tch2hmbm	1	15.00	15.00	\N	cmqeev0u00000l704f78yugzj	cmpzoaia200023xomsj6ohdvb
cmqefljuh000pl704pkei6pe9	1	50.00	50.00	\N	cmqefljug000nl704srmir2lv	cmpqqm3ot00063xvoeortkzib
cmqefmr0t000ijq044055ln09	1	40.00	40.00	\N	cmqefmr0t000gjq045lm8nln2	cmpqqm4t7000e3xvoazlktde5
cmqefmr0t000mjq047aro8t0l	1	25.00	25.00	\N	cmqefmr0t000gjq045lm8nln2	cmq7m4l080001la04q94r0qzv
cmqefu4fg000sjq04u0lenu19	1	40.00	40.00	\N	cmqefu4fg000qjq044svoavyg	cmpqqm3ot00063xvoeortkzib
cmqefz0ah000yl704x0tgiu2k	1	40.00	40.00	\N	cmqefz0ah000wl7046feyedr3	cmprepa050001jp04hcbe0l2v
cmqefz0ah0012l704eyadolal	1	35.00	35.00	\N	cmqefz0ah000wl7046feyedr3	cmpqqm4l9000c3xvojqoj1yyt
cmqeg6svc000yjq04jursp7ej	1	35.00	35.00	\N	cmqeg6svc000wjq04061val8b	cmpqqm9eg001i3xvoqq2p0pcl
cmqeg8tsi0015jq0414reonof	1	40.00	40.00	\N	cmqeg8tsi0013jq045drd16n9	cmpqqm81900163xvo5msxvp3a
cmqeg8tsi0019jq04io0dbgz2	1	15.00	15.00	\N	cmqeg8tsi0013jq045drd16n9	cmpzoaia200023xomsj6ohdvb
cmqegd94j0003ju04of0h4y6z	1	40.00	40.00	\N	cmqegd94j0001ju04y1dcckkq	cmpqqm4cx000a3xvo6ij5ksrm
cmqege2tl0003l404uo3yo0p4	1	35.00	35.00	\N	cmqege2tl0001l404tzbsbout	cmpqqm8iy001a3xvodugp204w
cmqegeddl0009l404m75uoceb	1	35.00	35.00	\N	cmqegeddl0007l40461h6z6kl	cmpqqm4l9000c3xvojqoj1yyt
cmqegeddl000dl404ddp8114f	1	35.00	35.00	\N	cmqegeddl0007l40461h6z6kl	cmpqqm8iy001a3xvodugp204w
cmqeglb080003l204v28egsyd	1	40.00	40.00	\N	cmqeglb080001l204a90y269y	cmpqqmahy001s3xvoh9qjvokp
cmqeglb080007l204b7wfbosw	1	35.00	35.00	\N	cmqeglb080001l204a90y269y	cmpqqma23001o3xvoooy0q9ws
cmqegmynv000dl2046jbnhf3n	1	35.00	35.00	\N	cmqegmynu000bl204v6ux4cal	cmpqqm9eg001i3xvoqq2p0pcl
cmqegoltz0002jm04is53dzhu	1	15.00	15.00	\N	cmqegolty0000jm04k5lmygkn	cmpzoaia200023xomsj6ohdvb
cmqegowpi000gju045r5bpnn6	1	45.00	45.00	\N	cmqegowpi000eju04vo1n0c92	cmpqqm4l9000c3xvojqoj1yyt
cmqegrqdc000sju04xj3x5yhd	1	45.00	45.00	\N	cmqegrqdb000qju04b81j0rx7	cmpqqmdk7002k3xvoo1d970sf
cmqegvt7g0019l7044vhoh76o	1	35.00	35.00	\N	cmqefe5od0000jq044w3dkn08	cmpqqm4l9000c3xvojqoj1yyt
cmqegvt7g001el704ssc145fy	2	35.00	70.00	\N	cmqefe5od0000jq044w3dkn08	cmpqqm4l9000c3xvojqoj1yyt
cmqegvt7g001jl704x6ggo26l	1	5.00	5.00	\N	cmqefe5od0000jq044w3dkn08	cmq7m69sc0003la04fmysvt29
cmqeh2whf0002l504g4pt39rv	1	35.00	35.00	\N	cmqeh2whf0000l504q1rdw4df	cmpqqm8iy001a3xvodugp204w
cmqeh5dnu000pl204wbmnzo4k	1	35.00	35.00	\N	cmqeh5dnu000nl204bwd7gsa1	cmpqqm4l9000c3xvojqoj1yyt
cmqeh5r50000bl5046u89cixd	1	40.00	40.00	\N	cmqeh5r500009l504p46seqda	cmpqqm513000g3xvo0iex8rrm
cmqeh636w000ll504cylbzloi	1	40.00	40.00	\N	cmqeh636w000jl5042dv21fb9	cmpqqm3ot00063xvoeortkzib
cmqeh8n5o000yl2049kjr1iy1	1	40.00	40.00	\N	cmqeh8n5o000wl204ou25zq0w	cmprepa050001jp04hcbe0l2v
cmqehk0ni001zl704mz87r46n	1	35.00	35.00	\N	cmqehk0ni001xl704tufjw9az	cmpqqm4l9000c3xvojqoj1yyt
cmqehnp01000vl504r66ie4qy	1	40.00	40.00	\N	cmqehnp01000tl5044avxcpir	cmprepa050001jp04hcbe0l2v
cmqehohi10014l504wvcjpocr	1	40.00	40.00	\N	cmqehohi10012l504h49ma1ej	cmpqqm45100083xvoo43pm2fa
cmqehp0h40028l704b0uhqgfx	1	35.00	35.00	\N	cmqehp0h40026l70425sbnf3g	cmpqqm4l9000c3xvojqoj1yyt
cmqehszu2002fl704tp3jpbd7	1	40.00	40.00	\N	cmqehsm2g0019l5047ixbwsxi	cmpqqm3ot00063xvoeortkzib
cmqehszu2002jl704l0jepp76	1	5.00	5.00	\N	cmqehsm2g0019l5047ixbwsxi	cmq7m69sc0003la04fmysvt29
cmqehwfio0004i304z3es6k93	1	40.00	40.00	\N	cmqehwfio0002i3042j7ijrmw	cmpqqm4t7000e3xvoazlktde5
cmqehz0ar002nl704cm2oryfc	1	35.00	35.00	\N	cmqehz0ar002ll704ttpnxq2b	cmpqqm9eg001i3xvoqq2p0pcl
cmqei0bdj002wl704ilzrnfsy	1	40.00	40.00	\N	cmqei0bdi002ul7048ivwgnxb	cmpqqm4t7000e3xvoazlktde5
cmqei2gsj000ei3041sjvyqux	1	40.00	40.00	\N	cmqei2gsj000ci304ttavm0hm	cmprepa050001jp04hcbe0l2v
cmqekpxv00003lb04s9v43w8h	1	40.00	40.00	\N	cmqekpxuz0001lb042kqghdsq	cmpqqm513000g3xvo0iex8rrm
cmqekqlft000clb04j7f24zhe	1	35.00	35.00	\N	cmqekqlft000alb04rkh20oqf	cmpqqm8iy001a3xvodugp204w
cmqekrmxr000llb04n85ha5jk	1	40.00	40.00	\N	cmqekrmxq000jlb040pgslxo1	cmpqqm3ot00063xvoeortkzib
cmqekrmxr000olb046w1b1aym	1	40.00	40.00	\N	cmqekrmxq000jlb040pgslxo1	cmpqqm65m000q3xvow1n8n4d2
cmqekv7060003lb04ey8xz7az	1	40.00	40.00	\N	cmqekv7060001lb041ncl7gms	cmpqqm3ot00063xvoeortkzib
cmqel2y52000wlb048hxqw2g2	1	40.00	40.00	\N	cmqel2y52000ulb04vu5o8f82	cmpqqm5gv000k3xvoc025780c
cmqel3f9c0015lb041zemnyqd	1	35.00	35.00	\N	cmqel3f9c0013lb04xopp32mt	cmpqqm4l9000c3xvojqoj1yyt
cmqzu88gj000kjn04quxs19bs	1	35.00	35.00	\N	cmqzu88gj000ijn04pahaail0	cmpqqm4l9000c3xvojqoj1yyt
cmqzu88gk000ojn04w31crmih	1	15.00	15.00	\N	cmqzu88gj000ijn04pahaail0	cmpzoaia200023xomsj6ohdvb
cmqzu88gk000pjn04syngyrxx	1	5.00	5.00	\N	cmqzu88gj000ijn04pahaail0	cmq7m69sc0003la04fmysvt29
cmqzunybb0003l504l10vq4fn	1	40.00	40.00	\N	cmqzunybb0001l504m2hke39o	cmpqqm513000g3xvo0iex8rrm
cmqzunybb0008l504twtyp287	1	35.00	35.00	\N	cmqzunybb0001l504m2hke39o	cmpqqm9eg001i3xvoqq2p0pcl
cmqzunybb000dl504o8lxsvz8	1	40.00	40.00	\N	cmqzunybb0001l504m2hke39o	cmpqqm81900163xvo5msxvp3a
cmqzunybc000il504alc4myaa	1	40.00	40.00	\N	cmqzunybb0001l504m2hke39o	cmpqqm5oq000m3xvo7hnkpo73
cmqzwtdpv000cl204w2fwy49z	1	35.00	35.00	\N	cmqzwtdpv000al204vcrawf87	cmpqqm4l9000c3xvojqoj1yyt
cmqzzyl1j0003l504v1j2ww37	1	40.00	40.00	\N	cmqzzyl1j0001l504kjjdl86c	cmprepa050001jp04hcbe0l2v
cmr00nkfb0003jr042rp7wse7	1	40.00	40.00	\N	cmr00nkfb0001jr04oaxfco8s	cmprepa050001jp04hcbe0l2v
cmr00nkfb0007jr04xaul66vg	1	45.00	45.00	\N	cmr00nkfb0001jr04oaxfco8s	cmpqqmbdf00203xvoi39rfzmh
cmr00oysw000kjr046qwuqyam	1	40.00	40.00	เพิ่มโกโก้	cmr00oysw000ijr042fy8yjhf	cmpqqm81900163xvo5msxvp3a
cmr00oysw000ojr04nmu0cuck	1	35.00	35.00	\N	cmr00oysw000ijr042fy8yjhf	cmpqqm9eg001i3xvoqq2p0pcl
cmr00u9g20003l704b5ughbex	1	35.00	35.00	\N	cmr00u9g20001l704mgsfpx3d	cmq8nuyoz0001k304d0qgxux4
cmqel4u94001elb04blmha5f7	1	35.00	35.00	ไม่ใส่นมข้น	cmqel4u94001clb04g44aiz26	cmpqqma23001o3xvoooy0q9ws
cmqel6vrh0009lb041gzx9a8x	1	40.00	40.00	ไม่ใส่น้ำเชื่อม	cmqel6vrh0007lb04221tcgcp	cmpqqm4t7000e3xvoazlktde5
cmqel7l3o001nlb04dm0zapb1	1	40.00	40.00	\N	cmqel7l3o001llb046wfqxcq3	cmprepa050001jp04hcbe0l2v
cmqemetdm0003l204v2u3bspc	1	35.00	35.00	\N	cmqemetdm0001l204600waj0e	cmpqqm4l9000c3xvojqoj1yyt
cmqemetdn0007l204yru6y87n	1	35.00	35.00	\N	cmqemetdm0001l204600waj0e	cmpqqm8iy001a3xvodugp204w
cmqeopz470003ih0419d44a2d	1	35.00	35.00	\N	cmqeopz470001ih04v431kzt4	cmpqqm8iy001a3xvodugp204w
cmqeopz470007ih04te96dp2s	1	35.00	35.00	\N	cmqeopz470001ih04v431kzt4	cmpqqm8iy001a3xvodugp204w
cmqep5dbb0009l404if8wdyj0	1	40.00	40.00	\N	cmqep4xu40001l4046bxwds4w	cmprepa050001jp04hcbe0l2v
cmqeq5v3h0003ib044ndkue2g	1	40.00	40.00	\N	cmqeq5v3h0001ib044lz9ni4a	cmpqqm3ot00063xvoeortkzib
cmqerio620003i504au3p5wy3	1	40.00	40.00	\N	cmqerio620001i504s4hd8t5b	cmpqqm81900163xvo5msxvp3a
cmqerio620007i5047dsay7o2	1	35.00	35.00	\N	cmqerio620001i504s4hd8t5b	cmpqqm8iy001a3xvodugp204w
cmqerozpe0003la04dkv28bmn	1	40.00	40.00	\N	cmqerozpe0001la04i8oyzn3s	cmpqqm4t7000e3xvoazlktde5
cmqerozpe0007la042xw7lv0k	1	35.00	35.00	\N	cmqerozpe0001la04i8oyzn3s	cmpqqm8iy001a3xvodugp204w
cmqfsqq750002ld04qcasrb04	1	35.00	35.00	\N	cmqfsqq750000ld048c870nbs	cmpqqm4l9000c3xvojqoj1yyt
cmqfsqq750006ld049eryqg3g	1	35.00	35.00	\N	cmqfsqq750000ld048c870nbs	cmpqqmc1300263xvodgeiz5il
cmqfsqq750009ld04ojap6fku	1	40.00	40.00	\N	cmqfsqq750000ld048c870nbs	cmprepa050001jp04hcbe0l2v
cmqfsqq75000dld049oza7sls	1	40.00	40.00	\N	cmqfsqq750000ld048c870nbs	cmpqqm4t7000e3xvoazlktde5
cmqfsqq76000hld04okvlmo6h	1	40.00	40.00	\N	cmqfsqq750000ld048c870nbs	cmprepa050001jp04hcbe0l2v
cmqfsqq76000lld04a4zcoa35	1	15.00	15.00	\N	cmqfsqq750000ld048c870nbs	cmpzoaia200023xomsj6ohdvb
cmqftvv5r0002ld04iio5vqtu	1	35.00	35.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm8iy001a3xvodugp204w
cmqftvv5r0007ld049b4qijgp	1	35.00	35.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm4l9000c3xvojqoj1yyt
cmqftvv5r000cld04ykbrbbb6	1	40.00	40.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm45100083xvoo43pm2fa
cmqftvv5r000hld04gx052gpf	2	35.00	70.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm4l9000c3xvojqoj1yyt
cmqftvv5r000mld04bg7kwctr	1	35.00	35.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm4l9000c3xvojqoj1yyt
cmqftvv5r000qld0416mwglrr	1	35.00	35.00	\N	cmqftvv5q0000ld0465xta0at	cmpqqm4l9000c3xvojqoj1yyt
cmqfud7nf0010ld04uovbir90	1	40.00	40.00	\N	cmqfud7nf000yld04jq4adjzq	cmprepa050001jp04hcbe0l2v
cmqfuyyrc0005l804qt5hu9z5	1	35.00	35.00	\N	cmqfuyyrb0003l804jh674tnc	cmpqqm4l9000c3xvojqoj1yyt
cmqfuyyrc0009l804s7iuxy5g	1	40.00	40.00	\N	cmqfuyyrb0003l804jh674tnc	cmpqqm5oq000m3xvo7hnkpo73
cmqfvbu550003ks04ktlf7fxm	2	35.00	70.00	\N	cmqfvbu550001ks04a8tdcmou	cmpqqm4l9000c3xvojqoj1yyt
cmqfvcak9000bks04a31zcg27	1	35.00	35.00	\N	cmqfvcak90009ks04frb5z0ya	cmpqqm4l9000c3xvojqoj1yyt
cmqfvh4rl000lks043mc4yvy4	1	40.00	40.00	ใส่แก้วมาเอง	cmqfvh4rl000jks04lk16yjy8	cmpqqm45100083xvoo43pm2fa
cmqfvi9rs0003jv04qjzxh1my	1	35.00	35.00	\N	cmqfvi9rs0001jv04v0eoq0tt	cmpqqm4l9000c3xvojqoj1yyt
cmqfvsiw8000ajv0474ifzzck	1	35.00	35.00	\N	cmqfvsiw80008jv045u9awuri	cmpqqm8iy001a3xvodugp204w
cmqfw2cld000jjv04bo6m6zdi	1	40.00	40.00	\N	cmqfw2clc000hjv04xvvg3a9h	cmpqqmc8y00283xvomsuwyqct
cmqfw96qm000rjv04e01zbyzp	2	35.00	70.00	\N	cmqfw96qm000pjv04z3e2xapt	cmpqqm8iy001a3xvodugp204w
cmqfwds850003l404vkp4p6ta	1	40.00	40.00	\N	cmqfwds850001l404h7wxfp60	cmprepa050001jp04hcbe0l2v
cmqfwio8o000al4043ye078wm	1	35.00	35.00	\N	cmqfwio8o0008l404j8o7uh0q	cmpqqm4l9000c3xvojqoj1yyt
cmqfwuju30011jv04m5u6gzau	2	35.00	70.00	\N	cmqfwuju3000zjv045v016l3p	cmpqqm8iy001a3xvodugp204w
cmqfx13wb000ll404fs5qgdtq	1	40.00	40.00	\N	cmqfx13wa000jl404q3wirgy3	cmpqqm4t7000e3xvoazlktde5
cmqfx1kkg000sl404y277nm3f	1	40.00	40.00	\N	cmqfx1kkg000ql404tksl9q7i	cmpqqm45100083xvoo43pm2fa
cmqfxayic0003jp04iahs8m7q	1	35.00	35.00	\N	cmqfxayic0001jp04p9jgevib	cmpqqm8iy001a3xvodugp204w
cmqg0d9w00003jo04xldx9v97	1	35.00	35.00	\N	cmqg0d9w00001jo048onrf7e2	cmpqqm4l9000c3xvojqoj1yyt
cmqg16zzf0003la0439395y36	1	35.00	35.00	\N	cmqg16zzf0001la046sy3i4wt	cmpqqm4l9000c3xvojqoj1yyt
cmqg2ip9m000d3xzgf54xkssp	1	35.00	35.00	\N	cmqg2ab5500013xzg34k6pfg1	cmpqqm4l9000c3xvojqoj1yyt
cmqg2sz0x0003ic04e4i1tqbj	1	35.00	35.00	\N	cmqg2sz0w0001ic04q2gywnhk	cmpqqm4l9000c3xvojqoj1yyt
cmqg2sz0x0007ic048jd1uzpi	1	35.00	35.00	\N	cmqg2sz0w0001ic04q2gywnhk	cmpqqm4l9000c3xvojqoj1yyt
cmqg3mdnz000w3xzgt146lzst	1	35.00	35.00	\N	cmqg38w9c000h3xzgdo8lcntj	cmpqqm4l9000c3xvojqoj1yyt
cmqg6xrh40003l804i1rtn9sw	1	40.00	40.00	\N	cmqg6xrh40001l80443zuen3d	cmpqqm4t7000e3xvoazlktde5
cmqg70do0000al80422alkp28	1	40.00	40.00	\N	cmqg70do00008l8041rjw1hvi	cmpqqm6di000s3xvog0defnci
cmqg7bbm40003le04ooxllxho	1	40.00	40.00	\N	cmqg7bbm40001le04pb74fltp	cmpqqmcoq002c3xvolsroh00b
cmqg8o3ow0003k004eaatyk1u	2	30.00	60.00	\N	cmqg8o3ov0001k004zn9iec6o	cmpqqm8qt001c3xvom39q1hsv
cmqg8pwmb000bk004g4bkz2yq	1	40.00	40.00	\N	cmqg8pwmb0009k004z056fnpt	cmprepa050001jp04hcbe0l2v
cmqg8w2n00003jg045vo40mzv	1	35.00	35.00	\N	cmqg8w2n00001jg04hwh2jc8v	cmpqqm8iy001a3xvodugp204w
cmqg93l3h000cjg04d3dmdr2t	1	40.00	40.00	\N	cmqg93l3h000ajg04x2r5n7u1	cmpqqm81900163xvo5msxvp3a
cmqg9m8wk0003l204k3onceim	1	40.00	40.00	\N	cmqg9m8wk0001l2044kvlwkjs	cmprepa050001jp04hcbe0l2v
cmqh8wax00003jv04n6tkj4tb	1	40.00	40.00	แก้วสีชมพูเอามาเอง	cmqh8wax00001jv04r8li7plu	cmpqqm45100083xvoo43pm2fa
cmqh8wmrw000ajv04u1oxx6ba	1	40.00	40.00	พี่เอ็ม	cmqh8wmrw0008jv04ur26ay8z	cmprepa050001jp04hcbe0l2v
cmqh935b80002l804txf4y137	1	35.00	35.00	\N	cmqh935b80000l804xbwxz2my	cmpqqm4l9000c3xvojqoj1yyt
cmqh935b80006l80428mabp00	1	40.00	40.00	\N	cmqh935b80000l804xbwxz2my	cmprepa050001jp04hcbe0l2v
cmqh9eh620002jp04xbp5jgrx	1	40.00	40.00	\N	cmqh9eh620000jp048o3l9529	cmpqqm4t7000e3xvoazlktde5
cmqh9eh620006jp04lylsf3ig	1	40.00	40.00	\N	cmqh9eh620000jp048o3l9529	cmpqqm3ot00063xvoeortkzib
cmqh9eh620009jp04g1ebxkxu	1	15.00	15.00	\N	cmqh9eh620000jp048o3l9529	cmpzoaia200023xomsj6ohdvb
cmqh9ho0j000fjp04sxpqie5e	1	35.00	35.00	\N	cmqh9ho0j000djp04obkt4exl	cmpqqm4l9000c3xvojqoj1yyt
cmqh9ho0j000kjp04igh75djm	2	35.00	70.00	\N	cmqh9ho0j000djp04obkt4exl	cmpqqm4l9000c3xvojqoj1yyt
cmqh9ho0j000pjp04d0faguga	1	35.00	35.00	\N	cmqh9ho0j000djp04obkt4exl	cmpqqm4l9000c3xvojqoj1yyt
cmqh9ho0j000tjp04ura0naeo	1	35.00	35.00	\N	cmqh9ho0j000djp04obkt4exl	cmpqqm4l9000c3xvojqoj1yyt
cmqh9ho0j000xjp044cz1khti	1	35.00	35.00	\N	cmqh9ho0j000djp04obkt4exl	cmpqqm8iy001a3xvodugp204w
cmqh9vl920003jp042w9xrqd8	1	35.00	35.00	\N	cmqh9vl920001jp04vzxkb2vn	cmpqqm4l9000c3xvojqoj1yyt
cmqh9vl920007jp04nax6k0u7	1	40.00	40.00	\N	cmqh9vl920001jp04vzxkb2vn	cmpqqm5oq000m3xvo7hnkpo73
cmqhaf3ao0003la04kl004nkd	1	35.00	35.00	\N	cmqhaf3ao0001la04zxmr7zrs	cmpqqm4l9000c3xvojqoj1yyt
cmqhaoj8s0002l704s4hl7jhi	1	35.00	35.00	\N	cmqhaoj8s0000l704s2lnk9db	cmpqqm4l9000c3xvojqoj1yyt
cmqhapsqa0003kz0459o5rh8p	1	35.00	35.00	\N	cmqhapsqa0001kz046m532ale	cmpqqm9eg001i3xvoqq2p0pcl
cmqhaun1j000cl7048ua0mg6o	1	35.00	35.00	\N	cmqhaun1j000al704nwyver1t	cmpqqm9eg001i3xvoqq2p0pcl
cmqhb1lml000cla04vjr4p5n9	1	35.00	35.00	\N	cmqhb1lml000ala04fq4bpcip	cmpqqm4l9000c3xvojqoj1yyt
cmqhb2h2t000ll704sjdeb5d3	1	40.00	40.00	\N	cmqhb2h2t000jl7049fgs758z	cmpqqm45100083xvoo43pm2fa
cmqhb64x1000ckz041ntz3w8g	1	35.00	35.00	\N	cmqhb64x0000akz04r3pajxy3	cmpqqm9eg001i3xvoqq2p0pcl
cmqhb97pr0002jr04jw8phjcj	1	40.00	40.00	\N	cmqhb97pr0000jr04pubtyqr2	cmpqqm3ot00063xvoeortkzib
cmqhbas6u000djr043talrgz4	1	40.00	40.00	\N	cmqhbas6t000bjr04oanv73n2	cmprepa050001jp04hcbe0l2v
cmqhbbzdo000mjr04rjgs1xhh	1	40.00	40.00	\N	cmqhbbzdo000kjr04249k17z8	cmpqqmc8y00283xvomsuwyqct
cmqhbcv6a000lla04d2zxuamv	1	40.00	40.00	\N	cmqhbcv6a000jla04rsxsaatv	cmpqqm5gv000k3xvoc025780c
cmqhbejle000ula04clxnaume	1	35.00	35.00	\N	cmqhbejle000sla04ilh347jq	cmpqqm8iy001a3xvodugp204w
cmqhbshph0003jv048nr9nwbh	1	35.00	35.00	\N	cmqhbshph0001jv04qhu8n2rx	cmpqqm4l9000c3xvojqoj1yyt
cmqhbyltz0012la04f25bgq64	1	40.00	40.00	\N	cmqhbyltz0010la04bflbvizt	cmprepa050001jp04hcbe0l2v
cmqhc7c29000ajv0413k7k1lz	1	40.00	40.00	คั่วอ่อน	cmqhc7c290008jv04is9tzreq	cmprepa050001jp04hcbe0l2v
cmqhcltl70005kz0496i4ckvx	1	40.00	40.00	\N	cmqhcltl70003kz04cy40mcax	cmpqqm3ot00063xvoeortkzib
cmqhcpdm6000jjv044w0fi14n	1	40.00	40.00	\N	cmqhcpdm6000hjv04fugns4mb	cmpqqm58z000i3xvo7kzkzfoh
cmqhcrws3000sjv04x8ck4wk4	1	35.00	35.00	\N	cmqhcrws3000qjv04xsvla0uz	cmpqqm4l9000c3xvojqoj1yyt
cmqhcun7e000dkz046qen5wzy	1	35.00	35.00	\N	cmqhcun7e000bkz047jjs8fxf	cmpqqm9eg001i3xvoqq2p0pcl
cmqhd5r8y0003jm04j0aqm1p8	1	35.00	35.00	\N	cmqhd5r8y0001jm04wa7iem68	cmpqqm4l9000c3xvojqoj1yyt
cmqhfuqx50003jo04uu2waoyi	1	35.00	35.00	\N	cmqhfuqx50001jo04t34m0axo	cmpqqm4l9000c3xvojqoj1yyt
cmqhfuqx50007jo04n97ie2y2	1	35.00	35.00	\N	cmqhfuqx50001jo04t34m0axo	cmpqqm9eg001i3xvoqq2p0pcl
cmqhg0ox90003l504u76qifky	1	35.00	35.00	\N	cmqhg0ox90001l504akagt4sa	cmpqqm4l9000c3xvojqoj1yyt
cmqhg1n0u000al504j6i2ucqz	1	40.00	40.00	\N	cmqhg1n0u0008l504pmder52z	cmpqqm45100083xvoo43pm2fa
cmqhg1n0u000el504vqwnbner	1	40.00	40.00	\N	cmqhg1n0u0008l504pmder52z	cmpqqmd4h002g3xvorpy8wab0
cmqhi0sfq0003k0040k8uvg7x	1	35.00	35.00	\N	cmqhi0sfq0001k0045pv79kx8	cmpqqm4l9000c3xvojqoj1yyt
cmqhi0sfq0007k004uj5yu31n	1	35.00	35.00	\N	cmqhi0sfq0001k0045pv79kx8	cmpqqma23001o3xvoooy0q9ws
cmqhl0ww20003lf04v9uond56	1	35.00	35.00	\N	cmqhl0ww20001lf04au52qo3h	cmpqqm8iy001a3xvodugp204w
cmqhm46sw0003l10404ufhmnl	1	40.00	40.00	\N	cmqhm46sw0001l1043tlu5z47	cmprepa050001jp04hcbe0l2v
cmqhm4yl3000al1042fbvcvzf	1	40.00	40.00	\N	cmqhm4yl20008l104rjf45rkt	cmpqqm4t7000e3xvoazlktde5
cmqhmf4g4000hl104h6bdho2a	1	40.00	40.00	\N	cmqhmf4g4000fl1042d92hgmz	cmpqqmc8y00283xvomsuwyqct
cmqhmhit10003l804bpiksvry	1	35.00	35.00	\N	cmqhmhit10001l804unnhg0v9	cmpqqm8iy001a3xvodugp204w
cmqhmhit10007l804w8u5zfjf	1	35.00	35.00	\N	cmqhmhit10001l804unnhg0v9	cmpqqm4l9000c3xvojqoj1yyt
cmqhmpg0q000gl8045kxa29wp	1	40.00	40.00	\N	cmqhmpg0q000el804kdgln2j2	cmprepa050001jp04hcbe0l2v
cmqhmppyq000ml8046idna3qk	1	40.00	40.00	\N	cmqhmppyp000kl8047u7gz2sb	cmprepa050001jp04hcbe0l2v
cmqhn1met000wl804odytc90g	1	35.00	35.00	\N	cmqhn1met000ul804vw7d4u44	cmpqqm4l9000c3xvojqoj1yyt
cmqhn1met0010l804bhh9gbq0	1	35.00	35.00	\N	cmqhn1met000ul804vw7d4u44	cmpqqm8iy001a3xvodugp204w
cmqhn1met0013l804pnsbw9yj	1	40.00	40.00	\N	cmqhn1met000ul804vw7d4u44	cmpqqm45100083xvoo43pm2fa
cmqhn2e8m000rl1047iv1mj0h	1	40.00	40.00	\N	cmqhn2e8m000pl104vfd9b0hv	cmpqqm81900163xvo5msxvp3a
cmqhn2e8m000vl104wgvrdmex	1	40.00	40.00	\N	cmqhn2e8m000pl104vfd9b0hv	cmpqqm81900163xvo5msxvp3a
cmqinyyyb0002jy044nlcxm5w	1	35.00	35.00	\N	cmqinyyyb0000jy040wi1ntt0	cmpqqm4l9000c3xvojqoj1yyt
cmqinyyyb0006jy04zsq3m4au	1	40.00	40.00	\N	cmqinyyyb0000jy040wi1ntt0	cmprepa050001jp04hcbe0l2v
cmqinyyyb000ajy048ane04kh	1	40.00	40.00	\N	cmqinyyyb0000jy040wi1ntt0	cmpqqm4t7000e3xvoazlktde5
cmqinyyyb000ejy04pmrm92ot	1	40.00	40.00	\N	cmqinyyyb0000jy040wi1ntt0	cmprepa050001jp04hcbe0l2v
cmqinyyyb000ijy040s7yx7tf	1	15.00	15.00	\N	cmqinyyyb0000jy040wi1ntt0	cmpzoaia200023xomsj6ohdvb
cmqiov38g0003l404r8ft3yxt	1	35.00	35.00	\N	cmqiov38g0001l404yv6kw1ds	cmpqqm4l9000c3xvojqoj1yyt
cmqiovbkk000al4047o5lyinp	1	40.00	40.00	\N	cmqiovbkk0008l4040pyo6jkb	cmpqqm45100083xvoo43pm2fa
cmqiptf510002l80472h5b34s	1	35.00	35.00	\N	cmqiptf510000l804u5anuxp0	cmpqqm4l9000c3xvojqoj1yyt
cmqipw8mg0002lb04a6cghnat	1	40.00	40.00	\N	cmqipw8mg0000lb04vnkmt0cf	cmpqqm3ot00063xvoeortkzib
cmqipzgaz000blb042r5a1j7q	1	40.00	40.00	\N	cmqipzgaz0009lb04c6nyrs81	cmpqqm81900163xvo5msxvp3a
cmqiqeil8000nlb04xpie7yed	1	35.00	35.00	\N	cmqiqeil8000llb045v88x0od	cmpqqm4l9000c3xvojqoj1yyt
cmqiqib4d0004l1040ky59b8q	1	40.00	40.00	\N	cmqiqib4d0002l10492bxht9b	cmprepa050001jp04hcbe0l2v
cmqiqk5460003l1042y26q3fl	1	25.00	25.00	\N	cmqiqk5460001l10498l06pva	cmq7m4l080001la04q94r0qzv
cmqiqnbci0005l304opgcyop1	1	40.00	40.00	แก้วสีชมพู เอามาเอง	cmqiqnbci0003l304uzkhhsrw	cmpqqm45100083xvoo43pm2fa
cmqiqnt3e000cl304tawt9wdz	1	35.00	35.00	\N	cmqiqnt3e000al304l4t5uwyr	cmpqqm4l9000c3xvojqoj1yyt
cmqiqqkb40009l1041umz5dy3	3	35.00	105.00	\N	cmqiqqkb40007l104em14o87o	cmpqqm4l9000c3xvojqoj1yyt
cmqiqqkb4000dl104lqjnzjnf	1	40.00	40.00	\N	cmqiqqkb40007l104em14o87o	cmprepa050001jp04hcbe0l2v
cmqiqrrhh000kl104a2bxr1br	1	40.00	40.00	\N	cmqiqrrhh000il104y40pq7as	cmpqqm4cx000a3xvo6ij5ksrm
cmqiqu26i000tl104lvia1tbh	1	35.00	35.00	\N	cmqiqu26i000rl104xqjjd24u	cmpqqm8iy001a3xvodugp204w
cmqirk8u6000ql1042hw1m6on	1	35.00	35.00	\N	cmqirk8u6000ol104x2pfp3ws	cmpqqm8iy001a3xvodugp204w
cmqiroem90003l704zb4kb5rh	1	35.00	35.00	\N	cmqiroem80001l7043h65f158	cmpqqm4l9000c3xvojqoj1yyt
cmqirqr8f000al704q67ttuyc	1	40.00	40.00	\N	cmqirqr8f0008l70423fkwlqv	cmpqqm58z000i3xvo7kzkzfoh
cmqiru9k9000hl704p3rlywdr	1	35.00	35.00	\N	cmqiru9k9000fl704p7ac3y2n	cmpqqm9eg001i3xvoqq2p0pcl
cmqirw55o000pl7044tvkk7hj	1	40.00	40.00	\N	cmqirw55o000nl704retl2fui	cmpqqm4t7000e3xvoazlktde5
cmqiryjwp000zl104wl1j7fey	1	30.00	30.00	\N	cmqiryjwp000xl104ol4pmudy	cmpqqm8qt001c3xvom39q1hsv
cmqis77xu001gl704qn0q0d76	1	35.00	35.00	\N	cmqis5j6z000xl7045xd718hq	cmpqqm9eg001i3xvoqq2p0pcl
cmqis77xu001jl704bs0j49ta	1	40.00	40.00	\N	cmqis5j6z000xl7045xd718hq	cmprepa050001jp04hcbe0l2v
cmqis77xu001ml704tttjcotc	1	35.00	35.00	\N	cmqis5j6z000xl7045xd718hq	cmpqqm9eg001i3xvoqq2p0pcl
cmqis77xu001pl704qerneyiw	1	40.00	40.00	\N	cmqis5j6z000xl7045xd718hq	cmpqqm3ot00063xvoeortkzib
cmqisj5tl001vl704ofycywaa	1	40.00	40.00	\N	cmqisj5tl001tl704ttt8nu22	cmpqqm3ot00063xvoeortkzib
cmqiv04280005ji04sw9b5pvp	1	40.00	40.00	\N	cmqiv04280003ji041auq6fff	cmprepa050001jp04hcbe0l2v
cmqiv5xly0003i804zwxgn6i3	1	35.00	35.00	\N	cmqiv5xly0001i8047r3319jk	cmpqqm4l9000c3xvojqoj1yyt
cmqivzsta0003jy04s4o5abqi	1	40.00	40.00	\N	cmqivzsta0001jy049uxzyzh5	cmpqqm3ot00063xvoeortkzib
cmqivzsta0006jy04ezjkh9mv	1	40.00	40.00	\N	cmqivzsta0001jy049uxzyzh5	cmprepa050001jp04hcbe0l2v
cmqiw7z4e0003i204rsgvfqdi	2	35.00	70.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm4l9000c3xvojqoj1yyt
cmqiw7z4e0007i2043f1jge84	1	35.00	35.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm4l9000c3xvojqoj1yyt
cmqiw7z4e000ci204x7zewwtm	1	40.00	40.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm45100083xvoo43pm2fa
cmqiw7z4e000fi2043jzwoj2l	2	35.00	70.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm4l9000c3xvojqoj1yyt
cmqiw7z4f000ji2042ervl7rq	1	35.00	35.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm4l9000c3xvojqoj1yyt
cmqiw7z4f000ni204d9e6x7ta	1	35.00	35.00	\N	cmqiw7z4e0001i204l23d2rgn	cmpqqm9eg001i3xvoqq2p0pcl
cmqiwt0mu0003l704kclys5pd	1	40.00	40.00	\N	cmqiwt0mu0001l704gjw4471l	cmprepa050001jp04hcbe0l2v
cmqiwt0mu0006l704swksstbu	1	15.00	15.00	\N	cmqiwt0mu0001l704gjw4471l	cmpzoaia200023xomsj6ohdvb
cmqiwx8kr000el704yud4mn5o	1	40.00	40.00	\N	cmqiwx8kr000cl704h0x2q4ct	cmpqqm81900163xvo5msxvp3a
cmqiwyfui0003js040iq4ozag	1	40.00	40.00	\N	cmqiwyfui0001js04m2gwqttk	cmpqqm3ot00063xvoeortkzib
cmqixfehj000djs047q6qmjkz	1	15.00	15.00	\N	cmqixfehj000bjs04ldhxm1xy	cmpzoaia200023xomsj6ohdvb
cmqixfehj000ejs04pmctn90q	1	40.00	40.00	\N	cmqixfehj000bjs04ldhxm1xy	cmpqqm58z000i3xvo7kzkzfoh
cmqj03pk40003l504n7wbyfxz	1	40.00	40.00	\N	cmqj03pk30001l5047vd6a30d	cmpqqm81900163xvo5msxvp3a
cmqj03pk40006l504u6bc8syg	1	40.00	40.00	\N	cmqj03pk30001l5047vd6a30d	cmpqqm5gv000k3xvoc025780c
cmqj0sewv0001il04i7yh09xg	1	40.00	40.00	\N	cmqiwxm6u000il704syhxhzzn	cmpqqm45100083xvoo43pm2fa
cmqj0su8e0003la04tyyf3xep	1	25.00	25.00	\N	cmqj0su8e0001la0481ue9a3y	cmq7m4l080001la04q94r0qzv
cmqj0tusn0008il042wp98ufo	1	40.00	40.00	\N	cmqj0tusn0006il049hk3esr5	cmpqqmcoq002c3xvolsroh00b
cmqj126pd0009la04wsx99sxt	1	30.00	30.00	\N	cmqj126pc0007la04a23oh02r	cmpqqme85002o3xvonvhpgw36
cmqj1bzri0003la04yqco8exj	1	35.00	35.00	\N	cmqj1bzrh0001la0444utd79h	cmpqqm8iy001a3xvodugp204w
cmqj1bzri0007la04a9hz35qy	1	35.00	35.00	\N	cmqj1bzrh0001la0444utd79h	cmpqqm8iy001a3xvodugp204w
cmqj1s5wz0003jy04xp6841zj	1	35.00	35.00	\N	cmqj1s5wy0001jy04yr0qqenu	cmpqqma9x001q3xvo0d6239vc
cmqj5utke0003jy04lxex9pob	1	40.00	40.00	\N	cmqj5utke0001jy04vhutjbqs	cmpqqm4cx000a3xvo6ij5ksrm
cmqj5va36000cjy04mm8fs5u3	2	35.00	70.00	\N	cmqj5va36000ajy04b0dxhee5	cmpqqm4l9000c3xvojqoj1yyt
cmqk4r47y0002ky04ihb28c19	1	40.00	40.00	\N	cmqk4r47y0000ky045yngfa64	cmpqqm4t7000e3xvoazlktde5
cmqk4r47z0006ky04nvogictz	1	40.00	40.00	\N	cmqk4r47y0000ky045yngfa64	cmpqqm3ot00063xvoeortkzib
cmqk4r47z0009ky0483g2ti3t	1	35.00	35.00	\N	cmqk4r47y0000ky045yngfa64	cmpqqm4l9000c3xvojqoj1yyt
cmqk4r47z000dky04lzvriu8b	2	15.00	30.00	\N	cmqk4r47y0000ky045yngfa64	cmpzoaia200023xomsj6ohdvb
cmqk4r47z000eky04q7daqqdt	1	30.00	30.00	\N	cmqk4r47y0000ky045yngfa64	cmpqqm6v9000w3xvoupr8eicc
cmqk4rtrq000nky04i365xde7	1	40.00	40.00	M	cmqk4rtrq000lky04lie0o6f0	cmpqqm45100083xvoo43pm2fa
cmqk5ltex0005jo04cbulcggd	1	40.00	40.00	\N	cmqk5ltex0003jo04135i4al5	cmpqqm5oq000m3xvo7hnkpo73
cmqk5ltex0009jo04xdwfx0vz	2	35.00	70.00	\N	cmqk5ltex0003jo04135i4al5	cmpqqm4l9000c3xvojqoj1yyt
cmqk5qumb0002l204e8q6dt41	1	40.00	40.00	\N	cmqk5qumb0000l204186dfqh5	cmpqqm3ot00063xvoeortkzib
cmqk5tdqv000gjo046qx2wush	1	35.00	35.00	\N	cmqk5tdqv000ejo0474h2oyq9	cmpqqm4l9000c3xvojqoj1yyt
cmqk5u11m000njo04rfx46qzq	1	35.00	35.00	\N	cmqk5u11m000ljo042uukqrg3	cmpqqm4l9000c3xvojqoj1yyt
cmqk5z6j50003jp04sxw0nq33	1	35.00	35.00	\N	cmqk5z6j50001jp04jhh9x4i9	cmpqqm9eg001i3xvoqq2p0pcl
cmqk63hot0009jp047rhw2dgz	1	40.00	40.00	\N	cmqk63hot0007jp047fvjcp3h	cmpqqm5oq000m3xvo7hnkpo73
cmqk63hou000djp04z89o7dej	1	40.00	40.00	\N	cmqk63hot0007jp047fvjcp3h	cmpqqm3ot00063xvoeortkzib
cmqk649d9000jjp044fsmqfs8	1	40.00	40.00	\N	cmqk649d9000hjp044yyvw8g0	cmpqqm4t7000e3xvoazlktde5
cmqk65vn80003l7045zxdhv6x	1	40.00	40.00	\N	cmqk65vn70001l7044hrqft2i	cmpqqm4cx000a3xvo6ij5ksrm
cmqk68npo0003k404s9t5dmtq	1	30.00	30.00	\N	cmqk68npo0001k404smn23y5s	cmpqqm8qt001c3xvom39q1hsv
cmqk6blov0002la04czivg6nm	2	35.00	70.00	\N	cmqk6blov0000la04xzyiq4e3	cmpqqm4l9000c3xvojqoj1yyt
cmqk6cn84000cla0452zyn0ah	1	40.00	40.00	\N	cmqk6cn84000ala04yst74y29	cmpqqmd4h002g3xvorpy8wab0
cmqk6ntea000nla04ttvyw250	1	40.00	40.00	\N	cmqk6ntea000lla04nuqff2gf	cmpqqm81900163xvo5msxvp3a
cmqk6pmav000ula049vsk7vn5	1	40.00	40.00	\N	cmqk6pmav000sla04r5z9ytfb	cmpqqm65m000q3xvow1n8n4d2
cmqk6pw5a0010la04g97ri84s	1	35.00	35.00	\N	cmqk6pw5a000yla04y205hndb	cmpqqm9eg001i3xvoqq2p0pcl
cmqk6ww8h001cla048nn7opd6	1	35.00	35.00	\N	cmqk6ww8h001ala049xsqdm23	cmpqqmc1300263xvodgeiz5il
cmqk6ww8h001fla04ckuvi5fo	1	40.00	40.00	\N	cmqk6ww8h001ala049xsqdm23	cmpqqm4t7000e3xvoazlktde5
cmqk6ww8h001jla049c6ko161	1	40.00	40.00	\N	cmqk6ww8h001ala049xsqdm23	cmpqqmd4h002g3xvorpy8wab0
cmqk734is0005l404u1sjqr80	1	35.00	35.00	\N	cmqk734is0003l404y4ybjmxu	cmpqqm4l9000c3xvojqoj1yyt
cmqk784u8001rla04juocc47l	1	40.00	40.00	\N	cmqk784u8001pla04004y7d93	cmprepa050001jp04hcbe0l2v
cmqk7o75v0022la04fjx6lvh9	1	40.00	40.00	\N	cmqk7o75v0020la049bqkxy9p	cmprepa050001jp04hcbe0l2v
cmqk7u1m90003le0481z7wrfv	1	35.00	35.00	\N	cmqk7u1m90001le04e559f8rg	cmpqqm4l9000c3xvojqoj1yyt
cmqkao9rg0003ji04p548ue0a	3	35.00	105.00	\N	cmqkao9rg0001ji0433je8ff8	cmpqqm4l9000c3xvojqoj1yyt
cmqkao9rg0007ji04elew8qzk	1	40.00	40.00	\N	cmqkao9rg0001ji0433je8ff8	cmprepa050001jp04hcbe0l2v
cmqkbe5pn0003jl04hra3nsx8	1	35.00	35.00	\N	cmqkbe5pn0001jl04qxal8mnz	cmpqqm4l9000c3xvojqoj1yyt
cmqkbe5pn0007jl04xdu7la69	1	35.00	35.00	\N	cmqkbe5pn0001jl04qxal8mnz	cmpqqm4l9000c3xvojqoj1yyt
cmqkbflu4000gjl04l6a07qko	1	40.00	40.00	\N	cmqkbflu4000ejl04zutao2ay	cmpqqm45100083xvoo43pm2fa
cmqkbflu4000kjl043wwelkgv	1	30.00	30.00	\N	cmqkbflu4000ejl04zutao2ay	cmpqqm6v9000w3xvoupr8eicc
cmqkbflu4000njl04y50uh4jk	1	35.00	35.00	\N	cmqkbflu4000ejl04zutao2ay	cmpqqm4l9000c3xvojqoj1yyt
cmqkc1g6a0003jv04ipatrxae	1	40.00	40.00	\N	cmqkc1g6a0001jv04qojswdj3	cmpqqmcwl002e3xvoh9uib930
cmqkc1g6a0006jv040uo2kzww	1	45.00	45.00	\N	cmqkc1g6a0001jv04qojswdj3	cmpqqmbdf00203xvoi39rfzmh
cmqkcrmxg0003jr04fg1kjclt	1	35.00	35.00	\N	cmqkcrmxf0001jr04wp3pyspw	cmpqqm4l9000c3xvojqoj1yyt
cmqkdsmbl0003jl04dj9lq8wo	1	35.00	35.00	\N	cmqkdsmbl0001jl04d2b9ejgd	cmpqqm4l9000c3xvojqoj1yyt
cmqkdzuo0000ajl041y4io2p3	1	40.00	40.00	\N	cmqkdzuo00008jl04l179jb78	cmpqqm3ot00063xvoeortkzib
cmqkek0jl0003lb049yek3178	1	40.00	40.00	\N	cmqkek0jl0001lb04443twlx5	cmpqqm65m000q3xvow1n8n4d2
cmqkfxl2s0003jo04d02s5d1g	1	40.00	40.00	\N	cmqkfxl2s0001jo04hs16xxrf	cmpqqmcoq002c3xvolsroh00b
cmqkfxl2s0006jo04l5zed3ox	1	25.00	25.00	\N	cmqkfxl2s0001jo04hs16xxrf	cmq7m4l080001la04q94r0qzv
cmqkfxl2s0007jo04ixg8i0qv	1	30.00	30.00	\N	cmqkfxl2s0001jo04hs16xxrf	cmpqqme85002o3xvonvhpgw36
cmqljgn1c0002l204vpthsf64	1	35.00	35.00	\N	cmqljgn1b0000l204wpqepccy	cmpqqm4l9000c3xvojqoj1yyt
cmqljgn1c0006l204qkicyzu0	1	35.00	35.00	\N	cmqljgn1b0000l204wpqepccy	cmpqqm4l9000c3xvojqoj1yyt
cmqljgn1c000al204up0tc0s4	1	40.00	40.00	\N	cmqljgn1b0000l204wpqepccy	cmpqqm4t7000e3xvoazlktde5
cmqljgn1c000el204t0sv6gfb	1	40.00	40.00	\N	cmqljgn1b0000l204wpqepccy	cmprepa050001jp04hcbe0l2v
cmqljgn1c000il204oa1i0qno	1	40.00	40.00	\N	cmqljgn1b0000l204wpqepccy	cmpqqm81900163xvo5msxvp3a
cmqljgn1c000ml204cfb87vd3	2	15.00	30.00	\N	cmqljgn1b0000l204wpqepccy	cmpzoaia200023xomsj6ohdvb
cmqljrnd5000tl204axfqmdgc	1	40.00	40.00	\N	cmqljrnd5000rl204061ohjkh	cmprepa050001jp04hcbe0l2v
cmqlk4vhi0002l304w4yu0rps	1	35.00	35.00	\N	cmqlk4vhi0000l304nax96eh9	cmpqqm4l9000c3xvojqoj1yyt
cmqlk4vhi0007l304sxhsmp5z	3	35.00	105.00	\N	cmqlk4vhi0000l304nax96eh9	cmpqqm4l9000c3xvojqoj1yyt
cmqlk4vhi000cl304r59lswsk	1	35.00	35.00	\N	cmqlk4vhi0000l304nax96eh9	cmpqqm4l9000c3xvojqoj1yyt
cmqlkrcmk0005js04dfzgt97e	1	40.00	40.00	\N	cmqlkrcmk0003js04txy6rzgn	cmpqqm45100083xvoo43pm2fa
cmqlksw6u000cjs049khfras9	2	40.00	80.00	\N	cmqlksw6u000ajs04imakf3oj	cmpqqm5oq000m3xvo7hnkpo73
cmqlksw6u000gjs04n1xtsmrs	1	35.00	35.00	\N	cmqlksw6u000ajs04imakf3oj	cmpqqm4l9000c3xvojqoj1yyt
cmqlktqce0003l4049y56tlze	1	35.00	35.00	\N	cmqlktqce0001l404m7zaa1do	cmpqqm4l9000c3xvojqoj1yyt
cmqlkxlik000njs0400wa5clf	1	40.00	40.00	\N	cmqlkxlik000ljs04rzxyq8u5	cmprepa050001jp04hcbe0l2v
cmqllcz5c0014js041lvbpr5m	1	40.00	40.00	\N	cmqllbybm000yjs04cz9jyxcl	cmpqqm3ot00063xvoeortkzib
cmqllcz5c0017js044cko4dgs	1	35.00	35.00	\N	cmqllbybm000yjs04cz9jyxcl	cmpqqm4l9000c3xvojqoj1yyt
cmqlllkbn001gjs04456qodb3	1	40.00	40.00	\N	cmqlllkbn001ejs04g41s95fm	cmpqqm45100083xvoo43pm2fa
cmqllo09h001ljs04sfr2o6kk	1	50.00	50.00	\N	cmqlllstk000el404mz6raner	cmpqqm4cx000a3xvo6ij5ksrm
cmqlloogx001sjs0492wy08ln	1	35.00	35.00	\N	cmqlloogx001qjs04kgxwn7kt	cmpqqm9eg001i3xvoqq2p0pcl
cmqllpdsf000nl404h9sn7738	1	35.00	35.00	\N	cmqllpdsf000ll404ayzm7yti	cmpqqma23001o3xvoooy0q9ws
cmqllptqx000tl404ndmgde3g	1	35.00	35.00	\N	cmqllptqx000rl404wdf3dtc8	cmpqqm9eg001i3xvoqq2p0pcl
cmqllq1ui0024js04aaqscchd	1	35.00	35.00	\N	cmqllq1ui0022js04iyts2h0u	cmpqqm4l9000c3xvojqoj1yyt
cmqllr38q0013l404msl9iind	1	35.00	35.00	\N	cmqllr38q0011l404xgn72ro6	cmpqqmc1300263xvodgeiz5il
cmqlltt0i0019l404uxzs3x4p	1	40.00	40.00	\N	cmqlltt0i0017l404fw8cs4s6	cmpqqm3ot00063xvoeortkzib
cmqllzdgh002bjs049a7zgb1u	1	35.00	35.00	\N	cmqllzdgh0029js04lp4nkczf	cmpqqm8iy001a3xvodugp204w
cmqlma3hg0003l504ws6xmz87	1	40.00	40.00	\N	cmqlma3hg0001l504mrf8zkxj	cmpqqm45100083xvoo43pm2fa
cmqlmbdat000bl5048qz97jcf	1	40.00	40.00	\N	cmqlmbdat0009l504qxa4xp32	cmpqqm5gv000k3xvoc025780c
cmqlmd8vp001nl404vwd0nvzt	1	35.00	35.00	\N	cmqlmd8vp001ll4044an4g0a7	cmpqqm9eg001i3xvoqq2p0pcl
cmqlmfqg7001tl404bgs6e5gx	1	35.00	35.00	น้ำแข็งครึ่งเดียว	cmqlmfqg7001rl4041embhu79	cmpqqm4l9000c3xvojqoj1yyt
cmqlmh9vv0020l4042rhsub2y	1	40.00	40.00	\N	cmqlmh9vv001yl404ao7exfp5	cmprepa050001jp04hcbe0l2v
cmqlmkzfk000njy04gj5dqf0o	1	35.00	35.00	\N	cmqlmkzfk000ljy04jswpjv5w	cmpqqm4l9000c3xvojqoj1yyt
cmqlmmlg80001l704rkm0oo33	1	35.00	35.00	\N	cmqlmk6yg000djy04v7w2x586	cmpqqm4l9000c3xvojqoj1yyt
cmqlmpczi000xjy040y4arieg	1	35.00	35.00	\N	cmqlmpczi000vjy04btf659c1	cmpqqm8iy001a3xvodugp204w
cmqlmqxpb0024l40435d8awt1	1	40.00	40.00	\N	cmqlmnpjf0008l704v0y6g8ya	cmpqqm4t7000e3xvoazlktde5
cmqlmqxpb0028l40484kueme3	1	40.00	40.00	\N	cmqlmnpjf0008l704v0y6g8ya	cmpqqmd4h002g3xvorpy8wab0
cmqlmzkq5000ll504nykztz1d	1	35.00	35.00	\N	cmqlmzkq5000jl5045tt9gmzs	cmpqqm4l9000c3xvojqoj1yyt
cmqlmzkq5000pl504ymd2gcwo	1	35.00	35.00	\N	cmqlmzkq5000jl5045tt9gmzs	cmpqqm9eg001i3xvoqq2p0pcl
cmqln2msy000zl5041kzqknhn	2	40.00	80.00	\N	cmqln2msy000xl504qji5b2aa	cmprepa050001jp04hcbe0l2v
cmqlnazqr0003je04wx2d800i	1	40.00	40.00	\N	cmqlnazqq0001je0455o8160w	cmprepa050001jp04hcbe0l2v
cmqlqa33v0003l7044a928rgi	1	35.00	35.00	\N	cmqlqa33v0001l704mrm0pdq6	cmpqqm9eg001i3xvoqq2p0pcl
cmqlqajdd000cl704dkh3b1bp	2	40.00	80.00	\N	cmqlqajdd000al704f5cejavb	cmprepa050001jp04hcbe0l2v
cmqlr5cd5000al704dyj1x7je	3	40.00	120.00	\N	cmqlr5cd50008l704v24do9vx	cmpqqm81900163xvo5msxvp3a
cmqlr6idy0001jm041zzcuczl	1	40.00	40.00	โซดา	cmqlr53u10001l7046hn9q7as	cmpqqm5oq000m3xvo7hnkpo73
cmqlrm6bc000ejp04ffmhm4fe	1	45.00	45.00	\N	cmqlrm6bc000cjp04xw7q5r21	cmpqqmbdf00203xvoi39rfzmh
cmqlrngve0001jx04y5jotj9m	1	40.00	40.00	\N	cmqlrkr5u0003jp04njzr6765	cmpqqm81900163xvo5msxvp3a
cmqls3v660008jx0422n70b57	1	40.00	40.00	\N	cmqls3v660006jx04be0ce1wz	cmprepa050001jp04hcbe0l2v
cmqlskn6o0003l70468zobgxr	1	35.00	35.00	\N	cmqlskn6o0001l7049kx5in70	cmpqqm4l9000c3xvojqoj1yyt
cmqlsth530008l20428kz7bzo	1	35.00	35.00	\N	cmqlsqlah0001l204izsehe9e	cmpqqm4l9000c3xvojqoj1yyt
cmqlsth53000cl204dnawxq6d	1	15.00	15.00	\N	cmqlsqlah0001l204izsehe9e	cmpzoaia200023xomsj6ohdvb
cmqlvchv00003l304vs1qmwv9	1	40.00	40.00	\N	cmqlvchuz0001l304uwqggsl4	cmpqqm4t7000e3xvoazlktde5
cmqlvd2iz000al30475faj2pr	1	30.00	30.00	\N	cmqlvd2iz0008l304142slk83	cmpqqme85002o3xvonvhpgw36
cmqlx9uh00003lb04br12hky1	2	40.00	80.00	\N	cmqlx9uh00001lb04xia4qo6m	cmpqqm4t7000e3xvoazlktde5
cmqlxaajc000clb041fco1j31	1	35.00	35.00	\N	cmqlxaajb000alb04jmtsr1eq	cmpqqm4l9000c3xvojqoj1yyt
cmqlxaajc000glb04aymo48y9	1	35.00	35.00	\N	cmqlxaajb000alb04jmtsr1eq	cmpqqm4l9000c3xvojqoj1yyt
cmqlxrvkn0003jo04c7ztk92i	1	40.00	40.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqmd4h002g3xvorpy8wab0
cmqlxrvkn0006jo04ofxd5imh	1	35.00	35.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqm4l9000c3xvojqoj1yyt
cmqlxrvkn000ajo04a3u41x1o	1	35.00	35.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqm4l9000c3xvojqoj1yyt
cmqlxrvkn000ejo04q9nz2j66	1	35.00	35.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqm8iy001a3xvodugp204w
cmqlxrvkn000ijo04tgp4t65s	1	40.00	40.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqmd4h002g3xvorpy8wab0
cmqlxrvkn000ljo04u0fwgwxs	1	40.00	40.00	\N	cmqlxrvkm0001jo04fnbli9ip	cmpqqmcgu002a3xvog83kbby5
cmqlyzdpf0003jv047un3bnbg	2	35.00	70.00	\N	cmqlyzdpf0001jv04v7hjs9no	cmpqqm4l9000c3xvojqoj1yyt
cmqlz8ese000cjv04hr5pqlao	1	40.00	40.00	\N	cmqlz8ese000ajv041dx8txqz	cmpqqm81900163xvo5msxvp3a
cmqlz8voc000ljv04q2azelc2	1	35.00	35.00	\N	cmqlz8voc000jjv045dts0ltq	cmpqqm9eg001i3xvoqq2p0pcl
cmqm1ht720003l104l8j241r7	1	35.00	35.00	\N	cmqm1ht720001l1046r3atqhc	cmpqqm4l9000c3xvojqoj1yyt
cmqm1i687000cl104fep5cana	1	40.00	40.00	\N	cmqm1i687000al1047oehbwrs	cmprepa050001jp04hcbe0l2v
cmqof8n1e0002l404pgeu3eq7	1	35.00	35.00	\N	cmqof8n1e0000l404yvrkazxb	cmpqqm4l9000c3xvojqoj1yyt
cmqofkfiy0007jr049z37yis6	1	40.00	40.00	\N	cmqofkfiy0005jr04y7tki1tl	cmpqqmd4h002g3xvorpy8wab0
cmqoflmyx000ejr04w86vut9e	1	35.00	35.00	\N	cmqoflmyx000cjr04qwjjjbtc	cmpqqm4l9000c3xvojqoj1yyt
cmqofxpsj0002l20492oguwbc	1	35.00	35.00	\N	cmqofxpsi0000l204o4q86h6l	cmpqqm4l9000c3xvojqoj1yyt
cmqofz20u0003jy04jqluw1rk	1	40.00	40.00	\N	cmqofz20t0001jy048fbnyvdu	cmprepa050001jp04hcbe0l2v
cmqofz20u0007jy04rmrzewla	1	35.00	35.00	\N	cmqofz20t0001jy048fbnyvdu	cmpqqm9eg001i3xvoqq2p0pcl
cmqofzkj6000ejy041vkfgaij	1	35.00	35.00	\N	cmqofzkj6000cjy04n6lf0g6x	cmpqqm9eg001i3xvoqq2p0pcl
cmqog4lo2000dl204fqf1iy1q	1	35.00	35.00	\N	cmqog4lo2000bl204n6c5okmt	cmpqqm4l9000c3xvojqoj1yyt
cmqog63yh000ojy04m2feqwa0	1	25.00	25.00	\N	cmqog63yh000mjy0440mtmjew	cmq7m4l080001la04q94r0qzv
cmqog7a1v000ujy04jdam7z21	1	35.00	35.00	\N	cmqog7a1v000sjy04yaeoek4e	cmpqqm4l9000c3xvojqoj1yyt
cmqogat78000ml204ec7v1wd4	1	40.00	40.00	\N	cmqogat78000kl204q4qf57of	cmpqqm3ot00063xvoeortkzib
cmqogb5rr000sl204925iqzu2	1	35.00	35.00	\N	cmqogb5rr000ql204h3j0fjol	cmpqqm9eg001i3xvoqq2p0pcl
cmqoggnri0011jy04tnu4xbyx	1	40.00	40.00	\N	cmqoggnri000zjy04nj5dejd1	cmpqqm4cx000a3xvo6ij5ksrm
cmqogh0g60018jy0492e21fsv	1	40.00	40.00	แก้วชมพู	cmqogh0g60016jy04t0bj25e1	cmpqqm45100083xvoo43pm2fa
cmqoghbpx0014l2042y8ct2v9	1	35.00	35.00	\N	cmqoghbpx0012l204zyk8ltaf	cmpqqm8iy001a3xvodugp204w
cmqogndw1001fjy04xq9c04cl	1	40.00	40.00	\N	cmqogndw1001djy04yqcoys6l	cmpqqm81900163xvo5msxvp3a
cmqogqhau001cl204mnxj9mrn	1	40.00	40.00	\N	cmqogqhau001al204d663z4pj	cmpqqm81900163xvo5msxvp3a
cmqoh0zo4001nl204bxq9146y	1	35.00	35.00	\N	cmqoh0zo3001ll204rmq12c9o	cmpqqm4l9000c3xvojqoj1yyt
cmqoh0zo4001rl204f2rbi2a5	1	35.00	35.00	\N	cmqoh0zo3001ll204rmq12c9o	cmpqqm4l9000c3xvojqoj1yyt
cmqoh0zo4001vl204vt55w56v	2	35.00	70.00	\N	cmqoh0zo3001ll204rmq12c9o	cmpqqm4l9000c3xvojqoj1yyt
cmqoh4aav0021l204m7n0eax9	1	35.00	35.00	\N	cmqoh4aau001zl204bxm2k34i	cmpqqma9x001q3xvo0d6239vc
cmqoh5bly0002l504l2nhjn79	1	40.00	40.00	\N	cmqoh5bly0000l5046a55usxi	cmprepa050001jp04hcbe0l2v
cmqoh9e6r001ojy04z6u0usvz	1	30.00	30.00	\N	cmqoh9e6r001mjy04267dacda	cmpu4u2520001l4045ganc8z4
cmqohj8mt002bl2046yj9kbla	1	35.00	35.00	\N	cmqohj8mt0029l204hlyx39l6	cmpqqm9eg001i3xvoqq2p0pcl
cmqohlvah002hl204tda1hqp7	1	40.00	40.00	\N	cmqohlvah002fl204ey5e0j21	cmpqqm4cx000a3xvo6ij5ksrm
cmqohpljt002ul2042ni9mkjj	1	15.00	15.00	\N	cmqohpljt002sl204orki3yvl	cmpzoaia200023xomsj6ohdvb
cmqohs761001yjy04z9wt4iu3	1	35.00	35.00	\N	cmqohs760001wjy04vsk1snbi	cmpqqm9eg001i3xvoqq2p0pcl
cmqohs7610021jy04rop1yao6	1	40.00	40.00	\N	cmqohs760001wjy04vsk1snbi	cmprepa050001jp04hcbe0l2v
cmqohsaa30027jy04otgy3xfy	1	35.00	35.00	\N	cmqohsaa30025jy04l3wz4gim	cmpqqm4l9000c3xvojqoj1yyt
cmqohu9cz0032l204l6yfyc4e	1	35.00	35.00	\N	cmqohu9cz0030l2047mqn7fis	cmpqqm4l9000c3xvojqoj1yyt
cmqohzq2c002ejy04tw1edbnl	1	40.00	40.00	\N	cmqohzq2b002cjy0435747mm8	cmprepa050001jp04hcbe0l2v
cmqoi2yrw003hl204duto3tvd	1	35.00	35.00	\N	cmqoi2yrw003fl20417yfow9f	cmpqqm4l9000c3xvojqoj1yyt
cmqoi6ryr002njy046j8vw5lz	1	35.00	35.00	\N	cmqoi6ryr002ljy04ci4r4ndp	cmpqqm4l9000c3xvojqoj1yyt
cmqoi6xvk002ujy04c9i4w4f3	1	40.00	40.00	\N	cmqoi6xvk002sjy04vutzsk5d	cmpqqm3ot00063xvoeortkzib
cmqoiau65003ql204w95sya5o	1	40.00	40.00	\N	cmqoiau65003ol204abxoqu0b	cmprepa050001jp04hcbe0l2v
cmqoiau65003tl2041c4l3kf1	1	40.00	40.00	\N	cmqoiau65003ol204abxoqu0b	cmpqqm4t7000e3xvoazlktde5
cmqolg4s80003ju040c72nafz	1	40.00	40.00	\N	cmqolg4s80001ju04xew4vlfq	cmprepa050001jp04hcbe0l2v
cmqolg4s80007ju045008zlr9	1	35.00	35.00	\N	cmqolg4s80001ju04xew4vlfq	cmpqqm4l9000c3xvojqoj1yyt
cmqolg4s8000bju045ttmwzef	1	40.00	40.00	\N	cmqolg4s80001ju04xew4vlfq	cmprepa050001jp04hcbe0l2v
cmqolni4u000kju04sv2auj8z	1	35.00	35.00	\N	cmqolni4u000iju04sh9c0wks	cmpqqm4l9000c3xvojqoj1yyt
cmqolni4u000oju04timqzfvb	1	40.00	40.00	\N	cmqolni4u000iju04sh9c0wks	cmpqqm45100083xvoo43pm2fa
cmqolqeql0003jv044i2s22s2	1	40.00	40.00	\N	cmqolqeql0001jv04i2g58uta	cmpqqm81900163xvo5msxvp3a
cmqomfj1z0003ji047zyngy6j	1	40.00	40.00	\N	cmqomfj1z0001ji041ryp1r64	cmpqqm3ot00063xvoeortkzib
cmqomg06u0009ji04ivzij5uc	1	40.00	40.00	\N	cmqomg06t0007ji04rq39l2eg	cmpqqm4t7000e3xvoazlktde5
cmqomppaf0005jo04j21r96gl	1	30.00	30.00	\N	cmqomppaf0003jo04xxxmdwn1	cmpqqme85002o3xvonvhpgw36
cmqomppaf0008jo04i6chwdht	1	25.00	25.00	\N	cmqomppaf0003jo04xxxmdwn1	cmq7m4l080001la04q94r0qzv
cmqomqyni0003l7045bpmb4ni	1	40.00	40.00	\N	cmqomqynh0001l704v0zp96ua	cmpqqm81900163xvo5msxvp3a
cmqomvxq70004jo047lrzqa6u	1	35.00	35.00	\N	cmqomvxq70002jo04rzjxbh57	cmpqqm4l9000c3xvojqoj1yyt
cmqomwyo5000bjo04pjr7ji82	1	35.00	35.00	\N	cmqomwyo50009jo0428s49uio	cmpqqm4l9000c3xvojqoj1yyt
cmqomwyo5000fjo0459k41ktl	1	40.00	40.00	\N	cmqomwyo50009jo0428s49uio	cmprepa050001jp04hcbe0l2v
cmqonxvbd0001k004ix8ov7kw	1	40.00	40.00	\N	cmqonqhbv0001k004evqx7jfj	cmpqqm3ot00063xvoeortkzib
cmqonxvbd0004k004frxe3fhu	1	40.00	40.00	ใส่มะพร้าว	cmqonqhbv0001k004evqx7jfj	cmprepa050001jp04hcbe0l2v
cmqopb9bl0003l404ryws78t9	1	35.00	35.00	\N	cmqopb9bl0001l404c5s0v1dz	cmpqqm4l9000c3xvojqoj1yyt
cmqopvfwu0003jr04a88hbqy8	1	35.00	35.00	\N	cmqopvfwu0001jr041i76bvga	cmpqqm4l9000c3xvojqoj1yyt
cmqoq28to000ejr04nrogt1yp	1	15.00	15.00	\N	cmqoq28to000cjr040bs22qec	cmpzoaia200023xomsj6ohdvb
cmqoqdbyr0003l104hu9g1iwn	1	35.00	35.00	\N	cmqoqdbyr0001l104u1b9bkrs	cmpqqma9x001q3xvo0d6239vc
cmqoqjxkv0003lg04me9s9rwd	1	40.00	40.00	\N	cmqoqjxkv0001lg04c2el3icb	cmpqqm3ot00063xvoeortkzib
cmqoqjxkv0006lg04383gzjds	1	40.00	40.00	\N	cmqoqjxkv0001lg04c2el3icb	cmpqqm513000g3xvo0iex8rrm
cmqorsvzv000elg045sdv0ohu	1	35.00	35.00	\N	cmqorr72l0001lg04ldt89q5n	cmpqqm8iy001a3xvodugp204w
cmqorsvzv000ilg043arioyyp	3	35.00	105.00	\N	cmqorr72l0001lg04ldt89q5n	cmpqqm4l9000c3xvojqoj1yyt
cmqorsvzv000mlg049xvq0ast	1	40.00	40.00	\N	cmqorr72l0001lg04ldt89q5n	cmprepa050001jp04hcbe0l2v
cmqorun5b0003k0045ye6qtao	1	35.00	35.00	\N	cmqorun5b0001k004d83itutj	cmpqqm8iy001a3xvodugp204w
cmqorun5b0006k004g3ibcudp	1	40.00	40.00	\N	cmqorun5b0001k004d83itutj	cmpqqmd4h002g3xvorpy8wab0
cmqos3npl000ek004aktqdw5o	1	40.00	40.00	25%	cmqos3npl000ck004y1e0ddp5	cmpqqm45100083xvoo43pm2fa
cmqoszbez0003kz04xjn2rb4c	1	35.00	35.00	\N	cmqoszbez0001kz04ysa1fr2a	cmpqqm9eg001i3xvoqq2p0pcl
cmqou0n820003la0423jdz1du	1	40.00	40.00	\N	cmqou0n820001la04ny6328bl	cmprepa050001jp04hcbe0l2v
cmqou6iwd0003jf049i5oyf11	1	35.00	35.00	\N	cmqou6iwc0001jf04zssojjyx	cmpqqm4l9000c3xvojqoj1yyt
cmqou89t0000ajf04eqnx331t	1	45.00	45.00	\N	cmqou89t00008jf049xa3w7my	cmpqqmblb00223xvok0kay89v
cmqpui11v0003lb0455oa5qr1	1	40.00	40.00	\N	cmqpui11v0001lb042itx3wrc	cmprepa050001jp04hcbe0l2v
cmqpuz63t000alb04jf549qju	1	35.00	35.00	\N	cmqpuz63t0008lb04i34g40d0	cmpqqm4l9000c3xvojqoj1yyt
cmqpuz63t000elb04oh5ikipq	1	40.00	40.00	\N	cmqpuz63t0008lb04i34g40d0	cmpqqm5oq000m3xvo7hnkpo73
cmqpv35yh0002kz048qx15akt	1	35.00	35.00	\N	cmqpv35yh0000kz04dyg19g6x	cmpqqm4l9000c3xvojqoj1yyt
cmqpv35yi0006kz048lted6sy	1	35.00	35.00	\N	cmqpv35yh0000kz04dyg19g6x	cmpqqm4l9000c3xvojqoj1yyt
cmqpv35yi000akz04waqz628o	1	35.00	35.00	\N	cmqpv35yh0000kz04dyg19g6x	cmpqqma23001o3xvoooy0q9ws
cmqpv35yi000ekz04tl74b34u	1	15.00	15.00	\N	cmqpv35yh0000kz04dyg19g6x	cmpzoaia200023xomsj6ohdvb
cmqpvj6ag0003kt04k4wziuez	1	35.00	35.00	\N	cmqpvj6ag0001kt04ess4ns7y	cmpqqm4l9000c3xvojqoj1yyt
cmqpvkgac000akt04j8858tt1	1	35.00	35.00	\N	cmqpvkgac0008kt04lj54abc5	cmpqqm9eg001i3xvoqq2p0pcl
cmqpvrsq60002kz04u7q838cg	1	35.00	35.00	\N	cmqpvrsq50000kz04fyrrw3hs	cmpqqm4l9000c3xvojqoj1yyt
cmqpw0j0b000bjl045sffln92	1	35.00	35.00	\N	cmqpvzyb10001jl04u6v8knih	cmpqqm4l9000c3xvojqoj1yyt
cmqpw0j0b000fjl04tbaqtrue	1	40.00	40.00	\N	cmqpvzyb10001jl04u6v8knih	cmpqqm3ot00063xvoeortkzib
cmqpw1p81000ljl04zwokviij	1	40.00	40.00	\N	cmqpw1p81000jjl04dxfxynlc	cmpqqm4cx000a3xvo6ij5ksrm
cmqpwcagz0003ld04wkvx7ik5	1	35.00	35.00	\N	cmqpwcagy0001ld04byj18eym	cmpqqm4l9000c3xvojqoj1yyt
cmqpwcq4d000ald04zzvhmt5a	1	40.00	40.00	\N	cmqpwcq4d0008ld04fmhsibir	cmpqqmd4h002g3xvorpy8wab0
cmqpwertx000jld0465hj0qvt	1	35.00	35.00	\N	cmqpwertx000hld0461x1ia2y	cmpqqma23001o3xvoooy0q9ws
cmqpwertx000nld04ptu7j89g	1	15.00	15.00	\N	cmqpwertx000hld0461x1ia2y	cmpzoaia200023xomsj6ohdvb
cmqpwertx000old04vp69k1vw	2	5.00	10.00	\N	cmqpwertx000hld0461x1ia2y	cmq7m69sc0003la04fmysvt29
cmqpwgjw20003jf04m9xbuw6b	1	45.00	45.00	\N	cmqpwgjw10001jf04ip51wtse	cmpqqmdk7002k3xvoo1d970sf
cmqpwq1rp0003jx044ddfeeq1	1	30.00	30.00	\N	cmqpwq1ro0001jx040h72icfv	cmpu4u2520001l4045ganc8z4
cmqpww1ap0009jf04tike10wg	2	40.00	80.00	\N	cmqpwtjhy0007jx043jjhxb7j	cmpqqm4t7000e3xvoazlktde5
cmqpx6f0b000jjx04s72etnko	1	40.00	40.00	\N	cmqpx6f0a000hjx04lti7mpac	cmpqqm3ot00063xvoeortkzib
cmqpxbqpu000kjf04l56vk1jl	1	40.00	40.00	\N	cmqpxbqpu000ijf043m6gjulk	cmprepa050001jp04hcbe0l2v
cmqpxfghs000xjf042p5pn1x1	1	35.00	35.00	\N	cmqpxfghr000vjf044dofdcuv	cmpqqm4l9000c3xvojqoj1yyt
cmqpxhdgw000pjx04d33mlc02	1	35.00	35.00	\N	cmqpxhdgw000njx045dlrlyp2	cmpqqm8iy001a3xvodugp204w
cmqpxiown000vjx04iewqw1m8	1	25.00	25.00	\N	cmqpxiown000tjx04e4595pmj	cmq7m4l080001la04q94r0qzv
cmqpxj6dt000zjx04iqeas099	1	35.00	35.00	\N	cmqpxj6dt000xjx04mz2oiq29	cmpqqm4l9000c3xvojqoj1yyt
cmqpzldaf0003l404ke4xnswb	1	40.00	40.00	\N	cmqpzldaf0001l40486tuof0m	cmprepa050001jp04hcbe0l2v
cmqpzldag0006l404fqtz444w	1	25.00	25.00	\N	cmqpzldaf0001l40486tuof0m	cmq7m4l080001la04q94r0qzv
cmqpzln7o0003kt04sucyl6ik	1	35.00	35.00	\N	cmqpzln7o0001kt04f99spf20	cmpqqm4l9000c3xvojqoj1yyt
cmqq03ztn000ekt041ry4uoba	1	40.00	40.00	\N	cmqq03ztn000ckt043fu09fhb	cmprepa050001jp04hcbe0l2v
cmqq03ztn000ikt04zo61m9jd	1	40.00	40.00	\N	cmqq03ztn000ckt043fu09fhb	cmpqqm3ot00063xvoeortkzib
cmqq2zqf30003jo04hotkm6mx	1	35.00	35.00	\N	cmqq2zqf30001jo04vpw9hcg3	cmpqqm4l9000c3xvojqoj1yyt
cmqq2zqf30007jo04m7mznu4a	1	35.00	35.00	\N	cmqq2zqf30001jo04vpw9hcg3	cmpqqm4l9000c3xvojqoj1yyt
cmqq307kw000gjo04v63gn8hj	1	40.00	40.00	\N	cmqq307kw000ejo04dohz48nf	cmprepa050001jp04hcbe0l2v
cmqq307kw000kjo04ripob30p	1	40.00	40.00	\N	cmqq307kw000ejo04dohz48nf	cmpqqm45100083xvoo43pm2fa
cmqq319mc000tjo04wrcigdhm	1	40.00	40.00	\N	cmqq319mc000rjo04bxfxgbk6	cmpqqm81900163xvo5msxvp3a
cmqq6nk7g0002l204s31ady4w	1	40.00	40.00	\N	cmqq6nk7f0000l2048tsin8h5	cmpqqm4t7000e3xvoazlktde5
cmqq6nk7g0006l204mlby15il	1	40.00	40.00	\N	cmqq6nk7f0000l2048tsin8h5	cmpqqm5gv000k3xvoc025780c
cmqq6obyz0003i3046ivikgrt	1	40.00	40.00	\N	cmqq6obyz0001i304n6oiwdn3	cmpqqm4t7000e3xvoazlktde5
cmqq6rct50009i304chsfns67	1	35.00	35.00	\N	cmqq6rct40007i304sag0w9cj	cmpqqmg7200363xvo3gkl3mbk
cmqq6wdo90003jy04cqhzo87i	1	40.00	40.00	\N	cmqq6wdo90001jy046dymokgb	cmprepa050001jp04hcbe0l2v
cmqq7lils0002lb0475jhn1ue	2	40.00	80.00	\N	cmqq7lilr0000lb0499saxfh7	cmpqqmd4h002g3xvorpy8wab0
cmqq7lils0005lb04xoif6zka	1	35.00	35.00	\N	cmqq7lilr0000lb0499saxfh7	cmpqqm8iy001a3xvodugp204w
cmqq7lils0009lb0472h8t0aa	4	35.00	140.00	\N	cmqq7lilr0000lb0499saxfh7	cmpqqm8iy001a3xvodugp204w
cmqq8x3770004lb04dkk8byt6	1	40.00	40.00	\N	cmqq8x3770002lb04yos38fog	cmpqqmcoq002c3xvolsroh00b
cmqq93f4r0001lb0477ey5vgg	1	40.00	40.00	\N	cmqq8xvem0008lb04odew7367	cmpqqm4t7000e3xvoazlktde5
cmqq93f4r0005lb04ctcu5doc	1	35.00	35.00	\N	cmqq8xvem0008lb04odew7367	cmpqqm8iy001a3xvodugp204w
cmqq965hy000hlb048fs18j6d	1	40.00	40.00	\N	cmqq965hx000flb04hp5wfoxc	cmpqqm65m000q3xvow1n8n4d2
cmqq9c6me000klb04z8nt3zzm	2	35.00	70.00	\N	cmqq9c6me000ilb04jab2xx01	cmpqqm4l9000c3xvojqoj1yyt
cmqq9l067000qlb04lip4i0n1	1	40.00	40.00	\N	cmqq93uva000alb043xvmsuhn	cmpqqmcoq002c3xvolsroh00b
cmqq9mgw7000rlb04jtxxi6uh	1	40.00	40.00	\N	cmqq9mgw6000plb04wyy9ja5n	cmpqqm45100083xvoo43pm2fa
cmqra6zq80002jo04fct0jcdf	1	35.00	35.00	\N	cmqra6zq80000jo046ttet8qg	cmpqqm4l9000c3xvojqoj1yyt
cmqra6zq80006jo0425h7xwym	2	5.00	10.00	\N	cmqra6zq80000jo046ttet8qg	cmq7m69sc0003la04fmysvt29
cmqra8rjw000cjo043kl5a1gu	1	40.00	40.00	\N	cmqra8rjw000ajo04wyg1h3yy	cmpqqmd4h002g3xvorpy8wab0
cmqracpce0003l404r1leil9s	1	35.00	35.00	\N	cmqracpce0001l4043l8c5jyn	cmpqqm4l9000c3xvojqoj1yyt
cmqracpcf0007l404l26eb38f	1	40.00	40.00	\N	cmqracpce0001l4043l8c5jyn	cmpqqm5oq000m3xvo7hnkpo73
cmqram8hw0003kz04xpj86e9d	1	40.00	40.00	\N	cmqram8hw0001kz04wlhybj4y	cmprepa050001jp04hcbe0l2v
cmqraodev000ckz04bticf1vt	1	40.00	40.00	\N	cmqraodev000akz04pbli9jk3	cmprepa050001jp04hcbe0l2v
cmqraodev000gkz04oheoutfu	1	40.00	40.00	\N	cmqraodev000akz04pbli9jk3	cmpqqm45100083xvoo43pm2fa
cmqravt500002jr04gdqk50v8	1	35.00	35.00	\N	cmqravt500000jr04fwnwafc0	cmpqqm4l9000c3xvojqoj1yyt
cmqrax84w000djr04nwbn0csg	1	40.00	40.00	\N	cmqrax84w000bjr04z8ciaayq	cmpqqm45100083xvoo43pm2fa
cmqrb1gbh0003l404uz9i1qic	1	35.00	35.00	\N	cmqrb1gbh0001l404mckhztkx	cmpqqm4l9000c3xvojqoj1yyt
cmqrbb9zw0003jo04ebkwzl4d	1	35.00	35.00	\N	cmqrbb9zw0001jo0441o02w6x	cmpqqm4l9000c3xvojqoj1yyt
cmqrbjawh000el404w4x3o51t	1	50.00	50.00	\N	cmqrbjawg000cl40460oj49t7	cmpqqm4cx000a3xvo6ij5ksrm
cmqrbthbi000mjo04f2pmue61	1	35.00	35.00	\N	cmqrbthbh000kjo04qpzlffdk	cmpqqm4l9000c3xvojqoj1yyt
cmqrc0lok000vjo046tr2ergn	1	35.00	35.00	\N	cmqrc0lok000tjo04qdar3f8j	cmpqqm8iy001a3xvodugp204w
cmqrc41nl0002i304pzm1kijd	1	35.00	35.00	\N	cmqrc41nl0000i304fvg1607m	cmpqqm4l9000c3xvojqoj1yyt
cmqrc5jtf000ci304dcsj2n5n	1	30.00	30.00	\N	cmqrc5jte000ai304ol3p9z3d	cmpqqm8qt001c3xvom39q1hsv
cmqrc65f80003l204jvtfbwh2	1	35.00	35.00	\N	cmqrc65f80001l204w0e2gwsx	cmpqqm4l9000c3xvojqoj1yyt
cmqrc8fgt0002jm043btumumu	1	40.00	40.00	\N	cmqrc8fgt0000jm043jieno7v	cmpqqm45100083xvoo43pm2fa
cmqrcl5ls0003ic047npgspw2	1	35.00	35.00	\N	cmqrcl5ls0001ic040ei43c90	cmpqqm4l9000c3xvojqoj1yyt
cmqrcp8x5000gic04y004h4m4	1	40.00	40.00	\N	cmqrcp8x5000eic04k8tjtens	cmpqqm3ot00063xvoeortkzib
cmqrcy4e50015jo04y5nbe2w4	1	40.00	40.00	\N	cmqrcy4e40013jo043h0t4tig	cmpqqm3ot00063xvoeortkzib
cmqrcy789001bjo04kpmaen0t	1	40.00	40.00	\N	cmqrcy7890019jo04r6sih9gp	cmpqqm4t7000e3xvoazlktde5
cmqrd263c0003jy04qf72p7z5	1	35.00	35.00	\N	cmqrd263c0001jy045zh4u85f	cmpqqm4l9000c3xvojqoj1yyt
cmqrf1mnw0003ld04nqa5sv7p	1	40.00	40.00	\N	cmqrf1mnw0001ld04bd7ymtk0	cmpqqmcwl002e3xvoh9uib930
cmqrf2wze000dld04edbtx87q	1	40.00	40.00	\N	cmqrf2gty0007ld04k9pjzsqi	cmpqqm45100083xvoo43pm2fa
cmqrf47jx000jld04uppsgd2r	1	40.00	40.00	\N	cmqrf47jx000hld04hfypa8ay	cmprepa050001jp04hcbe0l2v
cmqrfrglq0003l104t1higna1	1	40.00	40.00	\N	cmqrfrglq0001l104xmcarnun	cmpqqm3ot00063xvoeortkzib
cmqrg9nsl0003ie04yoe38dkf	1	35.00	35.00	\N	cmqrg9nsl0001ie04ejs3b9hh	cmpqqm4l9000c3xvojqoj1yyt
cmqrg9nsl0007ie04vwgu7tk1	1	40.00	40.00	เพิ่มโกโก้	cmqrg9nsl0001ie04ejs3b9hh	cmpqqm81900163xvo5msxvp3a
cmqrgvum70005kz04ztc9jwa3	1	35.00	35.00	\N	cmqrgvum70003kz04ag2o6xlv	cmpqqm4l9000c3xvojqoj1yyt
cmqrgvum70009kz04ngz2p7cn	1	15.00	15.00	\N	cmqrgvum70003kz04ag2o6xlv	cmpzoaia200023xomsj6ohdvb
cmqrgwl12000dkz0433yzzbe5	1	35.00	35.00	\N	cmqrgwl11000bkz04jf7but3l	cmpqqm4l9000c3xvojqoj1yyt
cmqrh5su70007l504gzg0kd0s	1	25.00	25.00	\N	cmqrh5su70005l5048raym4k7	cmq7m4l080001la04q94r0qzv
cmqrh9pt6000dl504fixjts0u	1	30.00	30.00	\N	cmqrh92r4000bl504oku7ssc3	cmpqqmfjf00303xvou7ww0eba
cmqrhb1fd000ll5047gvs236s	1	35.00	35.00	\N	cmqrhb1fd000jl504iijwrabr	cmpqqm4l9000c3xvojqoj1yyt
cmqrlnkzv0002lb04uxzxbdfb	1	40.00	40.00	\N	cmqrlnkzu0000lb04l5awr2va	cmpqqm4t7000e3xvoazlktde5
cmqrlnkzv0006lb043t3en7sa	1	40.00	40.00	\N	cmqrlnkzu0000lb04l5awr2va	cmpqqm5oq000m3xvo7hnkpo73
cmqrlubpn0001ic04p35rmycr	1	30.00	30.00	\N	cmqrlgt5d0000jp04txv6klq2	cmpqqmeg2002q3xvorgtl69w5
cmqrm3j3x0003lg04mmghnumg	1	15.00	15.00	\N	cmqrm3j3x0001lg04v48yqwyh	cmpzoaia200023xomsj6ohdvb
cmqrm3j3x0004lg04bmv3jlcw	1	15.00	15.00	\N	cmqrm3j3x0001lg04v48yqwyh	cmpzoaia200023xomsj6ohdvb
cmqrm6gsz000glb043tktle4t	1	40.00	40.00	\N	cmqrm6gsz000elb04yt2lfy0d	cmprepa050001jp04hcbe0l2v
cmqrm6t1o000plb04o0lyuqqq	1	40.00	40.00	\N	cmqrm6t1o000nlb04wqn4r05f	cmpqqm4t7000e3xvoazlktde5
cmqrmngr0000xlb04smqkle4n	5	35.00	175.00	\N	cmqrmngr0000vlb04rbad8inm	cmpqqm8iy001a3xvodugp204w
cmqrmngr00012lb045cgcosfh	2	35.00	70.00	\N	cmqrmngr0000vlb04rbad8inm	cmpqqm8iy001a3xvodugp204w
cmqrmngr00016lb04m6duzh3k	1	35.00	35.00	\N	cmqrmngr0000vlb04rbad8inm	cmpqqm4l9000c3xvojqoj1yyt
cmqrmngr0001alb04rqjm9gah	1	40.00	40.00	\N	cmqrmngr0000vlb04rbad8inm	cmpqqmd4h002g3xvorpy8wab0
cmqrnimbr0003jj04f9bf7czt	1	35.00	35.00	\N	cmqrnimbr0001jj0465jdmyhm	cmpqqm8iy001a3xvodugp204w
cmqrnimbr0006jj04xgqzu94b	1	35.00	35.00	\N	cmqrnimbr0001jj0465jdmyhm	cmpqqm8iy001a3xvodugp204w
cmqrnimbr0009jj04mmiulop1	1	35.00	35.00	\N	cmqrnimbr0001jj0465jdmyhm	cmpqqm9eg001i3xvoqq2p0pcl
cmqsopgjq0002l404fw7vhvu6	1	35.00	35.00	\N	cmqsopgjq0000l404rp3y2vou	cmpqqm4l9000c3xvojqoj1yyt
cmqsopgjq0006l404dkltwmz7	1	40.00	40.00	\N	cmqsopgjq0000l404rp3y2vou	cmprepa050001jp04hcbe0l2v
cmqsopgjq000al404wa1w9qsu	1	35.00	35.00	\N	cmqsopgjq0000l404rp3y2vou	cmpqqm9eg001i3xvoqq2p0pcl
cmqsopgjq000el404dqntbjo7	2	5.00	10.00	\N	cmqsopgjq0000l404rp3y2vou	cmq7m69sc0003la04fmysvt29
cmqspagr00002jr048q5snby8	1	40.00	40.00	\N	cmqspagr00000jr04wv487qjo	cmpqqm4t7000e3xvoazlktde5
cmqspagr00006jr04vf393dwe	2	15.00	30.00	\N	cmqspagr00000jr04wv487qjo	cmpzoaia200023xomsj6ohdvb
cmqspu3px0003l704tw8dv6mz	1	35.00	35.00	\N	cmqspu3px0001l7042wk9u83x	cmpqqm4l9000c3xvojqoj1yyt
cmqspu3px0007l704usogy67u	1	40.00	40.00	\N	cmqspu3px0001l7042wk9u83x	cmpqqm6di000s3xvog0defnci
cmqspwbay0006js04qr96w2zt	2	35.00	70.00	\N	cmqspwbay0004js04g2lmr5jc	cmpqqm4l9000c3xvojqoj1yyt
cmqspwbaz000bjs04uzu5uzuy	1	35.00	35.00	\N	cmqspwbay0004js04g2lmr5jc	cmpqqm4l9000c3xvojqoj1yyt
cmqspwbaz000gjs04r7k116w2	1	40.00	40.00	\N	cmqspwbay0004js04g2lmr5jc	cmpqqm5oq000m3xvo7hnkpo73
cmqspwbaz000ljs04qoydumqh	1	35.00	35.00	\N	cmqspwbay0004js04g2lmr5jc	cmpqqm96k001g3xvoeknbidid
cmqsqb9re0002l504vu8fw6un	1	40.00	40.00	\N	cmqsqb9rd0000l504xxf1rosa	cmpqqm3ot00063xvoeortkzib
cmqsqccav0003jv04aqmof1ds	1	40.00	40.00	\N	cmqsqbh380001jv04fa9hjogy	cmpqqm3ot00063xvoeortkzib
cmqsqccav0006jv04faxnow2l	1	40.00	40.00	\N	cmqsqbh380001jv04fa9hjogy	cmpqqmd4h002g3xvorpy8wab0
cmqsqcot5000cjv04qnqhjcjk	1	35.00	35.00	\N	cmqsqcot5000ajv04bqqbxo80	cmpqqm9eg001i3xvoqq2p0pcl
cmqsql12w000vjs04i1ehi38d	1	40.00	40.00	\N	cmqsql12w000tjs0452jscqle	cmprepa050001jp04hcbe0l2v
cmqsqnrgy000mjv049tn4ymg5	2	35.00	70.00	\N	cmqsqnrgy000kjv04s812jxc5	cmpqqm4l9000c3xvojqoj1yyt
cmqsqpxl5000yjv04k75do8p4	1	40.00	40.00	\N	cmqsqpgzf000rjv04zq0k50d2	cmpqqm4cx000a3xvo6ij5ksrm
cmqsqpxl50012jv04b97ckk8s	1	25.00	25.00	\N	cmqsqpgzf000rjv04zq0k50d2	cmq7m4l080001la04q94r0qzv
cmqsqs6uo0016jv0411thh8jy	1	35.00	35.00	\N	cmqsqs6uo0014jv04smldlbth	cmpqqm4l9000c3xvojqoj1yyt
cmqsqxi1s001djv0456d48r7j	1	35.00	35.00	\N	cmqsqxi1s001bjv049v7gmnik	cmpqqm4l9000c3xvojqoj1yyt
cmqsqzvh10016js04u9og9bji	1	45.00	45.00	\N	cmqsqzvh10014js04ryxuzh7o	cmpqqmdk7002k3xvoo1d970sf
cmqsr2w4q001cjs0419qvh5si	1	35.00	35.00	\N	cmqsr2w4q001ajs04hqimym69	cmpqqm9eg001i3xvoqq2p0pcl
cmqsr4y70001kjv049739narm	1	40.00	40.00	\N	cmqsr4lze001gjs04r00zb0f2	cmpqqm4t7000e3xvoazlktde5
cmqsraqs9001tjs042vjys8t0	1	30.00	30.00	\N	cmqsraqs9001rjs04h1hms8lq	cmpu4u2520001l4045ganc8z4
cmqsrwzrq0002l50464i6ndm4	1	35.00	35.00	\N	cmqsrwzrq0000l5040gm3nkc8	cmpqqm9eg001i3xvoqq2p0pcl
cmqsrxt81002djs04c6skmv1i	1	40.00	40.00	\N	cmqsrxt81002bjs04v79dal5h	cmpqqmd4h002g3xvorpy8wab0
cmqss6unk002njs04q7gcu6no	1	40.00	40.00	\N	cmqss6unk002ljs04vzfop6g8	cmprepa050001jp04hcbe0l2v
cmqss6unk002qjs04tkrgh41n	1	35.00	35.00	\N	cmqss6unk002ljs04vzfop6g8	cmpqqm9eg001i3xvoqq2p0pcl
cmqssend50030js048snj4fet	1	35.00	35.00	\N	cmqssend5002yjs04okujv8et	cmpqqm4l9000c3xvojqoj1yyt
cmqsujg810003jp04hssmyq7z	1	40.00	40.00	\N	cmqsujg810001jp04gj2edgq1	cmprepa050001jp04hcbe0l2v
cmqsujg810007jp04u7rw6w00	1	25.00	25.00	\N	cmqsujg810001jp04gj2edgq1	cmq7m4l080001la04q94r0qzv
cmqsvh2wd0003ic047xto4tx2	1	40.00	40.00	\N	cmqsvh2wd0001ic04vdtnplx8	cmprepa050001jp04hcbe0l2v
cmqsvh63a0009ic04iutosk05	1	40.00	40.00	\N	cmqsvh63a0007ic04ok0g4ggp	cmpqqm3ot00063xvoeortkzib
cmqsvhfat000fic0494gqecsi	1	35.00	35.00	\N	cmqsvhfat000dic045z00p714	cmpqqm4l9000c3xvojqoj1yyt
cmqswad3b0001l7040i4tupnv	2	40.00	80.00	เพิ่มช็อต+5 *2	cmqsvs7mv0001jr04vep682sr	cmpqqm81900163xvo5msxvp3a
cmqswad3b0005l7041cqalvjn	2	15.00	30.00	\N	cmqsvs7mv0001jr04vep682sr	cmpzoaia200023xomsj6ohdvb
cmqswgblj0001ju04chq7mio9	1	40.00	40.00	\N	cmqswdvqy0001jp04xxzkyv04	cmprepa050001jp04hcbe0l2v
cmqswgblk0005ju043obsqt48	1	30.00	30.00	\N	cmqswdvqy0001jp04xxzkyv04	cmpu4u2520001l4045ganc8z4
cmqswgblk0008ju04d7ti6qrv	1	35.00	35.00	ร้อน	cmqswdvqy0001jp04xxzkyv04	cmq8nuyoz0001k304d0qgxux4
cmqsx6mqv0003kv04fit6ooux	1	40.00	40.00	\N	cmqsx6mqv0001kv04gf0i7sa1	cmprepa050001jp04hcbe0l2v
cmqsymgxl0002le04t61uerfb	1	25.00	25.00	\N	cmqsymgxl0000le04e1apu8b2	cmq7m4l080001la04q94r0qzv
cmqsymgxl0003le0439z9t5tn	1	35.00	35.00	\N	cmqsymgxl0000le04e1apu8b2	cmpqqmhah003g3xvocqzdccbj
cmqsziijv0003ld048pal6x84	1	40.00	40.00	\N	cmqsziijv0001ld041aaxvbov	cmpqqm81900163xvo5msxvp3a
cmqsziijv0006ld04yu6j0ptj	1	40.00	40.00	\N	cmqsziijv0001ld041aaxvbov	cmpqqm3ot00063xvoeortkzib
cmqsziijv0009ld04392cnp80	1	40.00	40.00	\N	cmqsziijv0001ld041aaxvbov	cmpqqm81900163xvo5msxvp3a
cmqt160cf0002l504f8y62l1u	2	40.00	80.00	\N	cmqt160cf0000l504vdkn128n	cmpqqm5oq000m3xvo7hnkpo73
cmqt1clfd0003l70470aqe3li	1	40.00	40.00	\N	cmqt1clfd0001l7045bfcatmr	cmpqqm4t7000e3xvoazlktde5
cmqt3j7kp0003jp0432d5eyib	1	35.00	35.00	\N	cmqt3j7kp0001jp0477j6jcj8	cmpqqm8iy001a3xvodugp204w
cmqt3z3n8000dl5049fvrqyi6	1	35.00	35.00	\N	cmqt3yob20003l504pdzkz1dc	cmpqqm9eg001i3xvoqq2p0pcl
cmqt3z3n8000gl504shr2qooo	2	35.00	70.00	\N	cmqt3yob20003l504pdzkz1dc	cmpqqm4l9000c3xvojqoj1yyt
cmqtj9p2j00023xqf6jkwjsi1	1	40.00	40.00	\N	cmqtj9p2i00003xqf43kb9wo4	cmpqqm4cx000a3xvo6ij5ksrm
cmqu54za30003kz04hyng1v09	1	40.00	40.00	\N	cmqu54za30001kz04rauytwb9	cmprepa050001jp04hcbe0l2v
cmqu54za30007kz04qicd1jya	1	40.00	40.00	\N	cmqu54za30001kz04rauytwb9	cmpqqm5oq000m3xvo7hnkpo73
cmqu5bmn80002js044t308s7x	1	35.00	35.00	\N	cmqu5bmn80000js047iejoava	cmpqqm4l9000c3xvojqoj1yyt
cmqu5bmn80006js04rh5lbe23	1	15.00	15.00	\N	cmqu5bmn80000js047iejoava	cmpzoaia200023xomsj6ohdvb
cmqu5bmn80007js04sz69w1bb	2	5.00	10.00	\N	cmqu5bmn80000js047iejoava	cmq7m69sc0003la04fmysvt29
cmqu5ov4b0002l204qeni6scf	1	40.00	40.00	\N	cmqu5ov4b0000l2046p93napv	cmpqqm5oq000m3xvo7hnkpo73
cmqu5ov4b0007l204bgldxdq7	2	35.00	70.00	\N	cmqu5ov4b0000l2046p93napv	cmpqqm4l9000c3xvojqoj1yyt
cmqu5ov4b000cl2041urtx3f1	1	35.00	35.00	\N	cmqu5ov4b0000l2046p93napv	cmpqqm4l9000c3xvojqoj1yyt
cmqu5ov4b000hl2049f0zd7cd	1	40.00	40.00	\N	cmqu5ov4b0000l2046p93napv	cmpqqm4cx000a3xvo6ij5ksrm
cmqu5ov4b000ml204xxre32pf	1	40.00	40.00	\N	cmqu5ov4b0000l2046p93napv	cmpqqm45100083xvoo43pm2fa
cmqu5ph4u000vl204ug0u4068	1	40.00	40.00	\N	cmqu5ph4u000tl204qbuj1d31	cmpqqm5oq000m3xvo7hnkpo73
cmqu5ph4u0010l204wlovgzq0	2	35.00	70.00	\N	cmqu5ph4u000tl204qbuj1d31	cmpqqm4l9000c3xvojqoj1yyt
cmqu5ph4u0015l204sj3rarst	1	35.00	35.00	\N	cmqu5ph4u000tl204qbuj1d31	cmpqqm4l9000c3xvojqoj1yyt
cmqu5ph4u001al204in11saoh	1	40.00	40.00	\N	cmqu5ph4u000tl204qbuj1d31	cmpqqm4cx000a3xvo6ij5ksrm
cmqu5ph4u001fl2048kcl7vpw	1	40.00	40.00	\N	cmqu5ph4u000tl204qbuj1d31	cmpqqm45100083xvoo43pm2fa
cmqu5u99y0003le04rz39mqtx	1	40.00	40.00	\N	cmqu5u99y0001le04bwto7o2r	cmpqqm45100083xvoo43pm2fa
cmqu5wd1z001rl204xbcct8jz	1	35.00	35.00	\N	cmqu5wd1z001pl204snbpud2p	cmpqqm4l9000c3xvojqoj1yyt
cmqu5z3xg001yl2043ip74ybx	1	35.00	35.00	\N	cmqu5z3xf001wl204f103vh45	cmpqqm9eg001i3xvoqq2p0pcl
cmqu60x7w0024l204ymvcf4pm	1	40.00	40.00	\N	cmqu60x7w0022l204wlhxlvfv	cmpqqmd4h002g3xvorpy8wab0
cmqu60x7w0027l204ekus8n08	1	40.00	40.00	\N	cmqu60x7w0022l204wlhxlvfv	cmpqqm3ot00063xvoeortkzib
cmqzva6ev0003l704voqgwyqv	1	45.00	45.00	\N	cmqzva6ev0001l704zds8z4u5	cmpqqmdk7002k3xvoo1d970sf
cmqu6frwa000bl805ilv3b9rn	1	35.00	35.00	\N	cmqu6frwa0009l805c8bbgv7j	cmpqqm4l9000c3xvojqoj1yyt
cmqzva6ev0006l704qormwcj0	1	35.00	35.00	\N	cmqzva6ev0001l704zds8z4u5	cmpqqm4l9000c3xvojqoj1yyt
cmqzvnxad000cl7049qfljism	1	40.00	40.00	\N	cmqzvnxad000al704oapxd2t8	cmpqqm4t7000e3xvoazlktde5
cmqzvoicx0003l404lvguqdm7	1	35.00	35.00	\N	cmqzvoicx0001l404lbbs275o	cmpqqm4l9000c3xvojqoj1yyt
cmqzvoicx0008l4048dsdhm60	1	35.00	35.00	\N	cmqzvoicx0001l404lbbs275o	cmpqqm4l9000c3xvojqoj1yyt
cmqzvrvnp0002k104ln1dj1we	1	35.00	35.00	\N	cmqzvrvno0000k1046rg92011	cmpqqm4l9000c3xvojqoj1yyt
cmqzvtoh20003ib04izfjy97h	1	40.00	40.00	\N	cmqzvtoh20001ib04wwg2el8k	cmpqqm3ot00063xvoeortkzib
cmqzvtoh20006ib04g9j70r7g	1	35.00	35.00	\N	cmqzvtoh20001ib04wwg2el8k	cmpqqm8iy001a3xvodugp204w
cmqzw02l10002l204eqjp0v1a	1	35.00	35.00	\N	cmqzw02l10000l204fi314iya	cmpqqm4l9000c3xvojqoj1yyt
cmqzw0kco0002ju04qjeys6bs	1	35.00	35.00	\N	cmqzw0kco0000ju044iic57q3	cmpqqm8iy001a3xvodugp204w
cmr005g1o000cl504u39e8qtb	1	35.00	35.00	\N	cmr005g1o000al504dg4nt2zo	cmpqqm4l9000c3xvojqoj1yyt
cmr00nqhc000djr04g44ll0q2	1	35.00	35.00	\N	cmr00nqhc000bjr04bt0bcm9x	cmpqqm4l9000c3xvojqoj1yyt
cmr00umwc000al704qlvt2wt8	1	35.00	35.00	\N	cmr00umwc0008l704gvxzuz0w	cmpqqm4l9000c3xvojqoj1yyt
cmqu675xn0002jl04yqblxhff	1	35.00	35.00	\N	cmqu675xn0000jl04uptlngix	cmpqqm4l9000c3xvojqoj1yyt
cmqu675xn0007jl04jmlwbk9c	1	5.00	5.00	\N	cmqu675xn0000jl04uptlngix	cmq7m69sc0003la04fmysvt29
cmqu69t7f002ll204j4eoitbk	1	35.00	35.00	\N	cmqu69t7f002jl204qa98wvj9	cmpqqm8iy001a3xvodugp204w
cmqu6a3pw002rl204zxn8mgo1	1	40.00	40.00	\N	cmqu6a3pw002pl2041bhr1er8	cmpqqmd4h002g3xvorpy8wab0
cmqu6hkvd000ol805f5m2zpx9	2	35.00	70.00	\N	cmqu6gd5a002vl20464g25uuo	cmpqqm4l9000c3xvojqoj1yyt
cmqu6lort000fle04z44xv22v	1	40.00	40.00	\N	cmqu6lors000dle04oi7ou1pt	cmpqqmc8y00283xvomsuwyqct
cmqu6niaf000nle04cl599s5q	1	35.00	35.00	\N	cmqu6niaf000lle04xd561dlx	cmpqqm4l9000c3xvojqoj1yyt
cmqu6seyg0032l2044upw658e	1	40.00	40.00	\N	cmqu6fd6q0003l805cb43bo12	cmpqqm4t7000e3xvoazlktde5
cmqu6seyg0036l204tylooxt6	1	35.00	35.00	\N	cmqu6fd6q0003l805cb43bo12	cmpqqmc1300263xvodgeiz5il
cmqu7d0h20003ld04m0djlmol	1	30.00	30.00	\N	cmqu7d0h20001ld04nck0xfpz	cmpu4u2520001l4045ganc8z4
cmqu7jpdz0009ld04m3au717s	1	35.00	35.00	\N	cmqu7jpdz0007ld04c9pzibry	cmpqqm4l9000c3xvojqoj1yyt
cmqu7mptc000gld04nh7ddgui	1	40.00	40.00	\N	cmqu7mptc000eld04scjjmsi9	cmpqqm3ot00063xvoeortkzib
cmqu7vtwl000qld04wxx40dna	1	40.00	40.00	\N	cmqu7vtwl000old04p32hvbyx	cmprepa050001jp04hcbe0l2v
cmqu7vtwl000uld04ywi39290	1	25.00	25.00	\N	cmqu7vtwl000old04p32hvbyx	cmq7m4l080001la04q94r0qzv
cmqu7w23g000yld044bqe9hlx	1	40.00	40.00	\N	cmqu7w23g000wld04a62csjo2	cmprepa050001jp04hcbe0l2v
cmqu7wiio0014ld04uj2fcg7v	1	35.00	35.00	\N	cmqu7wiin0012ld04lgsadinz	cmpqqm4l9000c3xvojqoj1yyt
cmqu80m830016le04r8j2a8oz	1	40.00	40.00	\N	cmqu80m830014le04rswffq6b	cmprepa050001jp04hcbe0l2v
cmqubd48a0003l704qbdvqjlk	1	40.00	40.00	\N	cmqubd48a0001l704ooyhcy58	cmpqqm3ot00063xvoeortkzib
cmqubd48a0006l7048qrb2snu	1	40.00	40.00	\N	cmqubd48a0001l704ooyhcy58	cmpqqm45100083xvoo43pm2fa
cmqubgzgi000dl704mtbyva6b	1	40.00	40.00	\N	cmqubgzgi000bl70463lc0etm	cmpqqm45100083xvoo43pm2fa
cmqubgzgi000hl704h6lmh2gf	1	35.00	35.00	\N	cmqubgzgi000bl70463lc0etm	cmpqqma9x001q3xvo0d6239vc
cmqubqvo1000sl704qy3g3x5f	1	35.00	35.00	\N	cmqubqvo1000ql704r4ryecj4	cmpqqm4l9000c3xvojqoj1yyt
cmquc8umj0004ju040nrvx4rs	1	35.00	35.00	\N	cmquc8umj0002ju04vd21peyy	cmpqqm4l9000c3xvojqoj1yyt
cmquc8umj0008ju04i6r2nm7x	1	35.00	35.00	\N	cmquc8umj0002ju04vd21peyy	cmpqqm4l9000c3xvojqoj1yyt
cmquc8umj000dju042w93kgl7	1	40.00	40.00	\N	cmquc8umj0002ju04vd21peyy	cmpqqm81900163xvo5msxvp3a
cmquczn5m0003jp04zsk42x8z	1	40.00	40.00	\N	cmquczn5m0001jp046l5dm6i0	cmprepa050001jp04hcbe0l2v
cmquczn5n0007jp04virg0v1i	1	35.00	35.00	25	cmquczn5m0001jp046l5dm6i0	cmpqqm9eg001i3xvoqq2p0pcl
cmquf4zs60003l704yuik6w0c	1	40.00	40.00	\N	cmquf4zs60001l70456s6f7d9	cmprepa050001jp04hcbe0l2v
cmqugvw1e0003ky049l3abcio	1	40.00	40.00	\N	cmqugvw1e0001ky04g8uwr83y	cmpqqmd4h002g3xvorpy8wab0
cmquh8biu000bky04fvwim5is	1	35.00	35.00	\N	cmquh8biu0009ky04yv8gi8s4	cmpqqm4l9000c3xvojqoj1yyt
cmquhvspy0003kz04eg648bjy	1	35.00	35.00	\N	cmquhvspy0001kz04nsqifvjn	cmpqqmg7200363xvo3gkl3mbk
cmquhvspz0006kz048iiosbjt	1	40.00	40.00	\N	cmquhvspy0001kz04nsqifvjn	cmpqqm5oq000m3xvo7hnkpo73
cmquiehyl0003l804nk1c7tsr	1	35.00	35.00	\N	cmquiehyl0001l804zjf2li7i	cmpqqm8yp001e3xvolh59nlvx
cmquismqe0003l4041n4ac6yb	1	40.00	40.00	\N	cmquismqe0001l40446lmetom	cmpqqm81900163xvo5msxvp3a
cmqvkh56r0005jr04fmxxcsl9	1	35.00	35.00	\N	cmqvkh56r0003jr04nvnq7sib	cmpqqm4l9000c3xvojqoj1yyt
cmqvkh56r0009jr04dowgxhq5	2	40.00	80.00	\N	cmqvkh56r0003jr04nvnq7sib	cmpqqm5oq000m3xvo7hnkpo73
cmqvkhuen0003l9049wp5uth7	1	40.00	40.00	\N	cmqvkhuen0001l904r8yvo1hy	cmpqqm4t7000e3xvoazlktde5
cmqvlh5e20002kt04ndjcopea	1	35.00	35.00	\N	cmqvlh5e20000kt047pb74whb	cmpqqm8iy001a3xvodugp204w
cmqvlj8mi0001jm04eq7j6ajo	1	35.00	35.00	\N	cmqvky38n0000jv04kb6dkv59	cmpqqm4l9000c3xvojqoj1yyt
cmqvlj8mi0005jm0419k63rkt	1	40.00	40.00	\N	cmqvky38n0000jv04kb6dkv59	cmpqqm81900163xvo5msxvp3a
cmqvlj8mi0009jm04j4jhnkvx	1	35.00	35.00	\N	cmqvky38n0000jv04kb6dkv59	cmpqqma23001o3xvoooy0q9ws
cmqvlln5v0003l504jvox60de	1	45.00	45.00	\N	cmqvlln5v0001l504vvs9n8t7	cmpqqmdk7002k3xvoo1d970sf
cmqvlob4k0003ky047tyd9sgs	1	35.00	35.00	\N	cmqvlob4k0001ky04l2nm9erh	cmpqqm4l9000c3xvojqoj1yyt
cmqvlob4l0007ky04gs87regh	1	40.00	40.00	\N	cmqvlob4k0001ky04l2nm9erh	cmpqqmd4h002g3xvorpy8wab0
cmqvlob4l000aky04a0giphv8	1	40.00	40.00	\N	cmqvlob4k0001ky04l2nm9erh	cmpqqm3ot00063xvoeortkzib
cmqvlow8u0003js0499lew2ji	1	35.00	35.00	\N	cmqvlow8u0001js04fhes2gts	cmpqqm4l9000c3xvojqoj1yyt
cmqvlp9nq000gky04tvc35bxm	1	40.00	40.00	\N	cmqvlp9nq000eky04hutle273	cmpqqm4cx000a3xvo6ij5ksrm
cmqvlpbty000mky04f0a2d80z	1	5.00	5.00	\N	cmqvlpbty000kky04pk9aro6k	cmq7m69sc0003la04fmysvt29
cmqvlpbty000nky04sls4iufu	1	40.00	40.00	\N	cmqvlpbty000kky04pk9aro6k	cmpqqm3ot00063xvoeortkzib
cmqvlt1kf000wky04g37le17d	1	35.00	35.00	\N	cmqvlt1ke000uky04g29ikceg	cmpqqm9eg001i3xvoqq2p0pcl
cmqvlt1kf0011ky04ulfjkbji	2	35.00	70.00	\N	cmqvlt1ke000uky04g29ikceg	cmpqqm4l9000c3xvojqoj1yyt
cmqvlwhwv000bjs048jih32a6	1	35.00	35.00	\N	cmqvlwhwu0009js04kjz4nt37	cmpqqm9eg001i3xvoqq2p0pcl
cmqvm8ttk000ljs04whfjcang	1	30.00	30.00	เพิ่มน้ำร้อน	cmqvm8ttk000jjs04n9z1w6ab	cmpu4u2520001l4045ganc8z4
cmqvme3ch0009l504glraacj6	1	40.00	40.00	\N	cmqvme3ch0007l504e2y4gqjd	cmprepa050001jp04hcbe0l2v
cmqvmin8p0002l804w179hygh	1	45.00	45.00	\N	cmqvmin8o0000l804spujq9oh	cmpqqmb5j001y3xvorydyj1tt
cmqvmsyb7000il504u5z7xuce	1	35.00	35.00	\N	cmqvmsyb7000gl504zwb6jq4x	cmpqqm9md001k3xvofiitta7j
cmqvmwj5p000vl504pz82fwh7	1	35.00	35.00	\N	cmqvmvukw000ml504g5cuk2uj	cmpqqm9eg001i3xvoqq2p0pcl
cmqvmwj5p000yl504bx34v343	1	40.00	40.00	\N	cmqvmvukw000ml504g5cuk2uj	cmpqqmcoq002c3xvolsroh00b
cmqvmwj5p0011l504covelbif	1	40.00	40.00	\N	cmqvmvukw000ml504g5cuk2uj	cmpqqm3ot00063xvoeortkzib
cmqvmyrne0019l504ihkef79v	1	40.00	40.00	\N	cmqvmyrne0017l504y6dbhc1m	cmprepa050001jp04hcbe0l2v
cmqvn46sw000xjs040td4v9ij	1	40.00	40.00	\N	cmqvn46sv000vjs047vif4rei	cmpqqm4t7000e3xvoazlktde5
cmqvn92xz001hl5049chmlz50	1	40.00	40.00	\N	cmqvn92xz001fl504eqzrcnem	cmpqqm3ot00063xvoeortkzib
cmqvpsalm0003if04mds1y25p	1	35.00	35.00	\N	cmqvpsalm0001if04s0klkhz1	cmpqqm4l9000c3xvojqoj1yyt
cmqvpsltp000aif045080prdg	1	40.00	40.00	\N	cmqvpsltp0008if0495ohbj5u	cmpqqm3ot00063xvoeortkzib
cmqvpsltp000dif04sccl26ne	1	40.00	40.00	\N	cmqvpsltp0008if0495ohbj5u	cmprepa050001jp04hcbe0l2v
cmqvpuzmx0003l4048nr08t2y	1	35.00	35.00	\N	cmqvpuzmx0001l404y5wwm65n	cmpqqm4l9000c3xvojqoj1yyt
cmqvpuzmx0007l4041dvt3tqo	1	35.00	35.00	\N	cmqvpuzmx0001l404y5wwm65n	cmpqqm8iy001a3xvodugp204w
cmqvq5iib000pif045ksqbtze	1	40.00	40.00	\N	cmqvq5iib000nif04khems3ja	cmprepa050001jp04hcbe0l2v
cmqvqneye0003jp047hgw8zb7	1	35.00	35.00	\N	cmqvqneyd0001jp040k4velvo	cmpqqm9eg001i3xvoqq2p0pcl
cmqvqzqb2000bjp04kgkenzw2	1	35.00	35.00	\N	cmqvqzqb20009jp04kleo41np	cmpqqm4l9000c3xvojqoj1yyt
cmqvsgo950003jz04adptwhb6	1	30.00	30.00	\N	cmqvsgo950001jz04eqyq4qdh	cmpqqm73r000y3xvo4ll4a6t4
cmqzvua1b000cib04vzu5l1m9	1	40.00	40.00	M	cmqzvua1b000aib048uzjrcot	cmpqqm45100083xvoo43pm2fa
cmqvvczoc0002l1041e70v5qb	1	40.00	40.00	\N	cmqvvczoc0000l104ibzig4ya	cmpqqm4t7000e3xvoazlktde5
cmqvwf0p70001lb04h0rpwxhc	1	35.00	35.00	\N	cmqvtju9w0000jm04ug3a25pj	cmpqqmg7200363xvo3gkl3mbk
cmqyf83fy0002jo04vnwbfd7y	1	35.00	35.00	\N	cmqyf83fy0000jo04udtgo417	cmpqqm4l9000c3xvojqoj1yyt
cmqyf83fy0006jo04nzhp0ki5	1	40.00	40.00	\N	cmqyf83fy0000jo04udtgo417	cmpqqm81900163xvo5msxvp3a
cmqyf83fz000ajo04ls5f6nnm	1	35.00	35.00	\N	cmqyf83fy0000jo04udtgo417	cmpqqm9eg001i3xvoqq2p0pcl
cmqyfm4qb0003jl04ziquzuoo	1	35.00	35.00	\N	cmqyfm4qb0001jl043aulsxd4	cmpqqm4l9000c3xvojqoj1yyt
cmqyfrmqz0002jl04koczs19c	1	35.00	35.00	\N	cmqyfrmqz0000jl043dbmovp4	cmpqqm4l9000c3xvojqoj1yyt
cmqyfuauz000cjl04evpsrci8	1	35.00	35.00	\N	cmqyfuauz000ajl04jm0rhham	cmpqqma23001o3xvoooy0q9ws
cmqyfuauz000gjl04udkbuysj	1	5.00	5.00	\N	cmqyfuauz000ajl04jm0rhham	cmq7m69sc0003la04fmysvt29
cmqyg31jy0003lb04608s4x4v	1	35.00	35.00	\N	cmqyg31jy0001lb04mbdalepf	cmpqqm8iy001a3xvodugp204w
cmqyg5nbi000ejl04909o2cax	1	50.00	50.00	\N	cmqyg5nbh000cjl04zj4u576u	cmpqqm3ot00063xvoeortkzib
cmqyg5tjs000ljl04gze8deae	1	35.00	35.00	\N	cmqyg5tjs000jjl04uopxfksu	cmpqqm4l9000c3xvojqoj1yyt
cmqyg7p85000ujl044dl8u3h6	1	40.00	40.00	\N	cmqyg7p85000sjl046p7dojk3	cmpqqm45100083xvoo43pm2fa
cmqygs0l50017jl04oq3dettl	1	40.00	40.00	\N	cmqygs0l50015jl049wz8rtwo	cmpqqm4t7000e3xvoazlktde5
cmqyh0nsh0003jx04jii1hktv	1	40.00	40.00	\N	cmqyh0nsh0001jx048s9ggllz	cmpqqmc8y00283xvomsuwyqct
cmqyhje5a000djx04t5bx7kit	1	40.00	40.00	\N	cmqyhje5a000bjx04xead26pw	cmpqqmcoq002c3xvolsroh00b
cmqzw141o000dl204ykjl85by	1	40.00	40.00	\N	cmqzw141o000bl204hy27jx4g	cmpqqm81900163xvo5msxvp3a
cmqyhva8r0008jl04ax23g8qt	2	40.00	80.00	\N	cmqyhu0s50001jl041x0n7755	cmpqqm513000g3xvo0iex8rrm
cmqyhwqe2000ljx04qyc9w0bt	1	35.00	35.00	\N	cmqyhwqe2000jjx04yxewshue	cmpqqm4l9000c3xvojqoj1yyt
cmqyi1rza000fjl04f79oobht	1	40.00	40.00	\N	cmqyi1rza000djl04jxepzoob	cmpqqm4t7000e3xvoazlktde5
cmqyi6tet000ujx04d2c4o2ku	3	15.00	45.00	\N	cmqyi6tet000sjx04b8gieg51	cmpzoaia200023xomsj6ohdvb
cmqyi7tyh0010jx0496hkvvgv	1	40.00	40.00	\N	cmqyi7tyg000yjx04ekdlsh4k	cmpqqm3ot00063xvoeortkzib
cmqyl4dx50003l204z5yalb3z	1	40.00	40.00	\N	cmqyl4dx50001l204cp6l0030	cmprepa050001jp04hcbe0l2v
cmqyl59i80009l204uc9208om	1	40.00	40.00	\N	cmqyl59i80007l204l1ow01t4	cmprepa050001jp04hcbe0l2v
cmqyl59i8000cl2049cevofzb	1	40.00	40.00	\N	cmqyl59i80007l204l1ow01t4	cmpqqm3ot00063xvoeortkzib
cmqylepfg000kl2041t41nv5b	1	40.00	40.00	\N	cmqylepff000il204aj6lrrmi	cmpqqm4cx000a3xvo6ij5ksrm
cmqylseoo0003kz04tuuactcg	1	30.00	30.00	\N	cmqylseoo0001kz04luk3w457	cmpqqm7c800103xvol1ftobf3
cmqyma7970003l804e5mz4jqg	1	35.00	35.00	\N	cmqyma7970001l80423o6e1qy	cmpqqm4l9000c3xvojqoj1yyt
cmqynbmy60003jm04om8j1zy8	1	40.00	40.00	\N	cmqynbmy60001jm0420rys5i7	cmprepa050001jp04hcbe0l2v
cmqynlxtc0003l704o5hgblv7	1	35.00	35.00	\N	cmqynlxtb0001l704n1ujt39m	cmpqqm4l9000c3xvojqoj1yyt
cmqynlxtc0007l704bkkp7we5	1	35.00	35.00	\N	cmqynlxtb0001l704n1ujt39m	cmpqqm8iy001a3xvodugp204w
cmqynlxtc000bl704s97ui9q4	2	35.00	70.00	\N	cmqynlxtb0001l704n1ujt39m	cmpqqm4l9000c3xvojqoj1yyt
cmqynlxtc000fl704zpudja8y	1	40.00	40.00	\N	cmqynlxtb0001l704n1ujt39m	cmpqqm4t7000e3xvoazlktde5
cmqynx3nq000cjm0439n357io	1	40.00	40.00	เพิ่มโกโก้	cmqynx3nq000ajm04aybmf5jf	cmpqqm81900163xvo5msxvp3a
cmqyqzxsi000al404tb6qk8b8	1	35.00	35.00	\N	cmqyqzxsi0008l4046nu694oa	cmpqqma9x001q3xvo0d6239vc
cmqyr7p970003l704hiwgnjav	2	40.00	80.00	\N	cmqyr7p970001l704qnksm8yz	cmqyqvhd70001l404yqyqux46
cmqyr7w4m0009l704v15ms4xi	1	35.00	35.00	\N	cmqyr7w4m0007l704tpra1cj6	cmqyqvhd70001l404yqyqux46
cmqyr806q000fl70443yj14fs	1	30.00	30.00	\N	cmqyr806q000dl704ofw5w18i	cmqyqvhd70001l404yqyqux46
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.orders (id, "queueNo", status, note, subtotal, discount, total, "createdAt", "updatedAt", "userId", "discountId", "discountKind", "discountValue", "memberId", "pointsEarned", "pointsRedeemed", source, "couponCode", "pickupTime", "slipUrl", "slipUrls", "acknowledgedAt") FROM stdin;
cmpy8t5ah0009l504125vt8kh	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 15:50:15.305	2026-06-03 15:50:27.32	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpu4czuy0008jy048skwpqw7	2	COMPLETED	\N	45.00	0.00	45.00	2026-05-31 18:34:38.602	2026-05-31 18:36:13.076	\N	\N	\N	\N	cmpqxi3y80000jv042tmuxldv	4	0	ONLINE	\N	02:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3a2a8217-2c90-4333-877f-6fae46b6cd4f.jpg	\N	\N
cmprrzj440001jt04g0o4pnfx	1	COMPLETED	\N	40.00	0.00	40.00	2026-05-30 03:12:42.629	2026-05-30 03:18:46.633	cmprd13vv00003xwd57f832st	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	4	0	POS	\N	\N	\N	\N	\N
cmpr9cgwi00033xj31qufevei	1	CANCELLED	\N	40.00	9.00	31.00	2026-05-29 18:30:53.586	2026-05-31 18:36:48.217	\N	\N	AMOUNT	9.00	cmpr50gby0000l204k4iyqunq	3	0	ONLINE	540DB45DD382A4F7	01:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ede1cc03-a84e-4de0-82a7-8954e409be2f.png	\N	\N
cmprsdg5p0008jt04skruj31p	2	COMPLETED	\N	40.00	0.00	40.00	2026-05-30 03:23:31.981	2026-05-30 03:38:35.064	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	4	0	ONLINE	\N	10:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8a869431-4c3e-46da-902f-8bf03c2cc55a.jpeg	\N	\N
cmpw7yf7n003bjs044xfq7m6y	8	COMPLETED	\N	80.00	0.00	80.00	2026-06-02 05:50:49.475	2026-06-02 05:54:17.422	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpu4laht000ijy042ikyqdnr	3	COMPLETED	\N	40.00	0.00	40.00	2026-05-31 18:41:05.634	2026-05-31 18:43:31.357	\N	\N	\N	\N	cmpqxi3y80000jv042tmuxldv	4	0	ONLINE	\N	02:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1184ca6c-7fab-4e75-8fe6-0f119bf2f4f7.jpg	\N	\N
cmpw82lzi0001l4041sqpnwip	9	COMPLETED	\N	160.00	0.00	160.00	2026-06-02 05:54:04.878	2026-06-02 05:54:22.008	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpu59edy0000l804bjfgmfz2	4	COMPLETED	\N	40.00	0.00	40.00	2026-05-31 18:59:50.422	2026-05-31 19:01:21.591	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	4	0	ONLINE	\N	02:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/efe22e8d-0cf1-440c-9aa8-2275262dace0.jpeg	\N	\N
cmptyhvzb0000l804ucmfskuf	1	COMPLETED	\N	40.00	0.00	40.00	2026-05-31 15:50:29.159	2026-05-31 16:40:12.217	\N	\N	\N	\N	cmpqxi3y80000jv042tmuxldv	4	0	ONLINE	\N	00:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a75302fa-6f75-4261-84f5-07b05d76ec9b.jpg	\N	\N
cmprbxrj600003xv1wn5cwg4q	2	COMPLETED	\N	90.00	9.00	81.00	2026-05-29 19:43:26.368	2026-05-31 18:34:38.929	\N	\N	AMOUNT	9.00	cmpr50gby0000l204k4iyqunq	8	0	ONLINE	540DB45DD382A4F7	03:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/c26d615b-95be-4475-ac0c-1f1521e51d03.png	\N	\N
cmpuscer10000l704jawwp0xs	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-01 05:46:02.029	2026-06-01 05:48:15.363	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	4	0	ONLINE	\N	13:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/53f9ffb2-a91a-42d3-ae48-98a1fc164d0f.jpeg	\N	\N
cmpya2icv0000jr0483dlbk03	8	COMPLETED	\N	45.00	0.00	45.00	2026-06-03 16:25:31.76	2026-06-03 22:28:55.315	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	4	0	ONLINE	\N	00:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/18321159-e384-4aa1-b5d6-7d83fd64f9b2.jpeg	\N	\N
cmpushqhb000bl704j4943lbl	2	COMPLETED	\N	35.00	0.00	35.00	2026-06-01 05:50:10.511	2026-06-01 05:50:54.752	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	3	0	ONLINE	\N	13:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4c13d479-fc61-4e50-98ac-d475776c38e5.jpeg	\N	\N
cmpy8vdjy0000jo04autj6aeq	5	CANCELLED	\N	80.00	0.00	80.00	2026-06-03 15:51:59.326	2026-06-03 15:52:16.282	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	8	0	ONLINE	\N	23:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/87fcd80b-749a-423c-942d-2432d93a9254.jpeg	\N	\N
cmpy6et8w00013xozwek9fuyg	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 14:43:07.28	2026-06-03 15:46:08.289	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpw7m0j0000rjs04ayicm4w3	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-02 05:41:10.572	2026-06-02 05:51:49.718	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpw7lkgv000ijs04hyofli3c	2	COMPLETED	\N	140.00	0.00	140.00	2026-06-02 05:40:49.76	2026-06-02 05:51:51.405	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpw7kynu0001js043af1n07i	1	COMPLETED	\N	105.00	0.00	105.00	2026-06-02 05:40:21.499	2026-06-02 05:51:55.225	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpy9bomr0000js04wg0jzabt	7	COMPLETED	\N	50.00	0.00	50.00	2026-06-03 16:04:40.179	2026-06-03 22:28:38.687	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	5	0	ONLINE	\N	23:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b91c1778-5e8c-4fc5-b8a0-1319dd484b3d.jpeg	\N	\N
cmpw7okso0010js04oxd0l2ja	4	COMPLETED	\N	220.00	0.00	220.00	2026-06-02 05:43:10.152	2026-06-02 05:52:01.456	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpw7p6f3001ljs0493v3ovqi	5	COMPLETED	\N	135.00	0.00	135.00	2026-06-02 05:43:38.175	2026-06-02 05:52:11.084	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpy8wk4t0001kw049zwbalm2	6	COMPLETED	\N	50.00	0.00	50.00	2026-06-03 15:52:54.509	2026-06-03 15:53:48.427	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpw7u75d0021js04vam6tebi	6	COMPLETED	\N	390.00	0.00	390.00	2026-06-02 05:47:32.401	2026-06-02 05:52:18.467	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpy7dhzs00013xilojuzzw97	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 15:10:05.656	2026-06-03 15:49:51.363	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmpw7wuk2002vjs04gnhdu0p7	7	COMPLETED	\N	160.00	0.00	160.00	2026-06-02 05:49:36.05	2026-06-02 05:52:31.459	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpy8rgim0000l504nzvht0rq	3	COMPLETED	\N	85.00	0.00	85.00	2026-06-03 15:48:56.543	2026-06-03 15:49:53.002	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	8	0	ONLINE	\N	23:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/6322d16a-8dd9-478e-b898-eb92ff50b862.jpeg	\N	\N
cmpyn85rp0000jo046amu4tk5	10	COMPLETED	\N	155.00	0.00	155.00	2026-06-03 22:33:50.39	2026-06-03 23:24:39.807	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	15	0	ONLINE	\N	06:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/47a07cbe-2ea4-4367-917a-321df6a506b2.jpeg	\N	\N
cmpya51gg0005jr04o2x1r012	9	COMPLETED	ไม่ใส่น้ำเชื่อม	35.00	0.00	35.00	2026-06-03 16:27:29.825	2026-06-03 22:29:04.785	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	3	0	ONLINE	\N	23:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/c63e9dd6-fff4-4c0c-8742-a6d3c0ca046c.jpeg	\N	\N
cmpyo3c3f000bk305hw58ra46	12	COMPLETED	\N	70.00	0.00	70.00	2026-06-03 22:58:04.924	2026-06-03 23:33:26.873	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmpyo8l420001l7047zs7wc5q	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 23:02:09.891	2026-06-04 00:29:17.92	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmpyo24f70001k305w69f14oy	11	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 22:57:08.323	2026-06-03 23:11:21.226	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmpyos7o4000bl704y8zsr9oh	15	COMPLETED	\N	175.00	0.00	175.00	2026-06-03 23:17:25.589	2026-06-03 23:33:39.616	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmpyo5o8l000nk3059zpmxlnp	13	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 22:59:53.974	2026-06-03 23:25:36.566	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	06:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/c7f143b2-aaf1-4beb-8f37-22c2b785b3ad.jpeg	\N	\N
cmpypdxlc000kl704e97b6jei	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-03 23:34:18.96	2026-06-03 23:57:48.764	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpypoacr0001jp04t0pvmpi1	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-03 23:42:22.059	2026-06-04 00:07:57.78	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpypw91f000tl704gdmnje6v	19	COMPLETED	\N	80.00	0.00	80.00	2026-06-03 23:48:33.603	2026-06-04 00:26:58.08	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmpyrwtfj002al704z6n4zdkd	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 00:44:59.263	2026-06-04 00:50:59.035	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyov4k10000ju04ecmvai9z	16	COMPLETED	\N	120.00	0.00	120.00	2026-06-03 23:19:41.522	2026-06-04 00:07:50.536	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	12	0	ONLINE	\N	06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/89c7dc8a-ba7a-496d-ba95-82061a4f014c.jpeg	\N	\N
cmpyrwc2j0022l704v5dgi4oj	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:44:36.763	2026-06-04 00:51:03.19	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyqb4gh0013l704wwxhlkqm	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:00:07.505	2026-06-04 00:08:07.761	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmpyu5ney0000le049vr4ux0k	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 01:47:50.602	2026-06-04 07:03:28.988	\N	\N	\N	\N	cmpqxi3y80000jv042tmuxldv	4	0	ONLINE	\N	09:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/914201ad-a622-4488-a220-c40cd9ca49b8.jpg	\N	\N
cmpz5e57o0001jl04ndjnr903	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 07:02:22.693	2026-06-04 07:03:30.506	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrycrc002jl704kz47w8tu	12	COMPLETED	\N	70.00	0.00	70.00	2026-06-04 00:46:10.969	2026-06-04 00:55:17.197	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyqzle8001cl704f58q896q	3	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:19:09.2	2026-06-04 00:25:56.526	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpys032k001ljp04k6gxtkvp	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 00:47:31.724	2026-06-04 00:55:24.046	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq067dfz000ilb04tgxt3io3	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:12:52.56	2026-06-05 00:17:36.238	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrcbrw001tl704mobwy8li	6	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:29:03.26	2026-06-04 00:31:28.418	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyqtxgz000bjp043qd3fs2w	2	COMPLETED	\N	80.00	0.00	80.00	2026-06-04 00:14:44.915	2026-06-04 00:33:44.148	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpysbcsg0022jp04s2ddn7ae	15	COMPLETED	\N	30.00	0.00	30.00	2026-06-04 00:56:17.536	2026-06-04 00:59:45.307	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrbegh001kl7043gsxxdbo	5	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:28:20.082	2026-06-04 00:35:26.465	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpys7hzy001ujp0408t8disi	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:53:17.662	2026-06-04 00:59:54.302	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrgxvn000vjp04i8fcma6t	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:32:38.531	2026-06-04 00:39:26.904	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrlxmq0014jp04zv6o6vyo	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 00:36:31.49	2026-06-04 00:39:35.461	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq05vhyr000ml704lqvmx7bk	15	COMPLETED	\N	75.00	0.00	75.00	2026-06-05 00:03:38.547	2026-06-05 00:21:57.723	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyrs9ta001djp048hjxvets	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:41:27.214	2026-06-04 00:44:21.885	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpysnmna002ajp04yccow010	16	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 01:05:50.182	2026-06-04 01:10:53.37	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpzpklg2000j3xom2mmu1dqy	5	COMPLETED	\N	75.00	0.00	75.00	2026-06-04 16:27:15.986	2026-06-04 16:28:20.862	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	23:50	\N	\N	\N
cmpzmzky600013xmgkcxly408	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 15:14:56.33	2026-06-04 16:17:11.491	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq04h8b70001ju04pccgl4gt	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 23:24:33.236	2026-06-04 23:40:43.972	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyr4lyz000njp04kl5c34rf	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 00:23:03.227	2026-06-04 00:50:50.279	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpyteetj0000l1043odzmbbb	17	COMPLETED	\N	70.00	0.00	70.00	2026-06-04 01:26:39.751	2026-06-04 01:37:06.2	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	7	0	ONLINE	\N	08:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8fdaaea3-da15-4254-8bab-b985ab6d3312.jpeg	\N	\N
cmpzog3ud00043xomnrqdbumq	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 15:55:46.933	2026-06-04 16:18:33.921	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	00:00	\N	\N	\N
cmq03mjdo0001js046gquc8s7	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 23:00:41.244	2026-06-05 00:06:46.945	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmpzpakgw000b3xomrs2wflil	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 16:19:28.16	2026-06-04 16:24:51.887	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0607ve0002lb04kfq5p2wx	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 00:07:18.746	2026-06-05 00:42:53.125	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/87283051-0b7d-47a1-a4ef-a9ce8f152bfb.jpeg	\N	\N
cmq033frk0000jr047ttf5sut	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-04 22:45:50.097	2026-06-05 00:42:43.105	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	3	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fbfd1f3d-a663-4a7a-a6e5-2164ddf51f22.jpeg	\N	\N
cmq03wruo0007js04bw9vmhxi	11	COMPLETED	\N	120.00	0.00	120.00	2026-06-04 23:08:38.784	2026-06-05 00:42:48.122	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	12	0	ONLINE	\N	06:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a45bbef1-48ef-4a9b-a643-f6169d9ad64a.jpeg	\N	\N
cmpzn18t00002l804go4cusjg	2	COMPLETED	บริษัท เอ็กซาซีเลม ไปเอา 07:10น ค่ะ ปูเป้	250.00	0.00	250.00	2026-06-04 15:16:13.908	2026-06-05 00:07:51.011	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	25	0	ONLINE	\N	22:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/234dd298-6f07-4f25-a5d7-1274e0d481f6.jpeg	\N	\N
cmq03iklh0009jm04pktdyhzg	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-04 22:57:36.197	2026-06-05 00:08:09.067	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq05ihph0009l704llnb4lzg	14	COMPLETED	\N	70.00	0.00	70.00	2026-06-04 23:53:31.685	2026-06-04 23:59:16.179	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq06vtv40000jr05g818s0kz	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 00:31:53.584	2026-06-05 00:42:59.245	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/cf0c63ad-74e1-4e98-acc7-bd0a9c5c1c62.jpeg	\N	\N
cmq06gy610001jo04h607cspg	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:20:19.322	2026-06-05 00:43:13.229	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq05anbr0001l704v6czg26f	13	COMPLETED	\N	75.00	0.00	75.00	2026-06-04 23:47:25.719	2026-06-05 00:17:30.803	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq06lryv000cjo04e58gsuuf	19	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:24:04.567	2026-06-05 00:43:16.478	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq06nwi5000mjo04ikgif5bj	20	COMPLETED	\N	75.00	0.00	75.00	2026-06-05 00:25:43.757	2026-06-05 00:43:47.274	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq073zum0009jr05vxdzhzv5	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:38:14.591	2026-06-05 00:44:42.59	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq038s7a0000jm04iq6s93xw	8	COMPLETED	\N	45.00	0.00	45.00	2026-06-04 22:49:59.494	2026-06-05 00:43:06.816	\N	\N	\N	\N	cmq034bpi0009jr04rvfh744g	4	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b59ad898-8126-465a-805c-13d15655bfab.jpg	\N	\N
cmq06rx27000xjo047rfbe81p	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 00:28:51.103	2026-06-05 00:43:58.368	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq01tb4k0000jl04nnio0hsl	6	COMPLETED	\N	160.00	0.00	160.00	2026-06-04 22:09:57.908	2026-06-05 00:42:40.194	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	16	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/997b06e2-f3d2-40c1-9ba8-2cf8ee017680.jpeg	\N	\N
cmq07bqty0013jo04g8slvrk2	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:44:16.15	2026-06-05 00:46:21.527	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1jso1p0000l4047yyu3xai	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 23:21:07.262	2026-06-06 00:19:09.873	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7c02fa39-7d1c-467d-877a-1b94c2cd5323.jpeg	\N	\N
cmq07g3zc001ejo04te5eo8ju	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:47:39.816	2026-06-05 00:47:55.48	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0hb97i000aie04sfghxxh7	36	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 05:23:49.471	2026-06-05 05:26:10.712	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq07k7dh001ojo0465kqkk6i	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 00:50:50.837	2026-06-05 00:51:15.924	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1kl0fw000ql404r76egg3h	12	COMPLETED	\N	75.00	0.00	75.00	2026-06-05 23:43:09.693	2026-06-06 00:19:14.854	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq07r6oe001zjo042d28rh4p	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 00:56:16.526	2026-06-05 01:00:03.718	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq07r4bk001xjo04mzf783ak	27	COMPLETED	\N	0.00	0.00	0.00	2026-06-05 00:56:13.473	2026-06-05 01:00:33.167	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1m59t8001wl404cp5rvrv4	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-06 00:26:54.572	2026-06-06 00:49:14.934	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0htz850001i304o34f88yg	37	COMPLETED	\N	80.00	0.00	80.00	2026-06-05 05:38:22.998	2026-06-05 05:54:52.116	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq07x6jn0027jo04lt807js4	29	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 01:00:56.291	2026-06-05 01:01:03.914	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1jnwq30000le04w68is4ju	9	COMPLETED	ใส่น้ำส้ม30ml น้ำเปล่าแค่50ml พอนะ	40.00	0.00	40.00	2026-06-05 23:17:25.228	2026-06-05 23:28:45.551	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/53ae6866-f39b-4e43-ba54-877944a9c7b9.jpeg	\N	\N
cmq0i1ep70001jp04elz0ssov	38	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 05:44:09.643	2026-06-05 05:54:57.359	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1j9uqy000xld04w80mmdcz	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 23:06:29.482	2026-06-06 00:01:14.739	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq1irpg10000js04s9dnm156	3	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 22:52:22.801	2026-06-05 23:32:21.378	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f7a3a401-1675-4445-a3b0-dff02bdba95a.jpeg	\N	\N
cmq0igi48000djp04rdw0zwcc	39	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 05:55:53.912	2026-06-05 05:56:11.298	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0ba49w0001jr04jq89n3d4	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 02:34:58.724	2026-06-05 02:53:53.939	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0bailt0001jy04hajcs2nw	31	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 02:35:17.297	2026-06-05 02:53:55.401	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0by3100001jl04ifb8prdv	32	COMPLETED	\N	70.00	0.00	70.00	2026-06-05 02:53:36.852	2026-06-05 02:53:56.796	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0d7qmy0001ju04pjqyfrj3	33	COMPLETED	\N	105.00	35.00	70.00	2026-06-05 03:29:06.97	2026-06-05 03:29:24.164	cmprd13vv00003xwd57f832st	\N	AMOUNT	35.00	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0jchhy0001lg0410mvw1dc	40	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 06:20:46.102	2026-06-05 06:21:11.377	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0h2ywf0001l704pg7taii4	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 05:17:22.863	2026-06-05 05:20:21.336	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq0ha3nc0001ie04mwbcjwgr	35	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 05:22:55.609	2026-06-05 05:23:02.862	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq114w0z0000jm041r0x2r0z	1	COMPLETED	เอ็กซาซีเลม รับเวลา 07.10 (ปูเป้)\nโอนไป 2 ยอดนะคะ 95+10	105.00	0.00	105.00	2026-06-05 14:38:44.772	2026-06-06 00:18:28.491	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	10	0	ONLINE	\N	00:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f7dcb2cc-d3ec-4ec5-a1b7-2584185a53e3.jpeg	\N	\N
cmq1j8ao00009ld04wcuv55yt	5	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 23:05:16.801	2026-06-06 00:02:16.376	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1hwe630000kv04klzp66w9	2	COMPLETED	\N	80.00	0.00	80.00	2026-06-05 22:28:01.852	2026-06-06 00:18:36.29	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/24144d70-0339-4b51-a8db-1dd185c6eb28.jpeg	\N	\N
cmq1mn2u8001al204x09owya7	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:40:45.345	2026-06-06 00:48:33.101	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1lvzx5000al2048bv968a6	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:19:41.85	2026-06-06 00:27:48.188	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1j8vfb000gld0449sxklto	6	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 23:05:43.703	2026-06-06 00:04:06.935	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1kyktk0010l40474k7ctj8	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-05 23:53:42.633	2026-06-06 00:49:07.678	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1lea470001l204i4ox1gsn	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-06 00:05:55.256	2026-06-06 00:49:09.822	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1j7ldf0001ld0482lb9ucg	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 23:04:44.019	2026-06-06 00:18:45.45	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq1j9ers000mld04kspv7ko2	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-05 23:06:08.777	2026-06-06 00:18:54.46	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1914b577-f14d-4c1e-ab57-ee5da4af68b7.jpeg	\N	\N
cmq1kht9f000cl4043ymardtx	11	COMPLETED	\N	80.00	0.00	80.00	2026-06-05 23:40:40.419	2026-06-06 00:49:01.435	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ddd5d320-a7b1-49ca-9010-a1dff43a4980.jpeg	\N	\N
cmq1lq2qo001bl404bl5pkfn4	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-06 00:15:05.569	2026-06-06 00:27:54.899	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1mv31j001tl204cjjqo7x9	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-06 00:46:58.855	2026-06-06 00:49:26.139	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1mj2du0016l2045jfr7hzq	20	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:37:38.13	2026-06-06 00:49:23.444	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1misa5000zl2040ytnni9b	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:37:25.038	2026-06-06 00:41:27.901	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1m42o4000jl204j4s39q5s	17	COMPLETED	\N	115.00	0.00	115.00	2026-06-06 00:25:58.66	2026-06-06 00:48:36.698	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1mui5y001il204llon795b	23	COMPLETED	\N	70.00	0.00	70.00	2026-06-06 00:46:31.798	2026-06-06 00:53:34.22	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1mpf8r0024l404a7y95h31	22	COMPLETED	\N	75.00	0.00	75.00	2026-06-06 00:42:34.732	2026-06-06 01:03:49.833	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	7	0	ONLINE	\N	08:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1e213685-838d-4c03-84b9-8497cf7be118.jpeg	\N	\N
cmq1n86930001jq043dalfd09	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:57:09.543	2026-06-06 02:42:55.295	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1n4m220003jo04vsbqigyr	26	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:54:23.402	2026-06-06 01:03:55.208	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq1n0lod0022l2049b7xbprz	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-06 00:51:16.285	2026-06-06 01:05:08.3	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	\N	\N	\N	\N
cmq3wpg2n0001l204du6dqifh	2	COMPLETED	\N	35.00	0.00	35.00	2026-06-07 14:58:04.319	2026-06-07 22:56:12.779	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:00	\N	\N	\N
cmq1nwp660000jo04uxfhdmgv	28	COMPLETED	เอามาให้ที่ประตูเมื่อกี้นะคะ	115.00	0.00	115.00	2026-06-06 01:16:13.807	2026-06-06 02:42:51.971	\N	\N	\N	\N	cmq1np99f000gjo048bks9own	11	0	ONLINE	\N	08:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/71e341cd-70cd-4798-bfe5-909a0ac81d65.jpg	\N	\N
cmq4e0y6y0002jr0467ohj7al	18	COMPLETED	\N	115.00	0.00	115.00	2026-06-07 23:02:54.49	2026-06-07 23:35:48.709	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	11	0	ONLINE	\N	06:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/9e164d44-eb8a-46de-879e-949c87fc7cc0.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/9e164d44-eb8a-46de-879e-949c87fc7cc0.jpeg}	\N
cmq3x337z0009kz04qtt5vqh5	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-07 15:08:40.848	2026-06-07 22:56:26.793	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:10	\N	\N	\N
cmq3yelhs0001ky04x9894lxr	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:45:37.36	2026-06-07 22:55:40.49	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	15:50	\N	\N	\N
cmq3wyfme000dl204cw9ubkay	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:05:03.638	2026-06-07 15:26:53.759	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:10	\N	\N	\N
cmq4edy7y0009jy04i0t03bky	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 23:13:01.055	2026-06-08 00:18:30.597	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq3yvmtt0006l7040e6z8zvt	11	COMPLETED	ของเจมส์ครับ	40.00	0.00	40.00	2026-06-07 15:58:52.242	2026-06-07 22:55:48.904	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	4	0	ONLINE	\N	23:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3983e6f3-ba95-4495-b1a9-3fd50412d678.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3983e6f3-ba95-4495-b1a9-3fd50412d678.jpeg}	2026-06-07 15:59:05.55
cmq3wooeu0001l804kuzr342f	1	COMPLETED	\N	75.00	0.00	75.00	2026-06-07 14:57:28.47	2026-06-07 22:54:41.749	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	21:50	\N	\N	\N
cmq3wy7o10007l2041cmko7n2	3	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:04:53.329	2026-06-07 22:56:39.811	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:40	\N	\N	\N
cmq4ghtop000jl804muis7cqj	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:12:01.033	2026-06-08 00:17:58.008	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq3wznuq0001kz04nurdd92v	5	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:06:00.962	2026-06-07 22:56:03.188	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:10	\N	\N	\N
cmq4cnb2x0000k004gb57z98x	14	COMPLETED	\N	70.00	0.00	70.00	2026-06-07 22:24:18.393	2026-06-07 23:37:58.925	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	7	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/9bd9ea90-26e0-4af9-bc02-92b869f9459a.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/9bd9ea90-26e0-4af9-bc02-92b869f9459a.jpeg}	\N
cmq4dxpsb0000js046idgljfp	16	COMPLETED	\N	35.00	0.00	35.00	2026-06-07 23:00:23.628	2026-06-08 00:18:07.827	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	3	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/6c3f0608-b362-4f33-a2ae-b2de10c4586e.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/6c3f0608-b362-4f33-a2ae-b2de10c4586e.jpeg}	\N
cmq3xp7o0000ll2044708f1tg	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:25:53.04	2026-06-07 22:56:54.994	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:30	\N	\N	\N
cmq4fo7i90001l8044c2puwxv	20	COMPLETED	\N	75.00	0.00	75.00	2026-06-07 23:48:59.265	2026-06-08 00:18:13.745	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:20	\N	\N	\N
cmq4gf3u90008l804xk3zzlrl	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:09:54.226	2026-06-08 00:21:42.156	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3335dbdf-7b6a-42cd-b229-c21dc971169a.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3335dbdf-7b6a-42cd-b229-c21dc971169a.jpeg}	\N
cmq3yf3qi0001l7048ncz3zgv	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 15:46:01.002	2026-06-07 22:57:05.628	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	22:50	\N	\N	\N
cmq3yqbr70000jl04h71kd5ar	10	COMPLETED	แยกน้ำแข็ง	40.00	0.00	40.00	2026-06-07 15:54:44.612	2026-06-07 22:57:09.801	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	4	0	ONLINE	\N	23:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/69b73dc6-2a69-4114-9eea-b9fd399e3f5a.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/69b73dc6-2a69-4114-9eea-b9fd399e3f5a.jpeg}	2026-06-07 15:55:03.798
cmq4e00xp0001jr04f35am9hd	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 23:02:11.39	2026-06-08 00:17:36.119	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq4c5k7f0000lh04ajcehru4	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-07 22:10:30.411	2026-06-08 00:18:05.633	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	3	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4d0022aa-8f13-4105-ac0f-9982654659af.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4d0022aa-8f13-4105-ac0f-9982654659af.jpeg}	\N
cmq4fw1q50005l104068el22r	21	COMPLETED	\N	75.00	0.00	75.00	2026-06-07 23:55:05.021	2026-06-08 00:18:18.336	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:50	\N	\N	\N
cmq4fzln2000ll804nx62g2xm	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-07 23:57:50.799	2026-06-08 00:21:40.501	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/40113e00-997f-4d7f-8db6-ff29b3545778.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/40113e00-997f-4d7f-8db6-ff29b3545778.jpeg}	\N
cmq4dqtc40003jp04g9zzivy3	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-07 22:55:01.637	2026-06-08 00:06:28.929	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:00	\N	\N	\N
cmq4c2r220000jr04to75lb55	12	COMPLETED	\N	70.00	0.00	70.00	2026-06-07 22:08:19.322	2026-06-08 00:18:03.08	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	7	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/eaa6e37b-1d45-4b3d-a41d-f2d1baddd816.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/eaa6e37b-1d45-4b3d-a41d-f2d1baddd816.jpeg}	\N
cmq4fy94z000dl804mlz2mjya	22	COMPLETED	\N	55.00	0.00	55.00	2026-06-07 23:56:47.939	2026-06-08 00:17:49.916	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq4gbnu10001l804r9xduqb6	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:07:13.513	2026-06-08 00:17:55.044	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq4gxnwk000hjr04o12yoq3c	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:24:20.036	2026-06-08 00:31:18.333	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmq4higvo0014jr04o4iqz9ly	32	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:40:30.708	2026-06-08 00:48:06.844	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq4hkci6001cjr04f2h1z5bm	33	COMPLETED	\N	75.00	0.00	75.00	2026-06-08 00:41:58.35	2026-06-08 00:43:49.185	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq4h8bqd000qjr04ew4yaae6	29	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:32:37.478	2026-06-08 00:46:02.314	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	00:40	\N	\N	\N
cmq4hafzg000bjm04jajidhn8	31	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 00:34:16.3	2026-06-08 00:46:11.862	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq4h8s2l000xjr04g1of1a1o	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 00:32:58.654	2026-06-08 00:48:20.13	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq4h76r40001jm04oo5oc8e8	28	COMPLETED	\N	70.00	0.00	70.00	2026-06-08 00:31:44.369	2026-06-08 00:45:59.156	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq4hkzmq000hjm04614meh8y	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 00:42:28.322	2026-06-08 00:48:15.869	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq4hsyic000pjm04dm1d7iit	35	COMPLETED	\N	75.00	0.00	75.00	2026-06-08 00:48:40.116	2026-06-08 00:54:08.668	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq5tg4i1000dl5049cs206m7	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 23:02:22.922	2026-06-09 00:11:49.771	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	3	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fecd0add-ebaa-4ed1-a150-a8fef444aa04.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fecd0add-ebaa-4ed1-a150-a8fef444aa04.jpeg}	\N
cmq4icdtm0001ju0434ur99pq	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 01:03:46.426	2026-06-08 01:03:56.39	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq4qvttb0001js04s9aqx1c0	44	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 05:02:50.543	2026-06-08 05:31:32.979	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:00	\N	\N	\N
cmq4kw2vb0001ju04vlhvrfda	37	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 02:15:04.583	2026-06-08 02:20:03.132	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:10	\N	\N	\N
cmq4qwk6s0007js04xliroekn	45	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 05:03:24.724	2026-06-08 05:31:39.628	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:10	\N	\N	\N
cmq5utffz0001ks04exp6ucot	8	COMPLETED	\N	80.00	0.00	80.00	2026-06-08 23:40:43.248	2026-06-08 23:43:54.306	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq4ruj2g0001ju04vpivgkfz	48	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 05:29:49.576	2026-06-08 05:33:13.842	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:20	\N	\N	\N
cmq4le8uj0001kz04j4b5prfc	38	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 02:29:12.14	2026-06-08 02:46:51.67	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmq5tq5lt0000l804kevidzil	6	COMPLETED	\N	115.00	0.00	115.00	2026-06-08 23:10:10.914	2026-06-09 00:11:52.156	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	11	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a749b3b7-a73f-4b69-80f3-6f968a5ee239.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a749b3b7-a73f-4b69-80f3-6f968a5ee239.jpeg}	\N
cmq4ltlyo0001lh04zrbmpbvc	39	COMPLETED	\N	70.00	0.00	70.00	2026-06-08 02:41:08.976	2026-06-08 02:46:57.491	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq4ri5820001l204oupvmwdh	47	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 05:20:11.763	2026-06-08 05:43:24.777	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:20	\N	\N	\N
cmq4mqvuc0001l204btmo78mb	40	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 03:07:01.428	2026-06-08 03:11:03.191	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:50	\N	\N	\N
cmq5vh6uy0000jm0420zqs4qq	11	COMPLETED	\N	80.00	0.00	80.00	2026-06-08 23:59:11.867	2026-06-09 00:39:23.694	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	10	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/497e6997-6d5b-4ca6-a625-8b360db58549.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/497e6997-6d5b-4ca6-a625-8b360db58549.jpeg}	\N
cmq5uph800002kz04l96olp0d	7	COMPLETED	\N	75.00	0.00	75.00	2026-06-08 23:37:38.928	2026-06-09 00:24:27.58	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	9	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d7cb6a2e-5f13-4f52-ae05-8a4535747692.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d7cb6a2e-5f13-4f52-ae05-8a4535747692.jpeg}	\N
cmq4qav2q0001ju04oo3ddg46	41	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 04:46:32.402	2026-06-08 04:57:55.709	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	04:50	\N	\N	\N
cmq4szpi50001jl04lyf1l0by	49	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 06:01:50.813	2026-06-08 06:02:25.273	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:30	\N	\N	\N
cmq4qqx4z0001jy04971t6ffv	42	COMPLETED	\N	75.00	0.00	75.00	2026-06-08 04:59:01.572	2026-06-08 05:05:41.867	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:50	\N	\N	\N
cmq5tkrk30000jm04v7eptx56	5	COMPLETED	\N	70.00	0.00	70.00	2026-06-08 23:05:59.427	2026-06-08 23:29:51.054	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1dc8acc7-4b68-4a5e-9f98-88796b130773.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1dc8acc7-4b68-4a5e-9f98-88796b130773.jpeg}	\N
cmq4qrh3i000cjy04rkdrszaa	43	COMPLETED	\N	80.00	0.00	80.00	2026-06-08 04:59:27.438	2026-06-08 05:13:00.929	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:00	\N	\N	\N
cmq4rhdk50001jp04ti7p9qtu	46	COMPLETED	\N	15.00	0.00	15.00	2026-06-08 05:19:35.91	2026-06-08 05:19:47.206	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:10	\N	\N	\N
cmq5vfvir000ale048otfzs36	10	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 23:58:10.515	2026-06-09 00:11:28.687	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:40	\N	\N	\N
cmq5tjcm10001jr04vqmxbfqh	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-08 23:04:53.401	2026-06-09 00:17:17.395	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	23:10	\N	\N	\N
cmq5vo5no0001jr04zvj1gkgc	13	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 00:04:36.9	2026-06-09 00:11:40.102	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq5t5rru0000l5042bio6uw7	2	COMPLETED	\N	105.00	0.00	105.00	2026-06-08 22:54:19.866	2026-06-09 00:11:46.493	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	10	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d6a0b63b-b676-4209-b26e-c59dd5a80414.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d6a0b63b-b676-4209-b26e-c59dd5a80414.jpeg}	\N
cmq5s9aoe0000ju04scxlmgnf	1	COMPLETED	\N	70.00	0.00	70.00	2026-06-08 22:29:04.719	2026-06-09 00:39:19.949	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e37fae1d-dd40-472e-845d-2e61b0dbd171.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e37fae1d-dd40-472e-845d-2e61b0dbd171.jpeg}	\N
cmq5wlg1i0002jy04yvyhdr45	16	COMPLETED	\N	115.00	0.00	115.00	2026-06-09 00:30:30.006	2026-06-09 00:39:37.743	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmq5vs9zv0001kv042knvlzqz	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:07:49.147	2026-06-09 00:17:23.816	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq5vk5gz000djm04olj3rzqp	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:01:30.036	2026-06-09 00:11:26.716	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq5vzgks000akv04rurmz5c8	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:13:24.269	2026-06-09 00:17:44.598	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq5wp4nu000bl804wnl9yh39	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:33:21.882	2026-06-09 00:45:17.609	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq5wnwgd000kjy04a6rzb1ug	17	COMPLETED	\N	75.00	0.00	75.00	2026-06-09 00:32:24.589	2026-06-09 00:45:12.851	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq5wswte000kl80438byq14d	19	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:36:18.338	2026-06-09 00:48:17.439	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq5x8ymb0001jo04ogbf5o5l	22	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:48:47.171	2026-06-09 00:54:21.092	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq5x9gq00008jo048nn42gga	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:49:10.633	2026-06-09 00:54:32.13	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq5x7s000013jy04wp6i0z7g	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 00:47:51.936	2026-06-09 00:54:28.258	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq5vfhdn0000le04nau7i8rb	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-08 23:57:52.187	2026-06-09 00:39:13.672	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1ed58f9a-0ea2-4cd9-9a76-e31e287fc192.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1ed58f9a-0ea2-4cd9-9a76-e31e287fc192.jpeg}	\N
cmq61cze5000ajv04bwsz3vgl	32	COMPLETED	\N	110.00	0.00	110.00	2026-06-09 02:43:53.261	2026-06-09 02:50:40.315	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmq5x06rn000vjy0446row018	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 00:41:57.827	2026-06-09 00:46:24.961	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq793pjd0001jp04levxg68p	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 23:08:23.69	2026-06-10 00:50:02.408	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq5xnr2n001ejy04lmlsjpn7	24	COMPLETED	\N	30.00	0.00	30.00	2026-06-09 01:00:17.231	2026-06-09 01:02:06.394	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq61kwhi000jjp04savbjmxm	33	COMPLETED	\N	120.00	0.00	120.00	2026-06-09 02:50:02.743	2026-06-09 02:58:30.2	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:50	\N	\N	\N
cmq5zubfg0001ld04q02sryj9	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 02:01:22.781	2026-06-09 02:01:28.815	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmq5zwq1u0001l4046acqex6c	26	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 02:03:15.042	2026-06-09 02:07:47.323	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmq5zyjnd000al404ywy1lt9w	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 02:04:40.058	2026-06-09 02:08:42.886	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmq62bn1c0001l704jul62js8	34	COMPLETED	\N	80.00	0.00	80.00	2026-06-09 03:10:50.208	2026-06-09 03:15:16.933	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:50	\N	\N	\N
cmq78wz8v0001l504of56r07u	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 23:03:09.679	2026-06-09 23:13:45.697	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq60oagn0001jl04n10m83xh	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 02:24:41.207	2026-06-09 02:26:25.477	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmq62drkr0001ji041l91k2p8	35	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 03:12:29.403	2026-06-09 03:15:28.701	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:10	\N	\N	\N
cmq60ukbb0001jp040a2njvi2	29	COMPLETED	\N	115.00	0.00	115.00	2026-06-09 02:29:33.912	2026-06-09 02:34:41.928	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq78x7iv0008l5044n7pamfj	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 23:03:20.407	2026-06-09 23:13:51.133	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq63eera0001l404hii1ktqi	36	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 03:40:59.063	2026-06-09 03:46:54.18	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:40	\N	\N	\N
cmq610y3r0001js04tu34r85g	30	COMPLETED	\N	75.00	0.00	75.00	2026-06-09 02:34:31.72	2026-06-09 02:40:25.166	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq7ayit00000l504ki72wer9	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:00:20.916	2026-06-10 00:11:04.63	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7e572c4e-d66e-42a5-9426-96254a9a517d.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7e572c4e-d66e-42a5-9426-96254a9a517d.jpeg}	\N
cmq78xijx000fl504gy8sg7lf	5	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 23:03:34.701	2026-06-09 23:13:59.538	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq7a4ak30000jv04bxzlkgs2	8	COMPLETED	เดียวจะมีคนไปเอาแจ้งเลขออเดอร์รอเขาลงไปแล้วค่อยใส่น้ำแข็ง	75.00	0.00	75.00	2026-06-09 23:36:50.548	2026-06-09 23:54:39.295	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	9	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1b827ee8-c1f8-47c1-a96e-09b15191ef98.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1b827ee8-c1f8-47c1-a96e-09b15191ef98.jpeg}	\N
cmq618yr40001jv04f6hefwyp	31	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 02:40:45.808	2026-06-09 02:47:00.46	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmq63em2m0008l4045ifhngap	37	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 03:41:08.542	2026-06-09 03:47:00.543	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:40	\N	\N	\N
cmq78xvav000ml5044mi07d75	6	COMPLETED	\N	50.00	0.00	50.00	2026-06-09 23:03:51.223	2026-06-09 23:14:21.55	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq7asad70004jx04a8njafgl	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 23:55:30.044	2026-06-10 00:11:09.701	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b2ae3fe7-7e2d-427b-b4cd-a5bede8af226.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b2ae3fe7-7e2d-427b-b4cd-a5bede8af226.jpeg}	\N
cmq77yrtg0000ju04tahgagvy	1	COMPLETED	\N	110.00	0.00	110.00	2026-06-09 22:36:33.749	2026-06-09 23:26:40.814	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	13	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04b43407-9343-4601-a8ff-d4949541d528.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04b43407-9343-4601-a8ff-d4949541d528.jpeg}	\N
cmq7b9zbk000al504o0id4j6t	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:09:15.537	2026-06-10 00:12:26.57	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq7bhu83000ol5047kuqj32x	16	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:15:22.179	2026-06-10 00:17:41.898	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq7b7csl000ejx04lnfihuwh	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:07:13.029	2026-06-10 00:13:00.591	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:40	\N	\N	\N
cmq7bve060017l504zo89izjv	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:25:54.342	2026-06-10 00:52:42.258	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmq7a7d9t0001l204l2kj4957	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-09 23:39:14.034	2026-06-10 00:17:12.034	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq7bagqh000hl5047ml1sw8i	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:09:38.105	2026-06-10 00:12:47.314	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq78vwei0001js04n826opn2	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-09 23:02:19.338	2026-06-10 00:13:21.074	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq7bcr6l0004l4046p8u67e1	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:11:24.958	2026-06-10 00:17:53.394	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b0c520f0-6ada-4305-8686-6cbfb8866d94.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b0c520f0-6ada-4305-8686-6cbfb8866d94.jpeg}	\N
cmq7bokil000zl504zhgbtz8c	17	COMPLETED	\N	45.00	0.00	45.00	2026-06-10 00:20:36.19	2026-06-10 00:25:18.719	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmq7c4qve001el504quna1zfp	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:33:10.922	2026-06-10 00:39:40.811	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq7cb7aq000ujx04vwpsbm06	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:38:12.146	2026-06-10 00:50:17.268	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq7cg2d50023l504ap9eyhtw	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:41:59.033	2026-06-10 00:57:43.308	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq7c3rsp000mjx04hv5wi089	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:32:25.465	2026-06-10 00:51:56.876	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq67fyce0001k004zyndmnxk	38	COMPLETED	\N	145.00	0.00	145.00	2026-06-09 05:34:09.566	2026-06-16 03:57:18.828	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	05:40	\N	\N	\N
cmq7c6ksj001nl504w7mewddo	21	COMPLETED	\N	115.00	0.00	115.00	2026-06-10 00:34:36.355	2026-06-10 00:48:18.417	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq7cpoul0029l504cspijlew	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 00:49:28.077	2026-06-10 00:49:42.533	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq7ceuj00011jx04fb5vqojj	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:41:02.22	2026-06-10 00:50:28.684	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq7cy4hd002ll504gkgj43x7	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 00:56:01.586	2026-06-10 01:00:42.392	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmq7hzn710001jx04ckv06qyg	38	COMPLETED	\N	85.00	0.00	85.00	2026-06-10 03:17:10.574	2026-06-10 03:22:27.218	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmq7csl4l0019jx044amxrush	26	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 00:51:43.221	2026-06-10 00:58:44.656	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	00:50	\N	\N	\N
cmq7f4sgv0001l504ta16mwbs	28	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 01:57:11.839	2026-06-10 02:01:03.944	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmq7faodz0001i904csl3bg2w	29	COMPLETED	\N	80.00	0.00	80.00	2026-06-10 02:01:46.487	2026-06-10 02:01:53.819	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:00	\N	\N	\N
cmq7k1ws10001jv04torizare	40	COMPLETED	\N	30.00	0.00	30.00	2026-06-10 04:14:55.537	2026-06-10 04:15:24.639	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:20	\N	\N	\N
cmq7gifyr0001l404dwdralsk	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 02:35:48.435	2026-06-10 02:36:12.833	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	05:40	\N	\N	\N
cmq7gisgv000al404qfkmrjx3	31	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 02:36:04.639	2026-06-10 02:36:19.135	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmq7lhpbt0001ie04bpctbj88	41	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 04:55:11.993	2026-06-10 04:56:15.038	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	04:50	\N	\N	\N
cmq7j0f3e00013xjtcb3vgfda	39	COMPLETED	\N	50.00	0.00	50.00	2026-06-10 03:45:46.343	2026-06-10 04:56:25.212	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:30	\N	\N	\N
cmq7gx6lk000jl4046rd8gzaw	32	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 02:47:16.136	2026-06-10 02:51:53.67	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmq8nljlp0000k504ybgamm2p	1	COMPLETED	\N	215.00	0.00	215.00	2026-06-10 22:41:56.605	2026-06-10 23:24:36.162	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	26	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/c55cab57-4b6f-4622-9b51-c42289a58fbd.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/c55cab57-4b6f-4622-9b51-c42289a58fbd.jpeg}	\N
cmq7mb23t0005la04zcuigdic	42	COMPLETED	\N	45.00	0.00	45.00	2026-06-10 05:18:01.578	2026-06-10 05:18:33.563	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:00	\N	\N	\N
cmq7gxwrn000tl404ga1qa4j9	33	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 02:47:50.051	2026-06-10 03:03:11.982	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:50	\N	\N	\N
cmq7h2whm0001lb04t5dtediw	34	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 02:51:42.97	2026-06-10 03:03:17.303	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:50	\N	\N	\N
cmq7h8xl7000clb046p73sm3v	35	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 02:56:24.332	2026-06-10 03:03:19.927	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmq7hau7h0014l404wy9fcjc2	36	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 02:57:53.261	2026-06-10 03:03:23.458	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmq7nrx8e0001l104ydbdftuo	47	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 05:59:08.03	2026-06-10 06:13:32.81	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:50	\N	\N	\N
cmq7nsx2l0001l504kejmwuq9	48	COMPLETED	\N	70.00	0.00	70.00	2026-06-10 05:59:54.478	2026-06-10 06:13:35.907	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:00	\N	\N	\N
cmq7ntbex000el504b7x1w3xu	49	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 06:00:13.066	2026-06-10 06:13:42.404	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:00	\N	\N	\N
cmq7mf1n4000dla04oc09ngst	43	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 05:21:07.6	2026-06-10 05:24:00.94	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:20	\N	\N	\N
cmq8ovw360000k3042klqx77h	3	COMPLETED	\N	50.00	0.00	50.00	2026-06-10 23:17:58.963	2026-06-11 00:19:46.857	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	5	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b429447b-02a1-4d8a-96d3-6a21c78f69e7.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b429447b-02a1-4d8a-96d3-6a21c78f69e7.jpeg}	\N
cmq7mjt2a0001jr04lxq5g0sk	44	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 05:24:49.762	2026-06-10 05:45:13.117	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:30	\N	\N	\N
cmq7mkear000cjr043vwpfrm7	45	COMPLETED	\N	40.00	0.00	40.00	2026-06-10 05:25:17.283	2026-06-10 05:45:18.18	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:30	\N	\N	\N
cmq7nxaav000cl104dtxiupwb	50	COMPLETED	\N	70.00	0.00	70.00	2026-06-10 06:03:18.248	2026-06-10 06:14:53.228	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:10	\N	\N	\N
cmq7msmeq0001jy04wvfdb2jd	46	COMPLETED	\N	70.00	0.00	70.00	2026-06-10 05:31:41.042	2026-06-10 05:45:23.268	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:30	\N	\N	\N
cmq8pnnoh0001ih04vfrf667z	4	COMPLETED	\N	75.00	0.00	75.00	2026-06-10 23:39:34.434	2026-06-10 23:43:55.097	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:10	\N	\N	\N
cmq7o16oh000nl504n8fzjyqn	51	COMPLETED	\N	60.00	0.00	60.00	2026-06-10 06:06:20.177	2026-06-10 06:19:19.912	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:10	\N	\N	\N
cmq8prlhj0000js04teqhwo8p	5	COMPLETED	\N	70.00	0.00	70.00	2026-06-10 23:42:38.216	2026-06-10 23:49:39.793	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/59fefe9c-15c2-4010-8238-196aecce3de0.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/59fefe9c-15c2-4010-8238-196aecce3de0.jpeg}	\N
cmq8qw643000ji604v14hsfnl	11	COMPLETED	\N	15.00	0.00	15.00	2026-06-11 00:14:11.188	2026-06-11 00:14:24.82	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq8qcmk4000ki804tm3s43hq	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-10 23:58:59.38	2026-06-11 00:02:42.27	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq8qbbiz0001i804b6ytk86t	6	COMPLETED	\N	50.00	0.00	50.00	2026-06-10 23:57:58.427	2026-06-11 00:02:44.056	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:40	\N	\N	\N
cmq8qji0m0001i604ek4v1oc6	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 00:04:20.086	2026-06-11 00:14:28.966	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmq8qny5w000ai6043947j4he	10	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 00:07:47.637	2026-06-11 00:14:27.213	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmq8qbnil000ai804jju7b3bw	7	COMPLETED	\N	50.00	0.00	50.00	2026-06-10 23:58:13.965	2026-06-11 00:14:20.622	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/35ca29c8-c246-457d-9ed6-ec3997cfc553.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/35ca29c8-c246-457d-9ed6-ec3997cfc553.jpeg}	\N
cmq8rbxw4000ajo04dvpwz0gn	13	COMPLETED	\N	75.00	0.00	75.00	2026-06-11 00:26:27.028	2026-06-11 00:38:14.683	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmq8okvwv0000jv04zuzsd30a	2	COMPLETED	\N	180.00	0.00	180.00	2026-06-10 23:09:25.52	2026-06-11 00:19:44.911	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	18	0	ONLINE	\N	07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f451dfa2-9d2a-4b15-addc-e2f7a220e750.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f451dfa2-9d2a-4b15-addc-e2f7a220e750.jpeg}	\N
cmq7hgfzy0000k00428coxwvj	37	COMPLETED	\N	155.00	0.00	155.00	2026-06-10 03:02:14.783	2026-06-16 03:56:17.398	\N	\N	\N	\N	cmq7hdolg000klb04x9d9hye6	15	0	ONLINE	\N	10:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/31563055-5e16-4797-897d-e768b9d78ddd.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/31563055-5e16-4797-897d-e768b9d78ddd.jpeg}	2026-06-10 03:05:37.535
cmq8r28ci0000jo04dib4mjur	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 00:18:54.019	2026-06-11 00:28:45.411	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fbadce57-6c48-4643-a06b-fa20db145783.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fbadce57-6c48-4643-a06b-fa20db145783.jpeg}	\N
cmq8rcypz000mjo04f7zb2b33	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 00:27:14.76	2026-06-11 00:29:13.604	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq92lzws0008jl04n2h4ugql	35	COMPLETED	\N	115.00	0.00	115.00	2026-06-11 05:42:11.98	2026-06-11 05:53:49.515	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:40	\N	\N	\N
cmq8voquw000fjx0442s3nl96	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 02:28:22.904	2026-06-11 02:38:33.821	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq8rmcgi0003l204t5vw9rqd	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 00:34:32.467	2026-06-11 00:38:32.599	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmq8vuj1d000mjx04g8t3g0bz	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 02:32:52.706	2026-06-11 02:39:20.266	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmqa88zjs0001la04wa3kh58q	5	COMPLETED	\N	75.00	0.00	75.00	2026-06-12 01:07:48.856	2026-06-12 01:10:06.561	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	01:10	\N	\N	\N
cmq8vzsb60001kt04lfbscle2	28	COMPLETED	\N	130.00	0.00	130.00	2026-06-11 02:36:58.003	2026-06-11 02:47:06.808	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmq8rybua0015i604tyb0tc3v	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 00:43:51.538	2026-06-11 00:47:23.433	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq93ntbk0001jy049azdpsb7	36	COMPLETED	\N	145.00	0.00	145.00	2026-06-11 06:11:36.368	2026-06-11 06:25:08.33	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:50	\N	\N	\N
cmq8rns44000wjo0412zihgag	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 00:35:39.412	2026-06-11 00:48:21.642	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq8rn7af000ri604030l04to	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 00:35:12.424	2026-06-11 00:48:31.545	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq8ry5kv000yi604keu3rl3q	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 00:43:43.424	2026-06-11 00:48:41.678	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmq8widpi0001jn04ij5wkjif	29	COMPLETED	\N	80.00	0.00	80.00	2026-06-11 02:51:25.542	2026-06-11 02:56:10.192	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmq8s3ukb0001l1048336hs11	20	COMPLETED	\N	70.00	0.00	70.00	2026-06-11 00:48:09.083	2026-06-11 00:53:49.392	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq8sbfk2000gl104lyzfkcoa	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 00:54:02.882	2026-06-11 00:54:07.414	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmq8wkfs7000djn04ewp2bq2o	30	COMPLETED	\N	75.00	0.00	75.00	2026-06-11 02:53:01.543	2026-06-11 03:02:56.929	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmq8wtc0v000pjn04lvb0nzgm	31	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 02:59:56.575	2026-06-11 03:03:28.977	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmq8sdqca000pl1049qo5sjve	22	COMPLETED	\N	45.00	0.00	45.00	2026-06-11 00:55:50.171	2026-06-11 01:00:56.428	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmq8vjo4w0001js04ql4nlf36	23	COMPLETED	\N	30.00	0.00	30.00	2026-06-11 02:24:26.096	2026-06-11 02:25:43.851	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmq95z0oq0001jf04djb6mrz9	37	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 07:16:18.362	2026-06-11 07:16:32.593	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	14:20	\N	\N	\N
cmq8vo54e0001jx04ogew8vi3	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 02:27:54.734	2026-06-11 02:33:00.888	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq8vojuw0008jx04lx39g917	25	COMPLETED	\N	80.00	0.00	80.00	2026-06-11 02:28:13.833	2026-06-11 02:38:25.291	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmq8xx7x70001l104wenrsc6n	32	COMPLETED	\N	35.00	0.00	35.00	2026-06-11 03:30:57.499	2026-06-11 03:39:12.179	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmqa9s7vd000al8041vwp2yyz	9	COMPLETED	\N	95.00	0.00	95.00	2026-06-12 01:50:45.721	2026-06-12 01:54:37.677	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:50	\N	\N	\N
cmq92k7200001jl04dnymjlps	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-11 05:40:47.928	2026-06-11 05:44:47.502	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:30	\N	\N	\N
cmqa7hftw0002ju04khs7s5dj	1	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 00:46:23.588	2026-06-12 00:46:58.389	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:20	\N	\N	\N
cmqa7k8bs0001ic04v9ygvtrp	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 00:48:33.832	2026-06-12 00:50:38.355	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqa94h6c0001i904lt9wwjga	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 01:32:18.036	2026-06-12 01:35:34.353	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:10	\N	\N	\N
cmqa7hxla000bju04wq3kip3e	2	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 00:46:46.606	2026-06-12 00:50:45.251	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqa96bl10001l804va9b3q4r	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 01:33:44.101	2026-06-12 01:39:14.105	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:40	\N	\N	\N
cmqa7o7xd000iju0430igs9dj	4	COMPLETED	\N	85.00	0.00	85.00	2026-06-12 00:51:39.937	2026-06-12 00:57:46.958	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqa9v70q0009la04pmobcmr4	10	COMPLETED	\N	50.00	0.00	50.00	2026-06-12 01:53:04.586	2026-06-12 01:56:46.252	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:50	\N	\N	\N
cmqa9l9hl0001la04a6pmhncp	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 01:45:21.225	2026-06-12 01:46:35.655	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:40	\N	\N	\N
cmqaa98d2000tla04wc4t4p8z	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 02:03:59.511	2026-06-12 02:13:22.141	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqaa4j24000gla04xzk07cnf	11	COMPLETED	\N	55.00	0.00	55.00	2026-06-12 02:00:20.092	2026-06-12 02:04:08.879	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:00	\N	\N	\N
cmqaa6ttu000zl8041q45llcp	13	COMPLETED	\N	115.00	0.00	115.00	2026-06-12 02:02:07.363	2026-06-12 02:13:18.143	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqaa5r3f000sl804yp50p1rz	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 02:01:17.163	2026-06-12 02:05:31.62	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:00	\N	\N	\N
cmqaan28g0001ky04ffhfqjts	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 02:14:44.752	2026-06-12 02:17:29.103	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqae4s3p000al5040pbitj8g	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 03:52:30.277	2026-06-12 03:56:47.714	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:50	\N	\N	\N
cmqae0r1z0001l404odmfvjp1	17	COMPLETED	\N	80.00	0.00	80.00	2026-06-12 03:49:22.295	2026-06-12 03:49:59.929	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:20	\N	\N	\N
cmqae26dv0001l50425g2bpi8	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 03:50:28.819	2026-06-12 03:50:37.787	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:50	\N	\N	\N
cmqacvntj0001k004mj7x6j09	16	COMPLETED	\N	115.00	0.00	115.00	2026-06-12 03:17:25.207	2026-06-12 03:53:43.802	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqaee63v000al404x9r7buaz	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 03:59:48.331	2026-06-12 04:03:05.606	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:00	\N	\N	\N
cmqaehamu000il404helckqir	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 04:02:14.167	2026-06-12 04:03:11.645	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:00	\N	\N	\N
cmqaffjas0001l504xksxb12w	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 04:28:51.7	2026-06-12 05:43:51.349	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:10	\N	\N	\N
cmqafp3gv0001kt04r4sfhpd1	23	COMPLETED	\N	15.00	0.00	15.00	2026-06-12 04:36:17.744	2026-06-12 05:43:53.768	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:30	\N	\N	\N
cmqegeddl0007l40461h6z6kl	16	COMPLETED	\N	70.00	0.00	70.00	2026-06-15 00:07:01.689	2026-06-15 00:16:15.628	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ba4a604f-3098-433f-80b0-8fb6b94c947c.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ba4a604f-3098-433f-80b0-8fb6b94c947c.jpeg}	2026-06-15 00:08:47.235
cmqdv4b93000q3xapzueyweuf	2	CANCELLED	ทดสอบ ครั้งที่ 2	40.00	5.00	35.00	2026-06-14 14:11:20.44	2026-06-14 14:36:40.697	\N	\N	AMOUNT	5.00	cmpr50gby0000l204k4iyqunq	3	0	ONLINE	76FD6CD2387B86D6	2026-06-15T01:00:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/33a8555f-fb6e-495c-ae08-a8a1c95d6d6f.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/33a8555f-fb6e-495c-ae08-a8a1c95d6d6f.jpg}	\N
cmqaice7v0001l704dbrp72ta	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 05:50:23.995	2026-06-12 06:01:03.927	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:50	\N	\N	\N
cmqaib4eu0001l204jyly2ubl	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 05:49:24.63	2026-06-12 06:01:07.667	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:40	\N	\N	\N
cmqdw2koa0004kz04d6aywjbj	3	CANCELLED	123	35.00	5.00	30.00	2026-06-14 14:37:58.955	2026-06-14 14:40:52.584	\N	\N	AMOUNT	5.00	cmprr5tw70000l404nwvbr3wm	3	0	ONLINE	76FD6CD2387B86D6	02:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/138a4ea1-0368-4cf5-8d0c-72031e6e6d95.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/138a4ea1-0368-4cf5-8d0c-72031e6e6d95.jpeg}	\N
cmqair9hn000eib04n5wcyswl	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 06:01:57.708	2026-06-12 06:02:15.878	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:10	\N	\N	\N
cmqaipwww0001ib04f1k6jjk6	26	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 06:00:54.752	2026-06-12 06:08:36.095	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:50	\N	\N	\N
cmqaiqg540008ib044sa8hid1	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-12 06:01:19.672	2026-06-12 06:08:41.26	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:00	\N	\N	\N
cmqaj4e6e0005ky04ggvve583	29	COMPLETED	\N	105.00	0.00	105.00	2026-06-12 06:12:10.311	2026-06-12 06:24:44.057	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:10	\N	\N	\N
cmqdw5v990000lb04g5ikfk4d	4	CANCELLED	ของเจมส์	40.00	0.00	40.00	2026-06-14 14:40:32.637	2026-06-14 14:40:55.551	\N	\N	\N	\N	cmprr5tw70000l404nwvbr3wm	4	0	ONLINE	\N	2026-06-14T15:00:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/814e05e8-e045-46fc-a8ab-cf79beb0ccdd.png	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/814e05e8-e045-46fc-a8ab-cf79beb0ccdd.png}	\N
cmqajkqkh0003i804v79h5ant	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-12 06:24:52.866	2026-06-12 06:38:27.096	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:20	\N	\N	\N
cmqajq74g0001ld043b4b6ouz	31	COMPLETED	\N	200.00	0.00	200.00	2026-06-12 06:29:07.6	2026-06-12 06:40:25.834	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	13:30	\N	\N	\N
cmqeg6svc000wjq04061val8b	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:01:08.52	2026-06-15 00:06:28.652	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqefz0ah000wl7046feyedr3	11	COMPLETED	\N	75.00	0.00	75.00	2026-06-14 23:55:04.889	2026-06-14 23:59:59.813	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqefmr0t000gjq045lm8nln2	9	COMPLETED	\N	65.00	0.00	65.00	2026-06-14 23:45:33.005	2026-06-14 23:49:09.959	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:50	\N	\N	\N
cmqefljug000nl704srmir2lv	8	COMPLETED	\N	50.00	0.00	50.00	2026-06-14 23:44:37.049	2026-06-14 23:50:26.268	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	23:10	\N	\N	\N
cmqegd94j0001ju04y1dcckkq	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:06:09.523	2026-06-15 00:08:35.906	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmqeg8tsi0013jq045drd16n9	13	COMPLETED	\N	55.00	0.00	55.00	2026-06-15 00:02:43.026	2026-06-15 00:05:11.881	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmqege2tl0001l404tzbsbout	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:06:48.009	2026-06-15 00:09:40.868	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmqefe5od0000jq044w3dkn08	7	COMPLETED	\N	110.00	5.00	105.00	2026-06-14 23:38:52.093	2026-06-15 00:22:56.19	\N	\N	AMOUNT	5.00	cmpzm4vyo0000jv04i6eeh20d	10	0	ONLINE	76FD6CD2387B86D6	07:20	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d26f999b-3e46-4eae-a8f0-aa3fea15ab5e.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d26f999b-3e46-4eae-a8f0-aa3fea15ab5e.jpeg}	2026-06-14 23:49:39.444
cmqegolty0000jm04k5lmygkn	19	COMPLETED	\N	15.00	0.00	15.00	2026-06-15 00:14:59.207	2026-06-15 00:15:37.969	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	1	0	ONLINE	\N	2026-06-15T00:30:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0b40bed0-2eae-452e-bbe0-4d5ecef6c680.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0b40bed0-2eae-452e-bbe0-4d5ecef6c680.jpeg}	2026-06-15 00:15:28.953
cmqee26ja0001i005b85yae0i	5	COMPLETED	\N	40.00	0.00	40.00	2026-06-14 23:01:33.718	2026-06-15 00:11:54.59	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqeev0u00000l704f78yugzj	6	COMPLETED	\N	165.00	0.00	165.00	2026-06-14 23:23:59.352	2026-06-15 00:23:47.299	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	20	0	ONLINE	\N	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/aa5a1299-8449-4e12-a3db-7df679ba2ccf.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/aa5a1299-8449-4e12-a3db-7df679ba2ccf.jpeg}	\N
cmqegmynu000bl204v6ux4cal	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:13:42.523	2026-06-15 00:23:33.889	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	4	0	ONLINE	\N	07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a0ef78f1-e3d8-4571-92fa-56471bcec5d2.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a0ef78f1-e3d8-4571-92fa-56471bcec5d2.jpeg}	2026-06-15 00:19:09.468
cmqeglb080001l204a90y269y	17	COMPLETED	\N	75.00	0.00	75.00	2026-06-15 00:12:25.208	2026-06-15 00:19:20.322	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmqegrqdb000qju04b81j0rx7	21	COMPLETED	\N	45.00	0.00	45.00	2026-06-15 00:17:25.056	2026-06-15 00:26:08.614	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmqefu4fg000qjq044svoavyg	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-14 23:51:16.972	2026-06-15 00:38:05.605	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmqeh5dnu000nl204bwd7gsa1	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:28:01.77	2026-06-15 00:29:41.666	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmqegowpi000eju04vo1n0c92	20	COMPLETED	\N	45.00	0.00	45.00	2026-06-15 00:15:13.302	2026-06-15 00:29:34.948	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmqfvi9rs0001jv04v0eoq0tt	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 23:57:44.056	2026-06-16 00:06:18.951	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqfvcak90009ks04frb5z0ya	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 23:53:05.145	2026-06-16 00:09:40.306	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-16T00:15:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/07bfd2e7-48bd-4c10-9a19-55db695595eb.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/07bfd2e7-48bd-4c10-9a19-55db695595eb.jpeg}	\N
cmqfw2clc000hjv04xvvg3a9h	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 00:13:20.833	2026-06-16 00:18:18.032	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:10	\N	\N	\N
cmqeopz470001ih04v431kzt4	46	COMPLETED	\N	70.00	0.00	70.00	2026-06-15 04:00:00.007	2026-06-15 04:03:21.678	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:00	\N	\N	\N
cmqehsm2g0019l5047ixbwsxi	31	COMPLETED	\N	45.00	0.00	45.00	2026-06-15 00:46:05.752	2026-06-15 00:52:52.467	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqehwfio0002i3042j7ijrmw	32	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:49:03.889	2026-06-15 00:54:45.293	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-15T01:15:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/654dd059-7661-413b-b3d8-e3a8fbce09e4.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/654dd059-7661-413b-b3d8-e3a8fbce09e4.jpeg}	\N
cmqeh636w000jl5042dv21fb9	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:28:34.856	2026-06-15 00:31:42.674	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmqeh5r500009l504p46seqda	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:28:19.236	2026-06-15 00:38:08.19	\N	\N	\N	\N	cmq5wjkiw0000jy04p03a3vql	4	0	ONLINE	\N	2026-06-15T00:45:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/cc6b21c5-2d08-4916-ba59-a695f30bb235.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/cc6b21c5-2d08-4916-ba59-a695f30bb235.jpg}	2026-06-15 00:29:54.572
cmqeh2whf0000l504q1rdw4df	22	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:26:06.195	2026-06-15 00:38:11.915	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-15T00:45:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/65af7caa-e1d2-4255-ba6c-153f2894de80.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/65af7caa-e1d2-4255-ba6c-153f2894de80.jpeg}	2026-06-15 00:26:14.015
cmqehz0ar002ll704ttpnxq2b	33	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:51:04.131	2026-06-15 00:56:22.013	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqeh8n5o000wl204ou25zq0w	26	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:30:34.044	2026-06-15 00:42:32.99	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmqei0bdi002ul7048ivwgnxb	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:52:05.143	2026-06-15 00:57:58.496	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmqehk0ni001xl704tufjw9az	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:39:24.75	2026-06-15 00:43:57.257	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmqekrmxq000jlb040pgslxo1	38	COMPLETED	\N	80.00	0.00	80.00	2026-06-15 02:09:19.071	2026-06-15 02:19:56.823	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqehnp01000tl5044avxcpir	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:42:16.273	2026-06-15 00:45:37.395	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmqei2gsj000ci304ttavm0hm	35	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:53:45.476	2026-06-15 01:00:21.747	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	08:00	\N	\N	\N
cmqehohi10012l504h49ma1ej	29	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 00:42:53.209	2026-06-15 00:48:20.032	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqehp0h40026l70425sbnf3g	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 00:43:17.8	2026-06-15 00:51:35.615	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqftvv5q0000ld0465xta0at	2	COMPLETED	\N	250.00	0.00	250.00	2026-06-15 23:12:19.07	2026-06-16 00:41:18.59	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	31	0	ONLINE	\N	2026-06-16T00:15:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f88bf1ff-8f41-4057-b28a-72e119f27173.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f88bf1ff-8f41-4057-b28a-72e119f27173.jpeg}	\N
cmqekpxuz0001lb042kqghdsq	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 02:07:59.916	2026-06-15 02:10:43.537	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	01:10	\N	\N	\N
cmqep4xu40001l4046bxwds4w	47	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 04:11:38.189	2026-06-15 04:13:00.803	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:20	\N	\N	\N
cmqekqlft000alb04rkh20oqf	37	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 02:08:30.473	2026-06-15 02:12:13.037	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqduj93f00023xapgmz8rijc	1	CANCELLED	ทดสอบใช้ส่วนลด 2	40.00	5.00	35.00	2026-06-14 13:54:57.867	2026-06-14 14:36:39.217	\N	\N	AMOUNT	5.00	cmpr50gby0000l204k4iyqunq	3	0	ONLINE	76FD6CD2387B86D6	07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/57b89464-bcb4-4d68-a965-945fd1b2ca81.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/57b89464-bcb4-4d68-a965-945fd1b2ca81.jpg}	\N
cmqekv7060001lb041ncl7gms	39	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 02:12:05.046	2026-06-15 02:22:46.648	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:10	\N	\N	\N
cmqel7l3o001llb046wfqxcq3	44	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 02:21:43.188	2026-06-15 02:24:42.153	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmqel2y52000ulb04vu5o8f82	40	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 02:18:06.806	2026-06-15 02:28:29.423	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqel3f9c0013lb04xopp32mt	41	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 02:18:28.992	2026-06-15 02:29:16.854	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqel6vrh0007lb04221tcgcp	43	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 02:21:10.349	2026-06-15 02:31:06.273	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqel4u94001clb04g44aiz26	42	COMPLETED	\N	35.00	0.00	35.00	2026-06-15 02:19:35.081	2026-06-15 02:31:52.828	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqeq5v3h0001ib044lz9ni4a	48	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 04:40:20.91	2026-06-15 04:46:43.156	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:20	\N	\N	\N
cmqemetdm0001l204600waj0e	45	COMPLETED	\N	70.00	0.00	70.00	2026-06-15 02:55:20.123	2026-06-15 02:57:05.605	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:30	\N	\N	\N
cmqfud7nf000yld04jq4adjzq	3	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 23:25:48.411	2026-06-16 00:09:54.862	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	23:30	\N	\N	\N
cmqerio620001i504s4hd8t5b	49	COMPLETED	\N	75.00	0.00	75.00	2026-06-15 05:18:18.074	2026-06-15 05:24:35.829	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	11:40	\N	\N	\N
cmqfsqq750000ld048c870nbs	1	COMPLETED	\N	205.00	0.00	205.00	2026-06-15 22:40:19.745	2026-06-15 23:41:10.301	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	30	0	ONLINE	\N	2026-06-16T00:15:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e9572148-eea1-47d4-aa7d-9134962635cf.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e9572148-eea1-47d4-aa7d-9134962635cf.jpeg}	\N
cmqerozpe0001la04i8oyzn3s	50	COMPLETED	\N	75.00	0.00	75.00	2026-06-15 05:23:12.962	2026-06-15 05:29:03.329	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:20	\N	\N	\N
cmqfuyyrb0003l804jh674tnc	4	COMPLETED	\N	75.00	0.00	75.00	2026-06-15 23:42:43.32	2026-06-15 23:46:59.279	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:30	\N	\N	\N
cmqfvsiw80008jv045u9awuri	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 00:05:42.44	2026-06-16 00:09:48.959	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqfvh4rl000jks04lk16yjy8	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-15 23:56:50.913	2026-06-16 00:08:54.625	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:00	\N	\N	\N
cmqfvbu550001ks04a8tdcmou	5	COMPLETED	\N	70.00	0.00	70.00	2026-06-15 23:52:43.865	2026-06-16 00:08:46.384	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	06:50	\N	\N	\N
cmq8y8txt0009l104g3kq58gy	33	COMPLETED	\N	155.00	0.00	155.00	2026-06-11 03:39:59.249	2026-06-16 03:56:19.421	\N	\N	\N	\N	cmq7hdolg000klb04x9d9hye6	15	0	ONLINE	\N	11:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5ed367d-3dcf-441b-97f2-7424396de5d0.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5ed367d-3dcf-441b-97f2-7424396de5d0.jpeg}	2026-06-11 03:40:38.774
cmqfw96qm000pjv04z3e2xapt	11	COMPLETED	\N	70.00	0.00	70.00	2026-06-16 00:18:39.838	2026-06-16 00:22:24.188	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmqfwds850001l404h7wxfp60	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 00:22:14.309	2026-06-16 00:23:47.799	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:20	\N	\N	\N
cmqfwuju3000zjv045v016l3p	14	COMPLETED	\N	70.00	0.00	70.00	2026-06-16 00:35:16.587	2026-06-16 00:38:01.499	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:30	\N	\N	\N
cmqfwio8o0008l404j8o7uh0q	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 00:26:02.425	2026-06-16 00:38:03.668	\N	\N	\N	\N	cmq5wjkiw0000jy04p03a3vql	3	0	ONLINE	\N	2026-06-16T00:45:00.000Z	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fc3b5e9b-9d13-4bbb-8f92-8fc27278b841.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/fc3b5e9b-9d13-4bbb-8f92-8fc27278b841.jpg}	\N
cmqg6xrh40001l80443zuen3d	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 05:17:42.616	2026-06-16 05:20:27.665	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	10:30	\N	\N	\N
cmqfx1kkg000ql404tksl9q7i	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 00:40:44.128	2026-06-16 00:45:38.072	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmqg9m8wk0001l2044kvlwkjs	30	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 06:32:44.18	2026-06-16 06:36:55.811	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 13:20	\N	\N	\N
cmqg70do00008l8041rjw1hvi	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 05:19:44.688	2026-06-16 05:24:32.776	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	12:20	\N	\N	\N
cmqfx13wa000jl404q3wirgy3	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 00:40:22.523	2026-06-16 00:52:33.078	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmqfxayic0001jp04p9jgevib	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 00:48:02.1	2026-06-16 00:52:35.068	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:40	\N	\N	\N
cmqg0d9w00001jo048onrf7e2	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 02:13:49.008	2026-06-16 02:17:11.642	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	07:50	\N	\N	\N
cmqg16zzf0001la046sy3i4wt	19	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 02:36:55.851	2026-06-16 02:38:30.656	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:20	\N	\N	\N
cmqhaf3ao0001la04zxmr7zrs	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 23:42:56.112	2026-06-16 23:52:59.385	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 06:30	\N	\N	\N
cmqg7bbm40001le04pb74fltp	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 05:28:15.244	2026-06-16 06:06:50.688	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 12:30	\N	\N	\N
cmqg2sz0w0001ic04q2gywnhk	21	COMPLETED	\N	70.00	0.00	70.00	2026-06-16 03:22:00.657	2026-06-16 03:29:07.156	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	09:40	\N	\N	\N
cmqg2ab5500013xzg34k6pfg1	20	CANCELLED	test	35.00	0.00	35.00	2026-06-16 03:07:29.896	2026-06-16 03:24:26.311	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	01:40	\N	\N	\N
cmqg38w9c000h3xzgdo8lcntj	22	PREPARING	ใส่แก้วที่เอามาเอง	35.00	0.00	35.00	2026-06-16 03:34:22.69	2026-06-16 22:59:42.843	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	3	0	ONLINE	\N	2026-06-17 02:20	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/384ff7d3-354c-484d-90c3-70273817a2ee.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/384ff7d3-354c-484d-90c3-70273817a2ee.jpg}	\N
cmqg8pwmb0009k004z056fnpt	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 06:07:35.268	2026-06-16 06:08:02.672	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 13:10	\N	\N	\N
cmqg8o3ov0001k004zn9iec6o	26	COMPLETED	\N	60.00	0.00	60.00	2026-06-16 06:06:11.12	2026-06-16 06:14:02.267	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 12:30	\N	\N	\N
cmqg8w2n00001jg04hwh2jc8v	28	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 06:12:23.004	2026-06-16 06:16:05.828	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 13:10	\N	\N	\N
cmqg93l3h000ajg04x2r5n7u1	29	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 06:18:13.517	2026-06-16 06:26:36.424	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 13:20	\N	\N	\N
cmqh8wmrw0008jv04ur26ay8z	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 23:00:35.277	2026-06-17 00:30:28.302	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 06:10	\N	\N	\N
cmqh935b80000l804xbwxz2my	3	COMPLETED	\N	75.00	0.00	75.00	2026-06-16 23:05:39.236	2026-06-16 23:26:10.809	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	11	0	ONLINE	\N	2026-06-17 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b6fbed34-457b-43e7-ad52-eb2ff98fad4f.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b6fbed34-457b-43e7-ad52-eb2ff98fad4f.jpeg}	\N
cmqhb2h2t000jl7049fgs758z	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:01:07.061	2026-06-17 00:37:23.563	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-17 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4dd0e29d-e919-4f9b-88cb-6bd7ed811249.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4dd0e29d-e919-4f9b-88cb-6bd7ed811249.jpeg}	\N
cmqh9vl920001jp04vzxkb2vn	6	COMPLETED	\N	75.00	0.00	75.00	2026-06-16 23:27:46.262	2026-06-16 23:33:36.922	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 06:10	\N	\N	\N
cmqhapsqa0001kz046m532ale	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 23:51:15.634	2026-06-16 23:52:52.447	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 06:50	\N	\N	\N
cmqhb1lml000ala04fq4bpcip	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:00:26.301	2026-06-17 00:11:55.44	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:00	\N	\N	\N
cmqhaun1j000al704nwyver1t	10	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 23:55:01.543	2026-06-16 23:55:27.57	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:00	\N	\N	\N
cmqhaoj8s0000l704s2lnk9db	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-16 23:50:16.684	2026-06-16 23:56:37.456	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-17 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/2a0fb524-75a9-4447-ae5d-9ca029e21b94.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/2a0fb524-75a9-4447-ae5d-9ca029e21b94.jpeg}	\N
cmqh9eh620000jp048o3l9529	4	COMPLETED	\N	95.00	0.00	95.00	2026-06-16 23:14:27.818	2026-06-17 00:03:53.896	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	14	0	ONLINE	\N	2026-06-17 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b8f94234-2b14-4260-827a-b9da8eb2c774.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b8f94234-2b14-4260-827a-b9da8eb2c774.jpeg}	\N
cmqh9ho0j000djp04obkt4exl	5	COMPLETED	\N	210.00	5.00	205.00	2026-06-16 23:16:56.659	2026-06-17 00:30:19.769	\N	\N	AMOUNT	5.00	cmqh9bzp90002jo04a1bozkv8	20	0	ONLINE	76FD6CD2387B86D6	2026-06-17 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/19be8778-e52e-49e5-9a0b-7e684fd7fa49.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/19be8778-e52e-49e5-9a0b-7e684fd7fa49.jpeg}	\N
cmqh8wax00001jv04r8li7plu	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-16 23:00:19.908	2026-06-17 00:06:40.305	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-16 13:40	\N	\N	\N
cmqhb64x0000akz04r3pajxy3	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:03:57.925	2026-06-17 00:08:21.881	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-17 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a088169e-5bd2-495e-a5af-215bcc5e0938.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a088169e-5bd2-495e-a5af-215bcc5e0938.jpeg}	\N
cmqhi0sfq0001k0045pv79kx8	30	COMPLETED	\N	70.00	0.00	70.00	2026-06-17 03:15:45.782	2026-06-17 03:20:19.795	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 10:20	\N	\N	\N
cmqhcpdm6000hjv04fugns4mb	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:46:55.279	2026-06-17 00:49:19.996	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:50	\N	\N	\N
cmqhcltl70003kz04cy40mcax	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:44:09.355	2026-06-17 00:49:28.807	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:40	\N	\N	\N
cmqhbas6t000bjr04oanv73n2	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:07:34.71	2026-06-17 00:15:53.919	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:10	\N	\N	\N
cmqhmpg0q000el804kdgln2j2	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 05:26:54.555	2026-06-17 05:31:35.97	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:30	\N	\N	\N
cmqhcun7e000bkz047jjs8fxf	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:51:00.987	2026-06-17 00:53:11.115	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:50	\N	\N	\N
cmqhl0ww20001lf04au52qo3h	31	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 04:39:50.402	2026-06-17 04:41:46.029	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 10:20	\N	\N	\N
cmqhbshph0001jv04qhu8n2rx	19	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:21:20.933	2026-06-17 00:27:20.139	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:20	\N	\N	\N
cmqhcrws3000qjv04xsvla0uz	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:48:53.427	2026-06-17 00:53:50.351	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:50	\N	\N	\N
cmqhbyltz0010la04bflbvizt	20	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:26:06.215	2026-06-17 00:29:22.796	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:30	\N	\N	\N
cmqhbbzdo000kjr04249k17z8	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:08:30.684	2026-06-17 00:30:33.267	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:10	\N	\N	\N
cmqhbcv6a000jla04rsxsaatv	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:09:11.89	2026-06-17 00:30:35.333	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:10	\N	\N	\N
cmqhbejle000sla04ilh347jq	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:10:30.195	2026-06-17 00:30:37.134	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:10	\N	\N	\N
cmqhc7c290008jv04is9tzreq	21	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 00:32:53.457	2026-06-17 00:40:39.714	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 07:30	\N	\N	\N
cmqhb97pr0000jr04pubtyqr2	14	COMPLETED	เเยกน้ำเเข็งนะคะ 7:40ไปเอาค่ะ ออยล์	40.00	5.00	35.00	2026-06-17 00:06:21.519	2026-06-17 00:46:12.671	\N	\N	AMOUNT	5.00	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	76FD6CD2387B86D6	2026-06-17 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/bc9cf797-fcf5-4aaf-b2d7-775bab2170c9.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/bc9cf797-fcf5-4aaf-b2d7-775bab2170c9.jpg}	\N
cmqhd5r8y0001jm04wa7iem68	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 00:59:39.442	2026-06-17 00:59:44.845	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 08:00	\N	\N	\N
cmqhfuqx50001jo04t34m0axo	27	COMPLETED	\N	70.00	0.00	70.00	2026-06-17 02:15:04.649	2026-06-17 02:19:28.689	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 08:00	\N	\N	\N
cmqhg0ox90001l504akagt4sa	28	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 02:19:41.997	2026-06-17 02:23:29.316	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 09:20	\N	\N	\N
cmqhmf4g4000fl1042d92hgmz	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 05:18:52.996	2026-06-17 05:18:59.724	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:20	\N	\N	\N
cmqhg1n0u0008l504pmder52z	29	COMPLETED	\N	80.00	0.00	80.00	2026-06-17 02:20:26.19	2026-06-17 02:25:58.194	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 09:20	\N	\N	\N
cmqhm4yl20008l104rjf45rkt	33	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 05:10:58.839	2026-06-17 05:19:12.19	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:20	\N	\N	\N
cmqhn1met000ul804vw7d4u44	38	COMPLETED	\N	110.00	0.00	110.00	2026-06-17 05:36:22.709	2026-06-17 05:43:50.189	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:30	\N	\N	\N
cmqhmhit10001l804unnhg0v9	35	COMPLETED	\N	70.00	0.00	70.00	2026-06-17 05:20:44.917	2026-06-17 05:24:18.116	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:20	\N	\N	\N
cmqiovbkk0008l4040pyo6jkb	3	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 23:15:14.132	2026-06-18 00:22:59.607	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 06:20	\N	\N	\N
cmqhmppyp000kl8047u7gz2sb	37	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 05:27:07.442	2026-06-17 05:31:32.798	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:30	\N	\N	\N
cmqiptf510000l804u5anuxp0	4	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 23:41:45.061	2026-06-17 23:56:04.529	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-18 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/de4be560-b832-4d21-8c8e-c09c995aa40b.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/de4be560-b832-4d21-8c8e-c09c995aa40b.jpeg}	\N
cmqhn2e8m000pl104vfd9b0hv	39	COMPLETED	\N	80.00	0.00	80.00	2026-06-17 05:36:58.774	2026-06-17 05:45:36.477	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 12:40	\N	\N	\N
cmqiov38g0001l404yv6kw1ds	2	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 23:15:03.328	2026-06-17 23:31:25.936	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 06:20	\N	\N	\N
cmqhm46sw0001l1043tlu5z47	32	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 05:10:22.832	2026-06-17 05:45:53.091	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-17 11:40	\N	\N	\N
cmqinyyyb0000jy040wi1ntt0	1	COMPLETED	\N	170.00	0.00	170.00	2026-06-17 22:50:04.787	2026-06-17 23:43:44.69	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	25	0	ONLINE	\N	2026-06-18 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/57a6af6d-06c8-480e-a676-b433a9bea1d3.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/57a6af6d-06c8-480e-a676-b433a9bea1d3.jpeg}	\N
cmqiqeil8000llb045v88x0od	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-17 23:58:09.308	2026-06-18 00:09:06.41	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 06:20	\N	\N	\N
cmqipzgaz0009lb04c6nyrs81	6	COMPLETED	\N	40.00	0.00	40.00	2026-06-17 23:46:26.507	2026-06-18 00:04:49.254	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-18 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e713cb95-9f10-49b0-9d78-e38af99e517c.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e713cb95-9f10-49b0-9d78-e38af99e517c.jpeg}	\N
cmqlksw6u000ajs04imakf3oj	5	COMPLETED	\N	115.00	0.00	115.00	2026-06-19 23:44:40.951	2026-06-20 00:09:28.176	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 06:50	\N	\N	\N
cmqj03pk30001l5047vd6a30d	32	COMPLETED	\N	80.00	0.00	80.00	2026-06-18 04:29:41.284	2026-06-18 04:39:15.877	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 10:20	\N	\N	\N
cmqiqk5460001l10498l06pva	9	COMPLETED	\N	25.00	0.00	25.00	2026-06-18 00:02:31.782	2026-06-18 00:02:38.137	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:00	\N	\N	\N
cmqirqr8f0008l70423fkwlqv	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:35:39.999	2026-06-18 00:42:18.932	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:40	\N	\N	\N
cmqiru9k9000fl704p7ac3y2n	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 00:38:23.722	2026-06-18 00:47:50.567	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:40	\N	\N	\N
cmqiqu26i000rl104xqjjd24u	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 00:10:14.539	2026-06-18 00:21:44.035	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:10	\N	\N	\N
cmqipw8mg0000lb04vnkmt0cf	5	COMPLETED	แยกน้ำแข็งนะคะ ออย ไปรับ 7:40 ค่ะ	40.00	0.00	40.00	2026-06-17 23:43:56.584	2026-06-18 00:47:55.694	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	4	0	ONLINE	\N	2026-06-18 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04ee17a4-cf0f-4cca-ae54-d1ca69e6b1cd.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04ee17a4-cf0f-4cca-ae54-d1ca69e6b1cd.jpg}	\N
cmqivzsta0001jy049uxzyzh5	25	COMPLETED	\N	80.00	0.00	80.00	2026-06-18 02:34:40.414	2026-06-18 02:41:19.2	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 09:20	\N	\N	\N
cmqiqnbci0003l304uzkhhsrw	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:04:59.826	2026-06-18 00:23:08.854	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:10	\N	\N	\N
cmqiryjwp000xl104ol4pmudy	20	COMPLETED	\N	30.00	0.00	30.00	2026-06-18 00:41:43.753	2026-06-18 00:48:01.135	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:40	\N	\N	\N
cmqiqqkb40007l104em14o87o	12	COMPLETED	\N	145.00	0.00	145.00	2026-06-18 00:07:31.408	2026-06-18 00:23:16.643	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:10	\N	\N	\N
cmqirw55o000nl704retl2fui	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:39:51.324	2026-06-18 00:48:02.838	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:40	\N	\N	\N
cmqiqrrhh000il104y40pq7as	13	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:08:27.365	2026-06-18 00:23:22.295	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:10	\N	\N	\N
cmqiqib4d0002l10492bxht9b	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:01:06.253	2026-06-18 00:25:11.608	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-18 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/82aa3cfc-0354-497b-a257-aae6266a5750.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/82aa3cfc-0354-497b-a257-aae6266a5750.jpeg}	\N
cmqiqnt3e000al304l4t5uwyr	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 00:05:22.826	2026-06-18 00:28:54.603	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:10	\N	\N	\N
cmqj5va36000ajy04b0dxhee5	39	COMPLETED	\N	70.00	0.00	70.00	2026-06-18 07:11:05.682	2026-06-18 07:11:18.575	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 14:20	\N	\N	\N
cmqirk8u6000ol104x2pfp3ws	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 00:30:36.222	2026-06-18 00:33:35.953	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:20	\N	\N	\N
cmqiw7z4e0001i204l23d2rgn	26	COMPLETED	\N	285.00	0.00	285.00	2026-06-18 02:41:01.838	2026-06-18 02:57:30.048	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 09:40	\N	\N	\N
cmqiroem80001l7043h65f158	16	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 00:33:50.337	2026-06-18 00:40:03.99	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:40	\N	\N	\N
cmqis5j6z000xl7045xd718hq	21	COMPLETED	ของมิ้น มาเอา	150.00	0.00	150.00	2026-06-18 00:47:09.419	2026-06-18 00:54:53.816	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:50	\N	\N	\N
cmqisj5tl001tl704ttt8nu22	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 00:57:45.274	2026-06-18 02:06:40.527	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 07:50	\N	\N	\N
cmqiv04280003ji041auq6fff	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 02:06:55.377	2026-06-18 02:07:02.108	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 08:00	\N	\N	\N
cmqiwt0mu0001l704gjw4471l	27	COMPLETED	\N	55.00	0.00	55.00	2026-06-18 02:57:23.574	2026-06-18 03:01:47.137	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 09:50	\N	\N	\N
cmqiv5xly0001i8047r3319jk	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 02:11:26.951	2026-06-18 02:11:31.415	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 09:10	\N	\N	\N
cmqj1bzrh0001la0444utd79h	36	COMPLETED	\N	70.00	0.00	70.00	2026-06-18 05:04:07.374	2026-06-18 05:08:26.047	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 12:00	\N	\N	\N
cmqiwyfui0001js04m2gwqttk	30	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 03:01:36.57	2026-06-18 03:08:44.157	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 10:10	\N	\N	\N
cmqj0su8e0001la0481ue9a3y	33	COMPLETED	\N	25.00	0.00	25.00	2026-06-18 04:49:13.743	2026-06-18 04:49:23.812	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 11:50	\N	\N	\N
cmqiwx8kr000cl704h0x2q4ct	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 03:00:40.491	2026-06-18 03:10:10.259	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 10:00	\N	\N	\N
cmqixfehj000bjs04ldhxm1xy	31	COMPLETED	\N	55.00	0.00	55.00	2026-06-18 03:14:47.96	2026-06-18 03:18:59.215	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 10:10	\N	\N	\N
cmqj5utke0001jy04vhutjbqs	38	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 07:10:44.27	2026-06-18 07:11:20.328	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 14:20	\N	\N	\N
cmqj126pc0007la04a23oh02r	35	COMPLETED	\N	30.00	0.00	30.00	2026-06-18 04:56:29.809	2026-06-18 04:56:34.334	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 12:00	\N	\N	\N
cmqj1s5wy0001jy04yr0qqenu	37	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 05:16:41.843	2026-06-18 05:18:33.034	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 12:10	\N	\N	\N
cmqj0tusn0006il049hk3esr5	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 04:50:01.127	2026-06-18 04:56:38.191	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 11:50	\N	\N	\N
cmqiwxm6u000il704syhxhzzn	29	CANCELLED	\N	40.00	0.00	40.00	2026-06-18 03:00:58.135	2026-06-18 05:21:00.226	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 10:10	\N	\N	\N
cmqk4rtrq000lky04lie0o6f0	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-18 23:28:11.126	2026-06-19 00:33:47.687	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-18 12:30	\N	\N	\N
cmqk4r47y0000ky045yngfa64	1	COMPLETED	\N	175.00	0.00	175.00	2026-06-18 23:27:38.014	2026-06-18 23:45:40.66	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	26	0	ONLINE	\N	2026-06-19 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8dbef7a9-ae70-4b70-b9f1-e74b093d4c37.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8dbef7a9-ae70-4b70-b9f1-e74b093d4c37.jpeg}	\N
cmqk5ltex0003jo04135i4al5	3	COMPLETED	\N	110.00	0.00	110.00	2026-06-18 23:51:30.345	2026-06-19 00:00:30.588	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 06:40	\N	\N	\N
cmqk5u11m000ljo042uukqrg3	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 23:57:53.482	2026-06-19 00:01:29.667	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:00	\N	\N	\N
cmqllr38q0011l404xgn72ro6	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:11:16.395	2026-06-20 00:33:36.919	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:20	\N	\N	\N
cmqlmfqg7001rl4041embhu79	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:30:26.215	2026-06-20 00:36:25.588	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:30	\N	\N	\N
cmqllq1ui0022js04iyts2h0u	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:10:27.931	2026-06-20 00:33:13.273	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:10	\N	\N	\N
cmqk7u1m90001le04e559f8rg	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 00:53:53.457	2026-06-19 00:59:45.446	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:50	\N	\N	\N
cmqk6blov0000la04xzyiq4e3	12	COMPLETED	\N	70.00	0.00	70.00	2026-06-19 00:11:33.391	2026-06-19 00:31:12.101	\N	\N	\N	\N	cmqh9bzp90002jo04a1bozkv8	7	0	ONLINE	\N	2026-06-19 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d165f027-34ba-40d7-acf7-4c614f39cf65.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d165f027-34ba-40d7-acf7-4c614f39cf65.jpeg}	\N
cmqk5tdqv000ejo0474h2oyq9	5	COMPLETED	\N	35.00	0.00	35.00	2026-06-18 23:57:23.287	2026-06-19 00:01:18.69	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:00	\N	\N	\N
cmqk63hot0007jp047fvjcp3h	8	COMPLETED	\N	80.00	0.00	80.00	2026-06-19 00:05:14.958	2026-06-19 00:09:29.342	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqk65vn70001l7044hrqft2i	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 00:07:06.356	2026-06-19 00:33:34.46	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqk5z6j50001jp04jhh9x4i9	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 00:01:53.873	2026-06-19 00:10:05.037	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:00	\N	\N	\N
cmqkdsmbl0001jl04d2b9ejgd	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 03:40:44.673	2026-06-19 03:47:44.126	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 10:20	\N	\N	\N
cmqkao9rg0001ji0433je8ff8	22	COMPLETED	\N	145.00	0.00	145.00	2026-06-19 02:13:22.925	2026-06-19 02:27:30.882	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 08:00	\N	\N	\N
cmqk649d9000hjp044yyvw8g0	9	COMPLETED	มิ้น	40.00	0.00	40.00	2026-06-19 00:05:50.829	2026-06-19 00:33:42.055	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqk68npo0001k404smn23y5s	11	COMPLETED	\N	30.00	0.00	30.00	2026-06-19 00:09:16.044	2026-06-19 00:20:15.344	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqk6cn84000ala04yst74y29	13	COMPLETED	\N	40.00	5.00	35.00	2026-06-19 00:12:22.036	2026-06-19 00:23:17.684	\N	\N	AMOUNT	5.00	cmqiqhmsp0001l104ukcdhhbl	3	0	ONLINE	76FD6CD2387B86D6	2026-06-19 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8ba76bd4-c9a6-4ad8-b4bb-b854a87accba.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8ba76bd4-c9a6-4ad8-b4bb-b854a87accba.jpeg}	\N
cmqk6ntea000lla04nuqff2gf	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 00:21:03.25	2026-06-19 00:24:59.116	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqk6pw5a000yla04y205hndb	16	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 00:22:40.126	2026-06-19 00:33:56.601	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:30	\N	\N	\N
cmqk6pmav000sla04r5z9ytfb	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 00:22:27.368	2026-06-19 00:27:10.486	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:30	\N	\N	\N
cmqlllstk000el404mz6raner	10	COMPLETED	\N	50.00	0.00	50.00	2026-06-20 00:07:09.608	2026-06-20 00:21:12.792	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:10	\N	\N	\N
cmqk734is0003l404y4ybjmxu	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 00:32:57.508	2026-06-19 00:35:37.794	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:30	\N	\N	\N
cmqk784u8001pla04004y7d93	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 00:36:51.2	2026-06-19 00:41:14.384	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:40	\N	\N	\N
cmqk5qumb0000l204186dfqh5	4	COMPLETED	เเยกน้ำเเข็งนะคะ 07:40 ไปเอาค่ะ	40.00	0.00	40.00	2026-06-18 23:55:25.187	2026-06-19 00:47:59.447	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	4	0	ONLINE	\N	2026-06-19 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0b46d461-2e2b-44bd-81e4-9d36c432eab9.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0b46d461-2e2b-44bd-81e4-9d36c432eab9.jpg}	\N
cmqkek0jl0001lb04443twlx5	29	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 04:02:02.817	2026-06-19 04:05:44.144	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 10:50	\N	\N	\N
cmqk7o75v0020la049bqkxy9p	20	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 00:49:20.707	2026-06-19 00:54:44.576	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:40	\N	\N	\N
cmqkc1g6a0001jv04qojswdj3	25	COMPLETED	\N	85.00	0.00	85.00	2026-06-19 02:51:37.378	2026-06-19 03:03:18.073	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 09:40	\N	\N	\N
cmqk6ww8h001ala049xsqdm23	17	COMPLETED	\N	115.00	0.00	115.00	2026-06-19 00:28:06.833	2026-06-19 00:54:49.217	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:30	\N	\N	\N
cmqkbflu4000ejl04zutao2ay	24	COMPLETED	\N	105.00	0.00	105.00	2026-06-19 02:34:38.284	2026-06-19 03:03:21.072	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 09:40	\N	\N	\N
cmqkbe5pn0001jl04qxal8mnz	23	COMPLETED	\N	70.00	0.00	70.00	2026-06-19 02:33:30.731	2026-06-19 03:03:23.042	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 09:20	\N	\N	\N
cmqljgn1b0000l204wpqepccy	1	COMPLETED	\N	220.00	0.00	220.00	2026-06-19 23:07:09.6	2026-06-19 23:40:38.627	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	33	0	ONLINE	\N	2026-06-20 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e52fa4a1-187a-4dc3-a9a0-9c645f3f436b.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e52fa4a1-187a-4dc3-a9a0-9c645f3f436b.jpeg}	\N
cmqkcrmxf0001jr04wp3pyspw	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 03:11:59.188	2026-06-19 03:13:45.728	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 10:00	\N	\N	\N
cmqkfxl2s0001jo04hs16xxrf	30	COMPLETED	\N	95.00	0.00	95.00	2026-06-19 04:40:35.572	2026-06-19 04:46:23.327	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 11:10	\N	\N	\N
cmqkdzuo00008jl04l179jb78	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 03:46:22.08	2026-06-19 03:47:39.457	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 10:50	\N	\N	\N
cmqlkrcmk0003js04txy6rzgn	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 23:43:28.94	2026-06-19 23:51:22.208	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 06:20	\N	\N	\N
cmqlkxlik000ljs04rzxyq8u5	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 23:48:20.396	2026-06-19 23:50:30.907	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 06:50	\N	\N	\N
cmqlktqce0001l404m7zaa1do	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-19 23:45:20.03	2026-06-19 23:52:57.671	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 06:50	\N	\N	\N
cmqljrnd5000rl204061ohjkh	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-19 23:15:43.241	2026-06-20 00:04:50.872	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 11:50	\N	\N	\N
cmqlloogx001qjs04kgxwn7kt	11	CANCELLED	\N	35.00	0.00	35.00	2026-06-20 00:09:23.937	2026-06-20 00:18:56.746	\N	\N	\N	\N	cmqiqhmsp0001l104ukcdhhbl	3	0	ONLINE	\N	2026-06-20 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a4adbde9-1d78-4320-87ca-0bdc123b2c47.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a4adbde9-1d78-4320-87ca-0bdc123b2c47.jpeg}	\N
cmqlllkbn001ejs04g41s95fm	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:06:58.595	2026-06-20 00:33:24.343	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:10	\N	\N	\N
cmqllbybm000yjs04cz9jyxcl	8	COMPLETED	\N	75.00	0.00	75.00	2026-06-19 23:59:30.178	2026-06-20 00:16:04.333	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:30	\N	\N	\N
cmqllpdsf000ll404ayzm7yti	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:09:56.751	2026-06-20 00:20:26.298	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:10	\N	\N	\N
cmqlltt0i0017l404fw8cs4s6	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:13:23.106	2026-06-20 00:16:56.171	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:20	\N	\N	\N
cmqllzdgh0029js04lp4nkczf	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:17:42.881	2026-06-20 00:33:41.907	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:20	\N	\N	\N
cmqllptqx000rl404wdf3dtc8	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:10:17.433	2026-06-20 00:33:45.311	\N	\N	\N	\N	cmqiqhmsp0001l104ukcdhhbl	3	0	ONLINE	\N	2026-06-20 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/cb3cb80b-1243-4033-b14f-8843596b0f71.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/cb3cb80b-1243-4033-b14f-8843596b0f71.jpeg}	\N
cmqlma3hg0001l504mrf8zkxj	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:26:03.172	2026-06-20 00:34:08.789	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:30	\N	\N	\N
cmqlmh9vv001yl404ao7exfp5	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:31:38.059	2026-06-20 00:40:14.659	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:40	\N	\N	\N
cmqlmbdat0009l504qxa4xp32	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:27:02.549	2026-06-20 00:44:52.868	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-20 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/93210920-f8e6-42b5-9c18-ab7e41ce1897.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/93210920-f8e6-42b5-9c18-ab7e41ce1897.jpeg}	\N
cmqlmnpjf0008l704v0y6g8ya	25	COMPLETED	\N	80.00	0.00	80.00	2026-06-20 00:36:38.283	2026-06-20 00:47:56.584	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:40	\N	\N	\N
cmqlk4vhi0000l304nax96eh9	3	COMPLETED	\N	175.00	0.00	175.00	2026-06-19 23:26:00.294	2026-06-20 00:33:00.659	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	21	0	ONLINE	\N	2026-06-20 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/858ba047-6747-437e-9faa-502d4e2a9cf6.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/858ba047-6747-437e-9faa-502d4e2a9cf6.jpeg}	\N
cmqlmd8vp001ll4044an4g0a7	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:28:30.134	2026-06-20 00:34:06.935	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:30	\N	\N	\N
cmqlr53u10001l7046hn9q7as	32	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 02:42:08.425	2026-06-20 02:43:26.325	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 09:20	\N	\N	\N
cmqlr5cd50008l704v24do9vx	33	COMPLETED	\N	120.00	0.00	120.00	2026-06-20 02:42:19.481	2026-06-20 02:53:49.333	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 09:50	\N	\N	\N
cmqlmk6yg000djy04v7w2x586	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:33:54.232	2026-06-20 00:40:10.961	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:40	\N	\N	\N
cmqlmpczi000vjy04btf659c1	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:37:55.326	2026-06-20 00:43:01.463	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:40	\N	\N	\N
cmqlmkzfk000ljy04jswpjv5w	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 00:34:31.136	2026-06-20 00:47:28.048	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-20 08:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0ac8f37d-f7de-4c85-8ee3-99a3636ba819.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0ac8f37d-f7de-4c85-8ee3-99a3636ba819.jpeg}	\N
cmqlxaajb000alb04jmtsr1eq	42	COMPLETED	\N	70.00	0.00	70.00	2026-06-20 05:34:08.088	2026-06-20 05:34:12.069	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 12:40	\N	\N	\N
cmqlmzkq5000jl5045tt9gmzs	27	COMPLETED	\N	70.00	0.00	70.00	2026-06-20 00:45:51.917	2026-06-20 00:53:11.489	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:40	\N	\N	\N
cmqlrm6bc000cjp04xw7q5r21	35	COMPLETED	\N	45.00	0.00	45.00	2026-06-20 02:55:24.792	2026-06-20 03:01:12.679	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 10:00	\N	\N	\N
cmqlrkr5u0003jp04njzr6765	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 02:54:18.499	2026-06-20 03:01:14.667	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 09:50	\N	\N	\N
cmqln2msy000xl504qji5b2aa	28	COMPLETED	\N	80.00	0.00	80.00	2026-06-20 00:48:14.578	2026-06-20 00:57:15.583	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:50	\N	\N	\N
cmqlnazqq0001je0455o8160w	29	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 00:54:44.595	2026-06-20 00:57:43.305	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 07:50	\N	\N	\N
cmqlx9uh00001lb04xia4qo6m	41	COMPLETED	\N	80.00	0.00	80.00	2026-06-20 05:33:47.268	2026-06-20 05:34:13.629	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 12:40	\N	\N	\N
cmqls3v660006jx04be0ce1wz	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 03:09:10.158	2026-06-20 03:14:40.686	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 10:00	\N	\N	\N
cmqlqajdd000al704f5cejavb	31	COMPLETED	\N	80.00	0.00	80.00	2026-06-20 02:18:22.225	2026-06-20 02:18:35.165	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 09:20	\N	\N	\N
cmqlqa33v0001l704mrm0pdq6	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 02:18:01.147	2026-06-20 02:18:36.726	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 08:00	\N	\N	\N
cmqm1ht720001l1046r3atqhc	47	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 07:31:57.326	2026-06-20 07:32:23.943	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 13:30	\N	\N	\N
cmqlskn6o0001l7049kx5in70	37	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 03:22:12.96	2026-06-20 03:26:25.465	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 10:10	\N	\N	\N
cmqlxrvkm0001jo04fnbli9ip	43	COMPLETED	\N	225.00	0.00	225.00	2026-06-20 05:47:48.502	2026-06-20 06:10:30.478	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 12:40	\N	\N	\N
cmqlsqlah0001l204izsehe9e	38	COMPLETED	\N	50.00	0.00	50.00	2026-06-20 03:26:50.441	2026-06-20 03:31:53.87	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 10:30	\N	\N	\N
cmqm1i687000al1047oehbwrs	48	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 07:32:14.215	2026-06-20 07:32:25.292	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 14:40	\N	\N	\N
cmqlvd2iz0008l304142slk83	40	COMPLETED	\N	30.00	0.00	30.00	2026-06-20 04:40:18.443	2026-06-20 04:50:04.636	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 11:40	\N	\N	\N
cmqlvchuz0001l304uwqggsl4	39	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 04:39:51.66	2026-06-20 04:50:18.63	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 10:30	\N	\N	\N
cmqlyzdpf0001jv04v7hjs9no	44	COMPLETED	\N	70.00	0.00	70.00	2026-06-20 06:21:38.211	2026-06-20 06:25:59.404	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-19 07:10	\N	\N	\N
cmqof8n1e0000l404yvrkazxb	1	CANCELLED	\N	35.00	0.00	35.00	2026-06-21 23:32:16.418	2026-06-21 23:33:13.23	\N	\N	\N	\N	cmpqxi3y80000jv042tmuxldv	3	0	ONLINE	\N	2026-06-22 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/34ef0a33-2055-4f89-a765-ac56ad943f66.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/34ef0a33-2055-4f89-a765-ac56ad943f66.jpg}	\N
cmqlz8ese000ajv041dx8txqz	45	COMPLETED	\N	40.00	0.00	40.00	2026-06-20 06:28:39.519	2026-06-20 06:33:46.782	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 13:30	\N	\N	\N
cmqlz8voc000jjv045dts0ltq	46	COMPLETED	\N	35.00	0.00	35.00	2026-06-20 06:29:01.404	2026-06-20 06:33:48.354	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-20 13:30	\N	\N	\N
cmqofkfiy0005jr04y7tki1tl	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-21 23:41:26.554	2026-06-21 23:44:39.987	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 06:30	\N	\N	\N
cmqoflmyx000cjr04qwjjjbtc	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-21 23:42:22.857	2026-06-21 23:47:24.745	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-22 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/eac732d2-dd66-45df-9176-91324178b567.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/eac732d2-dd66-45df-9176-91324178b567.jpeg}	\N
cmqogat78000kl204q4qf57of	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:01:57.332	2026-06-22 00:32:10.475	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:00	\N	\N	\N
cmqofz20t0001jy048fbnyvdu	5	COMPLETED	\N	75.00	0.00	75.00	2026-06-21 23:52:48.894	2026-06-21 23:55:47.316	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 06:50	\N	\N	\N
cmqofzkj6000cjy04n6lf0g6x	6	COMPLETED	\N	35.00	0.00	35.00	2026-06-21 23:53:12.882	2026-06-21 23:58:09.561	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:00	\N	\N	\N
cmqog63yh000mjy0440mtmjew	8	COMPLETED	\N	25.00	0.00	25.00	2026-06-21 23:58:17.993	2026-06-21 23:58:23.288	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:00	\N	\N	\N
cmqog4lo2000bl204n6c5okmt	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-21 23:57:07.635	2026-06-22 00:05:31.814	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:00	\N	\N	\N
cmqog7a1v000sjy04yaeoek4e	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-21 23:59:12.547	2026-06-22 00:05:15.826	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:00	\N	\N	\N
cmqogb5rr000ql204h3j0fjol	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:02:13.623	2026-06-22 00:05:09.382	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:10	\N	\N	\N
cmqou0n820001la04ny6328bl	51	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 06:25:57.65	2026-06-22 06:26:18.883	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 13:00	\N	\N	\N
cmqou6iwc0001jf04zssojjyx	52	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 06:30:31.981	2026-06-22 06:35:24.633	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 13:30	\N	\N	\N
cmqohj8mt0029l204hlyx39l6	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:36:30.197	2026-06-22 00:40:24.585	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:30	\N	\N	\N
cmqoghbpx0012l204zyk8ltaf	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:07:01.269	2026-06-22 00:08:35.012	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:10	\N	\N	\N
cmqoggnri000zjy04nj5dejd1	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:06:30.222	2026-06-22 00:13:27.977	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:10	\N	\N	\N
cmqohlvah002fl204ey5e0j21	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:38:32.873	2026-06-22 00:40:34.554	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:40	\N	\N	\N
cmqogqhau001al204d663z4pj	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:14:08.406	2026-06-22 00:18:37.414	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:20	\N	\N	\N
cmqohpljt002sl204orki3yvl	23	COMPLETED	\N	15.00	0.00	15.00	2026-06-22 00:41:26.873	2026-06-22 00:41:32.183	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:40	\N	\N	\N
cmqogndw1001djy04yqcoys6l	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:11:44.017	2026-06-22 00:18:44.467	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:10	\N	\N	\N
cmqoi6xvk002sjy04vutzsk5d	30	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:54:56	2026-06-22 01:00:25.309	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 08:00	\N	\N	\N
cmqogh0g60016jy04t0bj25e1	13	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:06:46.662	2026-06-22 00:42:23.75	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:10	\N	\N	\N
cmqoh0zo3001ll204rmq12c9o	17	COMPLETED	\N	140.00	0.00	140.00	2026-06-22 00:22:18.772	2026-06-22 00:30:07.625	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:20	\N	\N	\N
cmqoh9e6r001mjy04267dacda	20	COMPLETED	\N	30.00	0.00	30.00	2026-06-22 00:28:50.835	2026-06-22 00:32:06.071	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:30	\N	\N	\N
cmqoh4aau001zl204bxm2k34i	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:24:52.519	2026-06-22 00:32:39.872	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-22 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4dff0dd6-63df-455b-a3e5-6fe722b9cf8b.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4dff0dd6-63df-455b-a3e5-6fe722b9cf8b.jpeg}	\N
cmqoh5bly0000l5046a55usxi	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:25:40.87	2026-06-22 00:39:07.639	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-22 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4c5888c3-6300-4102-b108-28b25c60f1cf.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4c5888c3-6300-4102-b108-28b25c60f1cf.jpeg}	\N
cmqomfj1z0001ji041ryp1r64	35	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 02:53:35.16	2026-06-22 02:54:17.74	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 09:40	\N	\N	\N
cmqofxpsi0000l204o4q86h6l	4	COMPLETED	7:40ไปรับนะคะ	35.00	0.00	35.00	2026-06-21 23:51:46.387	2026-06-22 00:48:25.058	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	\N	2026-06-22 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/08609257-2d28-4b01-9f5a-55eb614af390.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/08609257-2d28-4b01-9f5a-55eb614af390.jpg}	\N
cmqoi6ryr002ljy04ci4r4ndp	29	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:54:48.339	2026-06-22 01:02:25.22	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 08:00	\N	\N	\N
cmqohs760001wjy04vsk1snbi	24	COMPLETED	\N	75.00	0.00	75.00	2026-06-22 00:43:28.201	2026-06-22 00:48:31.97	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:50	\N	\N	\N
cmqomvxq70002jo04rzjxbh57	39	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 03:06:20.671	2026-06-22 03:11:55.543	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:10	\N	\N	\N
cmqohsaa30025jy04l3wz4gim	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:43:32.236	2026-06-22 00:48:39.156	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:50	\N	\N	\N
cmqoiau65003ol204abxoqu0b	31	COMPLETED	\N	80.00	0.00	80.00	2026-06-22 00:57:57.821	2026-06-22 01:08:24.341	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 08:00	\N	\N	\N
cmqohu9cz0030l2047mqn7fis	26	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:45:04.355	2026-06-22 00:49:11.232	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:50	\N	\N	\N
cmqohzq2b002cjy0435747mm8	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 00:49:19.284	2026-06-22 00:51:19.625	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:50	\N	\N	\N
cmqomg06t0007ji04rq39l2eg	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 02:53:57.366	2026-06-22 02:57:24.517	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:00	\N	\N	\N
cmqoi2yrw003fl20417yfow9f	28	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 00:51:50.54	2026-06-22 00:52:32.316	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 07:50	\N	\N	\N
cmqolg4s80001ju04xew4vlfq	32	COMPLETED	\N	115.00	0.00	115.00	2026-06-22 02:26:03.704	2026-06-22 02:31:18.196	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 08:00	\N	\N	\N
cmqolni4u000iju04sh9c0wks	33	COMPLETED	\N	75.00	0.00	75.00	2026-06-22 02:31:47.598	2026-06-22 02:36:51.32	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 09:30	\N	\N	\N
cmqolqeql0001jv04i2g58uta	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 02:34:03.165	2026-06-22 02:45:29.108	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 09:40	\N	\N	\N
cmqomwyo50009jo0428s49uio	40	COMPLETED	\N	75.00	0.00	75.00	2026-06-22 03:07:08.549	2026-06-22 03:13:48.478	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:10	\N	\N	\N
cmqomppaf0003jo04xxxmdwn1	37	COMPLETED	\N	55.00	0.00	55.00	2026-06-22 03:01:29.799	2026-06-22 03:02:38.615	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:00	\N	\N	\N
cmqomqynh0001l704v0zp96ua	38	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 03:02:28.59	2026-06-22 03:05:49.664	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:10	\N	\N	\N
cmqonqhbv0001k004evqx7jfj	41	COMPLETED	+5บาท	80.00	0.00	80.00	2026-06-22 03:30:05.755	2026-06-22 03:35:58.211	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:10	\N	\N	\N
cmqopvfwu0001jr041i76bvga	43	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 04:29:56.43	2026-06-22 04:30:17.68	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 11:20	\N	\N	\N
cmqoqdbyr0001l104u1b9bkrs	45	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 04:43:51.123	2026-06-22 04:45:56.887	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 11:40	\N	\N	\N
cmqopb9bl0001l404c5s0v1dz	42	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 04:14:14.769	2026-06-22 04:30:25.848	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 10:40	\N	\N	\N
cmqoq28to000cjr040bs22qec	44	COMPLETED	\N	15.00	0.00	15.00	2026-06-22 04:35:13.836	2026-06-22 04:35:18.962	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 11:30	\N	\N	\N
cmqoqjxkv0001lg04c2el3icb	46	COMPLETED	\N	80.00	0.00	80.00	2026-06-22 04:48:59.071	2026-06-22 04:53:55.626	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 11:50	\N	\N	\N
cmqorr72l0001lg04ldt89q5n	47	COMPLETED	\N	180.00	0.00	180.00	2026-06-22 05:22:37.582	2026-06-22 05:42:52.854	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 11:50	\N	\N	\N
cmqorun5b0001k004d83itutj	48	COMPLETED	\N	75.00	0.00	75.00	2026-06-22 05:25:18.383	2026-06-22 05:42:51.137	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 12:30	\N	\N	\N
cmqos3npl000ck004y1e0ddp5	49	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 05:32:19.017	2026-06-22 05:42:48.579	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 12:30	\N	\N	\N
cmqoszbez0001kz04ysa1fr2a	50	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 05:56:56.076	2026-06-22 05:57:02.952	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 12:40	\N	\N	\N
cmqou89t00008jf049xa3w7my	53	COMPLETED	\N	45.00	0.00	45.00	2026-06-22 06:31:53.508	2026-06-22 06:35:21.705	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-22 13:40	\N	\N	\N
cmqq319mc000rjo04bxfxgbk6	26	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 03:26:09.396	2026-06-23 03:26:17.102	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 10:30	\N	\N	\N
cmqpwcagy0001ld04byj18eym	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 00:18:46.403	2026-06-23 00:20:27.502	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:20	\N	\N	\N
cmqpx6f0a000hjx04lti7mpac	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 00:42:11.963	2026-06-23 00:49:02.689	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:40	\N	\N	\N
cmqpwertx000hld0461x1ia2y	11	COMPLETED	\N	60.00	0.00	60.00	2026-06-23 00:20:42.214	2026-06-23 00:23:14.343	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	9	0	ONLINE	\N	2026-06-23 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a4a9851c-0fbb-47f7-bcbd-f5fab4e28286.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a4a9851c-0fbb-47f7-bcbd-f5fab4e28286.jpeg}	\N
cmqpvkgac0008kt04lj54abc5	5	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 23:57:07.573	2026-06-23 00:00:56.214	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:00	\N	\N	\N
cmqpzldaf0001l40486tuof0m	21	COMPLETED	\N	65.00	0.00	65.00	2026-06-23 01:49:48.808	2026-06-23 01:50:26.037	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 08:00	\N	\N	\N
cmqpv35yh0000kz04dyg19g6x	3	COMPLETED	\N	120.00	0.00	120.00	2026-06-22 23:43:41.034	2026-06-23 00:10:52.285	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	18	0	ONLINE	\N	2026-06-23 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/adaa7533-c32a-4fce-aea8-f0b20afa6c12.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/adaa7533-c32a-4fce-aea8-f0b20afa6c12.jpeg}	\N
cmqpuz63t0008lb04i34g40d0	2	COMPLETED	\N	75.00	0.00	75.00	2026-06-22 23:40:34.601	2026-06-23 00:17:39.853	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 06:30	\N	\N	\N
cmqpxbqpu000ijf043m6gjulk	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 00:46:20.418	2026-06-23 00:49:06.444	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:50	\N	\N	\N
cmqpui11v0001lb042itx3wrc	1	COMPLETED	\N	40.00	0.00	40.00	2026-06-22 23:27:14.9	2026-06-23 00:17:45.578	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 06:30	\N	\N	\N
cmqpwgjw10001jf04ip51wtse	12	COMPLETED	\N	45.00	0.00	45.00	2026-06-23 00:22:05.234	2026-06-23 00:32:38.528	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:20	\N	\N	\N
cmqpvj6ag0001kt04ess4ns7y	4	COMPLETED	\N	35.00	0.00	35.00	2026-06-22 23:56:07.96	2026-06-23 00:17:51.974	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 06:50	\N	\N	\N
cmqpw1p81000jjl04dxfxynlc	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 00:10:32.305	2026-06-23 00:17:57.466	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:10	\N	\N	\N
cmqpwcq4d0008ld04fmhsibir	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 00:19:06.685	2026-06-23 00:19:12.324	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:20	\N	\N	\N
cmqpwq1ro0001jx040h72icfv	13	COMPLETED	\N	30.00	0.00	30.00	2026-06-23 00:29:28.309	2026-06-23 00:32:55.632	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:30	\N	\N	\N
cmqpzln7o0001kt04f99spf20	22	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 01:50:01.668	2026-06-23 01:54:03.556	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 08:50	\N	\N	\N
cmqpvzyb10001jl04u6v8knih	7	COMPLETED	\N	75.00	0.00	75.00	2026-06-23 00:09:10.766	2026-06-23 00:34:48.973	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:30	\N	\N	\N
cmqpxiown000tjx04e4595pmj	19	COMPLETED	\N	25.00	0.00	25.00	2026-06-23 00:51:44.663	2026-06-23 00:53:14.653	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 08:00	\N	\N	\N
cmqpwtjhy0007jx043jjhxb7j	14	COMPLETED	\N	80.00	0.00	80.00	2026-06-23 00:32:11.255	2026-06-23 00:36:24.204	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:30	\N	\N	\N
cmqpvrsq50000kz04fyrrw3hs	6	COMPLETED	เเยกน้ำเเข็งนะคะ 7:40ไปรับค่ะ	35.00	0.00	35.00	2026-06-23 00:02:50.286	2026-06-23 00:47:52.82	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	\N	2026-06-23 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7dae5973-ee42-448f-aef8-cc7b75a88c57.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7dae5973-ee42-448f-aef8-cc7b75a88c57.jpg}	\N
cmqpxfghr000vjf044dofdcuv	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 00:49:13.792	2026-06-23 00:53:19.926	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:50	\N	\N	\N
cmqpxhdgw000njx045dlrlyp2	18	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 00:50:43.184	2026-06-23 00:53:25.034	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 07:50	\N	\N	\N
cmqq03ztn000ckt043fu09fhb	23	COMPLETED	\N	80.00	0.00	80.00	2026-06-23 02:04:17.819	2026-06-23 02:10:07.722	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 09:00	\N	\N	\N
cmqpxj6dt000xjx04mz2oiq29	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 00:52:07.313	2026-06-23 00:54:03.783	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 08:00	\N	\N	\N
cmqq6rct40007i304sag0w9cj	29	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 05:10:25.433	2026-06-23 05:15:54.793	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 12:10	\N	\N	\N
cmqq2zqf30001jo04vpw9hcg3	24	COMPLETED	\N	70.00	0.00	70.00	2026-06-23 03:24:57.855	2026-06-23 03:26:14.003	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 09:10	\N	\N	\N
cmqq307kw000ejo04dohz48nf	25	COMPLETED	\N	80.00	0.00	80.00	2026-06-23 03:25:20.096	2026-06-23 03:26:15.54	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 10:30	\N	\N	\N
cmqq6wdo90001jy046dymokgb	30	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 05:14:19.833	2026-06-23 05:18:30.21	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 12:20	\N	\N	\N
cmqq6obyz0001i304n6oiwdn3	28	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 05:08:04.379	2026-06-23 05:16:03.699	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 12:10	\N	\N	\N
cmqq6nk7f0000l2048tsin8h5	27	COMPLETED	ไม่หวาน	80.00	5.00	75.00	2026-06-23 05:07:28.396	2026-06-23 05:18:25.46	\N	\N	AMOUNT	5.00	cmqomlong0000jo04nvihswtt	7	0	ONLINE	76FD6CD2387B86D6	2026-06-23 12:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/335f8824-f1ac-4c0d-8e25-2ab703822577.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/335f8824-f1ac-4c0d-8e25-2ab703822577.jpg}	\N
cmqq7lilr0000lb0499saxfh7	31	COMPLETED	\N	255.00	0.00	255.00	2026-06-23 05:33:52.624	2026-06-23 06:03:30.672	\N	\N	\N	\N	cmqlxu95y0000lh04zmipokf0	25	0	ONLINE	\N	2026-06-23 13:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1eb0da50-ed2b-488e-96fd-fc0273584573.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1eb0da50-ed2b-488e-96fd-fc0273584573.jpeg}	\N
cmqq8xvem0008lb04odew7367	33	COMPLETED	\N	75.00	0.00	75.00	2026-06-23 06:11:28.702	2026-06-23 06:30:15.35	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 13:20	\N	\N	\N
cmqq93uva000alb043xvmsuhn	34	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 06:16:07.942	2026-06-23 06:30:02.327	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	76FD6CD2387B86D6	2026-06-23 13:20	\N	\N	\N
cmqq8x3770002lb04yos38fog	32	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 06:10:52.147	2026-06-23 06:30:07.157	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 12:20	\N	\N	\N
cmqq9c6me000ilb04jab2xx01	36	COMPLETED	\N	70.00	0.00	70.00	2026-06-23 06:22:36.422	2026-06-23 06:30:19.982	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 13:20	\N	\N	\N
cmqq9mgw6000plb04wyy9ja5n	37	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 06:30:36.295	2026-06-23 06:33:18.993	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-23 13:30	\N	\N	\N
cmqq965hx000flb04hp5wfoxc	35	COMPLETED	\N	40.00	5.00	35.00	2026-06-23 06:17:55.03	2026-06-23 06:18:13.604	\N	\N	AMOUNT	5.00	cmqq92kxf0000jr047jszj64u	3	0	ONLINE	76FD6CD2387B86D6	2026-06-23 13:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5379f870-b3cb-47e4-82aa-2a76adc72af1.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5379f870-b3cb-47e4-82aa-2a76adc72af1.jpg}	\N
cmqrb1gbh0001l404mckhztkx	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-23 23:58:01.181	2026-06-24 00:11:05.238	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:00	\N	\N	\N
cmqra8rjw000ajo04wyg1h3yy	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 23:35:42.717	2026-06-23 23:47:10.35	\N	\N	\N	\N	cmpr50gby0000l204k4iyqunq	4	0	ONLINE	\N	2026-06-24 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a8347759-c4e2-4b39-95a1-aba58693e5e9.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a8347759-c4e2-4b39-95a1-aba58693e5e9.jpeg}	\N
cmqrax84w000bjr04z8ciaayq	7	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 23:54:43.952	2026-06-24 00:11:10.25	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 06:50	\N	\N	\N
cmqrc65f80001l204w0e2gwsx	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:29:39.956	2026-06-24 00:34:00.279	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:30	\N	\N	\N
cmqraodev000akz04pbli9jk3	5	COMPLETED	\N	80.00	0.00	80.00	2026-06-23 23:47:50.887	2026-06-23 23:58:15.31	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 06:50	\N	\N	\N
cmqracpce0001l4043l8c5jyn	3	COMPLETED	\N	75.00	0.00	75.00	2026-06-23 23:38:46.479	2026-06-24 00:11:13.73	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 06:40	\N	\N	\N
cmqram8hw0001kz04wlhybj4y	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-23 23:46:11.205	2026-06-23 23:58:23.075	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 06:40	\N	\N	\N
cmqrcp8x5000eic04k8tjtens	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 00:44:30.953	2026-06-24 00:51:15.022	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:50	\N	\N	\N
cmqrc5jte000ai304ol3p9z3d	14	COMPLETED	\N	30.00	0.00	30.00	2026-06-24 00:29:11.955	2026-06-24 00:34:14.243	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:30	\N	\N	\N
cmqra6zq80000jo046ttet8qg	1	COMPLETED	\N	45.00	0.00	45.00	2026-06-23 23:34:20	2026-06-24 00:07:59.918	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-24 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5d4c9a9-e065-4c17-b85d-593b1434bbab.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5d4c9a9-e065-4c17-b85d-593b1434bbab.jpeg}	\N
cmqrcl5ls0001ic040ei43c90	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:41:20.032	2026-06-24 00:41:27.665	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:30	\N	\N	\N
cmqrbb9zw0001jo0441o02w6x	9	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:05:39.548	2026-06-24 00:11:22.031	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:00	\N	\N	\N
cmqrc41nl0000i304fvg1607m	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:28:01.761	2026-06-24 00:41:29.772	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-24 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5e51403-b132-4e7f-9328-beaa1eacd813.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a5e51403-b132-4e7f-9328-beaa1eacd813.jpeg}	\N
cmqrbjawg000cl40460oj49t7	10	COMPLETED	\N	50.00	0.00	50.00	2026-06-24 00:11:53.969	2026-06-24 00:18:38.267	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:10	\N	\N	\N
cmqrc8fgt0000jm043jieno7v	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 00:31:26.285	2026-06-24 00:41:31.509	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-24 08:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/56014ba2-025b-425c-9a67-74ecb4e2a488.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/56014ba2-025b-425c-9a67-74ecb4e2a488.jpeg}	\N
cmqrbthbh000kjo04qpzlffdk	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:19:48.846	2026-06-24 00:21:36.941	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:20	\N	\N	\N
cmqrc0lok000tjo04qdar3f8j	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:25:21.092	2026-06-24 00:25:34.617	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:20	\N	\N	\N
cmqrcy4e40013jo043h0t4tig	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 00:51:24.989	2026-06-24 00:54:48.221	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 07:50	\N	\N	\N
cmqrfrglq0001l104xmcarnun	25	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 02:10:13.07	2026-06-24 02:10:17.096	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:00	\N	\N	\N
cmqrd263c0001jy045zh4u85f	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 00:54:33.816	2026-06-24 00:54:54.975	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 08:00	\N	\N	\N
cmqrf47jx000hld04hfypa8ay	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 01:52:08.253	2026-06-24 01:53:08.773	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:00	\N	\N	\N
cmqrcy7890019jo04r6sih9gp	20	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 00:51:28.665	2026-06-24 00:55:01.405	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 08:00	\N	\N	\N
cmqravt500000jr04fwnwafc0	6	COMPLETED	เเยกน้ำเเข็งนะคะ 7:40ไปรับค่ะ	35.00	0.00	35.00	2026-06-23 23:53:37.86	2026-06-24 00:56:11.471	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	\N	2026-06-24 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d6b4638f-cc5d-47c0-989a-3407814428e8.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/d6b4638f-cc5d-47c0-989a-3407814428e8.jpg}	\N
cmqrf1mnw0001ld04bd7ymtk0	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 01:50:07.866	2026-06-24 02:00:05.884	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 08:00	\N	\N	\N
cmqrgwl11000bkz04jf7but3l	28	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 02:42:11.702	2026-06-24 02:48:55.961	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:50	\N	\N	\N
cmqrf2gty0007ld04k9pjzsqi	23	COMPLETED	ใส่แก้วชินจัง	40.00	0.00	40.00	2026-06-24 01:50:46.967	2026-06-24 02:00:10.914	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:00	\N	\N	\N
cmqrg9nsl0001ie04ejs3b9hh	26	COMPLETED	\N	75.00	0.00	75.00	2026-06-24 02:24:22.197	2026-06-24 02:41:09.574	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:20	\N	\N	\N
cmqrh5su70005l5048raym4k7	29	COMPLETED	\N	25.00	0.00	25.00	2026-06-24 02:49:21.727	2026-06-24 02:53:14.836	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:50	\N	\N	\N
cmqrgvum70003kz04ag2o6xlv	27	COMPLETED	\N	50.00	0.00	50.00	2026-06-24 02:41:37.471	2026-06-24 02:48:59.928	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:30	\N	\N	\N
cmqrh92r4000bl504oku7ssc3	30	COMPLETED	\N	30.00	0.00	30.00	2026-06-24 02:51:54.545	2026-06-24 02:55:22.493	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 09:50	\N	\N	\N
cmqrhb1fd000jl504iijwrabr	31	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 02:53:26.137	2026-06-24 02:54:41.219	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 10:00	\N	\N	\N
cmqsvs7mv0001jr04vep682sr	25	COMPLETED	\N	110.00	0.00	110.00	2026-06-25 02:26:28.135	2026-06-25 02:41:02.405	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:20	\N	\N	\N
cmqswdvqy0001jp04xxzkyv04	26	COMPLETED	\N	105.00	0.00	105.00	2026-06-25 02:43:19.162	2026-06-25 02:50:12.055	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:50	\N	\N	\N
cmqsx6mqv0001kv04gf0i7sa1	27	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 03:05:40.519	2026-06-25 04:10:32.529	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:50	\N	\N	\N
cmqrlgt5d0000jp04txv6klq2	32	COMPLETED	เดียวลงไปเอาค่ะ	30.00	5.00	25.00	2026-06-24 04:49:53.81	2026-06-24 05:00:43.07	\N	\N	AMOUNT	5.00	cmqkghrt00000l704omhsxuo1	2	0	ONLINE	76FD6CD2387B86D6	2026-06-24 12:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/241dcbd0-d471-4d6a-9d51-29497e01fa9f.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/241dcbd0-d471-4d6a-9d51-29497e01fa9f.jpg}	\N
cmqrlnkzu0000lb04l5awr2va	33	COMPLETED	อเมส้ม(ไม่หวาน)เดี๋ยวเอาแก้วลงไปใส่เจ้า\n\nอเมพีช(ไม่หวาน)ใส่แก้วที่ร้านได้เลยเจ้า	80.00	0.00	80.00	2026-06-24 04:55:09.835	2026-06-24 05:07:15.64	\N	\N	\N	\N	cmqomlong0000jo04nvihswtt	8	0	ONLINE	\N	2026-06-24 12:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/134e135d-9e81-4659-a15d-4d81220dd1d0.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/134e135d-9e81-4659-a15d-4d81220dd1d0.jpg}	\N
cmqsopgjq0000l404rp3y2vou	1	COMPLETED	\N	120.00	0.00	120.00	2026-06-24 23:08:22.406	2026-06-24 23:30:01.441	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	18	0	ONLINE	\N	2026-06-25 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4437b81e-fe40-492c-b4f2-bde19693314d.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/4437b81e-fe40-492c-b4f2-bde19693314d.jpeg}	\N
cmqrm3j3x0001lg04v48yqwyh	34	COMPLETED	\N	30.00	0.00	30.00	2026-06-24 05:07:33.885	2026-06-24 05:07:38.18	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 12:10	\N	\N	\N
cmqspagr00000jr04wv487qjo	2	COMPLETED	\N	70.00	0.00	70.00	2026-06-24 23:24:42.444	2026-06-24 23:34:24.153	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	10	0	ONLINE	\N	2026-06-25 06:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/53767e9d-94d7-4894-8c55-85d00d1475b5.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/53767e9d-94d7-4894-8c55-85d00d1475b5.jpeg}	\N
cmqrm6t1o000nlb04wqn4r05f	36	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 05:10:06.733	2026-06-24 05:16:45.026	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 12:10	\N	\N	\N
cmqrm6gsz000elb04yt2lfy0d	35	COMPLETED	\N	40.00	0.00	40.00	2026-06-24 05:09:50.867	2026-06-24 05:16:46.955	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 12:10	\N	\N	\N
cmqrmngr0000vlb04rbad8inm	37	COMPLETED	\N	320.00	5.00	315.00	2026-06-24 05:23:03.948	2026-06-24 06:01:12.478	\N	\N	AMOUNT	5.00	cmqlxu95y0000lh04zmipokf0	31	0	ONLINE	76FD6CD2387B86D6	2026-06-24 12:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5a687cf8-87b6-428f-b7d0-40098421d6ba.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5a687cf8-87b6-428f-b7d0-40098421d6ba.jpeg}	\N
cmqrnimbr0001jj0465jdmyhm	38	COMPLETED	\N	105.00	0.00	105.00	2026-06-24 05:47:17.511	2026-06-24 06:17:51.962	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-24 12:20	\N	\N	\N
cmqsqbh380001jv04fa9hjogy	6	COMPLETED	\N	80.00	0.00	80.00	2026-06-24 23:53:29.156	2026-06-24 23:58:49.224	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 06:40	\N	\N	\N
cmqsqnrgy000kjv04s812jxc5	9	COMPLETED	\N	70.00	0.00	70.00	2026-06-25 00:03:02.482	2026-06-25 00:17:06.603	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:10	\N	\N	\N
cmqsqb9rd0000l504xxf1rosa	5	COMPLETED	เเยกน้ำแข็ง	40.00	0.00	40.00	2026-06-24 23:53:19.658	2026-06-25 00:45:55.975	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	4	0	ONLINE	\N	2026-06-25 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04bfdada-5496-4f7d-b6dd-b236632dff07.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/04bfdada-5496-4f7d-b6dd-b236632dff07.jpg}	\N
cmqspwbay0004js04g2lmr5jc	4	COMPLETED	\N	180.00	5.00	175.00	2026-06-24 23:41:41.819	2026-06-25 00:24:35.72	\N	\N	AMOUNT	5.00	cmqfwfly2000xjv048t8vu8hk	17	0	ONLINE	76FD6CD2387B86D6	2026-06-25 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/bbe21334-aae4-44fc-b535-190e5310f737.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/bbe21334-aae4-44fc-b535-190e5310f737.jpeg}	\N
cmqsqcot5000ajv04bqqbxo80	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-24 23:54:25.817	2026-06-25 00:01:06.753	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:00	\N	\N	\N
cmqspu3px0001l7042wk9u83x	3	COMPLETED	\N	75.00	0.00	75.00	2026-06-24 23:39:58.677	2026-06-25 00:02:03.608	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 06:20	\N	\N	\N
cmqsr2w4q001ajs04hqimym69	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 00:14:48.362	2026-06-25 00:23:08.734	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:20	\N	\N	\N
cmqsqs6uo0014jv04smldlbth	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 00:06:29.04	2026-06-25 00:18:04.826	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:10	\N	\N	\N
cmqsr4lze001gjs04r00zb0f2	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 00:16:08.522	2026-06-25 00:34:31.656	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:20	\N	\N	\N
cmqsql12w000tjs0452jscqle	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 00:00:54.968	2026-06-25 00:23:15.937	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:00	\N	\N	\N
cmqsqxi1s001bjv049v7gmnik	12	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 00:10:36.832	2026-06-25 00:18:06.911	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:10	\N	\N	\N
cmqsqzvh10014js04ryxuzh7o	13	COMPLETED	\N	45.00	0.00	45.00	2026-06-25 00:12:27.542	2026-06-25 00:24:33.406	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:20	\N	\N	\N
cmqsrxt81002bjs04v79dal5h	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 00:38:50.929	2026-06-25 00:41:39.504	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:30	\N	\N	\N
cmqsqpgzf000rjv04zq0k50d2	10	COMPLETED	\N	65.00	0.00	65.00	2026-06-25 00:04:22.203	2026-06-25 00:22:53.153	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:10	\N	\N	\N
cmqsraqs9001rjs04h1hms8lq	16	COMPLETED	\N	30.00	0.00	30.00	2026-06-25 00:20:54.681	2026-06-25 00:29:27.526	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:20	\N	\N	\N
cmqsrwzrq0000l5040gm3nkc8	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 00:38:12.758	2026-06-25 00:41:42.743	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-25 08:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7f15f3d4-fdc6-4e45-aafa-d05f59ee49f5.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/7f15f3d4-fdc6-4e45-aafa-d05f59ee49f5.jpeg}	\N
cmqss6unk002ljs04vzfop6g8	19	COMPLETED	\N	75.00	0.00	75.00	2026-06-25 00:45:52.688	2026-06-25 00:51:04.796	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:40	\N	\N	\N
cmqssend5002yjs04okujv8et	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 00:51:56.489	2026-06-25 00:53:53.568	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 07:50	\N	\N	\N
cmqsujg810001jp04gj2edgq1	21	COMPLETED	\N	65.00	0.00	65.00	2026-06-25 01:51:39.745	2026-06-25 01:52:06.678	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 08:00	\N	\N	\N
cmqsvh2wd0001ic04vdtnplx8	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 02:17:48.781	2026-06-25 02:19:47.76	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:00	\N	\N	\N
cmqsvh63a0007ic04ok0g4ggp	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 02:17:52.918	2026-06-25 02:19:51.958	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:20	\N	\N	\N
cmqsvhfat000dic045z00p714	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 02:18:04.854	2026-06-25 02:21:36.799	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 09:20	\N	\N	\N
cmqtj9p2i00003xqf43kb9wo4	1	COMPLETED	\N	40.00	5.00	35.00	2026-06-25 13:23:55.051	2026-06-25 23:55:14.321	\N	\N	AMOUNT	5.00	cmpr50gby0000l204k4iyqunq	3	0	ONLINE	76FD6CD2387B86D6	2026-06-25 20:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f82bcd05-76ea-4ace-9372-57d796c062b7.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/f82bcd05-76ea-4ace-9372-57d796c062b7.jpg}	\N
cmqsziijv0001ld041aaxvbov	29	COMPLETED	\N	120.00	0.00	120.00	2026-06-25 04:10:54.187	2026-06-25 04:11:15.316	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 10:10	\N	\N	\N
cmqsymgxl0000le04e1apu8b2	28	COMPLETED	เดียวเดินลงไปเอาตอนเที่ยง	60.00	0.00	60.00	2026-06-25 03:45:59.097	2026-06-25 05:02:48.109	\N	\N	\N	\N	cmqkghrt00000l704omhsxuo1	6	0	ONLINE	\N	2026-06-25 12:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5fd6da3a-5484-4422-8e3e-dd373a4320db.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/5fd6da3a-5484-4422-8e3e-dd373a4320db.jpeg}	\N
cmqu5ph4u000tl204qbuj1d31	5	CANCELLED	\N	225.00	0.00	225.00	2026-06-25 23:52:02.814	2026-06-26 00:35:01.893	\N	\N	\N	\N	cmqfwfly2000xjv048t8vu8hk	22	0	ONLINE	\N	2026-06-26 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b613ebb4-1dec-48c1-bd6b-7bc6efa77ef8.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b613ebb4-1dec-48c1-bd6b-7bc6efa77ef8.jpeg}	\N
cmqt1clfd0001l7045bfcatmr	31	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 05:02:17.209	2026-06-25 05:09:54.753	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 11:20	\N	\N	\N
cmqt160cf0000l504vdkn128n	30	COMPLETED	ไม่หวานเจ้า	80.00	0.00	80.00	2026-06-25 04:57:09.951	2026-06-25 05:09:57.077	\N	\N	\N	\N	cmqomlong0000jo04nvihswtt	8	0	ONLINE	\N	2026-06-25 12:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/23edce04-65df-4ee0-91bd-a6802dde5ef4.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/23edce04-65df-4ee0-91bd-a6802dde5ef4.jpg}	\N
cmqt3j7kp0001jp0477j6jcj8	32	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 06:03:25.081	2026-06-25 06:15:11.746	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 12:10	\N	\N	\N
cmqt3yob20003l504pdzkz1dc	33	COMPLETED	\N	105.00	0.00	105.00	2026-06-25 06:15:26.607	2026-06-25 06:15:58.561	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-25 13:10	\N	\N	\N
cmqu5u99y0001le04bwto7o2r	6	COMPLETED	\N	40.00	0.00	40.00	2026-06-25 23:55:45.91	2026-06-26 00:06:03.445	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 06:40	\N	\N	\N
cmqu5z3xf001wl204f103vh45	8	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 23:59:32.26	2026-06-26 00:01:39.828	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:00	\N	\N	\N
cmqu5wd1z001pl204snbpud2p	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-25 23:57:24.119	2026-06-26 00:01:44.235	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:00	\N	\N	\N
cmqu6niaf000lle04xd561dlx	17	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 00:18:30.616	2026-06-26 00:19:51.295	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:20	\N	\N	\N
cmqu54za30001kz04rauytwb9	2	COMPLETED	\N	80.00	0.00	80.00	2026-06-25 23:36:06.555	2026-06-26 00:01:55.665	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 06:40	\N	\N	\N
cmqu5bmn80000js047iejoava	3	COMPLETED	\N	60.00	0.00	60.00	2026-06-25 23:41:16.772	2026-06-26 00:02:04.227	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	9	0	ONLINE	\N	2026-06-26 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e432e313-7e61-4009-a778-e0ebc990b667.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/e432e313-7e61-4009-a778-e0ebc990b667.jpeg}	\N
cmqu69t7f002jl204qa98wvj9	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 00:07:51.579	2026-06-26 00:11:28.078	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:10	\N	\N	\N
cmqu6a3pw002pl2041bhr1er8	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:08:05.204	2026-06-26 00:47:16.755	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:10	\N	\N	\N
cmqu6gd5a002vl20464g25uuo	15	COMPLETED	\N	70.00	0.00	70.00	2026-06-26 00:12:57.358	2026-06-26 00:17:34.469	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:20	\N	\N	\N
cmqu675xn0000jl04uptlngix	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:05:48.107	2026-06-26 00:54:33.712	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	4	0	ONLINE	\N	2026-06-26 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/373ded82-6f91-4a45-a490-261faeb8dcf8.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/373ded82-6f91-4a45-a490-261faeb8dcf8.jpg}	\N
cmqu6lors000dle04oi7ou1pt	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:17:05.705	2026-06-26 00:26:08.858	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:20	\N	\N	\N
cmqu5ov4b0000l2046p93napv	4	COMPLETED	\N	225.00	0.00	225.00	2026-06-25 23:51:34.283	2026-06-26 00:34:09.354	\N	\N	\N	\N	cmqfwfly2000xjv048t8vu8hk	22	0	ONLINE	\N	2026-06-26 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/363d0fb0-e37f-4c7a-ac5d-874a6d7fed27.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/363d0fb0-e37f-4c7a-ac5d-874a6d7fed27.jpeg}	\N
cmqu7d0h20001ld04nck0xfpz	18	COMPLETED	\N	30.00	0.00	30.00	2026-06-26 00:38:20.582	2026-06-26 00:42:02.616	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:30	\N	\N	\N
cmqu6frwa0009l805c8bbgv7j	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 00:12:29.818	2026-06-26 00:42:05.957	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-26 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/2693ce45-5f4d-4924-8620-ca7f66ca5189.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/2693ce45-5f4d-4924-8620-ca7f66ca5189.jpeg}	\N
cmqu6fd6q0003l805cb43bo12	13	COMPLETED	\N	75.00	0.00	75.00	2026-06-26 00:12:10.754	2026-06-26 00:42:18.659	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:10	\N	\N	\N
cmqu60x7w0022l204wlhxlvfv	9	COMPLETED	โมส	80.00	0.00	80.00	2026-06-26 00:00:56.877	2026-06-26 00:49:06.506	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:30	\N	\N	\N
cmqu7vtwl000old04p32hvbyx	21	COMPLETED	\N	65.00	0.00	65.00	2026-06-26 00:52:58.533	2026-06-26 00:57:04.523	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:50	\N	\N	\N
cmqu7jpdz0007ld04c9pzibry	19	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 00:43:32.807	2026-06-26 00:58:55.848	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:40	\N	\N	\N
cmqu7mptc000eld04scjjmsi9	20	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:45:53.328	2026-06-26 00:58:59.823	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 07:50	\N	\N	\N
cmqu7w23g000wld04a62csjo2	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:53:09.148	2026-06-26 00:59:07.501	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 08:00	\N	\N	\N
cmqu7wiin0012ld04lgsadinz	23	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 00:53:30.432	2026-06-26 01:00:32.403	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 08:00	\N	\N	\N
cmqu80m830014le04rswffq6b	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 00:56:41.859	2026-06-26 01:02:39.291	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 08:00	\N	\N	\N
cmqubd48a0001l704ooyhcy58	25	COMPLETED	\N	80.00	0.00	80.00	2026-06-26 02:30:23.915	2026-06-26 02:40:32.161	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 08:00	\N	\N	\N
cmqubgzgi000bl70463lc0etm	26	COMPLETED	\N	75.00	0.00	75.00	2026-06-26 02:33:24.354	2026-06-26 02:47:47.85	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 09:40	\N	\N	\N
cmqubqvo1000ql704r4ryecj4	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 02:41:06.001	2026-06-26 02:52:19.23	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 09:40	\N	\N	\N
cmqvky38n0000jv04kb6dkv59	3	COMPLETED	\N	110.00	0.00	110.00	2026-06-26 23:46:25.128	2026-06-27 00:11:31.701	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	16	0	ONLINE	\N	2026-06-27 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/10253af1-ac6f-4606-b556-c82aa05107cd.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/10253af1-ac6f-4606-b556-c82aa05107cd.jpeg}	\N
cmquc8umj0002ju04vd21peyy	28	COMPLETED	ใช้คนละครึ่งหน้าร้าน	110.00	0.00	110.00	2026-06-26 02:55:04.459	2026-06-26 03:06:26.147	\N	\N	\N	\N	cmq7hdolg000klb04x9d9hye6	11	0	ONLINE	\N	2026-06-26 10:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/675c1035-ab91-4996-a7eb-ce913ecb5b1c.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/675c1035-ab91-4996-a7eb-ce913ecb5b1c.jpeg}	\N
cmquczn5m0001jp046l5dm6i0	29	COMPLETED	\N	75.00	0.00	75.00	2026-06-26 03:15:54.491	2026-06-26 03:21:56.138	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 09:50	\N	\N	\N
cmquf4zs60001l70456s6f7d9	30	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 04:16:03.366	2026-06-26 04:24:01.284	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 10:20	\N	\N	\N
cmqvlp9nq000eky04hutle273	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 00:07:33.159	2026-06-27 00:23:28.996	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:10	\N	\N	\N
cmqugvw1e0001ky04g8uwr83y	31	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 05:04:57.842	2026-06-26 05:05:14.191	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 12:10	\N	\N	\N
cmquh8biu0009ky04yv8gi8s4	32	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 05:14:37.782	2026-06-26 05:17:43.797	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 12:10	\N	\N	\N
cmquhvspy0001kz04nsqifvjn	33	COMPLETED	\N	75.00	0.00	75.00	2026-06-26 05:32:53.159	2026-06-26 05:36:17.13	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 12:20	\N	\N	\N
cmquiehyl0001l804zjf2li7i	34	COMPLETED	\N	35.00	0.00	35.00	2026-06-26 05:47:25.677	2026-06-26 05:48:10.441	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 12:40	\N	\N	\N
cmquismqe0001l40446lmetom	35	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 05:58:25.046	2026-06-26 05:58:29.183	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 12:50	\N	\N	\N
cmqvkh56r0003jr04nvnq7sib	1	COMPLETED	\N	115.00	0.00	115.00	2026-06-26 23:33:14.499	2026-06-26 23:39:01.213	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-26 11:20	\N	\N	\N
cmqvkhuen0001l904r8yvo1hy	2	COMPLETED	\N	40.00	0.00	40.00	2026-06-26 23:33:47.183	2026-06-26 23:39:56.623	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 06:40	\N	\N	\N
cmqvme3ch0007l504e2y4gqjd	13	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 00:26:51.377	2026-06-27 00:31:22.826	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:30	\N	\N	\N
cmqvlwhwu0009js04kjz4nt37	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 00:13:10.447	2026-06-27 00:23:41.305	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-27 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ab052e53-73ae-4e44-8dc5-907745649385.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ab052e53-73ae-4e44-8dc5-907745649385.jpeg}	\N
cmqvlt1ke000uky04g29ikceg	10	COMPLETED	\N	105.00	0.00	105.00	2026-06-27 00:10:29.295	2026-06-27 00:53:39.147	\N	\N	\N	\N	cmpzm4vyo0000jv04i6eeh20d	13	0	ONLINE	\N	2026-06-27 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/6afaad8c-51d1-4421-8a66-47463077eea2.png	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/6afaad8c-51d1-4421-8a66-47463077eea2.png}	\N
cmqvlln5v0001l504vvs9n8t7	5	COMPLETED	\N	45.00	0.00	45.00	2026-06-27 00:04:44.035	2026-06-27 00:11:21.64	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:10	\N	\N	\N
cmqvlh5e20000kt047pb74whb	4	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 00:01:14.378	2026-06-27 00:11:25.105	\N	\N	\N	\N	cmqiqhmsp0001l104ukcdhhbl	3	0	ONLINE	\N	2026-06-27 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/33a4f02d-3c11-444e-8a94-b176e2ff2da2.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/33a4f02d-3c11-444e-8a94-b176e2ff2da2.jpeg}	\N
cmqvlob4k0001ky04l2nm9erh	6	COMPLETED	\N	115.00	0.00	115.00	2026-06-27 00:06:48.404	2026-06-27 00:16:43.111	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:10	\N	\N	\N
cmqvm8ttk000jjs04n9z1w6ab	12	COMPLETED	\N	30.00	0.00	30.00	2026-06-27 00:22:45.752	2026-06-27 00:25:08.624	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:10	\N	\N	\N
cmqvmyrne0017l504y6dbhc1m	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 00:42:55.994	2026-06-27 00:49:39.011	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:50	\N	\N	\N
cmqvn46sv000vjs047vif4rei	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 00:47:08.912	2026-06-27 00:52:24.774	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:50	\N	\N	\N
cmqvlow8u0001js04fhes2gts	7	COMPLETED	มิ้น	35.00	0.00	35.00	2026-06-27 00:07:15.775	2026-06-27 00:27:23.399	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:10	\N	\N	\N
cmqvmsyb7000gl504zwb6jq4x	15	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 00:38:24.691	2026-06-27 00:42:25.225	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:30	\N	\N	\N
cmqvmin8o0000l804spujq9oh	14	COMPLETED	\N	45.00	0.00	45.00	2026-06-27 00:30:23.785	2026-06-27 00:45:36.842	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-27 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8ad4736e-cdbf-4d19-a7cc-9b0764c3e9a0.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/8ad4736e-cdbf-4d19-a7cc-9b0764c3e9a0.jpeg}	\N
cmqvlpbty000kky04pk9aro6k	9	COMPLETED	\N	45.00	0.00	45.00	2026-06-27 00:07:35.975	2026-06-27 00:48:53.75	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	4	0	ONLINE	\N	2026-06-27 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1624d2b6-700a-460b-986c-8f92c69c6088.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/1624d2b6-700a-460b-986c-8f92c69c6088.jpg}	\N
cmqvmvukw000ml504g5cuk2uj	16	COMPLETED	\N	115.00	0.00	115.00	2026-06-27 00:40:39.824	2026-06-27 01:03:06.617	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:40	\N	\N	\N
cmqvpuzmx0001l404y5wwm65n	22	COMPLETED	\N	70.00	0.00	70.00	2026-06-27 02:03:58.569	2026-06-27 02:11:53.789	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:10	\N	\N	\N
cmqvn92xz001fl504eqzrcnem	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 00:50:57.192	2026-06-27 00:52:40.575	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 07:50	\N	\N	\N
cmqvpsalm0001if04s0klkhz1	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 02:01:52.81	2026-06-27 02:02:14.824	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 08:00	\N	\N	\N
cmqvpsltp0008if0495ohbj5u	21	COMPLETED	\N	80.00	0.00	80.00	2026-06-27 02:02:07.358	2026-06-27 02:11:57.575	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:10	\N	\N	\N
cmqvq5iib000nif04khems3ja	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-27 02:12:09.588	2026-06-27 02:14:58.106	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:10	\N	\N	\N
cmqvqneyd0001jp040k4velvo	24	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 02:26:04.79	2026-06-27 02:28:38.332	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:20	\N	\N	\N
cmqvqzqb20009jp04kleo41np	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-27 02:35:39.374	2026-06-27 03:11:13.978	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:30	\N	\N	\N
cmqvsgo950001jz04eqyq4qdh	26	COMPLETED	\N	30.00	0.00	30.00	2026-06-27 03:16:49.481	2026-06-27 03:16:55.226	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 09:40	\N	\N	\N
cmqyfuauz000ajl04jm0rhham	4	COMPLETED	\N	40.00	0.00	40.00	2026-06-28 23:46:48.827	2026-06-28 23:54:48.749	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-29 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/09dd7957-467b-44e9-b82d-b72b85c0ae73.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/09dd7957-467b-44e9-b82d-b72b85c0ae73.jpeg}	\N
cmqynbmy60001jm0420rys5i7	22	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 03:16:14.958	2026-06-29 03:19:50.567	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 09:50	\N	\N	\N
cmqvvczoc0000l104ibzig4ya	28	COMPLETED	ไม่หวานเจ้า	40.00	0.00	40.00	2026-06-27 04:37:56.508	2026-06-27 05:09:12.897	\N	\N	\N	\N	cmqomlong0000jo04nvihswtt	4	0	ONLINE	\N	2026-06-27 12:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/22bd95be-abef-4c60-a7c8-36735c1ee33f.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/22bd95be-abef-4c60-a7c8-36735c1ee33f.jpg}	2026-06-27 05:05:15.485
cmqvtju9w0000jm04ug3a25pj	27	COMPLETED	ตอนเที่ยงลงไปเอาเจ้า	35.00	0.00	35.00	2026-06-27 03:47:16.868	2026-06-27 05:09:13.459	\N	\N	\N	\N	cmqkghrt00000l704omhsxuo1	3	0	ONLINE	\N	2026-06-27 12:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3f1f2dee-8b29-49d0-931b-f77821f560d1.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/3f1f2dee-8b29-49d0-931b-f77821f560d1.jpeg}	2026-06-27 05:05:05.979
cmqyhje5a000bjx04xead26pw	11	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 00:34:19.102	2026-06-29 00:34:37.434	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:20	\N	\N	\N
cmqyg31jy0001lb04mbdalepf	5	COMPLETED	\N	35.00	0.00	35.00	2026-06-28 23:53:36.67	2026-06-28 23:57:03.104	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 06:50	\N	\N	\N
cmqyfm4qb0001jl043aulsxd4	2	COMPLETED	\N	35.00	0.00	35.00	2026-06-28 23:40:27.635	2026-06-28 23:40:36.905	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-27 12:10	\N	\N	\N
cmqyl4dx50001l204cp6l0030	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 02:14:37.433	2026-06-29 02:18:11.308	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 08:00	\N	\N	\N
cmqyf83fy0000jo04udtgo417	1	COMPLETED	\N	110.00	0.00	110.00	2026-06-28 23:29:32.782	2026-06-28 23:52:49.491	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	16	0	ONLINE	\N	2026-06-29 07:00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/90d55ca1-49bb-4ddf-a5c7-a81db7365177.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/90d55ca1-49bb-4ddf-a5c7-a81db7365177.jpeg}	\N
cmqyl59i80007l204l1ow01t4	18	COMPLETED	\N	80.00	0.00	80.00	2026-06-29 02:15:18.368	2026-06-29 02:22:08.999	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 09:20	\N	\N	\N
cmqyhu0s50001jl041x0n7755	12	COMPLETED	\N	80.00	0.00	80.00	2026-06-29 00:42:34.997	2026-06-29 00:47:48.704	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:40	\N	\N	\N
cmqyg5nbh000cjl04zj4u576u	6	COMPLETED	\N	50.00	0.00	50.00	2026-06-28 23:55:38.19	2026-06-29 00:07:52.08	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:00	\N	\N	\N
cmqyg5tjs000jjl04uopxfksu	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-28 23:55:46.265	2026-06-29 00:07:57.136	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:00	\N	\N	\N
cmqyhwqe2000jjx04yxewshue	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-29 00:44:41.498	2026-06-29 00:48:58.635	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:50	\N	\N	\N
cmqyg7p85000sjl046p7dojk3	8	COMPLETED	\N	40.00	0.00	40.00	2026-06-28 23:57:13.974	2026-06-29 00:08:01.439	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:00	\N	\N	\N
cmqygs0l50015jl049wz8rtwo	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 00:13:01.817	2026-06-29 00:24:44.118	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:00	\N	\N	\N
cmqyi1rza000djl04jxepzoob	14	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 00:48:36.838	2026-06-29 00:50:34.975	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:50	\N	\N	\N
cmqyh0nsh0001jx048s9ggllz	10	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 00:19:45.137	2026-06-29 00:24:49.233	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:20	\N	\N	\N
cmqyfrmqz0000jl043dbmovp4	3	COMPLETED	\N	35.00	0.00	35.00	2026-06-28 23:44:44.267	2026-06-29 00:52:08.216	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	\N	2026-06-29 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/266fefc6-f52d-4ae3-a580-ea1bf7b7d74d.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/266fefc6-f52d-4ae3-a580-ea1bf7b7d74d.jpg}	\N
cmqylepff000il204aj6lrrmi	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 02:22:38.908	2026-06-29 02:27:38.497	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 09:20	\N	\N	\N
cmqyi6tet000sjx04b8gieg51	15	COMPLETED	\N	45.00	0.00	45.00	2026-06-29 00:52:31.973	2026-06-29 00:53:00.886	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 07:50	\N	\N	\N
cmqyi7tyg000yjx04ekdlsh4k	16	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 00:53:19.337	2026-06-29 00:54:44.086	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 08:00	\N	\N	\N
cmqylseoo0001kz04luk3w457	20	COMPLETED	\N	30.00	0.00	30.00	2026-06-29 02:33:18.168	2026-06-29 02:33:21.999	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 09:30	\N	\N	\N
cmqyma7970001l80423o6e1qy	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-29 02:47:08.347	2026-06-29 02:47:19.194	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 09:40	\N	\N	\N
cmqyr7p970001l704qnksm8yz	26	COMPLETED	\N	80.00	0.00	80.00	2026-06-29 05:05:09.787	2026-06-29 05:07:00.955	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 12:10	\N	\N	\N
cmqynlxtb0001l704n1ujt39m	23	COMPLETED	\N	180.00	0.00	180.00	2026-06-29 03:24:15.6	2026-06-29 03:35:52.64	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 10:20	\N	\N	\N
cmqynx3nq000ajm04aybmf5jf	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 03:32:56.391	2026-06-29 03:37:29.603	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 10:30	\N	\N	\N
cmqyr806q000dl704ofw5w18i	28	COMPLETED	\N	30.00	0.00	30.00	2026-06-29 05:05:23.954	2026-06-29 05:06:38.092	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 12:10	\N	\N	\N
cmqyqzxsi0008l4046nu694oa	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-29 04:59:07.602	2026-06-29 04:59:27.734	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 10:40	\N	\N	\N
cmqyr7w4m0007l704tpra1cj6	27	COMPLETED	\N	35.00	0.00	35.00	2026-06-29 05:05:18.695	2026-06-29 05:06:48.54	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-29 12:10	\N	\N	\N
cmqzunybb0001l504m2hke39o	3	COMPLETED	\N	155.00	0.00	155.00	2026-06-29 23:29:33.047	2026-06-30 00:30:26.587	\N	\N	\N	\N	cmqzu4sql0000l504bnw2yan4	15	0	ONLINE	\N	2026-06-30 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/42ae1a33-083f-4d56-99ee-04bb8688e2fe.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/42ae1a33-083f-4d56-99ee-04bb8688e2fe.jpeg}	\N
cmqzu62160000jn04v7d8urqd	1	COMPLETED	\N	150.00	5.00	145.00	2026-06-29 23:15:38.058	2026-06-30 00:30:32.561	\N	\N	AMOUNT	5.00	cmqyznxcy0000jo0477ol00sq	14	0	ONLINE	76FD6CD2387B86D6	2026-06-30 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b27191a2-c571-4a07-bc68-c53b7e5bc395.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/b27191a2-c571-4a07-bc68-c53b7e5bc395.jpeg}	\N
cmqzvnxad000al704oapxd2t8	5	COMPLETED	\N	40.00	0.00	40.00	2026-06-29 23:57:31.333	2026-06-30 00:25:01.272	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	6	0	ONLINE	\N	2026-06-30 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/abeb018f-5eb6-4f0e-a6cd-9160b0a05824.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/abeb018f-5eb6-4f0e-a6cd-9160b0a05824.jpeg}	\N
cmqzvrvno0000k1046rg92011	7	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:00:35.845	2026-06-30 00:27:08.402	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-30 07:15	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ea7642c0-b536-4cfb-85ed-4da93c8a7baa.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ea7642c0-b536-4cfb-85ed-4da93c8a7baa.jpeg}	\N
cmqzxim3x0025l204cqx361h5	22	COMPLETED	\N	30.00	0.00	30.00	2026-06-30 00:49:22.798	2026-06-30 00:55:34.555	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:50	\N	\N	\N
cmqzva6ev0001l704zds8z4u5	4	COMPLETED	\N	80.00	0.00	80.00	2026-06-29 23:46:49.975	2026-06-30 00:02:47.701	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 06:30	\N	\N	\N
cmqzvtoh20001ib04wwg2el8k	8	COMPLETED	\N	75.00	0.00	75.00	2026-06-30 00:01:59.846	2026-06-30 00:29:11.241	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:00	\N	\N	\N
cmr00umwc0008l704gvxzuz0w	30	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 02:22:42.54	2026-06-30 02:32:40.103	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:30	\N	\N	\N
cmqzwty7s000hl204nk415prf	15	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:30:12.088	2026-06-30 00:36:24.404	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:30	\N	\N	\N
cmqzxbcx6001nl204abmhwnti	20	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:43:44.299	2026-06-30 00:49:06.638	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:50	\N	\N	\N
cmqzw141o000bl204hy27jx4g	12	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:07:46.62	2026-06-30 00:29:15.002	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:10	\N	\N	\N
cmqzvoicx0001l404lbbs275o	6	COMPLETED	\N	70.00	0.00	70.00	2026-06-29 23:57:58.641	2026-06-30 00:17:39.326	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 06:50	\N	\N	\N
cmqzvua1b000aib048uzjrcot	9	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:02:27.791	2026-06-30 00:17:43.601	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:10	\N	\N	\N
cmqzwuqoe000rl204d3zt5ock	16	COMPLETED	\N	70.00	0.00	70.00	2026-06-30 00:30:48.974	2026-06-30 00:40:16.637	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:40	\N	\N	\N
cmr00nkfb0001jr04oaxfco8s	26	COMPLETED	\N	85.00	0.00	85.00	2026-06-30 02:17:12.743	2026-06-30 02:21:24.373	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:10	\N	\N	\N
cmqzw0kco0000ju044iic57q3	11	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:07:21.096	2026-06-30 00:31:04.127	\N	\N	\N	\N	cmqiqhmsp0001l104ukcdhhbl	3	0	ONLINE	\N	2026-06-30 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a78083fe-8e2d-41de-aede-204382cbe1e3.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/a78083fe-8e2d-41de-aede-204382cbe1e3.jpeg}	\N
cmqzu88gj000ijn04pahaail0	2	COMPLETED	\N	55.00	0.00	55.00	2026-06-29 23:17:19.7	2026-06-30 00:31:05.49	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	8	0	ONLINE	\N	2026-06-30 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/966adc6f-0a83-4787-b20e-6e54ec4e3942.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/966adc6f-0a83-4787-b20e-6e54ec4e3942.jpeg}	\N
cmqzwlqo40000l2046fbrbgqb	13	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:23:49.061	2026-06-30 00:50:17.78	\N	\N	\N	\N	cmpymupkz0000js04v26bxcpp	5	0	ONLINE	\N	2026-06-30 07:45	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0dc5526a-1e9e-4c7d-b94e-5a967186ac9e.jpeg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/0dc5526a-1e9e-4c7d-b94e-5a967186ac9e.jpeg}	\N
cmqzwtdpv000al204vcrawf87	14	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:29:45.523	2026-06-30 00:32:16.961	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:10	\N	\N	\N
cmqzwuvzo000yl204m20n58yv	17	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:30:55.861	2026-06-30 00:40:20.708	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:40	\N	\N	\N
cmqzxk1dy000fjv044mvfouyo	23	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:50:29.254	2026-06-30 00:56:23.8	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:50	\N	\N	\N
cmqzx77x10005jv04241e0lrn	19	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:40:31.189	2026-06-30 00:42:24.334	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:40	\N	\N	\N
cmqzw02l10000l204fi314iya	10	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:06:58.069	2026-06-30 00:46:15.287	\N	\N	\N	\N	cmqhb2kc7000sl704mpvec7wu	3	0	ONLINE	\N	2026-06-30 07:30	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ee720fb4-f908-4a9d-ab56-dbe1e4a449a3.jpg	{https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/slips/ee720fb4-f908-4a9d-ab56-dbe1e4a449a3.jpg}	\N
cmqzzyl1j0001l504kjjdl86c	24	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 01:57:47.143	2026-06-30 01:59:25.328	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 08:00	\N	\N	\N
cmqzx16gl001al204t63ek0jx	18	COMPLETED	\N	40.00	0.00	40.00	2026-06-30 00:35:49.366	2026-06-30 00:53:00.207	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:40	\N	\N	\N
cmqzxgkla001wl204k7ppbu3t	21	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 00:47:47.518	2026-06-30 00:53:04.683	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 07:50	\N	\N	\N
cmr00nqhc000bjr04bt0bcm9x	27	READY	\N	35.00	0.00	35.00	2026-06-30 02:17:20.592	2026-06-30 02:23:21.03	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:20	\N	\N	\N
cmr005g1o000al504dg4nt2zo	25	COMPLETED	\N	35.00	0.00	35.00	2026-06-30 02:03:07.26	2026-06-30 02:05:22.19	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:00	\N	\N	\N
cmr00u9g20001l704mgsfpx3d	29	READY	\N	35.00	0.00	35.00	2026-06-30 02:22:25.106	2026-06-30 02:32:30.934	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:20	\N	\N	\N
cmr00oysw000ijr042fy8yjhf	28	READY	\N	75.00	0.00	75.00	2026-06-30 02:18:18.032	2026-06-30 02:32:30.933	cmprd13vv00003xwd57f832st	\N	\N	\N	\N	0	0	POS	\N	2026-06-30 09:20	\N	\N	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.payments (id, method, amount, change, "transactionRef", "paidAt", "orderId") FROM stdin;
cmprrzjr00007jt04my8g17b3	QR	40.00	0.00	\N	2026-05-30 03:12:43.452	cmprrzj440001jt04g0o4pnfx
cmpw7kzf4000gjs04mg2b5sk9	CASH	105.00	0.00	\N	2026-06-02 05:40:22.48	cmpw7kynu0001js043af1n07i
cmpw7ll0j000pjs045vjgks68	CASH	140.00	0.00	\N	2026-06-02 05:40:50.467	cmpw7lkgv000ijs04hyofli3c
cmpw7m0vx000yjs041difnrw6	CASH	35.00	0.00	\N	2026-06-02 05:41:11.038	cmpw7m0j0000rjs04ayicm4w3
cmpw7ol3m001jjs04ou0zx7xn	CASH	220.00	0.00	\N	2026-06-02 05:43:10.546	cmpw7okso0010js04oxd0l2ja
cmpw7p6tb001zjs04si6243bl	CASH	135.00	0.00	\N	2026-06-02 05:43:38.688	cmpw7p6f3001ljs0493v3ovqi
cmpw7u7s2002tjs047s08i1sx	CASH	390.00	0.00	\N	2026-06-02 05:47:33.218	cmpw7u75d0021js04vam6tebi
cmpw7wuus0039js04w24mu92v	CASH	160.00	0.00	\N	2026-06-02 05:49:36.437	cmpw7wuk2002vjs04gnhdu0p7
cmpw7yfya003jjs04cnbtmfi4	CASH	80.00	0.00	\N	2026-06-02 05:50:50.434	cmpw7yf7n003bjs044xfq7m6y
cmpw82mlw000il404ehd4e0zq	CASH	160.00	0.00	\N	2026-06-02 05:54:05.684	cmpw82lzi0001l4041sqpnwip
cmpy6ez9s00073xoz9k4bs51y	QR	40.00	0.00	\N	2026-06-03 14:43:15.088	cmpy6et8w00013xozwek9fuyg
cmpy7do5m00073xil165k7dcd	THAI_HELP	40.00	0.00	\N	2026-06-03 15:10:13.642	cmpy7dhzs00013xilojuzzw97
cmpy8t5vv000fl5044fqbdomt	CASH	40.00	0.00	\N	2026-06-03 15:50:16.075	cmpy8t5ah0009l504125vt8kh
cmpy8wki80009kw04v1e10tqg	CASH	50.00	0.00	\N	2026-06-03 15:52:54.992	cmpy8wk4t0001kw049zwbalm2
cmpyo25030009k305x4ndit7f	QR	40.00	0.00	\N	2026-06-03 22:57:09.075	cmpyo24f70001k305w69f14oy
cmpyo3cic000mk305bm8jmlph	QR	70.00	0.00	\N	2026-06-03 22:58:05.46	cmpyo3c3f000bk305hw58ra46
cmpyo8lem0009l704y7y0c8d0	QR	40.00	0.00	\N	2026-06-03 23:02:10.271	cmpyo8l420001l7047zs7wc5q
cmpyos7zm000il7045cn2lj55	QR	175.00	0.00	\N	2026-06-03 23:17:26.002	cmpyos7o4000bl704y8zsr9oh
cmpypdxyt000rl7046j6xgerv	QR	40.00	0.00	\N	2026-06-03 23:34:19.446	cmpypdxlc000kl704e97b6jei
cmpypoapp0008jp04n2imi8nt	QR	35.00	0.00	\N	2026-06-03 23:42:22.525	cmpypoacr0001jp04t0pvmpi1
cmpypw9fr0011l704gc0gfc0o	QR	80.00	0.00	\N	2026-06-03 23:48:34.119	cmpypw91f000tl704gdmnje6v
cmpyqb4ry001al704ocskee3b	QR	40.00	0.00	\N	2026-06-04 00:00:07.918	cmpyqb4gh0013l704wwxhlkqm
cmpyqtxt0000ljp04do63kbex	QR	80.00	0.00	\N	2026-06-04 00:14:45.348	cmpyqtxgz000bjp043qd3fs2w
cmpyqzlrj001il704lv0ksos8	QR	40.00	0.00	\N	2026-06-04 00:19:09.679	cmpyqzle8001cl704f58q896q
cmpyr4mch000tjp04lh6gccyd	QR	40.00	0.00	\N	2026-06-04 00:23:03.713	cmpyr4lyz000njp04kl5c34rf
cmpyrbev8001rl7047rxbxp8f	QR	40.00	0.00	\N	2026-06-04 00:28:20.612	cmpyrbegh001kl7043gsxxdbo
cmpyrcc2t0020l704rowk90n1	QR	40.00	0.00	\N	2026-06-04 00:29:03.653	cmpyrcbrw001tl704mobwy8li
cmpyrgy7d0012jp04r8hehh1w	CASH	40.00	0.00	\N	2026-06-04 00:32:38.954	cmpyrgxvn000vjp04i8fcma6t
cmpyrlxzj001bjp04yemp9twy	QR	35.00	0.00	\N	2026-06-04 00:36:31.951	cmpyrlxmq0014jp04zv6o6vyo
cmpyrsa4c001jjp04t7qwq3c1	QR	40.00	0.00	\N	2026-06-04 00:41:27.613	cmpyrs9ta001djp048hjxvets
cmpyrwceg0028l704a0jdb3zv	QR	40.00	0.00	\N	2026-06-04 00:44:37.193	cmpyrwc2j0022l704v5dgi4oj
cmpyrwtpy002hl7048nglo2kq	QR	35.00	0.00	\N	2026-06-04 00:44:59.638	cmpyrwtfj002al704z6n4zdkd
cmpyryd32002ul704p930809h	QR	70.00	0.00	\N	2026-06-04 00:46:11.391	cmpyrycrc002jl704kz47w8tu
cmpys03fw001sjp04ib5agbhb	QR	35.00	0.00	\N	2026-06-04 00:47:32.204	cmpys032k001ljp04k6gxtkvp
cmpys7ib50020jp04pkkf0lb1	CASH	40.00	0.00	\N	2026-06-04 00:53:18.066	cmpys7hzy001ujp0408t8disi
cmpysbd4q0028jp04xu6xuf9f	QR	30.00	0.00	\N	2026-06-04 00:56:17.979	cmpysbcsg0022jp04s2ddn7ae
cmpysnmy8002gjp04yo43xhya	QR	35.00	0.00	\N	2026-06-04 01:05:50.577	cmpysnmna002ajp04yccow010
cmpz5e5lt0008jl04bpjtef0c	CASH	40.00	0.00	\N	2026-06-04 07:02:23.202	cmpz5e57o0001jl04ndjnr903
cmpzphfcf000h3xomudb49cvq	QR	40.00	0.00	\N	2026-06-04 16:24:48.111	cmpzpakgw000b3xomrs2wflil
cmpzplw94000t3xomadbkrqp6	QR	75.00	0.00	\N	2026-06-04 16:28:16.649	cmpzpklg2000j3xom2mmu1dqy
cmq01tb4k000gjl044qlpwv66	QR	160.00	0.00	\N	2026-06-04 22:09:57.908	cmq01tb4k0000jl04nnio0hsl
cmq033frk0006jr04b8c6nyaz	QR	35.00	0.00	\N	2026-06-04 22:45:50.097	cmq033frk0000jr047ttf5sut
cmq038s7a0003jm047am94rze	QR	45.00	0.00	\N	2026-06-04 22:49:59.494	cmq038s7a0000jm04iq6s93xw
cmq03wruo000jjs04v65wdzys	QR	120.00	0.00	\N	2026-06-04 23:08:38.784	cmq03wruo0007js04bw9vmhxi
cmq051zjj0008ju042d6zkm3k	QR	35.00	0.00	\N	2026-06-04 23:40:41.647	cmq04h8b70001ju04pccgl4gt
cmq05pufw000kl7049b2r0uzr	THAI_HELP	70.00	0.00	\N	2026-06-04 23:59:14.78	cmq05ihph0009l704llnb4lzg
cmq05ziiy0001lb04fyk8ji14	THAI_HELP	40.00	0.00	\N	2026-06-05 00:06:45.898	cmq03mjdo0001js046gquc8s7
cmq0607ve0008lb047znxlpph	QR	40.00	0.00	\N	2026-06-05 00:07:18.746	cmq0607ve0002lb04kfq5p2wx
cmq060vmi000clb04crqysuu4	QR	250.00	0.00	\N	2026-06-05 00:07:49.531	cmpzn18t00002l804go4cusjg
cmq061ac8000glb04iia2z0d3	QR	40.00	0.00	\N	2026-06-05 00:08:08.6	cmq03iklh0009jm04pktdyhzg
cmq067sua000plb04ji7mb93e	CASH	35.00	0.00	\N	2026-06-05 00:13:12.515	cmq067dfz000ilb04tgxt3io3
cmq06dbpa0001jv041m707t7k	THAI_HELP	75.00	0.00	\N	2026-06-05 00:17:30.238	cmq05anbr0001l704v6czg26f
cmq06hfr20008jo04i12dc2t4	THAI_HELP	35.00	0.00	\N	2026-06-05 00:20:42.111	cmq06gy610001jo04h607cspg
cmq06j1nc000ajo04wr2zvfjq	THAI_HELP	75.00	0.00	\N	2026-06-05 00:21:57.144	cmq05vhyr000ml704lqvmx7bk
cmq06md7m000kjo044xvvija9	CASH	35.00	0.00	\N	2026-06-05 00:24:32.098	cmq06lryv000cjo04e58gsuuf
cmq06vtv40005jr054krs9n7u	QR	40.00	0.00	\N	2026-06-05 00:31:53.584	cmq06vtv40000jr05g818s0kz
cmq07b47r000sjr059bvb2sgd	QR	75.00	0.00	\N	2026-06-05 00:43:46.84	cmq06nwi5000mjo04ikgif5bj
cmq07bcnd000ujr05ghcy6nq1	QR	40.00	0.00	\N	2026-06-05 00:43:57.77	cmq06rx27000xjo047rfbe81p
cmq07brum001ajo04h8b8phum	QR	35.00	0.00	\N	2026-06-05 00:44:17.47	cmq07bqty0013jo04g8slvrk2
cmq07cawi001cjo04dofuilmx	THAI_HELP	35.00	0.00	\N	2026-06-05 00:44:42.162	cmq073zum0009jr05vxdzhzv5
cmq07g4gp001mjo04z3s6iy9j	CASH	35.00	0.00	\N	2026-06-05 00:47:40.441	cmq07g3zc001ejo04te5eo8ju
cmq07k7s9001vjo04za4ot7g8	QR	35.00	0.00	\N	2026-06-05 00:50:51.369	cmq07k7dh001ojo0465kqkk6i
cmq07rmqt0025jo048xrl65xu	THAI_HELP	40.00	0.00	\N	2026-06-05 00:56:37.35	cmq07r6oe001zjo042d28rh4p
cmq07wiy7000wjr05q7vcwjh6	CASH	1.00	1.00	\N	2026-06-05 01:00:25.711	cmq07r4bk001xjo04mzf783ak
cmq07x6w9002ejo04aeikls9a	QR	35.00	0.00	\N	2026-06-05 01:00:56.745	cmq07x6jn0027jo04lt807js4
cmq0ba4oy0008jr04j937g1wl	QR	35.00	0.00	\N	2026-06-05 02:34:59.267	cmq0ba49w0001jr04jq89n3d4
cmq0baixj0005jy042oe3jb2l	CASH	40.00	0.00	\N	2026-06-05 02:35:17.72	cmq0bailt0001jy04hajcs2nw
cmq0by3dr0008jl04byq1d02h	QR	70.00	0.00	\N	2026-06-05 02:53:37.312	cmq0by3100001jl04ifb8prdv
cmq0d7r1g000cju04rbm88asx	CASH	100.00	30.00	\N	2026-06-05 03:29:07.493	cmq0d7qmy0001ju04pjqyfrj3
cmq0h6sb90005l7047pjqe9u7	QR	40.00	0.00	\N	2026-06-05 05:20:20.949	cmq0h2ywf0001l704pg7taii4
cmq0ha40d0008ie04teoubw3i	QR	35.00	0.00	\N	2026-06-05 05:22:56.077	cmq0ha3nc0001ie04mwbcjwgr
cmq0he9wp000hie04xg60gubx	QR	35.00	0.00	\N	2026-06-05 05:26:10.345	cmq0hb97i000aie04sfghxxh7
cmq0if6110009jp04n2pmwtgd	QR	80.00	0.00	\N	2026-06-05 05:54:51.59	cmq0htz850001i304o34f88yg
cmq0if9yo000bjp04gegjl4ct	QR	40.00	0.00	\N	2026-06-05 05:54:56.688	cmq0i1ep70001jp04elz0ssov
cmq0igifq000kjp04l5gubgev	QR	35.00	0.00	\N	2026-06-05 05:55:54.326	cmq0igi48000djp04rdw0zwcc
cmq0jchz20008lg04qwh68cex	CASH	35.00	0.00	\N	2026-06-05 06:20:46.719	cmq0jchhy0001lg0410mvw1dc
cmq114w10000bjm04krbvedxv	QR	105.00	0.00	\N	2026-06-05 14:38:44.772	cmq114w0z0000jm041r0x2r0z
cmq1hwe64000akv040ysc7dns	QR	80.00	0.00	\N	2026-06-05 22:28:01.852	cmq1hwe630000kv04klzp66w9
cmq1irpg10005js04wf421mb5	QR	40.00	0.00	\N	2026-06-05 22:52:22.801	cmq1irpg10000js04s9dnm156
cmq1j9ert000tld0468x9iwq0	QR	40.00	0.00	\N	2026-06-05 23:06:08.777	cmq1j9ers000mld04kspv7ko2
cmq1jnwq40005le04zhs4dtcp	QR	40.00	0.00	\N	2026-06-05 23:17:25.228	cmq1jnwq30000le04w68is4ju
cmq1jso1p0007l4044y4n5w3i	QR	40.00	0.00	\N	2026-06-05 23:21:07.262	cmq1jso1p0000l4047yyu3xai
cmq1kht9f000ml404i4txj5jc	QR	80.00	0.00	\N	2026-06-05 23:40:40.419	cmq1kht9f000cl4043ymardtx
cmq1l89cb0001l504ed8789vn	THAI_HELP	40.00	0.00	\N	2026-06-06 00:01:14.315	cmq1j9uqy000xld04w80mmdcz
cmq1l9kuw0017l404x0u0zn9q	THAI_HELP	35.00	0.00	\N	2026-06-06 00:02:15.896	cmq1j8ao00009ld04wcuv55yt
cmq1lby9g0019l404xvzeataw	THAI_HELP	40.00	0.00	\N	2026-06-06 00:04:06.581	cmq1j8vfb000gld0449sxklto
cmq1leahb0008l204mheh8pis	CASH	35.00	0.00	\N	2026-06-06 00:05:55.727	cmq1lea470001l204i4ox1gsn
cmq1lq32z001il404ypgzs481	QR	35.00	0.00	\N	2026-06-06 00:15:06.011	cmq1lq2qo001bl404bl5pkfn4
cmq1lus3q001ol404t31vj8ok	QR	40.00	0.00	\N	2026-06-06 00:18:45.062	cmq1j7ldf0001ld0482lb9ucg
cmq1lveq9001ul40457r7m93q	QR	75.00	0.00	\N	2026-06-06 00:19:14.386	cmq1kl0fw000ql404r76egg3h
cmq1lw0cl000hl204s7xglknp	QR	40.00	0.00	\N	2026-06-06 00:19:42.405	cmq1lvzx5000al2048bv968a6
cmq1m4314000xl2042965og8g	THAI_HELP	115.00	0.00	\N	2026-06-06 00:25:59.128	cmq1m42o4000jl204j4s39q5s
cmq1mn371001gl204193edqrv	QR	40.00	0.00	\N	2026-06-06 00:40:45.805	cmq1mn2u8001al204x09owya7
cmq1mnzct0023l4041sbx6xus	CASH	40.00	0.00	\N	2026-06-06 00:41:27.486	cmq1misa5000zl2040ytnni9b
cmq1mpf8s002el404ny6tg2b7	QR	75.00	0.00	\N	2026-06-06 00:42:34.732	cmq1mpf8r0024l404a7y95h31
cmq1mv3d10020l204whysfr5c	QR	35.00	0.00	\N	2026-06-06 00:46:59.27	cmq1mv31j001tl204cjjqo7x9
cmq1mxu37002kl404jf8gg2ge	QR	35.00	0.00	\N	2026-06-06 00:49:07.219	cmq1kyktk0010l40474k7ctj8
cmq1mxzr6002ml404y463d22p	THAI_HELP	35.00	0.00	\N	2026-06-06 00:49:14.562	cmq1m59t8001wl404cp5rvrv4
cmq1my6ab002ol404pw7tsea2	CASH	40.00	0.00	\N	2026-06-06 00:49:23.028	cmq1mj2du0016l2045jfr7hzq
cmq1n3jrd0001jo04xc8g1at3	CASH	70.00	0.00	\N	2026-06-06 00:53:33.77	cmq1mui5y001il204llon795b
cmq1n4men000bjo048d1pur3q	QR	40.00	0.00	\N	2026-06-06 00:54:23.855	cmq1n4m220003jo04vsbqigyr
cmq1n86mb0009jq04hgdacf5l	QR	40.00	0.00	\N	2026-06-06 00:57:10.02	cmq1n86930001jq043dalfd09
cmq1nifbo000fjo04zuytcmq1	QR	40.00	0.00	\N	2026-06-06 01:05:07.86	cmq1n0lod0022l2049b7xbprz
cmq1nwp67000djo04j80xfivz	QR	115.00	0.00	\N	2026-06-06 01:16:13.807	cmq1nwp660000jo04uxfhdmgv
cmq3wyg4l000jl204o8go78p3	CASH	40.00	0.00	\N	2026-06-07 15:05:04.293	cmq3wyfme000dl204cw9ubkay
cmq3x00o20007kz04hlcdsj3p	CASH	40.00	0.00	\N	2026-06-07 15:06:17.571	cmq3wznuq0001kz04nurdd92v
cmq3yqbr70005jl04f56bdlpw	QR	40.00	0.00	\N	2026-06-07 15:54:44.612	cmq3yqbr70000jl04h71kd5ar
cmq3yvmtu000bl704fo8z8hh2	QR	40.00	0.00	\N	2026-06-07 15:58:52.242	cmq3yvmtt0006l7040e6z8zvt
cmq4c2r220007jr047r80putw	QR	70.00	0.00	\N	2026-06-07 22:08:19.322	cmq4c2r220000jr04to75lb55
cmq4c5k7f0007lh04tkzxv65p	QR	35.00	0.00	\N	2026-06-07 22:10:30.411	cmq4c5k7f0000lh04ajcehru4
cmq4cnb2x000bk004b3oay28p	QR	70.00	0.00	\N	2026-06-07 22:24:18.393	cmq4cnb2x0000k004gb57z98x
cmq4dqdjc0001jp04dbzco12c	CASH	75.00	0.00	\N	2026-06-07 22:54:41.161	cmq3wooeu0001l804kuzr342f
cmq4drmpv0009jp04pej0oyuf	CASH	40.00	0.00	\N	2026-06-07 22:55:39.716	cmq3yelhs0001ky04x9894lxr
cmq4dsbc9000djp04gs0vdl4i	CASH	35.00	0.00	\N	2026-06-07 22:56:11.626	cmq3wpg2n0001l204du6dqifh
cmq4dsmpb000fjp04xrrxnbh4	CASH	35.00	0.00	\N	2026-06-07 22:56:26.351	cmq3x337z0009kz04qtt5vqh5
cmq4dswi50001jy04vlzp23h9	CASH	40.00	0.00	\N	2026-06-07 22:56:39.053	cmq3wy7o10007l2041cmko7n2
cmq4dt8fp0003jy04frqotv5m	CASH	40.00	0.00	\N	2026-06-07 22:56:54.517	cmq3xp7o0000ll2044708f1tg
cmq4dtggj0005jy042e8yrfhi	CASH	40.00	0.00	\N	2026-06-07 22:57:04.916	cmq3yf3qi0001l7048ncz3zgv
cmq4dxpsc0007js0400mwoqo0	QR	35.00	0.00	\N	2026-06-07 23:00:23.628	cmq4dxpsb0000js046idgljfp
cmq4e0y6y000ijr04qbwpl4cz	QR	115.00	0.00	\N	2026-06-07 23:02:54.49	cmq4e0y6y0002jr0467ohj7al
cmq4fo7vl000bl804kp22kixp	THAI_HELP	75.00	0.00	\N	2026-06-07 23:48:59.745	cmq4fo7i90001l8044c2puwxv
cmq4fw26u000gl104t2i7k14w	THAI_HELP	75.00	0.00	\N	2026-06-07 23:55:05.623	cmq4fw1q50005l104068el22r
cmq4fy9i3000kl804dhcnwxbl	QR	55.00	0.00	\N	2026-06-07 23:56:48.411	cmq4fy94z000dl804mlz2mjya
cmq4fzln3000sl804pfgtkos4	QR	35.00	0.00	\N	2026-06-07 23:57:50.799	cmq4fzln2000ll804nx62g2xm
cmq4gap240001jr040y64vq9j	THAI_HELP	40.00	0.00	\N	2026-06-08 00:06:28.445	cmq4dqtc40003jp04g9zzivy3
cmq4gbo6z0007l804yp80sc20	THAI_HELP	35.00	0.00	\N	2026-06-08 00:07:13.98	cmq4gbnu10001l804r9xduqb6
cmq4gf3ua000fl804d6of9eke	QR	35.00	0.00	\N	2026-06-08 00:09:54.226	cmq4gf3u90008l804xk3zzlrl
cmq4ghu1r000pl804zmz8d9rt	CASH	35.00	0.00	\N	2026-06-08 00:12:01.504	cmq4ghtop000jl804muis7cqj
cmq4gozwl0003jr048oehn4oi	THAI_HELP	40.00	0.00	\N	2026-06-08 00:17:35.686	cmq4e00xp0001jr04f35am9hd
cmq4gq5t5000bjr04y3dar6jt	QR	40.00	0.00	\N	2026-06-08 00:18:29.993	cmq4edy7y0009jy04i0t03bky
cmq4gxoah000ojr0442qzfjbu	THAI_HELP	35.00	0.00	\N	2026-06-08 00:24:20.538	cmq4gxnwk000hjr04o12yoq3c
cmq4hih8t001ajr04fzk30y71	QR	35.00	0.00	\N	2026-06-08 00:40:31.181	cmq4higvo0014jr04o4iqz9ly
cmq4hkcvb001mjr040f81mgcb	THAI_HELP	75.00	0.00	\N	2026-06-08 00:41:58.823	cmq4hkci6001cjr04f2h1z5bm
cmq4hl01k000njm045yy0sc6v	QR	40.00	0.00	\N	2026-06-08 00:42:28.856	cmq4hkzmq000hjm04614meh8y
cmq4hphz0001ojr04fzbiwcv9	QR	70.00	0.00	\N	2026-06-08 00:45:58.717	cmq4h76r40001jm04oo5oc8e8
cmq4hpkgt001qjr04v3996uup	CASH	35.00	0.00	\N	2026-06-08 00:46:01.949	cmq4h8bqd000qjr04ew4yaae6
cmq4hprrs001sjr04hy4xqpvp	THAI_HELP	40.00	0.00	\N	2026-06-08 00:46:11.416	cmq4hafzg000bjm04jajidhn8
cmq4hsil7001ujr04u6izk7z6	QR	35.00	0.00	\N	2026-06-08 00:48:19.484	cmq4h8s2l000xjr04g1of1a1o
cmq4hzzo10010jm04l1u4aj9m	THAI_HELP	75.00	0.00	\N	2026-06-08 00:54:08.21	cmq4hsyic000pjm04dm1d7iit
cmq4ice6c0008ju046u0419fe	QR	40.00	0.00	\N	2026-06-08 01:03:46.884	cmq4icdtm0001ju0434ur99pq
cmq4l2gxq0007ju04ide8px35	CASH	100.00	60.00	\N	2026-06-08 02:20:02.751	cmq4kw2vb0001ju04vlhvrfda
cmq4le9c90007kz04hn5l6yf4	QR	35.00	0.00	\N	2026-06-08 02:29:12.778	cmq4le8uj0001kz04j4b5prfc
cmq4m12fk0008lh04ger9hmxi	THAI_HELP	70.00	0.00	\N	2026-06-08 02:46:56.912	cmq4ltlyo0001lh04zrbmpbvc
cmq4mw2050008l204ol5d303q	QR	35.00	0.00	\N	2026-06-08 03:11:02.694	cmq4mqvuc0001l204btmo78mb
cmq4qavpy0008ju0466nwpwxw	THAI_HELP	40.00	0.00	\N	2026-06-08 04:46:33.238	cmq4qav2q0001ju04oo3ddg46
cmq4qzhjq000djs04bivsang1	CASH	75.00	0.00	\N	2026-06-08 05:05:41.271	cmq4qqx4z0001jy04971t6ffv
cmq4r8wfn000fjs04ck0o7xsz	THAI_HELP	80.00	0.00	\N	2026-06-08 05:13:00.468	cmq4qrh3i000cjy04rkdrszaa
cmq4rhdxd0005jp04bnuwtxsz	CASH	15.00	0.00	\N	2026-06-08 05:19:36.386	cmq4rhdk50001jp04ti7p9qtu
cmq4rujvl0007ju04lmg8hzug	THAI_HELP	40.00	0.00	\N	2026-06-08 05:29:50.626	cmq4ruj2g0001ju04vpivgkfz
cmq4rwqkr0009ju04urzk50fp	QR	35.00	0.00	\N	2026-06-08 05:31:32.619	cmq4qvttb0001js04s9aqx1c0
cmq4rwvh6000bju04tvodceqc	QR	35.00	0.00	\N	2026-06-08 05:31:38.97	cmq4qwk6s0007js04xliroekn
cmq4sbzqu0001js04i2c7fvh9	QR	40.00	0.00	\N	2026-06-08 05:43:24.342	cmq4ri5820001l204oupvmwdh
cmq4szpzb0008jl04w291sxgc	QR	35.00	0.00	\N	2026-06-08 06:01:51.431	cmq4szpi50001jl04lyf1l0by
cmq5s9aof000bju04d8gap8ua	QR	70.00	0.00	\N	2026-06-08 22:29:04.719	cmq5s9aoe0000ju04scxlmgnf
cmq5t5rru000al5040djmvu4h	QR	105.00	0.00	\N	2026-06-08 22:54:19.866	cmq5t5rru0000l5042bio6uw7
cmq5tg4i2000kl504zemvnbu0	QR	35.00	0.00	\N	2026-06-08 23:02:22.922	cmq5tg4i1000dl5049cs206m7
cmq5tkrk30006jm04dkdbupqx	QR	70.00	0.00	\N	2026-06-08 23:05:59.427	cmq5tkrk30000jm04v7eptx56
cmq5tq5lu000dl804u0aemx56	QR	115.00	0.00	\N	2026-06-08 23:10:10.914	cmq5tq5lt0000l804kevidzil
cmq5uph80000ekz04s7l395u3	QR	75.00	0.00	\N	2026-06-08 23:37:38.928	cmq5uph800002kz04l96olp0d
cmq5utfue000bks0472y785le	THAI_HELP	80.00	0.00	\N	2026-06-08 23:40:43.767	cmq5utffz0001ks04exp6ucot
cmq5vfhdn0006le04lir7syyq	QR	35.00	0.00	\N	2026-06-08 23:57:52.187	cmq5vfhdn0000le04nau7i8rb
cmq5vfvw6000hle048yqoitp2	THAI_HELP	35.00	0.00	\N	2026-06-08 23:58:10.999	cmq5vfvir000ale048otfzs36
cmq5vh6uz0009jm04d0obrugs	QR	80.00	0.00	\N	2026-06-08 23:59:11.867	cmq5vh6uy0000jm0420zqs4qq
cmq5vk5sq000kjm04wm3vx36i	THAI_HELP	35.00	0.00	\N	2026-06-09 00:01:30.459	cmq5vk5gz000djm04olj3rzqp
cmq5vo6130007jr04f6ficti7	QR	40.00	0.00	\N	2026-06-09 00:04:37.383	cmq5vo5no0001jr04zvj1gkgc
cmq5vsaeh0008kv04vy66iija	THAI_HELP	35.00	0.00	\N	2026-06-09 00:07:49.673	cmq5vs9zv0001kv042knvlzqz
cmq5vzgya000hkv04slw77axl	THAI_HELP	35.00	0.00	\N	2026-06-09 00:13:24.754	cmq5vzgks000akv04rurmz5c8
cmq5w4g3i0007l8047mpgkka2	THAI_HELP	40.00	0.00	\N	2026-06-09 00:17:16.926	cmq5tjcm10001jr04vqmxbfqh
cmq5wlgey000ijy04ve473akr	THAI_HELP	115.00	0.00	\N	2026-06-09 00:30:30.49	cmq5wlg1i0002jy04yvyhdr45
cmq5wp4zc000il804la3p0mxe	THAI_HELP	35.00	0.00	\N	2026-06-09 00:33:22.297	cmq5wp4nu000bl804wnl9yh39
cmq5wsx7v000rl804t6xk6rzx	THAI_HELP	35.00	0.00	\N	2026-06-09 00:36:18.859	cmq5wswte000kl80438byq14d
cmq5x074p0011jy04fpkvx2yq	CASH	35.00	0.00	\N	2026-06-09 00:41:58.298	cmq5x06rn000vjy0446row018
cmq5x4cvk000zl804r4lugck8	THAI_HELP	75.00	0.00	\N	2026-06-09 00:45:12.369	cmq5wnwgd000kjy04a6rzb1ug
cmq5x9h0x000fjo04r5kdi05x	THAI_HELP	35.00	0.00	\N	2026-06-09 00:49:11.025	cmq5x9gq00008jo048nn42gga
cmq5xg3y8001ajy04aa5no7f9	THAI_HELP	35.00	0.00	\N	2026-06-09 00:54:20.673	cmq5x8ymb0001jo04ogbf5o5l
cmq5xg9gl001cjy04bqtrqzgj	THAI_HELP	40.00	0.00	\N	2026-06-09 00:54:27.814	cmq5x7s000013jy04wp6i0z7g
cmq5xnref001kjy04ix3zupq4	QR	30.00	0.00	\N	2026-06-09 01:00:17.656	cmq5xnr2n001ejy04lmlsjpn7
cmq5zubun0008ld04r5f1eyn0	THAI_HELP	40.00	0.00	\N	2026-06-09 02:01:23.328	cmq5zubfg0001ld04q02sryj9
cmq5zwqep0008l404kafztpuv	THAI_HELP	40.00	0.00	\N	2026-06-09 02:03:15.505	cmq5zwq1u0001l4046acqex6c
cmq603qqa000gl404mphv5svz	THAI_HELP	40.00	0.00	\N	2026-06-09 02:08:42.514	cmq5zyjnd000al404ywy1lt9w
cmq60oauh0008jl04e33hpscj	QR	40.00	0.00	\N	2026-06-09 02:24:41.705	cmq60oagn0001jl04n10m83xh
cmq60ukqk000fjp047jzhcesh	THAI_HELP	115.00	0.00	\N	2026-06-09 02:29:34.46	cmq60ukbb0001jp040a2njvi2
cmq618ifq000hjp04laxp49b9	THAI_HELP	75.00	0.00	\N	2026-06-09 02:40:24.663	cmq610y3r0001js04tu34r85g
cmq618z3o0008jv04r8g1ywgi	CASH	35.00	0.00	\N	2026-06-09 02:40:46.261	cmq618yr40001jv04f6hefwyp
cmq61czrt000pjv04wwtljo1w	THAI_HELP	110.00	0.00	\N	2026-06-09 02:43:53.753	cmq61cze5000ajv04bwsz3vgl
cmq61vrog000rjv043ff1oggg	THAI_HELP	120.00	0.00	\N	2026-06-09 02:58:29.728	cmq61kwhi000jjp04savbjmxm
cmq62bnio000bl704c7sx2tl8	THAI_HELP	80.00	0.00	\N	2026-06-09 03:10:50.833	cmq62bn1c0001l704jul62js8
cmq62hlko0008ji04c5mvah5d	THAI_HELP	35.00	0.00	\N	2026-06-09 03:15:28.249	cmq62drkr0001ji041l91k2p8
cmq63m0a2000el404a81lp751	CASH	35.00	0.00	\N	2026-06-09 03:46:53.547	cmq63eera0001l404hii1ktqi
cmq63m58m000gl404yfufakj6	QR	35.00	0.00	\N	2026-06-09 03:46:59.975	cmq63em2m0008l4045ifhngap
cmq67fz13000ck004jlr3dacs	QR	145.00	0.00	\N	2026-06-09 05:34:10.455	cmq67fyce0001k004zyndmnxk
cmq77yrth000eju041qaahp76	QR	110.00	0.00	\N	2026-06-09 22:36:33.749	cmq77yrtg0000ju04tahgagvy
cmq79aljt0007jp04a7flks44	THAI_HELP	35.00	0.00	\N	2026-06-09 23:13:45.113	cmq78wz8v0001l504of56r07u
cmq79apuv0009jp04ucvg70iu	QR	40.00	0.00	\N	2026-06-09 23:13:50.696	cmq78x7iv0008l5044n7pamfj
cmq79awab000bjp040ar9g5sh	THAI_HELP	35.00	0.00	\N	2026-06-09 23:13:59.028	cmq78xijx000fl504gy8sg7lf
cmq79bdb6000djp043gm10ez0	QR	50.00	0.00	\N	2026-06-09 23:14:21.09	cmq78xvav000ml5044mi07d75
cmq7a4ak40009jv04c28b1dw6	QR	75.00	0.00	\N	2026-06-09 23:36:50.548	cmq7a4ak30000jv04bxzlkgs2
cmq7a7doh0008l204m9v9msmz	THAI_HELP	35.00	0.00	\N	2026-06-09 23:39:14.562	cmq7a7d9t0001l204l2kj4957
cmq7asad8000ajx044qzj19q1	QR	40.00	0.00	\N	2026-06-09 23:55:30.044	cmq7asad70004jx04a8njafgl
cmq7ayit00006l504q33kbff0	QR	35.00	0.00	\N	2026-06-10 00:00:20.916	cmq7ayit00000l504ki72wer9
cmq7b7d5i000kjx04qkq15r5c	CASH	40.00	0.00	\N	2026-06-10 00:07:13.495	cmq7b7csl000ejx04lnfihuwh
cmq7bcr6l000al40494b9l9rq	QR	40.00	0.00	\N	2026-06-10 00:11:24.958	cmq7bcr6l0004l4046p8u67e1
cmq7be2a3000el404oy6mvhdd	THAI_HELP	35.00	0.00	\N	2026-06-10 00:12:25.996	cmq7b9zbk000al504o0id4j6t
cmq7beidc000gl404hol4dq9c	QR	40.00	0.00	\N	2026-06-10 00:12:46.848	cmq7bagqh000hl5047ml1sw8i
cmq7bf8dh000il404c4oa1jef	CASH	40.00	0.00	\N	2026-06-10 00:13:20.55	cmq78vwei0001js04n826opn2
cmq7bhulq000vl504r1eleuiq	THAI_HELP	35.00	0.00	\N	2026-06-10 00:15:22.671	cmq7bhu83000ol5047kuqj32x
cmq7bokwk0015l5049vfsgwlg	QR	45.00	0.00	\N	2026-06-10 00:20:36.692	cmq7bokil000zl504zhgbtz8c
cmq7c3s6a000sjx041g9csbrl	THAI_HELP	40.00	0.00	\N	2026-06-10 00:32:25.954	cmq7c3rsp000mjx04hv5wi089
cmq7c4ra6001ll50445768hos	THAI_HELP	35.00	0.00	\N	2026-06-10 00:33:11.455	cmq7c4qve001el504quna1zfp
cmq7c6l7r0021l504qwihff4s	THAI_HELP	115.00	0.00	\N	2026-06-10 00:34:36.904	cmq7c6ksj001nl504w7mewddo
cmq7ceuyp0017jx04fyq5uuxk	THAI_HELP	40.00	0.00	\N	2026-06-10 00:41:02.786	cmq7ceuj00011jx04fb5vqojj
cmq7cppck002fl504iy67x8ln	THAI_HELP	35.00	0.00	\N	2026-06-10 00:49:28.725	cmq7cpoul0029l504cspijlew
cmq7cqf07002hl504ih884f0g	QR	40.00	0.00	\N	2026-06-10 00:50:01.975	cmq793pjd0001jp04levxg68p
cmq7cqqfg002jl504b9ksoep5	THAI_HELP	40.00	0.00	\N	2026-06-10 00:50:16.78	cmq7cb7aq000ujx04vwpsbm06
cmq7cslh1001kjx04z5943mlg	QR	75.00	0.00	\N	2026-06-10 00:51:43.67	cmq7csl4l0019jx044amxrush
cmq7ctuao001mjx04k8gjplxy	QR	35.00	0.00	\N	2026-06-10 00:52:41.76	cmq7bve060017l504zo89izjv
cmq7cy4u2002sl504p1vruwmh	THAI_HELP	40.00	0.00	\N	2026-06-10 00:56:02.042	cmq7cy4hd002ll504gkgj43x7
cmq7d0ani002ul504xmwcpz0y	QR	35.00	0.00	จ่ายที่มิ้น	2026-06-10 00:57:42.895	cmq7cg2d50023l504ap9eyhtw
cmq7f4szj000bl504ua8lg88q	THAI_HELP	75.00	0.00	\N	2026-06-10 01:57:12.512	cmq7f4sgv0001l504ta16mwbs
cmq7faosx000bi904kllwmiw3	QR	80.00	0.00	\N	2026-06-10 02:01:47.025	cmq7faodz0001i904csl3bg2w
cmq7gigd30008l404tf75wql1	THAI_HELP	35.00	0.00	\N	2026-06-10 02:35:48.951	cmq7gifyr0001l404dwdralsk
cmq7gisr1000hl404tal5asak	CASH	50.00	15.00	\N	2026-06-10 02:36:05.005	cmq7gisgv000al404qfkmrjx3
cmq7h2wzg0008lb045t1r8r4k	THAI_HELP	35.00	0.00	\N	2026-06-10 02:51:43.613	cmq7h2whm0001lb04t5dtediw
cmq7h34ac000alb041gw8l33y	CASH	75.00	0.00	\N	2026-06-10 02:51:53.077	cmq7gx6lk000jl4046rd8gzaw
cmq7h8y0e000jlb04urxa669a	THAI_HELP	35.00	0.00	\N	2026-06-10 02:56:24.879	cmq7h8xl7000clb046p73sm3v
cmq7hgfzz000gk004blig1yh1	QR	155.00	0.00	\N	2026-06-10 03:02:14.783	cmq7hgfzy0000k00428coxwvj
cmq7hhnr9000kk004m656pxup	CASH	75.00	0.00	\N	2026-06-10 03:03:11.494	cmq7gxwrn000tl404ga1qa4j9
cmq7hhwlg000mk004yk0rwchv	CASH	35.00	0.00	\N	2026-06-10 03:03:22.949	cmq7hau7h0014l404wy9fcjc2
cmq7hznm8000cjx04r40gy6ui	THAI_HELP	85.00	0.00	\N	2026-06-10 03:17:11.12	cmq7hzn710001jx04ckv06qyg
cmq7k1x6a0005jv04xarq3hcj	CASH	40.00	10.00	\N	2026-06-10 04:14:56.051	cmq7k1ws10001jv04torizare
cmq7lhq2v0008ie0425nxj8vt	THAI_HELP	40.00	0.00	\N	2026-06-10 04:55:12.968	cmq7lhpbt0001ie04bpctbj88
cmq7lj9eg000aie04a8zligen	CASH	50.00	0.00	\N	2026-06-10 04:56:24.664	cmq7j0f3e00013xjtcb3vgfda
cmq7mbi64000bla04i5p7v6io	THAI_HELP	45.00	0.00	\N	2026-06-10 05:18:22.396	cmq7mb23t0005la04zcuigdic
cmq7mir1f000kla04uruq1z02	CASH	100.00	60.00	\N	2026-06-10 05:24:00.483	cmq7mf1n4000dla04oc09ngst
cmq7na0ed0001l1047miunwmi	THAI_HELP	75.00	0.00	\N	2026-06-10 05:45:12.325	cmq7mjt2a0001jr04lxq5g0sk
cmq7na4iq0003l104prttt674	THAI_HELP	40.00	0.00	\N	2026-06-10 05:45:17.666	cmq7mkear000cjr043vwpfrm7
cmq7na8gq0005l10420p0irdz	THAI_HELP	70.00	0.00	\N	2026-06-10 05:45:22.778	cmq7msmeq0001jy04wvfdb2jd
cmq7nrxs5000al1046i5ip6es	QR	75.00	0.00	\N	2026-06-10 05:59:08.741	cmq7nrx8e0001l104ydbdftuo
cmq7nsxfc000cl504n5hllgv5	QR	70.00	0.00	\N	2026-06-10 05:59:54.937	cmq7nsx2l0001l504kejmwuq9
cmq7ntbso000ll5044j7jiiuy	QR	35.00	0.00	\N	2026-06-10 06:00:13.561	cmq7ntbex000el504b7x1w3xu
cmq7oc67e000tl504yj74zaqa	THAI_HELP	70.00	0.00	\N	2026-06-10 06:14:52.779	cmq7nxaav000cl104dtxiupwb
cmq7ohvyr000vl5044ycx7ghz	THAI_HELP	60.00	0.00	\N	2026-06-10 06:19:19.444	cmq7o16oh000nl504n8fzjyqn
cmq8nljlq000ok504vz3swhet	QR	215.00	0.00	\N	2026-06-10 22:41:56.605	cmq8nljlp0000k504ybgamm2p
cmq8okvww000kjv04y48cs9pb	QR	180.00	0.00	\N	2026-06-10 23:09:25.52	cmq8okvwv0000jv04zuzsd30a
cmq8ovw370008k304w15tv4n7	QR	50.00	0.00	\N	2026-06-10 23:17:58.963	cmq8ovw360000k3042klqx77h
cmq8pno11000bih04cjh409po	THAI_HELP	75.00	0.00	\N	2026-06-10 23:39:34.885	cmq8pnnoh0001ih04vfrf667z
cmq8prlhk0006js04fptnilje	QR	70.00	0.00	\N	2026-06-10 23:42:38.216	cmq8prlhj0000js04teqhwo8p
cmq8qbbzx0009i8044vfkf4ta	THAI_HELP	50.00	0.00	\N	2026-06-10 23:57:59.038	cmq8qbbiz0001i804b6ytk86t
cmq8qbnil000gi8047c3bwyir	QR	50.00	0.00	\N	2026-06-10 23:58:13.965	cmq8qbnil000ai804jju7b3bw
cmq8qcmwg000ri804zb20bh1o	THAI_HELP	35.00	0.00	\N	2026-06-10 23:58:59.824	cmq8qcmk4000ki804tm3s43hq
cmq8qjifu0008i604wkwnjfev	THAI_HELP	40.00	0.00	\N	2026-06-11 00:04:20.634	cmq8qji0m0001i604ek4v1oc6
cmq8qnyhj000hi604wxhap56s	THAI_HELP	35.00	0.00	\N	2026-06-11 00:07:48.055	cmq8qny5w000ai6043947j4he
cmq8qw6hu000ni6044i2xua66	QR	15.00	0.00	\N	2026-06-11 00:14:11.682	cmq8qw643000ji604v14hsfnl
cmq8r28ci0006jo04r6ke1z98	QR	35.00	0.00	\N	2026-06-11 00:18:54.019	cmq8r28ci0000jo04dib4mjur
cmq8rcz33000ujo049llatq3x	THAI_HELP	35.00	0.00	\N	2026-06-11 00:27:15.231	cmq8rcypz000mjo04f7zb2b33
cmq8rr3mc0014jo04pbxhsezu	THAI_HELP	75.00	0.00	\N	2026-06-11 00:38:14.292	cmq8rbxw4000ajo04dvpwz0gn
cmq8rrhea0016jo04810ediqb	THAI_HELP	40.00	0.00	\N	2026-06-11 00:38:32.146	cmq8rmcgi0003l204t5vw9rqd
cmq8s2v23001bi6044njcr0t1	CASH	50.00	10.00	\N	2026-06-11 00:47:23.068	cmq8rybua0015i604tyb0tc3v
cmq8s3uxc0008l1042ujioc0m	THAI_HELP	70.00	0.00	\N	2026-06-11 00:48:09.553	cmq8s3ukb0001l1048336hs11
cmq8s43u5000al104j3b67ei1	THAI_HELP	35.00	0.00	\N	2026-06-11 00:48:21.102	cmq8rns44000wjo0412zihgag
cmq8s4bju000cl104pxim183r	THAI_HELP	40.00	0.00	\N	2026-06-11 00:48:31.099	cmq8rn7af000ri604030l04to
cmq8s4jay000el104nrg2ff56	THAI_HELP	35.00	0.00	\N	2026-06-11 00:48:41.147	cmq8ry5kv000yi604keu3rl3q
cmq8sbfvs000nl104crk63ovh	THAI_HELP	40.00	0.00	\N	2026-06-11 00:54:03.305	cmq8sbfk2000gl104lyzfkcoa
cmq8skaae0011l104gz87xwsp	QR	45.00	0.00	\N	2026-06-11 01:00:55.959	cmq8sdqca000pl1049qo5sjve
cmq8vlbqz0007js04274osoko	CASH	100.00	70.00	\N	2026-06-11 02:25:43.356	cmq8vjo4w0001js04ql4nlf36
cmq8vup1t000tjx04ti59dxyr	THAI_HELP	40.00	0.00	\N	2026-06-11 02:33:00.497	cmq8vo54e0001jx04ogew8vi3
cmq8w1nbv000ikt042dq8r8jj	THAI_HELP	80.00	0.00	\N	2026-06-11 02:38:24.86	cmq8vojuw0008jx04lx39g917
cmq8w1tvq000kkt04wqzo18t7	QR	35.00	0.00	\N	2026-06-11 02:38:33.35	cmq8voquw000fjx0442s3nl96
cmq8w2tpf000mkt04c13dpp0r	THAI_HELP	35.00	0.00	\N	2026-06-11 02:39:19.78	cmq8vuj1d000mjx04g8t3g0bz
cmq8wctqz000okt04efhtc4y8	THAI_HELP	130.00	0.00	\N	2026-06-11 02:47:06.396	cmq8vzsb60001kt04lfbscle2
cmq8wie2e000bjn041761jt70	THAI_HELP	80.00	0.00	\N	2026-06-11 02:51:26.007	cmq8widpi0001jn04ij5wkjif
cmq8wkga4000njn04t6qgkheo	THAI_HELP	75.00	0.00	\N	2026-06-11 02:53:02.189	cmq8wkfs7000djn04ewp2bq2o
cmq8wtcf4000wjn04tyegir48	THAI_HELP	35.00	0.00	\N	2026-06-11 02:59:57.088	cmq8wtc0v000pjn04lvb0nzgm
cmq8y7t020008l104swhepw9p	THAI_HELP	35.00	0.00	\N	2026-06-11 03:39:11.379	cmq8xx7x70001l104wenrsc6n
cmq8y8txt000ll104s1yqi73e	QR	155.00	0.00	\N	2026-06-11 03:39:59.249	cmq8y8txt0009l104g3kq58gy
cmq92pbj8000mjl04x6iyr125	QR	40.00	0.00	\N	2026-06-11 05:44:47.012	cmq92k7200001jl04dnymjlps
cmq930xrv000ojl04no96abu6	THAI_HELP	115.00	0.00	\N	2026-06-11 05:53:49.052	cmq92lzws0008jl04n2h4ugql
cmq9457gx0001l504j0yd7tsb	THAI_HELP	145.00	0.00	\N	2026-06-11 06:25:07.858	cmq93ntbk0001jy049azdpsb7
cmq95z10k0008jf048890hqd6	QR	40.00	0.00	\N	2026-06-11 07:16:18.788	cmq95z0oq0001jf04djb6mrz9
cmqa7hggh0009ju04x3arnmv8	THAI_HELP	35.00	0.00	\N	2026-06-12 00:46:24.402	cmqa7hftw0002ju04khs7s5dj
cmqa7k8rx0008ic04wr2buu4a	THAI_HELP	35.00	0.00	\N	2026-06-12 00:48:34.413	cmqa7k8bs0001ic04v9ygvtrp
cmqa7n1cs000aic04hv7ptge5	THAI_HELP	35.00	0.00	\N	2026-06-12 00:50:44.764	cmqa7hxla000bju04wq3kip3e
cmqa7w2sx000sju046twpq3hw	THAI_HELP	85.00	0.00	\N	2026-06-12 00:57:46.545	cmqa7o7xd000iju0430igs9dj
cmqa8902s000cla04bu1zcgwg	QR	75.00	0.00	\N	2026-06-12 01:07:49.54	cmqa88zjs0001la04wa3kh58q
cmqa94hms0008i904598gau79	THAI_HELP	35.00	0.00	\N	2026-06-12 01:32:18.628	cmqa94h6c0001i904lt9wwjga
cmqa96c3b0008l804gnjmsduh	THAI_HELP	40.00	0.00	\N	2026-06-12 01:33:44.76	cmqa96bl10001l804va9b3q4r
cmqa9la2q0007la040ixdeffv	THAI_HELP	35.00	0.00	\N	2026-06-12 01:45:21.987	cmqa9l9hl0001la04a6pmhncp
cmqa9s88t000il804y83x7hj4	QR	95.00	0.00	\N	2026-06-12 01:50:46.206	cmqa9s7vd000al8041vwp2yyz
cmqa9zxk7000ql8046yyneebf	QR	50.00	0.00	\N	2026-06-12 01:56:45.607	cmqa9v70q0009la04pmobcmr4
cmqaa9f9c000zla0477djbi6a	QR	55.00	0.00	\N	2026-06-12 02:04:08.448	cmqaa4j24000gla04xzk07cnf
cmqaab7240011la04fct2076s	QR	35.00	0.00	\N	2026-06-12 02:05:31.132	cmqaa5r3f000sl804yp50p1rz
cmqaal73k001dl804bqmunalk	THAI_HELP	115.00	0.00	\N	2026-06-12 02:13:17.745	cmqaa6ttu000zl8041q45llcp
cmqaala4y001fl804tf57blbr	THAI_HELP	40.00	0.00	\N	2026-06-12 02:13:21.682	cmqaa98d2000tla04wc4t4p8z
cmqaaqkka0008ky04yn4lda4o	CASH	40.00	0.00	\N	2026-06-12 02:17:28.475	cmqaan28g0001ky04ffhfqjts
cmqacvo8h000bk0048rjzko6i	THAI_HELP	115.00	0.00	\N	2026-06-12 03:17:25.746	cmqacvntj0001k004mj7x6j09
cmqae1jmy0008l4041bl6y6bl	CASH	80.00	0.00	\N	2026-06-12 03:49:59.339	cmqae0r1z0001l404odmfvjp1
cmqae26s40008l504uwqbpxr8	THAI_HELP	35.00	0.00	\N	2026-06-12 03:50:29.332	cmqae26dv0001l50425g2bpi8
cmqae4shz000hl5041xti4kxv	CASH	40.00	0.00	\N	2026-06-12 03:52:30.791	cmqae4s3p000al5040pbitj8g
cmqaee6f7000gl404z8qgn11e	THAI_HELP	35.00	0.00	\N	2026-06-12 03:59:48.74	cmqaee63v000al404x9r7buaz
cmqaeiilb000pl404zg5o3r3r	QR	40.00	0.00	\N	2026-06-12 04:03:11.135	cmqaehamu000il404helckqir
cmqaffjsy0008l504g55y5gjb	CASH	40.00	0.00	\N	2026-06-12 04:28:52.354	cmqaffjas0001l504xksxb12w
cmqafp3yc0005kt049ei41i5v	CASH	15.00	0.00	\N	2026-06-12 04:36:18.372	cmqafp3gv0001kt04r4sfhpd1
cmqaib4w00008l2046o33xsoh	THAI_HELP	35.00	0.00	\N	2026-06-12 05:49:25.249	cmqaib4eu0001l204jyly2ubl
cmqaicem40008l704stzufzfc	THAI_HELP	40.00	0.00	\N	2026-06-12 05:50:24.508	cmqaice7v0001l704dbrp72ta
cmqairn4j000kib04ewk6sf4x	THAI_HELP	40.00	0.00	\N	2026-06-12 06:02:15.379	cmqair9hn000eib04n5wcyswl
cmqaizsdk0001ky044gh120yo	CASH	40.00	0.00	\N	2026-06-12 06:08:35.432	cmqaipwww0001ib04f1k6jjk6
cmqaizvuy0003ky04ghcfaswm	CASH	40.00	0.00	\N	2026-06-12 06:08:39.946	cmqaiqg540008ib044sa8hid1
cmqajkjdo0001i804t1f624nz	QR	105.00	0.00	\N	2026-06-12 06:24:43.548	cmqaj4e6e0005ky04ggvve583
cmqajkqy7000ai8049ovcmsj5	QR	35.00	0.00	\N	2026-06-12 06:24:53.359	cmqajkqkh0003i804v79h5ant
cmqajq7kn000ild04tdawt4xw	QR	200.00	0.00	\N	2026-06-12 06:29:08.184	cmqajq74g0001ld043b4b6ouz
cmqeev0u0000jl704lwroep64	QR	165.00	0.00	\N	2026-06-14 23:23:59.352	cmqeev0u00000l704f78yugzj
cmqefe5od000cjq049a9k594r	QR	100.00	0.00	\N	2026-06-14 23:38:52.093	cmqefe5od0000jq044w3dkn08
cmqeflkgb000ul704ulp33owc	QR	50.00	0.00	\N	2026-06-14 23:44:37.836	cmqefljug000nl704srmir2lv
cmqefmrgm000ojq04d3gye1e9	QR	65.00	0.00	\N	2026-06-14 23:45:33.575	cmqefmr0t000gjq045lm8nln2
cmqefz0pw0017l7046qa459cd	THAI_HELP	75.00	0.00	\N	2026-06-14 23:55:05.444	cmqefz0ah000wl7046feyedr3
cmqeg8u8l001bjq04kwxut5iv	THAI_HELP	55.00	0.00	\N	2026-06-15 00:02:43.605	cmqeg8tsi0013jq045drd16n9
cmqegd9m60008ju04i8v6gq6z	QR	40.00	0.00	\N	2026-06-15 00:06:10.159	cmqegd94j0001ju04y1dcckkq
cmqegdnj1000aju04wh4mnkl3	QR	35.00	0.00	\N	2026-06-15 00:06:28.19	cmqeg6svc000wjq04061val8b
cmqegeddl000hl404cs8jcidp	QR	70.00	0.00	\N	2026-06-15 00:07:01.689	cmqegeddl0007l40461h6z6kl
cmqeghrte000ll4041gunqfvk	CASH	35.00	0.00	\N	2026-06-15 00:09:40.37	cmqege2tl0001l404tzbsbout
cmqegkn1q000cju04fw6uoshl	QR	40.00	0.00	\N	2026-06-15 00:11:54.159	cmqee26ja0001i005b85yae0i
cmqegmynv000hl204w4c7zn5p	QR	35.00	0.00	\N	2026-06-15 00:13:42.523	cmqegmynu000bl204v6ux4cal
cmqegoltz0003jm04g1kyekqq	QR	15.00	0.00	\N	2026-06-15 00:14:59.207	cmqegolty0000jm04k5lmygkn
cmqegrqrr000wju0483edo7f1	QR	45.00	0.00	\N	2026-06-15 00:17:25.575	cmqegrqdb000qju04b81j0rx7
cmqegu6zy000ll204r5v7qfoy	CASH	75.00	0.00	\N	2026-06-15 00:19:19.919	cmqeglb080001l204a90y269y
cmqeh2whf0006l504ym6anez8	QR	35.00	0.00	\N	2026-06-15 00:26:06.195	cmqeh2whf0000l504q1rdw4df
cmqeh5e25000ul20424h2gowm	THAI_HELP	35.00	0.00	\N	2026-06-15 00:28:02.285	cmqeh5dnu000nl204bwd7gsa1
cmqeh5r50000fl504lodhqllq	QR	40.00	0.00	\N	2026-06-15 00:28:19.236	cmqeh5r500009l504p46seqda
cmqeh63l8000pl504e37ui2o7	THAI_HELP	40.00	0.00	\N	2026-06-15 00:28:35.372	cmqeh636w000jl5042dv21fb9
cmqeh7d3y000rl50464v7kaut	THAI_HELP	45.00	0.00	\N	2026-06-15 00:29:34.367	cmqegowpi000eju04vo1n0c92
cmqehib8w001rl704v5589set	QR	40.00	0.00	\N	2026-06-15 00:38:05.168	cmqefu4fg000qjq044svoavyg
cmqehk12o0024l704o93a0ito	THAI_HELP	35.00	0.00	\N	2026-06-15 00:39:25.297	cmqehk0ni001xl704tufjw9az
cmqeho1jw0010l504fymeakfh	THAI_HELP	40.00	0.00	\N	2026-06-15 00:42:32.54	cmqeh8n5o000wl204ou25zq0w
cmqehrztw002dl704gpjjqohg	THAI_HELP	40.00	0.00	\N	2026-06-15 00:45:36.932	cmqehnp01000tl5044avxcpir
cmqehsmeu001gl504ux9ss6he	CASH	40.00	0.00	\N	2026-06-15 00:46:06.199	cmqehsm2g0019l5047ixbwsxi
cmqehvhaz0001i304uz15pngw	QR	40.00	0.00	\N	2026-06-15 00:48:19.547	cmqehohi10012l504h49ma1ej
cmqehwfio0008i304s68e6v2i	QR	40.00	0.00	\N	2026-06-15 00:49:03.889	cmqehwfio0002i3042j7ijrmw
cmqehzo7x002sl70465vmqppq	THAI_HELP	35.00	0.00	\N	2026-06-15 00:51:35.134	cmqehp0h40026l70425sbnf3g
cmqei5t7u000li304bfr1vrop	THAI_HELP	35.00	0.00	\N	2026-06-15 00:56:21.546	cmqehz0ar002ll704ttpnxq2b
cmqei7vpe0031l7044xat9h5i	THAI_HELP	40.00	0.00	\N	2026-06-15 00:57:58.082	cmqei0bdi002ul7048ivwgnxb
cmqeiay5z0033l704naanezp6	THAI_HELP	40.00	0.00	\N	2026-06-15 01:00:21.24	cmqei2gsj000ci304ttavm0hm
cmqekpyar0008lb04mhseau34	THAI_HELP	40.00	0.00	\N	2026-06-15 02:08:00.484	cmqekpxuz0001lb042kqghdsq
cmqekqlu3000hlb04sfg525lg	THAI_HELP	35.00	0.00	\N	2026-06-15 02:08:30.987	cmqekqlft000alb04rkh20oqf
cmqekrnaf000slb04ey8xt12v	THAI_HELP	80.00	0.00	\N	2026-06-15 02:09:19.527	cmqekrmxq000jlb040pgslxo1
cmqel2ygi0011lb04eb2e042s	THAI_HELP	40.00	0.00	\N	2026-06-15 02:18:07.219	cmqel2y52000ulb04vu5o8f82
cmqel3fkq001alb04ka9tkl0m	CASH	35.00	0.00	\N	2026-06-15 02:18:29.403	cmqel3f9c0013lb04xopp32mt
cmqel4umv001jlb04up8pt8ly	THAI_HELP	35.00	0.00	\N	2026-06-15 02:19:35.575	cmqel4u94001clb04g44aiz26
cmqel6w42000elb04nz91kg4k	THAI_HELP	40.00	0.00	\N	2026-06-15 02:21:10.802	cmqel6vrh0007lb04221tcgcp
cmqel8xpv001slb04kyjj4064	THAI_HELP	40.00	0.00	\N	2026-06-15 02:22:46.195	cmqekv7060001lb041ncl7gms
cmqelbeql001ulb04njz5qrm2	CASH	40.00	0.00	\N	2026-06-15 02:24:41.566	cmqel7l3o001llb046wfqxcq3
cmqemetxu000cl204wga9rm60	QR	70.00	0.00	\N	2026-06-15 02:55:20.85	cmqemetdm0001l204600waj0e
cmqeopzkl000cih04x911nozq	THAI_HELP	70.00	0.00	\N	2026-06-15 04:00:00.597	cmqeopz470001ih04v431kzt4
cmqep6p77000el404df0a6k1s	THAI_HELP	40.00	0.00	\N	2026-06-15 04:13:00.308	cmqep4xu40001l4046bxwds4w
cmqeq5vi60007ib04ncdua48z	CASH	50.00	10.00	\N	2026-06-15 04:40:21.439	cmqeq5v3h0001ib044lz9ni4a
cmqerqr8f000cla048hs56jb0	QR	75.00	0.00	\N	2026-06-15 05:24:35.296	cmqerio620001i504s4hd8t5b
cmqerwho5000ela04ff3u9j2b	THAI_HELP	75.00	0.00	\N	2026-06-15 05:29:02.838	cmqerozpe0001la04i8oyzn3s
cmqfsqq76000mld04geer96ru	QR	205.00	0.00	\N	2026-06-15 22:40:19.745	cmqfsqq750000ld048c870nbs
cmqftvv5r000uld043xvyzf9i	QR	250.00	0.00	\N	2026-06-15 23:12:19.07	cmqftvv5q0000ld0465xta0at
cmqfuyzed000el804pfa7vt69	THAI_HELP	75.00	0.00	\N	2026-06-15 23:42:44.149	cmqfuyyrb0003l804jh674tnc
cmqfvburj0008ks049j56iw5k	THAI_HELP	70.00	0.00	\N	2026-06-15 23:52:44.671	cmqfvbu550001ks04a8tdcmou
cmqfvcak9000fks04593l46mo	QR	35.00	0.00	\N	2026-06-15 23:53:05.145	cmqfvcak90009ks04frb5z0ya
cmqfvtaqu000fjv04w3pllqko	THAI_HELP	35.00	0.00	\N	2026-06-16 00:06:18.535	cmqfvi9rs0001jv04v0eoq0tt
cmqfvwms7000qks04zpeyrdsu	THAI_HELP	40.00	0.00	\N	2026-06-16 00:08:54.103	cmqfvh4rl000jks04lk16yjy8
cmqfvxsru000uks04acrgq4pv	QR	35.00	0.00	\N	2026-06-16 00:09:48.522	cmqfvsiw80008jv045u9awuri
cmqfvxx8t000wks04sciif927	QR	40.00	0.00	\N	2026-06-16 00:09:54.317	cmqfud7nf000yld04jq4adjzq
cmqfw2czo000njv04nigl6iis	QR	40.00	0.00	\N	2026-06-16 00:13:21.348	cmqfw2clc000hjv04xvvg3a9h
cmqfw974v000wjv04ojfof77k	QR	70.00	0.00	\N	2026-06-16 00:18:40.352	cmqfw96qm000pjv04z3e2xapt
cmqfwdska0007l4046f4dwt2h	QR	40.00	0.00	\N	2026-06-16 00:22:14.747	cmqfwds850001l404h7wxfp60
cmqfwio8o000fl404colt1mih	QR	35.00	0.00	\N	2026-06-16 00:26:02.425	cmqfwio8o0008l404j8o7uh0q
cmqfwukb80016jv042jjxhiio	CASH	70.00	0.00	\N	2026-06-16 00:35:17.204	cmqfwuju3000zjv045v016l3p
cmqfx7v190001l104inlo0bzh	CASH	40.00	0.00	\N	2026-06-16 00:45:37.63	cmqfx1kkg000ql404tksl9q7i
cmqfxazn00007jp04kbt33f38	THAI_HELP	35.00	0.00	\N	2026-06-16 00:48:03.565	cmqfxayic0001jp04p9jgevib
cmqfxgr7g0009jp048ts8pbft	THAI_HELP	40.00	0.00	\N	2026-06-16 00:52:32.573	cmqfx13wa000jl404q3wirgy3
cmqg0hluf0008jo04xdqsoqvf	CASH	100.00	65.00	\N	2026-06-16 02:17:11.127	cmqg0d9w00001jo048onrf7e2
cmqg190lt0008la045xu2x1lv	THAI_HELP	35.00	0.00	\N	2026-06-16 02:38:29.969	cmqg16zzf0001la046sy3i4wt
cmqg323sv0003l104ws9p7fm0	THAI_HELP	70.00	0.00	\N	2026-06-16 03:29:06.751	cmqg2sz0w0001ic04q2gywnhk
cmqg38w9d000n3xzg7a26zpx4	QR	35.00	0.00	\N	2026-06-16 03:34:22.69	cmqg38w9c000h3xzgdo8lcntj
cmqg71a9c0001l604g6l8zxtp	QR	40.00	0.00	\N	2026-06-16 05:20:26.928	cmqg6xrh40001l80443zuen3d
cmqg76jle0003l604s2j1y5lm	THAI_HELP	40.00	0.00	\N	2026-06-16 05:24:32.307	cmqg70do00008l8041rjw1hvi
cmqg7bc1a0007le042hocyekh	QR	40.00	0.00	\N	2026-06-16 05:28:15.79	cmqg7bbm40001le04pb74fltp
cmqg8o46p0007k004qm0jsmy7	THAI_HELP	60.00	0.00	\N	2026-06-16 06:06:11.761	cmqg8o3ov0001k004zn9iec6o
cmqg8px1w000gk004npuczxnc	CASH	40.00	0.00	\N	2026-06-16 06:07:35.828	cmqg8pwmb0009k004z056fnpt
cmqg90u840008jg04gxz02dr8	CASH	100.00	65.00	\N	2026-06-16 06:16:05.381	cmqg8w2n00001jg04hwh2jc8v
cmqg9ectv000ik004ju49w6cc	THAI_HELP	40.00	0.00	\N	2026-06-16 06:26:36.019	cmqg93l3h000ajg04x2r5n7u1
cmqg9m9ea0008l2043b869dcp	QR	40.00	0.00	\N	2026-06-16 06:32:44.818	cmqg9m8wk0001l2044kvlwkjs
cmqh935b8000al80407h2rd88	QR	75.00	0.00	\N	2026-06-16 23:05:39.236	cmqh935b80000l804xbwxz2my
cmqh9eh62000ajp04raf03hgz	QR	95.00	0.00	\N	2026-06-16 23:14:27.818	cmqh9eh620000jp048o3l9529
cmqh9ho0k0011jp04yh84y6mx	QR	205.00	0.00	\N	2026-06-16 23:16:56.659	cmqh9ho0j000djp04obkt4exl
cmqha33fi000cjp04uecoidjj	THAI_HELP	75.00	0.00	\N	2026-06-16 23:33:36.415	cmqh9vl920001jp04vzxkb2vn
cmqhaf3ox0008la040djl3wqt	THAI_HELP	35.00	0.00	\N	2026-06-16 23:42:56.625	cmqhaf3ao0001la04zxmr7zrs
cmqhaoj8s0006l704ygbj7cpi	QR	35.00	0.00	\N	2026-06-16 23:50:16.684	cmqhaoj8s0000l704s2lnk9db
cmqhapt4y0007kz04e64uufgd	THAI_HELP	35.00	0.00	\N	2026-06-16 23:51:16.162	cmqhapsqa0001kz046m532ale
cmqhaunfq000gl704bovppwcw	QR	35.00	0.00	\N	2026-06-16 23:55:02.054	cmqhaun1j000al704nwyver1t
cmqhb1lzb000hla04kxqmruhu	THAI_HELP	35.00	0.00	\N	2026-06-17 00:00:26.76	cmqhb1lml000ala04fq4bpcip
cmqhb2h2t000pl704kzktveiu	QR	40.00	0.00	\N	2026-06-17 00:01:07.061	cmqhb2h2t000jl7049fgs758z
cmqhb64x1000gkz040t7jpxh3	QR	35.00	0.00	\N	2026-06-17 00:03:57.925	cmqhb64x0000akz04r3pajxy3
cmqhb97pr0005jr04omhz63ew	QR	35.00	0.00	\N	2026-06-17 00:06:21.519	cmqhb97pr0000jr04pubtyqr2
cmqhb9lv00009jr0451lnpl0u	THAI_HELP	40.00	0.00	\N	2026-06-17 00:06:39.853	cmqh8wax00001jv04r8li7plu
cmqhbbzs9000qjr049b4hrfaj	QR	40.00	0.00	\N	2026-06-17 00:08:31.209	cmqhbbzdo000kjr04249k17z8
cmqhbcvjv000qla04fo1lk1zy	QR	40.00	0.00	\N	2026-06-17 00:09:12.379	cmqhbcv6a000jla04rsxsaatv
cmqhbejx1000yla04uxolak3g	QR	35.00	0.00	\N	2026-06-17 00:10:30.614	cmqhbejle000sla04ilh347jq
cmqhblgsd0001kz04863lbnuo	THAI_HELP	40.00	0.00	\N	2026-06-17 00:15:53.149	cmqhbas6t000bjr04oanv73n2
cmqhc06j70016la04o923r0hq	CASH	40.00	5.00	\N	2026-06-17 00:27:19.7	cmqhbshph0001jv04qhu8n2rx
cmqhc2t790018la048z7edwnq	THAI_HELP	40.00	0.00	\N	2026-06-17 00:29:22.389	cmqhbyltz0010la04bflbvizt
cmqhc47oz001cla04mdpmmudr	QR	40.00	0.00	\N	2026-06-17 00:30:27.828	cmqh8wmrw0008jv04ur26ay8z
cmqhchbin000fjv04axyph9c5	THAI_HELP	40.00	0.00	\N	2026-06-17 00:40:39.312	cmqhc7c290008jv04is9tzreq
cmqhcpdza000ojv04rwhmzdcy	QR	40.00	0.00	\N	2026-06-17 00:46:55.75	cmqhcpdm6000hjv04fugns4mb
cmqhcsnpy000xjv04w68n42h7	THAI_HELP	40.00	0.00	\N	2026-06-17 00:49:28.342	cmqhcltl70003kz04cy40mcax
cmqhcxf8h000hkz04jas1uimf	THAI_HELP	35.00	0.00	\N	2026-06-17 00:53:10.625	cmqhcun7e000bkz047jjs8fxf
cmqhcy9io000jkz044zj4uv31	THAI_HELP	35.00	0.00	\N	2026-06-17 00:53:49.873	cmqhcrws3000qjv04xsvla0uz
cmqhd5rpk0008jm04c1rtb57m	THAI_HELP	35.00	0.00	\N	2026-06-17 00:59:40.04	cmqhd5r8y0001jm04wa7iem68
cmqhg0ean000cjo04vykx79jj	THAI_HELP	70.00	0.00	\N	2026-06-17 02:19:28.223	cmqhfuqx50001jo04t34m0axo
cmqhg5jyl000il504x1av3sca	QR	35.00	0.00	\N	2026-06-17 02:23:28.845	cmqhg0ox90001l504akagt4sa
cmqhg8qtk000kl504d64n8fkt	QR	80.00	0.00	\N	2026-06-17 02:25:57.705	cmqhg1n0u0008l504pmder52z
cmqhi0swy000ck004ss621z0x	THAI_HELP	70.00	0.00	\N	2026-06-17 03:15:46.402	cmqhi0sfq0001k0045pv79kx8
cmqhl3drd0008lf046c7lsre8	THAI_HELP	35.00	0.00	\N	2026-06-17 04:41:45.577	cmqhl0ww20001lf04au52qo3h
cmqhmf4wy000ll104249rchrb	THAI_HELP	40.00	0.00	\N	2026-06-17 05:18:53.602	cmqhmf4g4000fl1042d92hgmz
cmqhmfixa000nl10467dainge	QR	40.00	0.00	\N	2026-06-17 05:19:11.758	cmqhm4yl20008l104rjf45rkt
cmqhmm2z6000cl8044bad6k8x	THAI_HELP	70.00	0.00	\N	2026-06-17 05:24:17.682	cmqhmhit10001l804unnhg0v9
cmqhmvecg000ql8047sxguq5z	CASH	40.00	0.00	\N	2026-06-17 05:31:32.32	cmqhmppyp000kl8047u7gz2sb
cmqhmvgun000sl804lbqa4xjk	CASH	40.00	0.00	\N	2026-06-17 05:31:35.567	cmqhmpg0q000el804kdgln2j2
cmqhnb7770010l1043u7fqvf7	THAI_HELP	110.00	0.00	\N	2026-06-17 05:43:49.556	cmqhn1met000ul804vw7d4u44
cmqhndhcp0012l104ffgiunzj	THAI_HELP	80.00	0.00	\N	2026-06-17 05:45:36.026	cmqhn2e8m000pl104vfd9b0hv
cmqhndu5r0014l104glazvxi3	CASH	40.00	0.00	\N	2026-06-17 05:45:52.624	cmqhm46sw0001l1043tlu5z47
cmqinyyyb000jjy04hewozaha	QR	170.00	0.00	\N	2026-06-17 22:50:04.787	cmqinyyyb0000jy040wi1ntt0
cmqipg4z30001le04qhi4m3pu	QR	35.00	0.00	\N	2026-06-17 23:31:25.36	cmqiov38g0001l404yv6kw1ds
cmqiptf510006l804ortondu5	QR	35.00	0.00	\N	2026-06-17 23:41:45.061	cmqiptf510000l804u5anuxp0
cmqipw8mg0006lb04uh7i01zw	QR	40.00	0.00	\N	2026-06-17 23:43:56.584	cmqipw8mg0000lb04vnkmt0cf
cmqipzgaz000flb04fopqlxpb	QR	40.00	0.00	\N	2026-06-17 23:46:26.507	cmqipzgaz0009lb04c6nyrs81
cmqiqib4d0008l10452sarexl	QR	40.00	0.00	\N	2026-06-18 00:01:06.253	cmqiqib4d0002l10492bxht9b
cmqiqk5gb0005l104s77uiowf	QR	25.00	0.00	\N	2026-06-18 00:02:32.219	cmqiqk5460001l10498l06pva
cmqiqslal000pl104nv6pvly6	THAI_HELP	35.00	0.00	\N	2026-06-18 00:09:05.998	cmqiqeil8000llb045v88x0od
cmqiqu2jl000xl104eyqp498x	QR	35.00	0.00	\N	2026-06-18 00:10:15.01	cmqiqu26i000rl104xqjjd24u
cmqirag3k000cl104hddc4bo9	THAI_HELP	40.00	0.00	\N	2026-06-18 00:22:59.073	cmqiovbkk0008l4040pyo6jkb
cmqiranbq000el1046o96uo9i	THAI_HELP	40.00	0.00	\N	2026-06-18 00:23:08.438	cmqiqnbci0003l304uzkhhsrw
cmqiratco000gl1046wu6lh6p	THAI_HELP	145.00	0.00	\N	2026-06-18 00:23:16.248	cmqiqqkb40007l104em14o87o
cmqiraxnu000il104fwgubvym	QR	40.00	0.00	\N	2026-06-18 00:23:21.835	cmqiqrrhh000il104y40pq7as
cmqiri228000ml104eoxkm3bj	THAI_HELP	35.00	0.00	\N	2026-06-18 00:28:54.129	cmqiqnt3e000al304l4t5uwyr
cmqiro32x000vl1043sgdxj4u	QR	35.00	0.00	\N	2026-06-18 00:33:35.386	cmqirk8u6000ol104x2pfp3ws
cmqiru9y6000ll704o458193k	QR	35.00	0.00	\N	2026-06-18 00:38:24.222	cmqiru9k9000fl704p7ac3y2n
cmqirw5i8000tl704mp0l7u4y	THAI_HELP	40.00	0.00	\N	2026-06-18 00:39:51.776	cmqirw55o000nl704retl2fui
cmqirweme000vl704bmxrjsee	QR	35.00	0.00	\N	2026-06-18 00:40:03.59	cmqiroem80001l7043h65f158
cmqirzagb0013l1043hi0fr48	QR	40.00	0.00	\N	2026-06-18 00:42:18.155	cmqirqr8f0008l70423fkwlqv
cmqis6mrx001el704mvr1uudm	QR	30.00	0.00	\N	2026-06-18 00:48:00.718	cmqiryjwp000xl104ol4pmudy
cmqisfh7a0015l1046hgxygij	QR	150.00	0.00	\N	2026-06-18 00:54:53.398	cmqis5j6z000xl7045xd718hq
cmqiuzrzf0001ji04d7l8tvag	QR	40.00	0.00	\N	2026-06-18 02:06:39.723	cmqisj5tl001tl704ttt8nu22
cmqiv04ih000aji04d0vx3wp0	THAI_HELP	40.00	0.00	\N	2026-06-18 02:06:55.962	cmqiv04280003ji041auq6fff
cmqiv5y0j0008i804oa4a60de	THAI_HELP	35.00	0.00	\N	2026-06-18 02:11:27.476	cmqiv5xly0001i8047r3319jk
cmqivztby000bjy04d8jg1qyb	THAI_HELP	80.00	0.00	\N	2026-06-18 02:34:41.087	cmqivzsta0001jy049uxzyzh5
cmqiwt12r0008l7040l4b4s59	THAI_HELP	55.00	0.00	\N	2026-06-18 02:57:24.148	cmqiwt0mu0001l704gjw4471l
cmqiwt5az000al704ytg6x6is	THAI_HELP	285.00	0.00	\N	2026-06-18 02:57:29.627	cmqiw7z4e0001i204l23d2rgn
cmqix7le60007js04dv40cftx	QR	40.00	0.00	\N	2026-06-18 03:08:43.662	cmqiwyfui0001js04m2gwqttk
cmqix9fre0009js04f3ymuxtn	QR	40.00	0.00	\N	2026-06-18 03:10:09.674	cmqiwx8kr000cl704h0x2q4ct
cmqixfew2000jjs04xbnckegc	QR	55.00	0.00	\N	2026-06-18 03:14:48.483	cmqixfehj000bjs04ldhxm1xy
cmqj0g0iq000bl504yjj66lkz	THAI_HELP	80.00	0.00	\N	2026-06-18 04:39:15.363	cmqj03pk30001l5047vd6a30d
cmqj0summ0005la04qo01cqua	QR	25.00	0.00	\N	2026-06-18 04:49:14.255	cmqj0su8e0001la0481ue9a3y
cmqj1273p000dla047syc56l9	THAI_HELP	30.00	0.00	\N	2026-06-18 04:56:30.325	cmqj126pc0007la04a23oh02r
cmqj12cua000fla0414jb8cf6	THAI_HELP	40.00	0.00	\N	2026-06-18 04:56:37.763	cmqj0tusn0006il049hk3esr5
cmqj1c0g1000cla04pckj7jg0	CASH	100.00	30.00	\N	2026-06-18 05:04:08.258	cmqj1bzrh0001la0444utd79h
cmqj1s6fu0008jy04l8mpoml4	QR	35.00	0.00	\N	2026-06-18 05:16:42.523	cmqj1s5wy0001jy04yr0qqenu
cmqj5uu0e0008jy04r50p7qlj	CASH	100.00	60.00	\N	2026-06-18 07:10:44.847	cmqj5utke0001jy04vhutjbqs
cmqj5valv000hjy04r05dpg6g	CASH	100.00	30.00	\N	2026-06-18 07:11:06.355	cmqj5va36000ajy04b0dxhee5
cmqk4r47z000hky04r950lnwr	QR	175.00	0.00	\N	2026-06-18 23:27:38.014	cmqk4r47y0000ky045yngfa64
cmqk5qumb0006l20495v6rprf	QR	40.00	0.00	\N	2026-06-18 23:55:25.187	cmqk5qumb0000l204186dfqh5
cmqk5xdvy000sjo042f830c70	THAI_HELP	110.00	0.00	\N	2026-06-19 00:00:30.094	cmqk5ltex0003jo04135i4al5
cmqk5yf21000ujo04ybtpbeah	THAI_HELP	35.00	0.00	\N	2026-06-19 00:01:18.265	cmqk5tdqv000ejo0474h2oyq9
cmqk5ynia000wjo04bg5pwopm	THAI_HELP	35.00	0.00	\N	2026-06-19 00:01:29.219	cmqk5u11m000ljo042uukqrg3
cmqk68xod000ojp04wi32ysi6	CASH	100.00	20.00	\N	2026-06-19 00:09:28.957	cmqk63hot0007jp047fvjcp3h
cmqk69p5o0007k404lys2dbxd	THAI_HELP	35.00	0.00	\N	2026-06-19 00:10:04.573	cmqk5z6j50001jp04jhh9x4i9
cmqk6blov0007la0445f6rvn4	QR	70.00	0.00	\N	2026-06-19 00:11:33.391	cmqk6blov0000la04xzyiq4e3
cmqk6cn84000fla04cv3pmlpc	QR	35.00	0.00	\N	2026-06-19 00:12:22.036	cmqk6cn84000ala04yst74y29
cmqk6ms2g000jla04w1gdsi61	QR	30.00	0.00	\N	2026-06-19 00:20:14.873	cmqk68npo0001k404smn23y5s
cmqk6sv0r0018la043qmo388c	QR	40.00	0.00	\N	2026-06-19 00:24:58.635	cmqk6ntea000lla04nuqff2gf
cmqk6vog90001l404gu1h47z0	QR	40.00	0.00	\N	2026-06-19 00:27:10.09	cmqk6pmav000sla04r5z9ytfb
cmqk73woj000al404lr0rku0d	QR	40.00	0.00	\N	2026-06-19 00:33:34.003	cmqk65vn70001l7044hrqft2i
cmqk742kz000cl404um1l6o7y	QR	40.00	0.00	\N	2026-06-19 00:33:41.652	cmqk649d9000hjp044yyvw8g0
cmqk746vt000el404e0hapj50	QR	40.00	0.00	\N	2026-06-19 00:33:47.226	cmqk4rtrq000lky04lie0o6f0
cmqk74dsn000gl404els3tgd6	QR	35.00	0.00	\N	2026-06-19 00:33:56.184	cmqk6pw5a000yla04y205hndb
cmqk76jud000il4043qd73nri	QR	35.00	0.00	\N	2026-06-19 00:35:37.334	cmqk734is0003l404y4ybjmxu
cmqk7859t001wla04v0012003	CASH	40.00	0.00	\N	2026-06-19 00:36:51.761	cmqk784u8001pla04004y7d93
cmqk7v4ou0008le04ju8z4ppu	QR	40.00	0.00	\N	2026-06-19 00:54:44.094	cmqk7o75v0020la049bqkxy9p
cmqk7v88h000ale04sxn3ps46	QR	115.00	0.00	\N	2026-06-19 00:54:48.689	cmqk6ww8h001ala049xsqdm23
cmqk81kwt000cle04bv8wzw4v	THAI_HELP	35.00	0.00	\N	2026-06-19 00:59:45.053	cmqk7u1m90001le04e559f8rg
cmqkb6fj50001jn046ppvu2re	THAI_HELP	145.00	0.00	\N	2026-06-19 02:27:30.21	cmqkao9rg0001ji0433je8ff8
cmqkbe667000cjl04jfuw825j	QR	70.00	0.00	\N	2026-06-19 02:33:31.328	cmqkbe5pn0001jl04qxal8mnz
cmqkbfm76000sjl04vgi667bz	QR	105.00	0.00	\N	2026-06-19 02:34:38.755	cmqkbflu4000ejl04zutao2ay
cmqkcgghs000ajv043q0bjul2	THAI_HELP	85.00	0.00	\N	2026-06-19 03:03:17.633	cmqkc1g6a0001jv04qojswdj3
cmqkcrnb80008jr04ebmlabg2	QR	35.00	0.00	\N	2026-06-19 03:11:59.684	cmqkcrmxf0001jr04wp3pyspw
cmqke1hz9000ejl04850devoy	CASH	40.00	0.00	\N	2026-06-19 03:47:38.949	cmqkdzuo00008jl04l179jb78
cmqke1lmc000gjl04fqypq4w8	CASH	35.00	0.00	\N	2026-06-19 03:47:43.668	cmqkdsmbl0001jl04d2b9ejgd
cmqkek0zt0007lb04bxn94gdp	THAI_HELP	40.00	0.00	\N	2026-06-19 04:02:03.402	cmqkek0jl0001lb04443twlx5
cmqkg50wo000bjo0495o3gka2	THAI_HELP	95.00	0.00	\N	2026-06-19 04:46:22.68	cmqkfxl2s0001jo04hs16xxrf
cmqljgn1c000nl2040ksq1owp	QR	220.00	0.00	\N	2026-06-19 23:07:09.6	cmqljgn1b0000l204wpqepccy
cmqlk4vhi000hl304s62mu7hq	QR	175.00	0.00	\N	2026-06-19 23:26:00.294	cmqlk4vhi0000l304nax96eh9
cmqll0dt3000sjs04odn02gds	QR	40.00	0.00	\N	2026-06-19 23:50:30.376	cmqlkxlik000ljs04rzxyq8u5
cmqll1hgj000ujs04wbzl7xqg	CASH	40.00	0.00	\N	2026-06-19 23:51:21.763	cmqlkrcmk0003js04txy6rzgn
cmqll3j270008l404cqvez2du	THAI_HELP	35.00	0.00	\N	2026-06-19 23:52:57.151	cmqlktqce0001l404m7zaa1do
cmqllitc7001cjs04opyrfvs4	QR	40.00	0.00	\N	2026-06-20 00:04:50.311	cmqljrnd5000rl204061ohjkh
cmqlloogx001wjs04lu47jwsw	QR	35.00	0.00	\N	2026-06-20 00:09:23.937	cmqlloogx001qjs04kgxwn7kt
cmqllore80020js048pji6mch	QR	115.00	0.00	\N	2026-06-20 00:09:27.729	cmqlksw6u000ajs04imakf3oj
cmqllptqx000xl4042bbti3xq	QR	35.00	0.00	\N	2026-06-20 00:10:17.433	cmqllptqx000rl404wdf3dtc8
cmqllx8zw001dl4040ckbr7i7	QR	75.00	0.00	\N	2026-06-20 00:16:03.789	cmqllbybm000yjs04cz9jyxcl
cmqllyd2p001fl40483itpz65	QR	40.00	0.00	\N	2026-06-20 00:16:55.729	cmqlltt0i0017l404fw8cs4s6
cmqlm2v6d001hl4042hacw3w6	QR	35.00	0.00	\N	2026-06-20 00:20:25.814	cmqllpdsf000ll404ayzm7yti
cmqlm3v20001jl404dj4oo1kw	QR	50.00	0.00	\N	2026-06-20 00:21:12.312	cmqlllstk000el404mz6raner
cmqlma3u50008l504ao8uscxf	QR	40.00	0.00	\N	2026-06-20 00:26:03.629	cmqlma3hg0001l504mrf8zkxj
cmqlmbdat000fl504pmd5rkjn	QR	40.00	0.00	\N	2026-06-20 00:27:02.549	cmqlmbdat0009l504qxa4xp32
cmqlmjb1y0003jy04is3efjkw	QR	35.00	0.00	\N	2026-06-20 00:33:12.886	cmqllq1ui0022js04iyts2h0u
cmqlmjji20005jy043k9895wh	QR	40.00	0.00	\N	2026-06-20 00:33:23.835	cmqlllkbn001ejs04g41s95fm
cmqlmjt9d0007jy04lh3c5x3w	QR	35.00	0.00	\N	2026-06-20 00:33:36.481	cmqllr38q0011l404xgn72ro6
cmqlmjx570009jy04dyyg2ujc	QR	35.00	0.00	\N	2026-06-20 00:33:41.516	cmqllzdgh0029js04lp4nkczf
cmqlmkge4000kjy04spbuvlt1	QR	35.00	0.00	\N	2026-06-20 00:34:06.46	cmqlmd8vp001ll4044an4g0a7
cmqlmkzfk000rjy04agfbsbcg	QR	35.00	0.00	\N	2026-06-20 00:34:31.136	cmqlmkzfk000ljy04jswpjv5w
cmqlmnfb80006l704jjotei34	QR	35.00	0.00	\N	2026-06-20 00:36:25.028	cmqlmfqg7001rl4041embhu79
cmqlms9au002cl404v21w980m	CASH	35.00	0.00	\N	2026-06-20 00:40:10.518	cmqlmk6yg000djy04v7w2x586
cmqlmsc1f002el404fxud3mtm	QR	40.00	0.00	\N	2026-06-20 00:40:14.068	cmqlmh9vv001yl404ao7exfp5
cmqlmvwsh002gl404fhgnuhlf	CASH	35.00	0.00	\N	2026-06-20 00:43:00.93	cmqlmpczi000vjy04btf659c1
cmqln28ky000vl504ztstq1nc	QR	80.00	0.00	\N	2026-06-20 00:47:56.147	cmqlmnpjf0008l704v0y6g8ya
cmqln8zjd0014l504lefxb8iw	QR	70.00	0.00	\N	2026-06-20 00:53:11.017	cmqlmzkq5000jl5045tt9gmzs
cmqlnb04f0007je04x07fhcok	CASH	40.00	0.00	\N	2026-06-20 00:54:45.088	cmqlnazqq0001je0455o8160w
cmqlne7xn0009je04zdagdler	QR	80.00	0.00	\N	2026-06-20 00:57:15.179	cmqln2msy000xl504qji5b2aa
cmqlqa3kf0008l704my45pclh	CASH	35.00	0.00	\N	2026-06-20 02:18:01.744	cmqlqa33v0001l704mrm0pdq6
cmqlqajs2000hl704w5qsf8yq	THAI_HELP	80.00	0.00	\N	2026-06-20 02:18:22.754	cmqlqajdd000al704f5cejavb
cmqlr6rjy0006jm04kt2exu7x	QR	40.00	0.00	\N	2026-06-20 02:43:25.822	cmqlr53u10001l7046hn9q7as
cmqlrk4ao0001jp04bp0yxj01	CASH	200.00	80.00	\N	2026-06-20 02:53:48.864	cmqlr5cd50008l704v24do9vx
cmqlrkrkr000ajp04734ppri5	CASH	40.00	0.00	\N	2026-06-20 02:54:19.035	cmqlrkr5u0003jp04njzr6765
cmqlrm6nu000ijp04ybmhyp29	THAI_HELP	45.00	0.00	\N	2026-06-20 02:55:25.243	cmqlrm6bc000cjp04xw7q5r21
cmqlsaxqu000djx04ixpy6kpi	CASH	40.00	0.00	\N	2026-06-20 03:14:40.086	cmqls3v660006jx04be0ce1wz
cmqlsq1jt0008l704bolo9ilk	QR	35.00	0.00	\N	2026-06-20 03:26:24.857	cmqlskn6o0001l7049kx5in70
cmqlsx31y000el2047i4fs2u9	QR	50.00	0.00	\N	2026-06-20 03:31:53.399	cmqlsqlah0001l204izsehe9e
cmqlvpmg1000el304w56t4d41	THAI_HELP	30.00	0.00	\N	2026-06-20 04:50:04.13	cmqlvd2iz0008l304142slk83
cmqlvpx9r0001la04bq1hd3xs	QR	40.00	0.00	\N	2026-06-20 04:50:18.159	cmqlvchuz0001l304uwqggsl4
cmqlx9uw50008lb04v1q20iui	QR	80.00	0.00	\N	2026-06-20 05:33:47.813	cmqlx9uh00001lb04xia4qo6m
cmqlxaax1000llb04hlbyxwmd	THAI_HELP	70.00	0.00	\N	2026-06-20 05:34:08.582	cmqlxaajb000alb04jmtsr1eq
cmqlyl2600001l504alfnidbr	QR	225.00	0.00	\N	2026-06-20 06:10:30.072	cmqlxrvkm0001jo04fnbli9ip
cmqlz4yxf0008jv04ecw9m4fi	THAI_HELP	70.00	0.00	\N	2026-06-20 06:25:58.995	cmqlyzdpf0001jv04v7hjs9no
cmqlz8f46000hjv04986rf7yf	QR	40.00	0.00	\N	2026-06-20 06:28:39.943	cmqlz8ese000ajv041dx8txqz
cmqlz8vze000qjv040pa41qjo	QR	35.00	0.00	\N	2026-06-20 06:29:01.802	cmqlz8voc000jjv045dts0ltq
cmqm1htkc0008l104bkxnstdf	QR	35.00	0.00	\N	2026-06-20 07:31:57.804	cmqm1ht720001l1046r3atqhc
cmqm1i6jk000hl104bbo7g5z3	CASH	100.00	60.00	\N	2026-06-20 07:32:14.624	cmqm1i687000al1047oehbwrs
cmqof8n1e0006l404n595ap46	QR	35.00	0.00	\N	2026-06-21 23:32:16.418	cmqof8n1e0000l404yvrkazxb
cmqofkfx4000bjr04kpykvqvl	QR	40.00	0.00	\N	2026-06-21 23:41:27.064	cmqofkfiy0005jr04y7tki1tl
cmqoflmyx000ijr04zv74spu2	QR	35.00	0.00	\N	2026-06-21 23:42:22.857	cmqoflmyx000cjr04qwjjjbtc
cmqofxpsj0007l204i25u2n5w	QR	35.00	0.00	\N	2026-06-21 23:51:46.387	cmqofxpsi0000l204o4q86h6l
cmqog2vcj000kjy042ohb2n2r	THAI_HELP	75.00	0.00	\N	2026-06-21 23:55:46.867	cmqofz20t0001jy048fbnyvdu
cmqog5x2f000il204qxhlya54	QR	35.00	0.00	\N	2026-06-21 23:58:09.063	cmqofzkj6000cjy04n6lf0g6x
cmqog64bj000qjy04fj5gn57x	CASH	25.00	0.00	\N	2026-06-21 23:58:18.464	cmqog63yh000mjy0440mtmjew
cmqogex2l000wl204rogargln	QR	35.00	0.00	\N	2026-06-22 00:05:08.973	cmqogb5rr000ql204h3j0fjol
cmqogf224000yl204nx18znzh	THAI_HELP	35.00	0.00	\N	2026-06-22 00:05:15.437	cmqog7a1v000sjy04yaeoek4e
cmqogfedk0010l204m5dl1hhb	QR	35.00	0.00	\N	2026-06-22 00:05:31.401	cmqog4lo2000bl204n6c5okmt
cmqogjbo50018l204bjmttser	QR	35.00	0.00	\N	2026-06-22 00:08:34.518	cmqoghbpx0012l204zyk8ltaf
cmqogplqe001kjy04z7rlus4m	QR	40.00	0.00	\N	2026-06-22 00:13:27.495	cmqoggnri000zjy04nj5dejd1
cmqogw8gt001hl204kh8yo373	QR	40.00	0.00	\N	2026-06-22 00:18:36.894	cmqogqhau001al204d663z4pj
cmqogwdzu001jl2049fgs8up0	THAI_HELP	40.00	0.00	\N	2026-06-22 00:18:44.058	cmqogndw1001djy04yqcoys6l
cmqoh4aav0025l204kfi0lr00	QR	35.00	0.00	\N	2026-06-22 00:24:52.519	cmqoh4aau001zl204bxm2k34i
cmqoh5bly0006l504h15huf56	QR	40.00	0.00	\N	2026-06-22 00:25:40.87	cmqoh5bly0000l5046a55usxi
cmqohb11x001sjy04w4e8n7nh	QR	140.00	0.00	\N	2026-06-22 00:30:07.125	cmqoh0zo3001ll204rmq12c9o
cmqohdkjn001ujy04zha2o25i	CASH	30.00	0.00	\N	2026-06-22 00:32:05.7	cmqoh9e6r001mjy04267dacda
cmqohdnxc000al5047aecesr1	QR	40.00	0.00	\N	2026-06-22 00:32:10.08	cmqogat78000kl204q4qf57of
cmqoho94k002ol204a5u64ckz	THAI_HELP	35.00	0.00	\N	2026-06-22 00:40:24.117	cmqohj8mt0029l204hlyx39l6
cmqohogvt002ql204j8kkmkzf	THAI_HELP	40.00	0.00	\N	2026-06-22 00:40:34.17	cmqohlvah002fl204ey5e0j21
cmqohplvz002wl204owz9vz00	THAI_HELP	15.00	0.00	\N	2026-06-22 00:41:27.311	cmqohpljt002sl204orki3yvl
cmqohqt2a002yl204ty1m5reh	THAI_HELP	40.00	0.00	\N	2026-06-22 00:42:23.267	cmqogh0g60016jy04t0bj25e1
cmqohyp8f0039l204o0eq9cr8	QR	75.00	0.00	\N	2026-06-22 00:48:31.551	cmqohs760001wjy04vsk1snbi
cmqohyuri003bl204oz4v2nya	THAI_HELP	35.00	0.00	\N	2026-06-22 00:48:38.719	cmqohsaa30025jy04l3wz4gim
cmqohzjhh003dl204z1z3u9fm	QR	35.00	0.00	\N	2026-06-22 00:49:10.757	cmqohu9cz0030l2047mqn7fis
cmqoi2akg002jjy04cxyvrct0	THAI_HELP	40.00	0.00	\N	2026-06-22 00:51:19.168	cmqohzq2b002cjy0435747mm8
cmqoi3unc003ml204vnsbls9h	QR	35.00	0.00	\N	2026-06-22 00:52:31.848	cmqoi2yrw003fl20417yfow9f
cmqoidzlk003yl2040usq3uhx	CASH	40.00	0.00	\N	2026-06-22 01:00:24.825	cmqoi6xvk002sjy04vutzsk5d
cmqoigk440040l204kis8zt12	THAI_HELP	35.00	0.00	\N	2026-06-22 01:02:24.724	cmqoi6ryr002ljy04ci4r4ndp
cmqoio99q0042l204e4m8e4j3	CASH	80.00	0.00	\N	2026-06-22 01:08:23.918	cmqoiau65003ol204abxoqu0b
cmqolmv2y000gju04ffnvqzjf	QR	115.00	0.00	\N	2026-06-22 02:31:17.723	cmqolg4s80001ju04xew4vlfq
cmqolqf6d0008jv04oetikwxe	THAI_HELP	40.00	0.00	\N	2026-06-22 02:34:03.734	cmqolqeql0001jv04i2g58uta
cmqolu04b0001jo04azrrlmi8	CASH	100.00	25.00	\N	2026-06-22 02:36:50.844	cmqolni4u000iju04sh9c0wks
cmqomgfm2000eji042frduzvs	QR	40.00	0.00	\N	2026-06-22 02:54:17.354	cmqomfj1z0001ji041ryp1r64
cmqomkfqi000gji04slx86b32	QR	40.00	0.00	\N	2026-06-22 02:57:24.139	cmqomg06t0007ji04rq39l2eg
cmqomqz100008l704r87ujnga	CASH	40.00	0.00	\N	2026-06-22 03:02:29.076	cmqomqynh0001l704v0zp96ua
cmqomr60y000al7044nio8ayk	THAI_HELP	55.00	0.00	\N	2026-06-22 03:02:38.147	cmqomppaf0003jo04xxxmdwn1
cmqon33q2000kjo04f1xmmm4t	QR	35.00	0.00	\N	2026-06-22 03:11:55.034	cmqomvxq70002jo04rzjxbh57
cmqon5iyf000mjo043nn6weuk	QR	75.00	0.00	\N	2026-06-22 03:13:48.087	cmqomwyo50009jo0428s49uio
cmqony0u60009k004oz44k8wg	QR	80.00	0.00	\N	2026-06-22 03:35:57.63	cmqonqhbv0001k004evqx7jfj
cmqopvgci0008jr04fcitfq4p	CASH	100.00	65.00	\N	2026-06-22 04:29:56.995	cmqopvfwu0001jr041i76bvga
cmqopw29r000ajr04218h46sx	QR	35.00	0.00	\N	2026-06-22 04:30:25.408	cmqopb9bl0001l404c5s0v1dz
cmqoq294k000gjr04lnmfxvgz	CASH	15.00	0.00	\N	2026-06-22 04:35:14.229	cmqoq28to000cjr040bs22qec
cmqoqdcdy0008l1042qgfjqef	QR	35.00	0.00	\N	2026-06-22 04:43:51.671	cmqoqdbyr0001l104u1b9bkrs
cmqoqqa2t000blg041z8unlkp	CASH	100.00	20.00	\N	2026-06-22 04:53:55.206	cmqoqjxkv0001lg04c2el3icb
cmqorr7ht000clg04e2gt34i0	QR	175.00	0.00	\N	2026-06-22 05:22:38.129	cmqorr72l0001lg04ldt89q5n
cmqorunh1000ak004xwi4ldgw	QR	75.00	0.00	\N	2026-06-22 05:25:18.805	cmqorun5b0001k004d83itutj
cmqosh5110001la04zeq0dkp4	QR	40.00	0.00	\N	2026-06-22 05:42:47.99	cmqos3npl000ck004y1e0ddp5
cmqoszbx80008kz046cjtnc52	CASH	35.00	0.00	\N	2026-06-22 05:56:56.733	cmqoszbez0001kz04ysa1fr2a
cmqou0npb0008la04jrf06tdg	QR	40.00	0.00	\N	2026-06-22 06:25:58.271	cmqou0n820001la04ny6328bl
cmqoucq5o0001jr04y4xqa8tl	CASH	45.00	0.00	\N	2026-06-22 06:35:21.324	cmqou89t00008jf049xa3w7my
cmqoucscu0003jr04uueot2i2	CASH	35.00	0.00	\N	2026-06-22 06:35:24.174	cmqou6iwc0001jf04zssojjyx
cmqpuz6ig000jlb04hntc59d5	THAI_HELP	75.00	0.00	\N	2026-06-22 23:40:35.128	cmqpuz63t0008lb04i34g40d0
cmqpv35yi000fkz04rjp2kkpk	QR	120.00	0.00	\N	2026-06-22 23:43:41.034	cmqpv35yh0000kz04dyg19g6x
cmqpvpcb6000gkt04km4hcovs	QR	35.00	0.00	\N	2026-06-23 00:00:55.699	cmqpvkgac0008kt04lj54abc5
cmqpvrsq60007kz04yftlukaf	QR	35.00	0.00	\N	2026-06-23 00:02:50.286	cmqpvrsq50000kz04fyrrw3hs
cmqpwaz5p000sjl04v6etsg32	QR	40.00	0.00	\N	2026-06-23 00:17:45.086	cmqpui11v0001lb042itx3wrc
cmqpwb41c000ujl04glf7zgtg	QR	35.00	0.00	\N	2026-06-23 00:17:51.408	cmqpvj6ag0001kt04ess4ns7y
cmqpwb8a8000wjl04n2wmgth9	QR	40.00	0.00	\N	2026-06-23 00:17:56.912	cmqpw1p81000jjl04dxfxynlc
cmqpwcu2j000eld04xsazkrvb	QR	40.00	0.00	\N	2026-06-23 00:19:11.803	cmqpwcq4d0008ld04fmhsibir
cmqpweg3f000gld049odkzikl	QR	35.00	0.00	\N	2026-06-23 00:20:27.004	cmqpwcagy0001ld04byj18eym
cmqpwerty000pld048jmww2ha	QR	60.00	0.00	\N	2026-06-23 00:20:42.214	cmqpwertx000hld0461x1ia2y
cmqpwu46f000djx04rny2lm08	QR	45.00	0.00	\N	2026-06-23 00:32:38.055	cmqpwgjw10001jf04ip51wtse
cmqpwuhea000fjx04rda9d99g	CASH	30.00	0.00	\N	2026-06-23 00:32:55.186	cmqpwq1ro0001jx040h72icfv
cmqpwwwu5000ejf042xfa3ixa	QR	75.00	0.00	\N	2026-06-23 00:34:48.509	cmqpvzyb10001jl04u6v8knih
cmqpwyybi000gjf04emm7iur9	QR	80.00	0.00	\N	2026-06-23 00:36:23.743	cmqpwtjhy0007jx043jjhxb7j
cmqpxf7kr000rjf04zoo82t9n	CASH	40.00	0.00	\N	2026-06-23 00:49:02.236	cmqpx6f0a000hjx04lti7mpac
cmqpxfags000tjf04a8nhff34	QR	40.00	0.00	\N	2026-06-23 00:49:05.981	cmqpxbqpu000ijf043m6gjulk
cmqpxkly90014jx04rd099359	QR	25.00	0.00	\N	2026-06-23 00:53:14.145	cmqpxiown000tjx04e4595pmj
cmqpxkq120016jx04l0nm050j	QR	35.00	0.00	\N	2026-06-23 00:53:19.431	cmqpxfghr000vjf044dofdcuv
cmqpxku0o0018jx04u05mvtfw	QR	35.00	0.00	\N	2026-06-23 00:53:24.6	cmqpxhdgw000njx045dlrlyp2
cmqpxlnuh001ajx04chkxcc00	QR	35.00	0.00	\N	2026-06-23 00:54:03.257	cmqpxj6dt000xjx04mz2oiq29
cmqpzm5ld0008kt040yq5t6d9	QR	65.00	0.00	\N	2026-06-23 01:50:25.49	cmqpzldaf0001l40486tuof0m
cmqpzqtjj000akt04cx71t78f	QR	35.00	0.00	\N	2026-06-23 01:54:03.151	cmqpzln7o0001kt04f99spf20
cmqq0bheh000mkt04ck908hil	CASH	100.00	20.00	\N	2026-06-23 02:10:07.194	cmqq03ztn000ckt043fu09fhb
cmqq2zqwy000cjo04iaincfsf	THAI_HELP	70.00	0.00	\N	2026-06-23 03:24:58.499	cmqq2zqf30001jo04vpw9hcg3
cmqq30825000pjo04q7wtmyqk	CASH	80.00	0.00	\N	2026-06-23 03:25:20.717	cmqq307kw000ejo04dohz48nf
cmqq319yz000yjo04bmui3b8o	QR	40.00	0.00	\N	2026-06-23 03:26:09.851	cmqq319mc000rjo04bxfxgbk6
cmqq6nk7g000al204civ94nj0	QR	75.00	0.00	\N	2026-06-23 05:07:28.396	cmqq6nk7f0000l2048tsin8h5
cmqq6yejs0008jy04i06931lw	QR	35.00	0.00	\N	2026-06-23 05:15:54.281	cmqq6rct40007i304sag0w9cj
cmqq6yl8c000ajy042ce579el	QR	40.00	0.00	\N	2026-06-23 05:16:02.941	cmqq6obyz0001i304n6oiwdn3
cmqq71qg8000ejy04ke4qjand	QR	40.00	0.00	\N	2026-06-23 05:18:29.672	cmqq6wdo90001jy046dymokgb
cmqq7lils000dlb04ia5deji9	QR	255.00	0.00	\N	2026-06-23 05:33:52.624	cmqq7lilr0000lb0499saxfh7
cmqq965hy000klb04tztm0bq3	QR	35.00	0.00	\N	2026-06-23 06:17:55.03	cmqq965hx000flb04hp5wfoxc
cmqq9lqcm000ulb04q5tn97fz	QR	40.00	0.00	\N	2026-06-23 06:30:01.894	cmqq93uva000alb043xvmsuhn
cmqq9lu1k000wlb04bbrr9b6p	QR	40.00	0.00	\N	2026-06-23 06:30:06.68	cmqq8x3770002lb04yos38fog
cmqq9m0b4000ylb048ucva5zr	QR	75.00	0.00	\N	2026-06-23 06:30:14.801	cmqq8xvem0008lb04odew7367
cmqq9m3vb0010lb048nqk4sne	QR	70.00	0.00	\N	2026-06-23 06:30:19.415	cmqq9c6me000ilb04jab2xx01
cmqq9mh8g000wlb042elx6zvu	QR	40.00	0.00	\N	2026-06-23 06:30:36.736	cmqq9mgw6000plb04wyy9ja5n
cmqra6zq80007jo04xmypq531	QR	45.00	0.00	\N	2026-06-23 23:34:20	cmqra6zq80000jo046ttet8qg
cmqra8rjw000fjo044looy49g	QR	40.00	0.00	\N	2026-06-23 23:35:42.717	cmqra8rjw000ajo04wyg1h3yy
cmqravt500007jr04chqgwpd6	QR	35.00	0.00	\N	2026-06-23 23:53:37.86	cmqravt500000jr04fwnwafc0
cmqrb1quk0008l404ztfbn2dd	QR	80.00	0.00	\N	2026-06-23 23:58:14.828	cmqraodev000akz04pbli9jk3
cmqrb1wvb000al404l8e853up	CASH	40.00	0.00	\N	2026-06-23 23:58:22.632	cmqram8hw0001kz04wlhybj4y
cmqrbi8yb000ajo046beim86t	QR	35.00	0.00	\N	2026-06-24 00:11:04.787	cmqrb1gbh0001l404mckhztkx
cmqrbictj000cjo04ut2fxnp6	QR	40.00	0.00	\N	2026-06-24 00:11:09.799	cmqrax84w000bjr04z8ciaayq
cmqrbifh2000ejo04ij1x6fyt	QR	75.00	0.00	\N	2026-06-24 00:11:13.239	cmqracpce0001l4043l8c5jyn
cmqrbilx9000gjo04lu59ee2w	QR	35.00	0.00	\N	2026-06-24 00:11:21.598	cmqrbb9zw0001jo0441o02w6x
cmqrbryk5000ijo04btcntu08	QR	50.00	0.00	\N	2026-06-24 00:18:37.877	cmqrbjawg000cl40460oj49t7
cmqrbvse3000rjo041jjkfpqh	CASH	35.00	0.00	\N	2026-06-24 00:21:36.508	cmqrbthbh000kjo04qpzlffdk
cmqrc0vs4000zjo04uemwk5mv	CASH	35.00	0.00	\N	2026-06-24 00:25:34.181	cmqrc0lok000tjo04qdar3f8j
cmqrc41nl0006i304jgd1w5xb	QR	35.00	0.00	\N	2026-06-24 00:28:01.761	cmqrc41nl0000i304fvg1607m
cmqrc5kca000gi304yxki8ar7	QR	30.00	0.00	\N	2026-06-24 00:29:12.634	cmqrc5jte000ai304ol3p9z3d
cmqrc8fgt0006jm04s5k2lz11	QR	40.00	0.00	\N	2026-06-24 00:31:26.285	cmqrc8fgt0000jm043jieno7v
cmqrcbpvw000ajm04fuml9lif	QR	35.00	0.00	\N	2026-06-24 00:33:59.757	cmqrc65f80001l204w0e2gwsx
cmqrclb560008ic04im4oza5g	QR	35.00	0.00	\N	2026-06-24 00:41:27.21	cmqrcl5ls0001ic040ei43c90
cmqrcxwa40011jo04hyvqns24	QR	40.00	0.00	\N	2026-06-24 00:51:14.476	cmqrcp8x5000eic04k8tjtens
cmqrd2grl0008jy04ssxa5148	THAI_HELP	40.00	0.00	\N	2026-06-24 00:54:47.65	cmqrcy4e40013jo043h0t4tig
cmqrd2m28000ajy04lj8waz3i	QR	35.00	0.00	\N	2026-06-24 00:54:54.513	cmqrd263c0001jy045zh4u85f
cmqrd2qzy000cjy04wb3fuwpz	CASH	40.00	0.00	\N	2026-06-24 00:55:00.911	cmqrcy7890019jo04r6sih9gp
cmqrf5hvs000old045565k9dj	CASH	40.00	0.00	\N	2026-06-24 01:53:08.297	cmqrf47jx000hld04hfypa8ay
cmqrfefm1000qld0464bdwfow	QR	40.00	0.00	\N	2026-06-24 02:00:05.258	cmqrf1mnw0001ld04bd7ymtk0
cmqrfejj4000sld04wx4wu3ga	QR	40.00	0.00	\N	2026-06-24 02:00:10.336	cmqrf2gty0007ld04k9pjzsqi
cmqrfrh2b0007l104mio0wpyf	QR	40.00	0.00	\N	2026-06-24 02:10:13.667	cmqrfrglq0001l104xmcarnun
cmqrgv8qw0001kz046s4w8en3	CASH	75.00	0.00	\N	2026-06-24 02:41:09.128	cmqrg9nsl0001ie04ejs3b9hh
cmqrh58ih0001l5048tr4m8ck	QR	35.00	0.00	\N	2026-06-24 02:48:55.386	cmqrgwl11000bkz04jf7but3l
cmqrh5bm80003l50436sgl6cf	QR	50.00	0.00	\N	2026-06-24 02:48:59.409	cmqrgvum70003kz04ag2o6xlv
cmqrh5t8t0009l504wtzn8grt	CASH	25.00	0.00	\N	2026-06-24 02:49:22.254	cmqrh5su70005l5048raym4k7
cmqrh9qar000hl504tummiomm	CASH	40.00	10.00	\N	2026-06-24 02:52:25.059	cmqrh92r4000bl504oku7ssc3
cmqrhcmys000ql5040ztwkxwk	QR	35.00	0.00	\N	2026-06-24 02:54:40.709	cmqrhb1fd000jl504iijwrabr
cmqrlgt5e0005jp04jiv9g2vq	QR	30.00	0.00	\N	2026-06-24 04:49:53.81	cmqrlgt5d0000jp04txv6klq2
cmqrlnkzv000alb04c8sez1xb	QR	80.00	0.00	\N	2026-06-24 04:55:09.835	cmqrlnkzu0000lb04l5awr2va
cmqrm3jln0006lg04lrnwsgvp	CASH	30.00	0.00	\N	2026-06-24 05:07:34.523	cmqrm3j3x0001lg04v48yqwyh
cmqrm6h69000llb04lkidzp6p	QR	40.00	0.00	\N	2026-06-24 05:09:51.345	cmqrm6gsz000elb04yt2lfy0d
cmqrm6tf1000ulb04ptwlu11q	QR	40.00	0.00	\N	2026-06-24 05:10:07.214	cmqrm6t1o000nlb04wqn4r05f
cmqrmngr0001dlb04gfj114n4	QR	315.00	0.00	\N	2026-06-24 05:23:03.948	cmqrmngr0000vlb04rbad8inm
cmqrolwun0001l504pv5eqh07	QR	105.00	0.00	\N	2026-06-24 06:17:50.736	cmqrnimbr0001jj0465jdmyhm
cmqsopgjq000fl404uk6t92zf	QR	120.00	0.00	\N	2026-06-24 23:08:22.406	cmqsopgjq0000l404rp3y2vou
cmqspagr00007jr04ip6avqcu	QR	70.00	0.00	\N	2026-06-24 23:24:42.444	cmqspagr00000jr04wv487qjo
cmqspwbaz000pjs0459x58ryl	QR	175.00	0.00	\N	2026-06-24 23:41:41.819	cmqspwbay0004js04g2lmr5jc
cmqsqb9re0006l504ni0f736i	QR	40.00	0.00	\N	2026-06-24 23:53:19.658	cmqsqb9rd0000l504xxf1rosa
cmqsqibry000ijv0412qf1cou	THAI_HELP	80.00	0.00	\N	2026-06-24 23:58:48.863	cmqsqbh380001jv04fa9hjogy
cmqsql9ua0010js04rsx4cbgy	QR	35.00	0.00	\N	2026-06-25 00:01:06.323	cmqsqcot5000ajv04bqqbxo80
cmqsqmhpu0012js04tsbayy3d	THAI_HELP	75.00	0.00	\N	2026-06-25 00:02:03.186	cmqspu3px0001l7042wk9u83x
cmqsqxigc001ijv04ed8zap81	CASH	100.00	65.00	\N	2026-06-25 00:10:37.357	cmqsqxi1s001bjv049v7gmnik
cmqsr5u85001pjv04rapjs3u8	QR	70.00	0.00	\N	2026-06-25 00:17:05.861	cmqsqnrgy000kjv04s812jxc5
cmqsr73b6001rjv0424xmgc21	QR	35.00	0.00	\N	2026-06-25 00:18:04.29	cmqsqs6uo0014jv04smldlbth
cmqsrd9ue001xjs042x08kgjf	QR	65.00	0.00	\N	2026-06-25 00:22:52.694	cmqsqpgzf000rjv04zq0k50d2
cmqsrdlso001zjs04x5foy1xg	CASH	35.00	0.00	\N	2026-06-25 00:23:08.185	cmqsr2w4q001ajs04hqimym69
cmqsrdr9u0021js04mutcdopx	QR	40.00	0.00	\N	2026-06-25 00:23:15.283	cmqsql12w000tjs0452jscqle
cmqsrff6s0023js04it788qm8	QR	45.00	0.00	\N	2026-06-25 00:24:32.932	cmqsqzvh10014js04ryxuzh7o
cmqsrlq550027js04uvcmfvjz	CASH	30.00	0.00	\N	2026-06-25 00:29:27.065	cmqsraqs9001rjs04h1hms8lq
cmqsrs8n50029js04xb9lzgi0	QR	40.00	0.00	\N	2026-06-25 00:34:30.978	cmqsr4lze001gjs04r00zb0f2
cmqsrwzrq0006l504vn0z2zqx	QR	35.00	0.00	\N	2026-06-25 00:38:12.758	cmqsrwzrq0000l5040gm3nkc8
cmqss1evd002hjs04y1uooku4	QR	40.00	0.00	\N	2026-06-25 00:41:38.953	cmqsrxt81002bjs04v79dal5h
cmqssdj46002wjs04n1uakb2c	QR	75.00	0.00	\N	2026-06-25 00:51:04.327	cmqss6unk002ljs04vzfop6g8
cmqssh5dc0035js04bxqt9qb4	THAI_HELP	35.00	0.00	\N	2026-06-25 00:53:53.136	cmqssend5002yjs04okujv8et
cmqsuk0md0009jp041w2klyhd	CASH	100.00	35.00	\N	2026-06-25 01:52:06.181	cmqsujg810001jp04gj2edgq1
cmqsvjm4y000kic04i33y3sug	CASH	40.00	0.00	\N	2026-06-25 02:19:47.027	cmqsvh2wd0001ic04vdtnplx8
cmqsvjpbz000mic04ybokd55i	CASH	40.00	0.00	\N	2026-06-25 02:19:51.167	cmqsvh63a0007ic04ok0g4ggp
cmqsvlxmg000oic04x1whxj93	QR	35.00	0.00	\N	2026-06-25 02:21:35.225	cmqsvhfat000dic045z00p714
cmqswaxkk0007l7049jb6703e	CASH	110.00	0.00	\N	2026-06-25 02:41:01.557	cmqsvs7mv0001jr04vep682sr
cmqswmprz000dju04xmapq0cl	THAI_HELP	105.00	0.00	\N	2026-06-25 02:50:11.328	cmqswdvqy0001jp04xxzkyv04
cmqsx6nad0008kv04drsmgn12	CASH	40.00	0.00	\N	2026-06-25 03:05:41.221	cmqsx6mqv0001kv04gf0i7sa1
cmqsymgxl0006le04ltybpzjx	QR	60.00	0.00	\N	2026-06-25 03:45:59.097	cmqsymgxl0000le04e1apu8b2
cmqsziydk000dld04fv80knvq	QR	120.00	0.00	\N	2026-06-25 04:11:14.697	cmqsziijv0001ld041aaxvbov
cmqt160cf0006l504kgihgluy	QR	80.00	0.00	\N	2026-06-25 04:57:09.951	cmqt160cf0000l504vdkn128n
cmqt1mdye000al70417va9n96	CASH	40.00	0.00	\N	2026-06-25 05:09:54.086	cmqt1clfd0001l7045bfcatmr
cmqt3ycg80001l504qvpglpdr	QR	35.00	0.00	\N	2026-06-25 06:15:11.24	cmqt3j7kp0001jp0477j6jcj8
cmqt3zcd5000ll504ddzo9fq5	QR	105.00	0.00	\N	2026-06-25 06:15:57.785	cmqt3yob20003l504pdzkz1dc
cmqtj9p2j00063xqfsap46n8t	QR	35.00	0.00	\N	2026-06-25 13:23:55.051	cmqtj9p2i00003xqf43kb9wo4
cmqu5bmn80008js0483rstatf	QR	60.00	0.00	\N	2026-06-25 23:41:16.772	cmqu5bmn80000js047iejoava
cmqu5ov4c000ql204ax7p6pva	QR	225.00	0.00	\N	2026-06-25 23:51:34.283	cmqu5ov4b0000l2046p93napv
cmqu5ph4u001jl2042up7xu3k	QR	225.00	0.00	\N	2026-06-25 23:52:02.814	cmqu5ph4u000tl204qbuj1d31
cmqu61u0c002bl204180cvia9	QR	35.00	0.00	\N	2026-06-26 00:01:39.372	cmqu5z3xf001wl204f103vh45
cmqu61xej002dl204vgqpxg46	QR	35.00	0.00	\N	2026-06-26 00:01:43.772	cmqu5wd1z001pl204snbpud2p
cmqu6267i002fl204eosv6izc	QR	80.00	0.00	\N	2026-06-26 00:01:55.183	cmqu54za30001kz04rauytwb9
cmqu675xn0008jl04vw9kgzrb	QR	40.00	0.00	\N	2026-06-26 00:05:48.107	cmqu675xn0000jl04uptlngix
cmqu67hg6000cjl0465q167lt	QR	40.00	0.00	\N	2026-06-26 00:06:03.031	cmqu5u99y0001le04bwto7o2r
cmqu6efsf0001l8051kxig0sl	CASH	35.00	0.00	\N	2026-06-26 00:11:27.471	cmqu69t7f002jl204qa98wvj9
cmqu6frwa000fl805m6r5flmv	QR	35.00	0.00	\N	2026-06-26 00:12:29.818	cmqu6frwa0009l805c8bbgv7j
cmqu6mamh000jle046llcnyw6	QR	70.00	0.00	\N	2026-06-26 00:17:34.026	cmqu6gd5a002vl20464g25uuo
cmqu6p859000sle04fljw16ga	QR	35.00	0.00	\N	2026-06-26 00:19:50.781	cmqu6niaf000lle04xd561dlx
cmqu6xbgp000ule04iz5e6ai8	QR	40.00	0.00	\N	2026-06-26 00:26:08.329	cmqu6lors000dle04oi7ou1pt
cmqu7hrhb000yle042dyqn7of	CASH	30.00	0.00	\N	2026-06-26 00:42:02.207	cmqu7d0h20001ld04nck0xfpz
cmqu7i3tv0012le04v134iaej	QR	75.00	0.00	\N	2026-06-26 00:42:18.211	cmqu6fd6q0003l805cb43bo12
cmqu7ohui000kld04t877qxq4	QR	40.00	0.00	\N	2026-06-26 00:47:16.314	cmqu6a3pw002pl2041bhr1er8
cmqu7quj6000mld04azetngaz	QR	80.00	0.00	\N	2026-06-26 00:49:06.067	cmqu60x7w0022l204wlhxlvfv
cmqu813cz001ale04rdufyulr	QR	65.00	0.00	\N	2026-06-26 00:57:04.067	cmqu7vtwl000old04p32hvbyx
cmqu83ha3001cle04403t2m7w	QR	35.00	0.00	\N	2026-06-26 00:58:55.419	cmqu7jpdz0007ld04c9pzibry
cmqu83kc8001ele04y0y1diyt	QR	40.00	0.00	\N	2026-06-26 00:58:59.384	cmqu7mptc000eld04scjjmsi9
cmqu83qa2001gle04ilg8fo5y	QR	40.00	0.00	\N	2026-06-26 00:59:07.083	cmqu7w23g000wld04a62csjo2
cmqu85jrx001ile04b9ct21ey	QR	35.00	0.00	\N	2026-06-26 01:00:31.965	cmqu7wiin0012ld04lgsadinz
cmqu889nu0001jr04e856zd6e	QR	40.00	0.00	\N	2026-06-26 01:02:38.826	cmqu80m830014le04rswffq6b
cmqubgzxb000ml704nqgyyx8f	CASH	80.00	5.00	\N	2026-06-26 02:33:24.959	cmqubgzgi000bl70463lc0etm
cmqubq55w000ol704pb3i25eb	CASH	100.00	20.00	\N	2026-06-26 02:40:31.652	cmqubd48a0001l704ooyhcy58
cmquc5anu0001ju04df77j4ax	QR	35.00	0.00	\N	2026-06-26 02:52:18.619	cmqubqvo1000ql704r4ryecj4
cmquc8umj000hju04ncl1a6hq	QR	110.00	0.00	\N	2026-06-26 02:55:04.459	cmquc8umj0002ju04vd21peyy
cmqud7dtu000cjp0449c4f2zx	CASH	75.00	0.00	\N	2026-06-26 03:21:55.65	cmquczn5m0001jp046l5dm6i0
cmquff83y0001ie04xxhw0dbc	QR	40.00	0.00	\N	2026-06-26 04:24:00.719	cmquf4zs60001l70456s6f7d9
cmqugw8b60007ky04du991jfl	QR	40.00	0.00	\N	2026-06-26 05:05:13.746	cmqugvw1e0001ky04g8uwr83y
cmquhcaoi000gky04sj979tvo	QR	35.00	0.00	\N	2026-06-26 05:17:43.314	cmquh8biu0009ky04yv8gi8s4
cmqui05m6000bkz04yzfdzg45	QR	75.00	0.00	\N	2026-06-26 05:36:16.495	cmquhvspy0001kz04nsqifvjn
cmquifg2j0007l804kgsspkb3	QR	35.00	0.00	\N	2026-06-26 05:48:09.884	cmquiehyl0001l804zjf2li7i
cmquisn820008l404712ts820	QR	40.00	0.00	\N	2026-06-26 05:58:25.683	cmquismqe0001l40446lmetom
cmqvkok760001jy04yqtrw1xg	QR	115.00	0.00	\N	2026-06-26 23:39:00.547	cmqvkh56r0003jr04nvnq7sib
cmqvkpr5g0003jy04xpov60i9	QR	40.00	0.00	\N	2026-06-26 23:39:56.213	cmqvkhuen0001l904r8yvo1hy
cmqvky38o000fjv041il3z1yi	QR	125.00	0.00	\N	2026-06-26 23:46:25.128	cmqvky38n0000jv04kb6dkv59
cmqvlh5e20006kt0480jb3zmb	QR	35.00	0.00	\N	2026-06-27 00:01:14.378	cmqvlh5e20000kt047pb74whb
cmqvlpbtz000rky047ornjdm6	QR	45.00	0.00	\N	2026-06-27 00:07:35.975	cmqvlpbty000kky04pk9aro6k
cmqvlt1kf0016ky04tqf7twaa	QR	105.00	0.00	\N	2026-06-27 00:10:29.295	cmqvlt1ke000uky04g29ikceg
cmqvlu5k2001aky04440fkanw	QR	45.00	0.00	\N	2026-06-27 00:11:21.122	cmqvlln5v0001l504vvs9n8t7
cmqvlwhwv000fjs04ghfvkw59	QR	35.00	0.00	\N	2026-06-27 00:13:10.447	cmqvlwhwu0009js04kjz4nt37
cmqvm11k8000ejm04nmdumvkv	QR	115.00	0.00	\N	2026-06-27 00:16:42.536	cmqvlob4k0001ky04l2nm9erh
cmqvm9qsf000pjs043ngsvfpu	QR	40.00	0.00	\N	2026-06-27 00:23:28.479	cmqvlp9nq000eky04hutle273
cmqvmbvp5000tjs04zqyktx81	QR	30.00	0.00	\N	2026-06-27 00:25:08.153	cmqvm8ttk000jjs04n9z1w6ab
cmqvmeroh000el504jtkgfgip	QR	35.00	0.00	\N	2026-06-27 00:27:22.914	cmqvlow8u0001js04fhes2gts
cmqvmin8p0005l8046i9w0l6m	QR	45.00	0.00	\N	2026-06-27 00:30:23.785	cmqvmin8o0000l804spujq9oh
cmqvmjw9z0009l804dpouy67x	QR	40.00	0.00	\N	2026-06-27 00:31:22.152	cmqvme3ch0007l504e2y4gqjd
cmqvmy3k40015l504mqng8vhs	QR	35.00	0.00	\N	2026-06-27 00:42:24.773	cmqvmsyb7000gl504zwb6jq4x
cmqvn7e8d0014js047zz408tg	QR	40.00	0.00	\N	2026-06-27 00:49:38.51	cmqvmyrne0017l504y6dbhc1m
cmqvnay3m001ll504z4dbtzwr	QR	40.00	0.00	\N	2026-06-27 00:52:24.227	cmqvn46sv000vjs047vif4rei
cmqvnba3r0016js046zngo5ct	QR	40.00	0.00	\N	2026-06-27 00:52:39.783	cmqvn92xz001fl504eqzrcnem
cmqvnopex001ajs04ntfa2umv	QR	115.00	0.00	\N	2026-06-27 01:03:06.154	cmqvmvukw000ml504g5cuk2uj
cmqvpsr58000hif04wiokrvph	QR	35.00	0.00	\N	2026-06-27 02:02:14.252	cmqvpsalm0001if04s0klkhz1
cmqvq55xy000jif04lzgo7mzp	QR	70.00	0.00	\N	2026-06-27 02:11:53.303	cmqvpuzmx0001l404y5wwm65n
cmqvq58u5000lif04lvls5ebp	THAI_HELP	80.00	0.00	\N	2026-06-27 02:11:57.053	cmqvpsltp0008if0495ohbj5u
cmqvq944k000uif04t7bajket	QR	40.00	0.00	\N	2026-06-27 02:14:57.573	cmqvq5iib000nif04khems3ja
cmqvqqp0k0007jp04xgnjyp11	QR	35.00	0.00	\N	2026-06-27 02:28:37.796	cmqvqneyd0001jp040k4velvo
cmqvs9gwc0001l7047fj37yu1	QR	35.00	0.00	\N	2026-06-27 03:11:13.356	cmqvqzqb20009jp04kleo41np
cmqvsgsa80005jz04bkrjs33b	QR	30.00	0.00	\N	2026-06-27 03:16:54.704	cmqvsgo950001jz04eqyq4qdh
cmqvtju9w0005jm04fqccni3w	QR	35.00	0.00	\N	2026-06-27 03:47:16.868	cmqvtju9w0000jm04ug3a25pj
cmqvvczoc0006l104tilnmjrm	QR	40.00	0.00	\N	2026-06-27 04:37:56.508	cmqvvczoc0000l104ibzig4ya
cmqyf83fz000ejo040shl3lxu	QR	110.00	0.00	\N	2026-06-28 23:29:32.782	cmqyf83fy0000jo04udtgo417
cmqyfmbhz0008jl04rt1lmyuv	QR	35.00	0.00	\N	2026-06-28 23:40:36.408	cmqyfm4qb0001jl043aulsxd4
cmqyfrmqz0007jl04115xjxfx	QR	35.00	0.00	\N	2026-06-28 23:44:44.267	cmqyfrmqz0000jl043dbmovp4
cmqyfuauz000hjl041lyhi23u	QR	40.00	0.00	\N	2026-06-28 23:46:48.827	cmqyfuauz000ajl04jm0rhham
cmqyg7gez000qjl047uszdnku	QR	35.00	0.00	\N	2026-06-28 23:57:02.556	cmqyg31jy0001lb04mbdalepf
cmqygld9l000zjl04uz62mjvq	QR	50.00	0.00	\N	2026-06-29 00:07:51.658	cmqyg5nbh000cjl04zj4u576u
cmqyglh330011jl04pm7rmtto	CASH	35.00	0.00	\N	2026-06-29 00:07:56.608	cmqyg5tjs000jjl04uopxfksu
cmqyglkg00013jl049mnrix2d	QR	40.00	0.00	\N	2026-06-29 00:08:00.96	cmqyg7p85000sjl046p7dojk3
cmqyh723d0007jx04n3zk8rad	THAI_HELP	40.00	0.00	\N	2026-06-29 00:24:43.609	cmqygs0l50015jl049wz8rtwo
cmqyh761x0009jx0415t1y547	QR	40.00	0.00	\N	2026-06-29 00:24:48.742	cmqyh0nsh0001jx048s9ggllz
cmqyhjrwp000hjx04svypref7	QR	40.00	0.00	\N	2026-06-29 00:34:36.938	cmqyhje5a000bjx04xead26pw
cmqyi0qei000qjx04sz4ffpr4	QR	80.00	0.00	\N	2026-06-29 00:47:48.138	cmqyhu0s50001jl041x0n7755
cmqyi28ew000kjl04r2mrdo9y	QR	35.00	0.00	\N	2026-06-29 00:48:58.136	cmqyhwqe2000jjx04yxewshue
cmqyi4aqz000mjl048fpxo518	QR	40.00	0.00	\N	2026-06-29 00:50:34.476	cmqyi1rza000djl04jxepzoob
cmqyi7fbp000wjx04xnv71dlv	QR	45.00	0.00	\N	2026-06-29 00:53:00.373	cmqyi6tet000sjx04b8gieg51
cmqyi9mvo0014jx04xi591rvn	QR	40.00	0.00	\N	2026-06-29 00:54:43.476	cmqyi7tyg000yjx04ekdlsh4k
cmqyl8ykm000gl204hpqa6evk	QR	40.00	0.00	\N	2026-06-29 02:18:10.822	cmqyl4dx50001l204cp6l0030
cmqyle1xh0001ky040cieyk3l	QR	80.00	0.00	\N	2026-06-29 02:22:08.454	cmqyl59i80007l204l1ow01t4
cmqyll46x0003ky04yxwea3cb	QR	40.00	0.00	\N	2026-06-29 02:27:37.978	cmqylepff000il204aj6lrrmi
cmqylsf2r0005kz04dxz5m5ik	CASH	100.00	70.00	\N	2026-06-29 02:33:18.675	cmqylseoo0001kz04luk3w457
cmqymaf890008l8040ifimrng	QR	35.00	0.00	\N	2026-06-29 02:47:18.682	cmqyma7970001l80423o6e1qy
cmqynbned0008jm04437xmbmh	CASH	40.00	0.00	\N	2026-06-29 03:16:15.541	cmqynbmy60001jm0420rys5i7
cmqynx44c000hjm04udem3l4t	QR	40.00	0.00	\N	2026-06-29 03:32:56.988	cmqynx3nq000ajm04aybmf5jf
cmqyo0vba000jjm04a6yk2w3q	QR	180.00	0.00	\N	2026-06-29 03:35:52.199	cmqynlxtb0001l704n1ujt39m
cmqyr0cy0000fl404bq8qb0s4	QR	35.00	0.00	\N	2026-06-29 04:59:27.24	cmqyqzxsi0008l4046nu694oa
cmqyr9l1j000jl704u1qmonfy	QR	30.00	0.00	\N	2026-06-29 05:06:37.64	cmqyr806q000dl704ofw5w18i
cmqyr9t2q000ll704m7i0fm74	QR	35.00	0.00	\N	2026-06-29 05:06:48.05	cmqyr7w4m0007l704tpra1cj6
cmqyra2n8000nl704dt116vp9	QR	80.00	0.00	\N	2026-06-29 05:07:00.453	cmqyr7p970001l704qnksm8yz
cmqzu6216000fjn04puysafnt	QR	145.00	0.00	\N	2026-06-29 23:15:38.058	cmqzu62160000jn04v7d8urqd
cmqzu88gk000qjn04x6nhgthp	QR	55.00	0.00	\N	2026-06-29 23:17:19.7	cmqzu88gj000ijn04pahaail0
cmqzunybc000ol504qhwybkg5	QR	155.00	0.00	\N	2026-06-29 23:29:33.047	cmqzunybb0001l504m2hke39o
cmqzvnxad000gl704whsmfszw	QR	40.00	0.00	\N	2026-06-29 23:57:31.333	cmqzvnxad000al704oapxd2t8
cmqzvrvnp0006k1041d0kr3x8	QR	35.00	0.00	\N	2026-06-30 00:00:35.845	cmqzvrvno0000k1046rg92011
cmqzvup2j000hib04xuet1uzt	QR	80.00	0.00	\N	2026-06-30 00:02:47.276	cmqzva6ev0001l704zds8z4u5
cmqzw02l10007l2042j2q2hdp	QR	35.00	0.00	\N	2026-06-30 00:06:58.069	cmqzw02l10000l204fi314iya
cmqzw0kco0006ju04at0nlv9d	QR	35.00	0.00	\N	2026-06-30 00:07:21.096	cmqzw0kco0000ju044iic57q3
cmqzwdszb0001l204jmk8l4rg	QR	70.00	0.00	\N	2026-06-30 00:17:38.808	cmqzvoicx0001l404lbbs275o
cmqzwdwd20003l204joeiep2w	QR	40.00	0.00	\N	2026-06-30 00:17:43.19	cmqzvua1b000aib048uzjrcot
cmqzwlqo50006l204s438pkjp	QR	35.00	0.00	\N	2026-06-30 00:23:49.061	cmqzwlqo40000l2046fbrbgqb
cmqzwsmul0001jv047zrqe2bn	QR	75.00	0.00	\N	2026-06-30 00:29:10.701	cmqzvtoh20001ib04wwg2el8k
cmqzwsps90003jv04hq6q137m	QR	40.00	0.00	\N	2026-06-30 00:29:14.505	cmqzw141o000bl204hy27jx4g
cmqzwwm7x0018l204i852at7b	QR	35.00	0.00	\N	2026-06-30 00:32:16.509	cmqzwtdpv000al204vcrawf87
cmqzx1x4f001hl204wlp20f2u	QR	40.00	0.00	\N	2026-06-30 00:36:23.919	cmqzwty7s000hl204nk415prf
cmqzx6wc4001jl2044ma71yaw	THAI_HELP	70.00	0.00	\N	2026-06-30 00:40:16.18	cmqzwuqoe000rl204d3zt5ock
cmqzx6zgt001ll204x9e0h2js	QR	40.00	0.00	\N	2026-06-30 00:40:20.237	cmqzwuvzo000yl204m20n58yv
cmqzx9muh000bjv048fj6k0km	QR	40.00	0.00	\N	2026-06-30 00:42:23.849	cmqzx77x10005jv04241e0lrn
cmqzxgl770023l204idoh0gr1	QR	35.00	0.00	\N	2026-06-30 00:47:48.307	cmqzxgkla001wl204k7ppbu3t
cmqzxi992000djv04x1ul7pd1	QR	35.00	0.00	\N	2026-06-30 00:49:06.134	cmqzxbcx6001nl204abmhwnti
cmqzxn9jk000ljv04tq77mby2	CASH	40.00	0.00	\N	2026-06-30 00:52:59.792	cmqzx16gl001al204t63ek0jx
cmqzxqkl7000njv04cqswxhgj	QR	30.00	0.00	\N	2026-06-30 00:55:34.075	cmqzxim3x0025l204cqx361h5
cmqzxrml5000pjv04uhdy5wys	QR	40.00	0.00	\N	2026-06-30 00:56:23.322	cmqzxk1dy000fjv044mvfouyo
cmqzzylkx0008l5048a3ofjiz	QR	40.00	0.00	\N	2026-06-30 01:57:47.842	cmqzzyl1j0001l504kjjdl86c
cmr005gi9000hl504jsgdfo4s	QR	35.00	0.00	\N	2026-06-30 02:03:07.858	cmr005g1o000al504dg4nt2zo
cmr00sy3z000ujr04nse38322	THAI_HELP	85.00	0.00	\N	2026-06-30 02:21:23.76	cmr00nkfb0001jr04oaxfco8s
cmr017fk60001ju049kcqvopm	QR	35.00	0.00	\N	2026-06-30 02:32:39.558	cmr00umwc0008l704gvxzuz0w
\.


--
-- Data for Name: point_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.point_logs (id, action, amount, note, "createdAt", "memberId", "expiredAt", "orderId") FROM stdin;
cmpr7h33a00043x4afog52z7a	REDEEM	-50	แลก coupon 540DB45DD382A4F7	2026-05-29 17:38:29.734	cmpr50gby0000l204k4iyqunq	\N	\N
cmpr9ckxj00073xj35c1i17pv	EARN	3	ได้รับแต้มจากออเดอร์ #1	2026-05-29 18:30:56.658	cmpr50gby0000l204k4iyqunq	\N	cmpr9cgwi00033xj31qufevei
cmprbxun700063xv17nfxueok	EARN	8	ได้รับแต้มจากออเดอร์ #2	2026-05-29 19:43:30.097	cmpr50gby0000l204k4iyqunq	\N	cmprbxrj600003xv1wn5cwg4q
cmprs7bzz0001l504lfl5g4pf	EARN	4	Earned from POS #1	2026-05-30 03:18:46.656	cmprr5tw70000l404nwvbr3wm	2028-05-30 03:18:46.646	cmprrzj440001jt04g0o4pnfx
cmprsdg7c000gjt04bftd2nxz	EARN	4	ได้รับแต้มจากออเดอร์ #2	2026-05-30 03:23:32.016	cmpr50gby0000l204k4iyqunq	\N	cmprsdg5p0008jt04skruj31p
cmptyhw0g0007l804h499jwqi	EARN	4	ได้รับแต้มจากออเดอร์ #1	2026-05-31 15:50:29.199	cmpqxi3y80000jv042tmuxldv	\N	cmptyhvzb0000l804ucmfskuf
cmpu4czwg000fjy046rpo0ncy	EARN	4	ได้รับแต้มจากออเดอร์ #2	2026-05-31 18:34:38.63	cmpqxi3y80000jv042tmuxldv	\N	cmpu4czuy0008jy048skwpqw7
cmpu4laiw000ojy049pn366ue	EARN	4	ได้รับแต้มจากออเดอร์ #3	2026-05-31 18:41:05.672	cmpqxi3y80000jv042tmuxldv	\N	cmpu4laht000ijy042ikyqdnr
cmpu59ees0007l8047y1f2pkx	EARN	4	ได้รับแต้มจากออเดอร์ #4	2026-05-31 18:59:50.452	cmpr50gby0000l204k4iyqunq	\N	cmpu59edy0000l804bjfgmfz2
cmpuscesa0008l704sqryj3jf	EARN	4	ได้รับแต้มจากออเดอร์ #1	2026-06-01 05:46:02.072	cmprr5tw70000l404nwvbr3wm	\N	cmpuscer10000l704jawwp0xs
cmpushqi2000il7046s8pyj3g	EARN	3	ได้รับแต้มจากออเดอร์ #2	2026-06-01 05:50:10.538	cmprr5tw70000l404nwvbr3wm	\N	cmpushqhb000bl704j4943lbl
cmpy8rgk40007l504lysnr3l8	EARN	8	ได้รับแต้มจากออเดอร์ #3	2026-06-03 15:48:56.597	cmprr5tw70000l404nwvbr3wm	\N	cmpy8rgim0000l504nzvht0rq
cmpy8vdlb000bjo04goqrj782	EARN	8	ได้รับแต้มจากออเดอร์ #5	2026-06-03 15:51:59.373	cmprr5tw70000l404nwvbr3wm	\N	cmpy8vdjy0000jo04autj6aeq
cmpy9boo90008js04r9v8p9cf	EARN	5	ได้รับแต้มจากออเดอร์ #7	2026-06-03 16:04:40.209	cmprr5tw70000l404nwvbr3wm	\N	cmpy9bomr0000js04wg0jzabt
cmpya2idm0004jr04j5wj2rrq	EARN	4	ได้รับแต้มจากออเดอร์ #8	2026-06-03 16:25:31.784	cmprr5tw70000l404nwvbr3wm	\N	cmpya2icv0000jr0483dlbk03
cmpya51hf000bjr04m84h0b2s	EARN	3	ได้รับแต้มจากออเดอร์ #9	2026-06-03 16:27:29.857	cmprr5tw70000l404nwvbr3wm	\N	cmpya51gg0005jr04o2x1r012
cmpyn85ws000fjo04b1bumn1z	EARN	15	ได้รับแต้มจากออเดอร์ #10	2026-06-03 22:33:50.573	cmpymupkz0000js04v26bxcpp	\N	cmpyn85rp0000jo046amu4tk5
cmpyo5o9c000vk305p3ts6o8s	EARN	4	ได้รับแต้มจากออเดอร์ #13	2026-06-03 22:59:53.999	cmpymupkz0000js04v26bxcpp	\N	cmpyo5o8l000nk3059zpmxlnp
cmpyov4lp000cju04qzliav13	EARN	12	ได้รับแต้มจากออเดอร์ #16	2026-06-03 23:19:41.559	cmpymupkz0000js04v26bxcpp	\N	cmpyov4k10000ju04ecmvai9z
cmpyteeu60007l104ch2x72bv	EARN	7	ได้รับแต้มจากออเดอร์ #17	2026-06-04 01:26:39.775	cmpymupkz0000js04v26bxcpp	\N	cmpyteetj0000l1043odzmbbb
cmpyu5nfz0007le04ua27bk7s	EARN	4	ได้รับแต้มจากออเดอร์ #18	2026-06-04 01:47:50.64	cmpqxi3y80000jv042tmuxldv	\N	cmpyu5ney0000le049vr4ux0k
cmpzn18v6000ul804baaj7rgt	EARN	25	ได้รับแต้มจากออเดอร์ #21	2026-06-04 15:16:13.955	cmpzm4vyo0000jv04i6eeh20d	\N	cmpzn18t00002l804go4cusjg
cmq01tb7n000ijl04hjs5naav	EARN	16	ได้รับแต้มจากออเดอร์ #6	2026-06-04 22:09:57.993	cmpymupkz0000js04v26bxcpp	\N	cmq01tb4k0000jl04nnio0hsl
cmq033ft80008jr04alstdd2m	EARN	3	ได้รับแต้มจากออเดอร์ #7	2026-06-04 22:45:50.155	cmpymupkz0000js04v26bxcpp	\N	cmq033frk0000jr047ttf5sut
cmq038s820005jm04qxqpq6jk	EARN	4	ได้รับแต้มจากออเดอร์ #8	2026-06-04 22:49:59.522	cmq034bpi0009jr04rvfh744g	\N	cmq038s7a0000jm04iq6s93xw
cmq03wrzv000ljs04iw0y3nfg	EARN	12	ได้รับแต้มจากออเดอร์ #11	2026-06-04 23:08:38.971	cmpymupkz0000js04v26bxcpp	\N	cmq03wruo0007js04bw9vmhxi
cmq0607ws000alb04kmo25fhy	EARN	4	ได้รับแต้มจากออเดอร์ #16	2026-06-05 00:07:18.794	cmpymupkz0000js04v26bxcpp	\N	cmq0607ve0002lb04kfq5p2wx
cmq060wsf000elb04fv5astfb	EARN	25	Earned from POS #2	2026-06-05 00:07:51.04	cmpzm4vyo0000jv04i6eeh20d	2028-06-05 00:07:51.033	cmpzn18t00002l804go4cusjg
cmq06vtx20007jr05c3rz8s9e	EARN	4	ได้รับแต้มจากออเดอร์ #22	2026-06-05 00:31:53.627	cmpymupkz0000js04v26bxcpp	\N	cmq06vtv40000jr05g818s0kz
cmq079ot1000gjr05of9xgcmg	EARN	16	Earned from POS #6	2026-06-05 00:42:40.214	cmpymupkz0000js04v26bxcpp	2028-06-05 00:42:40.208	cmq01tb4k0000jl04nnio0hsl
cmq079r1r000ijr0501862w0u	EARN	3	Earned from POS #7	2026-06-05 00:42:43.119	cmpymupkz0000js04v26bxcpp	2028-06-05 00:42:43.116	cmq033frk0000jr047ttf5sut
cmq079ux6000kjr05emdux3dn	EARN	12	Earned from POS #11	2026-06-05 00:42:48.139	cmpymupkz0000js04v26bxcpp	2028-06-05 00:42:48.134	cmq03wruo0007js04bw9vmhxi
cmq079ysb000mjr05to4th92j	EARN	4	Earned from POS #16	2026-06-05 00:42:53.147	cmpymupkz0000js04v26bxcpp	2028-06-05 00:42:53.143	cmq0607ve0002lb04kfq5p2wx
cmq07a3i7000ojr054l6h2r6b	EARN	4	Earned from POS #22	2026-06-05 00:42:59.264	cmpymupkz0000js04v26bxcpp	2028-06-05 00:42:59.259	cmq06vtv40000jr05g818s0kz
cmq07a9ch000qjr05baz7etuh	EARN	4	Earned from POS #8	2026-06-05 00:43:06.833	cmq034bpi0009jr04rvfh744g	2028-06-05 00:43:06.829	cmq038s7a0000jm04iq6s93xw
cmq114w3t000djm0405nyucfc	EARN	10	ได้รับแต้มจากออเดอร์ #1	2026-06-05 14:38:44.873	cmpzm4vyo0000jv04i6eeh20d	\N	cmq114w0z0000jm041r0x2r0z
cmq1hwe8u000ckv04w3cdj5o1	EARN	8	ได้รับแต้มจากออเดอร์ #2	2026-06-05 22:28:01.927	cmpymupkz0000js04v26bxcpp	\N	cmq1hwe630000kv04klzp66w9
cmq1irphw0007js04nzbkhf3b	EARN	4	ได้รับแต้มจากออเดอร์ #3	2026-06-05 22:52:22.868	cmpymupkz0000js04v26bxcpp	\N	cmq1irpg10000js04s9dnm156
cmq1j9est000vld04qtqt40u9	EARN	4	ได้รับแต้มจากออเดอร์ #7	2026-06-05 23:06:08.811	cmpymupkz0000js04v26bxcpp	\N	cmq1j9ers000mld04kspv7ko2
cmq1jnwqu0007le04qmh6c32w	EARN	4	ได้รับแต้มจากออเดอร์ #9	2026-06-05 23:17:25.255	cmpymupkz0000js04v26bxcpp	\N	cmq1jnwq30000le04w68is4ju
cmq1jso440009l4046l85c6h6	EARN	4	ได้รับแต้มจากออเดอร์ #10	2026-06-05 23:21:07.296	cmpymupkz0000js04v26bxcpp	\N	cmq1jso1p0000l4047yyu3xai
cmq1k2how0001l404prrlhg44	EARN	4	Earned from POS #9	2026-06-05 23:28:45.585	cmpymupkz0000js04v26bxcpp	2028-06-05 23:28:45.578	cmq1jnwq30000le04w68is4ju
cmq1k747r000bl404q6wlfjg1	EARN	4	Earned from POS #3	2026-06-05 23:32:21.399	cmpymupkz0000js04v26bxcpp	2028-06-05 23:32:21.393	cmq1irpg10000js04s9dnm156
cmq1khtal000ol4044efa9lde	EARN	8	ได้รับแต้มจากออเดอร์ #11	2026-06-05 23:40:40.461	cmpymupkz0000js04v26bxcpp	\N	cmq1kht9f000cl4043ymardtx
cmq1lufby001kl404zpj6f1ou	EARN	10	Earned from POS #1	2026-06-06 00:18:28.51	cmpzm4vyo0000jv04i6eeh20d	2028-06-06 00:18:28.505	cmq114w0z0000jm041r0x2r0z
cmq1lulcp001ml404a9k1unrt	EARN	8	Earned from POS #2	2026-06-06 00:18:36.313	cmpymupkz0000js04v26bxcpp	2028-06-06 00:18:36.303	cmq1hwe630000kv04klzp66w9
cmq1luzdm001ql404yp9ebllp	EARN	4	Earned from POS #7	2026-06-06 00:18:54.491	cmpymupkz0000js04v26bxcpp	2028-06-06 00:18:54.487	cmq1j9ers000mld04kspv7ko2
cmq1lvb9g001sl404gjf8dhas	EARN	4	Earned from POS #10	2026-06-06 00:19:09.892	cmpymupkz0000js04v26bxcpp	2028-06-06 00:19:09.888	cmq1jso1p0000l4047yyu3xai
cmq1mpfad002gl404693oen5v	EARN	7	ได้รับแต้มจากออเดอร์ #22	2026-06-06 00:42:34.761	cmpymupkz0000js04v26bxcpp	\N	cmq1mpf8r0024l404a7y95h31
cmq1mxpn9002il4041xgfxl2q	EARN	8	Earned from POS #11	2026-06-06 00:49:01.462	cmpymupkz0000js04v26bxcpp	2028-06-06 00:49:01.455	cmq1kht9f000cl4043ymardtx
cmq1ngr4y000djo045dm48owg	EARN	7	Earned from POS #22	2026-06-06 01:03:49.859	cmpymupkz0000js04v26bxcpp	2028-06-06 01:03:49.849	cmq1mpf8r0024l404a7y95h31
cmq1nwpar000fjo04d56o8izr	EARN	11	ได้รับแต้มจากออเดอร์ #28	2026-06-06 01:16:13.971	cmq1np99f000gjo048bks9own	\N	cmq1nwp660000jo04uxfhdmgv
cmq1r044l0001l404d83z9m55	EARN	11	Earned from POS #28	2026-06-06 02:42:52.005	cmq1np99f000gjo048bks9own	2028-06-06 02:42:51.994	cmq1nwp660000jo04uxfhdmgv
cmq3yqbv80007jl049qbnd396	EARN	4	ได้รับแต้มจากออเดอร์ #10	2026-06-07 15:54:44.755	cmpr50gby0000l204k4iyqunq	\N	cmq3yqbr70000jl04h71kd5ar
cmq3yvmuq000dl7042x6l1ooo	EARN	4	ได้รับแต้มจากออเดอร์ #11	2026-06-07 15:58:52.274	cmpr50gby0000l204k4iyqunq	\N	cmq3yvmtt0006l7040e6z8zvt
cmq4c2r4o0009jr04wgyx8l8t	EARN	7	ได้รับแต้มจากออเดอร์ #12	2026-06-07 22:08:19.417	cmpzm4vyo0000jv04i6eeh20d	\N	cmq4c2r220000jr04to75lb55
cmq4c5k930009lh044r79as1k	EARN	3	ได้รับแต้มจากออเดอร์ #13	2026-06-07 22:10:30.447	cmpzm4vyo0000jv04i6eeh20d	\N	cmq4c5k7f0000lh04ajcehru4
cmq4cnb4q000dk0045stnwhos	EARN	7	ได้รับแต้มจากออเดอร์ #14	2026-06-07 22:24:18.459	cmpymupkz0000js04v26bxcpp	\N	cmq4cnb2x0000k004gb57z98x
cmq4drttu000bjp048ackmvrg	EARN	4	Earned from POS #11	2026-06-07 22:55:48.931	cmpr50gby0000l204k4iyqunq	2028-06-07 22:55:48.921	cmq3yvmtt0006l7040e6z8zvt
cmq4dtk900007jy04qh1zmg5d	EARN	4	Earned from POS #10	2026-06-07 22:57:09.828	cmpr50gby0000l204k4iyqunq	2028-06-07 22:57:09.82	cmq3yqbr70000jl04h71kd5ar
cmq4dxpuw0009js04x725bvap	EARN	3	ได้รับแต้มจากออเดอร์ #16	2026-06-07 23:00:23.686	cmpzm4vyo0000jv04i6eeh20d	\N	cmq4dxpsb0000js046idgljfp
cmq4e0y95000kjr044gb0xjb4	EARN	11	ได้รับแต้มจากออเดอร์ #18	2026-06-07 23:02:54.538	cmpymupkz0000js04v26bxcpp	\N	cmq4e0y6y0002jr0467ohj7al
cmq4f79j60001l104lff3qh1b	EARN	11	Earned from POS #18	2026-06-07 23:35:48.739	cmpymupkz0000js04v26bxcpp	2028-06-07 23:35:48.723	cmq4e0y6y0002jr0467ohj7al
cmq4fa1zw0003l1047408yiru	EARN	7	Earned from POS #14	2026-06-07 23:37:58.941	cmpymupkz0000js04v26bxcpp	2028-06-07 23:37:58.936	cmq4cnb2x0000k004gb57z98x
cmq4fzlnx000ul804594ddl69	EARN	4	ได้รับแต้มจากออเดอร์ #23	2026-06-07 23:57:50.829	cmpymupkz0000js04v26bxcpp	\N	cmq4fzln2000ll804nx62g2xm
cmq4gf3v1000hl804arp9s5eh	EARN	4	ได้รับแต้มจากออเดอร์ #25	2026-06-08 00:09:54.252	cmpymupkz0000js04v26bxcpp	\N	cmq4gf3u90008l804xk3zzlrl
cmq4gpl2d0005jr04gfaadwd3	EARN	7	Earned from POS #12	2026-06-08 00:18:03.109	cmpzm4vyo0000jv04i6eeh20d	2028-06-08 00:18:03.1	cmq4c2r220000jr04to75lb55
cmq4gpn150007jr04ny3tkuxd	EARN	3	Earned from POS #13	2026-06-08 00:18:05.658	cmpzm4vyo0000jv04i6eeh20d	2028-06-08 00:18:05.652	cmq4c5k7f0000lh04ajcehru4
cmq4gpoq60009jr04avr7g7v0	EARN	3	Earned from POS #16	2026-06-08 00:18:07.854	cmpzm4vyo0000jv04i6eeh20d	2028-06-08 00:18:07.848	cmq4dxpsb0000js046idgljfp
cmq4gu8tk000djr049nea39fy	EARN	4	Earned from POS #23	2026-06-08 00:21:40.521	cmpymupkz0000js04v26bxcpp	2028-06-08 00:21:40.515	cmq4fzln2000ll804nx62g2xm
cmq4gua3v000fjr048rbjwn18	EARN	4	Earned from POS #25	2026-06-08 00:21:42.187	cmpymupkz0000js04v26bxcpp	2028-06-08 00:21:42.183	cmq4gf3u90008l804xk3zzlrl
cmq5s9ar1000dju04d07ryd8d	EARN	8	ได้รับแต้มจากออเดอร์ #1	2026-06-08 22:29:04.814	cmpymupkz0000js04v26bxcpp	\N	cmq5s9aoe0000ju04scxlmgnf
cmq5t5rtd000cl504wbqpy5dt	EARN	10	ได้รับแต้มจากออเดอร์ #2	2026-06-08 22:54:19.921	cmpzm4vyo0000jv04i6eeh20d	\N	cmq5t5rru0000l5042bio6uw7
cmq5tg4it000ml5042pdque5w	EARN	3	ได้รับแต้มจากออเดอร์ #3	2026-06-08 23:02:22.95	cmpzm4vyo0000jv04i6eeh20d	\N	cmq5tg4i1000dl5049cs206m7
cmq5tkrkm0008jm04eoxu5mpq	EARN	8	ได้รับแต้มจากออเดอร์ #5	2026-06-08 23:05:59.447	cmpymupkz0000js04v26bxcpp	\N	cmq5tkrk30000jm04v7eptx56
cmq5tq5mu000fl804baev8lxf	EARN	11	ได้รับแต้มจากออเดอร์ #6	2026-06-08 23:10:10.951	cmpzm4vyo0000jv04i6eeh20d	\N	cmq5tq5lt0000l804kevidzil
cmq5ufg8e0001kz04tj4q7wmt	EARN	8	Earned from POS #5	2026-06-08 23:29:51.086	cmpymupkz0000js04v26bxcpp	2028-06-08 23:29:51.07	cmq5tkrk30000jm04v7eptx56
cmq5uph9t000gkz04mgvfflw6	EARN	9	ได้รับแต้มจากออเดอร์ #7	2026-06-08 23:37:38.993	cmpymupkz0000js04v26bxcpp	\N	cmq5uph800002kz04l96olp0d
cmq5vfhem0008le04ippjx0cr	EARN	4	ได้รับแต้มจากออเดอร์ #9	2026-06-08 23:57:52.223	cmpymupkz0000js04v26bxcpp	\N	cmq5vfhdn0000le04nau7i8rb
cmq5vh6vv000bjm04qdd2dq89	EARN	10	ได้รับแต้มจากออเดอร์ #11	2026-06-08 23:59:11.9	cmpymupkz0000js04v26bxcpp	\N	cmq5vh6uy0000jm0420zqs4qq
cmq5vxd5f0001l8044mrf0o47	EARN	10	Earned from POS #2	2026-06-09 00:11:46.515	cmpzm4vyo0000jv04i6eeh20d	2028-06-09 00:11:46.509	cmq5t5rru0000l5042bio6uw7
cmq5vxfoa0003l8043q0sy5op	EARN	3	Earned from POS #3	2026-06-09 00:11:49.786	cmpzm4vyo0000jv04i6eeh20d	2028-06-09 00:11:49.783	cmq5tg4i1000dl5049cs206m7
cmq5vxhiz0005l804yw3em6b2	EARN	11	Earned from POS #6	2026-06-09 00:11:52.187	cmpzm4vyo0000jv04i6eeh20d	2028-06-09 00:11:52.183	cmq5tq5lt0000l804kevidzil
cmq5wdof60009l804rsy1oeiv	EARN	9	Earned from POS #7	2026-06-09 00:24:27.619	cmpymupkz0000js04v26bxcpp	2028-06-09 00:24:27.612	cmq5uph800002kz04l96olp0d
cmq5wwo4a000tl804pw14rpnf	EARN	4	Earned from POS #9	2026-06-09 00:39:13.691	cmpymupkz0000js04v26bxcpp	2028-06-09 00:39:13.685	cmq5vfhdn0000le04nau7i8rb
cmq5wwsyu000vl804folnj5ub	EARN	8	Earned from POS #1	2026-06-09 00:39:19.975	cmpymupkz0000js04v26bxcpp	2028-06-09 00:39:19.971	cmq5s9aoe0000ju04scxlmgnf
cmq5wwvun000xl804b53kdhui	EARN	10	Earned from POS #11	2026-06-09 00:39:23.711	cmpymupkz0000js04v26bxcpp	2028-06-09 00:39:23.707	cmq5vh6uy0000jm0420zqs4qq
cmq77yrwn000gju04ui09djvc	EARN	13	ได้รับแต้มจากออเดอร์ #1	2026-06-09 22:36:33.836	cmpymupkz0000js04v26bxcpp	\N	cmq77yrtg0000ju04tahgagvy
cmq79r83q0001jx04au3e7uhy	EARN	13	Earned from POS #1	2026-06-09 23:26:40.839	cmpymupkz0000js04v26bxcpp	2028-06-09 23:26:40.827	cmq77yrtg0000ju04tahgagvy
cmq7a4amh000bjv040askc4r8	EARN	9	ได้รับแต้มจากออเดอร์ #8	2026-06-09 23:36:50.608	cmpymupkz0000js04v26bxcpp	\N	cmq7a4ak30000jv04bxzlkgs2
cmq7ar78b0003jx04p3d39csv	EARN	9	Earned from POS #8	2026-06-09 23:54:39.323	cmpymupkz0000js04v26bxcpp	2028-06-09 23:54:39.318	cmq7a4ak30000jv04bxzlkgs2
cmq7asae2000cjx04nzo3c6a5	EARN	5	ได้รับแต้มจากออเดอร์ #10	2026-06-09 23:55:30.075	cmpymupkz0000js04v26bxcpp	\N	cmq7asad70004jx04a8njafgl
cmq7ayiuu0008l50483vn08zw	EARN	4	ได้รับแต้มจากออเดอร์ #11	2026-06-10 00:00:20.953	cmpymupkz0000js04v26bxcpp	\N	cmq7ayit00000l504ki72wer9
cmq7bcbih0001l404o1bu1gv0	EARN	4	Earned from POS #11	2026-06-10 00:11:04.65	cmpymupkz0000js04v26bxcpp	2028-06-10 00:11:04.643	cmq7ayit00000l504ki72wer9
cmq7bcffu0003l4045dis7c0r	EARN	5	Earned from POS #10	2026-06-10 00:11:09.739	cmpymupkz0000js04v26bxcpp	2028-06-10 00:11:09.733	cmq7asad70004jx04a8njafgl
cmq7bcr81000cl404sb3n2tvf	EARN	5	ได้รับแต้มจากออเดอร์ #15	2026-06-10 00:11:24.984	cmpymupkz0000js04v26bxcpp	\N	cmq7bcr6l0004l4046p8u67e1
cmq7bl2x2000xl504arx62ivy	EARN	5	Earned from POS #15	2026-06-10 00:17:53.414	cmpymupkz0000js04v26bxcpp	2028-06-10 00:17:53.408	cmq7bcr6l0004l4046p8u67e1
cmq7hgg14000ik004bpspsht4	EARN	15	ได้รับแต้มจากออเดอร์ #37	2026-06-10 03:02:14.825	cmq7hdolg000klb04x9d9hye6	\N	cmq7hgfzy0000k00428coxwvj
cmq8nljo4000qk5049wcf4s5d	EARN	26	ได้รับแต้มจากออเดอร์ #1	2026-06-10 22:41:56.69	cmpymupkz0000js04v26bxcpp	\N	cmq8nljlp0000k504ybgamm2p
cmq8okw3j000mjv0468sz3el3	EARN	18	ได้รับแต้มจากออเดอร์ #2	2026-06-10 23:09:25.735	cmpzm4vyo0000jv04i6eeh20d	\N	cmq8okvwv0000jv04zuzsd30a
cmq8ovw4w000ak30405kuk0bj	EARN	5	ได้รับแต้มจากออเดอร์ #3	2026-06-10 23:17:58.995	cmpzm4vyo0000jv04i6eeh20d	\N	cmq8ovw360000k3042klqx77h
cmq8p4elj000ck304dtlimplc	EARN	26	Earned from POS #1	2026-06-10 23:24:36.199	cmpymupkz0000js04v26bxcpp	2028-06-10 23:24:36.187	cmq8nljlp0000k504ybgamm2p
cmq8prliy0008js044vk2tyw2	EARN	8	ได้รับแต้มจากออเดอร์ #5	2026-06-10 23:42:38.244	cmpymupkz0000js04v26bxcpp	\N	cmq8prlhj0000js04teqhwo8p
cmq8q0msw0001ju04b3zseqvp	EARN	8	Earned from POS #5	2026-06-10 23:49:39.824	cmpymupkz0000js04v26bxcpp	2028-06-10 23:49:39.818	cmq8prlhj0000js04teqhwo8p
cmq8qbnje000ii804yf4fn3c2	EARN	6	ได้รับแต้มจากออเดอร์ #7	2026-06-10 23:58:13.991	cmpymupkz0000js04v26bxcpp	\N	cmq8qbnil000ai804jju7b3bw
cmq8qwdes000pi6042s9vseyw	EARN	6	Earned from POS #7	2026-06-11 00:14:20.644	cmpymupkz0000js04v26bxcpp	2028-06-11 00:14:20.636	cmq8qbnil000ai804jju7b3bw
cmq8r28es0008jo04uhx4824r	EARN	4	ได้รับแต้มจากออเดอร์ #12	2026-06-11 00:18:54.065	cmpymupkz0000js04v26bxcpp	\N	cmq8r28ci0000jo04dib4mjur
cmq8r3bmu0001l2047p6iloer	EARN	18	Earned from POS #2	2026-06-11 00:19:44.934	cmpzm4vyo0000jv04i6eeh20d	2028-06-11 00:19:44.928	cmq8okvwv0000jv04zuzsd30a
cmq8r3d4q0003l204f1270ajy	EARN	5	Earned from POS #3	2026-06-11 00:19:46.874	cmpzm4vyo0000jv04i6eeh20d	2028-06-11 00:19:46.87	cmq8ovw360000k3042klqx77h
cmq8rewp10001l204tpx8t1s2	EARN	4	Earned from POS #12	2026-06-11 00:28:45.445	cmpymupkz0000js04v26bxcpp	2028-06-11 00:28:45.44	cmq8r28ci0000jo04dib4mjur
cmq8y8tz7000nl1045i9ckaij	EARN	15	ได้รับแต้มจากออเดอร์ #33	2026-06-11 03:39:59.297	cmq7hdolg000klb04x9d9hye6	\N	cmq8y8txt0009l104g3kq58gy
cmqdujcq800093xap0m4uktvr	EARN	3	ได้รับแต้มจากออเดอร์ #1	2026-06-14 13:55:02.27	cmpr50gby0000l204k4iyqunq	\N	cmqduj93f00023xapgmz8rijc
cmqdv4f1b000x3xap7mcq9gx9	EARN	3	ได้รับแต้มจากออเดอร์ #2	2026-06-14 14:11:25.036	cmpr50gby0000l204k4iyqunq	\N	cmqdv4b93000q3xapzueyweuf
cmqdw0v620001kz04mayd7hiy	EARN	3	Earned from POS #1	2026-06-14 14:36:39.242	cmpr50gby0000l204k4iyqunq	2028-06-14 14:36:39.235	cmqduj93f00023xapgmz8rijc
cmqdw0wb00003kz04tq2cen0u	EARN	3	Earned from POS #2	2026-06-14 14:36:40.716	cmpr50gby0000l204k4iyqunq	2028-06-14 14:36:40.712	cmqdv4b93000q3xapzueyweuf
cmqdw2kp7000ckz04qefcr1gu	EARN	3	ได้รับแต้มจากออเดอร์ #3	2026-06-14 14:37:58.988	cmprr5tw70000l404nwvbr3wm	\N	cmqdw2koa0004kz04d6aywjbj
cmqdw5vab0008lb04vlbp9swh	EARN	4	ได้รับแต้มจากออเดอร์ #4	2026-06-14 14:40:32.673	cmprr5tw70000l404nwvbr3wm	\N	cmqdw5v990000lb04g5ikfk4d
cmqdw6ao0000alb045rv47seb	EARN	3	Earned from POS #3	2026-06-14 14:40:52.608	cmprr5tw70000l404nwvbr3wm	2028-06-14 14:40:52.6	cmqdw2koa0004kz04d6aywjbj
cmqdw6cyd000clb0463e3ra7c	EARN	4	Earned from POS #4	2026-06-14 14:40:55.573	cmprr5tw70000l404nwvbr3wm	2028-06-14 14:40:55.569	cmqdw5v990000lb04g5ikfk4d
cmqeev0yo000ll704oes9qvbl	EARN	20	ได้รับแต้มจากออเดอร์ #6	2026-06-14 23:23:59.492	cmpymupkz0000js04v26bxcpp	\N	cmqeev0u00000l704f78yugzj
cmqefe5qa000ejq04uoiehpsc	EARN	10	ได้รับแต้มจากออเดอร์ #7	2026-06-14 23:38:52.161	cmpzm4vyo0000jv04i6eeh20d	\N	cmqefe5od0000jq044w3dkn08
cmqegedf4000jl4046osgpro5	EARN	8	ได้รับแต้มจากออเดอร์ #16	2026-06-15 00:07:01.745	cmpymupkz0000js04v26bxcpp	\N	cmqegeddl0007l40461h6z6kl
cmqegmyp6000jl2045pxfcbsi	EARN	4	ได้รับแต้มจากออเดอร์ #18	2026-06-15 00:13:42.569	cmpymupkz0000js04v26bxcpp	\N	cmqegmynu000bl204v6ux4cal
cmqegolvp0005jm048o15587h	EARN	1	ได้รับแต้มจากออเดอร์ #19	2026-06-15 00:14:59.246	cmpymupkz0000js04v26bxcpp	\N	cmqegolty0000jm04k5lmygkn
cmqegpfs0000mju04ipv9f5b8	EARN	1	Earned from POS #19	2026-06-15 00:15:38.016	cmpymupkz0000js04v26bxcpp	2028-06-15 00:15:38.004	cmqegolty0000jm04k5lmygkn
cmqegq8u7000oju040p40425i	EARN	8	Earned from POS #16	2026-06-15 00:16:15.679	cmpymupkz0000js04v26bxcpp	2028-06-15 00:16:15.669	cmqegeddl0007l40461h6z6kl
cmqegytxa001ll704ec7xilit	EARN	10	Earned from POS #7	2026-06-15 00:22:56.254	cmpzm4vyo0000jv04i6eeh20d	2028-06-15 00:22:56.232	cmqefe5od0000jq044w3dkn08
cmqegzmzu001nl704wr35riir	EARN	4	Earned from POS #18	2026-06-15 00:23:33.93	cmpymupkz0000js04v26bxcpp	2028-06-15 00:23:33.92	cmqegmynu000bl204v6ux4cal
cmqegzxd7001pl704xlilmaxz	EARN	20	Earned from POS #6	2026-06-15 00:23:47.371	cmpymupkz0000js04v26bxcpp	2028-06-15 00:23:47.351	cmqeev0u00000l704f78yugzj
cmqeh2wjx0008l504ce9acagq	EARN	5	ได้รับแต้มจากออเดอร์ #22	2026-06-15 00:26:06.252	cmpymupkz0000js04v26bxcpp	\N	cmqeh2whf0000l504q1rdw4df
cmqeh5r6r000hl504hde25o9v	EARN	4	ได้รับแต้มจากออเดอร์ #24	2026-06-15 00:28:19.3	cmq5wjkiw0000jy04p03a3vql	\N	cmqeh5r500009l504p46seqda
cmqehidlt001tl704gac282nw	EARN	4	Earned from POS #24	2026-06-15 00:38:08.225	cmq5wjkiw0000jy04p03a3vql	2028-06-15 00:38:08.214	cmqeh5r500009l504p46seqda
cmqehigh8001vl704h8kgraku	EARN	5	Earned from POS #22	2026-06-15 00:38:11.949	cmpymupkz0000js04v26bxcpp	2028-06-15 00:38:11.939	cmqeh2whf0000l504q1rdw4df
cmqehwfl1000ai304llr1iwxc	EARN	6	ได้รับแต้มจากออเดอร์ #32	2026-06-15 00:49:03.942	cmpymupkz0000js04v26bxcpp	\N	cmqehwfio0002i3042j7ijrmw
cmqei3qzg000ji3042hpn0aq5	EARN	6	Earned from POS #32	2026-06-15 00:54:45.341	cmpymupkz0000js04v26bxcpp	2028-06-15 00:54:45.328	cmqehwfio0002i3042j7ijrmw
cmqfsqqa7000old049u84di8b	EARN	30	ได้รับแต้มจากออเดอร์ #1	2026-06-15 22:40:19.823	cmpymupkz0000js04v26bxcpp	\N	cmqfsqq750000ld048c870nbs
cmqftvv8y000wld04sphavv4j	EARN	31	ได้รับแต้มจากออเดอร์ #2	2026-06-15 23:12:19.156	cmpzm4vyo0000jv04i6eeh20d	\N	cmqftvv5q0000ld0465xta0at
cmqfuwz210001l804b8hzaitf	EARN	30	Earned from POS #1	2026-06-15 23:41:10.393	cmpymupkz0000js04v26bxcpp	2028-06-15 23:41:10.375	cmqfsqq750000ld048c870nbs
cmqfvcakx000hks04zosrd7vt	EARN	5	ได้รับแต้มจากออเดอร์ #6	2026-06-15 23:53:05.169	cmpymupkz0000js04v26bxcpp	\N	cmqfvcak90009ks04frb5z0ya
cmqfvxmg9000sks04180686rj	EARN	5	Earned from POS #6	2026-06-16 00:09:40.329	cmpymupkz0000js04v26bxcpp	2028-06-16 00:09:40.323	cmqfvcak90009ks04frb5z0ya
cmqfwio9q000hl4044c4c6xlp	EARN	3	ได้รับแต้มจากออเดอร์ #13	2026-06-16 00:26:02.462	cmq5wjkiw0000jy04p03a3vql	\N	cmqfwio8o0008l404j8o7uh0q
cmqfwy4rv0018jv04jm3txu28	EARN	3	Earned from POS #13	2026-06-16 00:38:03.691	cmq5wjkiw0000jy04p03a3vql	2028-06-16 00:38:03.683	cmqfwio8o0008l404j8o7uh0q
cmqfx2b6j000xl4049glujhmh	EARN	31	Earned from POS #2	2026-06-16 00:41:18.619	cmpzm4vyo0000jv04i6eeh20d	2028-06-16 00:41:18.613	cmqftvv5q0000ld0465xta0at
cmqg396bu000p3xzg385pv01g	EARN	3	ได้รับแต้มจากออเดอร์ #22	2026-06-16 03:34:36.301	cmpr50gby0000l204k4iyqunq	\N	cmqg38w9c000h3xzgdo8lcntj
cmqg41b9700113xzg7rbr7yi4	EARN	15	Earned from POS #37	2026-06-16 03:56:29.371	cmq7hdolg000klb04x9d9hye6	2028-06-16 03:56:28.147	cmq7hgfzy0000k00428coxwvj
cmqg41cha00133xzge5ink0eb	EARN	15	Earned from POS #33	2026-06-16 03:56:30.958	cmq7hdolg000klb04x9d9hye6	2028-06-16 03:56:29.37	cmq8y8txt0009l104g3kq58gy
cmqh935ck000cl804h4x1ypkc	EARN	11	ได้รับแต้มจากออเดอร์ #3	2026-06-16 23:05:39.285	cmpymupkz0000js04v26bxcpp	\N	cmqh935b80000l804xbwxz2my
cmqh9eh7a000cjp04srtraxw9	EARN	14	ได้รับแต้มจากออเดอร์ #4	2026-06-16 23:14:27.863	cmpymupkz0000js04v26bxcpp	\N	cmqh9eh620000jp048o3l9529
cmqh9ho2d0013jp04k7zhe4qv	EARN	20	ได้รับแต้มจากออเดอร์ #5	2026-06-16 23:16:56.724	cmqh9bzp90002jo04a1bozkv8	\N	cmqh9ho0j000djp04obkt4exl
cmqh9tjn90001jo040baas722	EARN	11	Earned from POS #3	2026-06-16 23:26:10.869	cmpymupkz0000js04v26bxcpp	2028-06-16 23:26:10.857	cmqh935b80000l804xbwxz2my
cmqhaojb10008l704tefkf0ha	EARN	5	ได้รับแต้มจากออเดอร์ #8	2026-06-16 23:50:16.741	cmpymupkz0000js04v26bxcpp	\N	cmqhaoj8s0000l704s2lnk9db
cmqhawp2j000il7045re07fks	EARN	5	Earned from POS #8	2026-06-16 23:56:37.484	cmpymupkz0000js04v26bxcpp	2028-06-16 23:56:37.477	cmqhaoj8s0000l704s2lnk9db
cmqhb2h3v000rl704y0hzevys	EARN	6	ได้รับแต้มจากออเดอร์ #12	2026-06-17 00:01:07.098	cmpymupkz0000js04v26bxcpp	\N	cmqhb2h2t000jl7049fgs758z
cmqhb61ua0009kz0474uk3j5w	EARN	14	Earned from POS #4	2026-06-17 00:03:53.938	cmpymupkz0000js04v26bxcpp	2028-06-17 00:03:53.931	cmqh9eh620000jp048o3l9529
cmqhb64y5000ikz04i4e6saxn	EARN	5	ได้รับแต้มจากออเดอร์ #13	2026-06-17 00:03:57.965	cmpymupkz0000js04v26bxcpp	\N	cmqhb64x0000akz04r3pajxy3
cmqhb97rf0007jr045iczhlty	EARN	3	ได้รับแต้มจากออเดอร์ #14	2026-06-17 00:06:21.555	cmqhb2kc7000sl704mpvec7wu	\N	cmqhb97pr0000jr04pubtyqr2
cmqhbbsls000ijr049ytk0skp	EARN	5	Earned from POS #13	2026-06-17 00:08:21.904	cmpymupkz0000js04v26bxcpp	2028-06-17 00:08:21.9	cmqhb64x0000akz04r3pajxy3
cmqhc41hz001ala04fkdt1tc2	EARN	20	Earned from POS #5	2026-06-17 00:30:19.8	cmqh9bzp90002jo04a1bozkv8	2028-06-17 00:30:19.793	cmqh9ho0j000djp04obkt4exl
cmqhcd4i4001ela04q84mlhqr	EARN	6	Earned from POS #12	2026-06-17 00:37:23.597	cmpymupkz0000js04v26bxcpp	2028-06-17 00:37:23.59	cmqhb2h2t000jl7049fgs758z
cmqhcogrc0009kz04uvlmq8rw	EARN	3	Earned from POS #14	2026-06-17 00:46:12.697	cmqhb2kc7000sl704mpvec7wu	2028-06-17 00:46:12.69	cmqhb97pr0000jr04pubtyqr2
cmqinyz1g000ljy04rdmoi2ag	EARN	25	ได้รับแต้มจากออเดอร์ #1	2026-06-17 22:50:04.875	cmpymupkz0000js04v26bxcpp	\N	cmqinyyyb0000jy040wi1ntt0
cmqiptf6r0008l804c763w2mi	EARN	5	ได้รับแต้มจากออเดอร์ #4	2026-06-17 23:41:45.105	cmpymupkz0000js04v26bxcpp	\N	cmqiptf510000l804u5anuxp0
cmqipvzh00001jx04ik1jal8i	EARN	25	Earned from POS #1	2026-06-17 23:43:44.724	cmpymupkz0000js04v26bxcpp	2028-06-17 23:43:44.717	cmqinyyyb0000jy040wi1ntt0
cmqipw8o60008lb04mun1ae3t	EARN	4	ได้รับแต้มจากออเดอร์ #5	2026-06-17 23:43:56.62	cmqhb2kc7000sl704mpvec7wu	\N	cmqipw8mg0000lb04vnkmt0cf
cmqipzgc5000hlb04qr5p5ubj	EARN	6	ได้รับแต้มจากออเดอร์ #6	2026-06-17 23:46:26.547	cmpymupkz0000js04v26bxcpp	\N	cmqipzgaz0009lb04c6nyrs81
cmqiqbuc9000jlb040prk2o7i	EARN	5	Earned from POS #4	2026-06-17 23:56:04.569	cmpymupkz0000js04v26bxcpp	2028-06-17 23:56:04.561	cmqiptf510000l804u5anuxp0
cmqiqib5j000al104zfyyf4n0	EARN	6	ได้รับแต้มจากออเดอร์ #8	2026-06-18 00:01:06.292	cmpymupkz0000js04v26bxcpp	\N	cmqiqib4d0002l10492bxht9b
cmqiqn37w0001l304s74a67q6	EARN	6	Earned from POS #6	2026-06-18 00:04:49.293	cmpymupkz0000js04v26bxcpp	2028-06-18 00:04:49.285	cmqipzgaz0009lb04c6nyrs81
cmqirdadz000kl104ikldl0ww	EARN	6	Earned from POS #8	2026-06-18 00:25:11.64	cmpymupkz0000js04v26bxcpp	2028-06-18 00:25:11.627	cmqiqib4d0002l10492bxht9b
cmqis6iwx001cl704qs7ajskz	EARN	4	Earned from POS #5	2026-06-18 00:47:55.714	cmqhb2kc7000sl704mpvec7wu	2028-06-18 00:47:55.708	cmqipw8mg0000lb04vnkmt0cf
cmqk4r4ba000jky04ggip0hqq	EARN	26	ได้รับแต้มจากออเดอร์ #1	2026-06-18 23:27:38.098	cmpymupkz0000js04v26bxcpp	\N	cmqk4r47y0000ky045yngfa64
cmqk5ebm90001jo04sptllidq	EARN	26	Earned from POS #1	2026-06-18 23:45:40.689	cmpymupkz0000js04v26bxcpp	2028-06-18 23:45:40.684	cmqk4r47y0000ky045yngfa64
cmqk5qunz0008l204p51xgkmy	EARN	4	ได้รับแต้มจากออเดอร์ #4	2026-06-18 23:55:25.221	cmqhb2kc7000sl704mpvec7wu	\N	cmqk5qumb0000l204186dfqh5
cmqk6blps0009la0459igxv0w	EARN	7	ได้รับแต้มจากออเดอร์ #12	2026-06-19 00:11:33.422	cmqh9bzp90002jo04a1bozkv8	\N	cmqk6blov0000la04xzyiq4e3
cmqk6cn9r000hla044hx4sui2	EARN	3	ได้รับแต้มจากออเดอร์ #13	2026-06-19 00:12:22.066	cmqiqhmsp0001l104ukcdhhbl	\N	cmqk6cn84000ala04yst74y29
cmqk6qp5b0016la045r2np52d	EARN	3	Earned from POS #13	2026-06-19 00:23:17.712	cmqiqhmsp0001l104ukcdhhbl	2028-06-19 00:23:17.704	cmqk6cn84000ala04yst74y29
cmqk70v7m001nla04b25ota4b	EARN	7	Earned from POS #12	2026-06-19 00:31:12.13	cmqh9bzp90002jo04a1bozkv8	2028-06-19 00:31:12.123	cmqk6blov0000la04xzyiq4e3
cmqk7mghf001yla04o2vy56al	EARN	4	Earned from POS #4	2026-06-19 00:47:59.476	cmqhb2kc7000sl704mpvec7wu	2028-06-19 00:47:59.47	cmqk5qumb0000l204186dfqh5
cmqljgn46000pl204i6vwj9o9	EARN	33	ได้รับแต้มจากออเดอร์ #1	2026-06-19 23:07:09.703	cmpymupkz0000js04v26bxcpp	\N	cmqljgn1b0000l204wpqepccy
cmqlk4vjy000jl304dzalpjsy	EARN	21	ได้รับแต้มจากออเดอร์ #3	2026-06-19 23:26:00.374	cmpzm4vyo0000jv04i6eeh20d	\N	cmqlk4vhi0000l304nax96eh9
cmqlknp960001js04uetyl7wt	EARN	33	Earned from POS #1	2026-06-19 23:40:38.683	cmpymupkz0000js04v26bxcpp	2028-06-19 23:40:38.668	cmqljgn1b0000l204wpqepccy
cmqlloohl001yjs04fpdg4bot	EARN	3	ได้รับแต้มจากออเดอร์ #11	2026-06-20 00:09:23.959	cmqiqhmsp0001l104ukcdhhbl	\N	cmqlloogx001qjs04kgxwn7kt
cmqllptrp000zl4048difg1ue	EARN	3	ได้รับแต้มจากออเดอร์ #13	2026-06-20 00:10:17.46	cmqiqhmsp0001l104ukcdhhbl	\N	cmqllptqx000rl404wdf3dtc8
cmqlmbdbi000hl504dy1sx8s5	EARN	6	ได้รับแต้มจากออเดอร์ #19	2026-06-20 00:27:02.573	cmpymupkz0000js04v26bxcpp	\N	cmqlmbdat0009l504qxa4xp32
cmqlmj1n30001jy04j5rpwdu2	EARN	21	Earned from POS #3	2026-06-20 00:33:00.688	cmpzm4vyo0000jv04i6eeh20d	2028-06-20 00:33:00.682	cmqlk4vhi0000l304nax96eh9
cmqlmk032000bjy049mmp81jm	EARN	3	Earned from POS #13	2026-06-20 00:33:45.327	cmqiqhmsp0001l104ukcdhhbl	2028-06-20 00:33:45.323	cmqllptqx000rl404wdf3dtc8
cmqlmkzgb000tjy040xjrss2d	EARN	5	ได้รับแต้มจากออเดอร์ #24	2026-06-20 00:34:31.162	cmpymupkz0000js04v26bxcpp	\N	cmqlmkzfk000ljy04jswpjv5w
cmqlmyb6l002il404fzfz7943	EARN	6	Earned from POS #19	2026-06-20 00:44:52.893	cmpymupkz0000js04v26bxcpp	2028-06-20 00:44:52.888	cmqlmbdat0009l504qxa4xp32
cmqln1mx1000tl504pda49cms	EARN	5	Earned from POS #24	2026-06-20 00:47:28.07	cmpymupkz0000js04v26bxcpp	2028-06-20 00:47:28.063	cmqlmkzfk000ljy04jswpjv5w
cmqof8n3k0008l404lswhlcp6	EARN	3	ได้รับแต้มจากออเดอร์ #1	2026-06-21 23:32:16.471	cmpqxi3y80000jv042tmuxldv	\N	cmqof8n1e0000l404yvrkazxb
cmqoflmzi000kjr04ynwunqd5	EARN	5	ได้รับแต้มจากออเดอร์ #3	2026-06-21 23:42:22.876	cmpymupkz0000js04v26bxcpp	\N	cmqoflmyx000cjr04qwjjjbtc
cmqofs3xi000mjr043ap3il86	EARN	5	Earned from POS #3	2026-06-21 23:47:24.774	cmpymupkz0000js04v26bxcpp	2028-06-21 23:47:24.767	cmqoflmyx000cjr04qwjjjbtc
cmqofxptd0009l204rwv3htsh	EARN	3	ได้รับแต้มจากออเดอร์ #4	2026-06-21 23:51:46.417	cmqhb2kc7000sl704mpvec7wu	\N	cmqofxpsi0000l204o4q86h6l
cmqoh4abk0027l204ff2qgs6s	EARN	5	ได้รับแต้มจากออเดอร์ #18	2026-06-22 00:24:52.544	cmpymupkz0000js04v26bxcpp	\N	cmqoh4aau001zl204bxm2k34i
cmqoh5bmt0008l504jwnng37w	EARN	6	ได้รับแต้มจากออเดอร์ #19	2026-06-22 00:25:40.901	cmpymupkz0000js04v26bxcpp	\N	cmqoh5bly0000l5046a55usxi
cmqoheaxm000cl5045ua570k2	EARN	5	Earned from POS #18	2026-06-22 00:32:39.898	cmpymupkz0000js04v26bxcpp	2028-06-22 00:32:39.891	cmqoh4aau001zl204bxm2k34i
cmqohmm4u002ml204vfcpdopw	EARN	6	Earned from POS #19	2026-06-22 00:39:07.663	cmpymupkz0000js04v26bxcpp	2028-06-22 00:39:07.657	cmqoh5bly0000l5046a55usxi
cmqohyk8o0037l204rvmau8ko	EARN	3	Earned from POS #4	2026-06-22 00:48:25.08	cmqhb2kc7000sl704mpvec7wu	2028-06-22 00:48:25.074	cmqofxpsi0000l204o4q86h6l
cmqpv35zi000hkz04414nnwf0	EARN	18	ได้รับแต้มจากออเดอร์ #3	2026-06-22 23:43:41.07	cmpymupkz0000js04v26bxcpp	\N	cmqpv35yh0000kz04dyg19g6x
cmqpvrsr80009kz04hdi1xti3	EARN	3	ได้รับแต้มจากออเดอร์ #6	2026-06-23 00:02:50.324	cmqhb2kc7000sl704mpvec7wu	\N	cmqpvrsq50000kz04fyrrw3hs
cmqpw24nu000qjl04mxom7oh6	EARN	18	Earned from POS #3	2026-06-23 00:10:52.314	cmpymupkz0000js04v26bxcpp	2028-06-23 00:10:52.307	cmqpv35yh0000kz04dyg19g6x
cmqpweruc000rld042zzjp1j8	EARN	9	ได้รับแต้มจากออเดอร์ #11	2026-06-23 00:20:42.228	cmpymupkz0000js04v26bxcpp	\N	cmqpwertx000hld0461x1ia2y
cmqpwi18c0007jf04tntvt4up	EARN	9	Earned from POS #11	2026-06-23 00:23:14.364	cmpymupkz0000js04v26bxcpp	2028-06-23 00:23:14.358	cmqpwertx000hld0461x1ia2y
cmqpxdq16000pjf0415uomhzo	EARN	3	Earned from POS #6	2026-06-23 00:47:52.842	cmqhb2kc7000sl704mpvec7wu	2028-06-23 00:47:52.836	cmqpvrsq50000kz04fyrrw3hs
cmqq6nk9q000cl204hzr5vw1y	EARN	7	ได้รับแต้มจากออเดอร์ #27	2026-06-23 05:07:28.479	cmqomlong0000jo04nvihswtt	\N	cmqq6nk7f0000l2048tsin8h5
cmqq71n80000cjy04nd7vfsaz	EARN	7	Earned from POS #27	2026-06-23 05:18:25.488	cmqomlong0000jo04nvihswtt	2028-06-23 05:18:25.482	cmqq6nk7f0000l2048tsin8h5
cmqq7linn000flb04y73r0y6s	EARN	25	ได้รับแต้มจากออเดอร์ #31	2026-06-23 05:33:52.664	cmqlxu95y0000lh04zmipokf0	\N	cmqq7lilr0000lb0499saxfh7
cmqq8nmmk0001l204gzd85jqf	EARN	25	Earned from POS #31	2026-06-23 06:03:30.764	cmqlxu95y0000lh04zmipokf0	2028-06-23 06:03:30.75	cmqq7lilr0000lb0499saxfh7
cmqq8nmny0003l2046j1flpcr	EARN	25	Earned from POS #31	2026-06-23 06:03:30.815	cmqlxu95y0000lh04zmipokf0	2028-06-23 06:03:30.809	cmqq7lilr0000lb0499saxfh7
cmqq965l8000mlb04d0twk6so	EARN	3	ได้รับแต้มจากออเดอร์ #35	2026-06-23 06:17:55.146	cmqq92kxf0000jr047jszj64u	\N	cmqq965hx000flb04hp5wfoxc
cmqq96juh000olb044jhm4r1s	EARN	3	Earned from POS #35	2026-06-23 06:18:13.626	cmqq92kxf0000jr047jszj64u	2028-06-23 06:18:13.621	cmqq965hx000flb04hp5wfoxc
cmqra6zrn0009jo048olx3g02	EARN	6	ได้รับแต้มจากออเดอร์ #1	2026-06-23 23:34:20.052	cmpymupkz0000js04v26bxcpp	\N	cmqra6zq80000jo046ttet8qg
cmqra8rkz000hjo04k6phmpek	EARN	4	ได้รับแต้มจากออเดอร์ #2	2026-06-23 23:35:42.754	cmpr50gby0000l204k4iyqunq	\N	cmqra8rjw000ajo04wyg1h3yy
cmqrani5s0008kz04ranadn59	EARN	4	Earned from POS #2	2026-06-23 23:47:10.385	cmpr50gby0000l204k4iyqunq	2028-06-23 23:47:10.375	cmqra8rjw000ajo04wyg1h3yy
cmqravt650009jr04ex6g3u0v	EARN	3	ได้รับแต้มจากออเดอร์ #6	2026-06-23 23:53:37.885	cmqhb2kc7000sl704mpvec7wu	\N	cmqravt500000jr04fwnwafc0
cmqrbeabw0008jo041qtrx55u	EARN	6	Earned from POS #1	2026-06-24 00:07:59.949	cmpymupkz0000js04v26bxcpp	2028-06-24 00:07:59.942	cmqra6zq80000jo046ttet8qg
cmqrc41p70008i304zepgm8lk	EARN	5	ได้รับแต้มจากออเดอร์ #13	2026-06-24 00:28:01.793	cmpymupkz0000js04v26bxcpp	\N	cmqrc41nl0000i304fvg1607m
cmqrc8fie0008jm04xw77deqi	EARN	6	ได้รับแต้มจากออเดอร์ #16	2026-06-24 00:31:26.323	cmpymupkz0000js04v26bxcpp	\N	cmqrc8fgt0000jm043jieno7v
cmqrcld54000aic04feiqlr7y	EARN	5	Earned from POS #13	2026-06-24 00:41:29.801	cmpymupkz0000js04v26bxcpp	2028-06-24 00:41:29.79	cmqrc41nl0000i304fvg1607m
cmqrclehn000cic04tlgvvah7	EARN	6	Earned from POS #16	2026-06-24 00:41:31.547	cmpymupkz0000js04v26bxcpp	2028-06-24 00:41:31.54	cmqrc8fgt0000jm043jieno7v
cmqrd49gv000ejy04gn8cm3ot	EARN	3	Earned from POS #6	2026-06-24 00:56:11.503	cmqhb2kc7000sl704mpvec7wu	2028-06-24 00:56:11.492	cmqravt500000jr04fwnwafc0
cmqrlgt9w0007jp040fpo4x41	EARN	3	ได้รับแต้มจากออเดอร์ #32	2026-06-24 04:49:53.949	cmqkghrt00000l704omhsxuo1	\N	cmqrlgt5d0000jp04txv6klq2
cmqrlnl16000clb04881y3n1a	EARN	8	ได้รับแต้มจากออเดอร์ #33	2026-06-24 04:55:09.882	cmqomlong0000jo04nvihswtt	\N	cmqrlnkzu0000lb04l5awr2va
cmqrluq510005ic04t0pwjhhh	EARN	2	Earned from POS #32	2026-06-24 05:00:43.093	cmqkghrt00000l704omhsxuo1	2028-06-24 05:00:43.087	cmqrlgt5d0000jp04txv6klq2
cmqrm35220007ic04zln3dbno	EARN	8	Earned from POS #33	2026-06-24 05:07:15.675	cmqomlong0000jo04nvihswtt	2028-06-24 05:07:15.668	cmqrlnkzu0000lb04l5awr2va
cmqrmngst001flb04t1wr8h03	EARN	31	ได้รับแต้มจากออเดอร์ #37	2026-06-24 05:23:04.012	cmqlxu95y0000lh04zmipokf0	\N	cmqrmngr0000vlb04rbad8inm
cmqro0ind0001jj04rckpc8dw	EARN	31	Earned from POS #37	2026-06-24 06:01:12.554	cmqlxu95y0000lh04zmipokf0	2028-06-24 06:01:12.527	cmqrmngr0000vlb04rbad8inm
cmqsopglu000hl404g9lwm52l	EARN	18	ได้รับแต้มจากออเดอร์ #1	2026-06-24 23:08:22.483	cmpymupkz0000js04v26bxcpp	\N	cmqsopgjq0000l404rp3y2vou
cmqspagsv0009jr04gbkpcflj	EARN	10	ได้รับแต้มจากออเดอร์ #2	2026-06-24 23:24:42.511	cmpymupkz0000js04v26bxcpp	\N	cmqspagr00000jr04wv487qjo
cmqsphawr0001js047c7o8jff	EARN	18	Earned from POS #1	2026-06-24 23:30:01.468	cmpymupkz0000js04v26bxcpp	2028-06-24 23:30:01.462	cmqsopgjq0000l404rp3y2vou
cmqspmxmp0003js04binbjsf8	EARN	10	Earned from POS #2	2026-06-24 23:34:24.193	cmpymupkz0000js04v26bxcpp	2028-06-24 23:34:24.186	cmqspagr00000jr04wv487qjo
cmqspwbc9000rjs0474nd2y65	EARN	17	ได้รับแต้มจากออเดอร์ #4	2026-06-24 23:41:41.863	cmqfwfly2000xjv048t8vu8hk	\N	cmqspwbay0004js04g2lmr5jc
cmqsqb9sj0008l504qx8c19bb	EARN	4	ได้รับแต้มจากออเดอร์ #5	2026-06-24 23:53:19.696	cmqhb2kc7000sl704mpvec7wu	\N	cmqsqb9rd0000l504xxf1rosa
cmqsrfhd50025js04ahcao5uy	EARN	17	Earned from POS #4	2026-06-25 00:24:35.753	cmqfwfly2000xjv048t8vu8hk	2028-06-25 00:24:35.746	cmqspwbay0004js04g2lmr5jc
cmqsrwztm0008l50457sh9g81	EARN	5	ได้รับแต้มจากออเดอร์ #17	2026-06-25 00:38:12.79	cmpymupkz0000js04v26bxcpp	\N	cmqsrwzrq0000l5040gm3nkc8
cmqss1htd002jjs04i55v4h0t	EARN	5	Earned from POS #17	2026-06-25 00:41:42.769	cmpymupkz0000js04v26bxcpp	2028-06-25 00:41:42.762	cmqsrwzrq0000l5040gm3nkc8
cmqss6x7w002ujs04f424zaah	EARN	4	Earned from POS #5	2026-06-25 00:45:56.012	cmqhb2kc7000sl704mpvec7wu	2028-06-25 00:45:56.005	cmqsqb9rd0000l504xxf1rosa
cmqsymh1c0008le046ye0wea6	EARN	6	ได้รับแต้มจากออเดอร์ #28	2026-06-25 03:45:59.232	cmqkghrt00000l704omhsxuo1	\N	cmqsymgxl0000le04e1apu8b2
cmqt160ds0008l504rjysz0st	EARN	8	ได้รับแต้มจากออเดอร์ #30	2026-06-25 04:57:10	cmqomlong0000jo04nvihswtt	\N	cmqt160cf0000l504vdkn128n
cmqt1d9a70008l70451rio6uc	EARN	6	Earned from POS #28	2026-06-25 05:02:48.128	cmqkghrt00000l704omhsxuo1	2028-06-25 05:02:48.122	cmqsymgxl0000le04e1apu8b2
cmqt1mg9z000cl7046mf7nu9z	EARN	8	Earned from POS #30	2026-06-25 05:09:57.095	cmqomlong0000jo04nvihswtt	2028-06-25 05:09:57.087	cmqt160cf0000l504vdkn128n
cmqtj9ua600083xqfpkhy9wx6	EARN	3	ได้รับแต้มจากออเดอร์ #1	2026-06-25 13:23:59.659	cmpr50gby0000l204k4iyqunq	\N	cmqtj9p2i00003xqf43kb9wo4
cmqu5bmoe000ajs04iao021pw	EARN	9	ได้รับแต้มจากออเดอร์ #3	2026-06-25 23:41:16.814	cmpymupkz0000js04v26bxcpp	\N	cmqu5bmn80000js047iejoava
cmqu5ov60000sl2046lrsqxz9	EARN	22	ได้รับแต้มจากออเดอร์ #4	2026-06-25 23:51:34.344	cmqfwfly2000xjv048t8vu8hk	\N	cmqu5ov4b0000l2046p93napv
cmqu5ph6g001ll204wqcf5ye3	EARN	22	ได้รับแต้มจากออเดอร์ #5	2026-06-25 23:52:02.87	cmqfwfly2000xjv048t8vu8hk	\N	cmqu5ph4u000tl204qbuj1d31
cmqu5tkxg000cjs04pd49v26k	EARN	3	Earned from POS #1	2026-06-25 23:55:14.356	cmpr50gby0000l204k4iyqunq	2028-06-25 23:55:14.35	cmqtj9p2i00003xqf43kb9wo4
cmqu62d7l002hl204kn55383w	EARN	9	Earned from POS #3	2026-06-26 00:02:04.258	cmpymupkz0000js04v26bxcpp	2028-06-26 00:02:04.25	cmqu5bmn80000js047iejoava
cmqu675z2000ajl04xtk4vexm	EARN	4	ได้รับแต้มจากออเดอร์ #10	2026-06-26 00:05:48.133	cmqhb2kc7000sl704mpvec7wu	\N	cmqu675xn0000jl04uptlngix
cmqu6frx1000hl805s76ad5w8	EARN	5	ได้รับแต้มจากออเดอร์ #14	2026-06-26 00:12:29.843	cmpymupkz0000js04v26bxcpp	\N	cmqu6frwa0009l805c8bbgv7j
cmqu77mns000wle04aed30hb9	EARN	22	Earned from POS #4	2026-06-26 00:34:09.4	cmqfwfly2000xjv048t8vu8hk	2028-06-26 00:34:09.387	cmqu5ov4b0000l2046p93napv
cmqu7hue10010le04vjc2ixbw	EARN	5	Earned from POS #14	2026-06-26 00:42:05.977	cmpymupkz0000js04v26bxcpp	2028-06-26 00:42:05.972	cmqu6frwa0009l805c8bbgv7j
cmqu7xvdb0019ld04ms860l9c	EARN	4	Earned from POS #10	2026-06-26 00:54:33.744	cmqhb2kc7000sl704mpvec7wu	2028-06-26 00:54:33.737	cmqu675xn0000jl04uptlngix
cmquc8upc000jju04dbgnla5y	EARN	11	ได้รับแต้มจากออเดอร์ #28	2026-06-26 02:55:04.527	cmq7hdolg000klb04x9d9hye6	\N	cmquc8umj0002ju04vd21peyy
cmqucngn70001lb04zm3yfooi	EARN	11	Earned from POS #28	2026-06-26 03:06:26.18	cmq7hdolg000klb04x9d9hye6	2028-06-26 03:06:26.165	cmquc8umj0002ju04vd21peyy
cmqvky3b1000hjv04z08z590b	EARN	18	ได้รับแต้มจากออเดอร์ #3	2026-06-26 23:46:25.187	cmpymupkz0000js04v26bxcpp	\N	cmqvky38n0000jv04kb6dkv59
cmqvlh5g80008kt04iiser4ld	EARN	3	ได้รับแต้มจากออเดอร์ #4	2026-06-27 00:01:14.456	cmqiqhmsp0001l104ukcdhhbl	\N	cmqvlh5e20000kt047pb74whb
cmqvlpbuz000tky04otkzh41k	EARN	4	ได้รับแต้มจากออเดอร์ #9	2026-06-27 00:07:36.011	cmqhb2kc7000sl704mpvec7wu	\N	cmqvlpbty000kky04pk9aro6k
cmqvlt1lk0018ky046j83kp04	EARN	13	ได้รับแต้มจากออเดอร์ #10	2026-06-27 00:10:29.336	cmpzm4vyo0000jv04i6eeh20d	\N	cmqvlt1ke000uky04g29ikceg
cmqvlu8nj001cky04w92dfkg2	EARN	3	Earned from POS #4	2026-06-27 00:11:25.135	cmqiqhmsp0001l104ukcdhhbl	2028-06-27 00:11:25.129	cmqvlh5e20000kt047pb74whb
cmqvludqu001eky045r3d0dad	EARN	16	Earned from POS #3	2026-06-27 00:11:31.734	cmpymupkz0000js04v26bxcpp	2028-06-27 00:11:31.729	cmqvky38n0000jv04kb6dkv59
cmqvlwhyq000hjs04q0i8jhko	EARN	5	ได้รับแต้มจากออเดอร์ #11	2026-06-27 00:13:10.49	cmpymupkz0000js04v26bxcpp	\N	cmqvlwhwu0009js04kjz4nt37
cmqvma0ph000rjs04dhpho34e	EARN	5	Earned from POS #11	2026-06-27 00:23:41.333	cmpymupkz0000js04v26bxcpp	2028-06-27 00:23:41.325	cmqvlwhwu0009js04kjz4nt37
cmqvminan0007l804pdedjpnc	EARN	6	ได้รับแต้มจากออเดอร์ #14	2026-06-27 00:30:23.829	cmpymupkz0000js04v26bxcpp	\N	cmqvmin8o0000l804spujq9oh
cmqvn27s8001dl504lk6dalq0	EARN	6	Earned from POS #14	2026-06-27 00:45:36.872	cmpymupkz0000js04v26bxcpp	2028-06-27 00:45:36.866	cmqvmin8o0000l804spujq9oh
cmqvn6fpu0012js04botnm4gl	EARN	4	Earned from POS #9	2026-06-27 00:48:53.779	cmqhb2kc7000sl704mpvec7wu	2028-06-27 00:48:53.771	cmqvlpbty000kky04pk9aro6k
cmqvncjxl0018js04tl2g7sn7	EARN	13	Earned from POS #10	2026-06-27 00:53:39.178	cmpzm4vyo0000jv04i6eeh20d	2028-06-27 00:53:39.171	cmqvlt1ke000uky04g29ikceg
cmqvtjuc90007jm041imo567f	EARN	3	ได้รับแต้มจากออเดอร์ #27	2026-06-27 03:47:16.925	cmqkghrt00000l704omhsxuo1	\N	cmqvtju9w0000jm04ug3a25pj
cmqvvczqf0008l104xn9jvwvn	EARN	4	ได้รับแต้มจากออเดอร์ #28	2026-06-27 04:37:56.581	cmqomlong0000jo04nvihswtt	\N	cmqvvczoc0000l104ibzig4ya
cmqvwh7iz0005lb04x2sw9fe5	EARN	4	Earned from POS #28	2026-06-27 05:09:12.923	cmqomlong0000jo04nvihswtt	2028-06-27 05:09:12.914	cmqvvczoc0000l104ibzig4ya
cmqvwh7yd0007lb04qkkl8e4d	EARN	3	Earned from POS #27	2026-06-27 05:09:13.477	cmqkghrt00000l704omhsxuo1	2028-06-27 05:09:13.473	cmqvtju9w0000jm04ug3a25pj
cmqyf83hy000gjo04nfn0o3sx	EARN	16	ได้รับแต้มจากออเดอร์ #1	2026-06-28 23:29:32.855	cmpymupkz0000js04v26bxcpp	\N	cmqyf83fy0000jo04udtgo417
cmqyfrmsn0009jl04gnaw3w1x	EARN	3	ได้รับแต้มจากออเดอร์ #3	2026-06-28 23:44:44.295	cmqhb2kc7000sl704mpvec7wu	\N	cmqyfrmqz0000jl043dbmovp4
cmqyfuaw4000jjl049syd2jnr	EARN	6	ได้รับแต้มจากออเดอร์ #4	2026-06-28 23:46:48.868	cmpymupkz0000js04v26bxcpp	\N	cmqyfuauz000ajl04jm0rhham
cmqyg2165000ajl040pxl2b35	EARN	16	Earned from POS #1	2026-06-28 23:52:49.517	cmpymupkz0000js04v26bxcpp	2028-06-28 23:52:49.512	cmqyf83fy0000jo04udtgo417
cmqyg4l720007lb04h1vx7l74	EARN	6	Earned from POS #4	2026-06-28 23:54:48.782	cmpymupkz0000js04v26bxcpp	2028-06-28 23:54:48.775	cmqyfuauz000ajl04jm0rhham
cmqyi6b3t000ojl042t23q2w9	EARN	3	Earned from POS #3	2026-06-29 00:52:08.25	cmqhb2kc7000sl704mpvec7wu	2028-06-29 00:52:08.243	cmqyfrmqz0000jl043dbmovp4
cmqzu6243000hjn04szoar2y7	EARN	14	ได้รับแต้มจากออเดอร์ #1	2026-06-29 23:15:38.141	cmqyznxcy0000jo0477ol00sq	\N	cmqzu62160000jn04v7d8urqd
cmqzu88hr000sjn04loodilvf	EARN	8	ได้รับแต้มจากออเดอร์ #2	2026-06-29 23:17:19.741	cmpymupkz0000js04v26bxcpp	\N	cmqzu88gj000ijn04pahaail0
cmqzunydi000ql50482uk039t	EARN	15	ได้รับแต้มจากออเดอร์ #3	2026-06-29 23:29:33.127	cmqzu4sql0000l504bnw2yan4	\N	cmqzunybb0001l504m2hke39o
cmqzvnxc6000il7046ev7v8yz	EARN	6	ได้รับแต้มจากออเดอร์ #5	2026-06-29 23:57:31.366	cmpymupkz0000js04v26bxcpp	\N	cmqzvnxad000al704oapxd2t8
cmqzvrvp70008k104uyxpmh3j	EARN	5	ได้รับแต้มจากออเดอร์ #7	2026-06-30 00:00:35.875	cmpymupkz0000js04v26bxcpp	\N	cmqzvrvno0000k1046rg92011
cmqzw02mo0009l204n78bmq0y	EARN	3	ได้รับแต้มจากออเดอร์ #10	2026-06-30 00:06:58.104	cmqhb2kc7000sl704mpvec7wu	\N	cmqzw02l10000l204fi314iya
cmqzw0kdm0008ju04tq0jj9w6	EARN	3	ได้รับแต้มจากออเดอร์ #11	2026-06-30 00:07:21.13	cmqiqhmsp0001l104ukcdhhbl	\N	cmqzw0kco0000ju044iic57q3
cmqzwlqpi0008l2045whq4d7r	EARN	5	ได้รับแต้มจากออเดอร์ #13	2026-06-30 00:23:49.11	cmpymupkz0000js04v26bxcpp	\N	cmqzwlqo40000l2046fbrbgqb
cmqzwnafl0005l204ugvo8au5	EARN	6	Earned from POS #5	2026-06-30 00:25:01.329	cmpymupkz0000js04v26bxcpp	2028-06-30 00:25:01.32	cmqzvnxad000al704oapxd2t8
cmqzwq0i40007l2043sd5r1au	EARN	5	Earned from POS #7	2026-06-30 00:27:08.429	cmpymupkz0000js04v26bxcpp	2028-06-30 00:27:08.424	cmqzvrvno0000k1046rg92011
cmqzwu9fk000nl2048x2hiov0	EARN	15	Earned from POS #3	2026-06-30 00:30:26.624	cmqzu4sql0000l504bnw2yan4	2028-06-30 00:30:26.616	cmqzunybb0001l504m2hke39o
cmqzwue18000pl2044ct1lpd9	EARN	14	Earned from POS #1	2026-06-30 00:30:32.589	cmqyznxcy0000jo0477ol00sq	2028-06-30 00:30:32.583	cmqzu62160000jn04v7d8urqd
cmqzwv2e10014l2048z5ueqw8	EARN	3	Earned from POS #11	2026-06-30 00:31:04.154	cmqiqhmsp0001l104ukcdhhbl	2028-06-30 00:31:04.149	cmqzw0kco0000ju044iic57q3
cmqzwv3g30016l204gbmosfva	EARN	8	Earned from POS #2	2026-06-30 00:31:05.524	cmpymupkz0000js04v26bxcpp	2028-06-30 00:31:05.518	cmqzu88gj000ijn04pahaail0
cmqzxelg3001ul2044vekr0oo	EARN	3	Earned from POS #10	2026-06-30 00:46:15.316	cmqhb2kc7000sl704mpvec7wu	2028-06-30 00:46:15.308	cmqzw02l10000l204fi314iya
cmqzxjsjm002bl204sdqzjj14	EARN	5	Earned from POS #13	2026-06-30 00:50:17.794	cmpymupkz0000js04v26bxcpp	2028-06-30 00:50:17.79	cmqzwlqo40000l2046fbrbgqb
\.


--
-- Data for Name: product_option_groups; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.product_option_groups ("sortOrder", "productId", "optionGroupId") FROM stdin;
0	cmpqqm65m000q3xvow1n8n4d2	cmprak1wr000c3xj38au25c61
0	cmpqqm65m000q3xvow1n8n4d2	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm65m000q3xvow1n8n4d2	cmpraptea000n3xj3l9yv04bm
0	cmpqqm4l9000c3xvojqoj1yyt	cmpraghfn00083xj3mubzcis0
0	cmpqqm4l9000c3xvojqoj1yyt	cmprak1wr000c3xj38au25c61
0	cmpqqm4l9000c3xvojqoj1yyt	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm4l9000c3xvojqoj1yyt	cmpraptea000n3xj3l9yv04bm
0	cmpqqm4cx000a3xvo6ij5ksrm	cmprak1wr000c3xj38au25c61
0	cmpqqm4cx000a3xvo6ij5ksrm	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm4cx000a3xvo6ij5ksrm	cmpran7d3000k3xj3cddg18jm
0	cmpqqm4cx000a3xvo6ij5ksrm	cmpraptea000n3xj3l9yv04bm
0	cmpqqm45100083xvoo43pm2fa	cmprak1wr000c3xj38au25c61
0	cmpqqm45100083xvoo43pm2fa	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm45100083xvoo43pm2fa	cmpran7d3000k3xj3cddg18jm
0	cmpqqm45100083xvoo43pm2fa	cmpraptea000n3xj3l9yv04bm
0	cmpqqm3ot00063xvoeortkzib	cmprak1wr000c3xj38au25c61
0	cmpqqm3ot00063xvoeortkzib	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm3ot00063xvoeortkzib	cmpraptea000n3xj3l9yv04bm
0	cmpqqm6v9000w3xvoupr8eicc	cmpraghfn00083xj3mubzcis0
0	cmpqqmd4h002g3xvorpy8wab0	cmprak1wr000c3xj38au25c61
0	cmpqqmd4h002g3xvorpy8wab0	cmpraptea000n3xj3l9yv04bm
0	cmpqqmc1300263xvodgeiz5il	cmprak1wr000c3xj38au25c61
0	cmpqqmc1300263xvodgeiz5il	cmpraptea000n3xj3l9yv04bm
0	cmpqqmhq9003k3xvoadvnhwjy	cmpran7d3000k3xj3cddg18jm
0	cmpqqmhq9003k3xvoadvnhwjy	cmpraptea000n3xj3l9yv04bm
0	cmpqqmhie003i3xvoybyvebt7	cmpran7d3000k3xj3cddg18jm
0	cmpqqmhie003i3xvoybyvebt7	cmpraptea000n3xj3l9yv04bm
0	cmpqqmhah003g3xvocqzdccbj	cmpran7d3000k3xj3cddg18jm
0	cmpqqmhah003g3xvocqzdccbj	cmpraptea000n3xj3l9yv04bm
0	cmpqqmh2m003e3xvofpd1t1xp	cmpran7d3000k3xj3cddg18jm
0	cmpqqmh2m003e3xvofpd1t1xp	cmpraptea000n3xj3l9yv04bm
0	cmpqqmguq003c3xvobz35z24l	cmpran7d3000k3xj3cddg18jm
0	cmpqqmguq003c3xvobz35z24l	cmpraptea000n3xj3l9yv04bm
0	cmpqqmgmt003a3xvofi0j1ugq	cmpran7d3000k3xj3cddg18jm
0	cmpqqmgmt003a3xvofi0j1ugq	cmpraptea000n3xj3l9yv04bm
0	cmpqqmgex00383xvonmxflp92	cmpran7d3000k3xj3cddg18jm
0	cmpqqmgex00383xvonmxflp92	cmpraptea000n3xj3l9yv04bm
0	cmpqqmg7200363xvo3gkl3mbk	cmpran7d3000k3xj3cddg18jm
0	cmpqqmg7200363xvo3gkl3mbk	cmpraptea000n3xj3l9yv04bm
0	cmpqqmfz700343xvogibx6w25	cmpran7d3000k3xj3cddg18jm
0	cmpqqmfz700343xvogibx6w25	cmpraptea000n3xj3l9yv04bm
0	cmpqqmfrb00323xvok639ez5v	cmpran7d3000k3xj3cddg18jm
0	cmpqqmfrb00323xvok639ez5v	cmpraptea000n3xj3l9yv04bm
0	cmpqqmfjf00303xvou7ww0eba	cmpran7d3000k3xj3cddg18jm
0	cmpqqmfjf00303xvou7ww0eba	cmpraptea000n3xj3l9yv04bm
0	cmpqqmevt002u3xvo4bwqom23	cmpran7d3000k3xj3cddg18jm
0	cmpqqmevt002u3xvo4bwqom23	cmpraptea000n3xj3l9yv04bm
0	cmpqqmfbk002y3xvosi99u8ry	cmpran7d3000k3xj3cddg18jm
0	cmpqqmfbk002y3xvosi99u8ry	cmpraptea000n3xj3l9yv04bm
0	cmpqqmenx002s3xvozyfrvjck	cmpran7d3000k3xj3cddg18jm
0	cmpqqmenx002s3xvozyfrvjck	cmpraptea000n3xj3l9yv04bm
0	cmpqqmeg2002q3xvorgtl69w5	cmpran7d3000k3xj3cddg18jm
0	cmpqqmeg2002q3xvorgtl69w5	cmpraptea000n3xj3l9yv04bm
0	cmpqqme85002o3xvonvhpgw36	cmpran7d3000k3xj3cddg18jm
0	cmpqqme85002o3xvonvhpgw36	cmpraptea000n3xj3l9yv04bm
0	cmprex2q00001kt044kgwxhj2	cmpran7d3000k3xj3cddg18jm
0	cmprex2q00001kt044kgwxhj2	cmpraptea000n3xj3l9yv04bm
0	cmpresqx90001l70436g0jlwu	cmprak1wr000c3xj38au25c61
0	cmpresqx90001l70436g0jlwu	cmpraptea000n3xj3l9yv04bm
0	cmpqqmaps001u3xvo1w0msnzw	cmprak1wr000c3xj38au25c61
0	cmpqqmaps001u3xvo1w0msnzw	cmpran7d3000k3xj3cddg18jm
0	cmpqqmaps001u3xvo1w0msnzw	cmpraptea000n3xj3l9yv04bm
0	cmpqqmahy001s3xvoh9qjvokp	cmprak1wr000c3xj38au25c61
0	cmpqqmahy001s3xvoh9qjvokp	cmpran7d3000k3xj3cddg18jm
0	cmpqqmahy001s3xvoh9qjvokp	cmpraptea000n3xj3l9yv04bm
0	cmpqqma9x001q3xvo0d6239vc	cmprak1wr000c3xj38au25c61
0	cmpqqma9x001q3xvo0d6239vc	cmpran7d3000k3xj3cddg18jm
0	cmpqqma9x001q3xvo0d6239vc	cmpraptea000n3xj3l9yv04bm
0	cmpqqma23001o3xvoooy0q9ws	cmprak1wr000c3xj38au25c61
0	cmpqqma23001o3xvoooy0q9ws	cmpran7d3000k3xj3cddg18jm
0	cmpqqma23001o3xvoooy0q9ws	cmpraptea000n3xj3l9yv04bm
0	cmpqqm9u8001m3xvo3u2d61ub	cmprak1wr000c3xj38au25c61
0	cmpqqm9u8001m3xvo3u2d61ub	cmpraptea000n3xj3l9yv04bm
0	cmpqqm9md001k3xvofiitta7j	cmprak1wr000c3xj38au25c61
0	cmpqqm9md001k3xvofiitta7j	cmpraptea000n3xj3l9yv04bm
0	cmpqqm9eg001i3xvoqq2p0pcl	cmprak1wr000c3xj38au25c61
0	cmpqqm9eg001i3xvoqq2p0pcl	cmpran7d3000k3xj3cddg18jm
0	cmpqqm9eg001i3xvoqq2p0pcl	cmpraptea000n3xj3l9yv04bm
0	cmpqqm96k001g3xvoeknbidid	cmprak1wr000c3xj38au25c61
0	cmpqqm96k001g3xvoeknbidid	cmpraptea000n3xj3l9yv04bm
0	cmpqqm8yp001e3xvolh59nlvx	cmprak1wr000c3xj38au25c61
0	cmpqqm8yp001e3xvolh59nlvx	cmpraptea000n3xj3l9yv04bm
0	cmpqqm8qt001c3xvom39q1hsv	cmprak1wr000c3xj38au25c61
0	cmpqqm8qt001c3xvom39q1hsv	cmpraptea000n3xj3l9yv04bm
0	cmpqqm8iy001a3xvodugp204w	cmprak1wr000c3xj38au25c61
0	cmpqqm8iy001a3xvodugp204w	cmpran7d3000k3xj3cddg18jm
0	cmpqqm8iy001a3xvodugp204w	cmpraptea000n3xj3l9yv04bm
0	cmpqqm89400183xvo7b2i3mk9	cmprak1wr000c3xj38au25c61
0	cmpqqm89400183xvo7b2i3mk9	cmpran7d3000k3xj3cddg18jm
0	cmpqqm89400183xvo7b2i3mk9	cmpraptea000n3xj3l9yv04bm
0	cmpqqm81900163xvo5msxvp3a	cmprak1wr000c3xj38au25c61
0	cmpqqm81900163xvo5msxvp3a	cmpran7d3000k3xj3cddg18jm
0	cmpqqm81900163xvo5msxvp3a	cmpraptea000n3xj3l9yv04bm
0	cmpu4u2520001l4045ganc8z4	cmpraghfn00083xj3mubzcis0
0	cmprepa050001jp04hcbe0l2v	cmprak1wr000c3xj38au25c61
0	cmprepa050001jp04hcbe0l2v	cmpralv7h000h3xj3hrbl5r9s
0	cmprepa050001jp04hcbe0l2v	cmpran7d3000k3xj3cddg18jm
0	cmprepa050001jp04hcbe0l2v	cmpraptea000n3xj3l9yv04bm
0	cmpqqm4t7000e3xvoazlktde5	cmpraghfn00083xj3mubzcis0
0	cmpqqm4t7000e3xvoazlktde5	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm4t7000e3xvoazlktde5	cmpraptea000n3xj3l9yv04bm
0	cmpqqm4t7000e3xvoazlktde5	cmq3v6ydv0000js04142zjpoi
0	cmpqqm5wm000o3xvouvthr06v	cmpraghfn00083xj3mubzcis0
0	cmpqqm5wm000o3xvouvthr06v	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm5wm000o3xvouvthr06v	cmpraptea000n3xj3l9yv04bm
0	cmpqqm5wm000o3xvouvthr06v	cmq3v6ydv0000js04142zjpoi
0	cmpqqm5gv000k3xvoc025780c	cmpraghfn00083xj3mubzcis0
0	cmpqqm5gv000k3xvoc025780c	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm5gv000k3xvoc025780c	cmpraptea000n3xj3l9yv04bm
0	cmpqqm5gv000k3xvoc025780c	cmq3v6ydv0000js04142zjpoi
0	cmpqqm5oq000m3xvo7hnkpo73	cmpraghfn00083xj3mubzcis0
0	cmpqqm5oq000m3xvo7hnkpo73	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm5oq000m3xvo7hnkpo73	cmpraptea000n3xj3l9yv04bm
0	cmpqqm5oq000m3xvo7hnkpo73	cmq3v6ydv0000js04142zjpoi
0	cmpqqm58z000i3xvo7kzkzfoh	cmpraghfn00083xj3mubzcis0
0	cmpqqm58z000i3xvo7kzkzfoh	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm58z000i3xvo7kzkzfoh	cmpraptea000n3xj3l9yv04bm
0	cmpqqm58z000i3xvo7kzkzfoh	cmq3v6ydv0000js04142zjpoi
0	cmpqqm513000g3xvo0iex8rrm	cmpraghfn00083xj3mubzcis0
0	cmpqqm513000g3xvo0iex8rrm	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm513000g3xvo0iex8rrm	cmpraptea000n3xj3l9yv04bm
0	cmpqqm513000g3xvo0iex8rrm	cmq3v6ydv0000js04142zjpoi
0	cmpqqmc8y00283xvomsuwyqct	cmpraptea000n3xj3l9yv04bm
0	cmpqqmc8y00283xvomsuwyqct	cmq3v6ydv0000js04142zjpoi
0	cmpqqmcgu002a3xvog83kbby5	cmpraptea000n3xj3l9yv04bm
0	cmpqqmcgu002a3xvog83kbby5	cmq3v6ydv0000js04142zjpoi
0	cmpqqmcwl002e3xvoh9uib930	cmpraptea000n3xj3l9yv04bm
0	cmpqqmcwl002e3xvoh9uib930	cmq3v6ydv0000js04142zjpoi
0	cmpqqmdcc002i3xvo4phz7u97	cmq3v6ydv0000js04142zjpoi
0	cmpqqmdk7002k3xvoo1d970sf	cmq3v6ydv0000js04142zjpoi
0	cmpqqmds2002m3xvosfq01877	cmq3v6ydv0000js04142zjpoi
0	cmpqqmcoq002c3xvolsroh00b	cmpraptea000n3xj3l9yv04bm
0	cmpqqmcoq002c3xvolsroh00b	cmq3v6ydv0000js04142zjpoi
0	cmpqqm6di000s3xvog0defnci	cmprak1wr000c3xj38au25c61
0	cmpqqm6di000s3xvog0defnci	cmpralv7h000h3xj3hrbl5r9s
0	cmpqqm6di000s3xvog0defnci	cmpraptea000n3xj3l9yv04bm
0	cmpqqmb5j001y3xvorydyj1tt	cmq3v6ydv0000js04142zjpoi
0	cmpqqmaxn001w3xvow1rxe18a	cmq3v6ydv0000js04142zjpoi
0	cmpqqmblb00223xvok0kay89v	cmq3v6ydv0000js04142zjpoi
0	cmpqqmbdf00203xvoi39rfzmh	cmq3v6ydv0000js04142zjpoi
0	cmpqqmbt800243xvo16ousrnk	cmq3v6ydv0000js04142zjpoi
0	cmpqqmf3p002w3xvo6lw4xcsu	cmpran7d3000k3xj3cddg18jm
0	cmpqqmf3p002w3xvo6lw4xcsu	cmpraptea000n3xj3l9yv04bm
0	cmq8nuyoz0001k304d0qgxux4	cmq3v6ydv0000js04142zjpoi
0	cmq8nuyoz0001k304d0qgxux4	cmpran7d3000k3xj3cddg18jm
0	cmq8nuyoz0001k304d0qgxux4	cmpraptea000n3xj3l9yv04bm
0	cmqyqvhd70001l404yqyqux46	cmqyqzbdb0004l404fiuyewa2
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.products (id, name, slug, description, price, "imageUrl", "isActive", "createdAt", "updatedAt", "categoryId", "isFeatured", "sortOrder") FROM stdin;
cmpqqm6mo000u3xvoqx1so0mc	โกโก้ร้อน	hot-cocoa	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/397a5fb8-38ce-4cf0-93cc-4aed1dffd32b.jpeg	t	2026-05-29 09:46:34.129	2026-05-29 09:46:34.129	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm73r000y3xvo4ll4a6t4	ลาเต้ร้อน	hot-latte	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/1fc395b4-1e34-4e3d-a812-b8cd385af630.jpeg	t	2026-05-29 09:46:34.743	2026-05-29 09:46:34.743	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm7c800103xvol1ftobf3	คาปูชิโน่ร้อน	hot-cappuccino	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/ce93ba19-1810-4a31-a306-4bec5caac9c1.jpeg	t	2026-05-29 09:46:35.048	2026-05-29 09:46:35.048	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm7kt00123xvoajgexyib	มอคค่าร้อน	hot-mocha	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/24e53499-4efd-4557-8715-8d4929e5bc72.jpeg	t	2026-05-29 09:46:35.357	2026-05-29 09:46:35.357	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm7td00143xvop8sp5qf4	นมสดร้อน	hot-fresh-milk	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/d5abad51-3ef6-4467-9659-ded6d6b7d69b.jpeg	t	2026-05-29 09:46:35.665	2026-05-29 09:46:35.665	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm58z000i3xvo7kzkzfoh	อเมริกาโน่น้ำผึ้งมะนาว	americano-honey-lemon	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/64d7fc03-e5e9-4a83-92ef-a6b8142615e2.jpeg	t	2026-05-29 09:46:32.339	2026-06-10 05:39:35.691	cmpqqm2af00003xvop4gn7372	t	11
cmpqqm5oq000m3xvo7hnkpo73	อเมริกาโน่พีช	americano-peach	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/2003576c-55b9-4062-a7da-14a0fb5f7619.jpeg	t	2026-05-29 09:46:32.906	2026-06-10 05:39:38.869	cmpqqm2af00003xvop4gn7372	f	12
cmpqqm5wm000o3xvouvthr06v	อเมริกาโน่สับปะรด	americano-pineapple	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/55d8cbfe-063e-498f-9e9b-19ec60989acb.jpeg	t	2026-05-29 09:46:33.191	2026-06-10 05:39:43.208	cmpqqm2af00003xvop4gn7372	f	13
cmpqqm9eg001i3xvoqq2p0pcl	ชาเขียวเย็น	iced-green-tea	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/a73411ef-bbf8-43c9-8120-891d9b43095c.jpeg	t	2026-05-29 09:46:37.72	2026-06-10 05:47:07.435	cmpqqm2ys00023xvoxoade8tm	t	0
cmpqqm513000g3xvo0iex8rrm	อเมริกาโน่น้ำผึ้ง	americano-honey	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/c329ff30-e016-4460-bb6d-cf03773e7090.jpeg	t	2026-05-29 09:46:32.055	2026-06-10 05:39:04.019	cmpqqm2af00003xvop4gn7372	t	2
cmpqqm6di000s3xvog0defnci	กาแฟชาเขียว	coffee-green-tea	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/58ced53b-5dd3-4531-8fc0-fb3d8a50c951.jpeg	t	2026-05-29 09:46:33.798	2026-06-10 05:39:24.603	cmpqqm2af00003xvop4gn7372	t	8
cmpqqm4cx000a3xvo6ij5ksrm	มอคค่าเย็น	iced-mocha	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/d7580a35-ad8d-4b77-b1bd-c5e0ea1979ce.jpeg	t	2026-05-29 09:46:31.185	2026-06-10 05:39:20.979	cmpqqm2af00003xvop4gn7372	t	7
cmpqqm3ot00063xvoeortkzib	ลาเต้เย็น	iced-latte	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/1329c7b5-8895-43cf-a463-84d025fdbfc0.jpeg	t	2026-05-29 09:46:30.317	2026-06-10 05:39:13.123	cmpqqm2af00003xvop4gn7372	t	5
cmpqqm45100083xvoo43pm2fa	คาปูชิโน่เย็น	iced-cappuccino	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/6fe7970b-6127-475c-a799-65e3ef97e1ed.jpeg	t	2026-05-29 09:46:30.901	2026-06-10 05:39:17.92	cmpqqm2af00003xvop4gn7372	t	6
cmpqqm4t7000e3xvoazlktde5	อเมริกาโน่ส้ม	americano-orange	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/15b3b098-4aca-4c8f-a73c-f5d4e70705a6.jpeg	t	2026-05-29 09:46:31.771	2026-06-10 05:39:00.018	cmpqqm2af00003xvop4gn7372	t	1
cmpqqm4l9000c3xvojqoj1yyt	อเมริกาโน่เย็น	iced-americano	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/72ae99d3-bd39-4605-add4-18cd58fd8915.jpeg	t	2026-05-29 09:46:31.486	2026-06-10 05:38:56.429	cmpqqm2af00003xvop4gn7372	t	0
cmpqqm6v9000w3xvoupr8eicc	เอสเปรสโซ่ร้อน	hot-espresso	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/dd09824f-e5cd-4151-a545-74331b55d78c.jpeg	t	2026-05-29 09:46:34.437	2026-05-29 21:21:54.253	cmpqqm2qw00013xvon33dcoir	f	0
cmpqqm8qt001c3xvom39q1hsv	ชาดำเย็น	iced-black-tea	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/06a06d66-ae6b-4fe6-b565-928007ba92bb.jpeg	t	2026-05-29 09:46:36.87	2026-06-10 05:47:07.46	cmpqqm2ys00023xvoxoade8tm	f	5
cmpqqm9md001k3xvofiitta7j	ชาเขียวมะนาว	green-tea-lemon	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/8b8c3508-bf76-4953-8aa7-2ab1189239ed.jpeg	t	2026-05-29 09:46:38.005	2026-06-10 05:47:07.48	cmpqqm2ys00023xvoxoade8tm	f	10
cmpqqm89400183xvo7b2i3mk9	โกโก้มิ้นต์	cocoa-mint	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/468ceba9-cd46-467d-970e-6a25307c75a3.jpeg	t	2026-05-29 09:46:36.233	2026-06-10 05:47:07.506	cmpqqm2ys00023xvoxoade8tm	f	17
cmpqqm81900163xvo5msxvp3a	โกโก้เย็น	iced-cocoa	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/4e19314d-548a-4cf4-bffd-b1ff8db816c0.jpeg	t	2026-05-29 09:46:35.949	2026-06-10 05:47:07.447	cmpqqm2ys00023xvoxoade8tm	t	2
cmpqqm9u8001m3xvo3u2d61ub	ชาเขียวน้ำผึ้งมะนาว	green-tea-honey-lemon	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/2425e9b1-a2bf-449e-8c58-399eb927b676.jpeg	t	2026-05-29 09:46:38.289	2026-06-10 05:47:07.476	cmpqqm2ys00023xvoxoade8tm	f	9
cmpqqm96k001g3xvoeknbidid	ชามะนาวน้ำผึ้ง	honey-lemon-tea	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/5ff91122-c0b0-4134-93ab-26e5499125f9.jpeg	t	2026-05-29 09:46:37.436	2026-06-10 05:47:07.468	cmpqqm2ys00023xvoxoade8tm	f	7
cmpqqm8yp001e3xvolh59nlvx	ชามะนาว	lemon-tea	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/e9bec3f8-be04-4952-813d-247c04556e7c.jpeg	t	2026-05-29 09:46:37.153	2026-06-10 05:47:07.464	cmpqqm2ys00023xvoxoade8tm	f	6
cmpqqma23001o3xvoooy0q9ws	นมชมพูเย็น	iced-pink-milk	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/769866a6-e8a8-4f50-aa7e-28b80669337f.jpeg	t	2026-05-29 09:46:38.571	2026-06-10 05:47:07.456	cmpqqm2ys00023xvoxoade8tm	f	4
cmpqqm8iy001a3xvodugp204w	ชาไทยเย็น	iced-thai-tea	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/63b71889-326a-4a12-90a2-84fcd0edc4ba.jpeg	t	2026-05-29 09:46:36.586	2026-06-10 05:47:07.443	cmpqqm2ys00023xvoxoade8tm	t	1
cmpqqmaxn001w3xvow1rxe18a	ชาไทยสตรอเบอร์รี่	thai-tea-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/10586832-af30-42d4-b83f-2909d5f1f8be.jpeg	t	2026-05-29 09:46:39.708	2026-06-10 05:47:07.488	cmpqqm2ys00023xvoxoade8tm	f	12
cmpqqmds2002m3xvosfq01877	มัจฉะลาเต้โกโก้	matcha-latte-cocoa	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/6cb873ed-dfb2-4a82-9fb2-6a4b2e45e3f8.jpeg	t	2026-05-29 09:46:43.394	2026-06-10 05:41:06.452	cmpqqm36o00033xvo1r46v845	f	7
cmpqqmd4h002g3xvorpy8wab0	มัจฉะลาเต้	matcha-latte	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/4dd3356d-e58f-4a98-a76c-22fcfe99b04c.jpeg	t	2026-05-29 09:46:42.545	2026-06-10 05:40:42.662	cmpqqm36o00033xvo1r46v845	t	1
cmpqqmdk7002k3xvoo1d970sf	มัจฉะลาเต้สตรอเบอร์รี่	matcha-latte-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/462f8e3f-15ce-48dd-aa82-4c74ac85116a.jpeg	t	2026-05-29 09:46:43.111	2026-06-10 05:40:51.538	cmpqqm36o00033xvo1r46v845	f	3
cmpqqmdcc002i3xvo4phz7u97	มัจฉะลาเต้คาราเมล	matcha-latte-caramel	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/1fb81f04-0119-4653-8df5-3ba9950530e8.jpeg	t	2026-05-29 09:46:42.828	2026-06-10 05:41:04.442	cmpqqm36o00033xvo1r46v845	f	6
cmpqqmgex00383xvonmxflp92	น้ำพีชโซดา	peach-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/b3ba19d2-2df5-463f-aff9-76aa0a5c1211.jpeg	t	2026-05-29 09:46:46.81	2026-05-29 21:31:35.657	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmg7200363xvo3gkl3mbk	น้ำบลูฮาวายโซดา	blue-hawaii-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/8c19d3dd-648a-4b4b-aae1-8c843859e668.jpeg	t	2026-05-29 09:46:46.526	2026-05-29 21:32:09.435	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmfz700343xvogibx6w25	น้ำผึ้งมะนาว	honey-lemon-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/b26dcafa-a65f-439a-b682-06d3f72930c0.jpeg	t	2026-05-29 09:46:46.243	2026-05-29 21:32:37.908	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmfrb00323xvok639ez5v	น้ำสับปะรด	pineapple-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/83980a1d-e8ec-41e8-85e6-f496b9e9d838.jpeg	t	2026-05-29 09:46:45.96	2026-05-29 21:33:05.453	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmfjf00303xvou7ww0eba	น้ำแอปเปิ้ลเขียว	green-apple-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/5781cfe4-4b16-4175-a78a-1d65974228f2.jpeg	t	2026-05-29 09:46:45.675	2026-05-29 21:33:55.822	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmevt002u3xvo4bwqom23	น้ำบลูเบอร์รี่	blueberry-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/4d768531-1c81-4dd3-a3ca-dde11875fc77.jpeg	t	2026-05-29 09:46:44.826	2026-05-29 21:34:34.625	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmfbk002y3xvosi99u8ry	น้ำกีวี่	kiwi-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/895e713e-6155-44ee-b728-602e56dbc74b.jpeg	t	2026-05-29 09:46:45.393	2026-05-29 21:35:03.154	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmenx002s3xvozyfrvjck	น้ำพีช	peach-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/fa391630-0dd1-4dbb-819f-cd8f8ff11122.jpeg	t	2026-05-29 09:46:44.541	2026-05-29 21:36:17.027	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmeg2002q3xvorgtl69w5	น้ำบลูฮาวาย	blue-hawaii	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/447ae9b9-e0a0-4c1a-80a4-b4d457d71c48.jpeg	t	2026-05-29 09:46:44.259	2026-05-29 21:37:04.31	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqme85002o3xvonvhpgw36	น้ำส้ม	orange-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/78502a85-3edb-45a7-a431-7bee68db13ed.jpeg	t	2026-05-29 09:46:43.694	2026-05-29 21:37:55.655	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmahy001s3xvoh9qjvokp	นมสดมิ้นต์	fresh-milk-mint	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/c54a255d-8353-4510-846e-d4c49a70ae6a.jpeg	t	2026-05-29 09:46:39.142	2026-06-10 05:47:07.499	cmpqqm2ys00023xvoxoade8tm	f	15
cmpqqmbdf00203xvoi39rfzmh	นมสดสตรอเบอร์รี่	fresh-milk-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/742a9976-c3d9-46c4-9851-f798e69229f0.jpeg	t	2026-05-29 09:46:40.275	2026-06-10 05:47:07.503	cmpqqm2ys00023xvoxoade8tm	f	16
cmpqqmb5j001y3xvorydyj1tt	ชาเขียวสตรอเบอร์รี่	green-tea-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/3e57316e-4cab-4eab-a85b-7f219ad57479.jpeg	t	2026-05-29 09:46:39.992	2026-06-10 05:47:07.484	cmpqqm2ys00023xvoxoade8tm	f	11
cmpqqmcwl002e3xvoh9uib930	มัจฉะมะพร้าว	matcha-coconut	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/438cea0a-f148-44e6-b1a1-b23fea5905a4.jpeg	t	2026-05-29 09:46:42.261	2026-06-10 05:40:48.475	cmpqqm36o00033xvo1r46v845	t	2
cmpqqmc8y00283xvomsuwyqct	มัจฉะน้ำผึ้ง	matcha-honey	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/db26ce38-4559-4370-95ce-93804a69140b.jpeg	t	2026-05-29 09:46:41.411	2026-06-10 05:40:55.239	cmpqqm36o00033xvo1r46v845	f	4
cmpqqmcoq002c3xvolsroh00b	มัจฉะส้ม	matcha-orange	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/3bdb2773-990d-4000-ad79-87193b24faf7.jpeg	t	2026-05-29 09:46:41.978	2026-06-10 05:41:08.702	cmpqqm36o00033xvo1r46v845	f	8
cmpqqma9x001q3xvo0d6239vc	นมสดเย็น	iced-fresh-milk	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/11d7c63a-60ef-476d-91f6-c41697674b8b.jpeg	t	2026-05-29 09:46:38.854	2026-06-10 05:47:07.452	cmpqqm2ys00023xvoxoade8tm	f	3
cmpqqmblb00223xvok0kay89v	นมชมพูสตรอเบอร์รี่	pink-milk-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/85d211e9-e2c6-4844-80fb-ebf5b14bf645.jpeg	t	2026-05-29 09:46:40.56	2026-06-10 05:47:07.491	cmpqqm2ys00023xvoxoade8tm	f	13
cmpqqmaps001u3xvo1w0msnzw	นมสดคาราเมล	fresh-milk-caramel	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/0192a10a-fdde-44d4-ab97-b061db57da9d.jpeg	t	2026-05-29 09:46:39.425	2026-06-10 05:47:07.496	cmpqqm2ys00023xvoxoade8tm	f	14
cmpqqmf3p002w3xvo6lw4xcsu	น้ำสตรอเบอร์รี่	strawberry-juice	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/1e6d529c-8a8e-4ede-aa0b-e1d12fa773f6.jpeg	t	2026-05-29 09:46:45.109	2026-06-07 15:18:19.391	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmc1300263xvodgeiz5il	เพียวมัจฉะ	pure-matcha	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/6c7c0f15-4ba3-41a6-92cc-c5c628bc1d5a.jpeg	t	2026-05-29 09:46:41.127	2026-06-10 05:40:39.354	cmpqqm36o00033xvo1r46v845	t	0
cmpqqmgmt003a3xvofi0j1ugq	น้ำบลูเบอร์รี่โซดา	blueberry-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/862d9ec6-6744-4d15-8430-26feb084001a.jpeg	t	2026-05-29 09:46:47.093	2026-05-29 21:31:02.443	cmpqqm3gw00043xvoo5oazetj	f	0
cmprex2q00001kt044kgwxhj2	น้ำส้มโซดา	orangeju-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/aa12e98e-f08d-4685-9f85-98f3cbc2091d.png	t	2026-05-29 21:06:53.064	2026-05-31 16:13:28.38	cmpqqm3gw00043xvoo5oazetj	f	0
cmq7m69sc0003la04fmysvt29	น้ำแข็ง พร้อมแก้ว	ice	\N	5.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/2b0a68a9-c3a0-4834-9b9b-1dade897fe6e.jpeg	t	2026-06-10 05:14:18.252	2026-06-10 05:39:30.131	cmpqqm2af00003xvop4gn7372	f	10
cmpqqmcgu002a3xvog83kbby5	มัจฉะน้ำผึ้งมะนาว	matcha-honey-lemon	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/bbfc32e1-1336-4cec-816a-d40dd782e794.jpeg	t	2026-05-29 09:46:41.695	2026-06-10 05:41:01.704	cmpqqm36o00033xvo1r46v845	f	5
cmpqqmhq9003k3xvoadvnhwjy	น้ำผึ้งมะนาวโซดา	honey-lemon-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/0dc4eda7-be33-4764-a16d-7da5e975d294.jpeg	t	2026-05-29 09:46:48.513	2026-05-29 21:27:43.996	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmhie003i3xvoybyvebt7	น้ำสับปะรดโซดา	pineapple-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/ce6e65cb-2013-47aa-8132-c5e39df79bdf.jpeg	t	2026-05-29 09:46:48.23	2026-05-29 21:28:30.788	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmhah003g3xvocqzdccbj	น้ำแอปเปิ้ลเขียวโซดา	green-apple-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/3b5e5c7e-88d3-4200-99e7-d22558b83ed8.jpeg	t	2026-05-29 09:46:47.946	2026-05-29 21:29:05.971	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmh2m003e3xvofpd1t1xp	น้ำกีวี่โซดา	kiwi-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/2b63542c-6906-4440-a97d-289665e8cad4.jpeg	t	2026-05-29 09:46:47.662	2026-05-29 21:29:31.562	cmpqqm3gw00043xvoo5oazetj	f	0
cmpqqmguq003c3xvobz35z24l	น้ำสตรอเบอร์รี่โซดา	strawberry-soda	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/f76e05b6-9e1b-40b9-9ce5-27bbefd92e39.jpeg	t	2026-05-29 09:46:47.378	2026-05-29 21:30:37.129	cmpqqm3gw00043xvoo5oazetj	f	0
cmpzoaia200023xomsj6ohdvb	ไข่ลวก	egg	\N	15.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/f29df9e9-5f83-4ca1-a64b-8688b0a6f58c.jpg	t	2026-06-04 15:51:25.706	2026-06-07 15:03:24.087	cmpzo7q3e00003xom8w85pzdb	t	0
cmpu4u2520001l4045ganc8z4	แบล็คคอฟฟี่ร้อน	1	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/9739a326-8653-4b8b-9ef6-8d4a65b9f5e3.jpeg	t	2026-05-31 18:47:54.71	2026-05-31 18:55:01.412	cmpqqm2qw00013xvon33dcoir	f	0
cmpresqx90001l70436g0jlwu	ชาเขียวดำเย็น	ice-blackgreentea	\N	30.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/2d121fbf-37c1-40e4-9574-6e740aef77b4.png	t	2026-05-29 21:03:31.149	2026-06-10 05:47:07.471	cmpqqm2ys00023xvoxoade8tm	f	8
cmpqqmbt800243xvo16ousrnk	โกโก้สตรอเบอร์รี่	cocoa-strawberry	\N	45.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/84a46f51-2dbf-4436-9eeb-8b522d72dc19.jpeg	t	2026-05-29 09:46:40.844	2026-06-10 05:47:07.51	cmpqqm2ys00023xvoxoade8tm	f	18
cmq8nuyoz0001k304d0qgxux4	ชาไต้หวัน	taiwanese-tea	\N	35.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/34eedda9-d1ae-43bb-8d60-002df0c80150.jpg	t	2026-06-10 22:49:16.067	2026-06-10 22:49:16.067	cmpqqm2ys00023xvoxoade8tm	f	0
cmpqqm5gv000k3xvoc025780c	อเมริกาโน่มะพร้าว	americano-coconut	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/8454be7f-bb0d-4e8c-b6ea-5598d612ef8b.jpeg	t	2026-05-29 09:46:32.623	2026-06-10 05:39:07.307	cmpqqm2af00003xvop4gn7372	t	3
cmprepa050001jp04hcbe0l2v	เอสเปรสโซ่เย็น	ice-espresso	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/fb8999d8-e983-47b3-8363-f16e50e960c0.jpeg	t	2026-05-29 21:00:49.253	2026-06-10 05:39:09.854	cmpqqm2af00003xvop4gn7372	t	4
cmpqqm65m000q3xvow1n8n4d2	กาแฟชาไทย	coffee-thai-tea	\N	40.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/dd2aa01c-bee3-4ab1-b9a8-fdaf78f84254.jpeg	t	2026-05-29 09:46:33.514	2026-06-10 05:39:27.67	cmpqqm2af00003xvop4gn7372	t	9
cmq7m4l080001la04q94r0qzv	ข้าวไข่เจียว	omelet	\N	25.00	https://jp-sibling-upload-bucket.s3.ap-southeast-2.amazonaws.com/products/62ef13d1-6ca8-4422-9163-2ccf4622decf.jpeg	t	2026-06-10 05:12:59.48	2026-06-29 04:56:20.28	cmpzo7q3e00003xom8w85pzdb	t	0
cmqyqvhd70001l404yqyqux46	ข้าวราดแกง	food-rice	\N	30.00	\N	t	2026-06-29 04:55:39.692	2026-06-29 05:03:01.367	cmpzo7q3e00003xom8w85pzdb	t	0
cmqyqw25g0003l404r758zgr6	ข้าวราดแกง	food	\N	30.00	\N	f	2026-06-29 04:56:06.628	2026-06-29 05:04:16.055	cmpzo7q3e00003xom8w85pzdb	f	0
\.


--
-- Data for Name: truck_locations; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.truck_locations (id, name, description, "mapUrl", "openTime", "closeTime", "daysOfWeek", "isActive", "updatedAt", "isOpen", "blockOnlineOrder", "manualClose") FROM stdin;
cmpr5tcym00003x4anuq9i7rn	-	บริษัท เอ็กซา ซีแลม จำกัด (สำนักงานใหญ่)	https://maps.app.goo.gl/DBoHF7BBgKsdKtpg9?g_st=ic	06:00	10:00	วันที่ 1 - 8 มิถุนายน 2569	t	2026-06-24 02:55:25.596	t	f	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, email, "passwordHash", name, role, "isActive", "createdAt", "updatedAt") FROM stdin;
cmprd13vv00003xwd57f832st	admin@example.com	$argon2id$v=19$m=65536,t=3,p=4$c6/OpOpKiSOtwZ6ZHwFAHQ$/9AiRVHVgm9HfoiwAmj8FTA7mRV3ZrEp47sOuh912ws	Administrator	ADMIN	t	2026-05-29 20:14:01.963	2026-05-29 20:14:01.963
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: campaign_coupons campaign_coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.campaign_coupons
    ADD CONSTRAINT campaign_coupons_pkey PRIMARY KEY ("campaignId", "couponId");


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: coupon_uses coupon_uses_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupon_uses
    ADD CONSTRAINT coupon_uses_pkey PRIMARY KEY (id);


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- Name: discounts discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);


--
-- Name: fcm_tokens fcm_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.fcm_tokens
    ADD CONSTRAINT fcm_tokens_pkey PRIMARY KEY (id);


--
-- Name: location_requests location_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_requests
    ADD CONSTRAINT location_requests_pkey PRIMARY KEY (id);


--
-- Name: location_schedules location_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_schedules
    ADD CONSTRAINT location_schedules_pkey PRIMARY KEY (id);


--
-- Name: location_votes location_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_votes
    ADD CONSTRAINT location_votes_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: option_groups option_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.option_groups
    ADD CONSTRAINT option_groups_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: order_item_options order_item_options_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_item_options
    ADD CONSTRAINT order_item_options_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: point_logs point_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT point_logs_pkey PRIMARY KEY (id);


--
-- Name: product_option_groups product_option_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_option_groups
    ADD CONSTRAINT product_option_groups_pkey PRIMARY KEY ("productId", "optionGroupId");


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: truck_locations truck_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.truck_locations
    ADD CONSTRAINT truck_locations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: articles_slug_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX articles_slug_key ON public.articles USING btree (slug);


--
-- Name: categories_slug_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX categories_slug_key ON public.categories USING btree (slug);


--
-- Name: coupons_code_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX coupons_code_key ON public.coupons USING btree (code);


--
-- Name: fcm_tokens_token_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX fcm_tokens_token_key ON public.fcm_tokens USING btree (token);


--
-- Name: location_votes_memberId_weekYear_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "location_votes_memberId_weekYear_key" ON public.location_votes USING btree ("memberId", "weekYear");


--
-- Name: location_votes_requestId_memberId_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "location_votes_requestId_memberId_key" ON public.location_votes USING btree ("requestId", "memberId");


--
-- Name: members_email_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX members_email_key ON public.members USING btree (email);


--
-- Name: members_googleId_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "members_googleId_key" ON public.members USING btree ("googleId");


--
-- Name: members_lineUserId_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "members_lineUserId_key" ON public.members USING btree ("lineUserId");


--
-- Name: payments_orderId_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX "payments_orderId_key" ON public.payments USING btree ("orderId");


--
-- Name: products_slug_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX products_slug_key ON public.products USING btree (slug);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: campaign_coupons campaign_coupons_campaignId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.campaign_coupons
    ADD CONSTRAINT "campaign_coupons_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES public.campaigns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: campaign_coupons campaign_coupons_couponId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.campaign_coupons
    ADD CONSTRAINT "campaign_coupons_couponId_fkey" FOREIGN KEY ("couponId") REFERENCES public.coupons(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: coupon_uses coupon_uses_couponId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupon_uses
    ADD CONSTRAINT "coupon_uses_couponId_fkey" FOREIGN KEY ("couponId") REFERENCES public.coupons(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: coupon_uses coupon_uses_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupon_uses
    ADD CONSTRAINT "coupon_uses_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: coupon_uses coupon_uses_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.coupon_uses
    ADD CONSTRAINT "coupon_uses_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fcm_tokens fcm_tokens_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.fcm_tokens
    ADD CONSTRAINT "fcm_tokens_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: location_requests location_requests_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_requests
    ADD CONSTRAINT "location_requests_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: location_schedules location_schedules_truckLocationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_schedules
    ADD CONSTRAINT "location_schedules_truckLocationId_fkey" FOREIGN KEY ("truckLocationId") REFERENCES public.truck_locations(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: location_votes location_votes_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_votes
    ADD CONSTRAINT "location_votes_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: location_votes location_votes_requestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.location_votes
    ADD CONSTRAINT "location_votes_requestId_fkey" FOREIGN KEY ("requestId") REFERENCES public.location_requests(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: options options_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT "options_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public.option_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item_options order_item_options_optionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_item_options
    ADD CONSTRAINT "order_item_options_optionId_fkey" FOREIGN KEY ("optionId") REFERENCES public.options(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_item_options order_item_options_orderItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_item_options
    ADD CONSTRAINT "order_item_options_orderItemId_fkey" FOREIGN KEY ("orderItemId") REFERENCES public.order_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_items order_items_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "order_items_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: order_items order_items_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT "order_items_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: orders orders_discountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_discountId_fkey" FOREIGN KEY ("discountId") REFERENCES public.discounts(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "orders_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: payments payments_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT "payments_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: point_logs point_logs_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT "point_logs_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.members(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: product_option_groups product_option_groups_optionGroupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_option_groups
    ADD CONSTRAINT "product_option_groups_optionGroupId_fkey" FOREIGN KEY ("optionGroupId") REFERENCES public.option_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_groups product_option_groups_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_option_groups
    ADD CONSTRAINT "product_option_groups_productId_fkey" FOREIGN KEY ("productId") REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: products products_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "products_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: neondb_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict UlmqpCyBAhmL5bFJVj1Rb7FqZWXQBVctQw2Vgs0MYCGHZChEdV330mocfzcmwLF

