import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/storage_service.dart';
import 'cart_state.dart';
import 'models/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(storageServiceProvider));
});

class CartRepository {
  final StorageService _storage;

  CartRepository(this._storage);

  CartState loadCart() {
    final raw = _storage.getString(AppConstants.cartStorageKey);
    if (raw == null) return const CartState();
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final total =
          items.fold<double>(0.0, (sum, i) => sum + i.price * i.quantity);
      return CartState(items: items, total: total);
    } catch (_) {
      return const CartState();
    }
  }

  /// Persists the cart to local storage.
  /// Has an artificial delay to simulate async I/O — this delay is
  /// intentional and relevant to how state mutations are ordered.
  Future<void> persistCart(CartState cart) async {
    await Future.delayed(AppConstants.persistDelay);
    final encoded = jsonEncode(cart.items.map((e) => e.toJson()).toList());
    await _storage.setString(AppConstants.cartStorageKey, encoded);
  }
}
