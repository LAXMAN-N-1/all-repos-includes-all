import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../core/providers.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/theme_toggle.dart';
import '../../settings/settings_screen.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current user provider or just current user from auth state
    // currentUserProvider is usually defined in auth_providers.dart or core/providers.dart
    // Let's assume we can access user via authState
    // But currentUserProvider is cleaner.
    // I need to make sure currentUserProvider is available.
    // It was used in my failed attempt: import '../../../core/providers.dart';
    
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    // Greeting logic
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          // Profile Photo
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null
                ? Text(
                    (user?.name ?? 'D').substring(0, 1).toUpperCase(),
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          
          AppSpacing.gapW12,
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greeting,',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  user?.name ?? "Dealer",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user?.dealershipName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            user!.dealershipName!,
                            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textHint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
