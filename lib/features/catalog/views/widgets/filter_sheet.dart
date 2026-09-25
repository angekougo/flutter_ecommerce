import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../models/product_filter.dart';
import '../../models/product_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/filter_provider.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
    ),
    builder: (_) => const FilterSheet(),
  );
}

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(filterDraftProvider);
    final notifier = ref.read(filterDraftProvider.notifier);
    final bounds = ref.watch(priceBoundsProvider);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filtrer', style: textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: notifier.clear, child: const Text('Réinitialiser')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Catégorie', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: draft.category == null,
                  onSelected: (_) => notifier.setCategory(null),
                ),
                for (final category in ProductCategory.values)
                  ChoiceChip(
                    label: Text(category.label),
                    selected: draft.category == category,
                    onSelected: (_) => notifier.setCategory(category),
                  ),
              ],
            ),
            if (bounds != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Prix', style: textTheme.titleMedium),
              _PriceSlider(
                min: bounds.min,
                max: bounds.max,
                start: draft.minPrice ?? bounds.min,
                end: draft.maxPrice ?? bounds.max,
                // On stocke null quand le curseur est en butée : pas de limite.
                onChanged: (start, end) => notifier.setPriceRange(
                  start <= bounds.min ? null : start,
                  end >= bounds.max ? null : end,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text('Trier par', style: textTheme.titleMedium),
            RadioGroup<ProductSort>(
              groupValue: draft.sort,
              onChanged: (sort) => notifier.setSort(sort!),
              child: Column(
                children: [
                  for (final sort in ProductSort.values)
                    RadioListTile<ProductSort>(
                      value: sort,
                      title: Text(sort.label, style: textTheme.bodyLarge),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                ref.read(filterProvider.notifier).apply(draft);
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSlider extends StatelessWidget {
  const _PriceSlider({
    required this.min,
    required this.max,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int start;
  final int end;
  final void Function(int start, int end) onChanged;

  // Arrondi au multiple de 500 FCFA le plus proche.
  static int _round(double value) => (value / 500).round() * 500;

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).textTheme.bodySmall;

    return Column(
      children: [
        RangeSlider(
          min: min.toDouble(),
          max: max.toDouble(),
          values: RangeValues(start.toDouble(), end.toDouble()),
          onChanged: (values) => onChanged(
            _round(values.start).clamp(min, max),
            _round(values.end).clamp(min, max),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatPrice(start), style: caption),
            Text(formatPrice(end), style: caption),
          ],
        ),
      ],
    );
  }
}
