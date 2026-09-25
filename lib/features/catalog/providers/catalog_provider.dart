import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';
import '../models/product_model.dart';

/// Point d'accès unique au repository. Dans les tests, on peut le remplacer
/// avec overrideWithValue(FakeRepository()).
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Liste complète des produits, chargée une seule fois puis mise en cache.
/// ref.invalidate(productsProvider) relance le chargement (bouton Réessayer).
final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).fetchProducts();
});

/// Un produit par son id, pour l'écran de détail. On s'appuie sur la liste
/// déjà en cache plutôt que de relire le JSON : l'ouverture est instantanée
/// et le Hero peut s'animer.
final productByIdProvider = FutureProvider.family<Product, String>((ref, id) async {
  final products = await ref.watch(productsProvider.future);
  return products.firstWhere(
    (product) => product.id == id,
    orElse: () => throw Exception('Produit introuvable ($id)'),
  );
});

/// Prix mini et maxi du catalogue, pour borner le slider du filtre.
/// null tant que les produits ne sont pas chargés.
final priceBoundsProvider = Provider<({int min, int max})?>((ref) {
  final products = ref.watch(productsProvider).value;
  if (products == null || products.isEmpty) return null;

  final prices = products.map((p) => p.price);
  return (
    min: prices.reduce((a, b) => a < b ? a : b),
    max: prices.reduce((a, b) => a > b ? a : b),
  );
});
