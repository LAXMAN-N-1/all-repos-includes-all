# Wezu Pass - Subscription System

## Quick Start Guide

### Overview
Wezu Pass is a premium subscription service that allows users to enjoy unlimited battery swaps with exclusive benefits. This system includes plan management, purchase flow, auto-renewal, and subscription management features.

### Key Features

#### ✨ User-Facing Features
- **Multiple Plans**: Daily (₹99), Weekly (₹499), Monthly (₹999)
- **Unlimited Swaps**: All plans include unlimited battery swaps
- **Priority Access**: Priority queue at battery stations
- **Exclusive Offers**: Member-only discounts and promotions
- **24/7 Support**: Dedicated customer support
- **Auto-Renewal**: Automatic subscription renewal (toggleable)
- **Easy Cancellation**: Cancel anytime with prorated refunds

#### 👨‍💼 Business Features
- **Subscription Management**: Track active subscriptions
- **Auto-Renewal System**: Automatic payment processing
- **Refund Management**: Prorated refunds on cancellation
- **Plan Comparison**: Side-by-side feature comparison
- **Renewal Reminders**: Automated notification system
- **Failover Handling**: Retry logic and grace period for failed payments

### File Structure

```
lib/features/wallet/
├── Wezupass.dart                          # Main exports
├── models/
│   ├── subscription_plan.dart             # Plan data model
│   ├── subscription.dart                  # Active subscription model
│   └── subscription_requests.dart         # Request/Response DTOs
├── services/
│   └── subscription_service.dart          # API client
├── providers/
│   └── subscription_provider.dart         # State management
├── screens/
│   ├── wezu_pass_screen.dart             # Main Wezu Pass screen
│   ├── subscription_purchase_screen.dart  # Purchase flow (3-step)
│   └── subscription_management_screen.dart # Manage active subscription
└── widgets/
    ├── plan_card.dart                     # Individual plan card
    └── plan_comparison.dart               # Plan comparison table
```

### Quick Implementation

#### 1. Import Wezu Pass
```dart
import 'package:wezu_customer_app/features/wallet/Wezupass.dart';
```

#### 2. Add Routes to main.dart
```dart
'/wezu-pass': (context) => const WezuPassScreen(),
'/subscription-purchase': (context) => SubscriptionPurchaseScreen(
  selectedPlan: ModalRoute.of(context)?.settings.arguments as SubscriptionPlan,
),
'/subscription-management': (context) => const SubscriptionManagementScreen(),
```

#### 3. Add Navigation Button
```dart
// In Dashboard or Navigation
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/wezu-pass'),
  child: const Text('Wezu Pass'),
)
```

#### 4. Access Subscription Info
```dart
// In any ConsumerWidget
final subscriptionState = ref.watch(subscriptionNotifierProvider);

if (subscriptionState.activeSubscription != null) {
  // User has active subscription
  final sub = subscriptionState.activeSubscription!;
  print('Plan: ${sub.planName}');
  print('Expires: ${sub.endDate}');
  print('Auto-Renew: ${sub.autoRenew}');
}
```

### Screens Overview

#### WezuPassScreen
**Location**: `screens/wezu_pass_screen.dart`
**Purpose**: Main Wezu Pass landing page

Features:
- Hero section with benefits
- Two tabs: "Plans" & "Compare"
- Benefits grid (4 main benefits)
- FAQ Accordion (4 common questions)
- Testimonials section
- Pull-to-refresh

Usage:
```dart
Navigator.push(context, 
  MaterialPageRoute(builder: (_) => const WezuPassScreen())
);
```

#### SubscriptionPurchaseScreen
**Location**: `screens/subscription_purchase_screen.dart`
**Purpose**: Guided purchase flow

3-Step Flow:
1. **Review**: Confirm plan details & enable auto-renewal
2. **Payment**: Select payment method (Card, UPI, Wallet, Net Banking)
3. **Confirm**: Show success with subscription details

Usage:
```dart
Navigator.push(context,
  MaterialPageRoute(
    builder: (_) => SubscriptionPurchaseScreen(
      selectedPlan: plan,
    )
  )
);
```

#### SubscriptionManagementScreen
**Location**: `screens/subscription_management_screen.dart`
**Purpose**: Manage active subscription

Features:
- Subscription card with validity
- Detailed info: start date, end date, swaps used
- Auto-renewal toggle
- Renewal countdown
- Cancellation with feedback form

Usage:
```dart
Navigator.push(context,
  MaterialPageRoute(builder: (_) => const SubscriptionManagementScreen())
);
```

### API Endpoints

All endpoints use base URL: `{baseUrl}/api/v1`

