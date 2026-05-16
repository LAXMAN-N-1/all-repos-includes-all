import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  GoogleMapController? _mapController;

  // Current pin position (starts at user location, moves as map drags)
  LatLng? _pinLatLng;

  // Form fields
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedLabel = 'Home';
  bool _isSaving = false;
  bool _isGeocodingLoading = false;
  bool _isLocating = true;

  static const _defaultCenter = LatLng(20.5937, 78.9629); // India center

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  @override
  void dispose() {
    // Clear any active snackbars to prevent them from persisting after pop
    ScaffoldMessenger.of(context).clearSnackBars();
    _addressController.dispose();
    _notesController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  /// Get the user's current location as the starting map position
  Future<void> _initUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _pinLatLng = _defaultCenter;
          _isLocating = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _pinLatLng = _defaultCenter;
          _isLocating = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _pinLatLng = latLng;
        _isLocating = false;
      });

      // Move camera
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15.5),
      ));

      // Reverse geocode the starting position
      _reverseGeocode(latLng);
    } catch (_) {
      setState(() {
        _pinLatLng = _defaultCenter;
        _isLocating = false;
      });
    }
  }

  /// Reverse-geocode the given latLng and auto-fill the address field
  Future<void> _reverseGeocode(LatLng latLng) async {
    if (kIsWeb) return; // geocoding package is mobile-only
    setState(() => _isGeocodingLoading = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (mounted) {
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
          _addressController.text = parts;
        } else {
          // Fallback if no placemarks found
          _addressController.text =
              'Location at ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        }
      }
    } catch (e) {
      // Fallback on error (e.g. no internet or service down)
      if (mounted) {
        _addressController.text =
            'Selected Location (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})';
      }
    } finally {
      if (mounted) setState(() => _isGeocodingLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ──────────────────────────────────────────────────────────────────
          // Main scrollable content column
          Column(
            children: [
              // ── Map Section (fixed height at top) ─────────────────────────
              SizedBox(
                height: screenHeight * 0.45,
                child: _buildMapSection(isDark),
              ),

              // ── Form fields below the map ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address label (auto-reverse geocoded)
                      _sectionLabel('Address', isDark),
                      const SizedBox(height: 10),
                      _buildAddressField(isDark),
                      const SizedBox(height: 22),

                      // Label chips
                      _sectionLabel('Label', isDark),
                      const SizedBox(height: 10),
                      _buildLabelChips(isDark),
                      const SizedBox(height: 22),

                      // Notes
                      _sectionLabel('Additional Notes (optional)', isDark),
                      const SizedBox(height: 10),
                      _buildNotesField(isDark),
                      const SizedBox(height: 28),

                      // Save button
                      _buildSaveButton(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── AppBar overlay on top of map ──────────────────────────────────
          _buildTransparentAppBar(context),
        ],
      ),
    );
  }

  // ─── Transparent AppBar ────────────────────────────────────────────────────

  Widget _buildTransparentAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 20, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  'Add New Address',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Map Section ────────────────────────────────────────────────────────────

  Widget _buildMapSection(bool isDark) {
    if (kIsWeb) {
      return _buildWebMapPlaceholder();
    }

    if (_isLocating) {
      return Container(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryBlue),
              SizedBox(height: 16),
              Text('Getting your location…'),
            ],
          ),
        ),
      );
    }

    final startPosition = _pinLatLng ?? _defaultCenter;

    return Stack(
      children: [
        // Google Map — user drags to pan, pin stays fixed in center
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            if (isDark) {
              controller.setMapStyle(AppTheme.mapStyleDark);
            }
          },
          initialCameraPosition:
              CameraPosition(target: startPosition, zoom: 15.5),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: !kIsWeb,
          onCameraMove: (position) {
            // Update pin LatLng as map moves — the pin icon is fixed center
            setState(() => _pinLatLng = position.target);
          },
          onCameraIdle: () {
            // Reverse geocode when the user stops panning
            if (_pinLatLng != null) {
              _reverseGeocode(_pinLatLng!);
            }
          },
        ),

        // Fixed center pin (always stays in middle of map)
        const Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shadow circle under pin
                  _MapPin(),
                  // Drop shadow oval
                  SizedBox(height: 0),
                  _PinShadow(),
                ],
              ),
            ),
          ),
        ),

        // My-location button
        Positioned(
          right: 16,
          bottom: 80,
          child: GestureDetector(
            onTap: _goToCurrentLocation,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowMedium,
              ),
              child: const Icon(LucideIcons.navigation,
                  color: AppTheme.primaryBlue, size: 20),
            ),
          ),
        ),

        // Geocoding loading indicator
        if (_isGeocodingLoading)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Finding address…',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),

        // Coordinates badge
        if (_pinLatLng != null)
          Positioned(
            bottom: _isGeocodingLoading ? 40 : 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_pinLatLng!.latitude.toStringAsFixed(5)}, ${_pinLatLng!.longitude.toStringAsFixed(5)}',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWebMapPlaceholder() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.mapPin,
                color: AppTheme.primaryBlue, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Map not available on web.\nEnter your address below.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── Address Field ─────────────────────────────────────────────────────────

  Widget _buildAddressField(bool isDark) {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      style: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
          height: 1.5),
      decoration: InputDecoration(
        hintText: 'Address will be auto-filled when you move the map pin…',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 14, left: 12, right: 8),
          child:
              Icon(LucideIcons.mapPin, size: 18, color: AppTheme.primaryBlue),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        suffixIcon: _isGeocodingLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryBlue)),
              )
            : null,
        hintStyle: GoogleFonts.outfit(
            color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ─── Label Chips ───────────────────────────────────────────────────────────

  Widget _buildLabelChips(bool isDark) {
    final labels = [
      ('Home', LucideIcons.home),
      ('Work', LucideIcons.briefcase),
      ('Other', LucideIcons.mapPin),
    ];

    return Row(
      children: labels.map((item) {
        final isSelected = _selectedLabel == item.$1;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedLabel = item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.$2,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white54 : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.$1,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Notes Field ───────────────────────────────────────────────────────────

  Widget _buildNotesField(bool isDark) {
    return TextField(
      controller: _notesController,
      maxLines: 2,
      style: GoogleFonts.outfit(
          fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: 'e.g. Ring the bell twice, 2nd floor…',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(top: 14, left: 12, right: 8),
          child: Icon(LucideIcons.fileText, size: 18, color: Colors.grey),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        hintStyle: GoogleFonts.outfit(
            color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ─── Save Button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isSaving) ? null : _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Save Address',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label, bool isDark) => Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white60 : Colors.black45,
          letterSpacing: 0.5,
        ),
      );

  Future<void> _goToCurrentLocation() async {
    await _initUserLocation();
  }

  Future<void> _saveAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please move the map to select a location',
              style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final notes = _notesController.text.trim();
      final fullAddress = notes.isNotEmpty ? '$address ($notes)' : address;

      await ref.read(profileProvider.notifier).addAddress({
        'title': _selectedLabel,
        'full_address': fullAddress.isNotEmpty ? fullAddress : 'Address',
        if (_pinLatLng != null) 'lat': _pinLatLng!.latitude,
        if (_pinLatLng != null) 'lng': _pinLatLng!.longitude,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address saved!', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e', style: GoogleFonts.outfit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Map Pin Widget ─────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue,
            ),
            child:
                const Icon(LucideIcons.mapPin, color: Colors.white, size: 22),
          ),
        ),
        // Pointer tip
        CustomPaint(
          size: const Size(16, 10),
          painter: _PinTipPainter(),
        ),
      ],
    );
  }
}

class _PinShadow extends StatelessWidget {
  const _PinShadow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 4,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primaryBlue;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTipPainter oldDelegate) => false;
}
