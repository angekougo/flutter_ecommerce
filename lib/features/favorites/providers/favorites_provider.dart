import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/models/product_model.dart';
import '../../catalog/providers/catalog_provider.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

/// Ids des produits favoris. AsyncNotifier car la lecture du disque est
/// asynchrone : l'état est un `AsyncValue<Set<String>>` (loading -> data/error).
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(favoritesRepositoryProvider).load();
  }

  /// Mise à jour optimiste : le cœur change tout de suite, puis on sauvegarde.
  /// Si l'écriture échoue, on revient à l'état précédent et on relance
  /// l'erreur pour que l'UI puisse prévenir l'utilisateur.
  Future<void> toggle(String productId) async {
    final previous = await future;
    final updated = previous.contains(productId)
        ? ({...previous}..remove(productId))
        : {...previous, productId};

    state = AsyncData(updated);

    try {
      await ref.read(favoritesRepositoryProvider).save(updated);
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous);
      rethrow;
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// true si le produit est en favori. Chaque cœur n'écoute que son produit.
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesProvider).value?.contains(productId) ?? false;
});

/// Produits favoris complets (le plus récent en premier). Combine deux
/// AsyncValue : il faut que les produits ET les favoris soient chargés.
final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productsProvider);
  final favorites = ref.watch(favoritesProvider);

  return switch ((products, favorites)) {
    (AsyncData(value: final products), AsyncData(value: final ids)) => AsyncData([
        for (final id in ids.toList().reversed)
          ...products.where((product) => product.id == id),
      ]),
    (AsyncError(:final error, :final stackTrace), _) ||
    (_, AsyncError(:final error, :final stackTrace)) =>
      AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});
