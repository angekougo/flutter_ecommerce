import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/models/product_model.dart';
import '../models/cart_item_model.dart';

const deliveryFee = 2000;
const maxQuantityPerItem = 10;

/// Le panier est une liste immuable : chaque action crée une nouvelle liste
/// et l'assigne à state, ce qui notifie les widgets qui l'écoutent.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Ajoute le produit, ou augmente sa quantité s'il est déjà dans le panier.
  void add(Product product, {int quantity = 1}) {
    final index = state.indexWhere((item) => item.product == product);

    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: quantity)];
    } else {
      final current = state[index].quantity;
      _replaceAt(index, (current + quantity).clamp(1, maxQuantityPerItem));
    }
  }

  void increment(String productId) {
    final index = _indexOf(productId);
    if (index == -1) return;
    final quantity = state[index].quantity;
    if (quantity < maxQuantityPerItem) _replaceAt(index, quantity + 1);
  }

  /// Ne descend jamais sous 1 : pour retirer un article on utilise [remove].
  void decrement(String productId) {
    final index = _indexOf(productId);
    if (index == -1) return;
    final quantity = state[index].quantity;
    if (quantity > 1) _replaceAt(index, quantity - 1);
  }

  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Remet un article supprimé à sa place (bouton "Annuler" du SnackBar).
  void restore(CartItem item, int index) {
    if (_indexOf(item.product.id) != -1) return;
    final items = [...state];
    items.insert(index.clamp(0, items.length), item);
    state = items;
  }

  void clear() => state = const [];

  int _indexOf(String productId) =>
      state.indexWhere((item) => item.product.id == productId);

  void _replaceAt(int index, int quantity) {
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantity: quantity) else state[i],
    ];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

// --- Providers dérivés : recalculés automatiquement quand le panier change ---

/// Nombre total d'articles (badge de l'icône panier).
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.total);
});

final cartTotalProvider = Provider<int>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal == 0 ? 0 : subtotal + deliveryFee;
});

/// Quantité choisie sur l'écran Détail avant l'ajout au panier.
/// family : une valeur par produit. autoDispose : remise à 1 en quittant l'écran.
class SelectedQuantityNotifier extends Notifier<int> {
  SelectedQuantityNotifier(this.productId);

  final String productId;

  @override
  int build() => 1;

  void increment() {
    if (state < maxQuantityPerItem) state++;
  }

  void decrement() {
    if (state > 1) state--;
  }
}

final selectedQuantityProvider =
    NotifierProvider.autoDispose.family<SelectedQuantityNotifier, int, String>(
  SelectedQuantityNotifier.new,
);
