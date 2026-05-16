import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/api/api_client.dart';

import '../providers/profile_provider.dart';
import '../models/profile_state.dart';
import '../../../core/providers/auth_provider.dart';

// Modular Imports
import 'settings_theme.dart';
import 'settings_common_widgets.dart';
import 'business_profile_section.dart';
import 'contact_info_section.dart';
import 'verification_status_section.dart';
import 'station_defaults_section.dart';
import 'inventory_alerts_section.dart';
import 'notifications_section.dart';
import 'bank_payouts_section.dart';
import 'change_bank_drawer.dart';
import 'security_section.dart';
import 'rental_settings_section.dart';
import '../providers/settings_extra_providers.dart';
import 'danger_zone_section.dart';
import 'danger_zone_dialog.dart';
import 'appearance_section.dart';
import 'language_region_section.dart';
import 'date_time_section.dart';
import '../../onboarding/providers/kyc_status_provider.dart';
import '../models/settings_extra_models.dart';

// ── SETTINGS SCREEN ─────────────────────────────────────────────
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  String _activeSection = 'Business Profile';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State for unsaved changes tracking
  late Map<String, TextEditingController> _controllers;
  late Map<String, String> _initialValues;
  late Map<String, dynamic> _portalPreferences;
  final Map<String, bool> _toggles = {};
  final Map<String, bool> _initialToggles = {};
  final ValueNotifier<int> _modifiedCount = ValueNotifier<int>(0);
  bool _isGstinVerified = true;
  bool _showSaveSuccess = false;
  Timer? _successTimer;

  // Sync-once flags: prevent provider rebuilds from overwriting user input
  bool _profileSynced = false;
  bool _stationDefaultsSynced = false;
  bool _inventoryRulesSynced = false;
  bool _rentalSettingsSynced = false;

  @override
  void initState() {
    super.initState();

    _initialValues = {
      'business_name': '',
      'gstin': '',
      'pan': '',
      'year': '',
      'website': '',
      'description': '',
      'street': '',
      'city': '',
      'zip': '',
      'contact_email': '',
      'phone_primary': '',
      'phone_alternate': '',
      'phone_whatsapp': '',
      'support_email': '',
      'support_phone': '',
      'station_open_time': '08:00 AM',
      'station_close_time': '10:00 PM',
      'battery_capacity': '60V 30Ah',
      'low_stock_threshold': '5',
      'alert_offline_val': '30',
      'alert_anomaly_val': '15',
      'bank_account_mask': '**** **** 8842',
      'ifsc_code': 'HDFC0001234',
      'payout_schedule': 'Weekly',
      'payout_threshold': '5000',
      'current_password': '',
      'new_password': '',
      'confirm_password': '',
      'session_timeout': '4 hrs',
      'daily_rate': '150.0',
      'security_deposit': '2000.0',
      'late_fee_hourly': '25.0',
      'grace_period_hours': '2',
      'max_concurrent_rentals': '2',
      'min_battery_checkout': '85',
      'postal_code': '560001',
    };

    // ── PORTAL MOCK PREFERENCES ───────────────────────────────────
    _portalPreferences = {
      'theme': 'dark',
      'accent_color': 'cyan',
      'language': 'en',
      'region': 'India',
      'date_format': 'DD/MM/YYYY',
      'use_24h': false,
      'timezone': '(GMT+05:30) India Standard Time',
    };

    _controllers = _initialValues
        .map((key, value) => MapEntry(key, TextEditingController(text: value)));
    _controllers.forEach(
        (key, controller) => controller.addListener(_updateModifiedCount));

    // Add GSTIN listener to reset verification on change
    _controllers['gstin']?.addListener(() {
      final current = _controllers['gstin']?.text ?? '';
      final initial = _initialValues['gstin'] ?? '';
      if (current != initial) {
        if (_isGstinVerified) {
          setState(() => _isGstinVerified = false);
        }
      } else {
        if (!_isGstinVerified) {
          setState(() => _isGstinVerified = true);
        }
      }
    });

    // Notification Toggles (Real Backend Flags)
    _initToggle('low_stock_push', true);
    _initToggle('low_stock_email', false);
    _initToggle('maintenance_push', true);
    _initToggle('maintenance_email', false);
    _initToggle('rental_reminders_push', true);
    _initToggle('rental_reminders_email', true);
    _initToggle('payment_push', true);
    _initToggle('payment_email', true);
    _initToggle('swap_suggestions_push', true);
    _initToggle('swap_suggestions_email', false);

    // Grid Notification Events
    final events = [
      'new_ticket',
      'status_change',
      'low_inventory',
      'maintenance',
      'payout',
      'registration',
      'role_change'
    ];
    for (var event in events) {
      _initToggle('notify_${event}_email', true);
      _initToggle('notify_${event}_sms', false);
    }

    // Security Section (Initial Mock State)
    _initToggle('2fa_enabled', false);

    // Rental Settings (Mock fallback)
    _initToggle('allow_extension', true);
    _initToggle('allow_pause', true);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs =
        await ref.read(profileProvider.notifier).fetchNotificationPreferences();
    if (prefs.isNotEmpty && mounted) {
      setState(() {
        prefs.forEach((key, value) {
          if (_toggles.containsKey(key)) {
            _toggles[key] = value;
            _initialToggles[key] = value;
          }
        });
      });
    }
  }

  void _initToggle(String key, bool value) {
    _toggles[key] = value;
    _initialToggles[key] = value;
  }

  void _updateModifiedCount() {
    int count = 0;
    _controllers.forEach((key, controller) {
      if (controller.text != _initialValues[key]) count++;
    });
    _toggles.forEach((key, value) {
      if (value != _initialToggles[key]) count++;
    });
    _modifiedCount.value = count;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _modifiedCount.dispose();
    _successTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final isNarrow = MediaQuery.of(context).size.width < 800;

    // Sync from providers (only once per provider load)
    if (!_profileSynced && !state.isLoading && state.profile != null) {
      _profileSynced = true;
      _syncFromProfile(state.profile!);
    }

    final stationDefaultsState = ref.watch(stationDefaultsProvider);
    if (!_stationDefaultsSynced &&
        !stationDefaultsState.isLoading &&
        stationDefaultsState.data != null) {
      _stationDefaultsSynced = true;
      _syncFromStationDefaults(stationDefaultsState.data!);
    }

    final inventoryRulesState = ref.watch(inventoryRulesProvider);
    if (!_inventoryRulesSynced &&
        !inventoryRulesState.isLoading &&
        inventoryRulesState.data != null) {
      _inventoryRulesSynced = true;
      _syncFromInventoryRules(inventoryRulesState.data!);
    }

    final rentalSettingsState = ref.watch(rentalSettingsProvider);
    if (!_rentalSettingsSynced &&
        !rentalSettingsState.isLoading &&
        rentalSettingsState.data != null) {
      _rentalSettingsSynced = true;
      _syncFromRentalSettings(rentalSettingsState.data!);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SettingsTheme.backgroundDark,
      endDrawer: _buildEndDrawer(),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isNarrow) _buildSidebar(),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        isNarrow
                            ? (Theme.of(context).platform ==
                                    TargetPlatform.android
                                ? 8
                                : 16)
                            : 48,
                        16,
                        isNarrow
                            ? (Theme.of(context).platform ==
                                    TargetPlatform.android
                                ? 8
                                : 16)
                            : 48,
                        160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNarrow) ...[
                          _buildMobileMenuTrigger(),
                          const SizedBox(height: 16),
                        ],
                        if (state.isLoading && state.profile == null)
                          const Center(
                              child: CircularProgressIndicator(
                                  color: SettingsTheme.primaryGreen))
                        else if (state.error != null &&
                            state.error != 'Empty profile data' &&
                            state.profile == null)
                          ErrorPanel(message: state.error!)
                        else
                          _buildSectionContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── GLOBAL SAVE BAR (RESTORED) ───────────────────────────
          ValueListenableBuilder<int>(
            valueListenable: _modifiedCount,
            builder: (context, count, child) {
              if (count == 0 && !_showSaveSuccess)
                return const SizedBox.shrink();
              return Positioned(
                bottom: 32,
                left: isNarrow ? 16 : 48,
                right: isNarrow ? 16 : 48,
                child: FloatingSaveBar(
                  count: count,
                  onSave: _handleSave,
                  onDiscard: _handleDiscard,
                  isSaving: state.isUpdating,
                  isSuccess: _showSaveSuccess,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _syncFromProfile(ProfileDto profile) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateField('business_name', profile.businessName ?? '');
      _updateField('gstin', profile.gstNumber ?? '');
      _updateField('pan', profile.panNumber ?? '');
      _updateField(
          'contact_email', profile.email ?? profile.contactEmail ?? '');
      _updateField('phone_primary', profile.contactPhone ?? '');
      _updateField('street', profile.addressLine1 ?? '');
      _updateField('city', profile.city ?? '');
      _updateField('zip', profile.pincode ?? '');
      _updateField('phone_alternate', profile.alternatePhone ?? '');
      _updateField('phone_whatsapp', profile.whatsappNumber ?? '');
      _updateField('support_email', profile.supportEmail ?? '');
      _updateField('support_phone', profile.supportPhone ?? '');
      _updateField('year', profile.yearEstablished ?? '');
      _updateField('website', profile.websiteUrl ?? '');
      _updateField('description', profile.businessDescription ?? '');

      if (profile.bankDetails != null) {
        final bank = profile.bankDetails!;
        final acc = bank['account_number']?.toString() ?? '';
        final mask =
            acc.length > 4 ? '**** **** ${acc.substring(acc.length - 4)}' : acc;
        _updateField('bank_account_mask', mask);
        _updateField('ifsc_code', bank['ifsc_code']?.toString() ?? '');
      }
    });
  }

  void _updateField(String key, String value) {
    _controllers[key]?.text = value;
    _initialValues[key] = value;
    _updateModifiedCount();
  }

  void _syncFromStationDefaults(StationDefaultsDto data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateField('station_open_time', data.stationOpenTime ?? '08:00 AM');
      _updateField('station_close_time', data.stationCloseTime ?? '10:00 PM');
      _updateField('battery_capacity', data.batteryCapacity ?? '60V 30Ah');
      _updateField('low_stock_threshold', data.lowStockThreshold ?? '5');
    });
  }

  void _syncFromInventoryRules(InventoryRulesDto data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateField('alert_offline_val', data.alertOfflineVal ?? '30');
      _updateField('alert_anomaly_val', data.alertAnomalyVal ?? '15');
    });
  }

  void _syncFromRentalSettings(RentalSettingsDto data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateField('daily_rate', data.dailyRate?.toString() ?? '150.0');
      _updateField(
          'security_deposit', data.securityDeposit?.toString() ?? '2000.0');
      _updateField('late_fee_hourly', data.lateFeeHourly?.toString() ?? '25.0');
      _updateField(
          'grace_period_hours', data.gracePeriodHours?.toString() ?? '2');
      _updateField(
          'max_concurrent_rentals', data.maxConcurrentRentals.toString());
      _updateField('min_battery_checkout', data.minBatteryCheckout.toString());
      setState(() {
        _toggles['allow_extension'] = data.allowExtension;
        _toggles['allow_pause'] = data.allowPause;
        _initialToggles['allow_extension'] = data.allowExtension;
        _initialToggles['allow_pause'] = data.allowPause;
      });
    });
  }

  void _handleSave() async {
    final Map<String, dynamic> updateData = {};
    final mapping = {
      'business_name': 'business_name',
      'gstin': 'gst_number',
      'pan': 'pan_number',
      'phone_primary': 'contact_phone',
      'contact_email': 'contact_email',
      'street': 'address_line1',
      'city': 'city',
      'zip': 'pincode',
      'year': 'year_established',
      'website': 'website_url',
      'description': 'business_description',
      'phone_alternate': 'alternate_phone',
      'phone_whatsapp': 'whatsapp_number',
      'support_email': 'support_email',
      'support_phone': 'support_phone',
    };

    // Collect all text changes
    _controllers.forEach((key, controller) {
      if (controller.text != (_initialValues[key] ?? '')) {
        final backendKey = mapping[key] ?? key;
        updateData[backendKey] = controller.text;
      }
    });

    final Map<String, bool> toggleUpdates = {};
    _toggles.forEach((key, value) {
      if (value != _initialToggles[key]) {
        toggleUpdates[key] = value;
      }
    });

    if (updateData.isEmpty && toggleUpdates.isEmpty) return;

    bool profileSuccess = true;
    if (updateData.isNotEmpty) {
      profileSuccess =
          await ref.read(profileProvider.notifier).updateProfile(updateData);
    }

    bool toggleSuccess = true;
    if (toggleUpdates.isNotEmpty) {
      toggleSuccess = await ref
          .read(profileProvider.notifier)
          .updateNotificationPreferences(toggleUpdates);
    }

    // Station Defaults Save
    bool stationDefaultsSuccess = true;
    final Map<String, dynamic> stationUpdates = {};
    const stationKeys = [
      'station_open_time',
      'station_close_time',
      'battery_capacity',
      'low_stock_threshold'
    ];
    for (var key in stationKeys) {
      if (_controllers[key]?.text != _initialValues[key]) {
        stationUpdates[key] = _controllers[key]?.text;
      }
    }
    if (stationUpdates.isNotEmpty) {
      stationDefaultsSuccess = await ref
          .read(stationDefaultsProvider.notifier)
          .update(stationUpdates);
    }

    // Inventory Rules Save
    bool inventoryRulesSuccess = true;
    final Map<String, dynamic> inventoryUpdates = {};
    const inventoryKeys = ['alert_offline_val', 'alert_anomaly_val'];
    for (var key in inventoryKeys) {
      if (_controllers[key]?.text != _initialValues[key]) {
        inventoryUpdates[key] = _controllers[key]?.text;
      }
    }
    if (inventoryUpdates.isNotEmpty) {
      inventoryRulesSuccess = await ref
          .read(inventoryRulesProvider.notifier)
          .update(inventoryUpdates);
    }

    // Rental Settings Save
    bool rentalSuccess = true;
    final Map<String, dynamic> rentalUpdates = {};
    const rentalKeys = [
      'daily_rate',
      'security_deposit',
      'late_fee_hourly',
      'grace_period_hours',
      'max_concurrent_rentals',
      'min_battery_checkout'
    ];
    for (var key in rentalKeys) {
      if (_controllers[key]?.text != _initialValues[key]) {
        rentalUpdates[key] = _controllers[key]?.text;
      }
    }
    ['allow_extension', 'allow_pause'].forEach((key) {
      if (_toggles[key] != _initialToggles[key]) {
        rentalUpdates[key] = _toggles[key];
      }
    });

    if (rentalUpdates.isNotEmpty) {
      rentalSuccess =
          await ref.read(rentalSettingsProvider.notifier).update(rentalUpdates);
    }

    // Password Change Logic
    bool passwordUpdateSuccess = true;
    final currentPass = _controllers['current_password']?.text ?? '';
    final newPass = _controllers['new_password']?.text ?? '';
    final confirmPass = _controllers['confirm_password']?.text ?? '';

    if (newPass.isNotEmpty && currentPass.isNotEmpty) {
      if (newPass == confirmPass) {
        final error = await ref
            .read(profileProvider.notifier)
            .changePassword(currentPass, newPass);
        if (error == null) {
          if (mounted) {
            // Success: Show message and logout
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Password changed successfully! Logging out of all devices for security...'),
                backgroundColor: SettingsTheme.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );

            // Wait for user to read
            await Future.delayed(const Duration(seconds: 2));

            // Perform global logout (local clears storage, backend team handles others)
            await ref.read(authProvider.notifier).logout();

            // Aggressive redirect: Force navigation to login
            if (mounted) {
              GoRouter.of(context).go('/login');
            }
          }
        } else {
          passwordUpdateSuccess = false;
          if (mounted) {
            _showPasswordErrorDialog(context, error);
          }
        }
      } else {
        passwordUpdateSuccess = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('New passwords do not match'),
              backgroundColor: SettingsTheme.errorRed));
        }
      }
    }

    if (mounted &&
        (profileSuccess ||
            toggleSuccess ||
            passwordUpdateSuccess ||
            stationDefaultsSuccess ||
            inventoryRulesSuccess)) {
      setState(() {
        if (profileSuccess) {
          updateData.forEach((backendKey, value) {
            final originalKey = mapping.entries
                .firstWhere((e) => e.value == backendKey,
                    orElse: () => MapEntry(backendKey, backendKey))
                .key;
            _initialValues[originalKey] = value.toString();
          });
        }
        if (stationDefaultsSuccess) {
          stationUpdates
              .forEach((key, value) => _initialValues[key] = value.toString());
        }
        if (inventoryRulesSuccess) {
          inventoryUpdates
              .forEach((key, value) => _initialValues[key] = value.toString());
        }
        if (rentalSuccess) {
          rentalUpdates.forEach((key, value) {
            if (value is bool) {
              _initialToggles[key] = value;
            } else {
              _initialValues[key] = value.toString();
            }
          });
        }
        if (toggleSuccess) {
          toggleUpdates.forEach((key, value) {
            _initialToggles[key] = value;
          });
        }
        _updateModifiedCount();
      });

      // Auto-dismiss success state
      if (profileSuccess && toggleSuccess && passwordUpdateSuccess) {
        _successTimer?.cancel();
        setState(() => _showSaveSuccess = true);
        _successTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showSaveSuccess = false);
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save changes'),
          backgroundColor: SettingsTheme.errorRed));
    }
  }

  void _showPasswordErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SettingsTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: SettingsTheme.errorRed),
            const SizedBox(width: 12),
            Text('Security Alert', style: SettingsTheme.h2),
          ],
        ),
        content: Text(
          message,
          style: SettingsTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(
                    color: SettingsTheme.primaryGreen,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleDiscard() {
    _controllers.forEach((key, c) => c.text = _initialValues[key] ?? '');
    setState(() {
      _toggles
          .forEach((key, _) => _toggles[key] = _initialToggles[key] ?? true);
    });
    _updateModifiedCount();
  }

  Widget _buildMobileMenuTrigger() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: SettingsTheme.shellDark,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SETTINGS NAVIGATION',
                    style: SettingsTheme.subline
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(child: _buildSidebarContent(isMobile: true)),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: SettingsTheme.borderSubtle),
            borderRadius: BorderRadius.circular(8),
            color: SettingsTheme.shellDark),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.menu,
                color: SettingsTheme.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Text('Change Section', style: SettingsTheme.body),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: SettingsTheme.shellDark,
        border: Border(right: BorderSide(color: SettingsTheme.borderSubtle)),
      ),
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent({bool isMobile = false}) {
    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shrinkWrap: isMobile,
      physics: isMobile ? const BouncingScrollPhysics() : null,
      children: [
        _buildNavGroup(
            'ACCOUNT',
            [
              ('Business Profile', LucideIcons.briefcase),
              ('Contact Information', LucideIcons.mail),
              ('Verification Status', LucideIcons.shieldCheck),
            ],
            isMobile),
        const Divider(height: 32, color: SettingsTheme.borderSubtle),
        _buildNavGroup(
            'PORTAL',
            [
              ('Appearance', LucideIcons.palette),
              ('Language and Region', LucideIcons.globe),
              ('Date and Time Format', LucideIcons.clock),
            ],
            isMobile),
        const Divider(height: 32, color: SettingsTheme.borderSubtle),
        _buildNavGroup(
            'OPERATIONS',
            [
              ('Station Defaults', LucideIcons.mapPin),
              ('Inventory Alerts', LucideIcons.alertTriangle),
              ('Rental Settings', LucideIcons.repeat),
            ],
            isMobile),
        const Divider(height: 32, color: SettingsTheme.borderSubtle),
        const SizedBox(height: 12),
        _buildNavGroup(
            'MORE',
            [
              ('Notifications', LucideIcons.bell),
              ('Payments', LucideIcons.creditCard),
              ('Security', LucideIcons.lock),
            ],
            isMobile),
        if (isMobile) ...[
          const Divider(height: 1, color: SettingsTheme.borderSubtle),
          _buildNavItem('Danger Zone', LucideIcons.trash2,
              isMobile: isMobile, isDanger: true),
        ],
      ],
    );

    if (isMobile) return content;

    return Column(
      children: [
        Expanded(child: content),
        const Divider(height: 1, color: SettingsTheme.borderSubtle),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildNavItem('Danger Zone', LucideIcons.trash2,
              isMobile: isMobile, isDanger: true),
        ),
      ],
    );
  }

  Widget _buildNavGroup(
      String title, List<(String, IconData)> items, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
          child: Text(title,
              style: SettingsTheme.subline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8)),
        ),
        for (var item in items)
          _buildNavItem(item.$1, item.$2, isMobile: isMobile),
      ],
    );
  }

  Widget _buildNavItem(String label, IconData icon,
      {bool isMobile = false, bool isDanger = false}) {
    final isActive = _activeSection == label;
    final color = isDanger
        ? SettingsTheme.errorRed
        : (isActive ? SettingsTheme.primaryGreen : SettingsTheme.textHigh);

    return InkWell(
      onTap: () {
        setState(() => _activeSection = label);
        if (isMobile) Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? const Border(
                  left: BorderSide(color: SettingsTheme.primaryGreen, width: 2))
              : null,
          color: isActive
              ? SettingsTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon,
                size: 18, color: color.withValues(alpha: isActive ? 1.0 : 0.6)),
            const SizedBox(width: 12),
            Text(label,
                style: SettingsTheme.body.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget? _buildEndDrawer() {
    switch (_activeSection) {
      case 'Inventory Alerts':
        return const CustomAlertDrawer();
      case 'Payments':
        return const ChangeBankDrawer();
      case 'Danger Zone':
        return null;
      default:
        return null;
    }
  }

  Widget _buildSectionContent() {
    switch (_activeSection) {
      case 'Business Profile':
        return BusinessProfileSection(
          controllers: _controllers,
          initialValues: _initialValues,
          onLocateOnMap: () => _showMapPickerModal(context),
          onGstinVerified: () => setState(() => _isGstinVerified = true),
        );
      case 'Contact Information':
        return ContactInfoSection(
          controllers: _controllers,
          initialValues: _initialValues,
          onOpenEmailFlow: () => _showChangeEmailModal(context),
          onOpenHolidayCalendar: () => _showHolidayCalendarModal(context),
        );
      case 'Verification Status':
        final kycState = ref.watch(kycStatusProvider);
        return VerificationStatusSection(kycState: kycState);
      case 'Station Defaults':
        final stationState = ref.watch(stationDefaultsProvider);
        return StationDefaultsSection(
          controllers: _controllers,
          initialValues: _initialValues,
          isRealTime: stationState.isRealTime,
        );
      case 'Inventory Alerts':
        final inventoryState = ref.watch(inventoryRulesProvider);
        return InventoryAlertsSection(
          controllers: _controllers,
          initialValues: _initialValues,
          toggles: _toggles,
          isRealTime: inventoryState.isRealTime,
          onToggle: (key, val) => setState(() {
            _toggles[key] = val;
            _updateModifiedCount();
          }),
          onAddCustom: () => _scaffoldKey.currentState?.openEndDrawer(),
        );
      case 'Rental Settings':
        final rentalState = ref.watch(rentalSettingsProvider);
        return RentalSettingsSection(
          controllers: [
            _controllers['daily_rate']!,
            _controllers['security_deposit']!,
            _controllers['late_fee_hourly']!,
            _controllers['grace_period_hours']!,
            _controllers['max_concurrent_rentals']!,
            _controllers['min_battery_checkout']!,
          ],
          initialValues: _initialValues,
          data: rentalState.data,
          isRealTime: rentalState.isRealTime,
        );
      case 'Notifications':
        return NotificationsSection(
          toggles: _toggles,
          onToggle: (key, val) => setState(() {
            _toggles[key] = val;
            _updateModifiedCount();
          }),
        );
      case 'Payments':
        return BankPayoutsSection(
          controllers: _controllers,
          initialValues: _initialValues,
          onOpenChangeBankDrawer: () =>
              _scaffoldKey.currentState?.openEndDrawer(),
          isRealTime: true, // Mark as connected since we sync from profile
        );
      case 'Security':
        final sessionsState = ref.watch(sessionsProvider);
        return SecuritySection(
          controllers: _controllers,
          initialValues: _initialValues,
          toggles: _toggles,
          sessionsState: sessionsState,
          onRevokeSession: (id) =>
              ref.read(sessionsProvider.notifier).revokeSession(id),
          onToggleSort: () =>
              ref.read(sessionsProvider.notifier).toggleSortOrder(),
          onRefresh: () => ref.read(sessionsProvider.notifier).refresh(),
          onToggle: (key, val) => setState(() {
            _toggles[key] = val;
            _updateModifiedCount();
          }),
          onForceLogout: () => _showForceLogoutDialog(context),
        );
      case 'Danger Zone':
        final profile = ref.watch(profileProvider).profile;
        final businessName = profile?.businessName ?? 'MY BUSINESS';

        return DangerZoneSection(
          businessName: businessName,
          onDeactivate: () => _showDangerDialog(
            context,
            title: 'Deactivate Account',
            description:
                'Are you sure you want to pause your business activities? You can reactivate at any time by contacting support.',
            actionLabel: 'Deactivate My Account',
            requiredBusinessName: businessName,
            onConfirmAction: (password) => ref.read(dioProvider).post(
                '/dealers/account/deactivate',
                data: {'password': password}),
          ),
          onExportData: () => _showExportNotice(context),
          onDeleteAccount: () => _showDangerDialog(
            context,
            title: 'Permanently Delete Account',
            description:
                'This is a final action. All your historical records, station data, and transactions will be deleted. This cannot be undone.',
            actionLabel: 'Delete Everything',
            requiredBusinessName: businessName,
            onConfirmAction: (password) => ref.read(dioProvider).delete(
                '/dealers/account/delete',
                data: {'password': password}),
          ),
        );
      case 'Appearance':
        return AppearanceSection(
          preferences: _portalPreferences,
          onPreferenceChanged: (key, value) =>
              setState(() => _portalPreferences[key] = value),
        );
      case 'Language and Region':
        return LanguageRegionSection(
          preferences: _portalPreferences,
          onPreferenceChanged: (key, value) =>
              setState(() => _portalPreferences[key] = value),
        );
      case 'Date and Time Format':
        return DateTimeSection(
          preferences: _portalPreferences,
          onPreferenceChanged: (key, value) =>
              setState(() => _portalPreferences[key] = value),
        );
      default:
        return PlaceholderSection(title: _activeSection);
    }
  }

  void _showDangerDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String actionLabel,
    required String requiredBusinessName,
    required Future<void> Function(String password) onConfirmAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => DangerZoneDialog(
        title: title,
        description: description,
        actionLabel: actionLabel,
        requiredBusinessName: requiredBusinessName,
        onConfirm: (password) async {
          Navigator.pop(context); // Close dialog

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
                child:
                    CircularProgressIndicator(color: SettingsTheme.errorRed)),
          );

          try {
            await onConfirmAction(password);
            if (mounted) {
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title Successful (Request Processed)'),
                  backgroundColor: SettingsTheme.primaryGreen,
                ),
              );
              // Aggressive redirect: Force navigation to login on destructive actions
              await ref.read(authProvider.notifier).logout();
              GoRouter.of(context).go('/login');
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context); // Close loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Action failed: $e'),
                  backgroundColor: SettingsTheme.errorRed,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showExportNotice(BuildContext context) {
    // Fire real API export request in background
    unawaited(_requestExportData());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SettingsTheme.surfaceDark,
        title: Text('Export All Data', style: SettingsTheme.h2),
        content: Text(
          'A full GDPR-compliant data export has been requested. Our system will generate a secure link and send it to your registered business email within 24-48 hours.',
          style: SettingsTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: SettingsTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _requestExportData() async {
    try {
      await ref.read(dioProvider).post('/dealers/export-data');
    } catch (e) {
      debugPrint("Export request failed: $e");
    }
  }

  void _showForceLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SettingsTheme.surfaceDark,
        title: Text('Force Logout all Sessions?', style: SettingsTheme.h2),
        content: Text(
          'This will invalidate all current active sessions across all your devices. You will need to log in again.',
          style: SettingsTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: SettingsTheme.mutedGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (mounted) {
                await ref.read(authProvider.notifier).logout();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SettingsTheme.errorRed.withValues(alpha: 0.2),
              foregroundColor: SettingsTheme.errorRed,
              side: const BorderSide(color: SettingsTheme.errorRed),
            ),
            child: const Text('Confirm Logout',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMapPickerModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => MapPickerModal(
            onLocationSelected: (address, city, zip) => setState(() {
                  _controllers['street']?.text = address;
                  _controllers['city']?.text = city;
                  _controllers['zip']?.text = zip;
                })));
  }

  void _showChangeEmailModal(BuildContext context) {
    showDialog(
        context: context, builder: (context) => const ChangeEmailModal());
  }

  void _showHolidayCalendarModal(BuildContext context) {
    showDialog(
        context: context, builder: (context) => const HolidayCalendarModal());
  }
}
