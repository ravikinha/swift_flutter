import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/view_interceptor.dart';

void main() {
  group('SwiftViewInterceptor', () {
    tearDown(() {
      SwiftViewInterceptor.disable();
      SwiftViewInterceptor.setContext(null);
    });

    test('should be disabled by default', () {
      expect(SwiftViewInterceptor.isEnabled, false);
    });

    test('should enable view interception', () {
      SwiftViewInterceptor.enable();
      expect(SwiftViewInterceptor.isEnabled, true);
    });

    test('should disable view interception', () {
      SwiftViewInterceptor.enable();
      SwiftViewInterceptor.disable();
      expect(SwiftViewInterceptor.isEnabled, false);
    });

    test('should set and clear context', () {
      // Note: We can't easily test BuildContext in unit tests
      // This test just verifies the methods exist and don't throw
      SwiftViewInterceptor.setContext(null);
      expect(SwiftViewInterceptor.canShowDebugPage(), false);
    });

    test('should check if debug page can be shown', () {
      expect(SwiftViewInterceptor.canShowDebugPage(), false);
      
      SwiftViewInterceptor.enable();
      expect(SwiftViewInterceptor.canShowDebugPage(), false); // Still false without context
    });
  });
}

