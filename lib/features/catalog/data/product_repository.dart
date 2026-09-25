import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product_model.dart';

class ProductRepository {
  ProductRepository({this.simulateError = false});

  // Passer à true pour tester l'écran d'erreur.
  final bool simulateError;

  Future<List<Product>> fetchProducts() async {
    final products = await rootBundle.loadString("assets/data/products.json");

    await Future.delayed(const Duration(milliseconds: 800));

    if (simulateError) {
      throw Exception("Impossible de joindre le serveur");
    }

    final data = jsonDecode(products) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
