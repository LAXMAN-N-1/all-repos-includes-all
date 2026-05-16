import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_extra_providers.dart';
import '../models/settings_extra_models.dart';
import 'package:flutter/services.dart';
import 'settings_theme.dart';

import '../../../core/api/api_client.dart';

bool get _showDataStatus =>
    kIsWeb || defaultTargetPlatform != TargetPlatform.android;

// ── SHARED UI: SETTINGS CARD ─────────────────────────────
class SettingsCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<Widget> children;
  final String? dataStatus;
  final Widget? trailing;

  const SettingsCard({
    super.key,
    required this.title,
    required this.accentColor,
    required this.children,
    this.dataStatus,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 800;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: isNarrow
              ? (defaultTargetPlatform == TargetPlatform.android ? 8 : 16)
              : 32,
          vertical: isNarrow ? 24 : 32),
      decoration: BoxDecoration(
        color: SettingsTheme.surfaceDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 40,
              spreadRadius: -10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: accentColor.withValues(alpha: 0.5),
                        blurRadius: 8)
                  ],
                )),
            const SizedBox(width: 16),
            Text(title,
                style: (isNarrow ? SettingsTheme.h3 : SettingsTheme.h2)
                    .copyWith(letterSpacing: 0.5)),
            if (dataStatus != null && _showDataStatus) ...[
              const SizedBox(width: 12),
              DataStatusTag(status: dataStatus!),
            ],
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ]),
          SizedBox(height: isNarrow ? 24 : 32),
          ...children,
        ],
      ),
    );
  }
}

// â”€â”€ SHARED UI: UNSAVED CHANGES WRAPPER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class UnsavedWrapper extends StatelessWidget {
  final Widget child;
  final bool isModified;
  const UnsavedWrapper(
      {super.key, required this.child, required this.isModified});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isModified)
          Positioned(
            left: 0,
            top: 4,
            bottom: 4,
            child: Container(
                width: 3,
                decoration: const BoxDecoration(
                    color: SettingsTheme.secondaryAmber,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)))),
          ),
      ],
    );
  }
}

// â”€â”€ SHARED UI: ADAPTIVE FIELD ROW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class SettingsFieldRow extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool isModified;
  final bool isMono;
  final bool isMultiline;
  final String? placeholder;
  final Widget? suffix;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final TextCapitalization textCapitalization;
  final String? counterText;
  final String? dataStatus; // 'Mock' or 'Real-time'

  const SettingsFieldRow({
    super.key,
    required this.label,
    this.controller,
    required this.isModified,
    this.isMono = false,
    this.isMultiline = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.placeholder,
    this.suffix,
    this.suffixIcon,
    this.dataStatus,
    this.maxLength,
    this.maxLengthEnforcement,
    this.textCapitalization = TextCapitalization.none,
    this.counterText,
  });

  @override
  State<SettingsFieldRow> createState() => _SettingsFieldRowState();
}

class _SettingsFieldRowState extends State<SettingsFieldRow> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final inputWidget = Container(
        decoration: BoxDecoration(
          border: widget.isModified
              ? const Border(
                  left:
                      BorderSide(color: SettingsTheme.secondaryAmber, width: 4))
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: widget.isMultiline ? 3 : 1,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          textCapitalization: widget.textCapitalization,
          style: (widget.isMono ? SettingsTheme.mono : SettingsTheme.body)
              .copyWith(fontSize: isNarrow ? 15 : 14),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle:
                SettingsTheme.subline.copyWith(fontSize: isNarrow ? 14 : 11),
            counterText: widget.counterText,
            filled: true,
            fillColor: SettingsTheme.backgroundDark.withValues(alpha: 0.3),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isModified
                      ? SettingsTheme.primaryGreen.withValues(alpha: 0.3)
                      : SettingsTheme.borderSubtle,
                  width: widget.isModified ? 1.5 : 1,
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: SettingsTheme.primaryGreen, width: 1.5)),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 20, vertical: isNarrow ? 20 : 16),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 20,
                      color: SettingsTheme.mutedGray,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : widget.suffixIcon,
            suffix: widget.suffix != null && !isNarrow ? widget.suffix : null,
          ),
        ),
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: SettingsTheme.h3
                          .copyWith(color: SettingsTheme.mutedGray)),
                  const SizedBox(height: 10),
                  inputWidget,
                  if (widget.suffix != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: widget.suffix),
                ],
              )
            : Row(
                crossAxisAlignment: widget.isMultiline
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.label,
                              style: SettingsTheme.h3
                                  .copyWith(color: SettingsTheme.mutedGray)),
                          if (widget.dataStatus != null && _showDataStatus) ...[
                            const SizedBox(height: 4),
                            DataStatusTag(status: widget.dataStatus!),
                          ],
                        ],
                      )),
                  Expanded(child: inputWidget),
                ],
              ),
      );
    });
  }
}

