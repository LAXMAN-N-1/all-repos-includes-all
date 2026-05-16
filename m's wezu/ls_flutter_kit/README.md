# LS Flutter Kit

A **premium, production-grade Flutter UI toolkit** with glassmorphism widgets, responsive utilities, Dio-based networking, secure auth flow, and 50+ reusable components extracted from 15+ real-world applications.

## ✨ Features

| Category | Components |
|----------|-----------|
| 🎨 **Theme System** | AppColors, AppTypography, AppSpacing, AppRadius, AppShadows, ThemeBuilder (light+dark), context extensions |
| 📐 **Responsive** | Breakpoints, ResponsiveBuilder, `context.isMobile/isTablet/isDesktop`, `context.responsive()` |
| 🔤 **Extensions** | String (capitalize, truncate, initials, slug), DateTime (timeAgo, format), Number (toCurrency, toCompact) |
| ✅ **Validators** | Composable validators: required, email, phone, password, minLength, pattern, match |
| 🌐 **Networking** | Dio ApiClient, ApiException, AuthInterceptor (JWT+refresh), RetryInterceptor, LoggingInterceptor |
| 💾 **Storage** | SecureStorage, LocalStorage (SharedPreferences), CacheManager (TTL) |
| 🪟 **Glass Widgets** | GlassContainer, GlassButton, GlassTextField, GlassScaffold |
| 💬 **Feedback** | SkeletonLoader, SkeletonCard, SkeletonList, AdvancedToast, EmptyState, ErrorState |
| 🔘 **Buttons** | BouncyButton, GradientButton, LoadingButton, IconActionButton |
| 🃏 **Cards** | BouncyCard, MetricCard, InfoCard, ProductCard |
| ✏️ **Inputs** | AnimatedSearchBar, OtpInput, PhoneInput, SearchableDropdown, MediaPickerWidget |
| 📐 **Layout** | AdminShell, SectionHeader, ResponsiveGrid, PageHeader, ConfirmationModal, InfiniteScrollView, SlidableListItem, StandardBottomSheet |
| 🛡 **Hardware** | PermissionGate |
| 🗺 **Navigation** | AdminSidebar, SideMenuDrawer, ContextMenu |
| 📊 **Charts** | LineChartWidget, BarChartWidget, DonutChartWidget (using fl_chart) |
| 📑 **Tables** | DataTableView (paginated & responsive) |
| 🔐 **Auth Logic** | AuthState, AuthNotifier (Riverpod), AuthGuard mixin |
| 📱 **Auth Screens** | LoginScreenTemplate, SignupScreenTemplate, OtpScreenTemplate, ForgotPasswordTemplate |
| 🚀 **Init Screens** | SplashScreenTemplate, OnboardingTemplate |
| 🗺 **Router** | RouteTransitions (fade, slideRight, slideUp, scale) |
| 🛠 **Services** | Logger, CsvExportService |

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ls_flutter_kit:
    git:
      url: https://github.com/LAXMAN-N-1/flutter_ui_kit.git
```

## 🚀 Quick Start

```dart
import 'package:ls_flutter_kit/ls_flutter_kit.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeBuilder.light(),
    darkTheme: ThemeBuilder.dark(),
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Column(
        children: [
          GlassContainer(
            child: MetricCard(
              label: 'Total Revenue',
              value: 245000.toCurrency(),
              delta: '+12.5%',
              icon: Icons.trending_up,
            ),
          ),
          GradientButton(
            label: 'Get Started',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
```

## 🎨 Theme System

```dart
// One-liner light & dark themes
MaterialApp(
  theme: ThemeBuilder.light(primaryColor: Color(0xFF6366F1)),
  darkTheme: ThemeBuilder.dark(primaryColor: Color(0xFF6366F1)),
);

// Context extensions
Text('Hello', style: context.titleLarge);
if (context.isMobile) { /* mobile layout */ }
```

## 🌐 Networking

```dart
final api = ApiClient(
  baseUrl: 'https://api.example.com/v1',
  interceptors: [
    AuthInterceptor(getToken: () => authNotifier.getToken()),
    RetryInterceptor(maxRetries: 3),
    LoggingInterceptor(),
  ],
);

try {
  final response = await api.get('/users');
} on ApiException catch (e) {
  if (e.isAuth) { /* redirect to login */ }
}
```

## ✅ Form Validators

```dart
TextFormField(
  validator: Validators.compose([
    Validators.required('Email is required'),
    Validators.email(),
  ]),
)
```

## 🏗 Architecture

```
lib/
├── src/
│   ├── core/           # Theme, responsive, extensions, validators
│   ├── network/        # Dio client, interceptors, exceptions
│   ├── storage/        # Secure + local + cache
│   ├── widgets/        # Glass, feedback, buttons, cards, inputs, layout
│   ├── auth/           # State management + route guard
│   ├── router/         # Page transitions
│   └── services/       # Logger, CSV export
└── ls_flutter_kit.dart # Barrel export
```

## 📄 License

MIT License © 2026 Gannetz Technologies
