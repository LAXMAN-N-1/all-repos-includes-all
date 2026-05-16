# Wezu Pass - Subscription System Documentation

## Overview
Wezu Pass is a comprehensive subscription-based unlimited battery swap system designed to increase user retention and provide predictable recurring revenue. Users can choose between Daily, Weekly, and Monthly plans with unlimited swaps and exclusive benefits.

## System Architecture

### 1. Data Models

#### SubscriptionPlan
- **File**: `models/subscription_plan.dart`
- **Purpose**: Represents available subscription plans
- **Key Properties**:
  - `id`: Unique plan identifier
  - `name`: Plan display name (e.g., "Monthly Pass")
  - `type`: PlanType enum (daily, weekly, monthly)
  - `price`: Plan cost in rupees
  - `durationDays`: Validity period
  - `unlimitedSwaps`: Boolean for unlimited vs limited swaps
  - `benefits`: List of plan benefits
  - `isPopular`: Flag for "Most Popular" badge
  - `originalPrice`: For calculating savings percentage

#### Subscription
- **File**: `models/subscription.dart`
- **Purpose**: Represents user's active or past subscriptions
- **Key Properties**:
  - `id`: Subscription ID
  - `userId`: Associated user
  - `planId`: Purchased plan ID
  - `startDate`: Subscription start
  - `endDate`: Subscription expiry
  - `status`: SubscriptionStatus enum (active, expired, cancelled, pending)
  - `autoRenew`: Auto-renewal toggle
  - `nextRenewalDate`: Upcoming renewal date
  - `swapsUsed`: Swaps consumed (if limited)
  - `swapsLimit`: Maximum allowed swaps (0 for unlimited)

#### SubscriptionRequests
- **File**: `models/subscription_requests.dart`
- **Purpose**: Request/Response DTOs for API communication
- **Classes**:
  - `SubscriptionPurchaseRequest`: Plan purchase request
  - `SubscriptionPurchaseResponse`: Purchase confirmation
  - `SubscriptionCancellationRequest`: Cancellation request with reason
  - `SubscriptionCancellationResponse`: Cancellation confirmation & refund

### 2. Services

#### SubscriptionService
- **File**: `services/subscription_service.dart`
- **Purpose**: Handles all API communication with subscription endpoints
- **Key Methods**:
  ```dart
  // Fetch available plans
  getSubscriptionPlans()
  
  // Get user's active subscription
  getActiveSubscription()
  
  // Purchase a subscription
  purchaseSubscription(SubscriptionPurchaseRequest request)
  
  // Update auto-renewal status
  updateAutoRenewal(int subscriptionId, bool autoRenew)
  
  // Cancel subscription
  cancelSubscription(int subscriptionId, SubscriptionCancellationRequest request)
  
  // Manual renewal
  manualRenewal(int subscriptionId)
  
  // Get subscription history
  getSubscriptionHistory()
  
  // Validate plan eligibility
  validatePlanEligibility(int planId)
  ```

### 3. State Management (Riverpod)

#### SubscriptionNotifier
- **File**: `providers/subscription_provider.dart`
- **Purpose**: Manages subscription state and business logic
- **State Shape**:
  ```dart
  SubscriptionState {
    Subscription? activeSubscription;
    List<SubscriptionPlan> plans;
    bool isLoading;
    String? error;
    SubscriptionPurchaseResponse? lastPurchase;
  }
  ```
- **Key Operations**:
  - Load plans and active subscription
  - Execute purchase transaction
  - Toggle auto-renewal
  - Handle cancellation
  - Manual renewal
  - Error management

#### Providers
- `subscriptionServiceProvider`: Provides SubscriptionService instance
- `subscriptionPlansProvider`: FutureProvider for available plans
- `activeSubscriptionProvider`: FutureProvider for active subscription
- `subscriptionHistoryProvider`: FutureProvider for subscription history
- `subscriptionNotifierProvider`: StateNotifierProvider for main state

### 4. UI Components

#### Screens

