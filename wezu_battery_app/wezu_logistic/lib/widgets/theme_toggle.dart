import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme_provider.dart';
import '../config/app_colors.dart';
import '../utils/app_haptics.dart';
import 'theme_transition_wrapper.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    IconData icon;
    if (themeMode == ThemeMode.light) {
      icon = Icons.wb_sunny_outlined;
    } else if (themeMode == ThemeMode.dark) {
      icon = Icons.nightlight_round;
    } else {
      // System mode
      final brightness = MediaQuery.of(context).platformBrightness;
      icon = brightness == Brightness.dark ? Icons.nightlight_round : Icons.wb_sunny_outlined;
    }

    return IconButton(
      onPressed: () {
        AppHaptics.impact();
        // Find button position for the reveal effect
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        Offset position = box != null 
            ? box.localToGlobal(box.size.center(Offset.zero))
            : Offset.zero;

        // Calculate new theme mode
        final current = themeMode == ThemeMode.system
            ? (MediaQuery.of(context).platformBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light)
            : themeMode;
        
        final newMode = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

        // Trigger transition
        ThemeTransitionWrapper.of(context).changeTheme(newMode, position);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isSun = child.key == const ValueKey(Icons.wb_sunny_outlined);
          
          return RotationTransition(
            turns: isSun 
                ? Tween<double>(begin: 0.5, end: 1).animate(animation) 
                : Tween<double>(begin: 0.75, end: 1).animate(animation),
            child: ScaleTransition(
              scale: animation, 
              child: child,
            ),
          );
        },
        child: Icon(
          icon,
          key: ValueKey(icon),
        ),
      ),
      tooltip: 'Toggle Theme',
    );
  }
}
