import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Écran "Une erreur est survenue" avec bouton Réessayer.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.onRetry,
    this.message = 'Impossible de charger les produits.\nVérifiez votre connexion puis réessayez.',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text('Une erreur est survenue', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 180,
              child: FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            ),
          ],
        ),
      ),
    );
  }
}
