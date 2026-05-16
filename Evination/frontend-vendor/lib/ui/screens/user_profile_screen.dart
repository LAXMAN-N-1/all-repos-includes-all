import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/providers/auth_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    if (user == null) {
      return const Center(child: Text('User not found'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Profile',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF5A623),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your personal information',
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Avatar & Basic Info
              Expanded(
                flex: 1,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFFFF8E1),
                          child: Text(
                            user.firstName?.substring(0, 1) ?? user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Color(0xFFF5A623), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName.isNotEmpty ? user.fullName : user.username,
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                           child: Text(
                            user.role?.name ?? 'Admin', 
                            style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Right Column: Details Form
              Expanded(
                flex: 2,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Personal Information', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 24),
                         
                         Row(
                           children: [
                             Expanded(child: _InfoField(label: 'First Name', value: user.firstName ?? '')),
                             const SizedBox(width: 16),
                             Expanded(child: _InfoField(label: 'Last Name', value: user.lastName ?? '')),
                           ],
                         ),
                         const SizedBox(height: 16),
                         
                         Row(
                           children: [
                             Expanded(child: _InfoField(label: 'Email', value: user.email)),
                             const SizedBox(width: 16),
                             Expanded(child: _InfoField(label: 'Phone', value: user.phone ?? '')),
                           ],
                         ),
                         
                         const SizedBox(height: 24),
                         Text('Organization Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 16),
                         // TODO: pass Organization name if available
                         const _InfoField(label: 'Organization', value: 'Eventifi HQ'), 

                         const SizedBox(height: 32),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                             const SizedBox(width: 12),
                             ElevatedButton(
                               onPressed: () {}, 
                               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5A623), foregroundColor: Colors.white),
                               child: const Text('Update Profile')
                             ),
                           ],
                         ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value.isNotEmpty ? value : '-', style: GoogleFonts.inter()),
        ),
      ],
    );
  }
}
