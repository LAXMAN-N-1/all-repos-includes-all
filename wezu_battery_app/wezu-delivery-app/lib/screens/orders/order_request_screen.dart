import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../widgets/order_request_dialog.dart';

class OrderRequestScreen extends StatefulWidget {
  final Function(Order) onAccept;
  final Function() onReject;

  const OrderRequestScreen({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<OrderRequestScreen> createState() => _OrderRequestScreenState();
}

class _OrderRequestScreenState extends State<OrderRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderRepository>(
      builder: (context, orderRepo, child) {
        final pendingOrders = orderRepo.orders
            .where((order) => order.status == OrderStatus.pending)
            .toList();

        if (pendingOrders.isEmpty) {
          return const Center(
            child: Text(
              'No pending requests',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final pendingOrder = pendingOrders.first;
        return Center(
          child: SingleChildScrollView(
            child: OrderRequestDialog(
              order: pendingOrder,
              onAccept: () async {
                await orderRepo.updateOrderStatus(
                  pendingOrder.id,
                  OrderStatus.accepted,
                );
                widget.onAccept(pendingOrder);
              },
              onReject: () async {
                await orderRepo.updateOrderStatus(
                  pendingOrder.id,
                  OrderStatus.cancelled,
                );
                widget.onReject();
              },
            ),
          ),
        );
      },
    );
  }
}