class FloatingSaveBar extends StatelessWidget {
  final int count;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final bool isSaving;
  final bool isSuccess;

  const FloatingSaveBar({
    super.key,
    required this.count,
    required this.onSave,
    required this.onDiscard,
    this.isSaving = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.2), BlendMode.dstATop),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 16 : 24, vertical: 16),
          decoration: BoxDecoration(
            color: isSuccess
                ? SettingsTheme.primaryGreen.withValues(alpha: 0.15)
                : SettingsTheme.surfaceDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSuccess
                    ? SettingsTheme.primaryGreen.withValues(alpha: 0.4)
                    : SettingsTheme.secondaryAmber.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Row(
            children: [
              Icon(
                  isSuccess
                      ? LucideIcons.checkCircle2
                      : LucideIcons.alertTriangle,
                  color: isSuccess
                      ? SettingsTheme.primaryGreen
                      : SettingsTheme.secondaryAmber,
                  size: isNarrow ? 18 : 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSuccess
                      ? 'Changes synchronized'
                      : (isNarrow
                          ? '$count changes'
                          : 'You have $count unsaved changes'),
                  style: SettingsTheme.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSuccess
                          ? SettingsTheme.primaryGreen
                          : Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isSuccess) ...[
                const SizedBox(width: 8),
                TextButton(
                    onPressed: onDiscard,
                    child: Text('Discard',
                        style: TextStyle(
                            color: SettingsTheme.mutedGray,
                            fontSize: isNarrow ? 12 : 13))),
                const SizedBox(width: 4),
              ],
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color:
                            SettingsTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: -2)
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsTheme.primaryGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          ),
                        )
                      : Text(
                          isSuccess
                              ? 'âœ“ Saved'
                              : (isNarrow
                                  ? 'Save $count'
                                  : 'Save $count ${count > 1 ? 'Changes' : 'Change'}'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ SHARED UI: LOGO UPLOAD ZONE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class LogoUploadZone extends StatelessWidget {
  final String? imageUrl;
  const LogoUploadZone({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SettingsTheme.surfaceDark,
                SettingsTheme.backgroundDark,
              ],
            ),
            border: Border.all(color: SettingsTheme.borderSubtle, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : Center(
                    child: Icon(LucideIcons.building2,
                        color: SettingsTheme.mutedGray.withValues(alpha: 0.5),
                        size: 32)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: SettingsTheme.primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(color: SettingsTheme.surfaceDark, width: 2),
              boxShadow: [
                BoxShadow(
                  color: SettingsTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child:
                const Icon(LucideIcons.camera, color: Colors.black, size: 14),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ SHARED UI: VERIFY BUTTON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class VerifyButton extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final VoidCallback onTap;
  const VerifyButton({super.key, this.controller, required this.onTap});

  @override
  ConsumerState<VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends ConsumerState<VerifyButton> {
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _error;

  void _handleVerify() async {
    if (_isVerified || _isVerifying) return;

    final gstin = widget.controller?.text ?? '';
    if (gstin.isEmpty) {
      _showTempError('ENTER GSTIN');
      return;
    }

    // Standard Indian GSTIN Regex
    final regex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!regex.hasMatch(gstin)) {
      _showTempError('INVALID FORMAT');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.post('/dealers/gstin/verify', data: {'gstin': gstin});

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _isVerified = true;
          });
          widget.onTap();
        }
      } else {
        throw Exception('VERIFICATION FAILED');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        _showTempError('VERIFICATION FAILED');
      }
    }
  }

  void _showTempError(String msg) {
    setState(() => _error = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _error = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerified) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCircle2,
                color: SettingsTheme.primaryGreen, size: 16),
            const SizedBox(width: 6),
            Text('VERIFIED',
                style: SettingsTheme.subline.copyWith(
                    color: SettingsTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1)),
          ],
        ),
      );
    }

    final hasError = _error != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: _handleVerify,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hasError
                ? SettingsTheme.errorRed.withValues(alpha: 0.1)
                : _isVerifying
                    ? SettingsTheme.mutedGray.withValues(alpha: 0.1)
                    : SettingsTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: hasError
                    ? SettingsTheme.errorRed.withValues(alpha: 0.3)
                    : _isVerifying
                        ? SettingsTheme.borderSubtle
                        : SettingsTheme.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isVerifying) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(SettingsTheme.primaryGreen)),
                ),
                const SizedBox(width: 8),
              ],
              if (hasError) ...[
                const Icon(LucideIcons.alertCircle,
                    color: SettingsTheme.errorRed, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                  hasError
                      ? _error!
                      : _isVerifying
                          ? 'VERIFYING...'
                          : 'VERIFY',
                  style: SettingsTheme.subline.copyWith(
                      color: hasError
                          ? SettingsTheme.errorRed
                          : _isVerifying
                              ? SettingsTheme.mutedGray
                              : SettingsTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ SHARED UI: SYNC SWITCH â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class SyncSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? dataStatus;

  const SyncSwitch(
      {super.key,
      required this.value,
      required this.onChanged,
      this.dataStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? SettingsTheme.primaryGreen.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: value
                ? SettingsTheme.primaryGreen.withValues(alpha: 0.2)
                : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sync Primary',
                  style: SettingsTheme.subline.copyWith(
                      color: value
                          ? SettingsTheme.primaryGreen
                          : SettingsTheme.mutedGray)),
              if (dataStatus != null && _showDataStatus) ...[
                const SizedBox(height: 2),
                DataStatusTag(status: dataStatus!, isSmall: true),
              ],
            ],
          ),
          const SizedBox(width: 4),
          Switch(
              value: value,
              activeThumbColor: SettingsTheme.primaryGreen,
              activeTrackColor:
                  SettingsTheme.primaryGreen.withValues(alpha: 0.3),
              onChanged: onChanged),
        ],
      ),
    );
  }
}

