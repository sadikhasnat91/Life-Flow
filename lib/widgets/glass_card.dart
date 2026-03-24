import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 0.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
