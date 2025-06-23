import 'package:flutter/material.dart';

/// Reusable circular icon button with loading state support
class CircularIconButton extends StatelessWidget {

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.isLoading = false,
    this.size = 56,
  });
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              )
            : Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
} 
