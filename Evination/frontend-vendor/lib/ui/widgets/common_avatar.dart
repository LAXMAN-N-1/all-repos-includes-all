import 'package:flutter/material.dart';

class CommonAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const CommonAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor = const Color(0xFFF3F4F6), // muted
    this.foregroundColor = const Color(0xFF4B5563), // muted-foreground
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl == null ? backgroundColor : null,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null && initials != null
          ? Text(
              initials!,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }
}
