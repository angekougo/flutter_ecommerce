import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../core/shared_widgets/error_view.dart';
import '../../../core/shared_widgets/quantity_selector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/views/widgets/added_to_cart_sheet.dart';
import '../../cart/views/widgets/cart_badge_icon.dart';
import '../../favorites/views/widgets/favorite_button.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';
import 'widgets/product_image.dart';
import 'widgets/rating_label.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ref.read(navigationProvider.notifier).goTo(AppTab.cart);
            },
            icon: const CartBadgeIcon(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: productAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: 'Impossible de charger ce produit.',
          onRetry: () => ref.invalidate(productByIdProvider(productId)),
        ),
        data: (product) => _ProductDetails(product: product),
      ),
      // Le bouton n'apparaît qu'une fois le produit chargé.
      bottomNavigationBar: productAsync.whenOrNull(
        data: (product) => _AddToCartBar(product: product),
      ),
    );
  }
}

class _AddToCartBar extends ConsumerWidget {
  const _AddToCartBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: FilledButton.icon(
          onPressed: () {
            final quantity = ref.read(selectedQuantityProvider(product.id));
            ref.read(cartProvider.notifier).add(product, quantity: quantity);
            showAddedToCartSheet(context, product);
          },
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: const Text('Ajouter au panier'),
        ),
      ),
    );
  }
}

class _ProductDetails extends ConsumerWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final quantity = ref.watch(selectedQuantityProvider(product.id));
    final quantityNotifier = ref.read(selectedQuantityProvider(product.id).notifier);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _ImageGallery(product: product),
        const SizedBox(height: AppSpacing.xl),
        Text(product.name, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        RatingLabel(
          rating: product.rating,
          reviewCount: product.reviewCount,
          showWordAvis: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          formatPrice(product.price),
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          product.description,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Quantité', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: QuantitySelector(
            quantity: quantity,
            onDecrement: quantity > 1 ? quantityNotifier.decrement : null,
            onIncrement: quantity < maxQuantityPerItem ? quantityNotifier.increment : null,
          ),
        ),
      ],
    );
  }
}

/// Carrousel d'images avec indicateur de page. Le Hero relie la première
/// image à celle de la carte produit.
class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.product});

  final Product product;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images.isEmpty ? [product.imageUrl] : product.images;

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: AspectRatio(
                aspectRatio: 1,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  itemBuilder: (_, index) {
                    final image = ProductImage(url: images[index], padding: 24);
                    return index == 0
                        ? Hero(tag: 'product-image-${product.id}', child: image)
                        : image;
                  },
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: FavoriteButton(productId: product.id, size: 40),
            ),
          ],
        ),
        if (images.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          // Écoute le controller directement : pas besoin de setState.
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final current = _controller.hasClients
                  ? (_controller.page ?? 0).round()
                  : 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == current ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == current ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
