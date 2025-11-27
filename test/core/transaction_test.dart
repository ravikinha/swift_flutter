import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:swift_flutter/core/transaction.dart';

void main() {
  group('Transaction', () {
    test('should batch notifications', () {
      final notifier = _TestNotifier();
      var notificationCount = 0;
      notifier.addListener(() => notificationCount++);
      
      Transaction.run(() {
        notifier.trigger();
        notifier.trigger();
        notifier.trigger();
        expect(notificationCount, 0); // No notifications during transaction
      });
      
      expect(notificationCount, 1); // Only one notification after transaction
    });

    test('should return value from transaction', () {
      final result = Transaction.run(() => 42);
      expect(result, 42);
    });

    test('should handle nested transactions', () {
      final notifier = _TestNotifier();
      var notificationCount = 0;
      notifier.addListener(() => notificationCount++);
      
      Transaction.run(() {
        Transaction.run(() {
          notifier.trigger();
        });
        notifier.trigger();
        expect(notificationCount, 0); // No notifications during transaction
      });
      
      expect(notificationCount, 1); // Only one notification after all transactions complete
    });

    test('should check if in transaction', () {
      expect(Transaction.isActive, false);
      
      Transaction.run(() {
        expect(Transaction.isActive, true);
      });
      
      expect(Transaction.isActive, false);
    });
  });
}

class _TestNotifier extends ChangeNotifier {
  void trigger() {
    notifyListenersTransaction();
  }
}

