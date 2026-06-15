import 'dart:async';

/// A utility to debounce rapid successive function calls.
///
/// Exists in the codebase but is not currently wired up.
/// Consider where rapid user actions cause unexpected behaviour.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
