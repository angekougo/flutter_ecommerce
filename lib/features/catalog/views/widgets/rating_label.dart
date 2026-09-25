import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// ★ 4.8 (124)
class RatingLabel extends StatelessWidget {
  const RatingLabel({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.showWordAvis = false,
  });

  final double rating;
  final int reviewCount;
  final bool showWordAvis;

  @override
  Widget build(BuildContext context) {
    final reviews = showWordAvis ? '$reviewCount avis' : '$reviewCount';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          '${rating.toStringAsFixed(1)} ($reviews)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
