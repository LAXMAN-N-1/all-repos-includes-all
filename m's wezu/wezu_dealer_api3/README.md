# WEZU Dealer Portal API3 — Frontend (Separate Copy)

Premium enterprise dealer management portal for the WEZU battery swapping network. Built with Flutter Web using the **Electric Grid** design system.

This app copy is intentionally separated from `wezu_dealer` and targets `https://api3.powerfrill.com` by default.

## 🚀 Features
- **8-Stage Onboarding Wizard**: Real-time tracking of dealer verification.
- **Dynamic Dashboard**: Animated KPIs and performance charts.
- **Live Inventory & Sales**: Real-time synchronization with FastAPI backend.
- **Support & Documents**: Integrated ticket management and KYC handling.
- **Role-Based Access**: Multi-user management with permissions.

## 🛠 Tech Stack
- **Framework**: Flutter (Web)
- **State Management**: Riverpod (with Freezed & StateNotifier)
- **Networking**: Dio
- **Routing**: GoRouter
- **Icons**: Lucide Icons
- **Theming**: Custom "Electric Grid" Dark Mode

## 🏁 Getting Started

1. **Go to this app directory**:
   ```bash
   cd wezu_dealer_api3
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run locally**:
   ```bash
   flutter run -d chrome --web-port 5180
   ```

4. **Build for production**:
   ```bash
   flutter build web
   ```

## 🔧 Environment

Default `.env` for this copy:

```env
API_ROOT_URL=https://api3.powerfrill.com
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
APP_ENV=production
```

Optional overrides:

```env
API_BASE_URL=https://api3.powerfrill.com/api/v1
API_VERSION_PATH=/api/v1
```

`API_BASE_URL` overrides `API_ROOT_URL + API_VERSION_PATH`.

Auth note (Supabase cutover):
- This app now signs in against Supabase (`/auth/v1/token`) and uses the returned bearer token for backend APIs.
- Backend auth introspection is via `GET /api/v1/auth/me`.
- Legacy dealer auth routes are no longer used.

## 🏗 Project Structure
- `lib/core`: Routing, theme, and shared widgets.
- `lib/features`: Module-based architecture (Auth, Dashboard, Stations, etc.).
- `lib/widgets`: Reusable UI components.

## 📄 License
Internal use by WEZU Tech.
