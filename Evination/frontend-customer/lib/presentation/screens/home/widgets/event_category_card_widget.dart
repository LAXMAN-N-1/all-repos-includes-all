import 'package:flutter/material.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/constants/app_sizes.dart';
import 'package:evination_customer_app/data/models/event/event_category_model.dart';

class EventCategoryCardWidget extends StatelessWidget {
  final EventCategoryModel category;

  const EventCategoryCardWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to booking/details
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          image: category.imageUrl != null 
            ? DecorationImage(
                image: NetworkImage(category.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              )
            : null,
          color: category.imageUrl == null ? const Color(0xFF2A2A2A) : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(category.iconName),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.sunflowerYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSizeMD,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String? iconName) {
    IconData iconData;
    switch (iconName) {
      case 'sparkles': iconData = Icons.auto_awesome; break;
      case 'cake': iconData = Icons.cake; break;
      case 'heart': iconData = Icons.favorite; break;
      case 'briefcase': iconData = Icons.business_center; break;
      case 'rocket': iconData = Icons.rocket_launch; break;
      default: iconData = Icons.event;
    }
    return Icon(iconData, color: AppColors.crimsonSilk, size: 32);
  }
}
