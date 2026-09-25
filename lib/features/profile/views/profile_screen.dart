import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../core/shared_widgets/error_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../models/user_profile_model.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: const Text('Mon profil')),
      body: profileAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: 'Impossible de charger votre profil.',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (user) => _ProfileContent(user: user),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final favoriteCount = ref.watch(favoritesProvider).value?.length ?? 0;
    final memberSince = DateFormat.yMMMM('fr_FR').format(user.memberSince);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              user.initials,
              style: textTheme.headlineMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(user.fullName, textAlign: TextAlign.center, style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(user.email, textAlign: TextAlign.center, style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Membre depuis $memberSince',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Card(
          child: Column(
            children: [
              _MenuTile(
                icon: Icons.person_outline_rounded,
                label: 'Informations personnelles',
                onTap: () => _showPersonalInfo(context),
              ),
              const Divider(height: 1),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                label: 'Mes commandes',
                trailing: '${user.orderCount}',
                onTap: () => _showComingSoon(context),
              ),
              const Divider(height: 1),
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                label: 'Mes favoris',
                trailing: '$favoriteCount',
                onTap: () => ref.read(navigationProvider.notifier).goTo(AppTab.favorites),
              ),
              const Divider(height: 1),
              const _DarkModeTile(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'v1.0.0',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  void _showPersonalInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations personnelles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(icon: Icons.badge_outlined, value: user.fullName),
              _InfoRow(icon: Icons.mail_outline_rounded, value: user.email),
              _InfoRow(icon: Icons.phone_outlined, value: user.phone),
              _InfoRow(icon: Icons.location_on_outlined, value: user.address),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Bientôt disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text("Cette version de démonstration n'a pas de vrai compte."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) _showComingSoon(context);
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _DarkModeTile extends ConsumerWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    // En mode "système", on affiche l'état réel du téléphone.
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode_outlined),
      title: Text('Mode sombre', style: Theme.of(context).textTheme.bodyMedium),
      value: isDark,
      onChanged: ref.read(themeModeProvider.notifier).setDark,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
