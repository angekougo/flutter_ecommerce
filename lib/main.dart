import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/main_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      // Riverpod 3 relance automatiquement un provider en erreur. On coupe ce
      // comportement : c'est l'utilisateur qui décide via "Réessayer".
      retry: (retryCount, error) => null,
      child: const ShoplyApp(),
    ),
  );
}

class ShoplyApp extends StatelessWidget {
  const ShoplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