**a) WezuPassScreen** (`screens/wezu_pass_screen.dart`)
- Hero section with benefits overview
- Two tabs: "Plans" and "Compare"
- Benefits grid (Unlimited Swaps, Priority Access, Exclusive Offers, 24/7 Support)
- FAQ Accordion (expandable sections)
- User testimonials carousel
- Pull-to-refresh functionality
- Current plan status indicator

**b) SubscriptionPurchaseScreen** (`screens/subscription_purchase_screen.dart`)
- Multi-step purchase flow (3 steps)
  - Step 1: Review selected plan
  - Step 2: Choose payment method
  - Step 3: Purchase confirmation
- Plan details display
- Auto-renewal checkbox
- Payment method selection (Card, UPI, Wallet, Net Banking)
- Price breakdown
- Success confirmation with subscription details

**c) SubscriptionManagementScreen** (`screens/subscription_management_screen.dart`)
- Current subscription card (gradient background)
- Subscription details display
- Auto-renewal toggle
- Renewal date countdown
- Cancellation dialog with reason selection
- Feedback form for cancellation
- Empty state for inactive users

#### Widgets

**a) PlanCard** (`widgets/plan_card.dart`)
- Individual plan card component
- Displays: name, description, price, benefits
- "Most Popular" badge
- "Current Plan" indicator
- Select button with disabled state for current plan
- Visual styling for dark/light mode

**b) PlanComparisonTable** (`widgets/plan_comparison.dart`)
- Side-by-side plan comparison
- Feature matrix view
- PageView for horizontal scrolling
- Selectable cards
- Feature comparison: swaps, duration, priority access, support

### 5. API Integration

#### Endpoints
```
GET    /api/v1/subscriptions/plans
POST   /api/v1/subscriptions/purchase
GET    /api/v1/subscriptions/active
PUT    /api/v1/subscriptions/{id}/auto-renew
PUT    /api/v1/subscriptions/{id}/cancel
POST   /api/v1/subscriptions/{id}/renew
GET    /api/v1/subscriptions/history
GET    /api/v1/subscriptions/plans/{id}/eligibility
```

#### Response Format Examples

**Get Plans Response**:
```json
[
  {
    "id": 1,
    "name": "Daily Pass",
    "description": "Unlimited Swaps for 24 hours",
    "type": "daily",
    "price": 99.0,
    "duration_days": 1,
    "unlimited_swaps": true,
    "swaps_included": 0,
    "benefits": ["Unlimited Swaps", "Priority Support"],
    "original_price": 150.0,
    "is_popular": false
  }
]
```

**Purchase Response**:
```json
{
  "subscription_id": 123,
  "transaction_id": "txn_abc123",
  "amount": 999.0,
  "start_date": "2025-02-23T10:00:00Z",
  "end_date": "2025-03-23T10:00:00Z",
  "status": "active"
}
```

## Business Logic

### Plan Eligibility
- Check if user can purchase specific plan
- Validate existing subscriptions
- Handle plan upgrade/downgrade logic

### Auto-Renewal System
- Toggle enabled/disabled by user
- Automatic payment processing on renewal date
- Retry logic for failed payments (3 attempts)
- Grace period of 3 days after failure
- Reminder notifications:
  - 3 days before renewal
  - 1 day before renewal

### Swap Management
- Track swaps used vs allowed
- Unlimited vs limited swap enforcement
- Reset swap counter on renewal

### Cancellation Logic
- Immediate cancellation vs end-of-period
- Prorated refund calculation
- Continued access until period end
- Feedback collection
- Email confirmation

### Upgrade/Downgrade
- Overlapping subscription handling
- Prorated amount calculation
- Credit application for unused portion

## Update Paths to Existing Code

### 1. Add to Main Routes (`lib/main.dart`)
```dart
'/wezu-pass': (context) => const WezuPassScreen(),
'/subscription-purchase': (context) => SubscriptionPurchaseScreen(
  selectedPlan: ModalRoute.of(context)?.settings.arguments as SubscriptionPlan,
),
'/subscription-management': (context) => const SubscriptionManagementScreen(),
```

### 2. Add to Dashboard (`lib/features/dashboard/screens/home_screen.dart`)
```dart
// Add button to quick actions pointing to WezuPass
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/wezu-pass'),
  child: const Text('Wezu Pass'),
)
```

