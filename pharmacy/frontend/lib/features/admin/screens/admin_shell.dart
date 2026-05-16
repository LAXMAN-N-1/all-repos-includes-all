import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/common/aura_logo.dart';
import 'package:frontend/features/admin/admin_menu_config.dart';
import 'package:google_fonts/google_fonts.dart';

// Import all admin screens for the internal navigator
import 'package:frontend/features/admin/screens/admin_dashboard_screen.dart';
import 'package:frontend/features/admin/screens/dashboard/live_map_screen.dart';
import 'package:frontend/features/admin/screens/dashboard/dashboard_alerts_screen.dart';
import 'package:frontend/features/admin/screens/orgs/tenant_list_screen.dart';
import 'package:frontend/features/admin/screens/orgs/onboarding_screen.dart';
import 'package:frontend/features/admin/screens/billing/plans_screen.dart';
import 'package:frontend/features/admin/screens/billing/invoices_screen.dart';
import 'package:frontend/features/admin/screens/billing/subscriptions_screen.dart';
import 'package:frontend/features/admin/screens/billing/revenue_analytics_screen.dart';
import 'package:frontend/features/admin/screens/support/support_tickets_screen.dart';
import 'package:frontend/features/admin/screens/support/live_chat_screen.dart';
import 'package:frontend/features/admin/screens/support/knowledge_base_screen.dart';
import 'package:frontend/features/admin/screens/monitoring/server_health_screen.dart';
import 'package:frontend/features/admin/screens/monitoring/error_logs_screen.dart';
import 'package:frontend/features/admin/screens/monitoring/database_health_screen.dart';
import 'package:frontend/features/admin/screens/settings/global_config_screen.dart';
import 'package:frontend/features/admin/screens/settings/audit_logs_screen.dart';
import 'package:frontend/features/admin/screens/users/admin_users_screen.dart';
import 'package:frontend/features/admin/screens/users/roles_screen.dart';
import 'package:frontend/features/admin/screens/master/drug_database_screen.dart';
import 'package:frontend/features/admin/screens/security/backup_management_screen.dart';
import 'package:frontend/features/admin/screens/integrations/integrations_hub_screen.dart';
import 'package:frontend/features/admin/screens/marketing/announcements_screen.dart';
import 'package:frontend/features/admin/screens/analytics/usage_stats_screen.dart';
import 'package:frontend/features/admin/screens/analytics/export_center_screen.dart';
import 'package:frontend/features/admin/screens/settings/feature_flags_screen.dart';
import 'package:frontend/features/admin/screens/master/lab_tests_screen.dart';
import 'package:frontend/features/admin/screens/master/insurance_screen.dart';
import 'package:frontend/features/admin/screens/training/training_screen.dart';
import 'package:frontend/features/admin/screens/orgs/suspended_tenants_screen.dart';
import 'package:frontend/features/admin/screens/orgs/trials_tenants_screen.dart';
import 'package:frontend/features/admin/screens/orgs/org_insights_screen.dart';
import 'package:frontend/features/admin/screens/sandbox/sandbox_screen.dart';
import 'package:frontend/features/admin/screens/mobile/mobile_app_screen.dart';
import 'package:frontend/features/admin/screens/notifications/notifications_screen.dart';
import 'package:frontend/features/admin/screens/profile/profile_screen.dart';

