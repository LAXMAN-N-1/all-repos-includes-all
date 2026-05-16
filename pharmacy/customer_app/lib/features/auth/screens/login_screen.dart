import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:customer_app/core/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  String? _currentAddress;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = "${place.subLocality}, ${place.locality}";
          });
        }
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _handleSendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid number")));
      return;
    }
    
    try {
      await Provider.of<AuthService>(context, listen: false).sendOTP(phone);
      setState(() => _isOtpSent = true);
      // Demo: Auto-fill logic can be added here if needed, but keeping it manual per request
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Sent: 9640 (Demo)")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleVerifyOTP() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();
    
    try {
      await Provider.of<AuthService>(context, listen: false).verifyOTP(phone, otp);
      // Navigation handled by main 'home' wrapper or manual push
      // For now, let's assume Main Wrapper listens to auth state/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Image.asset('assets/images/logo.png', height: 120)
                    .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 40),
              
              Text(
                "Welcome to AuraMed",
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  _isGettingLocation 
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _currentAddress ?? "Detecting location...",
                          style: GoogleFonts.inter(color: Colors.grey[600]),
                        ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              if (!_isOtpSent) ...[
                // Phone Input
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    prefixText: "+91 ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleSendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authService.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Get OTP", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ] else ...[
                // OTP Input
                Text("Enter OTP sent to +91 ${_phoneController.text}", style: GoogleFonts.inter(color: Colors.grey[600])),
                const SizedBox(height: 20),
                Pinput(
                  controller: _otpController,
                  length: 4,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6200EE)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                 SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleVerifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authService.isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Verify & Login", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isOtpSent = false), 
                  child: const Text("Change Number")
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
