import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/navigation/main_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Noms des mois en français ("mars 2025") pour DateFormat.
  await initializeDateFormatting('fr_FR');

  runApp(
    ProviderScope(
      // Riverpod 3 relance automatiquement un provider en erreur. On coupe ce
      // comportement : c'est l'utilisateur qui décide via "Réessayer".
      retry: (retryCount, error) => null,
      child: const ShoplyApp(),
    ),
  );
}

class ShoplyApp extends ConsumerWidget {
  const ShoplyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Shoply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const MainShell(),
    );
  }
}
