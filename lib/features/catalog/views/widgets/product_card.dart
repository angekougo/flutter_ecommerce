import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';
import 'product_image.dart';
import 'rating_label.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: SizedBox.expand(child: ProductImage(url: product.imageUrl)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              RatingLabel(rating: product.rating, reviewCount: product.reviewCount),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatPrice(product.price),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
