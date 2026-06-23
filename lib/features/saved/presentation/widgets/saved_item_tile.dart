import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shop/features/saved/providers/saved_providers.dart';

import '../../data/models/saved_item.dart';

class SavedItemTile extends ConsumerWidget {
  final SavedItem item;

  const SavedItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFFE0E0E0)),
          ),
        ),
      ),
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        '\$${item.price.toStringAsFixed(2)}',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.green[700]),
      ),
      // TODO: add action buttons : Task 4
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ref
                  .read(savedNotifierProvider.notifier)
                  .moveToCart(item.productId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref
                  .read(savedNotifierProvider.notifier)
                  .removeFromSaved(item.productId);
            },
          ),
        ],
      ),
    );
  }
}
