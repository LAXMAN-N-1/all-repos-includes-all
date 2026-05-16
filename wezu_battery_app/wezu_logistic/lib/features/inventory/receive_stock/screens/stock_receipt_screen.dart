import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/manifest_model.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../config/app_routes.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/widgets.dart';
import '../../../../config/app_navigator.dart';

class StockReceiptScreen extends StatelessWidget {
  final ManifestModel manifest;

  const StockReceiptScreen({super.key, required this.manifest});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Receipt'),
            leading: IconButton(
              icon: const Icon(Icons.close),
                  onPressed: () => AppNavigator.toInventory(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 64),
                  AppSpacing.gapH16,
                  Text(
                    'Stock Received Successfully',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH8,
                  Text(
                    'Manifest #${manifest.id}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Source: ${manifest.source}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  AppSpacing.gapH32,
                  _buildSummaryCard(context),
                  AppSpacing.gapH24,
                  if (manifest.issueCount > 0)
                     Text(
                      'Issues Reported',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                ],
              ),
            ),
          ),
          if (manifest.issueCount > 0)
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = manifest.items
                        .where((i) =>
                            i.status == ManifestItemStatus.damaged ||
                            i.status == ManifestItemStatus.missing ||
                            i.status == ManifestItemStatus.extra)
                        .elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AppCard(
                        child: ListTile(
                          leading: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status)),
                          title: Text(item.batteryId),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  AppStatusBadge(
                    label: item.status.label,
                    color: _getStatusColor(item.status),
                  ),
                              if (item.damageReport != null)
                                Text('Report: ${item.damageReport}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: manifest.issueCount,
                ),
              ),
            ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: AppButton(
                  label: 'Done',
                      onPressed: () => AppNavigator.toInventory(context),
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(context, 'Total', '${manifest.totalItems}'),
            _buildStat(context, 'Received', '${manifest.scannedCount}', color: AppColors.success),
            _buildStat(context, 'Issues', '${manifest.issueCount}', color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  IconData _getStatusIcon(ManifestItemStatus status) {
    switch (status) {
      case ManifestItemStatus.missing:
        return Icons.help_outline;
      case ManifestItemStatus.damaged:
        return Icons.broken_image_outlined;
      case ManifestItemStatus.extra:
        return Icons.add_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(ManifestItemStatus status) {
    switch (status) {
      case ManifestItemStatus.missing:
        return AppColors.warning;
      case ManifestItemStatus.damaged:
        return AppColors.error;
      case ManifestItemStatus.extra:
        return AppColors.info;
      default:
        return AppColors.textHint;
    }
  }
}
