import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../core/shared_widgets/empty_view.dart';
import '../../../core/shared_widgets/error_view.dart';
import '../../../core/shared_widgets/skeleton.dart';
import '../../../core/theme/app_colors.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../../catalog/views/product_detail_screen.dart';
import '../../catalog/views/widgets/product_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);
    final count = favoritesAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mes favoris'),
            if (count > 0)
              Text(
                count > 1 ? '$count produits' : '1 produit',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: favoritesAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: ProductGridSkeleton(itemCount: 4),
        ),
        error: (error, _) => ErrorView(
          message: 'Impossible de charger vos favoris.',
          onRetry: () {
            ref.invalidate(productsProvider);
            ref.invalidate(favoritesProvider);
          },
        ),
        data: (products) {
          if (products.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'Aucun favori',
              message: 'Ajoutez des produits à vos favoris\npour les retrouver facilement.',
              actionLabel: 'Découvrir',
              onAction: () => ref.read(navigationProvider.notifier).goTo(AppTab.home),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.68,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                key: ValueKey(product.id),
                product: product,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
