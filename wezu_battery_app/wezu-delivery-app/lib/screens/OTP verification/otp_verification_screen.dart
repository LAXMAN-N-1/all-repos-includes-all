import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../repositories/auth_repository.dart';
import '../../widgets/auth/auth_backdrop.dart';
import 'otp_verification_view_model.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OtpVerificationViewModel(
        authRepository: context.read<AuthRepository>(),
      ),
      child: _OtpVerificationView(phoneNumber: phoneNumber),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  final String phoneNumber;

  const _OtpVerificationView({required this.phoneNumber});

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late final AnimationController _entryController;
  late final AnimationController _ambientController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 860),
      vsync: this,
    )..forward();
    _ambientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _entryController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _submitOtp(OtpVerificationViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    final code = _otpController.text.trim();
    final success = await viewModel.verifyOtp(code, widget.phoneNumber);

    if (success && mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthBackdrop(
          animation: _ambientController,
          child: SafeArea(
            child: Consumer<OtpVerificationViewModel>(
              builder: (context, viewModel, child) {
                final viewInsets = MediaQuery.viewInsetsOf(context);
                final pinTheme = _buildPinTheme(theme);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        14,
                        20,
                        24 + viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 38,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    _TopIconButton(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      onTap: () =>
                                          Navigator.of(context).maybePop(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'OTP Verification',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Text(
                                  'Almost there.',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter the 6-digit secure code sent to ${_maskedPhone(widget.phoneNumber)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        18,
                                        18,
                                        18,
                                        18,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.82,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.16,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 16),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF0D47A1),
                                                          Color(0xFF00897B),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: const Icon(
                                                  Icons.password_rounded,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'One-Time Password',
                                                      style: theme
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Code expires quickly for your security',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: const Color(
                                                              0xFF5B657C,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          Pinput(
                                            controller: _otpController,
                                            length: 6,
                                            keyboardType: TextInputType.number,
                                            defaultPinTheme: pinTheme,
                                            focusedPinTheme: pinTheme.copyWith(
                                              height: 58,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF0D47A1,
                                                  ),
                                                  width: 1.5,
                                                ),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF0D47A1,
                                                    ).withValues(alpha: 0.18),
                                                    blurRadius: 14,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            submittedPinTheme: pinTheme
                                                .copyWith(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    color: const Color(
                                                      0xFFEAF0FF,
                                                    ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFF9BB3FF,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            onChanged: (_) => setState(() {}),
                                            onCompleted: (_) {
                                              if (!viewModel.isLoading) {
                                                _submitOtp(viewModel);
                                              }
                                            },
                                          ),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child:
                                                viewModel.errorMessage == null
                                                ? const SizedBox(height: 14)
                                                : Container(
                                                    key: ValueKey(
                                                      viewModel.errorMessage,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 14,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFEBEE,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFFFC5CB,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.error_outline,
                                                          color: Color(
                                                            0xFFCB2D3E,
                                                          ),
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            viewModel
                                                                .errorMessage!,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: const Color(
                                                                    0xFFA52531,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 14),
                                          _OtpActionButton(
                                            isLoading: viewModel.isLoading,
                                            enabled:
                                                _otpController.text
                                                    .trim()
                                                    .length ==
                                                6,
                                            onPressed: () {
                                              if (!viewModel.isLoading) {
                                                _submitOtp(viewModel);
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.center,
                                            child: TextButton.icon(
                                              onPressed:
                                                  viewModel.canResend &&
                                                      !viewModel.isLoading
                                                  ? () {
                                                      _otpController.clear();
                                                      setState(() {});
                                                      viewModel.resendOtp(
                                                        widget.phoneNumber,
                                                      );
                                                    }
                                                  : null,
                                              icon: Icon(
                                                Icons.refresh_rounded,
                                                size: 18,
                                                color: viewModel.canResend
                                                    ? theme.colorScheme.primary
                                                    : const Color(0xFF8A92A8),
                                              ),
                                              label: Text(
                                                viewModel.canResend
                                                    ? 'Resend code'
                                                    : 'Resend in ${viewModel.timerSeconds}s',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: viewModel.canResend
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : const Color(
                                                              0xFF8A92A8,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  PinTheme _buildPinTheme(ThemeData theme) {
    return PinTheme(
      width: 50,
      height: 58,
      textStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: const Color(0xFF334557)),
      ),
    );
  }

  String _maskedPhone(String phoneNumber) {
    if (phoneNumber.length < 4) return phoneNumber;
    final lastFour = phoneNumber.substring(phoneNumber.length - 4);
    return '******$lastFour';
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

class _OtpActionButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const _OtpActionButton({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isActive ? 1 : 0.72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF0D47A1), Color(0xFF00897B)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D47A1).withValues(alpha: 0.34),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey('idle'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Verify & Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle_outline_rounded),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
