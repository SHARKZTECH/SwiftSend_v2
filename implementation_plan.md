# SwiftSend Kenya - Implementation Plan

A mobile-based parcel delivery platform for Nairobi, Kenya that connects boda boda riders, businesses, and end customers. This plan outlines the technical implementation strategy for building the complete system.

---

## Executive Summary

SwiftSend is designed to formalize last-mile delivery using local boda boda riders. Key features include:

- Fast booking & price negotiation
- Real-time GPS tracking
- Secure mobile payments (M-Pesa, Airtel Money)
- Delivery confirmation with photo & signature
- Commission-based revenue model (10-20%)

---

## Technology Stack

| Layer              | Technology                         |
| ------------------ | ---------------------------------- |
| Mobile App         | Flutter (Android-first, iOS later) |
| Admin Panel        | Next.js + shadcn/ui + Tremor       |
| Backend            | Supabase (BaaS)                    |
| Database           | PostgreSQL (via Supabase)          |
| Authentication     | Supabase Auth (Email/Password)     |
| Real-time          | Supabase Realtime                  |
| Maps & Navigation  | OpenStreetMap (flutter_map)        |
| Payments           | M-Pesa (primary), Airtel Money     |
| Push Notifications | Supabase Realtime + Local Notifs   |
| Storage            | Supabase Storage                   |

---

## Proposed Changes

### Phase 1: Project Foundation & Setup

#### [NEW] Flutter Project Structure

```
swiftsend/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── services/
│   ├── features/
│   │   ├── auth/
│   │   ├── delivery/
│   │   ├── chat/
│   │   ├── tracking/
│   │   ├── payments/
│   │   ├── ratings/
│   │   └── notifications/
│   ├── models/
│   ├── providers/
│   └── widgets/
├── android/
├── ios/
├── test/
└── pubspec.yaml
```

#### [NEW] Supabase Database Schema

