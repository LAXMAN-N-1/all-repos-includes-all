import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/profile_provider.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class BusinessProfileSection extends ConsumerWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final VoidCallback onLocateOnMap;
  final VoidCallback onGstinVerified;

  const BusinessProfileSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    required this.onLocateOnMap,
    required this.onGstinVerified,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsCard(
          title: 'Business Identity',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: 'Real-time Data',
          children: [
            _buildIdentityHeader(ref),
            const SizedBox(height: 48),
            _buildField(
              'Business Display Name', 
              'business_name', 
              placeholder: 'Legal entity name...',
              maxLength: 100,
            ),
            _buildField(
              'GSTIN Number', 
              'gstin', 
              isMono: true, 
              showVerify: true,
              maxLength: 15,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
              counterText: '',
            ),
            _buildField(
              'PAN Number', 
              'pan', 
              isMono: true,
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
              counterText: '',
            ),
            _buildField(
              'Year Established', 
              'year', 
              placeholder: 'e.g. 2024',
              maxLength: 4,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              counterText: '',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildField(
              'Website URL', 
              'website', 
              placeholder: 'https://',
              maxLength: 255,
              keyboardType: TextInputType.url,
            ),
            _buildField(
              'Business Description', 
              'description', 
              isMultiline: true,
              maxLength: 500,
            ),
          ],
        ),
        const SizedBox(height: 32),
        SettingsCard(
          title: 'Primary Business Address',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Real-time Data',
          children: [
             _buildField('Street Address', 'street'),
             _buildField('City', 'city'),
             _buildField(
               'Postal Code', 
               'zip',
               keyboardType: TextInputType.number,
               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
             ),
             const SizedBox(height: 12),
             AddressMapTile(onLocate: onLocateOnMap),
          ],
        ),
      ],
    );
  }

  Widget _buildIdentityHeader(WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    
    return Row(
      children: [
        const LogoUploadZone(),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controllers['business_name']!,
                      builder: (context, value, _) {
                        // Priority: 1. User is typing (controller not empty) 
                        //           2. Backend data (profile not null)
                        //           3. Default placeholder
                        String displayName = 'Business Account';
                        if (value.text.isNotEmpty) {
                          displayName = value.text;
                        } else if (profile?.businessName != null && profile!.businessName!.isNotEmpty) {
                          displayName = profile.businessName!;
                        }
                        
                        return Text(
                          displayName, 
                          style: SettingsTheme.h2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10), 
                  const Tooltip(
                    message: 'Official verified dealer account',
                    child: Icon(LucideIcons.badgeCheck, color: SettingsTheme.primaryCyan, size: 20),
                  ),
                ]
              ),
              const SizedBox(height: 4),
              Text(
                'Verification Status: ACTIVE', 
                style: SettingsTheme.subline.copyWith(
                  color: SettingsTheme.primaryGreen, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String key, {
    bool isMono = false, 
    bool showVerify = false, 
    bool isMultiline = false, 
    String? placeholder, 
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? counterText,
  }) {
    final controller = controllers[key];
    final isModified = controller != null && controller.text != (initialValues[key] ?? '');
    
    // All fields in BusinessProfileSection are now connected to the backend
    final status = 'Real-time Data';

    return SettingsFieldRow(
      label: label,
      controller: controller,
      isModified: isModified,
      isMono: isMono,
      isMultiline: isMultiline,
      placeholder: placeholder,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      textCapitalization: textCapitalization,
      counterText: counterText,
      suffix: showVerify 
        ? VerifyButton(
            controller: controller,
            onTap: () {
              // Notify parent of verification success
              onGstinVerified();
              debugPrint('GSTIN Verified for $key');
            },
          ) 
        : null,
      dataStatus: status,
    );
  }
}
