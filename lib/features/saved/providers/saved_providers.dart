import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/saved_item.dart';
import '../data/saved_repository.dart';
import '../../cart/data/models/cart_item.dart';
// ignore: unused_import — needed when implementing moveToCart
import '../../cart/providers/cart_providers.dart';

final savedNotifierProvider =
    AsyncNotifierProvider<SavedNotifier, List<SavedItem>>(SavedNotifier.new);

class SavedNotifier extends AsyncNotifier<List<SavedItem>> {
  late SavedRepository _savedRepository;

  @override
  Future<List<SavedItem>> build() async {
    _savedRepository = ref.read(savedRepositoryProvider);
    return _savedRepository.getSavedItems();
  }

  Future<void> saveForLater(CartItem cartItem) async {
    final current = state.valueOrNull ?? [];
    if (current.any((i) => i.productId == cartItem.productId)) return;

    await _savedRepository.saveItem(cartItem);
    state = AsyncData([
      ...current,
      SavedItem(
        productId: cartItem.productId,
        name: cartItem.name,
        price: cartItem.price,
        imageUrl: cartItem.imageUrl,
        quantity: cartItem.quantity,
      ),
    ]);
  }

  Future<void> removeFromSaved(String productId) async {
    // TODO: Task 4: removing from saved items
    final current = state.valueOrNull ?? [];

     await _savedRepository.removeItem(productId);
     state = AsyncData(
    current.where((i) => i.productId != productId).toList(),
  );
  }

  Future<void> moveToCart(String productId) async {
    // TODO: Task 4: enabling moving saved items to cart

    final current = state.valueOrNull ?? [];

    final item = current.firstWhere((i)=> i.productId == productId);

    await ref.read(cartNotifierProvider.notifier).addItem(
      CartItem(
        productId: item.productId,
        name: item.name,
        imageUrl: item.imageUrl,
        price: item.price,
        quantity: item.quantity,
      )
    );
    await _savedRepository.moveToCart(
      productId
    );

     state = AsyncData(
    current.where((i) => i.productId != productId).toList(),
  );
  }
}
