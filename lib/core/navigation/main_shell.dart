import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/views/cart_screen.dart';
import '../../features/cart/views/widgets/cart_badge_icon.dart';
import '../../features/catalog/views/product_list_screen.dart';
import '../../features/favorites/views/favorites_screen.dart';
import 'navigation_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  // Même ordre que l'enum AppTab.
  static const _screens = [
    ProductListScreen(),
    FavoritesScreen(),
    CartScreen(),
    Center(child: Text('Profil')), // Branché à l'étape 5.
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(navigationProvider);

    return Scaffold(
      // IndexedStack garde chaque onglet en vie : on retrouve le scroll
      // et la recherche en revenant sur l'accueil.
      body: IndexedStack(
        index: tab.index,
        children: [
          for (final (index, screen) in _screens.indexed)
            // Accueil et Favoris affichent les mêmes produits avec les mêmes
            // tags Hero : on désactive ceux des onglets cachés pour éviter
            // le conflit à l'ouverture d'un détail.
            HeroMode(enabled: index == tab.index, child: screen),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) =>
            ref.read(navigationProvider.notifier).goTo(AppTab.values[index]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: const CartBadgeIcon(),
            selectedIcon: const CartBadgeIcon(selected: true),
            label: 'Panier',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
