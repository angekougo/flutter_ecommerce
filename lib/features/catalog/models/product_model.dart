import 'package:flutter/material.dart';

enum ProductCategory {
  tech('Tech', Icons.laptop_mac_rounded),
  mode('Mode', Icons.checkroom_rounded),
  maison('Maison', Icons.home_outlined),
  beaute('Beauté', Icons.spa_outlined);

  const ProductCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  static ProductCategory fromName(String name) => ProductCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => throw FormatException('Catégorie inconnue : $name'),
      );
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.images = const [],
  });

  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final int price; // en FCFA
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ProductCategory.fromName(json['category'] as String),
      price: (json['price'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String,
      images: (json['images'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  // Deux produits sont identiques s'ils ont le même id : utile pour le panier
  // et les favoris.
  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
