import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared_widgets/quantity_selector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../catalog/views/widgets/product_image.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final product = item.product;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: SizedBox.square(
                dimension: 76,
                child: ProductImage(url: product.imageUrl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrice(product.price),
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  QuantitySelector(
                    compact: true,
                    quantity: item.quantity,
                    onDecrement: item.quantity > 1 ? () => cart.decrement(product.id) : null,
                    onIncrement: item.quantity < maxQuantityPerItem
                        ? () => cart.increment(product.id)
                        : null,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: 'Retirer',
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
