import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_filter.dart';
import '../models/product_model.dart';
import 'catalog_provider.dart';

class FilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(ProductCategory? category) =>
      state = state.copyWith(category: () => category);

  /// Remplace catégorie, prix et tri d'un coup (bouton "Appliquer" du
  /// bottom sheet). La recherche en cours est conservée.
  void apply(ProductFilter filter) => state = filter.copyWith(query: state.query);

  void reset() => state = ProductFilter(query: state.query);
}

final filterProvider = NotifierProvider<FilterNotifier, ProductFilter>(
  FilterNotifier.new,
);

/// Brouillon du bottom sheet "Filtrer" : les choix ne touchent le catalogue
/// qu'au clic sur Appliquer. autoDispose -> le brouillon est jeté à la
/// fermeture du sheet et repart du filtre actif à la prochaine ouverture.
class FilterDraftNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => ref.read(filterProvider);

  void setCategory(ProductCategory? category) =>
      state = state.copyWith(category: () => category);

  void setPriceRange(int? min, int? max) =>
      state = state.copyWith(minPrice: () => min, maxPrice: () => max);

  void setSort(ProductSort sort) => state = state.copyWith(sort: sort);

  void clear() => state = ProductFilter(query: state.query);
}

final filterDraftProvider =
    NotifierProvider.autoDispose<FilterDraftNotifier, ProductFilter>(
  FilterDraftNotifier.new,
);

/// Produits affichés : combine le chargement asynchrone et les filtres.
/// whenData garde les états loading/error de productsProvider intacts.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final filter = ref.watch(filterProvider);
  return ref.watch(productsProvider).whenData(filter.apply);
});
