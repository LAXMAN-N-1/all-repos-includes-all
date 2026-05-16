import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

class RoleFormScreen extends StatelessWidget {
  const RoleFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Row(children: [
          OutlinedButton.icon(icon: const Icon(LucideIcons.arrowLeft, size: 14), label: const Text('Back'),
            onPressed: () => context.go('/roles')),
        ]),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create New Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Define a new role and assign permissions', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            Text('ROLE NAME', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            const TextField(style: TextStyle(color: AppColors.textPrimary, fontSize: 14), decoration: InputDecoration(hintText: 'e.g. Warehouse Manager')),
            const SizedBox(height: 20),
            Text('DESCRIPTION', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            const TextField(maxLines: 3, style: TextStyle(color: AppColors.textPrimary, fontSize: 14), decoration: InputDecoration(hintText: 'Describe the responsibilities and access scope for this role')),
            const SizedBox(height: 28),
            Row(children: [
              const Spacer(),
              OutlinedButton(onPressed: () => context.go('/roles'), child: const Text('Cancel')),
              const SizedBox(width: 12),
              ElevatedButton.icon(icon: const Icon(LucideIcons.check, size: 16), label: const Text('Create Role'), onPressed: () {}),
            ]),
          ]),
        ),
      ]),
    );
  }
}
