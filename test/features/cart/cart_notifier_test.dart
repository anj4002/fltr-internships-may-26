import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_shop/features/cart/data/cart_repository.dart';
import 'package:flutter_shop/features/cart/data/cart_state.dart';
import 'package:flutter_shop/features/cart/data/models/cart_item.dart';
import 'package:flutter_shop/features/cart/providers/cart_providers.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CartState());
  });

  late ProviderContainer container;
  late MockCartRepository mockRepo;

  const testItem = CartItem(
    productId: 'p1',
    name: 'Test Headphones',
    price: 10.00,
    imageUrl: 'https://example.com/img.jpg',
  );

  const testItem2 = CartItem(
    productId: 'p2',
    name: 'Test Keyboard',
    price: 20.00,
    imageUrl: 'https://example.com/img2.jpg',
  );

  setUp(() {
    mockRepo = MockCartRepository();
    when(() => mockRepo.loadCart()).thenReturn(const CartState());
    when(() => mockRepo.persistCart(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('CartNotifier', () {
    test('initial state is empty', () async {
      final state = await container.read(cartNotifierProvider.future);
      expect(state.items, isEmpty);
      expect(state.total, 0.0);
    });

    test('addItem adds a new product to the cart', () async {
      await container.read(cartNotifierProvider.future);
      await container.read(cartNotifierProvider.notifier).addItem(testItem);

      final state = container.read(cartNotifierProvider).requireValue;
      expect(state.items.length, 1);
      expect(state.items.first.productId, 'p1');
      expect(state.items.first.quantity, 1);
    });

    test('addItem with an existing productId increases quantity, not count',
        () async {
      await container.read(cartNotifierProvider.future);
      await container.read(cartNotifierProvider.notifier).addItem(testItem);
      await container.read(cartNotifierProvider.notifier).addItem(testItem);

      final state = container.read(cartNotifierProvider).requireValue;
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
    });

    test('removeItem removes the item from the cart', () async {
      await container.read(cartNotifierProvider.future);
      await container.read(cartNotifierProvider.notifier).addItem(testItem);
      await container.read(cartNotifierProvider.notifier).removeItem('p1');

      final state = container.read(cartNotifierProvider).requireValue;
      expect(state.items, isEmpty);
    });

    test('addItem updates total correctly for new items', () async {
      await container.read(cartNotifierProvider.future);
      await container.read(cartNotifierProvider.notifier).addItem(testItem);
      await container.read(cartNotifierProvider.notifier).addItem(testItem2);

      final state = container.read(cartNotifierProvider).requireValue;
      expect(state.total, closeTo(30.0, 0.01));
    });

    test(
      'TODO: rapid incrementQuantity calls should result in the correct quantity',
      () async {
        // When incrementQuantity is called 3 times in quick succession,
        // the final quantity should be 4 (1 initial + 3 increments).
        // Currently fails because incrementQuantity captures a stale item
        // reference before awaiting the persist call (Bug #1).
        await container.read(cartNotifierProvider.future);

        await container.read(cartNotifierProvider.notifier).addItem(testItem);

        await Future.wait([
          container.read(cartNotifierProvider.notifier).incrementQuantity("p1"),
          container.read(cartNotifierProvider.notifier).incrementQuantity("p2"),
          container.read(cartNotifierProvider.notifier).incrementQuantity("p1"),
        ]);

        final state =
        container.read(cartNotifierProvider).requireValue;

    expect(state.items.first.quantity, 4);
      },
    );

    test(
      'TODO: total should reflect quantity after incrementQuantity',
      () async {
        // Add item at \$10, increment twice → expect total == \$30.
        // Currently fails because incrementQuantity does not update the
        // cached `total` field on CartState (Bug #2).

        await container.read(cartNotifierProvider.future);
        await container.read(cartNotifierProvider.notifier).addItem(testItem);

        await container.read(cartNotifierProvider.notifier).incrementQuantity('p1');

        await container.read(cartNotifierProvider.notifier).incrementQuantity('p1');

        final state =
        container.read(cartNotifierProvider).requireValue;

    expect(state.total, closeTo(30.0, 0.01));
      },
    );

    test(
      'TODO: total should not go negative after incrementing then removing',
      () async {
        // Add item at \$10, increment to quantity 3, then remove.
        // Expected total: \$0.00.
        // Currently total drifts negative because removeItem subtracts
        // price × quantity but `total` was never updated during increments (Bug #2).
        await container.read(cartNotifierProvider.future);

        await container.read(cartNotifierProvider.notifier).addItem(testItem);

        await container .read(cartNotifierProvider.notifier).incrementQuantity('p1');

        await container.read(cartNotifierProvider.notifier).incrementQuantity('p1');

        await container.read(cartNotifierProvider.notifier).removeItem('p1');

        final state =container.read(cartNotifierProvider).requireValue;

        expect(state.total, 0.0);
      },
    );

    test(
      'TODO: quantity changes should survive an app restart',
      () async {
        // After calling incrementQuantity, re-create the ProviderContainer
        // (simulating a restart) and verify the persisted quantity is correct.
        // Currently fails because incrementQuantity never calls persistCart
        // after updating state (Bug #3).
         CartState persistedState = const CartState();

         when(() => mockRepo.persistCart(any())).thenAnswer((invocation) async {
          persistedState = invocation.positionalArguments.first as CartState;
        });

        when(() => mockRepo.loadCart()).thenAnswer((_) => persistedState);

        await container.read(cartNotifierProvider.future);

         await container.read(cartNotifierProvider.notifier).addItem(testItem);

          await container
              .read(cartNotifierProvider.notifier)
              .incrementQuantity('p1');

          final restartedContainer = ProviderContainer(
            overrides: [
              cartRepositoryProvider.overrideWithValue(mockRepo),
            ],
          );

          addTearDown(restartedContainer.dispose);

          final restartedState =
              await restartedContainer.read(cartNotifierProvider.future);

          expect(restartedState.items.length, 1);
          expect(restartedState.items.first.quantity, 2);

      },
    );
  });
}
