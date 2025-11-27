import 'package:flutter/foundation.dart';

/// Transaction context for batching multiple updates
class Transaction {
  static bool _inTransaction = false;
  static final Set<ChangeNotifier> _pendingNotifiers = {};
  static int _transactionDepth = 0;

  /// Runs a function within a transaction (batches notifications)
  static T run<T>(T Function() fn) {
    _transactionDepth++;
    final wasInTransaction = _inTransaction;
    _inTransaction = true;

    try {
      return fn();
    } finally {
      _transactionDepth--;
      if (_transactionDepth == 0) {
        _inTransaction = false;
        _flushPending();
      } else if (!wasInTransaction) {
        _inTransaction = false;
      }
    }
  }

  /// Checks if currently in a transaction
  static bool get isActive => _inTransaction;

  /// Schedules a notification for a notifier to be sent after transaction completes.
  ///
  /// Uses Set to deduplicate - same notifier will only notify once per transaction.
  static void scheduleNotificationFor(ChangeNotifier notifier) {
    if (_inTransaction) {
      _pendingNotifiers.add(notifier);
    } else {
      // Direct call is safe here as we're calling on the instance
      notifier.notifyListeners();
    }
  }

  static void _flushPending() {
    final notifiers = List<ChangeNotifier>.from(_pendingNotifiers);
    _pendingNotifiers.clear();
    for (final notifier in notifiers) {
      // Direct call is safe here as we're calling on the instance
      notifier.notifyListeners();
    }
  }
}

/// Extension to make ChangeNotifier transaction-aware.
///
/// This extension adds the [notifyListenersTransaction] method which
/// respects transaction context and batches notifications.
extension TransactionNotifier on ChangeNotifier {
  /// Notifies listeners, respecting transaction context.
  ///
  /// Batches notifications - same notifier will only notify once per transaction.
  /// This is safe to use as it's an extension method on ChangeNotifier.
  void notifyListenersTransaction() {
    if (Transaction.isActive) {
      Transaction.scheduleNotificationFor(this);
    } else {
      // Safe to call notifyListeners from extension method
      notifyListeners();
    }
  }
}

