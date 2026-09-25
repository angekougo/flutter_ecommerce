import 'package:flutter_ecommerce/features/catalog/models/product_filter.dart';
import 'package:flutter_ecommerce/features/catalog/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id, ProductCategory category, int price, double rating) {
  return Product(
    id: id,
    name: 'Produit $id',
    description: '',
    category: category,
    price: price,
    rating: rating,
    reviewCount: 0,
    imageUrl: '',
  );
}

void main() {
  final products = [
    _product('a', ProductCategory.tech, 45000, 4.8),
    _product('b', ProductCategory.mode, 25000, 4.2),
    _product('c', ProductCategory.tech, 60000, 4.5),
    _product('d', ProductCategory.maison, 3500, 3.9),
  ];

  List<String> ids(List<Product> list) => list.map((p) => p.id).toList();

  test('sans critère, tous les produits sont renvoyés dans le même ordre', () {
    expect(ids(const ProductFilter().apply(products)), ['a', 'b', 'c', 'd']);
  });

  test('filtre par catégorie', () {
    const filter = ProductFilter(category: ProductCategory.tech);
    expect(ids(filter.apply(products)), ['a', 'c']);
  });

  test('filtre par fourchette de prix (bornes incluses)', () {
    const filter = ProductFilter(minPrice: 25000, maxPrice: 45000);
    expect(ids(filter.apply(products)), ['a', 'b']);
  });

  test('la recherche ignore la casse', () {
    const filter = ProductFilter(query: 'PRODUIT c');
    expect(ids(filter.apply(products)), ['c']);
  });

  test('tri par prix croissant puis décroissant', () {
    expect(
      ids(const ProductFilter(sort: ProductSort.priceAsc).apply(products)),
      ['d', 'b', 'a', 'c'],
    );
    expect(
      ids(const ProductFilter(sort: ProductSort.priceDesc).apply(products)),
      ['c', 'a', 'b', 'd'],
    );
  });

  test('tri par note combiné à une catégorie', () {
    const filter = ProductFilter(
      category: ProductCategory.tech,
      sort: ProductSort.topRated,
    );
    expect(ids(filter.apply(products)), ['a', 'c']);
  });

  test('copyWith permet de remettre la catégorie à null', () {
    const filter = ProductFilter(category: ProductCategory.mode);
    expect(filter.copyWith(category: () => null).category, isNull);
    expect(filter.copyWith(sort: ProductSort.priceAsc).category, ProductCategory.mode);
  });
}
