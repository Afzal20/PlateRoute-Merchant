# PlateRoute Merchant Mobile Application

Production-ready, high-performance Flutter tablet and mobile application for the **PlateRoute** food delivery platform, tailored specifically for **Restaurant Owners & Managers**. Built for real-time order processing, menu management, and business analytics.

---

## 1. Architectural Overview & Design System

### 1.1 Architecture
The application is structured using **Feature-First Clean Architecture** powered by **Riverpod 2.x**:
- `lib/core/`: Networking (`ApiClient`, `WebSocketClient`), Router (`GoRouter`), and Storage.
- `lib/features/`: Isolated feature modules such as `auth`, `live_orders`, `menu_editor`, `analytics`, and `store_settings`.

### 1.2 Design Tokens & Rules
- **Color Palette:**
  - **Plate Blue** (`#2563EB` light / `#60A5FA` dark) as Primary brand token.
  - **Alert Red** (`#EF4444`) for urgent order actions or delays.
  - Dark Canvas (`#0A0F1D`) and Dark Surface (`#121B2E`) with calibrated text hierarchy.
- **Layout:** Optimized for both mobile devices (portrait) and point-of-sale tablets (landscape).
- **Typography & Tabular Figures:** Proportional Inter font for text, with `FontFeature.tabularFigures()` applied to all financial metrics and order timers.

---

## 2. Core Features & Screen Catalog

| Module | Feature Description |
| :--- | :--- |
| **Auth** | Secure login for restaurant staff, role-based access control (Manager vs Staff). |
| **Live Orders** | Real-time Kanban-style order board (New, Preparing, Ready, Handed Over) via WebSockets. |
| **Order Details** | Deep dive into specific order items, special instructions, and customer details. |
| **Menu Manager** | Toggle item availability, update prices, and manage categories on the fly. |
| **Analytics** | Dashboard displaying daily revenue, top-selling items, and completion ratios. |
| **Store Settings** | Manage store operating hours, temporary closures, and notification preferences. |

---

## 3. Technology Stack

- **Flutter SDK:** `>=3.3.0 <4.0.0`
- **State Management:** `flutter_riverpod: ^2.5.1`
- **Routing:** `go_router: ^14.2.0`
- **Networking:** `dio: ^5.4.3+1` & `web_socket_channel: ^3.0.0`
- **Charts:** Native Flutter charting libraries for analytics visualization.

---

## 4. Environment & Getting Started

1. Clone repository and navigate to workspace:
   ```bash
   cd apps/merchant
   ```

2. Setup Environment:
   ```bash
   cp .env.example .env
   # Edit values (dev defaults point at 10.0.2.2 emulator host)
   ```

3. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

4. Run in development environment:
   ```bash
   flutter run -d chrome
   # or for tablet/mobile emulator
   flutter run
   ```

> **Note:** Implementation plan and internal technical documentation lives in `docs/IMPLEMENTATION_PLAN.md`.
