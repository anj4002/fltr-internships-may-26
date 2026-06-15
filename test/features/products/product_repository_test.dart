import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_shop/features/products/data/product_repository.dart';

void main() {
  group('ProductRepository', () {
    late ProductRepository repo;

    setUp(() {
      repo = ProductRepository();
    });

    test('fetchProducts returns a non-empty list for page 0', () async {
      // Retries up to 5 times to account for the 5% simulated failure rate.
      List<dynamic>? products;
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          products = await repo.fetchProducts(page: 0);
          break;
        } catch (_) {}
      }
      expect(products, isNotNull);
      expect(products!.length, greaterThan(0));
    });

    test('fetchProducts returns an empty list for an out-of-range page',
        () async {
      List<dynamic>? products;
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          products = await repo.fetchProducts(page: 99);
          break;
        } catch (_) {}
      }
      expect(products, isNotNull);
      expect(products!, isEmpty);
    });

    test('fetchProducts supports pagination: page 1 is empty with 10 products',
        () async {
      List<dynamic> page0 = [];
      List<dynamic> page1 = [];
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          page0 = await repo.fetchProducts(page: 0);
          page1 = await repo.fetchProducts(page: 1);
          break;
        } catch (_) {}
      }
      // Catalogue has exactly 10 items and page size is 10, so page 1 is empty.
      expect(page0, isNotEmpty);
      expect(page1, isEmpty);
    });
  });
}
