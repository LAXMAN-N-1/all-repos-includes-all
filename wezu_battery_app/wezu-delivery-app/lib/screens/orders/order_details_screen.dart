import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Constants for Demo - mirroring ActiveDeliveryViewModel locations
  static const LatLng _pickupLocation = LatLng(12.9352, 77.6245); // Koramangala
  static const LatLng _dropoffLocation = LatLng(
    12.9279,
    77.6271,
  ); // Sony World Signal

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  void _setupMapData() {
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
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_pickupLocation, _dropoffLocation],
        color: AppColors.primary,
        width: 4,
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Fit bounds
    Future.delayed(const Duration(milliseconds: 200), () {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_pickupLocation, _dropoffLocation]),
          50.0, // padding
        ),
      );
    });
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${widget.order.id}')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Preview Section
              SizedBox(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _pickupLocation,
                    zoom: 13,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  polylines: _polylines,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildCustomerSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildOrderItemsSection(),
                    const SizedBox(height: 24),
                    _buildBillDetailsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFD802E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.order.status == OrderStatus.delivering
                      ? 'ON WAY'
                      : widget.order.status == OrderStatus.delivered
                      ? 'DELIVERED'
                      : widget.order.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFD802E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple timeline/progress
          Row(
            children: [
              _buildTimelineStep('Picked Up', true),
              _buildTimelineLine(true),
              _buildTimelineStep(
                'On Way',
                widget.order.status == OrderStatus.delivering ||
                    widget.order.status == OrderStatus.delivered,
              ),
              _buildTimelineLine(widget.order.status == OrderStatus.delivered),
              _buildTimelineStep(
                'Delivered',
                widget.order.status == OrderStatus.delivered,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isActive
              ? const Color(0xFFFD802E)
              : Colors.grey[300],
          child: isActive
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF233D4C) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFFD802E) : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _buildSectionContainer(
      title: 'Customer Details',
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF233D4C),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.dropoffName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233D4C),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+91 98765 43210', // Mock Phone
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              print('Calling customer...');
            },
            icon: const Icon(Icons.phone, color: Color(0xFFFD802E)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFD802E).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildSectionContainer(
      title: 'Location Details',
      child: Column(
        children: [
          _buildLocationItem(
            Icons.store,
            widget.order.pickupName,
            widget.order.pickupAddress,
            isPickup: true,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: SizedBox(
              height: 20,
              child: VerticalDivider(color: Colors.grey, thickness: 1),
            ),
          ),
          _buildLocationItem(
            Icons.location_on,
            widget.order.dropoffName,
            widget.order.dropoffAddress,
            isPickup: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    IconData icon,
    String title,
    String address, {
    required bool isPickup,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isPickup ? const Color(0xFF233D4C) : const Color(0xFFFD802E),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {
            print('Navigating to $title');
          },
          icon: const Icon(Icons.navigation, size: 16),
          label: const Text('Navigate'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFD802E)),
        ),
      ],
    );
  }

  Widget _buildOrderItemsSection() {
    return _buildSectionContainer(
      title: 'Order Items',
      child: Column(
        children: [
          _buildOrderItem('NMC 2kWH Battery', 1, 120.0),
          _buildOrderItem('Service Charge', 1, 40.0),
          const Divider(),
          _buildOrderItem('Item Total', null, 160.0, isBold: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String name,
    int? qty,
    double price, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (qty != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${qty}x',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (qty != null) const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: const Color(0xFF233D4C),
                ),
              ),
            ],
          ),
          Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: const Color(0xFF233D4C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetailsSection() {
    return _buildSectionContainer(
      title: 'Bill Details',
      child: Column(
        children: [
          _buildBillRow('Item Total', 160.0),
          _buildBillRow('Delivery Fee (Earnings)', 35.0),
          _buildBillRow('Tip', 10.0),
          const Divider(),
          _buildBillRow('Total Earnings', widget.order.amount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF233D4C) : Colors.grey[600],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? const Color(0xFFFD802E)
                  : const Color(0xFF233D4C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233D4C),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/help-support');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFFD802E)),
              ),
              child: const Text('Help'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // If order is active/in-progress, go to Active Delivery screen
                if (widget.order.status != OrderStatus.delivered &&
                    widget.order.status != OrderStatus.cancelled) {
                  Navigator.pushNamed(
                    context,
                    '/active-delivery',
                    arguments: widget.order,
                  );
                } else {
                  // If completed, maybe show receipt or just a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order is already completed.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD802E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                (widget.order.status != OrderStatus.delivered &&
                        widget.order.status != OrderStatus.cancelled)
                    ? 'Update Status'
                    : 'View Receipt',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
