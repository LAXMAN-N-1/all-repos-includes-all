import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_colors.dart';
import '../../models/order_model.dart';
import 'delivery_verification_screen.dart';
import '../../repositories/order_repository.dart';
import 'active_delivery_view_model.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  final Order order;

  const ActiveDeliveryScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveDeliveryViewModel(
        orderRepository: context.read<OrderRepository>(),
      )..init(order),
      child: Consumer<ActiveDeliveryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(12.9716, 77.5946), // Bangalore Default
                    zoom: 14.0,
                  ),
                  onMapCreated: viewModel.onMapCreated,
                  markers: viewModel.markers,
                  polylines: viewModel.polylines,
                  myLocationEnabled: false, // Using custom marker for driver
                  zoomControlsEnabled: false,
                ),

                // Back Button (if needed, though it's in MainScreen usually)
                /*
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                */

                // Recenter Button
                Positioned(
                  right: 16,
                  bottom: 320, // Push up above the card
                  child: FloatingActionButton(
                    heroTag: 'recenter',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: viewModel.recenterMap,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // Order Details Card (Bottom Sheet style)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusBadge(viewModel.deliveryStage),
                            const Text(
                              '10 mins',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Steps (Pickup -> Dropoff)
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildLocationRow(
                                  Icons.store,
                                  order.pickupName,
                                  order.pickupAddress,
                                  isCompleted: viewModel.deliveryStage >= 2,
                                  isActive: viewModel.deliveryStage < 2,
                                ),
                                _buildDashedLine(),
                                _buildLocationRow(
                                  Icons.location_on,
                                  order.dropoffName,
                                  order.dropoffAddress,
                                  isCompleted: viewModel.deliveryStage >= 5,
                                  isActive:
                                      viewModel.deliveryStage >= 2 &&
                                      viewModel.deliveryStage < 5,
                                  isDest: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => viewModel.advanceStage(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeliveryVerificationScreen(
                                    orderId: order.id,
                                  ),
                                ),
                              );
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getStatusColor(
                                viewModel.deliveryStage,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _getButtonText(viewModel.deliveryStage),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(int stage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(stage).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(stage),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(stage),
            style: TextStyle(
              color: _getStatusColor(stage),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int stage) {
    if (stage >= 4) return Colors.green;
    if (stage >= 2) return AppColors.primary;
    return const Color(0xFF233D4C);
  }

  String _getStatusText(int stage) {
    switch (stage) {
      case 0:
        return 'Heading to Pickup';
      case 1:
        return 'Reached Pickup';
      case 2:
        return 'Order Picked Up';
      case 3:
        return 'Heading to Drop';
      case 4:
        return 'Reached Drop Location';
      default:
        return 'Delivery Completed';
    }
  }

  String _getButtonText(int stage) {
    switch (stage) {
      case 0:
        return 'Reached Pickup Location';
      case 1:
        return 'Confirm Pickup';
      case 2:
        return 'Start Delivery';
      case 3:
        return 'Reached Drop Location';
      case 4:
        return 'Verify Delivery';
      default:
        return 'Completed';
    }
  }

  Widget _buildLocationRow(
    IconData icon,
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isActive = false,
    bool isDest = false,
  }) {
    Color iconColor = isCompleted
        ? Colors.green
        : (isActive ? AppColors.primary : Colors.grey);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isActive || isCompleted
                      ? const Color(0xFF233D4C)
                      : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Container(
      margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      height: 30,
      width: 2,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          height: 4,
          width: 2,
          margin: const EdgeInsets.symmetric(vertical: 1),
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
