import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/common/aura_logo.dart';
import 'package:frontend/features/admin/admin_menu_config.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  const AdminLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Row(
        children: [
          // Sidebar
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
                      ? const AuraLogo(size: 40, animate: false)
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
                    itemCount: adminMenuStructure.length + 1, // +1 for spacer
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

          // Main Content
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
                
                // Page Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(AdminMenuItem item) {
    bool hasSubMenu = item.subMenus != null && item.subMenus!.isNotEmpty;

    if (_isSidebarCollapsed) {
      return IconButton(
        icon: Icon(item.icon, color: Colors.white70),
        tooltip: item.title,
        onPressed: () => _navigateTo(item.route), // Allow clicking parent if no submenu
        padding: const EdgeInsets.symmetric(vertical: 16),
      );
    }

    if (!hasSubMenu) {
      return ListTile(
        leading: Icon(item.icon, color: Colors.white70, size: 20),
        title: Text(item.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        hoverColor: AuraColors.primary.withOpacity(0.1),
        onTap: () => _navigateTo(item.route),
        dense: true,
      );
    }

    return ExpansionTile(
      leading: Icon(item.icon, color: Colors.white70, size: 20),
      title: Text(item.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      childrenPadding: const EdgeInsets.only(left: 20),
      collapsedIconColor: Colors.white70,
      iconColor: AuraColors.primary,
      children: item.subMenus!.map((subItem) {
        return ListTile(
          leading: Icon(subItem.icon, color: Colors.white60, size: 16),
          title: Text(subItem.title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          hoverColor: AuraColors.primary.withOpacity(0.1),
          onTap: () => _navigateTo(subItem.route),
          dense: true,
        );
      }).toList(),
    );
  }
  
  void _navigateTo(String? route) {
    if (route == null) return;
    
    Widget screen;
    // Navigate to the route
    // Note: Since every screen wraps itself in AdminLayout, we use pushReplacementNamed
    // to switch the whole screen.
    Navigator.of(context).pushReplacementNamed(route);
  }
}
