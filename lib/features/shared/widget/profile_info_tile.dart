// lib/features/shared/widget/profile_info_tile.dart

import 'package:flutter/material.dart';

class ProfileInfoTile extends StatefulWidget {
  final String label;
  final String value;
  final double minHeight;

  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.minHeight = 70,
  });

  @override
  State<ProfileInfoTile> createState() => _ProfileInfoTileState();
}

class _ProfileInfoTileState extends State<ProfileInfoTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.minHeight,
        decoration: BoxDecoration(
          color: scheme.surface, // Use surface for better contrast
          borderRadius: BorderRadius.circular(20),
          border: Border(
            top: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.5), width: 1),
            left: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.5), width: 1),
            right: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.5), width: 1),
            bottom: BorderSide(
              color: scheme.outlineVariant.withOpacity(0.5),
              width: _isPressed ? 1 : 4, // 3D effect press
            ),
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: scheme.primary.withOpacity(0.1),
            onTap: () {
              // Show full text in a tooltip or dialog if truncated
              if (widget.value.length > 20) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.value),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Centered label
                    Text(
                      widget.label.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // Centered value
                    Text(
                      widget.value,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
