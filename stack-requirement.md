# Project Stack & Initial Requirements

## Project Overview

Web Application สำหรับ:

- POS (Point of Sale)
- Back Office Management
- Public Website (SEO)
- Member System

Architecture เน้น:
- Responsive
- SSR
- SEO-friendly
- Secure
- Simple maintainable structure
- Solo developer friendly

---

# Tech Stack

## Frontend / SSR Framework

### Nuxt 3
ใช้สำหรับ:
- SSR
- Routing
- API Routes
- SEO
- Middleware
- Fullstack monolith structure

Features:
- Server-side rendering (SSR)
- Hybrid rendering
- File-based routing
- API endpoints
- Middleware & auth guard
- Auto imports
- Composables

---

## Database ORM

### Prisma
ใช้สำหรับ:
- Database ORM
- Schema management
- Migration
- Query abstraction
- Type-safe database access

Features:
- PostgreSQL support
- Type-safe queries
- Migration system
- Relational data handling
- Prevent common SQL injection issues

---

## Database

### PostgreSQL
ใช้สำหรับ:
- Product data
- Orders
- Queue
- Members
- Promotions
- Transactions

Features:
- Relational database
- ACID transaction
- Good performance
- Scalable
- Reliable for POS systems

---

## UI / Styling

### TailwindCSS
ใช้สำหรับ:
- Responsive UI
- Utility-first styling
- Fast UI development

Features:
- Mobile-first responsive design
- Reusable utility classes
- Fast prototyping
- Easy maintenance

---

## State Management

### Pinia
ใช้สำหรับ:
- POS cart state
- User session
- Member state
- Queue/order state

Features:
- Lightweight
- Vue-native
- TypeScript friendly
- Simple store structure

---

# Initial Modules

## 1. POS System

Features:
- Multiple orders
- Queue management
- Cart system
- Discounts
- Checkout/payment
- Order status
- Receipt support (future)

Possible Entities:
- Orders
- OrderItems
- Products
- Discounts
- Payments
- Queue

---

## 2. Back Office

Features:
- Product management
- Category management
- User management
- Login/authentication
- Role management
- Member management

Roles:
- Admin
- Cashier
- Staff

---

## 3. Public Website

Features:
- Campaign pages
- News/articles
- Voting system
- SEO pages

Requirements:
- SSR enabled
- SEO optimized
- Social share metadata
- Sitemap
- OpenGraph support

---

## 4. Member System

Features:
- Login/register
- Online ordering
- Point system
- Promotions
- Privileges
- Order history

Possible Entities:
- Members
- Points
- Rewards
- Promotions
- MemberOrders

---

# Security Requirements

## Authentication
- HttpOnly Cookie Session
- Secure Cookie
- SameSite Cookie Policy

---

## Password Security
- bcrypt or argon2 hashing

---

## Validation
- API validation
- Input sanitization
- Server-side validation

Recommended:
- zod
- valibot

---

## Authorization
Role-based access:
- admin
- cashier
- member

---

## API Security
- Rate limiting
- CSRF protection
- CORS policy
- Request validation

---

## General Security
- HTTPS only (production)
- Helmet/CSP headers
- Environment variables
- Database access restriction

---

# Suggested Project Structure

```txt
/app
  /pages
  /components
  /layouts
  /middleware
  /composables
  /stores
  /server
    /api
    /utils
  /prisma