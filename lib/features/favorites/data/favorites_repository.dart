import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local des favoris : on ne garde que les ids des produits.
class FavoritesRepository {
  FavoritesRepository([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const _key = 'favorite_product_ids';

  final SharedPreferencesAsync _prefs;

  Future<Set<String>> load() async {
    final ids = await _prefs.getStringList(_key);
    return {...?ids};
  }

  Future<void> save(Set<String> ids) => _prefs.setStringList(_key, ids.toList());
}
