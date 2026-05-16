import 'package:flutter/material.dart';

class VehicleTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelected;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> _vehicleTypes = const [
    {'type': 'Bike', 'icon': Icons.motorcycle},
    {
      'type': 'Scooter',
      'icon': Icons.moped,
    }, // Using moped as proxy for scooter
    {'type': 'Car', 'icon': Icons.directions_car},
    {'type': 'Van', 'icon': Icons.local_shipping},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _vehicleTypes.length,
      itemBuilder: (context, index) {
        final type = _vehicleTypes[index]['type'] as String;
        final icon = _vehicleTypes[index]['icon'] as IconData;
        final isSelected = selectedType == type;

        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFD802E) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFD802E)
                    : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : const Color(0xFF233D4C),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF233D4C),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
