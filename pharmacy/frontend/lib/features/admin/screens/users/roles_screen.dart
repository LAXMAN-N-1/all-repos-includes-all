import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_users.dart';
import 'package:google_fonts/google_fonts.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Roles & Permissions", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_moderator),
                  label: const Text("Create Role"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.2,
                ),
                itemCount: mockRoles.length,
                itemBuilder: (context, index) {
                  return _buildRoleCard(mockRoles[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(Role role) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.security, color: AuraColors.secondary, size: 28),
              if (role.name == "Super Admin")
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                   child: const Text("SYSTEM", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                 ),
            ],
          ),
          const SizedBox(height: 16),
          Text(role.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(role.description, style: const TextStyle(color: Colors.white60, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          
          const Spacer(),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text("${role.usersCount} Users", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text("Configure Permissions")),
            ],
          )
        ],
      ),
    );
  }
}
