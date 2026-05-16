import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_text_styles.dart';
import '../../../config/app_constants.dart';
import '../../../models/order_model.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/app_card.dart';
import '../fleet/providers/logistics_providers.dart';
import '../fleet/widgets/google_map_widget.dart';

/// Full-screen live tracking view for an in_transit order.
/// Shows: live driver location on Google Maps, ETA, delay alert, contact buttons.
class TrackingScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const TrackingScreen({super.key, required this.order});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  Timer? _etaRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh ETA every 60s
    _etaRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && widget.order.assignedDriverId != null) {
        ref.invalidate(etaProvider((
          driverId: widget.order.assignedDriverId!,
          destination: widget.order.destination ?? '',
        )));
      }
    });
  }

  @override
  void dispose() {
    _etaRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverId = widget.order.assignedDriverId;

    if (driverId == null) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Live Tracking')),
        body: const Center(child: Text('No driver assigned to this order.')),
      );
    }

    final liveDriverAsync = ref.watch(driverLiveLocationProvider(driverId));
    final etaAsync = ref.watch(etaProvider((
      driverId: driverId,
      destination: widget.order.destination ?? '',
    )));

    return AppScaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(driverLiveLocationProvider(driverId));
              ref.invalidate(etaProvider((
                driverId: driverId,
                destination: widget.order.destination ?? '',
              )));
            },
          ),
        ],
      ),
      body: liveDriverAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load driver location: $e'),
            ],
          ),
        ),
        data: (driver) {
          if (driver == null) {
            return const Center(child: Text('Driver location unavailable'));
          }

          // Parse ETA result
          final etaResult = etaAsync.value;
          final routePoints = etaResult?.routePoints
              .map((p) => LatLng(p['lat']!, p['lng']!))
              .toList() ?? [];

          // Destination LatLng (best-effort: we don't have geocoded coords,
          // so we show the route from Directions API if available)
          final destination = widget.order.destination;

          // Delay alert
          final isDelayed = etaResult != null &&
              ref.watch(delayAlertProvider((
                etaMinutes: etaResult.etaMinutes,
                estimatedDelivery: widget.order.estimatedDelivery,
              )));

          return Column(
            children: [
              // ── Delay Alert Banner ──────────────────────────────────
              if (isDelayed)
                Container(
                  width: double.infinity,
                  color: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Delivery delay detected — ETA exceeds estimated delivery by more than ${AppConstants.delayAlertThresholdMinutes.toInt()} min',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Map ─────────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: GoogleMapWidget(
                    driver: driver,
                    routePoints: routePoints,
                  ),
                ),
              ),

              // ── Info Panel ──────────────────────────────────────────
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingMd.copyWith(top: 0),
                  child: Column(
                    children: [
                      // ETA Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.schedule_rounded,
                                  color: AppColors.info),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Estimated Arrival',
                                      style: AppTextStyles.caption),
                                  Text(
                                    etaAsync.when(
                                      data: (r) => r.etaText,
                                      loading: () => 'Calculating...',
                                      error: (_, __) => 'Unavailable',
                                    ),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: isDelayed
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDelayed)
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.error),
                          ],
                        ),
                      ),
                      AppSpacing.gapH12,

                      // Driver Info + Contact Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery Partner',
                                style: AppTextStyles.labelLarge),
                            AppSpacing.gapH12,
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: Text(
                                    driver.name[0],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(driver.name,
                                          style: AppTextStyles.bodyLarge),
                                      Text(
                                        '${driver.vehicleType} • ${driver.vehiclePlate}',
                                        style: AppTextStyles.caption,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.battery_full,
                                              size: 14,
                                              color: _batteryColor(
                                                  driver.currentBatteryLevel)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${driver.currentBatteryLevel}% device battery',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.phone_rounded),
                                    label: const Text('Call'),
                                    onPressed: () =>
                                        _launchPhone(driver.phoneNumber),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.message_rounded),
                                    label: const Text('Message'),
                                    onPressed: () =>
                                        _launchSms(driver.phoneNumber),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapH12,

                      // Destination Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Destination',
                                      style: AppTextStyles.caption),
                                  Text(
                                    destination ?? 'Unknown',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _batteryColor(int level) {
    if (level >= AppConstants.batteryFullThreshold) return AppColors.success;
    if (level >= AppConstants.batteryMediumThreshold) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
