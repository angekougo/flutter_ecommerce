import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { home, favorites, cart, profile }

/// Onglet actif de la barre de navigation. Dans un provider plutôt que dans
/// le state du Scaffold : n'importe quel écran peut changer d'onglet
/// (ex. "Voir le panier" après un ajout, "Explorer" sur le panier vide).
class NavigationNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void goTo(AppTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationNotifier, AppTab>(
  NavigationNotifier.new,
);
