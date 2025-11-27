import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/animation.dart';
import 'package:swift_flutter/core/tween.dart';

void main() {
  group('SwiftTween', () {
    test('should initialize with progress', () {
      final tween = TweenHelper.doubleTween(begin: 0.0, end: 100.0);
      expect(tween.progress, 0.0);
      expect(tween.value, 0.0);
    });

    test('should interpolate values', () {
      final tween = TweenHelper.doubleTween(begin: 0.0, end: 100.0);
      tween.progress = 0.5;
      expect(tween.value, 50.0);
    });

    test('should clamp progress', () {
      final tween = TweenHelper.doubleTween(begin: 0.0, end: 100.0);
      tween.progress = 1.5; // Should clamp to 1.0
      expect(tween.progress, 1.0);
      expect(tween.value, 100.0);
    });

    test('should animate to target', () async {
      final tween = TweenHelper.doubleTween(begin: 0.0, end: 100.0);
      await tween.animateTo(1.0, duration: Duration(milliseconds: 100));
      expect(tween.progress, closeTo(1.0, 0.1));
      expect(tween.value, closeTo(100.0, 10.0));
    });

    test('should create int tween', () {
      final tween = TweenHelper.intTween(begin: 0, end: 100);
      tween.progress = 0.5;
      expect(tween.value, 50);
    });

    test('should create color tween', () {
      final tween = TweenHelper.colorTween(
        begin: const Color(0xFF000000),
        end: const Color(0xFFFFFFFF),
      );
      tween.progress = 0.5;
      expect(tween.value, isA<Color>());
    });
  });
}

