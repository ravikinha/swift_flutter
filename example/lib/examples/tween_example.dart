import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Animation Tween Example
class TweenExample extends StatefulWidget {
  const TweenExample({super.key});

  @override
  State<TweenExample> createState() => _TweenExampleState();
}

class _TweenExampleState extends State<TweenExample> {
  // SwiftTween is a specialized class for reactive animations
  // It manages tween interpolation with reactive progress
  late final SwiftTween<double> sizeTween;
  late final SwiftTween<Color?> colorTween;

  @override
  void initState() {
    super.initState();
    sizeTween = TweenHelper.doubleTween(begin: 50.0, end: 200.0);
    colorTween = TweenHelper.colorTween(
      begin: Colors.blue,
      end: Colors.purple,
    );
  }

  @override
  void dispose() {
    sizeTween.dispose();
    colorTween.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mark(
          builder: (context) => Center(
            child: Container(
              width: sizeTween.value,
              height: sizeTween.value,
              decoration: BoxDecoration(
                color: colorTween.value,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => sizeTween.animateTo(1.0),
              child: const Text('Animate Size'),
            ),
            ElevatedButton(
              onPressed: () => colorTween.animateTo(1.0),
              child: const Text('Animate Color'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Mark(
          builder: (context) => Slider(
            value: sizeTween.progress,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => sizeTween.progress = v,
          ),
        ),
        Mark(
          builder: (context) => Text('Progress: ${(sizeTween.progress * 100).toStringAsFixed(0)}%'),
        ),
      ],
    );
  }
}