```sql
-- Core tables for SwiftSend

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  phone_number TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  user_type TEXT CHECK (user_type IN ('rider', 'business', 'customer')) NOT NULL,
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rider-specific information
CREATE TABLE public.riders (
  id UUID REFERENCES public.profiles PRIMARY KEY,
  national_id TEXT,
  driving_license TEXT,
  ntsa_permit TEXT,
  vehicle_registration TEXT,
  vehicle_type TEXT DEFAULT 'motorcycle',
  insurance_document TEXT,
  verification_status TEXT CHECK (verification_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  is_online BOOLEAN DEFAULT FALSE,
  current_location GEOGRAPHY(POINT),
  rating_average DECIMAL(2,1) DEFAULT 0,
  total_deliveries INT DEFAULT 0,
  wallet_balance DECIMAL(10,2) DEFAULT 0
);

-- Business-specific information
CREATE TABLE public.businesses (
  id UUID REFERENCES public.profiles PRIMARY KEY,
  business_name TEXT NOT NULL,
  business_type TEXT,
  kra_pin TEXT,
  business_permit TEXT,
  verification_status TEXT CHECK (verification_status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  address TEXT,
  location GEOGRAPHY(POINT)
);

-- Delivery orders
CREATE TABLE public.deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES public.profiles NOT NULL,
  rider_id UUID REFERENCES public.riders,
  receiver_name TEXT NOT NULL,
  receiver_phone TEXT NOT NULL,
  pickup_address TEXT NOT NULL,
  pickup_location GEOGRAPHY(POINT) NOT NULL,
  dropoff_address TEXT NOT NULL,
  dropoff_location GEOGRAPHY(POINT) NOT NULL,
  package_description TEXT,
  package_size TEXT CHECK (package_size IN ('small', 'medium', 'large')),
  initial_price DECIMAL(10,2),
  agreed_price DECIMAL(10,2),
  commission_rate DECIMAL(4,2) DEFAULT 0.15,
  platform_fee DECIMAL(10,2),
  status TEXT CHECK (status IN ('pending', 'negotiating', 'accepted', 'picked_up', 'in_transit', 'delivered', 'cancelled', 'disputed')) DEFAULT 'pending',
  pickup_photo_url TEXT,
  delivery_photo_url TEXT,
  signature_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  picked_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ
);

-- Price negotiations
CREATE TABLE public.negotiations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries NOT NULL,
  rider_id UUID REFERENCES public.riders NOT NULL,
  proposed_price DECIMAL(10,2) NOT NULL,
  status TEXT CHECK (status IN ('pending', 'accepted', 'rejected', 'countered')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat messages
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries NOT NULL,
  sender_id UUID REFERENCES public.profiles NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT CHECK (message_type IN ('text', 'image', 'location')) DEFAULT 'text',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

-- Location tracking history
CREATE TABLE public.location_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries NOT NULL,
  rider_id UUID REFERENCES public.riders NOT NULL,
  location GEOGRAPHY(POINT) NOT NULL,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ratings and reviews
CREATE TABLE public.ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries NOT NULL,
  rater_id UUID REFERENCES public.profiles NOT NULL,
  rated_id UUID REFERENCES public.profiles NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions/Payments
CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries,
  user_id UUID REFERENCES public.profiles NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  transaction_type TEXT CHECK (transaction_type IN ('payment', 'payout', 'refund', 'commission')) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('mpesa', 'airtel_money', 'wallet')),
  external_reference TEXT,
  status TEXT CHECK (status IN ('pending', 'completed', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Disputes
CREATE TABLE public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID REFERENCES public.deliveries NOT NULL,
  raised_by UUID REFERENCES public.profiles NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT CHECK (status IN ('open', 'under_review', 'resolved', 'closed')) DEFAULT 'open',
  resolution TEXT,
  resolved_by UUID REFERENCES public.profiles,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

-- Push notification tokens
CREATE TABLE public.push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles NOT NULL,
  token TEXT NOT NULL,
  device_type TEXT CHECK (device_type IN ('android', 'ios')) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### Phase 2: User Management Module

#### [NEW] `lib/features/auth/`

| File                                        | Purpose                                  |
| ------------------------------------------- | ---------------------------------------- |
| `screens/splash_screen.dart`                | App entry point with auth check          |
| `screens/onboarding_screen.dart`            | First-time user onboarding               |
| `screens/phone_input_screen.dart`           | Phone number entry for OTP               |
| `screens/otp_verification_screen.dart`      | OTP verification                         |
| `screens/user_type_selection_screen.dart`   | Role selection (Rider/Business/Customer) |
| `screens/rider_registration_screen.dart`    | Rider document upload                    |
| `screens/business_registration_screen.dart` | Business verification                    |
| `providers/auth_provider.dart`              | State management for auth                |
| `services/auth_service.dart`                | Supabase auth integration                |

---

### Phase 3: Core Delivery System

#### [NEW] `lib/features/delivery/`

| File                                   | Purpose                        |
| -------------------------------------- | ------------------------------ |
| `screens/create_delivery_screen.dart`  | New delivery booking form      |
| `screens/delivery_list_screen.dart`    | List of active/past deliveries |
| `screens/delivery_details_screen.dart` | Individual delivery view       |
| `screens/available_jobs_screen.dart`   | Rider job feed                 |
| `screens/negotiate_price_screen.dart`  | Price negotiation interface    |
| `providers/delivery_provider.dart`     | Delivery state management      |
| `services/delivery_service.dart`       | Supabase delivery operations   |

---

### Phase 4: GPS & Tracking Features

#### [NEW] `lib/features/tracking/`

| File                                 | Purpose                    |
| ------------------------------------ | -------------------------- |
| `screens/live_tracking_screen.dart`  | Real-time map tracking     |
| `screens/share_location_screen.dart` | Customer location sharing  |
| `widgets/map_widget.dart`            | Google Maps integration    |
| `services/location_service.dart`     | GPS & geolocation          |
| `services/tracking_service.dart`     | Real-time location updates |

---

### Phase 5: Payment & Wallet System

#### [NEW] `lib/features/payments/`

| File                                      | Purpose                  |
| ----------------------------------------- | ------------------------ |
| `screens/wallet_screen.dart`              | Rider wallet & balance   |
| `screens/payment_screen.dart`             | Payment initiation       |
| `screens/transaction_history_screen.dart` | Past transactions        |
| `services/mpesa_service.dart`             | Safaricom Daraja API     |
| `services/airtel_service.dart`            | Airtel Money integration |
| `providers/wallet_provider.dart`          | Wallet state management  |

---

### Phase 6: Delivery Confirmation & Rating

#### [NEW] `lib/features/confirmation/`

| File                                    | Purpose                   |
| --------------------------------------- | ------------------------- |
| `screens/proof_of_delivery_screen.dart` | Photo & signature capture |
| `screens/rating_screen.dart`            | Rate & review interface   |
| `screens/dispute_screen.dart`           | Raise dispute form        |
| `widgets/signature_pad.dart`            | Digital signature widget  |
| `widgets/camera_capture.dart`           | Photo capture widget      |

---

### Phase 7: Notification System

#### [NEW] `lib/features/notifications/`

| File                                       | Purpose             |
| ------------------------------------------ | ------------------- |
| `screens/notifications_screen.dart`        | Notification center |
| `services/notification_service.dart`       | FCM integration     |
| `services/local_notification_service.dart` | Local notifications |

---

### Phase 8: Admin Panel (Next.js Web Dashboard)

> [!NOTE]
> The admin panel will be a separate **Next.js** web application connected to the same Supabase backend.

#### [NEW] `swiftsend-admin/` (separate repository)

```
swiftsend-admin/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx                    # Dashboard home
│   │   ├── riders/
│   │   │   ├── page.tsx                # Riders list
│   │   │   └── [id]/page.tsx           # Rider details
│   │   ├── businesses/
│   │   │   ├── page.tsx                # Businesses list
│   │   │   └── [id]/page.tsx           # Business details
│   │   ├── deliveries/
│   │   │   ├── page.tsx                # Deliveries list
│   │   │   ├── live/page.tsx           # Live tracking map
│   │   │   └── [id]/page.tsx           # Delivery details
│   │   ├── disputes/
│   │   │   └── page.tsx                # Disputes queue
│   │   ├── payouts/
│   │   │   └── page.tsx                # Payout management
│   │   └── settings/
│   │       └── page.tsx                # App configuration
│   ├── components/
│   │   ├── ui/                         # shadcn/ui components
│   │   ├── charts/                     # Tremor/Recharts
│   │   └── tables/                     # Data tables
│   ├── lib/
│   │   ├── supabase.ts                 # Supabase client
│   │   └── utils.ts
│   └── types/
├── package.json
└── tailwind.config.ts
```

**Key Dependencies:**

- `@supabase/supabase-js` - Backend connection
- `shadcn/ui` - UI components
- `tremor` - Dashboard charts
- `@tanstack/react-table` - Data tables
- `react-map-gl` - Live delivery map

**Admin Features:**

| Feature             | Description                                                   |
| ------------------- | ------------------------------------------------------------- |
| **Dashboard**       | KPIs: active deliveries, revenue, rider count, charts         |
| **Riders**          | Approve/reject applications, view documents, suspend accounts |
| **Businesses**      | Verify businesses, manage accounts                            |
| **Live Deliveries** | Real-time map with active deliveries                          |
| **Disputes**        | Queue with resolution workflow                                |
| **Payouts**         | Rider earnings, trigger M-Pesa payouts                        |
| **Settings**        | Commission rates (10-20%), app configuration                  |

---

## Verification Plan

### Automated Tests

Since this is a greenfield project, we will establish testing infrastructure as part of the implementation:

```bash
# Run Flutter unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

