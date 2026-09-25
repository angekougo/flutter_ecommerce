import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../core/shared_widgets/empty_view.dart';
import '../../../core/shared_widgets/error_view.dart';
import '../../../core/shared_widgets/skeleton.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/views/widgets/cart_badge_icon.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/filter_provider.dart';
import 'product_detail_screen.dart';
import 'widgets/category_selector.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList.list(
                children: [
                  const _Header(),
                  const SizedBox(height: AppSpacing.xl),
                  const _Greeting(),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Trouvez ce qui vous plaît.', style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    onChanged: ref.read(filterProvider.notifier).setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Catégories', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  const CategorySelector(),
                  const SizedBox(height: AppSpacing.xxl),
                  const _SectionTitle(),
                ],
              ),
            ),

            // Les trois états de l'AsyncValue. skipLoadingOnRefresh: false pour
            // réafficher le skeleton quand on clique sur Réessayer.
            ...productsAsync.when(
              skipLoadingOnRefresh: false,
              loading: () => const [
                SliverToBoxAdapter(child: ProductGridSkeleton()),
              ],
              error: (error, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(onRetry: () => ref.invalidate(productsProvider)),
                ),
              ],
              data: (products) {
                if (products.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        icon: Icons.search_off_rounded,
                        title: 'Aucun produit trouvé',
                        message: 'Essayez une autre recherche\nou modifiez les filtres.',
                        actionLabel: 'Effacer les filtres',
                        onAction: ref.read(filterProvider.notifier).reset,
                      ),
                    ),
                  ];
                }
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl,
                    ),
                    sliver: SliverGrid.builder(
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
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(productId: product.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 28),
        const SizedBox(width: AppSpacing.sm),
        Text('Shoply', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).goTo(AppTab.cart),
          icon: const CartBadgeIcon(),
        ),
      ],
    );
  }
}

/// "Bonjour, Ange 👋" : le prénom vient du profil. Pendant le chargement
/// (ou en cas d'erreur) on affiche simplement "Bonjour".
class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(userProfileProvider.select((p) => p.value?.firstName));

    return Text(
      firstName == null ? 'Bonjour 👋' : 'Bonjour, $firstName 👋',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

/// "Produits populaires" + bouton Filtrer (avec le nombre de filtres actifs).
class _SectionTitle extends ConsumerWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(filterProvider.select((f) => f.activeCount));

    return Row(
      children: [
        Text('Produits populaires', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        TextButton.icon(
          onPressed: () => showFilterSheet(context),
          iconAlignment: IconAlignment.end,
          icon: Badge(
            isLabelVisible: activeFilters > 0,
            label: Text('$activeFilters'),
            child: const Icon(Icons.tune_rounded, size: 20),
          ),
          label: const Text('Filtrer'),
        ),
      ],
    );
  }
}
