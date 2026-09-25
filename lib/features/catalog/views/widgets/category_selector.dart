import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/filter_provider.dart';

/// Rangée de catégories en ronds. Un second tap sur la catégorie
/// sélectionnée la désélectionne.
class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  // Couleurs de fond des pastilles, comme sur la maquette.
  static const _tints = {
    ProductCategory.tech: Color(0xFF6E54FD),
    ProductCategory.mode: Color(0xFFCF3BA7),
    ProductCategory.maison: Color(0xFF14B8A6),
    ProductCategory.beaute: Color(0xFFF43F5E),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select : ne rebuild que si la catégorie change, pas à chaque lettre tapée
    final selected = ref.watch(filterProvider.select((f) => f.category));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (final category in ProductCategory.values)
          _CategoryItem(
            category: category,
            tint: _tints[category]!,
            isSelected: category == selected,
            onTap: () => ref
                .read(filterProvider.notifier)
                .setCategory(category == selected ? null : category),
          ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.tint,
    required this.isSelected,
    required this.onTap,
  });

  final ProductCategory category;
  final Color tint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? tint : tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: isSelected ? Colors.white : tint),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            category.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? tint : null,
                  fontWeight: isSelected ? FontWeight.w700 : null,
                ),
          ),
        ],
      ),
    );
  }
}