// â”€â”€ SHARED UI: DATA STATUS TAG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class DataStatusTag extends StatelessWidget {
  final String status;
  final bool isSmall;

  const DataStatusTag({super.key, required this.status, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    final isRealTime = status.toLowerCase().contains('real');
    final color =
        isRealTime ? SettingsTheme.primaryGreen : SettingsTheme.secondaryAmber;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8, vertical: isSmall ? 1 : 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 4 : 5,
            height: isSmall ? 4 : 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(status.toUpperCase(),
              style: SettingsTheme.subline.copyWith(
                  color: color,
                  fontSize: isSmall ? 8 : 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// â”€â”€ SHARED UI: ADDRESS MAP TILE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AddressMapTile extends StatelessWidget {
  final VoidCallback onLocate;
  const AddressMapTile({super.key, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
              color: SettingsTheme.backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SettingsTheme.borderSubtle)),
          child: Opacity(
              opacity: 0.2,
              child: const Icon(LucideIcons.map,
                  size: 80, color: SettingsTheme.primaryCyan)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onLocate,
          icon: const Icon(LucideIcons.crosshair, size: 16),
          label: const Text('Locate on Map'),
          style: ElevatedButton.styleFrom(
              backgroundColor: SettingsTheme.backgroundDark,
              foregroundColor: SettingsTheme.textHigh,
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: SettingsTheme.borderSubtle)),
        ),
      ],
    );
  }
}

// â”€â”€ SHARED UI: ERROR PANEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class ErrorPanel extends StatelessWidget {
  final String message;
  const ErrorPanel({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: SettingsTheme.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: SettingsTheme.errorRed.withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(LucideIcons.alertCircle,
            color: SettingsTheme.errorRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style:
                    SettingsTheme.body.copyWith(color: SettingsTheme.errorRed)))
      ]),
    );
  }
}

