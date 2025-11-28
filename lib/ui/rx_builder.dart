import 'package:flutter/material.dart';
import '../core/rx.dart';
import 'mark.dart';

/// Builder widget that rebuilds when Rx values change
class RxBuilder<T> extends StatelessWidget {
  final Rx<T> rx;
  final Widget Function(BuildContext context, T value) builder;

  const RxBuilder({
    super.key,
    required this.rx,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => builder(context, rx.value),
    );
  }
}

