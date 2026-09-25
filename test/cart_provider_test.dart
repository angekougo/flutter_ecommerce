import 'package:flutter_ecommerce/features/cart/providers/cart_provider.dart';
import 'package:flutter_ecommerce/features/catalog/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const casque = Product(
  id: 'p1',
  name: 'Casque',
  description: '',
  category: ProductCategory.tech,
  price: 45000,
  rating: 4.8,
  reviewCount: 124,
  imageUrl: '',
);

const montre = Product(
  id: 'p2',
  name: 'Montre',
  description: '',
  category: ProductCategory.tech,
  price: 60000,
  rating: 4.6,
  reviewCount: 98,
  imageUrl: '',
);

void main() {
  late ProviderContainer container;
  late CartNotifier cart;

  setUp(() {
    // ProviderContainer.test() dispose automatiquement le container en fin de test.
    container = ProviderContainer.test();
    cart = container.read(cartProvider.notifier);
  });

  test('le panier est vide au départ', () {
    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartTotalProvider), 0);
  });

  test('ajouter deux fois le même produit cumule la quantité', () {
    cart.add(casque);
    cart.add(casque, quantity: 2);

    final items = container.read(cartProvider);
    expect(items, hasLength(1));
    expect(items.single.quantity, 3);
  });

  test('la quantité reste entre 1 et le maximum autorisé', () {
    cart.add(casque);
    cart.decrement(casque.id);
    expect(container.read(cartProvider).single.quantity, 1);

    cart.add(casque, quantity: 50);
    expect(container.read(cartProvider).single.quantity, maxQuantityPerItem);
  });

  test('les totaux sont recalculés à chaque changement', () {
    cart.add(casque, quantity: 2); // 90 000
    cart.add(montre); // 60 000

    expect(container.read(cartCountProvider), 3);
    expect(container.read(cartSubtotalProvider), 150000);
    expect(container.read(cartTotalProvider), 150000 + deliveryFee);

    cart.increment(montre.id);
    expect(container.read(cartSubtotalProvider), 210000);
  });

  test('supprimer puis restaurer remet l\'article à sa position', () {
    cart.add(casque);
    cart.add(montre);
    final removed = container.read(cartProvider).first;

    cart.remove(casque.id);
    expect(container.read(cartProvider).map((i) => i.product.id), ['p2']);

    cart.restore(removed, 0);
    expect(container.read(cartProvider).map((i) => i.product.id), ['p1', 'p2']);
  });

  test('clear vide le panier', () {
    cart.add(casque);
    cart.clear();
    expect(container.read(cartProvider), isEmpty);
  });
}
