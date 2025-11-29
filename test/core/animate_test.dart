import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swift_flutter/core/animate.dart';

void main() {
  group('DurationShorthand', () {
    test('should parse milliseconds string', () {
      final shorthand = DurationShorthand.parse('.500ms');
      expect(shorthand.duration, const Duration(milliseconds: 500));
    });

    test('should parse seconds string', () {
      // Note: ".5s" is parsed as 5 seconds (leading dot is stylistic)
      // For 0.5 seconds, use "0.5s" or 0.5.s
      final shorthand = DurationShorthand.parse('0.5s');
      expect(shorthand.duration, const Duration(milliseconds: 500));
    });

    test('should parse minutes string', () {
      // Note: ".5m" is parsed as 5 minutes (leading dot is stylistic)
      // For 0.5 minutes, use "0.5m" or 0.5.m
      final shorthand = DurationShorthand.parse('0.5m');
      expect(shorthand.duration, const Duration(milliseconds: 30000));
    });

    test('should parse without leading dot', () {
      final shorthand = DurationShorthand.parse('500ms');
      expect(shorthand.duration, const Duration(milliseconds: 500));
    });

    test('should create from number extensions', () {
      expect(500.ms.duration, const Duration(milliseconds: 500));
      expect(0.5.s.duration, const Duration(milliseconds: 500));
      expect(1.m.duration, const Duration(minutes: 1));
    });
  });

  group('AnimateExtension', () {
    test('should create AnimatedWidgetBuilder from widget', () {
      final widget = Container();
      final builder = widget.animate();
      
      expect(builder, isA<AnimatedWidgetBuilder>());
      expect(builder.child, widget);
    });
  });

  group('AnimatedWidgetBuilder', () {
    test('should chain scale animation', () {
      final widget = Container();
      final builder = widget.animate().scale(1.5);
      
      expect(builder.config.scale, 1.5);
      expect(builder.config.scaleX, isNull);
      expect(builder.config.scaleY, isNull);
    });

    test('should chain scaleX and scaleY separately', () {
      final widget = Container();
      final builder = widget.animate().scaleX(1.2).scaleY(1.5);
      
      expect(builder.config.scaleX, 1.2);
      expect(builder.config.scaleY, 1.5);
    });

    test('should chain fadeIn animation', () {
      final widget = Container();
      final builder = widget.animate().fadeIn();
      
      expect(builder.config.opacity, 1.0);
    });

    test('should chain fadeOut animation', () {
      final widget = Container();
      final builder = widget.animate().fadeOut();
      
      expect(builder.config.opacity, 0.0);
    });

    test('should chain custom opacity', () {
      final widget = Container();
      final builder = widget.animate().opacity(0.5);
      
      expect(builder.config.opacity, 0.5);
    });

    test('should clamp opacity values', () {
      final widget = Container();
      final builder1 = widget.animate().opacity(-1.0);
      final builder2 = widget.animate().opacity(2.0);
      
      expect(builder1.config.opacity, 0.0);
      expect(builder2.config.opacity, 1.0);
    });

    test('should chain slideX and slideY', () {
      final widget = Container();
      final builder = widget.animate().slideX(50).slideY(100);
      
      expect(builder.config.translateX, 50);
      expect(builder.config.translateY, 100);
    });

    test('should chain slideInTop', () {
      final widget = Container();
      final builder = widget.animate().slideInTop();
      
      expect(builder.config.slideIn, SlideDirection.top);
    });

    test('should chain slideInBottom', () {
      final widget = Container();
      final builder = widget.animate().slideInBottom();
      
      expect(builder.config.slideIn, SlideDirection.bottom);
    });

    test('should chain slideInLeft', () {
      final widget = Container();
      final builder = widget.animate().slideInLeft();
      
      expect(builder.config.slideIn, SlideDirection.left);
    });

    test('should chain slideInRight', () {
      final widget = Container();
      final builder = widget.animate().slideInRight();
      
      expect(builder.config.slideIn, SlideDirection.right);
    });

    test('should chain rotate animation', () {
      final widget = Container();
      final builder = widget.animate().rotate(360);
      
      expect(builder.config.rotate, 360);
    });

    test('should chain fadeInScale', () {
      final widget = Container();
      final builder = widget.animate().fadeInScale(1.5);
      
      expect(builder.config.opacity, 1.0);
      expect(builder.config.scale, 1.5);
    });

    test('should chain bounce animation', () {
      final widget = Container();
      final builder = widget.animate().bounce();
      
      expect(builder.config.bounce, true);
    });

    test('should chain pulse animation', () {
      final widget = Container();
      final builder = widget.animate().pulse();
      
      expect(builder.config.pulse, true);
    });

    test('should chain duration', () {
      final widget = Container();
      final duration = const Duration(seconds: 2);
      final builder = widget.animate().duration(duration);
      
      expect(builder.config.duration, duration);
    });

    test('should chain duration with string shorthand', () {
      final widget = Container();
      final builder = widget.animate().duration('0.5s');
      
      expect(builder.config.duration, const Duration(milliseconds: 500));
    });

    test('should chain duration with number shorthand', () {
      final widget = Container();
      final builder = widget.animate().duration(500.ms);
      
      expect(builder.config.duration, const Duration(milliseconds: 500));
    });

    test('should chain delay', () {
      final widget = Container();
      final delay = const Duration(milliseconds: 500);
      final builder = widget.animate().delay(delay);
      
      expect(builder.config.delay, delay);
    });

    test('should chain delay with string shorthand', () {
      final widget = Container();
      final builder = widget.animate().delay('0.5s');
      
      expect(builder.config.delay, const Duration(milliseconds: 500));
    });

    test('should chain delay with number shorthand', () {
      final widget = Container();
      final builder = widget.animate().delay(500.ms);
      
      expect(builder.config.delay, const Duration(milliseconds: 500));
    });

    test('should chain curve', () {
      final widget = Container();
      final curve = Curves.bounceOut;
      final builder = widget.animate().curve(curve);
      
      expect(builder.config.curve, curve);
    });

    test('should chain repeat without reverse', () {
      final widget = Container();
      final builder = widget.animate().repeat();
      
      expect(builder.config.repeat, true);
      expect(builder.config.reverse, false);
    });

    test('should chain repeat with reverse', () {
      final widget = Container();
      final builder = widget.animate().repeat(reverse: true);
      
      expect(builder.config.repeat, true);
      expect(builder.config.reverse, true);
    });

    test('should chain repeatCount', () {
      final widget = Container();
      final builder = widget.animate().repeatCount(5);
      
      expect(builder.config.repeat, true);
      expect(builder.config.repeatCount, 5);
    });

    test('should chain repeatCount with reverse', () {
      final widget = Container();
      final builder = widget.animate().repeatCount(3, reverse: true);
      
      expect(builder.config.repeat, true);
      expect(builder.config.repeatCount, 3);
      expect(builder.config.reverse, true);
    });

    test('should chain persist', () {
      final widget = Container();
      final builder = widget.animate().persist();
      
      expect(builder.config.persist, true);
    });

    test('should chain multiple animations', () {
      final widget = Container();
      final builder = widget
          .animate()
          .scale(1.5)
          .fadeIn()
          .rotate(180)
          .duration(const Duration(seconds: 1))
          .curve(Curves.easeInOut)
          .repeat(reverse: true);
      
      expect(builder.config.scale, 1.5);
      expect(builder.config.opacity, 1.0);
      expect(builder.config.rotate, 180);
      expect(builder.config.duration, const Duration(seconds: 1));
      expect(builder.config.curve, Curves.easeInOut);
      expect(builder.config.repeat, true);
      expect(builder.config.reverse, true);
    });

    test('should be usable as Widget', () {
      final widget = Container();
      final animated = widget.animate().fadeIn().scale(1.2);
      
      // Should be able to use directly in widget tree
      expect(animated, isA<Widget>());
      expect(animated.build, isA<Widget Function(BuildContext)>());
    });
  });

  group('AnimationConfig', () {
    test('should have default values', () {
      final config = AnimationConfig();
      
      expect(config.scale, isNull);
      expect(config.opacity, isNull);
      expect(config.duration, const Duration(milliseconds: 300));
      expect(config.delay, Duration.zero);
      expect(config.curve, Curves.easeInOut);
      expect(config.repeat, false);
      expect(config.reverse, false);
      expect(config.persist, false);
      expect(config.bounce, false);
      expect(config.pulse, false);
    });

    test('should copyWith values', () {
      final config = AnimationConfig();
      final newConfig = config.copyWith(
        scale: 1.5,
        opacity: 0.5,
        duration: const Duration(seconds: 2),
      );
      
      expect(newConfig.scale, 1.5);
      expect(newConfig.opacity, 0.5);
      expect(newConfig.duration, const Duration(seconds: 2));
      expect(newConfig.delay, Duration.zero); // Should keep original
    });
  });

  group('Widget Integration', () {
    testWidgets('should render animated widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ).animate().fadeIn(),
          ),
        ),
      );
      
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should render with multiple animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            )
                .animate()
                .fadeIn()
                .scale(1.2)
                .duration(const Duration(milliseconds: 500)),
          ),
        ),
      );
      
      expect(find.byType(Container), findsOneWidget);
      
      // Allow animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

