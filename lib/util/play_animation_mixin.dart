
import 'package:flutter/material.dart';

const _animationDuration = Duration(milliseconds: 400);

mixin PlayAnimationMixin<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  Duration get duration => _animationDuration;
  Duration? get reverseDuration => null;
  double get upperBound => 1.0;
  double get lowerBound => 0.0;

  late final animationController = AnimationController(
    vsync: this,
    duration: duration,
    reverseDuration: reverseDuration,
    upperBound: upperBound,
    lowerBound: lowerBound,
  );

  Future<void> playAnimation() => animationController.isCompleted
      ? animationController.reverse()
      : animationController.forward();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
