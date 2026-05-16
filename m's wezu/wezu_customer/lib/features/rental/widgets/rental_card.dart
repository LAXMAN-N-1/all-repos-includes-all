import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/time_utils.dart';
import '../models/rental.dart';
import '../../../core/theme/app_theme.dart';

class RentalCard extends StatelessWidget {
  final Rental rental;
  final VoidCallback? onTap;
  final VoidCallback? onDownloadInvoice;

  const RentalCard({
    super.key,
    required this.rental,
    this.onTap,
    this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color/label
    Color statusColor;
    String statusLabel;

    switch (rental.status.toLowerCase()) {
      case 'active':
        statusColor = AppTheme.accentGreen;
        statusLabel = 'ACTIVE';
        break;
      case 'completed':
        statusColor = AppTheme.textSecondary;
        statusLabel = 'COMPLETED';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusLabel = 'PENDING';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = rental.status.toUpperCase();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=400', // detailed placeholder
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[800]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.battery_alert),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rental.battery.modelNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TimeUtils.shortDateFromDt(rental.startTime),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${rental.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (rental.status.toLowerCase() == 'completed')
                  IconButton(
                    icon: const Icon(Icons.download,
                        color: AppTheme.primaryBlue, size: 20),
                    onPressed: onDownloadInvoice,
                  ),
              ],
            ),
            // Optional: Display station info if we had Station object
          ],
        ),
      ),
    );
  }
}
