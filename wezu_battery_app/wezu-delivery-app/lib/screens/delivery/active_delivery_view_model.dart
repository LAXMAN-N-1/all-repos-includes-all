import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/order_model.dart';

import '../../repositories/order_repository.dart';

class ActiveDeliveryViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;

  ActiveDeliveryViewModel({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  // ... (existing fields)
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _deliveryStage = 0;
  LatLng _driverLocation = const LatLng(12.9716, 77.5946); // Default: Bangalore
  Timer? _simulationTimer;
  late Order _currentOrder;

  // ... (getters)
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  int get deliveryStage => _deliveryStage;
  LatLng get driverLocation => _driverLocation;

  // ... (constants)
  static const LatLng _pickupLocation = LatLng(12.9352, 77.6245); // Koramangala
  static const LatLng _dropoffLocation = LatLng(
    12.9279,
    77.6271,
  ); // Sony World Signal

  void init(Order order) {
    _currentOrder = order;
    if (order.status == OrderStatus.pickingUp) _deliveryStage = 1;
    if (order.status == OrderStatus.delivering) _deliveryStage = 3;
    _setInitialMarkers();
    _setPolyline();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateCamera();
  }

  void _setInitialMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: _dropoffLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff Location'),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'You (Driver)'),
        rotation: 0,
      ),
    };
    notifyListeners();
  }

  void _setPolyline() {
    // Mock Polyline for demo
    List<LatLng> polylineCoordinates = [
      _driverLocation,
      const LatLng(12.9600, 77.6100),
      _pickupLocation,
      _dropoffLocation,
    ];

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ),
    };
    notifyListeners();
  }

  void _updateCamera() {
    if (_mapController == null) return;

    LatLng target;
    if (_deliveryStage < 2) {
      target = _pickupLocation;
    } else {
      target = _dropoffLocation;
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngZoom(target, 14.0));
  }

  Future<void> advanceStage(VoidCallback onComplete) async {
    if (_deliveryStage < 5) {
      _deliveryStage++;
      notifyListeners();

      if (_deliveryStage == 2) {
        // Picked up
        await _orderRepository.updateOrderStatus(
          _currentOrder.id,
          OrderStatus.delivering,
        );
        // Start heading to drop
        _startSimulation(_pickupLocation, _dropoffLocation);
      } else if (_deliveryStage == 5) {
        onComplete();
      }
      _updateCamera();
    }
  }

  void _startSimulation(LatLng start, LatLng end) {
    _simulationTimer?.cancel();
    double lat = start.latitude;
    double lng = start.longitude;
    double latDiff = (end.latitude - start.latitude) / 100;
    double lngDiff = (end.longitude - start.longitude) / 100;

    int steps = 0;
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (steps >= 100) {
        timer.cancel();
        return;
      }
      lat += latDiff;
      lng += lngDiff;
      _driverLocation = LatLng(lat, lng);

      // Update Driver Marker
      _markers.removeWhere((m) => m.markerId.value == 'driver');
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
      notifyListeners();
      steps++;
    });
  }

  void recenterMap() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_driverLocation, 15.0),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }
}