**Test Categories to Implement:**

1. **Unit Tests**: Services, providers, models
2. **Widget Tests**: UI components
3. **Integration Tests**: Full user flows

### Manual Verification

> [!NOTE]
> Manual testing will be required for:
>
> - M-Pesa/Airtel Money payment flows (sandbox testing)
> - GPS tracking accuracy on physical devices
> - Push notification delivery
> - Photo/signature capture quality

**User Flow Testing:**

1. **Business Flow**: Register → Create delivery → Track → Confirm
2. **Rider Flow**: Register → Verify → Go online → Accept job → Navigate → Deliver → Get paid
3. **Customer Flow**: Receive notification → Share location → Track → Receive → Rate

### API Testing

- Use Supabase dashboard for database verification
- M-Pesa sandbox for payment testing
- Firebase Console for FCM testing

---

## Non-Functional Requirements Compliance

| Requirement               | Implementation                  |
| ------------------------- | ------------------------------- |
| High Availability (99.9%) | Supabase managed infrastructure |
| Fast Response             | Optimistic UI updates, caching  |
| Data Encryption           | HTTPS, Supabase RLS policies    |
| Scalability               | Supabase auto-scaling           |
| User-Friendly             | Material Design 3, intuitive UX |

---

## Implementation Timeline (Estimated)

