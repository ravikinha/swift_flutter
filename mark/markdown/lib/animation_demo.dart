import 'package:flutter/material.dart';
import 'package:swift_flutter/core/extensions.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Interactive animation demo component for the learning guide
/// This component allows users to see and interact with animations in real-time
class AnimationDemo extends StatefulWidget {
  final String title;
  final Widget Function() builder;

  const AnimationDemo({super.key, required this.title, required this.builder});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252526) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF007ACC), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2D2D30)
                    : const Color(0xFFF3F3F3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: const Color(0xFF007ACC),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark
                        ? const Color(0xFFCCCCCC)
                        : const Color(0xFF424242),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(24),
              child: widget.builder(),
            ),
        ],
      ),
    );
  }
}

/// Pre-built animation demos for the learning guide
class AnimationDemos {
  /// Fade In Demo
  static Widget fadeInDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fade In Animation',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ).animate().fadeIn().duration(1.s),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .fadeIn()\n  .duration(1.s)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }

  /// Scale Demo
  static Widget scaleDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scale Animation',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.green,
          ).animate().scale(1.5).duration(1.s),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .scale(1.5)\n  .duration(1.s)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }

  /// Combined Demo
  static Widget combinedDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Combined Animations',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.purple,
          ).animate().fadeIn().scale(1.2).rotate(180).duration(1.5.s),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .fadeIn()\n  .scale(1.2)\n  .rotate(180)\n  .duration(1.5.s)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }

  /// Bounce Demo
  static Widget bounceDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bounce Animation',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ).animate().bounce().scale(1.3).duration(800.ms),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .bounce()\n  .scale(1.3)\n  .duration(800.ms)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }

  /// Repeat Demo
  static Widget repeatDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeating Animation',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.teal,
          ).animate().scale(1.3).repeat(reverse: true).duration(800.ms),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .scale(1.3)\n  .repeat(reverse: true)\n  .duration(800.ms)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }

  /// Interactive Demo
  static Widget interactiveDemo() {
    return _InteractiveAnimationDemo();
  }
}

class _InteractiveAnimationDemo extends StatefulWidget {
  @override
  State<_InteractiveAnimationDemo> createState() =>
      _InteractiveAnimationDemoState();
}

class _InteractiveAnimationDemoState extends State<_InteractiveAnimationDemo> {
  bool _isExpanded = false;
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactive Animation (Tap to Toggle)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded.toggle;
                _tapCount.add(1);
              });
            },
            child:
                Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Tap! ($_tapCount)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(_isExpanded ? 1.5 : 1.0)
                    .rotate(_isExpanded ? 180 : 0)
                    .duration(300.ms)
                    .curve(Curves.easeInOut),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Code:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Container(...)\n  .animate()\n  .scale(isExpanded ? 1.5 : 1.0)\n  .rotate(isExpanded ? 180 : 0)\n  .duration(300.ms)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD7BA7D),
            ),
          ),
        ),
      ],
    );
  }
}
