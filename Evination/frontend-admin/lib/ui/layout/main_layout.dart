import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/role_right_model.dart';
import '../../data/models/menu_model.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? expandedItem;

  final List<Map<String, dynamic>> navigation = [
    {
      'name': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'path': '/admin',
      'code': 'DASHBOARD',
    },
    {
      'name': 'Event Requests',
      'icon': Icons.event_note_outlined,
      'code': 'EVENT_REQUESTS',
      'children': [
        {'name': 'All Requests', 'path': '/admin/events/requests', 'code': 'EVENT_REQ_ALL'},
        {'name': 'By Status', 'path': '/admin/events/requests/status', 'code': 'EVENT_REQ_STATUS'},
        {'name': 'By Category', 'path': '/admin/events/requests/category', 'code': 'EVENT_REQ_CATEGORY'},
        {'name': 'Quotation Mgmt', 'path': '/admin/events/quotations', 'code': 'EVENT_QUOTES'},
        {'name': 'Calendar View', 'path': '/admin/events/calendar', 'code': 'EVENT_CALENDAR'},
      ],
    },
    {
      'name': 'Vendor Management',
      'icon': Icons.store_outlined,
      'code': 'VENDOR_MGMT',
      'children': [
        {'name': 'All Vendors', 'path': '/admin/vendors/list', 'code': 'VENDOR_LIST'},
        {'name': 'Pending Approvals', 'path': '/admin/vendors/pending', 'code': 'VENDOR_PENDING'},
         // Placeholder for specific filter views, can just rely on main list with args later
        {'name': 'Active Vendors', 'path': '/admin/vendors/active', 'code': 'VENDOR_ACTIVE'}, 
        {'name': 'Inactive Vendors', 'path': '/admin/vendors/inactive', 'code': 'VENDOR_INACTIVE'},
        {'name': 'Performance', 'path': '/admin/vendors/performance', 'code': 'VENDOR_PERF'},
        {'name': 'Commission', 'path': '/admin/vendors/commission', 'code': 'VENDOR_COMMISSION'},
        {'name': 'Payouts', 'path': '/admin/vendors/payouts', 'code': 'VENDOR_PAYOUTS'},
        {'name': 'Analytics', 'path': '/admin/vendors/analytics', 'code': 'VENDOR_ANALYTICS'},
        {'name': 'Vendor Categories', 'path': '/admin/vendors/categories', 'code': 'VENDOR_CATEGORIES'},
      ],
    },
    {
      'name': 'Customer Mgmt',
      'icon': Icons.people_outline,
      'code': 'CUSTOMER_MGMT',
      'path': '/admin/customers', // Placeholder
    },
    {
      'name': 'Financial Mgmt',
      'icon': Icons.attach_money_outlined,
      'code': 'FINANCE_MGMT',
      'path': '/admin/finance', // Placeholder
    },
    {
      'name': 'Reports & Analytics',
      'icon': Icons.bar_chart_outlined,
      'code': 'REPORTS',
      'children': [
        {'name': 'Dashboard', 'path': '/admin/reports/dashboard', 'code': 'REP_DASH'},
        {'name': 'All Reports', 'path': '/admin/reports/landing', 'code': 'REP_LANDING'},
        {'name': 'Report Builder', 'path': '/admin/reports/builder', 'code': 'REP_BUILDER'},
      ],
    },
    {
      'name': 'Marketing',
      'icon': Icons.campaign_outlined,
      'code': 'MARKETING',
      'children': [
        {'name': 'Campaigns', 'path': '/admin/marketing/campaigns', 'code': 'MKT_CAMPAIGNS'},
        {'name': 'Discounts', 'path': '/admin/marketing/discounts', 'code': 'MKT_DISCOUNTS'},
      ],
    },
    {
      'name': 'Platform Settings',
      'icon': Icons.settings_outlined,
      'code': 'SETTINGS',
      'children': [
        {'name': 'General', 'path': '/admin/settings/general', 'code': 'SET_GENERAL'},
        {'name': 'Commissions', 'path': '/admin/settings/commission', 'code': 'SET_COMMISSION'},
        {'name': 'Payments', 'path': '/admin/settings/payments', 'code': 'SET_PAYMENTS'},
      ],
    },
    {
      'name': 'User & Roles',
      'icon': Icons.admin_panel_settings_outlined,
      'code': 'USER_ROLES',
      'children': [
         {'name': 'Users', 'path': '/admin/organization/users', 'code': 'USERS'},
         {'name': 'Roles', 'path': '/admin/organization/roles', 'code': 'ROLES'},
      ],
    },
    {
      'name': 'Notifications',
      'icon': Icons.notifications_active_outlined,
      'code': 'NOTIFICATIONS',
      'children': [
        {'name': 'Send New', 'path': '/admin/notifications/send', 'code': 'NOTIF_SEND'},
        {'name': 'Alert Settings', 'path': '/admin/notifications/alerts', 'code': 'NOTIF_ALERTS'},
      ],
    },
    {
      'name': 'Support & Tickets',
      'icon': Icons.support_agent, 
      'code': 'SUPPORT',
      'path': '/admin/support/dashboard',
    },
    {
      'name': 'Content Mgmt',
      'icon': Icons.article_outlined,
      'code': 'CONTENT',
      'children': [
        {'name': 'Event Categories', 'path': '/admin/content/categories', 'code': 'CONTENT_CATEGORIES'},
        {'name': 'Banners & Ads', 'path': '/admin/content/banners', 'code': 'CONTENT_BANNERS'},
        {'name': 'Email Templates', 'path': '/admin/content/email', 'code': 'CONTENT_EMAIL'},
      ]
    },
    {
      'name': 'Audit & Logs',
      'icon': Icons.history_outlined,
      'code': 'AUDIT',
      'children': [
        {'name': 'Activity Logs', 'path': '/admin/audit/activity', 'code': 'AUDIT_ACTIVITY'},
        {'name': 'Login History', 'path': '/admin/audit/login', 'code': 'AUDIT_LOGIN'},
        {'name': 'System Logs', 'path': '/admin/audit/system', 'code': 'AUDIT_SYSTEM'},
        {'name': 'Audit Reports', 'path': '/admin/audit/report', 'code': 'AUDIT_REPORT'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive layout
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Use theme default
      appBar: isDesktop
          ? null // Custom top bar for desktop
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Row(
                children: [
                  const Icon(Icons.event, color: AppTheme.accentYellow),
                  const SizedBox(width: 8),
                  Text(
                    'EVE NATION',
                    style: GoogleFonts.outfit(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/admin/notifications'),
                ),
              ],
            ),
       drawer: !isDesktop ? _buildDrawer(context) : null,
      body: Row(
        children: [
          // Sidebar for Desktop
          if (isDesktop)
            SizedBox(
              width: 256,
              child: _buildDrawer(context, isSidebar: true),
            ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar for Desktop
                if (isDesktop) _buildDesktopTopBar(context),
                
                // Page Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, {bool isSidebar = false}) {
    return Container(
      color: AppTheme.sidebarDark,
      child: Column(
        children: [
          // Header (only for Sidebar, Drawer uses built-in SafeArea usually or custom header)
          if (isSidebar)
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppTheme.accentYellow, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EVE NATION',
                         style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                         ),
                      ),
                      Text(
                        'Every Celebration,\nPerfectly Planned',
                        style: TextStyle(fontSize: 10, color: Colors.white70, height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Navigation
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildNavigation(context),
              ),
            ),
          ),

          // User Profile Section in Mobile Drawer
          if (!isSidebar)
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Column(
                children: [
                   ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      context.push('/admin/settings');
                      Navigator.pop(context);
                    },
                   ),
                    ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () {
                       context.go('/login');
                    },
                   ),
                ],
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
      
      return Column(
        children: [
          ListTile(
            leading: Icon(
              item['icon'],
              color: isExpanded ? AppTheme.accentYellow : Colors.white70,
            ),
            title: Text(
              item['name'],
              style: TextStyle(
                color: isExpanded ? AppTheme.accentYellow : Colors.white70,
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
               size: 18,
               color: Colors.grey[400],
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () {
              setState(() {
                if (expandedItem == item['name']) {
                  expandedItem = null;
                } else {
                  expandedItem = item['name'];
                }
              });
            },
            dense: true,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 48), // Indent
              child: Column(
                children: children.map((child) {
                   final isActive = GoRouterState.of(context).uri.toString() == child['path'];
                   return InkWell(
                    onTap: () {
                      if (!_scaffoldKey.currentState!.isDrawerOpen) {
                        // Desktop
                       context.go(child['path']);
                      } else {
                         // Mobile
                         context.push(child['path']);
                         Navigator.pop(context); 
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: isActive ? BoxDecoration(
                        color: AppTheme.primary600,
                        borderRadius: BorderRadius.circular(8),
                      ) : null,
                      child: Text(
                        child['name'],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white60,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                   );
                }).toList(),
              ),
            ),
        ],
      );
    } else {
      final isActive = GoRouterState.of(context).uri.toString() == item['path'];
      return ListTile(
        leading: Icon(
          item['icon'],
           color: isActive ? AppTheme.accentYellow : Colors.white70,
        ),
        title: Text(
          item['name'],
           style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
             fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isActive,
        selectedTileColor: AppTheme.primary600.withOpacity(0.2), // Optional bg for active parent
        onTap: () {
          if (!_scaffoldKey.currentState!.isDrawerOpen) {
             context.go(item['path']);
          } else {
             context.push(item['path']);
             Navigator.pop(context);
          }
        },
        dense: true,
      );
    }
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.04),
             blurRadius: 8,
             offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Notifications
           IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.grey),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: const Text('4', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            onPressed: () => context.push('/admin/notifications'),
          ),
          const SizedBox(width: 16),
          
          // Profile Dropdown Sim
          InkWell(
             onTap: () {
                // Navigate to settings or show menu
                context.push('/admin/settings');
             },
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFfdb913), Color(0xFFe5a711)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Admin User', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                     Text('Administrator', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigation(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    // Helper to check permission
    bool hasPermission(String? code) {
      if (code == null) return true; // Public or no specific permission needed
      
      // Check Super Admin via Role if available
      if (user?.role?.code == 'SUPERADMIN') return true;
      
      // Fallback to rights list from AuthResponse directly
      final rights = authState.value?.rights;
      if (rights == null) return false;

      // Check if any right has this menu code and canView is true
      return rights.any((r) => r.menu?.code == code && r.canView);
    }

    final List<Widget> navItems = [];

    for (var item in navigation) {
      // Check parent permission
      // if (!hasPermission(item['code'])) continue; // Disabled to restore full view

      if (item.containsKey('children')) {
        final children = item['children'] as List;
        // final filteredChildren = children.where((child) => hasPermission(child['code'])).toList(); // Disabled
        final filteredChildren = children; // Show all children
        
        // If parent has children but user has no access to any child, hide parent?
        // Or show parent but empty? Better to hide parent if no visible children.
        if (filteredChildren.isNotEmpty) {
           final newItem = Map<String, dynamic>.from(item);
           newItem['children'] = filteredChildren;
           navItems.add(_buildNavItem(context, newItem));
        }
      } else {
        navItems.add(_buildNavItem(context, item));
      }
    }
    
    return navItems;
  }
}
