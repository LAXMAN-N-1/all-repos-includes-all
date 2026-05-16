import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../widgets/animated_3d_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/bid_provider.dart';
import '../../logic/providers/vendor_bidding_provider.dart';
import '../../data/models/bidding_event_model.dart';
import '../../data/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? expandedItem;
  bool _showIntro = true; // Show intro overlay on first load
  // State for real-time tracking
  final Set<int> _knownEventIds = {};
  bool _isFirstLoad = true;
  bool _hasShownOpportunityPopup = false; 

  @override
  void initState() {
    super.initState();
    _checkLastViewedEvent();
  }

  Future<void> _checkLastViewedEvent() async {
    final prefs = await SharedPreferences.getInstance();
    // We don't need to do anything here, just getting ready
  }

  Future<void> _updateLastViewedEvent(int maxId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_viewed_event_id', maxId);
  }

  void _showNewOpportunityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: AppTheme.darkGold, size: 24),
            const SizedBox(width: 8),
            const Text('New Opportunity!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'A new service request has been posted! Check the marketplace now.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: AppTheme.gray600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/vendor/bidding/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> navigation = [
    {
      'name': 'Bidding',
      'icon': Icons.gavel_rounded,
      'code': 'BIDDING',
      'children': [
        {'name': 'Active Bids', 'path': '/vendor/bidding/active', 'code': 'BIDDING'},
        {'name': 'Bid History', 'path': '/vendor/bidding/history', 'code': 'BIDDING'},
      ],
    },
    {
      'name': 'Orders',
      'icon': Icons.shopping_cart_outlined,
      'code': 'ORDERS',
      'children': [
        {'name': 'My Orders', 'path': '/vendor/orders/my-orders', 'code': 'ORDERS'},
      ],
    },
    {
      'name': 'Payments',
      'icon': Icons.account_balance_wallet_outlined,
      'code': 'PAYMENTS',
      'children': [
        {'name': 'Payment Overview', 'path': '/vendor/payments/overview', 'code': 'PAYMENTS'},
        {'name': 'Payment List', 'path': '/vendor/payments/list', 'code': 'PAYMENTS'},
      ],
    },
    {
      'name': 'My Business',
      'icon': Icons.business_center_outlined,
      'code': 'BUSINESS',
      'children': [
        {'name': 'Profile', 'path': '/vendor/business/profile', 'code': 'BUSINESS'},
        {'name': 'Categories', 'path': '/vendor/business/categories', 'code': 'BUSINESS'},
      ],
    },
    {
      'name': 'Analytics',
      'icon': Icons.analytics_outlined,
      'code': 'ANALYTICS',
      'children': [
        {'name': 'Performance', 'path': '/vendor/analytics/performance', 'code': 'ANALYTICS'},
        {'name': 'Revenue', 'path': '/vendor/analytics/revenue', 'code': 'ANALYTICS'},
      ],
    },
    {
      'name': 'Activity History',
      'icon': Icons.history_rounded,
      'code': 'HISTORY',
      'children': [
        {'name': 'Activity History', 'path': '/vendor/activity/history', 'code': 'HISTORY'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Listen for new opportunities stream
    ref.listen(marketplaceEventsProvider, (previous, next) {
      next.whenData((events) async {
         if (events.isEmpty) return;

         // Calculate current max ID
         final currentMaxId = events.map((e) => e.id).fold(0, (max, id) => id > max ? id : max);
         
         final prefs = await SharedPreferences.getInstance();
         final lastViewedId = prefs.getInt('last_viewed_event_id') ?? 0;

         if (currentMaxId > lastViewedId) {
            // New events available!
            if (!_hasShownOpportunityPopup) {
               _hasShownOpportunityPopup = true;
               if (mounted) {
                 _showNewOpportunityDialog(context);
                 // Update last viewed immediately so it doesn't show again this session/restart
                 // unless an even newer one comes.
                 _updateLastViewedEvent(currentMaxId);
               }
            }
         }
      });
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(
                'EVE NATION',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
      drawer: !isDesktop ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 256,
              child: _buildDrawer(context, isSidebar: true),
            ),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildDesktopTopBar(context),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, {bool isSidebar = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.sidebarColor, // Critical Update: Dark Evergreen Sidebar
        border: Border(right: BorderSide(color: AppTheme.mintWhisper.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          if (isSidebar)
            Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Animated3DLogo(size: 36, animateStory: false),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EVE NATION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Vendor Portal',
                        style: TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: navigation.map((item) => _buildNavItem(context, item)).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.mintWhisper.withOpacity(0.1))),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.royalAmethyst,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Vendor',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        Text(
                          'Rajesh Kumar',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right, size: 16, color: Colors.white54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, Map<String, dynamic> item) {
    if (item.containsKey('children')) {
      final children = item['children'] as List;
      final isExpanded = expandedItem == item['name'];
      
      // Check if any child is active to highlight parent
      final isAnyChildActive = children.any((c) => GoRouterState.of(context).uri.toString() == c['path']);
      final parentColor = (isExpanded || isAnyChildActive) ? AppTheme.emeraldGreen : Colors.white70;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                item['icon'],
                color: parentColor,
                size: 20,
              ),
              title: Text(
                item['name'],
                style: TextStyle(
                  color: parentColor,
                  fontWeight: (isExpanded || isAnyChildActive) ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.white38,
              ),
              onTap: () {
                setState(() {
                  expandedItem = isExpanded ? null : item['name'];
                });
              },
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              hoverColor: Colors.white.withOpacity(0.05),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Column(
                  children: children.map((child) {
                    final isActive = GoRouterState.of(context).uri.toString() == child['path'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: InkWell(
                        onTap: () {
                          if (!_scaffoldKey.currentState!.isDrawerOpen) {
                            context.go(child['path']);
                          } else {
                            context.push(child['path']);
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: isActive
                              ? BoxDecoration(
                                  color: AppTheme.emeraldGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: AppTheme.emeraldGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                                  ],
                                )
                              : null,
                          child: Text(
                            child['name'],
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white60,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    } else {
      final isActive = GoRouterState.of(context).uri.toString() == item['path'];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: ListTile(
          leading: Icon(
            item['icon'],
            color: isActive ? Colors.white : Colors.white70,
            size: 20,
          ),
          title: Text(
            item['name'],
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: isActive,
          selectedTileColor: AppTheme.emeraldGreen,
          tileColor: isActive ? AppTheme.emeraldGreen : null,
          hoverColor: Colors.white.withOpacity(0.05),
          onTap: () {
            if (!_scaffoldKey.currentState!.isDrawerOpen) {
              context.go(item['path']);
            } else {
              context.push(item['path']);
              Navigator.pop(context);
            }
          },
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
        ),
      );
    }
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            'Welcome back!',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/vendor/notifications'),
          ),
        ],
      ),
    );
  }
}