// â”€â”€ MODALS (SIMULATED) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MapPickerModal extends StatelessWidget {
  final Function(String, String, String) onLocationSelected;
  const MapPickerModal({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SettingsTheme.surfaceDark,
      child: Container(
        width: 600,
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Simulated Map Picker', style: SettingsTheme.h2),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  onLocationSelected(
                      '123 Energy Park St', 'Bengaluru', '560001');
                  Navigator.pop(context);
                },
                child: const Text('Confirm Location')),
          ],
        ),
      ),
    );
  }
}

class ChangeEmailModal extends StatelessWidget {
  const ChangeEmailModal({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: SettingsTheme.surfaceDark,
        title: Text('Change Email', style: SettingsTheme.h2),
        content: Text('A verification link will be sent to your new email.',
            style: SettingsTheme.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Send Link'))
        ]);
  }
}

class HolidayCalendarModal extends ConsumerWidget {
  const HolidayCalendarModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(holidayCalendarProvider);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      backgroundColor: SettingsTheme.surfaceDark,
      title: Row(
        children: [
          const Icon(LucideIcons.calendar,
              color: SettingsTheme.primaryCyan, size: 20),
          const SizedBox(width: 12),
          Text('Holiday Calendar', style: SettingsTheme.h2),
          const Spacer(),
          IconButton(
            icon: const Icon(LucideIcons.plus,
                color: SettingsTheme.primaryGreen, size: 20),
            tooltip: 'Add Holiday',
            onPressed: () =>
                _showAddHolidayDialog(context, ref, state.holidays),
          ),
          if (_showDataStatus) const DataStatusTag(status: 'Real-time Data'),
        ],
      ),
      content: SizedBox(
        width: isNarrow ? double.maxFinite : 500,
        height: 400,
        child: state.isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: SettingsTheme.primaryCyan))
            : state.error != null
                ? Center(
                    child: Text(state.error!,
                        style: const TextStyle(color: SettingsTheme.errorRed)))
                : state.holidays.isEmpty
                    ? const Center(
                        child: Text('No upcoming holidays scheduled',
                            style: TextStyle(color: SettingsTheme.mutedGray)))
                    : ListView.separated(
                        itemCount: state.holidays.length,
                        separatorBuilder: (_, __) => Divider(
                            color: SettingsTheme.borderSubtle
                                .withValues(alpha: 0.5)),
                        itemBuilder: (context, index) {
                          final holiday = state.holidays[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(holiday.name,
                                style: SettingsTheme.body
                                    .copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(holiday.date,
                                    style: SettingsTheme.mono.copyWith(
                                        color: SettingsTheme.primaryCyan,
                                        fontSize: 12)),
                                if (holiday.description != null)
                                  Text(holiday.description!,
                                      style: SettingsTheme.subline),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (holiday.isNational)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: SettingsTheme.primaryGreen
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: SettingsTheme.primaryGreen
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: const Text('NATIONAL',
                                        style: TextStyle(
                                            color: SettingsTheme.primaryGreen,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2,
                                      color: SettingsTheme.errorRed, size: 18),
                                  tooltip: 'Remove',
                                  onPressed: () => _handleDelete(
                                      context, ref, state.holidays, index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: SettingsTheme.mutedGray))),
        ElevatedButton(
          onPressed: () => ref.read(holidayCalendarProvider.notifier).refresh(),
          style: ElevatedButton.styleFrom(
              backgroundColor: SettingsTheme.primaryCyan,
              foregroundColor: Colors.black),
          child: const Text('Refresh'),
        ),
      ],
    );
  }

  void _showAddHolidayDialog(
      BuildContext context, WidgetRef ref, List<HolidayCalendarDto> existing) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;
    bool isNational = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SettingsTheme.surfaceDark,
          title: Text('Add Scheduled Holiday', style: SettingsTheme.h2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: SettingsTheme.body,
                  decoration: InputDecoration(
                    labelText: 'Holiday Name',
                    labelStyle: const TextStyle(color: SettingsTheme.mutedGray),
                    hintText: 'e.g. Independence Day',
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: SettingsTheme.borderSubtle)),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: SettingsTheme.body,
                  ),
                  trailing: const Icon(LucideIcons.calendar,
                      color: SettingsTheme.primaryCyan),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: SettingsTheme.primaryCyan,
                            onPrimary: Colors.black,
                            surface: SettingsTheme.surfaceDark,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: SettingsTheme.body,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: const TextStyle(color: SettingsTheme.mutedGray),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: SettingsTheme.borderSubtle)),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('National Holiday',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: isNational,
                  activeThumbColor: SettingsTheme.primaryGreen,
                  onChanged: (v) => setDialogState(() => isNational = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: SettingsTheme.mutedGray)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedDate == null) return;

                final newHoliday = HolidayCalendarDto(
                  name: nameController.text,
                  date: selectedDate!.toIso8601String().split('T')[0],
                  description:
                      descController.text.isEmpty ? null : descController.text,
                  isNational: isNational,
                );

                final newList = [...existing, newHoliday];
                final data = newList.map((h) => h.toJson()).toList();

                final success = await ref
                    .read(holidayCalendarProvider.notifier)
                    .update(data);
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.primaryGreen,
                  foregroundColor: Colors.black),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref,
      List<HolidayCalendarDto> existing, int index) async {
    final newList = List<HolidayCalendarDto>.from(existing)..removeAt(index);
    final data = newList.map((h) => h.toJson()).toList();
    await ref.read(holidayCalendarProvider.notifier).update(data);
  }
}