### 3. Add to Profile (`lib/features/profile/screens/profile_screen.dart`)
```dart
// Add "My Subscription" tile in settings
ListTile(
  title: const Text('My Subscription'),
  onTap: () => Navigator.push(context, 
    MaterialPageRoute(builder: (_) => const SubscriptionManagementScreen()),
  ),
)
```

### 4. Add to Wallet (`lib/features/wallet/`)
```dart
// Create wallet screen to include Wezu Pass quick access
```

## Notifications Integration

### Required Notifications
1. **Renewal Reminders**: 3 days and 1 day before renewal
2. **Renewal Success**: After automatic renewal
3. **Renewal Failure**: Payment failure with retry info
4. **Cancellation Confirmation**: When subscription cancelled
5. **Upgrade/Downgrade**: Plan change confirmation

### Implementation
- Use existing notification service in `core/services/notification_service.dart`
- Schedule local notifications using `flutter_local_notifications`
- Send push notifications via Firebase Cloud Messaging
- Email notifications via backend

## Testing Checklist

### Unit Tests
- [ ] SubscriptionNotifier state transitions
- [ ] Plan eligibility validation
- [ ] Refund calculations
- [ ] Swap limit enforcement

### Integration Tests
- [ ] Load plans from API
- [ ] Purchase subscription flow
- [ ] Auto-renewal toggle
- [ ] Cancel subscription with reason
- [ ] Plan history retrieval

### UI Tests
- [ ] Plan cards display correctly
- [ ] Purchase flow steps work sequentially
- [ ] Payment method selection
- [ ] Auto-renewal checkbox toggle
- [ ] Cancellation dialog

### Functional Tests
- [ ] Daily/Weekly/Monthly plans
- [ ] Unlimited swap enforcement
- [ ] Renewal date calculations
- [ ] Prorated refund calculations
- [ ] Error handling and retry logic

## Video Integration Points

### Payment Gateway
- Razorpay or Stripe integration
- Order creation before payment
- Payment verification after
- Error handling for failed transactions

### Email Service
- Purchase confirmation email
- Renewal reminders
- Cancellation confirmation
- Invoice/Receipt generation and sending

### Push Notifications
- Firebase Cloud Messaging setup
- Notification payload formatting
- In-app notification handling

## Future Enhancements

1. **Referral System**: Earn credits by referring friends
2. **Promo Codes**: Discount codes for plans
3. **Family Plans**: Multiple users under one subscription
4. **Analytics Dashboard**: Usage stats and insights
5. **Plan Recommendations**: AI-based plan suggestions
6. **Payment Methods**: More payment options
7. **Subscription Gifting**: Gift subscriptions to friends
8. **Loyalty Program**: Points system and rewards

## File Structure Summary

```
lib/features/wallet/
├── Wezupass.dart (Main exports)
├── models/
│   ├── subscription_plan.dart
│   ├── subscription.dart
│   └── subscription_requests.dart
├── services/
│   └── subscription_service.dart
├── providers/
│   └── subscription_provider.dart
├── screens/
│   ├── wezu_pass_screen.dart
│   ├── subscription_purchase_screen.dart
│   └── subscription_management_screen.dart
└── widgets/
    ├── plan_card.dart
    └── plan_comparison.dart
```

## Dependencies

Ensure these are in `pubspec.yaml`:
```yaml
dependencies:
  flutter_riverpod: ^2.0.0
  dio: ^5.0.0
  google_fonts: ^6.0.0
  lucide_icons: ^0.0.0
  flutter_secure_storage: ^8.0.0
```

## Support & Troubleshooting

### Common Issues

**1. Plans not loading**
- Check API endpoint in `ApiConstants`
- Verify network connectivity
- Check Dio interceptors for auth

**2. Purchase failing**
- Verify payment method selection
- Check payment gateway configuration
- Review error messages in logs

**3. Auto-renewal not working**
- Verify payment method saved
- Check renewal date calculations
- Review background task scheduling

**4. Subscription not updating**
- Clear app cache
- Force refresh using pull-to-refresh
- Verify API response format

## Contact & Support

For issues or feature requests, contact the development team.
