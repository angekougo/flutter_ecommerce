import 'package:flutter/foundation.dart';

import '../../catalog/models/product_model.dart';

@immutable
class CartItem {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  int get total => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
