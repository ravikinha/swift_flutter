import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'rx.dart';
import '../ui/mark.dart';

/// Reactive tween that animates between values
class RxTween<T> extends ChangeNotifier {
  final Tween<T> _tween;
  final Rx<double> _progress;
  T? _currentValue;

  RxTween(this._tween, {double initialProgress = 0.0})
      : _progress = Rx(initialProgress.clamp(0.0, 1.0)) {
    _progress.addListener(_updateValue);
    _updateValue();
  }

  /// Current progress (0.0 to 1.0)
  double get progress {
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(_progress);
    }
    return _progress.value;
  }

  set progress(double value) {
    _progress.value = value.clamp(0.0, 1.0);
  }

  /// Current interpolated value
  T get value {
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(_progress);
    }
    return _currentValue!;
  }

  void _updateValue() {
    final newValue = _tween.lerp(_progress.value);
    if (_currentValue != newValue) {
      _currentValue = newValue;
      notifyListeners();
    }
  }

  /// Animate to a target progress value
  Future<void> animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final start = _progress.value;
    final end = target.clamp(0.0, 1.0);
    final startTime = DateTime.now().millisecondsSinceEpoch;

    while (true) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = (now - startTime) / duration.inMilliseconds;

      if (elapsed >= 1.0) {
        _progress.value = end;
        break;
      }

      final curved = curve.transform(elapsed);
      _progress.value = start + (end - start) * curved;

      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  @override
  void dispose() {
    _progress.removeListener(_updateValue);
    _progress.dispose();
    super.dispose();
  }
}

/// Helper for creating common tweens
class TweenHelper {
  static RxTween<double> doubleTween({
    required double begin,
    required double end,
    double initialProgress = 0.0,
  }) {
    return RxTween(Tween(begin: begin, end: end), initialProgress: initialProgress);
  }

  static RxTween<int> intTween({
    required int begin,
    required int end,
    double initialProgress = 0.0,
  }) {
    return RxTween(IntTween(begin: begin, end: end), initialProgress: initialProgress);
  }

  static RxTween<Color?> colorTween({
    required Color begin,
    required Color end,
    double initialProgress = 0.0,
  }) {
    return RxTween<Color?>(ColorTween(begin: begin, end: end), initialProgress: initialProgress);
  }
}

