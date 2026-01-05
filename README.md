# 🧾 Billing Management System

A full-stack Billing Management System built with Ruby on Rails, designed to handle real-world billing scenarios including **tax calculation**, **cash denomination handling**, **stock management**, and **customer purchase history tracking**.

![Ruby](https://img.shields.io/badge/Ruby-3.x-red)
![Rails](https://img.shields.io/badge/Rails-7.x-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue)
![Sidekiq](https://img.shields.io/badge/Sidekiq-Background_Jobs-orange)
![Stimulus](https://img.shields.io/badge/Stimulus-Frontend-green)

> 💡 This is a **server-rendered Rails application** (not an API) with modern frontend behavior using **Stimulus** and background job processing via **Sidekiq**.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Core Models](#-core-models)
- [Business Rules](#-business-rules)
- [Architecture](#-architecture)
- [Setup Instructions](#-setup-instructions)
- [Usage Guide](#-usage-guide)
- [Testing](#-testing)
- [Email Configuration](#-email-configuration)
- [Design Decisions](#-design-decisions)
- [Future Improvements](#-future-improvements)
- [Assumptions & Business Rules](#-assumptions--business-rules)
- [Author](#-author)

---

## 🚀 Features

### 1. 📝 Bill Generation

**Create bills with:**
- Customer email
- Multiple products
- Quantity per product
- Automatic per-item tax calculation

**Validations:**
- ✅ Product stock availability
- ✅ Paid amount must be ≥ net bill amount
- ✅ Cash denomination total must exactly match paid amount

---

### 2. 👁️ Live Bill Preview (Before Submit)

- Shows **subtotal**, **tax**, and **net amount** dynamically
- **No database records** are created during preview
- Backend calculation handled by a **service object**
- Prevents invalid submissions early

---

### 3. 💵 Cash Denomination Handling

Customer enters denominations: **₹500, ₹200, ₹100, ₹50, ₹20, ₹10, ₹5, ₹2, ₹1**

**System behavior:**
- Validates denomination total = paid amount
- Adds customer-given cash to system inventory
- Calculates change using available denominations
- Supports **partial change return**

**Example:**
```
Bill Total: ₹570
Paid Amount: ₹600
Change Due: ₹30
Available Denomination: ₹20 only

Returned: ₹20
Remaining Due: ₹10 (shown clearly)
```

---

### 4. 📦 Stock Management

#### Product Stock
- Validated **before** bill creation
- Reduced **after** successful billing
- Prevents overselling

#### Denomination Stock
- **Increased** when customer pays
- **Reduced** when change is returned
- Maintains accurate cash inventory

---

### 5. 📜 Purchase History

- Each bill is linked to a customer via **email**
- From Bill Show Page, user can click: **"Previous Purchases"**
- Redirects to history page with customer email
- Lists all previous bills (clickable)

---

### 6. 📧 Invoice Email (Background Job)

- Invoice email sent **after** bill creation
- Executed asynchronously using **Sidekiq**
- Does **not block** bill creation
- Uses **ActionMailer**

**Flow:**
```
Bill Created → Sidekiq Job → Email Sent
```

---

### 7. 🏗️ Clean Architecture

- Business logic isolated in `Billing::Calculator`
- Controllers handle only **HTTP concerns**
- Frontend + backend validations (defensive design)
- Clear separation of responsibilities

---

## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Ruby 3.x** | Language |
| **Rails 7.x** | Framework |
| **PostgreSQL** | Database |
| **Stimulus** | Frontend interactivity |
| **Sidekiq** | Background jobs |
| **Redis** | Sidekiq backend |
| **RSpec** | Testing |
| **ActionMailer** | Emails |
| **letter_opener** | Email preview (dev) |

---

## 🗂 Core Models

```
Customer
  └── Bills
        ├── BillItems ── Products
        └── BillDenominations ── Denominations
```

| Model | Description |
|-------|-------------|
| **Customer** | Identified by email |
| **Bill** | Main billing record |
| **BillItem** | Line items |
| **Product** | Price, tax %, stock |
| **Denomination** | Cash inventory |
| **BillDenomination** | Change given |

---

## 🧠 Business Rules

1. Paid amount must **not** be less than net amount
2. Denomination total must **match** paid amount
3. Products with quantity **0** are ignored
4. Partial change scenarios are **supported and displayed**

---

## 🏗️ Architecture

### Service Object Pattern

```ruby
# app/services/billing/calculator.rb
module Billing
  class Calculator
    def call
      # stock validation
      # tax calculation
      # denomination handling
      # bill persistence
    end
  end
end
```

**Why:**
- Keeps controllers **thin**
- Easy to **test**
- **Reusable** logic
- Cleaner codebase

---

## ▶️ Setup Instructions

### Prerequisites

- Ruby 3.x
- Rails 7.x
- PostgreSQL
- Redis

### Installation

```bash
git clone https://github.com/nishkarshh013/billing-management.git
cd billing_management
bundle install
rails db:create db:migrate db:seed
```

### Start Services

#### 1. Start Redis
```bash
redis-server
```

#### 2. Start Sidekiq (new terminal)
```bash
bundle exec sidekiq
```

#### 3. Start Rails (new terminal)
```bash
rails s
```

Visit 👉 **http://localhost:3000**

---

## 📖 Usage Guide

### Create Bill

1. Go to `/bills/new`
2. Enter customer email
3. Add products & quantity
4. Preview bill
5. Enter denominations
6. Generate bill

### Purchase History

1. Open any bill
2. Click **"Previous Purchases"**
3. View all past bills

---

## 🧪 Testing

**Run all tests:**
```bash
bundle exec rspec
```

**Includes:**
- Billing service tests
- Controller tests
- Stock & denomination edge cases
- Preview validations

---

## 📧 Email Configuration

### Development

Uses **letter_opener**.  
Emails open in browser automatically.

### Production

Configure SMTP in `production.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'yourdomain.com',
  user_name:            ENV['SMTP_USERNAME'],
  password:             ENV['SMTP_PASSWORD'],
  authentication:       'plain',
  enable_starttls_auto: true
}
```

---

## 📌 Design Decisions

| Decision | Reason |
|----------|--------|
| **Service objects** | Complex logic isolation |
| **Sidekiq** | Real async processing |
| **Stimulus** | Rails-native, lightweight |
| **Server-rendered views** | Not an API, admin-focused |

---

## 🚧 Future Improvements

- [ ] PDF invoices
- [ ] Discounts & coupons
- [ ] Admin analytics dashboard
- [ ] Returns & refunds
- [ ] Role-based access

---

## 📋 Assumptions & Business Rules

### 🔹 Assumption 1: Bill Summary Is Mandatory Before Payment

**The system always shows a bill summary before payment is accepted.**

**Reason:**

Without a bill summary, the customer (and cashier) cannot know:
- Total price without tax
- Total tax payable
- Final net amount to be paid

**Implementation:**
- A real-time **Bill Summary** (Subtotal, Tax, Net Total) is calculated and displayed before bill generation
- The customer is **not allowed to proceed** blindly without knowing the payable amount
- This mirrors **real-world billing/POS systems**

---

### 🔹 Assumption 2: Two Separate Cash Sources Are Maintained

**The system assumes two different types of cash:**

1. **Cash given by the customer** (for current transaction)
2. **Cash already available with the shop owner** (system denominations)

**Why this matters:**

- Customer cash must first be **validated**
- Change must be returned **only from available system denominations**, not magically generated

**Flow:**

```
1. Customer enters denominations → validated against paid amount
2. Customer cash is added to system cash inventory
3. Change is calculated using existing system denominations
4. If exact change is not possible:
   → Partial change is returned
   → Remaining unpaid balance is clearly shown
```

**This reflects real-world cash handling, not an idealized system.**

---

## 👨‍💻 Author

**Nishkarsh Sahu**  
Backend Ruby on Rails Developer

📧 Email: nishkarshsahu007@gmail.com  
💼 LinkedIn: [linkedin.com/in/nishkarsh-sahu-b54ba8193](https://www.linkedin.com/in/nishkarsh-sahu-b54ba8193/)  
🐙 GitHub: [@nishkarshh013](https://github.com/nishkarshh013)

---

## 📄 License

MIT License

---

**Built with 💰 Real-World Billing Logic**