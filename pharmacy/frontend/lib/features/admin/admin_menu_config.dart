import 'package:flutter/material.dart';

class AdminMenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<AdminMenuItem>? subMenus;

  AdminMenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subMenus,
  });
}

final List<AdminMenuItem> adminMenuStructure = [
  // 1. Dashboard
  AdminMenuItem(
    title: "Dashboard",
    icon: Icons.dashboard_rounded,
    subMenus: [
      AdminMenuItem(title: "Overview", icon: Icons.analytics_outlined, route: "/admin/dashboard"),
      AdminMenuItem(title: "Live Map", icon: Icons.map_outlined, route: "/admin/dashboard/map"),
      AdminMenuItem(title: "Alerts", icon: Icons.notifications_active_outlined, route: "/admin/dashboard/alerts"),
    ],
  ),

  // 2. Organizations
  AdminMenuItem(
    title: "Organizations",
    icon: Icons.business_rounded,
    subMenus: [
      AdminMenuItem(title: "All Tenants", icon: Icons.list_alt, route: "/admin/orgs"),
      AdminMenuItem(title: "Onboarding Wizard", icon: Icons.add_business, route: "/admin/orgs/new"),
      AdminMenuItem(title: "Suspended", icon: Icons.block, route: "/admin/orgs/suspended"),
      AdminMenuItem(title: "Trials", icon: Icons.hourglass_top, route: "/admin/orgs/trials"),
      AdminMenuItem(title: "Insights", icon: Icons.insights, route: "/admin/orgs/insights"),
    ],
  ),

  // 3. Billing
  AdminMenuItem(
    title: "Billing & Revenue",
    icon: Icons.payments_rounded,
    subMenus: [
      AdminMenuItem(title: "Subscription Plans", icon: Icons.price_change, route: "/admin/billing/plans"),
      AdminMenuItem(title: "Active Subscriptions", icon: Icons.subscriptions, route: "/admin/billing/subscriptions"),
      AdminMenuItem(title: "Invoices", icon: Icons.receipt_long, route: "/admin/billing/invoices"),
      AdminMenuItem(title: "Revenue Analytics", icon: Icons.monetization_on, route: "/admin/billing/analytics"),
    ],
  ),
  
  // 4. Support
  AdminMenuItem(
    title: "Support Center",
    icon: Icons.support_agent_rounded,
    subMenus: [
      AdminMenuItem(title: "Tickets", icon: Icons.confirmation_number, route: "/admin/support/tickets"),
      AdminMenuItem(title: "Live Chat", icon: Icons.chat, route: "/admin/support/chat"),
      AdminMenuItem(title: "Knowledge Base", icon: Icons.library_books, route: "/admin/support/kb"),
    ],
  ),

  // 5. Monitoring
  AdminMenuItem(
    title: "System Monitoring",
    icon: Icons.monitor_heart_rounded,
    subMenus: [
      AdminMenuItem(title: "Server Health", icon: Icons.dns, route: "/admin/monitoring/servers"),
      AdminMenuItem(title: "Error Logs", icon: Icons.bug_report, route: "/admin/monitoring/logs"),
      AdminMenuItem(title: "Database", icon: Icons.storage, route: "/admin/monitoring/db"),
    ],
  ),

  // 6. Analytics
  AdminMenuItem(
    title: "Analytics & Reports",
    icon: Icons.bar_chart_rounded,
    subMenus: [
      AdminMenuItem(title: "Revenue Report", icon: Icons.attach_money, route: "/admin/analytics/revenue"),
      AdminMenuItem(title: "Usage Stats", icon: Icons.data_usage, route: "/admin/analytics/usage"),
      AdminMenuItem(title: "Export Center", icon: Icons.download, route: "/admin/analytics/export"),
    ],
  ),

  // 7. Platform Settings
  AdminMenuItem(
    title: "Platform Settings",
    icon: Icons.settings_rounded,
    subMenus: [
      AdminMenuItem(title: "Global Config", icon: Icons.tune, route: "/admin/settings/global"),
      AdminMenuItem(title: "Feature Flags", icon: Icons.toggle_on, route: "/admin/settings/features"),
      AdminMenuItem(title: "Audit Logs", icon: Icons.history_edu, route: "/admin/settings/audit"),
    ],
  ),

  // 8. Master Data
  AdminMenuItem(
    title: "Master Data",
    icon: Icons.dataset_rounded,
    subMenus: [
      AdminMenuItem(title: "Drug Database", icon: Icons.medication, route: "/admin/master/drugs"),
      AdminMenuItem(title: "Lab Tests", icon: Icons.biotech, route: "/admin/master/labs"),
      AdminMenuItem(title: "Insurance Providers", icon: Icons.health_and_safety, route: "/admin/master/insurance"),
    ],
  ),
  
  // 9. Users
  AdminMenuItem(
    title: "Admin Users",
    icon: Icons.admin_panel_settings_rounded,
    subMenus: [
      AdminMenuItem(title: "Super Admins", icon: Icons.people_alt, route: "/admin/users/admins"),
      AdminMenuItem(title: "Roles & Permissions", icon: Icons.security, route: "/admin/users/roles"),
    ],
  ),

  // 11. Marketing
  AdminMenuItem(
    title: "Marketing",
    icon: Icons.campaign,
    subMenus: [
      AdminMenuItem(title: "Announcements", icon: Icons.message, route: "/admin/marketing/announcements"),
    ],
  ),
  
  // 13. Training
  AdminMenuItem(
    title: "Training Center",
    icon: Icons.school,
    route: "/admin/training/videos",
  ),

  // 12. Integrations Hub
  AdminMenuItem(
    title: "Integrations Hub",
    icon: Icons.hub_rounded,
    route: "/admin/integrations/hub",
  ),
  
  // 10. Security
  AdminMenuItem(
     title: "Security & Compliance",
     icon: Icons.security,
     subMenus: [
       AdminMenuItem(title: "Backups", icon: Icons.backup, route: "/admin/security/backups"),
     ],
  ),
];
