import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

/// Icône panier avec le nombre d'articles. Le badge "rebondit" à chaque ajout.
class CartBadgeIcon extends ConsumerStatefulWidget {
  const CartBadgeIcon({super.key, this.selected = false});

  final bool selected;

  @override
  ConsumerState<CartBadgeIcon> createState() => _CartBadgeIconState();
}

class _CartBadgeIconState extends ConsumerState<CartBadgeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
    TweenSequenceItem(
      tween: Tween(begin: 1.35, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 60,
    ),
  ]).animate(_bounce);

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen réagit à un changement sans reconstruire le widget :
    // idéal pour déclencher une animation.
    ref.listen(cartCountProvider, (previous, next) {
      if (next > (previous ?? 0)) _bounce.forward(from: 0);
    });

    final count = ref.watch(cartCountProvider);

    return ScaleTransition(
      scale: _scale,
      child: Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accent,
        label: Text('$count'),
        child: Icon(
          widget.selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
        ),
      ),
    );
  }
}
