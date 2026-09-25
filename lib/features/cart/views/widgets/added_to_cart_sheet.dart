import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/navigation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../catalog/models/product_model.dart';
import '../../../catalog/views/widgets/product_image.dart';

/// Confirmation "Produit ajouté au panier !" (bonus : animation d'ajout).
Future<void> showAddedToCartSheet(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
    ),
    builder: (_) => _AddedToCartSheet(product: product),
  );
}

class _AddedToCartSheet extends ConsumerWidget {
  const _AddedToCartSheet({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Le produit "tombe" dans le panier...
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: -60, end: 0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, offset, child) => Transform.translate(
                      offset: Offset(0, offset),
                      child: Opacity(opacity: ((offset + 60) / 60).clamp(0, 1), child: child),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: SizedBox.square(
                        dimension: 90,
                        child: ProductImage(url: product.imageUrl),
                      ),
                    ),
                  ),
                  // ...puis la coche apparaît avec un petit rebond.
                  Positioned(
                    right: -18,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: const Interval(0.45, 1, curve: Curves.elasticOut),
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Produit ajouté au panier !', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(product.name, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () {
                // On ferme le sheet et l'écran détail, puis on bascule sur l'onglet Panier.
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(navigationProvider.notifier).goTo(AppTab.cart);
              },
              child: const Text('Voir le panier'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuer mes achats'),
            ),
          ],
        ),
      ),
    );
  }
}
