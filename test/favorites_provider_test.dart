import 'package:flutter_ecommerce/features/favorites/data/favorites_repository.dart';
import 'package:flutter_ecommerce/features/favorites/providers/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Remplace shared_preferences par une simple variable en mémoire.
class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository([Set<String> initial = const {}]) : stored = {...initial};

  Set<String> stored;
  bool failOnSave = false;

  @override
  Future<Set<String>> load() async => {...stored};

  @override
  Future<void> save(Set<String> ids) async {
    if (failOnSave) throw Exception('disque plein');
    stored = {...ids};
  }
}

void main() {
  late FakeFavoritesRepository repository;
  late ProviderContainer container;

  void createContainer([Set<String> initial = const {}]) {
    repository = FakeFavoritesRepository(initial);
    container = ProviderContainer.test(
      overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('charge les favoris déjà enregistrés au démarrage', () async {
    createContainer({'p1', 'p3'});

    expect(container.read(favoritesProvider), isA<AsyncLoading<Set<String>>>());
    expect(await container.read(favoritesProvider.future), {'p1', 'p3'});
    expect(container.read(isFavoriteProvider('p1')), isTrue);
    expect(container.read(isFavoriteProvider('p2')), isFalse);
  });

  test('toggle ajoute puis retire un favori et le persiste', () async {
    createContainer();
    final notifier = container.read(favoritesProvider.notifier);

    await notifier.toggle('p2');
    expect(container.read(favoritesProvider).value, {'p2'});
    expect(repository.stored, {'p2'});

    await notifier.toggle('p2');
    expect(container.read(favoritesProvider).value, isEmpty);
    expect(repository.stored, isEmpty);
  });

  test("si la sauvegarde échoue, l'état revient en arrière", () async {
    createContainer({'p1'});
    await container.read(favoritesProvider.future);
    repository.failOnSave = true;

    await expectLater(
      container.read(favoritesProvider.notifier).toggle('p2'),
      throwsException,
    );
    expect(container.read(favoritesProvider).value, {'p1'});
  });
}
