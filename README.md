# Shoply — App e-commerce Flutter avec Riverpod

Application e-commerce réalisée pour valider la maîtrise du state management avec **Riverpod 3**.
Catalogue, panier, favoris persistés, filtres/tri et profil, sur un design system maison (palette violette `#6E54FD`, police Manrope, thème clair/sombre).

| | |
|---|---|
| Flutter | 3.47 (Dart 3.13) |
| State management | `flutter_riverpod` 3.4 — **exclusivement** |
| Persistance | `shared_preferences` 2.5 (`SharedPreferencesAsync`) |
| Données | JSON local de 24 produits ([assets/data/products.json](assets/data/products.json)) |
| Tests | 16 tests unitaires (logique métier + providers) |

---

## Sommaire

1. [Lancer le projet](#lancer-le-projet)
2. [Architecture](#architecture)
3. [Liste des providers](#liste-des-providers)
4. [Fonctionnalités obligatoires](#fonctionnalités-obligatoires)
5. [Exigences techniques](#exigences-techniques)
6. [Bonus : animations d'ajout au panier](#bonus--animations-dajout-au-panier)
7. [Tests](#tests)
8. [Choix techniques](#choix-techniques)

---

## Lancer le projet

```bash
git clone https://github.com/angekougo/flutter_ecommerce.git
cd flutter_ecommerce
flutter pub get
flutter run
```

```bash
flutter test      # 16 tests
flutter analyze   # 0 issue
```

> Sous Windows, les plugins (shared_preferences) nécessitent le **mode développeur** : `start ms-settings:developers`.

**Tester l'écran d'erreur :** dans [catalog_provider.dart, ligne 9](lib/features/catalog/providers/catalog_provider.dart#L9), remplacer `ProductRepository()` par `ProductRepository(simulateError: true)`.

---

## Architecture

Architecture **feature-first**, chaque feature étant découpée en couches :

```
lib/
├── main.dart                         # ProviderScope + MaterialApp (thème piloté par un provider)
├── core/                             # Code partagé
│   ├── navigation/                   # Shell à onglets + navigationProvider
│   ├── theme/                        # Couleurs, espacements, ThemeData clair/sombre
│   ├── utils/                        # formatPrice() -> "45 000 FCFA"
│   └── shared_widgets/               # ErrorView, EmptyView, Skeleton, QuantitySelector
└── features/
    ├── catalog/
    │   ├── data/                     # ProductRepository (lecture JSON + latence simulée)
    │   ├── models/                   # Product, ProductCategory, ProductFilter (+ logique de tri)
    │   ├── providers/                # catalog_provider.dart, filter_provider.dart
    │   └── views/                    # product_list_screen, product_detail_screen, widgets/
    ├── cart/
    │   ├── models/                   # CartItem
    │   ├── providers/                # cart_provider.dart
    │   └── views/                    # cart_screen, widgets/ (badge animé, confirmation d'ajout)
    ├── favorites/
    │   ├── data/                     # FavoritesRepository (shared_preferences)
    │   ├── providers/                # favorites_provider.dart
    │   └── views/                    # favorites_screen, widgets/favorite_button
    └── profile/
        ├── data/                     # ProfileRepository (mock)
        ├── models/                   # UserProfile
        ├── providers/                # profile_provider.dart
        └── views/                    # profile_screen
```

### Flux des données

```
  Widget (views/)  ──ref.watch──▶  Provider (providers/)  ──appelle──▶  Repository (data/)  ──▶  JSON / SharedPreferences
        ▲                                │
        └──────── AsyncValue ◀───────────┘   (loading / data / error)
```

| Couche | Rôle | Dépend de Flutter UI ? |
|---|---|---|
| `data/` | Accès aux données (fichier JSON, stockage local). Aucune connaissance de Riverpod. | Non |
| `models/` | Objets immuables + règles métier pures (filtrage, tri, totaux). Testables sans widget. | Non |
| `providers/` | État de l'application, combinaison et dérivation des données. | Non |
| `views/` | Affichage uniquement. Lit l'état avec `ref.watch`, déclenche des actions avec `ref.read(...notifier)`. | Oui |

Les features ne s'importent jamais « écran à écran » : elles communiquent par les providers (ex. l'accueil lit le prénom dans `userProfileProvider`, le profil lit le nombre de favoris dans `favoritesProvider`).

---

## Liste des providers

**19 providers distincts** (le sujet en demande au moins 5).

| # | Provider | Type | Fichier | Rôle |
|---|---|---|---|---|
| 1 | `productRepositoryProvider` | `Provider` | [catalog_provider.dart#L8](lib/features/catalog/providers/catalog_provider.dart#L8) | Injection du repository produits |
| 2 | `productsProvider` | `FutureProvider` | [catalog_provider.dart#L14](lib/features/catalog/providers/catalog_provider.dart#L14) | Chargement asynchrone du catalogue |
| 3 | `productByIdProvider` | `FutureProvider.family` | [catalog_provider.dart#L21](lib/features/catalog/providers/catalog_provider.dart#L21) | Un produit par id (écran détail) |
| 4 | `priceBoundsProvider` | `Provider` (dérivé) | [catalog_provider.dart#L31](lib/features/catalog/providers/catalog_provider.dart#L31) | Prix min/max pour le slider |
| 5 | `filterProvider` | `NotifierProvider` | [filter_provider.dart#L23](lib/features/catalog/providers/filter_provider.dart#L23) | Critères actifs : recherche, catégorie, prix, tri |
| 6 | `filterDraftProvider` | `NotifierProvider.autoDispose` | [filter_provider.dart#L45](lib/features/catalog/providers/filter_provider.dart#L45) | Brouillon du bottom sheet (appliqué au clic) |
| 7 | `filteredProductsProvider` | `Provider<AsyncValue>` | [filter_provider.dart#L52](lib/features/catalog/providers/filter_provider.dart#L52) | Produits affichés = catalogue + filtres |
| 8 | `cartProvider` | `NotifierProvider` | [cart_provider.dart#L67](lib/features/cart/providers/cart_provider.dart#L67) | Contenu du panier |
| 9 | `cartCountProvider` | `Provider` (dérivé) | [cart_provider.dart#L74](lib/features/cart/providers/cart_provider.dart#L74) | Nombre d'articles (badge) |
| 10 | `cartSubtotalProvider` | `Provider` (dérivé) | [cart_provider.dart#L78](lib/features/cart/providers/cart_provider.dart#L78) | Sous-total |
| 11 | `cartTotalProvider` | `Provider` (dérivé) | [cart_provider.dart#L82](lib/features/cart/providers/cart_provider.dart#L82) | Total livraison comprise |
| 12 | `selectedQuantityProvider` | `NotifierProvider.autoDispose.family` | [cart_provider.dart#L106](lib/features/cart/providers/cart_provider.dart#L106) | Quantité choisie sur le détail |
| 13 | `favoritesRepositoryProvider` | `Provider` | [favorites_provider.dart#L7](lib/features/favorites/providers/favorites_provider.dart#L7) | Injection du stockage local |
| 14 | `favoritesProvider` | `AsyncNotifierProvider` | [favorites_provider.dart#L39](lib/features/favorites/providers/favorites_provider.dart#L39) | Ids favoris persistés |
| 15 | `isFavoriteProvider` | `Provider.family` | [favorites_provider.dart#L44](lib/features/favorites/providers/favorites_provider.dart#L44) | État du cœur d'un produit |
| 16 | `favoriteProductsProvider` | `Provider<AsyncValue>` | [favorites_provider.dart#L50](lib/features/favorites/providers/favorites_provider.dart#L50) | Produits favoris complets |
| 17 | `profileRepositoryProvider` | `Provider` | [profile_provider.dart#L7](lib/features/profile/providers/profile_provider.dart#L7) | Injection du service utilisateur mock |
| 18 | `userProfileProvider` | `FutureProvider` | [profile_provider.dart#L11](lib/features/profile/providers/profile_provider.dart#L11) | Profil utilisateur |
| 19 | `themeModeProvider` | `NotifierProvider` | [profile_provider.dart#L23](lib/features/profile/providers/profile_provider.dart#L23) | Thème clair / sombre / système |
| + | `navigationProvider` | `NotifierProvider` | [navigation_provider.dart#L15](lib/core/navigation/navigation_provider.dart#L15) | Onglet actif de la barre de navigation |

---

## Fonctionnalités obligatoires

### 1. Catalogue de produits (liste + détail)

**Chargement des produits — `FutureProvider`**
📄 [lib/features/catalog/providers/catalog_provider.dart](lib/features/catalog/providers/catalog_provider.dart#L14-L16) — lignes 14 à 16

```dart
final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).fetchProducts();
});
```

**Source des données (JSON local + latence réseau simulée)**
📄 [lib/features/catalog/data/product_repository.dart](lib/features/catalog/data/product_repository.dart#L13-L26) — lignes 13 à 26

```dart
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
```

**Liste — écran d'accueil (grille de produits)**
📄 [lib/features/catalog/views/product_list_screen.dart](lib/features/catalog/views/product_list_screen.dart#L60-L114) — lignes 60 à 114

**Détail — `FutureProvider.family`** : un produit par id, lu dans la liste déjà en cache (ouverture instantanée, animation Hero entre la carte et le détail).
📄 [lib/features/catalog/providers/catalog_provider.dart](lib/features/catalog/providers/catalog_provider.dart#L21-L27) — lignes 21 à 27

```dart
final productByIdProvider = FutureProvider.family<Product, String>((ref, id) async {
  final products = await ref.watch(productsProvider.future);
  return products.firstWhere(
    (product) => product.id == id,
    orElse: () => throw Exception('Produit introuvable ($id)'),
  );
});
```

📄 Écran : [lib/features/catalog/views/product_detail_screen.dart](lib/features/catalog/views/product_detail_screen.dart#L40-L52) — lignes 40 à 52 (carrousel d'images, note, prix, description, quantité, ajout au panier).

---

### 2. Panier d'achat (ajout, suppression, quantité)

**Notifier du panier** — état immuable : chaque action produit une nouvelle liste.
📄 [lib/features/cart/providers/cart_provider.dart](lib/features/cart/providers/cart_provider.dart#L11-L65) — lignes 11 à 65

| Action | Méthode | Ligne |
|---|---|---|
| Ajout (cumule si déjà présent) | `add(product, quantity:)` | [L16](lib/features/cart/providers/cart_provider.dart#L16) |
| Quantité + | `increment(productId)` | [L27](lib/features/cart/providers/cart_provider.dart#L27) |
| Quantité − (jamais sous 1) | `decrement(productId)` | [L35](lib/features/cart/providers/cart_provider.dart#L35) |
| Suppression | `remove(productId)` | [L42](lib/features/cart/providers/cart_provider.dart#L42) |
| Annulation de suppression | `restore(item, index)` | [L47](lib/features/cart/providers/cart_provider.dart#L47) |

```dart
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
```

**Providers dérivés** — recalculés automatiquement à chaque modification du panier.
📄 [lib/features/cart/providers/cart_provider.dart](lib/features/cart/providers/cart_provider.dart#L74-L85) — lignes 74 à 85

```dart
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
```

**Suppression depuis l'UI** (bouton ou swipe `Dismissible`, avec « Annuler »)
📄 [lib/features/cart/views/cart_screen.dart](lib/features/cart/views/cart_screen.dart#L65-L80) — lignes 65 à 80

```dart
void _removeItem(BuildContext context, WidgetRef ref, CartItem item, int index) {
  final cart = ref.read(cartProvider.notifier);
  cart.remove(item.product.id);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${item.product.name} retiré du panier'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => cart.restore(item, index),
        ),
      ),
    );
}
```

**Ajout depuis le détail avec la quantité choisie**
📄 [lib/features/catalog/views/product_detail_screen.dart](lib/features/catalog/views/product_detail_screen.dart#L69-L71) — lignes 69 à 71

```dart
final quantity = ref.read(selectedQuantityProvider(product.id));
ref.read(cartProvider.notifier).add(product, quantity: quantity);
showAddedToCartSheet(context, product);
```

---

### 3. Système de favoris persisté localement

**Stockage — `shared_preferences`**
📄 [lib/features/favorites/data/favorites_repository.dart](lib/features/favorites/data/favorites_repository.dart#L12-L17) — lignes 12 à 17

```dart
Future<Set<String>> load() async {
  final ids = await _prefs.getStringList(_key);
  return {...?ids};
}

Future<void> save(Set<String> ids) => _prefs.setStringList(_key, ids.toList());
```

**`AsyncNotifier` avec mise à jour optimiste et retour arrière en cas d'échec**
📄 [lib/features/favorites/providers/favorites_provider.dart](lib/features/favorites/providers/favorites_provider.dart#L13-L37) — lignes 13 à 37

```dart
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(favoritesRepositoryProvider).load();
  }

  Future<void> toggle(String productId) async {
    final previous = await future;
    final updated = previous.contains(productId)
        ? ({...previous}..remove(productId))
        : {...previous, productId};

    state = AsyncData(updated);

    try {
      await ref.read(favoritesRepositoryProvider).save(updated);
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous);
      rethrow;
    }
  }
}
```

**État d'un cœur — `Provider.family`** (chaque bouton n'écoute que son produit)
📄 [lib/features/favorites/providers/favorites_provider.dart](lib/features/favorites/providers/favorites_provider.dart#L44-L46) — lignes 44 à 46

```dart
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesProvider).value?.contains(productId) ?? false;
});
```

📄 Bouton cœur : [favorite_button.dart](lib/features/favorites/views/widgets/favorite_button.dart#L16) — 📄 Écran : [favorites_screen.dart](lib/features/favorites/views/favorites_screen.dart#L37)

---

### 4. Filtrage et tri des produits

**Logique métier pure** (aucune dépendance à Flutter ou Riverpod, couverte par 7 tests)
📄 [lib/features/catalog/models/product_filter.dart](lib/features/catalog/models/product_filter.dart#L59-L83) — lignes 59 à 83

```dart
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
```

**Combinaison chargement asynchrone + filtres**
📄 [lib/features/catalog/providers/filter_provider.dart](lib/features/catalog/providers/filter_provider.dart#L52-L55) — lignes 52 à 55

```dart
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final filter = ref.watch(filterProvider);
  return ref.watch(productsProvider).whenData(filter.apply);
});
```

| Critère | Où dans l'UI | Fichier / ligne |
|---|---|---|
| Recherche par nom | Champ de recherche de l'accueil | [product_list_screen.dart#L41](lib/features/catalog/views/product_list_screen.dart#L41) |
| Catégorie | Pastilles rondes de l'accueil | [category_selector.dart#L36](lib/features/catalog/views/widgets/category_selector.dart#L36) |
| Catégorie, prix, tri | Bottom sheet « Filtrer » | [filter_sheet.dart#L25](lib/features/catalog/views/widgets/filter_sheet.dart#L23) |
| Fourchette de prix | `RangeSlider` | [filter_sheet.dart#L75](lib/features/catalog/views/widgets/filter_sheet.dart#L75) |
| Tri (pertinence, prix ↑, prix ↓, notes) | `RadioGroup` | [filter_sheet.dart#L83](lib/features/catalog/views/widgets/filter_sheet.dart#L83) |
| Application du brouillon | Bouton « Appliquer » | [filter_sheet.dart#L102](lib/features/catalog/views/widgets/filter_sheet.dart#L102) |

---

### 5. Écran de profil utilisateur (mock)

📄 [lib/features/profile/data/profile_repository.dart](lib/features/profile/data/profile_repository.dart#L5-L18) — lignes 5 à 18 (utilisateur fictif, 600 ms de latence)
📄 [lib/features/profile/providers/profile_provider.dart](lib/features/profile/providers/profile_provider.dart#L11-L13) — lignes 11 à 13

```dart
final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).fetchCurrentUser();
});
```

📄 Écran : [lib/features/profile/views/profile_screen.dart](lib/features/profile/views/profile_screen.dart#L21-L28) — avatar, informations personnelles, nombre de favoris en direct ([L42](lib/features/profile/views/profile_screen.dart#L42)), interrupteur mode sombre ([L221](lib/features/profile/views/profile_screen.dart#L221)).

Le prénom est aussi réutilisé sur l'accueil (« Bonjour, Ange 👋 ») :
📄 [lib/features/catalog/views/product_list_screen.dart](lib/features/catalog/views/product_list_screen.dart#L153) — ligne 153

```dart
final firstName = ref.watch(userProfileProvider.select((p) => p.value?.firstName));
```

---

## Exigences techniques

### Utiliser exclusivement Riverpod

Aucun autre gestionnaire d'état (ni Provider, ni Bloc, ni GetX). Toute l'app est enveloppée dans un `ProviderScope` :
📄 [lib/main.dart](lib/main.dart#L14-L21) — lignes 14 à 21

```dart
runApp(
  ProviderScope(
    // Riverpod 3 relance automatiquement un provider en erreur. On coupe ce
    // comportement : c'est l'utilisateur qui décide via "Réessayer".
    retry: (retryCount, error) => null,
    child: const ShoplyApp(),
  ),
);
```

Même le thème de l'application est piloté par un provider ([main.dart#L34](lib/main.dart#L34)) : `themeMode: ref.watch(themeModeProvider)`.

Types de providers utilisés :

| Type | Exemples |
|---|---|
| `Provider` | `productRepositoryProvider`, `cartTotalProvider`, `filteredProductsProvider` |
| `Provider.family` | `isFavoriteProvider` |
| `FutureProvider` | `productsProvider`, `userProfileProvider` |
| `FutureProvider.family` | `productByIdProvider` |
| `NotifierProvider` | `cartProvider`, `filterProvider`, `themeModeProvider`, `navigationProvider` |
| `NotifierProvider.autoDispose` | `filterDraftProvider` |
| `NotifierProvider.autoDispose.family` | `selectedQuantityProvider` |
| `AsyncNotifierProvider` | `favoritesProvider` |

> **`Notifier` plutôt que `StateNotifier`** : depuis Riverpod 3, `StateNotifier`/`StateNotifierProvider` et `StateProvider` sont déplacés dans `package:flutter_riverpod/legacy.dart` et marqués comme obsolètes. La documentation officielle recommande `Notifier` / `AsyncNotifier`, qui jouent le même rôle (état + méthodes de mutation) avec accès direct à `ref`. Le projet utilise donc l'API actuelle.

### Au moins 5 providers distincts

✅ **19 providers** — voir le [tableau complet](#liste-des-providers).

### Séparer la logique métier des widgets (architecture en couches)

✅ Voir la section [Architecture](#architecture). Exemples concrets :

- Filtrage et tri : `ProductFilter.apply()` — [product_filter.dart#L59](lib/features/catalog/models/product_filter.dart#L59), aucune ligne de logique dans les widgets.
- Calcul des totaux : providers dérivés — [cart_provider.dart#L74-L85](lib/features/cart/providers/cart_provider.dart#L74-L85).
- Accès aux données derrière des repositories injectés par provider — [catalog_provider.dart#L8](lib/features/catalog/providers/catalog_provider.dart#L8), [favorites_provider.dart#L7](lib/features/favorites/providers/favorites_provider.dart#L7), remplaçables dans les tests avec `overrideWithValue` ([favorites_provider_test.dart#L29-L31](test/favorites_provider_test.dart#L29-L31)).

### Gérer les états de chargement et d'erreur dans l'UI

Widgets partagés pour les trois états visuels :

| État | Widget | Fichier |
|---|---|---|
| Chargement | `ProductGridSkeleton` (cartes grises animées) | [skeleton.dart#L52](lib/core/shared_widgets/skeleton.dart#L52) |
| Erreur | `ErrorView` + bouton « Réessayer » | [error_view.dart#L7](lib/core/shared_widgets/error_view.dart#L7) |
| Vide | `EmptyView` + action | [empty_view.dart#L7](lib/core/shared_widgets/empty_view.dart#L7) |

« Réessayer » relance le provider avec `ref.invalidate(...)` :
📄 [product_list_screen.dart#L68](lib/features/catalog/views/product_list_screen.dart#L68) · [product_detail_screen.dart#L45](lib/features/catalog/views/product_detail_screen.dart#L45) · [favorites_screen.dart#L46-L47](lib/features/favorites/views/favorites_screen.dart#L46-L47) · [profile_screen.dart#L26](lib/features/profile/views/profile_screen.dart#L26)

Les erreurs d'écriture des favoris sont aussi remontées à l'utilisateur (SnackBar) : [favorite_button.dart#L45-L56](lib/features/favorites/views/widgets/favorite_button.dart#L45-L56).

### Utiliser `AsyncValue` pour les données asynchrones

**`AsyncValue.when`** sur les 4 écrans alimentés par des données asynchrones :

| Écran | Fichier / ligne |
|---|---|
| Accueil | [product_list_screen.dart#L60](lib/features/catalog/views/product_list_screen.dart#L60) |
| Détail | [product_detail_screen.dart#L40](lib/features/catalog/views/product_detail_screen.dart#L40) |
| Favoris | [favorites_screen.dart#L37](lib/features/favorites/views/favorites_screen.dart#L37) |
| Profil | [profile_screen.dart#L21](lib/features/profile/views/profile_screen.dart#L21) |

📄 [lib/features/catalog/views/product_list_screen.dart](lib/features/catalog/views/product_list_screen.dart#L60-L70) — lignes 60 à 70

```dart
...productsAsync.when(
  skipLoadingOnRefresh: false,
  loading: () => const [
    SliverToBoxAdapter(child: ProductGridSkeleton()),
  ],
  error: (error, _) => [
    SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorView(onRetry: () => ref.invalidate(productsProvider)),
    ),
  ],
  data: (products) { /* grille, ou EmptyView si aucun résultat */ },
```

Autres manipulations d'`AsyncValue` :

- **`whenData`** pour transformer la donnée sans perdre les états loading/error — [filter_provider.dart#L54](lib/features/catalog/providers/filter_provider.dart#L54)
- **`whenOrNull`** pour n'afficher le bouton « Ajouter au panier » qu'une fois le produit chargé — [product_detail_screen.dart#L50](lib/features/catalog/views/product_detail_screen.dart#L50)
- **Pattern matching** pour combiner deux `AsyncValue` — [favorites_provider.dart#L50-L64](lib/features/favorites/providers/favorites_provider.dart#L50-L64)

```dart
return switch ((products, favorites)) {
  (AsyncData(value: final products), AsyncData(value: final ids)) => AsyncData([
      for (final id in ids.toList().reversed)
        ...products.where((product) => product.id == id),
    ]),
  (AsyncError(:final error, :final stackTrace), _) ||
  (_, AsyncError(:final error, :final stackTrace)) =>
    AsyncError(error, stackTrace),
  _ => const AsyncLoading(),
};
```

- **`AsyncData` dans un notifier** pour la mise à jour optimiste — [favorites_provider.dart#L28](lib/features/favorites/providers/favorites_provider.dart#L28)

### Données produits mockées (JSON local)

📄 [assets/data/products.json](assets/data/products.json) — 24 produits, 4 catégories (Tech, Mode, Maison, Beauté), prix en FCFA.
Désérialisation : [product_model.dart#L44](lib/features/catalog/models/product_model.dart#L44) (`Product.fromJson`).

---

## Bonus : animations d'ajout au panier

| Animation | Technique | Fichier |
|---|---|---|
| Le produit « tombe » dans une feuille de confirmation, puis une coche apparaît avec un rebond | `TweenAnimationBuilder` + `Curves.easeOutBack` / `Interval` + `Curves.elasticOut` | [added_to_cart_sheet.dart#L42-L81](lib/features/cart/views/widgets/added_to_cart_sheet.dart#L42-L79) |
| Le badge du panier rebondit à chaque ajout | `ref.listen` + `AnimationController` + `TweenSequence` | [cart_badge_icon.dart#L42-L44](lib/features/cart/views/widgets/cart_badge_icon.dart#L42-L44) |
| Transition carte → détail | `Hero` | [product_card.dart#L35](lib/features/catalog/views/widgets/product_card.dart#L35) |
| Changement de quantité / cœur favori | `AnimatedSwitcher` + `ScaleTransition` | [quantity_selector.dart#L30](lib/core/shared_widgets/quantity_selector.dart#L30), [favorite_button.dart#L27](lib/features/favorites/views/widgets/favorite_button.dart#L27) |

`ref.listen` déclenche l'animation **sans reconstruire** le widget :
📄 [lib/features/cart/views/widgets/cart_badge_icon.dart](lib/features/cart/views/widgets/cart_badge_icon.dart#L42-L44) — lignes 42 à 44

```dart
ref.listen(cartCountProvider, (previous, next) {
  if (next > (previous ?? 0)) _bounce.forward(from: 0);
});
```

---

## Tests

```bash
flutter test
```

| Fichier | Tests | Ce qui est vérifié |
|---|---|---|
| [test/product_filter_test.dart](test/product_filter_test.dart) | 7 | Filtre par catégorie, prix, recherche ; les 3 tris ; `copyWith` |
| [test/cart_provider_test.dart](test/cart_provider_test.dart) | 6 | Cumul des quantités, bornes 1–10, totaux dérivés, suppression/restauration |
| [test/favorites_provider_test.dart](test/favorites_provider_test.dart) | 3 | Chargement depuis le stockage, persistance du toggle, retour arrière si l'écriture échoue |

Les providers sont testés avec `ProviderContainer.test()` et un faux repository injecté par `overrideWithValue` — aucun widget ni plugin natif n'est nécessaire.

---

## Choix techniques

- **`ref.watch` / `ref.read` / `ref.listen`** : `watch` pour afficher, `read` dans les callbacks (`onPressed`), `listen` pour les effets de bord (animation du badge).
- **`select`** pour limiter les rebuilds : les pastilles de catégorie ne se reconstruisent pas à chaque lettre tapée dans la recherche ([category_selector.dart#L24](lib/features/catalog/views/widgets/category_selector.dart#L24)).
- **`autoDispose`** pour l'état éphémère : le brouillon du filtre et la quantité du détail sont libérés à la fermeture de l'écran.
- **`family`** pour paramétrer un provider : un produit, un cœur, une quantité par id.
- **Retry automatique désactivé** ([main.dart#L18](lib/main.dart#L18)) : l'utilisateur garde la main via « Réessayer ».
- **Navigation par onglets pilotée par un provider** ([navigation_provider.dart](lib/core/navigation/navigation_provider.dart)) : n'importe quel écran peut ouvrir le panier (« Voir le panier », « Explorer »…).
- **Modèles immuables** (`@immutable`, `copyWith`, `==` sur l'id) : Riverpod détecte les changements par comparaison de références.
