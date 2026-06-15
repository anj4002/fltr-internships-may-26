# Flutter Shop — Technical Assessment

A Flutter e-commerce application used as a skills assessment. The codebase is
intentionally close to a real production codebase: it compiles, runs, and mostly
works — but contains a handful of known issues for you to find and fix.

---

## Setup

```bash
# Install dependencies
flutter pub get

# Generate freezed / json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test
```

Requirements: Flutter stable channel, Dart ≥ 3.3.

---

## Architecture

The project follows a **feature-first** structure:

```
lib/
├── core/            # Constants, error types, shared utilities
├── features/
│   ├── products/    # Product catalogue (data, providers, UI)
│   ├── cart/        # Shopping cart (data, providers, UI)
│   └── saved/       # Save-for-later (partially implemented)
├── services/        # StorageService (SharedPreferences wrapper)
├── routing/         # go_router navigation
└── main.dart
```

Each feature owns its own:
- **data layer** — repository + freezed models
- **providers** — Riverpod `AsyncNotifier` for state management
- **presentation** — screens and widgets

Shared infrastructure lives in `lib/core/` and `lib/services/`.

Navigation uses `go_router` with `StatefulShellRoute` for a bottom navigation
bar that preserves each tab's navigator stack independently.

---

## Your Tasks

### Task 1 — Incorrect quantity when tapping "+" rapidly

**Symptom:** Users report that tapping the "+" button on a cart item several
times in quick succession results in a lower quantity than expected. For example,
tapping "+" three times sometimes only increments by one.

Investigate `CartNotifier.incrementQuantity` and fix the root cause.

---

### Task 2 — Cart total is wrong after certain operations

**Symptom:** The displayed cart total occasionally does not match the sum of
`(price × quantity)` for all items. In some cases it goes negative. The issue
appears after changing quantities and then removing items.

Investigate how `CartState.total` is maintained across operations and fix the
root cause.

---

### Task 3 — Quantity changes are lost after restarting the app

**Symptom:** Adding a new item to the cart persists correctly across restarts.
However, increasing or decreasing the quantity of an existing item is lost when
the app is killed and relaunched — the quantity always resets.

Investigate which cart operations call the persistence layer and fix the gap.

---

### Task 4 — Complete the Save For Later feature

The "Save for later" flow is roughly 40% implemented. The bookmark button on
each product card already works and items appear in the Saved tab. However, the
following functionality is missing:

- **Remove from saved** — users cannot remove an item from the saved list.
- **Move to cart** — users cannot move a saved item back into the cart.

Implement the missing functionality by following the existing patterns. Relevant
files to complete:

- `lib/features/saved/data/saved_repository.dart` — `removeItem`, `moveToCart`
- `lib/features/saved/providers/saved_providers.dart` — `removeFromSaved`, `moveToCart`
- `lib/features/saved/presentation/widgets/saved_item_tile.dart` — action buttons

The repository and notifier layers should stay in separate domains.

---

### Task 5 — Fill in the missing tests

Several tests in `test/features/` are marked `skip`. After fixing the bugs above,
remove the skip annotations and implement the test bodies. Use the existing
passing tests as a guide for structure and mocking patterns.

Files:
- `test/features/cart/cart_notifier_test.dart`
- `test/features/saved/saved_notifier_test.dart`

---

## Evaluation Notes

- Do not change the overall architecture or swap dependencies.
- All fixes should be minimal and targeted — avoid unrelated refactors.
- Code style should match the existing codebase.
- Tests should cover both the happy path and relevant edge cases.
