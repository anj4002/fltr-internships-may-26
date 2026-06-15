import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product.dart';
import '../data/product_repository.dart';

final productPageProvider = StateProvider<int>((ref) => 0);

final productListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final page = ref.watch(productPageProvider);
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProducts(page: page);
});
