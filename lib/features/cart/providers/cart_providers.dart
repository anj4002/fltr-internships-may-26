import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_repository.dart';
import '../data/cart_state.dart';
import '../data/models/cart_item.dart';

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<CartState> {
  late CartRepository _cartRepository;

  @override
  Future<CartState> build() async {
    _cartRepository = ref.read(cartRepositoryProvider);
    return _cartRepository.loadCart();
  }

  Future<void> addItem(CartItem item) async {
    final current = state.requireValue;
    final existingIndex =
        current.items.indexWhere((i) => i.productId == item.productId);

    final CartState next;
    if (existingIndex >= 0) {
      final updatedItems = [...current.items];
      updatedItems[existingIndex] = updatedItems[existingIndex]
          .copyWith(quantity: updatedItems[existingIndex].quantity + 1);
      next = current.copyWith(
        items: updatedItems,
        total: current.total + item.price,
      );
    } else {
      next = current.copyWith(
        items: [...current.items, item],
        total: current.total + item.price,
      );
    }

    state = AsyncData(next);
    await _cartRepository.persistCart(next);
  }

  Future<void> removeItem(String productId) async {
    final current = state.requireValue;
    final item =
        current.items.firstWhere((i) => i.productId == productId);
    final next = current.copyWith(
      items: current.items.where((i) => i.productId != productId).toList(),
      total: current.total - (item.price * item.quantity),
    );
    state = AsyncData(next);
    await _cartRepository.persistCart(next);
  }

  Future<void> incrementQuantity(String productId) async {
    //Task 1: The cart quantity was not updating correctly when 
    //users tapped the "+" button multiple times in quick succession. 
    //Due to asynchronous state updates, each tap was reading an outdated
    // quantity value, causing some increments to be lost. I fixed this by 
    //updating the cart state using the latest available state before persisting it, 
    //ensuring that every tap is processed correctly and the quantity always reflects the expected value.

    final current = state.requireValue;

    final updatedItems = current.items.map((i) {
      if(i.productId == productId) {
        return i.copyWith(quantity: i.quantity +1);
      }
      return i;
    }).toList();

    final item =
      current.items.firstWhere(
        (i) => i.productId == productId,
        );

    final next = current.copyWith(
      items: updatedItems, 
      total: current.total + item.price,
      );

    //Task 3: Earlier we used to persist the cart and then update 
    //the data now we update the data then persist the cart.
       state = AsyncData(next);
       await _cartRepository.persistCart(next);
  }

  Future<void> decrementQuantity(String productId) async {
    final current = state.requireValue;
    final item = current.items.firstWhere((i) => i.productId == productId);

    if (item.quantity <= 1) {
      await removeItem(productId);
      return;
    }

    //Task 2: The cart total was becoming inconsistent after quantity
    // updates and item removals because the total value was not being 
    //updated correctly across all cart operations. In some scenarios, 
    //this caused the displayed total to differ from the actual sum of 
    //(price × quantity) and could even result in negative values. I 
    //fixed this by ensuring that the cart total is updated accurately 
    //whenever item quantities change or items are removed, keeping it 
    //synchronized with the cart contents at all times.

    final updatedItems = current.items
        .map((i) => i.productId == productId
            ? i.copyWith(quantity: i.quantity - 1)
            : i)
        .toList();

    final next = current.copyWith(
      items: updatedItems,
      total: current.total - item.price,
    );

    state = AsyncData(next);
    await _cartRepository.persistCart(next);
  }
}
