import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/app_animations.dart';
import '../../config/app_navigator.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../models/dashboard_stats_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_scanner.dart';
import '../../models/dashboard_alert_model.dart';
import '../../core/result.dart';

import 'providers/dashboard_providers.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/metric_card.dart';
import 'widgets/dashboard_fab_menu.dart';
import 'widgets/charts/battery_pie_chart.dart';
import 'widgets/charts/trend_line_chart.dart';
import '../inventory/providers/inventory_providers.dart';
import 'widgets/charts/station_bar_chart.dart';
import '../../models/dashboard_analytics_model.dart';
import '../../widgets/theme_toggle.dart';
import 'package:intl/intl.dart';

/// Dashboard screen — wired to providers for reactive data.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _fabCollapseProgress = ValueNotifier<double>(0);
  double _lastScrollOffset = 0;
  static const double _collapseTravel = 92;
  static const double _minScrollDelta = 0.2;
  bool _isGeneratingReport = false;
  ValueNotifier<_ReportProgressUiState>? _reportProgressNotifier;
  Timer? _reportProgressTimer;
  bool _isReportProgressDialogOpen = false;

  void _setFabProgress(double value) {
    final clamped = value.clamp(0.0, 1.0);
    final snapped = clamped <= 0.02 ? 0.0 : (clamped >= 0.98 ? 1.0 : clamped);
    if ((_fabCollapseProgress.value - snapped).abs() > 0.0001) {
      _fabCollapseProgress.value = snapped;
    }
  }

  @override
  void initState() {
    super.initState();
    // Load data on first build
    Future.microtask(() {
      ref.read(dashboardStatsProvider.notifier).loadStats();
      ref.read(recentActivityProvider.notifier).loadActivity();
      ref.read(dashboardAnalyticsProvider.notifier).loadAnalytics();
      ref.read(dashboardAlertsProvider.notifier).loadAlerts();
    });

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }
      final offset = _scrollController.position.pixels.clamp(
        0.0,
        double.infinity,
      );
      final delta = offset - _lastScrollOffset;
      _lastScrollOffset = offset;

      if (offset <= 0) {
        _setFabProgress(0);
      } else if (delta.abs() >= _minScrollDelta) {
        final next = _fabCollapseProgress.value + (delta / _collapseTravel);
        _setFabProgress(next);
      }
    });
  }

  @override
  void dispose() {
    _stopReportProgressTimer();
    _reportProgressNotifier?.dispose();
    _scrollController.dispose();
    _fabCollapseProgress.dispose();
    super.dispose();
  }

  void _onReceiveStock() {
    AppNavigator.toInventory(context);
    // TODO: Ideally open "Receive" dialog or deep link
  }

  void _onDispatchStock() {
    AppNavigator.toCreateOrder(context);
  }

  void _onViewInventory() {
    AppNavigator.toInventory(context);
  }

  void _showReportProgressDialog() {
    if (!mounted) return;
    _stopReportProgressTimer();
    _reportProgressNotifier?.dispose();
    _reportProgressNotifier = ValueNotifier(
      const _ReportProgressUiState(
        progress: 0.05,
        title: 'Preparing report',
        message: 'Starting secure report generation...',
      ),
    );
    _isReportProgressDialogOpen = true;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: _ReportProgressDialog(notifier: _reportProgressNotifier!),
        ),
      ).whenComplete(() {
        _isReportProgressDialogOpen = false;
        _stopReportProgressTimer();
        _reportProgressNotifier?.dispose();
        _reportProgressNotifier = null;
      }),
    );
  }

  void _setReportProgress({
    required double progress,
    required String title,
    required String message,
    bool isError = false,
    bool isComplete = false,
  }) {
    final notifier = _reportProgressNotifier;
    if (notifier == null) return;
    notifier.value = _ReportProgressUiState(
      progress: progress.clamp(0, 1).toDouble(),
      title: title,
      message: message,
      isError: isError,
      isComplete: isComplete,
    );
  }

  void _startReportProgressTimer({
    required double minProgress,
    required double maxProgress,
    required String title,
    required String message,
  }) {
    _stopReportProgressTimer();
    _setReportProgress(progress: minProgress, title: title, message: message);

    _reportProgressTimer = Timer.periodic(const Duration(milliseconds: 260), (
      _,
    ) {
      final notifier = _reportProgressNotifier;
      if (notifier == null) return;
      final current = notifier.value;
      final nextProgress = (current.progress + 0.012).clamp(
        minProgress,
        maxProgress,
      );
      if ((nextProgress - current.progress).abs() < 0.0001) return;
      notifier.value = current.copyWith(progress: nextProgress);
    });
  }

  void _stopReportProgressTimer() {
    _reportProgressTimer?.cancel();
    _reportProgressTimer = null;
  }

  Future<void> _closeReportProgressDialog({
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (!mounted || !_isReportProgressDialogOpen) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _handleReportFailure(String message) async {
    _setReportProgress(
      progress: 1,
      title: 'Could not finish report',
      message: message,
      isError: true,
    );
    await _closeReportProgressDialog(delay: const Duration(milliseconds: 1100));
    _showSnack(message);
  }

  Future<void> _onGenerateReport() async {
    if (_isGeneratingReport) {
      _showSnack('Report generation is already in progress.');
      return;
    }

    setState(() => _isGeneratingReport = true);
    _showReportProgressDialog();
    _setReportProgress(
      progress: 0.12,
      title: 'Submitting request',
      message: 'Sending dashboard metrics to report service...',
    );

    final repository = ref.read(dashboardRepositoryProvider);
    final nowUtc = DateTime.now().toUtc();
    final fromUtc = nowUtc.subtract(const Duration(days: 7));
    const reportFormat = 'pdf';

    try {
      final queueResult = await repository.queueDashboardReport(
        from: fromUtc,
        to: nowUtc,
        format: reportFormat,
      );
      if (!mounted) {
        return;
      }

      if (queueResult.isFailure || queueResult.dataOrNull == null) {
        await _handleReportFailure(
          queueResult.error ?? 'Failed to queue report.',
        );
        return;
      }

      final queued = queueResult.dataOrNull!;
      _startReportProgressTimer(
        minProgress: 0.28,
        maxProgress: 0.7,
        title: 'Building dashboard report',
        message: 'Crunching KPIs and preparing a professional PDF...',
      );

      final statusResult = await repository.waitForDashboardReport(
        queued.reportId,
      );
      if (!mounted) {
        return;
      }
      _stopReportProgressTimer();

      if (statusResult.isFailure || statusResult.dataOrNull == null) {
        await _handleReportFailure(
          statusResult.error ?? 'Failed to fetch report status.',
        );
        return;
      }

      final status = statusResult.dataOrNull!;
      if (status.isFailed) {
        await _handleReportFailure(
          status.detail?.trim().isNotEmpty == true
              ? status.detail!
              : 'Report generation failed.',
        );
        return;
      }
      if (!status.isCompleted || status.fileUrl == null) {
        await _handleReportFailure(
          'Report is still processing. Try again soon.',
        );
        return;
      }

      _setReportProgress(
        progress: 0.78,
        title: 'Downloading report',
        message: 'Fetching file from secure download URL...',
      );
      final downloadResult = await repository.downloadDashboardReportFile(
        status.fileUrl!,
      );
      if (!mounted) return;
      if (downloadResult.isFailure || downloadResult.dataOrNull == null) {
        await _handleReportFailure(
          downloadResult.error ?? 'Report download failed.',
        );
        return;
      }

      _setReportProgress(
        progress: 0.9,
        title: 'Saving file',
        message: 'Storing the PDF locally on this device...',
      );
      final savedPath = await _saveReportFile(
        bytes: downloadResult.dataOrNull!,
        reportId: status.reportId,
        extension: reportFormat,
      );
      if (!mounted) return;

      _setReportProgress(
        progress: 1,
        title: 'Opening report',
        message: 'Launching the report viewer...',
        isComplete: true,
      );
      final openResult = await OpenFilex.open(savedPath);
      if (!mounted) return;

      await _closeReportProgressDialog(
        delay: const Duration(milliseconds: 450),
      );
      if (!mounted) return;

      if (openResult.type == ResultType.done) {
        _showSnack('Report downloaded and opened on this device.');
        return;
      }

      final detail = openResult.message.trim();
      if (detail.isNotEmpty) {
        _showSnack('Report saved to $savedPath ($detail)');
      } else {
        _showSnack('Report saved to $savedPath');
      }
    } finally {
      _stopReportProgressTimer();
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  Future<String> _saveReportFile({
    required List<int> bytes,
    required String reportId,
    required String extension,
  }) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${baseDir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedReportId = reportId.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final fileName =
        'wezu_logistics_report_${sanitizedReportId}_$timestamp.$extension';
    final file = File('${reportsDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onScanQR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppScanner(
          continuous:
              true, // We handle the pop manually to avoid race conditions
          onScan: (code) {
            // Close the scanner immediately
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Process the code
            _handleScannedCode(code);
          },
        ),
      ),
    );
  }

  void _handleScannedCode(String code) {
    if (code.startsWith('BAT-')) {
      AppNavigator.toBatteryDetail(context, batteryId: code);
    } else if (code.startsWith('ORD-')) {
      AppNavigator.toOrderDetail(context, orderId: code);
    } else if (code.startsWith('MAN-')) {
      // For manifests, we search in inventory or go to receive stock
      // For now, let's assume we want to view it in the Receive Stock flow
      AppNavigator.toInventory(context);
      // Optional: triggering a search or receive flow could be added here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Manifest Scanned: $code')));
    } else {
      // Fallback: Search in Inventory
      ref.read(inventorySearchQueryProvider.notifier).state = code;
      AppNavigator.toInventory(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Searching for "$code"...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(dashboardStatsProvider);
    final activityState = ref.watch(recentActivityProvider);
    final analyticsState = ref.watch(dashboardAnalyticsProvider);
    final alertsState = ref.watch(dashboardAlertsProvider);

    return AppScaffold(
      // Add FAB Menu
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _fabCollapseProgress,
        builder: (context, progress, _) => DashboardFloatingActionMenu(
          collapseProgress: progress,
          onReceiveStock: _onReceiveStock,
          onDispatchStock: _onDispatchStock,
          onViewInventory: _onViewInventory,
          onGenerateReport: _onGenerateReport,
          onScanQR: _onScanQR,
        ),
      ),
      useSafeArea: false,
      // M3 Overhaul: No Standard AppBar, use CustomScrollView with SliverAppBar
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(dashboardStatsProvider.notifier).refreshStats(),
            ref.read(recentActivityProvider.notifier).loadActivity(),
            ref.read(dashboardAnalyticsProvider.notifier).loadAnalytics(),
            ref.read(dashboardAlertsProvider.notifier).loadAlerts(),
          ]);
        },
        color: Theme.of(context).colorScheme.primary, // M3
        child: CustomScrollView(
          controller: _scrollController,
          // physics: const BouncingScrollPhysics(), // Removed to allow platform default
          slivers: [
            // M3 Large Top Bar
            SliverAppBar.large(
              title: const Text('Wezu Logistics'),
              centerTitle: false,
              actions: [
                const ThemeToggle(),
                _buildNotificationMenu(context, alertsState),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _onScanQR,
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Main Content Area
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const DashboardHeader().sectionEntrance(),
                  AppSpacing.gapH24,

                  // ─── Metric Cards ──────────────────────────────────────
                  statsState.when(
                    initial: () => _buildMetricShimmer(),
                    loading: () => _buildMetricShimmer(),
                    loaded: (stats) => _buildMetricCards(stats),
                    error: (message) => _buildMetricError(message),
                  ),
                  AppSpacing.gapH24,

                  // ─── Quick Actions ─────────────────────────────────────
                  QuickActionsGrid(
                    onReceiveStock: _onReceiveStock,
                    onDispatchStock: _onDispatchStock,
                    onViewInventory: _onViewInventory,
                    onGenerateReport: _onGenerateReport,
                    onScanQR: _onScanQR,
                  ).sectionEntrance(delay: const Duration(milliseconds: 100)),

                  AppSpacing.gapH24,

                  // ─── Analytics Charts ──────────────────────────────────
                  analyticsState.when(
                    initial: () => _buildAnalyticsShimmer(),
                    loading: () => _buildAnalyticsShimmer(),
                    loaded: (data) => _buildAnalyticsSection(data),
                    error: (message) => _buildMetricError(message),
                  ),
                  AppSpacing.gapH24,

                  // ─── Section Title ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          AppNavigator.toActivity(context);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ).sectionEntrance(delay: const Duration(milliseconds: 200)),
                  AppSpacing.gapH12,

                  // ─── Activity List ─────────────────────────────────────
                  activityState.when(
                    initial: () => _buildActivityShimmer(),
                    loading: () => _buildActivityShimmer(),
                    loaded: (items) => _buildActivityList(items),
                    error: (message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  // Add extra padding at bottom for FAB
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationMenu(
    BuildContext context,
    AsyncState<List<DashboardAlert>> alertsState,
  ) {
    return PopupMenuButton<void>(
      tooltip: 'Notifications',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 12),
      elevation: 4,

      surfaceTintColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // More rounded
      icon: Badge(
        label:
            alertsState.dataOrNull != null && alertsState.dataOrNull!.isNotEmpty
            ? Text('${alertsState.dataOrNull!.length}')
            : null,
        isLabelVisible:
            alertsState.dataOrNull != null &&
            alertsState.dataOrNull!.isNotEmpty,
        child: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      itemBuilder: (context) {
        return alertsState.when(
          initial: () => [
            const PopupMenuItem(
              enabled: false,
              child: Text('No notifications'),
            ),
          ],
          loading: () => [
            const PopupMenuItem(enabled: false, child: Text('Loading...')),
          ],
          error: (_) => [
            const PopupMenuItem(
              enabled: false,
              child: Text('Error loading alerts'),
            ),
          ],
          loaded: (alerts) {
            if (alerts.isEmpty) {
              return [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('No notifications'),
                ),
              ];
            }

            final sortedAlerts = List<DashboardAlert>.from(alerts)
              ..sort(
                (a, b) => b.timestamp.compareTo(a.timestamp),
              ); // Newest first

            return [
              // Header
              PopupMenuItem(
                enabled: false,
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      height: 16,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),

              ...sortedAlerts.map((alert) {
                return PopupMenuItem(
                  height: 0, // Allow variable height content to define it
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Container
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: alert.severity.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          alert.severity.icon,
                          color: alert.severity.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeAgo(alert.timestamp),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.8),
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (alert.actionLabel != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                alert.actionLabel!,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Footer
              PopupMenuItem(
                enabled: false,
                height: 40,
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'View all notifications',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        );
      },
    );
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildMetricCards(DashboardStats stats) {
    return Column(
      children: [
        // Row 1: Key Performance
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.battery_charging_full_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primaryLight,
                label: 'Total Batteries',
                value: '${stats.totalBatteries}',
                onTap: () => AppNavigator.toInventory(context),
              ).metricEntrance(index: 0),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: MetricCard(
                icon: Icons.currency_rupee_rounded,
                iconColor: AppColors.success,
                iconBgColor: AppColors.successLight,
                label: 'Revenue',
                value: '₹${NumberFormat.compact().format(stats.revenue)}',
              ).metricEntrance(index: 1),
            ),
          ],
        ),
        AppSpacing.gapH12,

        // Row 2: Operational
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.outbound_rounded,
                iconColor: AppColors.info,
                iconBgColor: AppColors.infoLight,
                label: 'Sent Today',
                value: '${stats.sentToday}',
                trend: stats.sentTrend,
              ).metricEntrance(index: 2),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: MetricCard(
                icon: Icons.call_received_rounded,
                iconColor: AppColors.warning,
                iconBgColor: AppColors.warningLight,
                label: 'Received',
                value: '${stats.receivedToday}',
                // Show badge if pending Receipts > 0? MetricCard doesn't support badge yet but value works.
              ).metricEntrance(index: 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricShimmer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: AppShimmer(width: double.infinity, height: 100)),
            AppSpacing.gapW12,
            Expanded(child: AppShimmer(width: double.infinity, height: 100)),
          ],
        ),
        AppSpacing.gapH12,
        Row(
          children: [
            Expanded(child: AppShimmer(width: double.infinity, height: 100)),
            AppSpacing.gapW12,
            Expanded(child: AppShimmer(width: double.infinity, height: 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricError(String message) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            AppSpacing.gapW12,
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(dashboardStatsProvider.notifier).loadStats(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(List<ActivityItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No recent activity',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ActivityCard(item: item).listItem(index: entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildActivityShimmer() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppShimmer(width: double.infinity, height: 64),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(DashboardAnalyticsData data) {
    // Responsive layout can be handled here or via separate widget
    // For now, stacking them with some logic
    return Column(
      children: [
        // Row 1: Pie Chart & Station Bar Chart (Tablet/Desktop) or Column (Mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: AppCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: RepaintBoundary(
                                child: BatteryPieChart(
                                  title: 'Battery Readiness',
                                  data: data.batteryStatusDistribution,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.gapW16,
                        Expanded(
                          child: AppCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: RepaintBoundary(
                                child: StationBarChart(
                                  title: 'Order Pipeline',
                                  data: data.stationDispatchDistribution,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RepaintBoundary(
                        child: BatteryPieChart(
                          title: 'Battery Readiness',
                          data: data.batteryStatusDistribution,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapH16,
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RepaintBoundary(
                        child: StationBarChart(
                          title: 'Order Pipeline',
                          data: data.stationDispatchDistribution,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ).sectionEntrance(delay: const Duration(milliseconds: 150)),

        AppSpacing.gapH16,

        // Row 2: Trend Charts
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              child: TrendLineChart(
                title: 'Dispatch Units (Last 7 Days)',
                data: data.dailyDispatchTrend,
                lineColor: AppColors.primary,
              ),
            ),
          ),
        ).sectionEntrance(delay: const Duration(milliseconds: 180)),

        AppSpacing.gapH16,

        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              child: TrendLineChart(
                title: 'Delivered Orders (Last 7 Days)',
                data: data.inventoryLevelTrend,
                lineColor: AppColors.warning,
              ),
            ),
          ),
        ).sectionEntrance(delay: const Duration(milliseconds: 210)),
      ],
    );
  }

  Widget _buildAnalyticsShimmer() {
    return Column(
      children: [
        AppShimmer(width: double.infinity, height: 250),
        AppSpacing.gapH16,
        AppShimmer(width: double.infinity, height: 200),
      ],
    );
  }
}

class _ReportProgressUiState {
  const _ReportProgressUiState({
    required this.progress,
    required this.title,
    required this.message,
    this.isError = false,
    this.isComplete = false,
  });

  final double progress;
  final String title;
  final String message;
  final bool isError;
  final bool isComplete;

  _ReportProgressUiState copyWith({
    double? progress,
    String? title,
    String? message,
    bool? isError,
    bool? isComplete,
  }) {
    return _ReportProgressUiState(
      progress: progress ?? this.progress,
      title: title ?? this.title,
      message: message ?? this.message,
      isError: isError ?? this.isError,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class _ReportProgressDialog extends StatelessWidget {
  const _ReportProgressDialog({required this.notifier});

  final ValueNotifier<_ReportProgressUiState> notifier;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ValueListenableBuilder<_ReportProgressUiState>(
        valueListenable: notifier,
        builder: (context, state, _) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final accent = state.isError
              ? colorScheme.error
              : (state.isComplete ? AppColors.success : colorScheme.primary);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: state.isComplete ? 1.08 : 1,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      state.isError
                          ? Icons.error_outline_rounded
                          : (state.isComplete
                                ? Icons.check_circle_outline_rounded
                                : Icons.description_outlined),
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, 0.18),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    state.title,
                    key: ValueKey(state.title),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    state.message,
                    key: ValueKey(state.message),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AnimatedProgressBar(
                  progress: state.progress,
                  color: accent,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.progress * 100).round()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0, 1).toDouble();
    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.76), color],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.type == ActivityType.lowInventory
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primaryLight.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              item.type.icon,
              color: item.type == ActivityType.lowInventory
                  ? AppColors.error
                  : AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.labelLarge),
                AppSpacing.gapH4,
                Text(
                  _timeAgo(item.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
