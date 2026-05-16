import 'package:flutter/material.dart';
import '../../../config/app_spacing.dart';
import '../../../models/warehouse_model.dart';
import 'rack_widget.dart';

class WarehouseGrid extends StatelessWidget {
  final WarehouseModel warehouse;
  final Function(ShelfModel) onShelfTap;

  const WarehouseGrid({
    super.key,
    required this.warehouse,
    required this.onShelfTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.screenPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warehouse.racks.map((rack) {
          return RackWidget(
            rack: rack,
            onShelfTap: onShelfTap,
          );
        }).toList(),
      ),
    );
  }
}
