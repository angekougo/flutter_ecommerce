import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/favorites_provider.dart';

/// Cœur rond affiché sur les cartes et l'écran détail.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 32});

  final String productId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(productId));

    return SizedBox.square(
      dimension: size,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _toggle(context, ref),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: child,
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              size: size * 0.55,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(favoritesProvider.notifier).toggle(productId);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Impossible d'enregistrer le favori, réessayez."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