class PlaceholderSection extends StatelessWidget {
  final String title;
  const PlaceholderSection({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Section: $title is currently unavailable.',
                style: SettingsTheme.body),
            if (_showDataStatus) ...[
              const SizedBox(height: 16),
              const DataStatusTag(status: 'Pending Configuration'),
            ],
          ],
        ),
      );
}

// â”€â”€ SHARED UI: PASSWORD STRENGTH INDICATOR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;

    Color color;
    String label;
    if (strength <= 0.25) {
      color = SettingsTheme.errorRed;
      label = 'WEAK';
    } else if (strength <= 0.5) {
      color = SettingsTheme.secondaryAmber;
      label = 'FAIR';
    } else if (strength <= 0.75) {
      color = SettingsTheme.primaryCyan;
      label = 'GOOD';
    } else {
      color = SettingsTheme.primaryGreen;
      label = 'STRONG';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: strength,
                    backgroundColor: SettingsTheme.backgroundDark,
                    color: color,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: SettingsTheme.subline.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Use 8+ characters with mixed case, numbers & symbols',
            style: SettingsTheme.subline.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ SHARED UI: SETTINGS DROPDOWN â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class SettingsDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isModified;
  final String? dataStatus;

  const SettingsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isModified,
    this.dataStatus,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final dropdownWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: SettingsTheme.backgroundDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isModified
                  ? SettingsTheme.primaryGreen.withValues(alpha: 0.3)
                  : SettingsTheme.borderSubtle,
              width: isModified ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: SettingsTheme.body),
                      ))
                  .toList(),
              onChanged: onChanged,
              dropdownColor: SettingsTheme.surfaceDark,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: SettingsTheme.mutedGray),
              isExpanded: true,
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: SettingsTheme.h3
                            .copyWith(color: SettingsTheme.mutedGray)),
                    const SizedBox(height: 10),
                    dropdownWidget,
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label,
                              style: SettingsTheme.h3
                                  .copyWith(color: SettingsTheme.mutedGray)),
                          if (dataStatus != null) ...[
                            const SizedBox(height: 4),
                            DataStatusTag(status: dataStatus!),
                          ],
                        ],
                      ),
                    ),
                    Expanded(child: dropdownWidget),
                  ],
                ),
        );
      },
    );
  }
}

// -- SHARED UI: INFO NOTE ---------------------------------------
class InfoNote extends StatelessWidget {
  final String message;
  final IconData icon;
  const InfoNote({super.key, required this.message, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: SettingsTheme.primaryCyan.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: SettingsTheme.primaryCyan.withValues(alpha: 0.15))),
      child: Row(
        children: [
          Icon(icon, color: SettingsTheme.primaryCyan, size: 18),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: SettingsTheme.subline.copyWith(
                      color: SettingsTheme.textHigh.withValues(alpha: 0.7)))),
        ],
      ),
    );
  }
}
