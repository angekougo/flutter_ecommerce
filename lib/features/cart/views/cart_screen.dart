import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../core/shared_widgets/empty_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/price_formatter.dart';
import '../models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mon panier'),
            if (items.isNotEmpty)
              Text(
                count > 1 ? '$count articles' : '1 article',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
      body: items.isEmpty
          ? EmptyView(
              icon: Icons.shopping_cart_outlined,
              title: 'Votre panier est vide',
              message: 'Découvrez nos produits et\ncommencez vos achats.',
              actionLabel: 'Explorer',
              onAction: () => ref.read(navigationProvider.notifier).goTo(AppTab.home),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  onDismissed: (_) => _removeItem(context, ref, item, index),
                  child: CartItemTile(
                    item: item,
                    onRemove: () => _removeItem(context, ref, item, index),
                  ),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty ? null : const _CartSummary(),
    );
  }

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
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
    );
  }
}

class _CartSummary extends ConsumerWidget {
  const _CartSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final total = ref.watch(cartTotalProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Sous-total', value: formatPrice(subtotal)),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(label: 'Livraison', value: formatPrice(deliveryFee)),
          const Divider(height: AppSpacing.xxl),
          Row(
            children: [
              Text('Total', style: textTheme.titleMedium),
              const Spacer(),
              Text(
                formatPrice(total),
                style: textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => _confirmOrder(context, ref, total),
            child: const Text('Commander'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref, int total) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la commande'),
        content: Text('Montant à payer : ${formatPrice(total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    ref.read(cartProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commande validée, merci pour votre achat !'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