class AdminShell extends StatefulWidget {
  final String initialRoute;
  const AdminShell({Key? key, this.initialRoute = '/admin/dashboard'}) : super(key: key);

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _currentRoute = '/admin/dashboard';

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Row(
        children: [
          // --- Persistent Sidebar ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 280,
            decoration: BoxDecoration(
              color: AuraColors.surface,
              border: Border(right: BorderSide(color: AuraColors.glassBorder)),
            ),
            child: Column(
              children: [
                // Header (Logo)
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isSidebarCollapsed
                      // Small Logo
                      ? InkWell(
                          onTap: () => setState(() => _isSidebarCollapsed = false),
                          child: const AuraLogo(size: 40, animate: false)
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AuraLogo(size: 32, animate: false),
                            const SizedBox(width: 12),
                            Text(
                              "AuraMed",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
                
                Divider(color: AuraColors.glassBorder),
                
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: adminMenuStructure.length + 1,
                    itemBuilder: (context, index) {
                      if (index == adminMenuStructure.length) return const SizedBox(height: 20);
                      final item = adminMenuStructure[index];
                      return _buildMenuItem(item);
                    },
                  ),
                ),
                
                // User Profile Bottom
                Divider(color: AuraColors.glassBorder),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AuraColors.primary,
                    child: Text("SA", style: TextStyle(color: Colors.white)),
                  ),
                  title: _isSidebarCollapsed ? null : const Text("Super Admin", style: TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: _isSidebarCollapsed ? null : const Text("Online", style: TextStyle(color: AuraColors.success, fontSize: 10)),
                  onTap: () => _navigateTo('/admin/profile'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // --- Main Content Area (TopBar + Nested Navigator) ---
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AuraColors.surface,
                    border: Border(bottom: BorderSide(color: AuraColors.glassBorder)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Collapse Toggle
                      IconButton(
                        icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu),
                        color: Colors.white,
                        onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                      ),
                      
                      const Spacer(),
                      
                      // Search
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AuraColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Search everything...",
                            prefixIcon: Icon(Icons.search, size: 18),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Actions
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined), 
                        onPressed: () => _navigateTo('/admin/notifications'),
                      ),
                      IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
                    ],
                  ),
                ),
                
