import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// [ - ]  2  [ + ]
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 28.0 : 36.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove_rounded, size: size, onPressed: onDecrement),
        SizedBox(
          width: compact ? 32 : 44,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        _StepButton(icon: Icons.add_rounded, size: size, onPressed: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.size, this.onPressed});

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: size * 0.5,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textMuted,
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        icon: Icon(icon),
      ),
    );
  }
}
