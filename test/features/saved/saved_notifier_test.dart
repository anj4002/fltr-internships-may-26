import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_shop/features/cart/data/models/cart_item.dart';
import 'package:flutter_shop/features/saved/data/models/saved_item.dart';
import 'package:flutter_shop/features/saved/data/saved_repository.dart';
import 'package:flutter_shop/features/saved/providers/saved_providers.dart';

class MockSavedRepository extends Mock implements SavedRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CartItem(
      productId: '',
      name: '',
      price: 0,
      imageUrl: '',
    ));
  });

  late ProviderContainer container;
  late MockSavedRepository mockRepo;

  const testCartItem = CartItem(
    productId: 's1',
    name: 'Saved Headphones',
    price: 25.00,
    imageUrl: 'https://example.com/img.jpg',
  );

  const expectedSavedItem = SavedItem(
    productId: 's1',
    name: 'Saved Headphones',
    price: 25.00,
    imageUrl: 'https://example.com/img.jpg',
  );

  setUp(() {
    mockRepo = MockSavedRepository();
    when(() => mockRepo.getSavedItems()).thenReturn([]);
    when(() => mockRepo.saveItem(any())).thenAnswer((_) async {});
    when(() => mockRepo.removeItem(any())).thenAnswer((_) async {});
    when(() => mockRepo.moveToCart(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        savedRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('SavedNotifier', () {
    test('loads saved items from repository on init', () async {
      when(() => mockRepo.getSavedItems()).thenReturn([expectedSavedItem]);

      // Re-create container after stubbing the return value.
      container.dispose();
      container = ProviderContainer(
        overrides: [savedRepositoryProvider.overrideWithValue(mockRepo)],
      );

      final state = await container.read(savedNotifierProvider.future);
      expect(state.length, 1);
      expect(state.first.productId, 's1');
    });

    test('saveForLater adds the item to state', () async {
      await container.read(savedNotifierProvider.future);
      await container
          .read(savedNotifierProvider.notifier)
          .saveForLater(testCartItem);

      final state = container.read(savedNotifierProvider).requireValue;
      expect(state.length, 1);
      expect(state.first.productId, 's1');
      expect(state.first.price, 25.00);
    });

    test('saveForLater does not add a duplicate product', () async {
      await container.read(savedNotifierProvider.future);
      await container
          .read(savedNotifierProvider.notifier)
          .saveForLater(testCartItem);
      await container
          .read(savedNotifierProvider.notifier)
          .saveForLater(testCartItem);

      final state = container.read(savedNotifierProvider).requireValue;
      expect(state.length, 1);
    });

    test(
      'TODO: removeFromSaved removes the item from state',
      () async {
        // Save an item, then call removeFromSaved and verify the list is empty.
      },
      skip: 'Task 4 — removeFromSaved not yet implemented',
    );

    test(
      'TODO: moveToCart removes item from saved and adds it to cart',
      () async {
        // Save an item, call moveToCart, verify:
        //   - saved list is empty
        //   - cart contains the item
      },
      skip: 'Task 4 — moveToCart not yet implemented',
    );

    test(
      'TODO: saved items persist across app restarts',
      () async {
        // Save an item, re-create the container, verify the item is still present.
      },
      skip: 'Task 5 — persistence not yet tested',
    );
  });
}
