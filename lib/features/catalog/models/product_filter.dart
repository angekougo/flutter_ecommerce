import 'package:flutter/foundation.dart';

import 'product_model.dart';

enum ProductSort {
  relevance('Pertinence'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  topRated('Meilleures notes');

  const ProductSort(this.label);
  final String label;
}

/// Critères de recherche du catalogue. Immuable : chaque changement
/// crée une nouvelle instance via [copyWith].
@immutable
class ProductFilter {
  const ProductFilter({
    this.query = '',
    this.category,
    this.minPrice,
    this.maxPrice,
    this.sort = ProductSort.relevance,
  });

  final String query;
  final ProductCategory? category; // null = toutes les catégories
  final int? minPrice;
  final int? maxPrice;
  final ProductSort sort;

  bool get hasPriceRange => minPrice != null || maxPrice != null;

  /// Nombre de critères actifs (hors recherche), affiché sur le bouton Filtrer.
  int get activeCount =>
      (category != null ? 1 : 0) +
      (hasPriceRange ? 1 : 0) +
      (sort != ProductSort.relevance ? 1 : 0);

  // Les fonctions en paramètre permettent de remettre une valeur à null :
  // copyWith(category: () => null)
  ProductFilter copyWith({
    String? query,
    ProductCategory? Function()? category,
    int? Function()? minPrice,
    int? Function()? maxPrice,
    ProductSort? sort,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      sort: sort ?? this.sort,
    );
  }

  List<Product> apply(List<Product> products) {
    final search = query.trim().toLowerCase();

    final result = products.where((p) {
      if (category != null && p.category != category) return false;
      if (minPrice != null && p.price < minPrice!) return false;
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (search.isNotEmpty && !p.name.toLowerCase().contains(search)) {
        return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case ProductSort.relevance:
        break;
      case ProductSort.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.topRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }
}
