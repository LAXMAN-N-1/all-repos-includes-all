import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rental/models/rental.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  final Rental rental;

  const LiveTrackingScreen({super.key, required this.rental});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Mock initial position (Hyderabad)
  LatLng _batteryPosition = const LatLng(17.440081, 78.348915);
  final LatLng _stationPosition = const LatLng(17.440081, 78.348915); // Pickup station
  
  Timer? _locationTimer;
  bool _isOutOfBounds = false;
  final double _geoFenceRadius = 5000; // 5km
  
  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLiveTracking() {
    // Simulate live movement every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      
      setState(() {
        // Move battery significantly to demonstrate updates
        // Adding ~50 meters random drift
        double newLat = _batteryPosition.latitude + (0.0005 * (timer.tick % 2 == 0 ? 1 : -1));
        double newLng = _batteryPosition.longitude + (0.0005 * (timer.tick % 3 == 0 ? 1 : -1));
        
        _batteryPosition = LatLng(newLat, newLng);
        
        // Simple distance check (approximate)
        // 1 deg lat ~= 111km, 0.045 deg ~= 5km
        double distLat = (_batteryPosition.latitude - _stationPosition.latitude).abs();
        double distLng = (_batteryPosition.longitude - _stationPosition.longitude).abs();
        
        // Artificial alert for demo if it drifts too far (unlikely with this math but safety net)
        _isOutOfBounds = distLat > 0.045 || distLng > 0.045; 
      });
      
      _updateCamera();
    });
  }

  Future<void> _updateCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_batteryPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                widget.rental.battery.modelNumber,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.green, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "Live Tracking • Updated Just Now",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _batteryPosition,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('battery'),
                position: _batteryPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: InfoWindow(title: widget.rental.battery.serialNumber),
              ),
              Marker(
                markerId: const MarkerId('station'),
                position: _stationPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: const InfoWindow(title: "Pickup Station"),
              ),
            },
            circles: {
              Circle(
                circleId: const CircleId('geofence'),
                center: _stationPosition,
                radius: _geoFenceRadius,
                fillColor: Colors.blue.withValues(alpha: 0.1),
                strokeColor: Colors.blue.withValues(alpha: 0.3),
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          
          if (_isOutOfBounds)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.withValues(alpha: 0.9),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Warning: Battery is outside the designated 5km zone.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          _buildBottomPanel(context),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Positioned(
      bottom: 30, // Higher for floating look
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Distance from Station",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "2.4 km", // Mock value
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.battery_charging_full, size: 16, color: AppColors.accentGold),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.rental.battery.currentCharge.toInt()}%",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to Location History
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("History", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       final controller = _controller.future;
                       controller.then((c) => c.animateCamera(CameraUpdate.newLatLng(_batteryPosition)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Re-center", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}