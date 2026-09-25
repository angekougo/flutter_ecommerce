import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bloc gris qui "respire" pendant le chargement.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 12, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorder
        : const Color(0xFFEDEDF2);

    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Grille de cartes produits factices (état de chargement du catalogue).
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SkeletonBox(height: double.infinity, radius: 12)),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(width: 110),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 60),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(width: 80, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
