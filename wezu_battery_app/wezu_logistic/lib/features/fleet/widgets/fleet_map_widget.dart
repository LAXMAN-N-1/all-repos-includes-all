import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';
import '../../../models/driver_model.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../core/utils/polyline_decoder.dart';
import '../../../core/utils/web_google_maps_support.dart';

class FleetMapWidget extends StatefulWidget {
  final List<DriverModel> drivers;
  final DeliveryRouteModel? activeRoute;

  const FleetMapWidget({
    super.key,
    required this.drivers,
    this.activeRoute,
    this.onDriverTap,
  });

  final Function(String)? onDriverTap;

  @override
  State<FleetMapWidget> createState() => _FleetMapWidgetState();
}

class _FleetMapWidgetState extends State<FleetMapWidget> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _buildMapObjects();
  }

  @override
  void didUpdateWidget(FleetMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drivers != widget.drivers ||
        oldWidget.activeRoute != widget.activeRoute) {
      _buildMapObjects();
    }
  }

  void _buildMapObjects() {
    _markers.clear();
    _polylines.clear();

    // 1. Driver Markers
    for (final driver in widget.drivers) {
      _markers.add(
        Marker(
          markerId: MarkerId(driver.id),
          position: LatLng(driver.currentLat, driver.currentLng),
          infoWindow: InfoWindow(
            title: driver.name,
            snippet: '${driver.status.label} • ${driver.vehicleType}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            (driver.status == DriverStatus.available ||
                    driver.status == DriverStatus.onRoute ||
                    driver.status == DriverStatus.busy)
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          onTap: () => widget.onDriverTap?.call(driver.id),
        ),
      );
    }

    // 2. Route Visualization
    if (widget.activeRoute != null) {
      final points = widget.activeRoute!.waypoints
          .map((wp) => LatLng(wp.location.lat, wp.location.lng))
          .toList();

      // Add Driver Start Position if available (assuming first driver is the one being optimized)
      if (widget.drivers.isNotEmpty) {
        points.insert(
          0,
          LatLng(
            widget.drivers.first.currentLat,
            widget.drivers.first.currentLng,
          ),
        );
      }

      // Polyline from Google Maps (Road Network)
      if (widget.activeRoute!.overviewPolyline.isNotEmpty) {
        final decodedPoints = decodePolyline(
          widget.activeRoute!.overviewPolyline,
        ).map((p) => LatLng(p['lat']!, p['lng']!)).toList();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('active_route'),
            points: decodedPoints,
            color: AppColors.primary,
            width: 5,
            jointType: JointType.round,
          ),
        );
      } else {
        // Fallback: Straight lines between waypoints
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('active_route_fallback'),
            points: points,
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 5,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );
      }

      // Waypoint Markers
      for (final wp in widget.activeRoute!.waypoints) {
        _markers.add(
          Marker(
            markerId: MarkerId('wp_${wp.sequenceIndex}'),
            position: LatLng(wp.location.lat, wp.location.lng),
            infoWindow: InfoWindow(
              title: 'Stop #${wp.sequenceIndex + 1}',
              snippet: wp.address ?? 'Delivery Point',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (!AppConstants.isWebGoogleMapsEnabled) {
        return _buildWebMapFallback(
          'Map preview disabled on web.\n'
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

    // Default to first driver or a central location if empty
    final initialPos = widget.drivers.isNotEmpty
        ? LatLng(
            widget.drivers.first.currentLat,
            widget.drivers.first.currentLng,
          )
        : const LatLng(12.9716, 77.5946); // Bangalore default

    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
        markers: _markers,
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
