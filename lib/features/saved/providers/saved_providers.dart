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
    // TODO: implement
  }

  Future<void> moveToCart(String productId) async {
    // TODO: implement
  }
}
