# WEZU Dealer Portal — Frontend

Premium enterprise dealer management portal for the WEZU battery swapping network. Built with Flutter Web using the **Electric Grid** design system.

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

1. **Clone the repo**:
   ```bash
   git clone https://github.com/LAXMAN-N-1/wezu_dealer_portal.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run locally**:
   ```bash
   flutter run -d chrome
   ```

5. **Build for production**:
   ```bash
   flutter build web
   ```

## 🏗 Project Structure
- `lib/core`: Routing, theme, and shared widgets.
- `lib/features`: Module-based architecture (Auth, Dashboard, Stations, etc.).
- `lib/widgets`: Reusable UI components.

## 📄 License
Internal use by WEZU Tech.
