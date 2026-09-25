import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Image réseau avec fond clair, indicateur de chargement et repli
/// en cas d'échec (hors ligne, URL cassée...).
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.padding = 8});

  final String url;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark ? AppColors.darkBorder : const Color(0xFFF4F4F7),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
