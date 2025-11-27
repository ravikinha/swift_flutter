import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'rx.dart';
import '../ui/mark.dart';
import 'logger.dart';

/// Reactive tween that animates between values using AnimationController
class SwiftTween<T> extends ChangeNotifier {
  final Tween<T> _tween;
  final Rx<double> _progress;
  T? _currentValue;
  AnimationController? _controller;
  Animation<double>? _animation;
  TickerProvider? _tickerProvider;

  SwiftTween(
    this._tween, {
    double initialProgress = 0.0,
    TickerProvider? vsync,
  })  : _progress = Rx(initialProgress.clamp(0.0, 1.0)) {
    _tickerProvider = vsync;
    _progress.addListener(_updateValue);
    _updateValue();
    
    if (_tickerProvider != null) {
      _controller = AnimationController(
        vsync: _tickerProvider!,
        duration: const Duration(milliseconds: 300),
      );
      _animation = CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );
      _animation!.addListener(_onAnimationUpdate);
    }
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
    // Use transform instead of lerp to avoid protected member access
    final newValue = _tween.transform(_progress.value);
    if (_currentValue != newValue) {
      _currentValue = newValue;
      notifyListeners();
    }
  }

  void _onAnimationUpdate() {
    if (_animation != null && _controller != null) {
      _progress.value = _animation!.value;
    }
  }

  /// Animate to a target progress value using AnimationController if available
  Future<void> animateTo(
    double target, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final end = target.clamp(0.0, 1.0);

    if (_controller != null && _tickerProvider != null) {
      // Use AnimationController (more efficient)
      _controller!.duration = duration;
      _animation = CurvedAnimation(
        parent: _controller!,
        curve: curve,
      );
      _animation!.removeListener(_onAnimationUpdate);
      _animation!.addListener(_onAnimationUpdate);

      final startProgress = _progress.value;
      _controller!.value = startProgress;
      await _controller!.animateTo(end);
    } else {
      // Fallback to polling (for backwards compatibility)
      await _animateToPolling(end, duration: duration, curve: curve);
    }
  }

  /// Fallback animation using polling (for when vsync is not available)
  Future<void> _animateToPolling(
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

  /// Animate multiple values in sequence (staggered animation)
  Future<void> animateSequence(
    List<double> targets, {
    Duration duration = const Duration(milliseconds: 300),
    Duration stagger = const Duration(milliseconds: 100),
    Curve curve = Curves.easeInOut,
  }) async {
    for (var i = 0; i < targets.length; i++) {
      if (i > 0) {
        await Future.delayed(stagger);
      }
      await animateTo(targets[i], duration: duration, curve: curve);
    }
  }

  /// Stop current animation
  void stop() {
    _controller?.stop();
  }

  /// Reset animation
  void reset() {
    _controller?.reset();
    _progress.value = 0.0;
  }

  @override
  void dispose() {
    _progress.removeListener(_updateValue);
    _animation?.removeListener(_onAnimationUpdate);
    _controller?.dispose();
    _progress.dispose();
    super.dispose();
  }
}

/// Helper for creating common tweens
class TweenHelper {
  static SwiftTween<double> doubleTween({
    required double begin,
    required double end,
    double initialProgress = 0.0,
  }) {
    return SwiftTween(Tween(begin: begin, end: end), initialProgress: initialProgress);
  }

  static SwiftTween<int> intTween({
    required int begin,
    required int end,
    double initialProgress = 0.0,
  }) {
    return SwiftTween(IntTween(begin: begin, end: end), initialProgress: initialProgress);
  }

  static SwiftTween<Color?> colorTween({
    required Color begin,
    required Color end,
    double initialProgress = 0.0,
  }) {
    return SwiftTween<Color?>(ColorTween(begin: begin, end: end), initialProgress: initialProgress);
  }
}