                // Nested Content
                Expanded(
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: widget.initialRoute,
                    onGenerateRoute: (settings) {
                      WidgetBuilder builder;
                      // Mapping routes to screens
                      switch (settings.name) {
                        case '/admin/dashboard': builder = (_) => const AdminDashboardScreen(); break;
                        case '/admin/dashboard/map': builder = (_) => const LiveMapScreen(); break;
                        case '/admin/dashboard/alerts': builder = (_) => const DashboardAlertsScreen(); break;
                        case '/admin/orgs': builder = (_) => const TenantListScreen(); break;
                        case '/admin/orgs/new': builder = (_) => const OnboardingWizardScreen(); break;
                        case '/admin/orgs/suspended': builder = (_) => const SuspendedTenantsScreen(); break; 
                        case '/admin/orgs/trials': builder = (_) => const TrialTenantsScreen(); break;
                        case '/admin/orgs/insights': builder = (_) => const OrgInsightsScreen(); break;
                        
                        // Billing
                        case '/admin/billing/plans': builder = (_) => const PlansScreen(); break;
                        case '/admin/billing/subscriptions': builder = (_) => const SubscriptionsScreen(); break;
                        case '/admin/billing/invoices': builder = (_) => const InvoicesScreen(); break;
                        case '/admin/billing/analytics': builder = (_) => const RevenueAnalyticsScreen(); break;
                        
                        // Support
                        case '/admin/support/tickets': builder = (_) => const SupportTicketsScreen(); break;
                        case '/admin/support/chat': builder = (_) => const LiveChatScreen(); break;
                        case '/admin/support/kb': builder = (_) => const KnowledgeBaseScreen(); break;
                        
                        // Monitoring
                        case '/admin/monitoring/servers': builder = (_) => const ServerHealthScreen(); break;
                        case '/admin/monitoring/logs': builder = (_) => const ErrorLogsScreen(); break;
                        case '/admin/monitoring/db': builder = (_) => const DatabaseHealthScreen(); break;
                        
                        // Settings
                        case '/admin/settings/global': builder = (_) => const GlobalConfigScreen(); break;
                        case '/admin/settings/features': builder = (_) => const FeatureFlagsScreen(); break;
                        case '/admin/settings/audit': builder = (_) => const AuditLogsScreen(); break;
                        
                        // Users
                        case '/admin/users/admins': builder = (_) => const AdminUsersScreen(); break;
                        case '/admin/users/roles': builder = (_) => const RolesScreen(); break;
                        
                        // Master Data
                        case '/admin/master/drugs': builder = (_) => const DrugDatabaseScreen(); break;
                        case '/admin/master/labs': builder = (_) => const LabTestsScreen(); break;
                        case '/admin/master/insurance': builder = (_) => const InsuranceProvidersScreen(); break;
                        
                        // Security & Integrations
                        case '/admin/security/backups': builder = (_) => const BackupManagementScreen(); break;
                        case '/admin/integrations/hub': builder = (_) => const IntegrationsHubScreen(); break;
                        
                        // Marketing & Training
                        case '/admin/marketing/announcements': builder = (_) => const AnnouncementsScreen(); break;
                        case '/admin/training/videos': builder = (_) => const TrainingScreen(); break;

                        // Analytics
                        case '/admin/analytics/revenue': builder = (_) => const RevenueAnalyticsScreen(); break;
                        case '/admin/analytics/usage': builder = (_) => const UsageStatsScreen(); break;
                        case '/admin/analytics/export': builder = (_) => const ExportCenterScreen(); break;
                        
                        // Final Modules
                        case '/admin/sandbox': builder = (_) => const SandboxScreen(); break;
                        case '/admin/mobile': builder = (_) => const MobileAppScreen(); break;
                        case '/admin/notifications': builder = (_) => const NotificationsScreen(); break;
                        case '/admin/profile': builder = (_) => const ProfileScreen(); break;
                        
                        default: builder = (_) => Center(child: Text("Route not found: ${settings.name}", style: TextStyle(color: Colors.white)));
                      }
                      
                      return MaterialPageRoute(builder: builder, settings: settings);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Menu Builder (Same as before, but handles nested navigation) ---
  Widget _buildMenuItem(AdminMenuItem item) {
    bool hasSubMenu = item.subMenus != null && item.subMenus!.isNotEmpty;
    bool isActive = _currentRoute == item.route || (item.subMenus?.any((sub) => sub.route == _currentRoute) ?? false);

    if (_isSidebarCollapsed) {
      return IconButton(
        icon: Icon(item.icon, color: isActive ? AuraColors.primary : Colors.white70),
        tooltip: item.title,
        onPressed: () => _navigateTo(item.route),
        padding: const EdgeInsets.symmetric(vertical: 16),
      );
    }

    if (!hasSubMenu) {
      return ListTile(
        leading: Icon(item.icon, color: isActive ? AuraColors.primary : Colors.white70, size: 20),
        title: Text(item.title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        tileColor: isActive ? AuraColors.primary.withOpacity(0.1) : null,
        onTap: () => _navigateTo(item.route),
        dense: true,
      );
    }

    return ExpansionTile(
      initiallyExpanded: isActive, // Keep expanded if active
      leading: Icon(item.icon, color: isActive ? AuraColors.primary : Colors.white70, size: 20),
      title: Text(item.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      childrenPadding: const EdgeInsets.only(left: 20),
      collapsedIconColor: Colors.white70,
      iconColor: AuraColors.primary,
      children: item.subMenus!.map((subItem) {
        bool isSubActive = _currentRoute == subItem.route;
        return ListTile(
          leading: Icon(subItem.icon, color: isSubActive ? AuraColors.primary : Colors.white60, size: 16),
          title: Text(subItem.title, style: TextStyle(color: isSubActive ? Colors.white : Colors.white60, fontSize: 13)),
          tileColor: isSubActive ? AuraColors.primary.withOpacity(0.1) : null,
          onTap: () => _navigateTo(subItem.route),
          dense: true,
        );
      }).toList(),
    );
  }

  void _navigateTo(String? route) {
    if (route == null) return;
    
    setState(() => _currentRoute = route);
    _navigatorKey.currentState!.pushReplacementNamed(route);
  }
}