```
GET    /subscriptions/plans              # Fetch available plans
GET    /subscriptions/active             # Get active subscription
POST   /subscriptions/purchase           # Purchase subscription
PUT    /subscriptions/{id}/auto-renew    # Toggle auto-renewal
PUT    /subscriptions/{id}/cancel        # Cancel subscription
POST   /subscriptions/{id}/renew         # Manual renewal
GET    /subscriptions/history            # Get subscription history
```

### State Management

#### Accessing Subscription State
```dart
// Watch the provider
final subscriptionState = ref.watch(subscriptionNotifierProvider);

// Available properties
subscriptionState.activeSubscription    // Current active subscription
subscriptionState.plans                 // All available plans
subscriptionState.isLoading             // Loading indicator
subscriptionState.error                 // Error message if any
subscriptionState.lastPurchase          // Last purchase response
```

#### Common Operations
```dart
// Purchase subscription
await ref.read(subscriptionNotifierProvider.notifier).purchaseSubscription(
  planId: plan.id,
  paymentMethodId: 'payment_method_id',
  autoRenew: true,
);

// Toggle auto-renewal
await ref.read(subscriptionNotifierProvider.notifier).updateAutoRenewal(
  subscriptionId,
  true, // enabled
);

// Cancel subscription
await ref.read(subscriptionNotifierProvider.notifier).cancelSubscription(
  subscriptionId: subscriptionId,
  reason: 'Too expensive',
  feedback: 'Optional feedback...',
);

// Refresh data
ref.read(subscriptionNotifierProvider.notifier).refetchPlans();
ref.read(subscriptionNotifierProvider.notifier).refetchActiveSubscription();
```

### Data Models

#### SubscriptionPlan
```dart
SubscriptionPlan(
  id: 1,
  name: 'Monthly Pass',
  description: 'Unlimited swaps for 30 days',
  type: PlanType.monthly,
  price: 999.0,
  durationDays: 30,
  unlimitedSwaps: true,
  benefits: ['Unlimited Swaps', 'Priority Access', '24/7 Support'],
  originalPrice: 1299.0,
  isPopular: true,
)
```

#### Subscription
```dart
Subscription(
  id: 1,
  userId: 123,
  planId: 1,
  planName: 'Monthly Pass',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 30)),
  status: SubscriptionStatus.active,
  autoRenew: true,
  nextRenewalDate: DateTime.now().add(Duration(days: 30)),
  swapsUsed: 5,
  swapsLimit: 0, // 0 = unlimited
)
```

### Dark Mode Support
All screens and widgets support both light and dark modes automatically using:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### Error Handling
All API calls use try-catch with user-friendly error messages:
```dart
try {
  await ref.read(subscriptionNotifierProvider.notifier)
    .purchaseSubscription(...);
} catch (e) {
  // Error handled in state
  final error = ref.read(subscriptionNotifierProvider).error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error ?? 'Error occurred'))
  );
}
```

### Customization

#### Plan Display Format
```dart
// Price display
plan.displayPrice              // "₹999"
plan.durationDisplay           // "/month"

// Savings calculation
plan.savingsPercentage         // 23.0 (for 23% off)

// Swap info
plan.unlimitedSwaps            // true/false
plan.swapsIncluded             // 0 or count
```

#### Subscription Properties
```dart
subscription.isActive          // true if active
subscription.isExpired         // true if expired
subscription.daysRemaining     // Duration object
subscription.daysRemainingCount // count (e.g., 15)
subscription.renewsSoon        // true if <= 3 days
subscription.swapsRemaining    // count if limited
subscription.isUnlimited       // true for unlimited
```

### Next Steps

1. **Configure API Endpoints**
   - Update `lib/core/constants/api_constants.dart`
   - Add subscription endpoints

2. **Integrate Payment Gateway**
   - Add Razorpay/Stripe integration
   - Link payment methods to purchase flow

3. **Setup Notifications**
   - Schedule renewal reminders
   - Send purchase confirmations
   - Email notifications

4. **Add to Navigation**
   - Link from dashboard
   - Add profile menu item
   - Create wallet widget

5. **Testing**
   - Test all purchase scenarios
   - Verify auto-renewal logic
   - Test cancellation flow

### Troubleshooting

**Q: Subscriptions not loading?**
- Check API endpoint configuration
- Verify network connectivity
- Check authentication headers

**Q: Purchase keeps failing?**
- Verify payment method is selected
- Check payment gateway configuration
- Review error logs in console

**Q: Auto-renewal not triggering?**
- Verify payment method is saved
- Check renewal dates in database
- Enable background task execution

###Support
For detailed documentation, see `WEZU_PASS_DOCUMENTATION.md`

