import 'package:flutter/material.dart';
import '../../../../widgets/widgets.dart';
import '../../../models/driver_model.dart';

class DriverStatusChip extends StatelessWidget {
  final DriverStatus status;

  const DriverStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: status.label,
      color: status.color,
      hasDot: true,
    );
  }
}
