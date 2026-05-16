import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../dashboard/widgets/main_layout.dart';
import '../providers/auth_provider.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String target;
  final bool isRegistration;

  const OTPScreen({
    super.key,
    required this.target,
    this.isRegistration = true,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill name if provided from registration screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['fullName'] != null) {
        _nameController.text = args['fullName'];
      }
    });
  }

  void _verify() {
    if (ref.read(authProvider).isLoading) return;
    if (_otpController.text.length < 6) return;
    
    ref.read(authProvider.notifier).verifyOtp(
      target: widget.target,
      code: _otpController.text,
      fullName: widget.isRegistration ? _nameController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && !next.isLoading) {
        debugPrint("AUTH ERROR DETECTED: ${next.error}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        Future.microtask(() => ref.read(authProvider.notifier).clearError());
      }
      
      if (!next.isLoading && next.isAuthenticated) {
        debugPrint('Authenticated: Navigating to MainLayout...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
        child: ResponsiveWrapper(
          maxWidth: Responsive.formMaxWidth(context),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter OTP',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'A 6-digit code has been sent to \n${widget.target}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.black, // Changed to black for light theme
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Changed to light grey
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!, // Changed to light border
                    ),
                  ),
                ),
                onCompleted: (pin) => _verify(),
              ),
            ),
            const SizedBox(height: 32),
            if (widget.isRegistration) ...[
              const Text(
                'Full Name',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Changed to light grey
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!, // Changed to light border
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black), // Changed to black
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Doe',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.person, color: AppTheme.primaryBlue),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            if (authState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _verify,
                child: const Text('Verify & Continue'),
              ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).requestOtp(widget.target);
                },
                child: const Text('Resend Code'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
