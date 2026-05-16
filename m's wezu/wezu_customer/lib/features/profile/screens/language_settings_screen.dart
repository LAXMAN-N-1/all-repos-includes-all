import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/core/theme/theme_provider.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  static const _languages = <Map<String, String>>[
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'Hindi'},
    {'code': 'te', 'label': 'Telugu'},
    {'code': 'ta', 'label': 'Tamil'},
  ];

  String _selectedCode = 'en';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = ref.read(sharedPrefsProvider);
    setState(() {
      _selectedCode = prefs.getString('preferred_language_code') ?? 'en';
      _loading = false;
    });
  }

  Future<void> _selectLanguage(String code) async {
    setState(() => _selectedCode = code);
    await ref.read(sharedPrefsProvider).setString('preferred_language_code', code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language preference saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Language',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedCode == language['code'];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      width: 1.2,
                    ),
                    boxShadow: AppTheme.shadowLight,
                  ),
                  child: ListTile(
                    onTap: () => _selectLanguage(language['code']!),
                    title: Text(
                      language['label']!,
                      style: GoogleFonts.outfit(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
