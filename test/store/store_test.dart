import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/store/store.dart';
import 'package:swift_flutter/store/middleware.dart';
import 'package:swift_flutter/core/rx.dart';

void main() {
  group('Store', () {
    setUp(() {
      store.clear();
    });

    test('should register and get service', () {
      final service = _TestService();
      store.register<_TestService>(service);
      
      expect(store.has<_TestService>(), true);
      expect(store.get<_TestService>(), service);
    });

    test('should throw if service not found', () {
      expect(() => store.get<_TestService>(), throwsStateError);
    });

    test('should unregister service', () {
      final service = _TestService();
      store.register<_TestService>(service);
      store.unregister<_TestService>();
      
      expect(store.has<_TestService>(), false);
    });

    test('should register and get state', () {
      final state = Rx<int>(42);
      store.registerState('counter', state);
      
      expect(store.hasState('counter'), true);
      expect(store.getState<int>('counter'), state);
    });

    test('should throw if state not found', () {
      expect(() => store.getState<int>('missing'), throwsStateError);
    });

    test('should dispatch action through middleware', () async {
      final middleware = _TestMiddleware();
      store.addMiddleware(middleware);
      
      final action = _TestAction('test', {}, () async => 'result');
      final result = await store.dispatch<String>(action);
      
      expect(result, 'result');
      expect(middleware.beforeCalled, true);
      expect(middleware.afterCalled, true);
    });
  });
}

class _TestService {}

class _TestMiddleware extends Middleware {
  bool beforeCalled = false;
  bool afterCalled = false;

  @override
  Future<Action?> before(Action action) async {
    beforeCalled = true;
    return action;
  }

  @override
  Future<void> after(Action action, dynamic result) async {
    afterCalled = true;
  }
}

class _TestAction implements Action {
  @override
  final String type;
  @override
  final Map<String, dynamic> payload;
  final Future<dynamic> Function() _execute;

  _TestAction(this.type, this.payload, this._execute);

  @override
  Future<dynamic> execute() => _execute();
}

