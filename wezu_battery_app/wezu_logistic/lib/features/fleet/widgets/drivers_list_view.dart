import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_navigator.dart';
import '../../../../config/app_spacing.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../config/app_colors.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_feedback.dart';
import '../../../../widgets/app_loader.dart';
import '../../../models/driver_model.dart';
import '../../fleet/widgets/driver_status_chip.dart';
import '../../fleet/providers/logistics_providers.dart';

class DriversListView extends ConsumerWidget {
  const DriversListView({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(fleetListProvider);

    return driversAsync.when(
      data: (drivers) {
        if (drivers.isEmpty) {
          return const AppEmptyState(
            message: 'No drivers found',
            icon: Icons.local_shipping_outlined,
          );
        }
        return ListView.separated(
          controller: scrollController,
          padding: AppSpacing.screenPadding,
          itemCount: drivers.length,
          separatorBuilder: (context, index) => AppSpacing.gapH12,
          itemBuilder: (context, index) {
            final driver = drivers[index];
            return _DriverCard(driver: driver);
          },
        );
      },
      error: (err, stack) => AppErrorState(
        message: 'Failed to load drivers: $err',
        onRetry: () => ref.read(fleetListProvider.notifier).refresh(),
      ),
      loading: () => const AppLoader(),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverModel driver;

  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        AppNavigator.toDriverDetail(context, driverId: driver.id);
      },
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                driver.name.substring(0, 1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            AppSpacing.gapW16,

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: AppTextStyles.titleMedium),
                  AppSpacing.gapH4,
                  AppSpacing.gapH4,
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      AppSpacing.gapW4,
                      Flexible(
                        child: Text(
                          '${driver.vehicleType} • ${driver.vehiclePlate}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.warning),
                      AppSpacing.gapW4,
                      Text(
                        driver.rating.toString(),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.gapW12,
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      AppSpacing.gapW4,
                      Text(
                        '${driver.completedDeliveries} del.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status
            DriverStatusChip(status: driver.status),
          ],
        ),
      ),
    );
  }
}
