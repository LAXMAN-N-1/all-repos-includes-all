/// LS Flutter Kit — A premium, production-grade Flutter UI toolkit.
///
/// Provides glassmorphism widgets, responsive utilities, Dio-based networking,
/// secure auth flow, and reusable components for rapid app development.
library ls_flutter_kit;

// ── Core: Theme ──
export 'src/core/theme/app_colors.dart';
export 'src/core/theme/app_typography.dart';
export 'src/core/theme/app_spacing.dart';
export 'src/core/theme/app_radius.dart';
export 'src/core/theme/theme_builder.dart';
export 'src/core/theme/theme_extensions.dart';

// ── Core: Responsive ──
export 'src/core/responsive/responsive.dart';

// ── Core: Extensions ──
export 'src/core/extensions/extensions.dart';

// ── Core: Validators ──
export 'src/core/validators/validators.dart';

// ── Network ──
export 'src/network/api_client.dart';
export 'src/network/api_exception.dart';
export 'src/network/interceptors/interceptors.dart';

// ── Storage ──
export 'src/storage/storage.dart';

// ── Widgets: Glass ──
export 'src/widgets/glass/glass_container.dart';
export 'src/widgets/glass/glass_widgets.dart';

// ── Widgets: Feedback ──
export 'src/widgets/feedback/feedback_widgets.dart';

// ── Widgets: Buttons ──
export 'src/widgets/buttons/buttons.dart';

// ── Widgets: Cards ──
export 'src/widgets/cards/cards.dart';

// ── Widgets: Inputs ──
export 'src/widgets/inputs/inputs.dart';

// ── Widgets: Layout ──
export 'src/widgets/layout/layout_widgets.dart';

// ── Auth ──
export 'src/auth/auth.dart';

// ── Router ──
export 'src/router/router.dart';

// ── Services ──
export 'src/services/services.dart';

// ── Widgets: Navigation ──
export 'src/widgets/navigation/admin_sidebar.dart';
export 'src/widgets/navigation/side_menu_drawer.dart';
export 'src/widgets/navigation/context_menu.dart';

// ── Widgets: Tables ──
export 'src/widgets/tables/data_table_view.dart';

// ── Widgets: Charts ──
export 'src/widgets/charts/line_chart_widget.dart';
export 'src/widgets/charts/donut_chart_widget.dart';
export 'src/widgets/charts/bar_chart_widget.dart';

// ── Screens: Auth ──
export 'src/screens/auth/login_screen_template.dart';
export 'src/screens/auth/signup_screen_template.dart';
export 'src/screens/auth/otp_screen_template.dart';
export 'src/screens/auth/forgot_password_template.dart';

// ── Screens: Init ──
export 'src/screens/init/splash_screen_template.dart';
export 'src/screens/init/onboarding_template.dart';

// ── Widgets: Advanced Integration (Enterprise) ──
export 'src/widgets/inputs/advanced/searchable_dropdown.dart';
export 'src/widgets/inputs/advanced/media_picker_widget.dart';
export 'src/widgets/layout/advanced/infinite_scroll_view.dart';
export 'src/widgets/layout/advanced/slidable_list_item.dart';
export 'src/widgets/layout/advanced/standard_bottom_sheet.dart';
export 'src/widgets/hardware/permission_gate.dart';
