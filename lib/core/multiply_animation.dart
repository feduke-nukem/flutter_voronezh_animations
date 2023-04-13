import 'package:flutter/material.dart';

/// Анимация, которая производит умножение значений переданных анимаций.
class MultiplyAnimation extends CompoundAnimation<double> {
  MultiplyAnimation({required super.first, required super.next});

  @override
  get value => first.value * next.value;
}
