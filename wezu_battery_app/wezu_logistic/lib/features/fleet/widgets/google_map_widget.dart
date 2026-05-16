import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/driver_model.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_constants.dart';
import '../../../core/utils/web_google_maps_support.dart';

/// A real Google Maps widget showing a driver's live location with
/// an accuracy circle and an optional destination marker + route polyline.
class GoogleMapWidget extends StatefulWidget {
  final DriverModel driver;
  final LatLng? destination;
  final List<LatLng> routePoints;
  final VoidCallback? onMarkerTap;

  const GoogleMapWidget({
    super.key,
    required this.driver,
    this.destination,
    this.routePoints = const [],
    this.onMarkerTap,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _buildOverlays();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driver != widget.driver ||
        oldWidget.destination != widget.destination ||
        oldWidget.routePoints != widget.routePoints) {
      _buildOverlays();
      _animateToDriver();
    }
  }

  void _buildOverlays() {
    final driverPos = LatLng(
      widget.driver.currentLat,
      widget.driver.currentLng,
    );

    _markers.clear();
    _circles.clear();
    _polylines.clear();

    // Driver marker
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: driverPos,
        infoWindow: InfoWindow(
          title: widget.driver.name,
          snippet:
              '${widget.driver.vehicleType} • ${widget.driver.vehiclePlate}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: widget.onMarkerTap,
      ),
    );

    // Accuracy circle
    if (widget.driver.locationAccuracy > 0) {
      _circles.add(
        Circle(
          circleId: const CircleId('accuracy'),
          center: driverPos,
          radius: widget.driver.locationAccuracy,
          fillColor: AppColors.info.withValues(alpha: 0.15),
          strokeColor: AppColors.info.withValues(alpha: 0.5),
          strokeWidth: 1,
        ),
      );
    }

    // Destination marker
    if (widget.destination != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );
    }

    // Route polyline
    if (widget.routePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.routePoints,
          color: AppColors.primary,
          width: 4,
          patterns: [],
        ),
      );
    }

    if (mounted) setState(() {});
  }

  void _animateToDriver() {
    _controller?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(widget.driver.currentLat, widget.driver.currentLng),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (!AppConstants.isWebGoogleMapsEnabled) {
        return _buildWebMapFallback(
          'Live map disabled on web.\n'
          'Enable with --dart-define=ENABLE_WEB_GOOGLE_MAPS=true '
          'after configuring Google Maps JS in web/index.html.',
        );
      }

      if (!isGoogleMapsJsAvailable()) {
        return _buildWebMapFallback(
          'Google Maps JS API not loaded.\n'
          'Add your Google Maps script key in web/index.html, then reload.',
        );
      }
    }

    final driverPos = LatLng(
      widget.driver.currentLat,
      widget.driver.currentLng,
    );

    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: driverPos, zoom: 14),
        markers: _markers,
        circles: _circles,
        polylines: _polylines,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }

  Widget _buildWebMapFallback(String message) {
    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
