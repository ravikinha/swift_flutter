import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/lifecycle.dart';

void main() {
  group('LifecycleController', () {
    test('should start in initializing state', () {
      final lifecycle = LifecycleController();
      expect(lifecycle.state, LifecycleState.initializing);
      expect(lifecycle.isInitialized, false);
    });

    test('should transition to initialized', () {
      final lifecycle = LifecycleController();
      lifecycle.initialize();
      expect(lifecycle.state, LifecycleState.initialized);
      expect(lifecycle.isInitialized, true);
    });

    test('should activate', () {
      final lifecycle = LifecycleController();
      lifecycle.initialize();
      lifecycle.activate();
      expect(lifecycle.state, LifecycleState.active);
      expect(lifecycle.isActive, true);
    });

    test('should deactivate', () {
      final lifecycle = LifecycleController();
      lifecycle.initialize();
      lifecycle.activate();
      lifecycle.deactivate();
      expect(lifecycle.state, LifecycleState.inactive);
    });

    test('should pause and resume', () {
      final lifecycle = LifecycleController();
      lifecycle.initialize();
      lifecycle.activate();
      lifecycle.pause();
      expect(lifecycle.state, LifecycleState.paused);
      
      lifecycle.resume();
      expect(lifecycle.state, LifecycleState.resumed);
    });

    test('should store and retrieve data', () {
      final lifecycle = LifecycleController();
      lifecycle.setData('key', 'value');
      expect(lifecycle.getData<String>('key'), 'value');
    });

    test('should remove data', () {
      final lifecycle = LifecycleController();
      lifecycle.setData('key', 'value');
      lifecycle.removeData('key');
      expect(lifecycle.getData('key'), null);
    });

    test('should dispose', () {
      final lifecycle = LifecycleController();
      lifecycle.initialize();
      lifecycle.startDisposing();
      lifecycle.dispose();
      expect(lifecycle.state, LifecycleState.disposed);
      expect(lifecycle.isDisposed, true);
    });
  });
}

