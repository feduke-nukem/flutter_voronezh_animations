import 'package:flutter/material.dart';

/// Анимация, которая производит умножение значений переданных анимаций.
///
/// Идея позаимствована из https://youtu.be/YqzUIGsAJQA?t=4831
class MultiplyAnimation extends CompoundAnimation<double> {
  MultiplyAnimation({required super.first, required super.next});

  @override
  double get value => first.value * next.value;
}