| Phase   | Duration  | Deliverable                    |
| ------- | --------- | ------------------------------ |
| Phase 1 | 1 week    | Project setup, database schema |
| Phase 2 | 2 weeks   | User auth & registration       |
| Phase 3 | 2 weeks   | Core delivery system           |
| Phase 4 | 1.5 weeks | GPS tracking                   |
| Phase 5 | 2 weeks   | Payments integration           |
| Phase 6 | 1 week    | Confirmation & ratings         |
| Phase 7 | 1 week    | Notifications                  |
| Phase 8 | 2 weeks   | Admin panel                    |
| Phase 9 | 1.5 weeks | Testing & deployment           |

**Total Estimated Duration: 14-16 weeks**

---

## Next Steps

1. **Review and approve this implementation plan**
2. Initialize Flutter project with required dependencies
3. Set up Supabase project and database schema
4. Begin Phase 1 implementation

---

## Confirmed Decisions

| Decision         | Choice                                          |
| ---------------- | ----------------------------------------------- |
| Mobile Stack     | Flutter + Supabase                              |
| Admin Panel      | Next.js (separate repo)                         |
| Payment Priority | M-Pesa primary, Airtel Money secondary          |
| MVP Scope        | All features with mocked 3rd-party integrations |

---

## MVP Approach: Mocked Integrations

For the pilot, we'll implement **all features** but mock external services:

| Service             | MVP Behavior                                | Production           |
| ------------------- | ------------------------------------------- | -------------------- |
| **M-Pesa (Daraja)** | Mock payment success/failure responses      | Safaricom Daraja API |
| **Airtel Money**    | Mock payment responses                      | Airtel Money API     |
| **Maps**            | **OpenStreetMap** (free, no API key)        | Google Maps Platform |
| **Notifications**   | **Supabase Realtime** + Local Notifications | Firebase FCM         |
| **Auth**            | Email/Password (skip OTP)                   | Same or Phone OTP    |

**Free Workarounds Strategy:**

1.  **Maps**: Use `flutter_map` package with OpenStreetMap tiles. It's completely free and requires no API key.
2.  **Notifications**: Instead of FCM, the app will listen to `Supabase Realtime` channels. When an event occurs (e.g., `INSERT` on `messages` table), the app will trigger a `flutter_local_notification`. This works perfectly for the pilot while the app is running.

**Mock Payment Service:**

```dart
// lib/core/services/mock_payment_service.dart
class MockPaymentService {
  Future<PaymentResult> initiatePayment(double amount) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    return PaymentResult(
      success: true,
      transactionId: 'MOCK_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Payment simulated successfully',
    );
  }
}
```

> [!IMPORTANT]
> When ready for production, swap `MockPaymentService` with `DarajaPaymentService` via dependency injection.
