import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_voronezh_animations/util/play_animation_mixin.dart';
import 'package:flutter_voronezh_animations/common/widget/expandable_floating_action_button.dart';

final _lerpKey = GlobalKey<_LerpColoredBoxState>();
final _colorTweenKey = GlobalKey<_ColoredBoxState>();

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({super.key});

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basics'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _LerpColoredBox(key: _lerpKey),
          ),
          Center(
            child: _ColoredBox(key: _colorTweenKey),
          ),
        ],
      ),
      floatingActionButton: ExpandableFloatingActionButton(
        children: [
          ExpandableFloatingActionButtonChild(
            onPressed: () => _lerpKey.currentState!.playAnimation(),
            child: const Text('lerp back'),
          ),
          ExpandableFloatingActionButtonChild(
            onPressed: () => _colorTweenKey.currentState!.playColorAnimation(),
            child: const Text('box color'),
          ),
          ExpandableFloatingActionButtonChild(
            onPressed: () =>
                _colorTweenKey.currentState!.playOpacityAnimation(),
            child: const Text('box opacity'),
          ),
          ExpandableFloatingActionButtonChild(
            onPressed: () => _colorTweenKey.currentState!.playSizeAnimation(),
            child: const Text('box size'),
          ),
        ],
      ),
    );
  }
}

class _LerpColoredBox extends StatefulWidget {
  const _LerpColoredBox({super.key});

  @override
  State<_LerpColoredBox> createState() => _LerpColoredBoxState();
}

/// В данном случае используется [SingleTickerProviderStateMixin] для
/// одного единственного [AnimationController].
///
/// Стоит использовать именно [SingleTickerProviderStateMixin], если не
/// предполагается создание более одного [Ticker].
class _LerpColoredBoxState extends State<_LerpColoredBox>
    with SingleTickerProviderStateMixin, PlayAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController.view,
      builder: (_, __) {
        final color = Color.lerp(
          Colors.amber,
          Colors.blueGrey,
          animationController.value,
        );

        return ColoredBox(color: color!);
      },
    );
  }
}

class _ColoredBox extends StatefulWidget {
  const _ColoredBox({super.key});

  @override
  State<_ColoredBox> createState() => _ColoredBoxState();
}

/// Виджет с созданием нескольких экземпляров [AnimationController].
///
/// В данном случае используется [TickerProviderStateMixin], который отличается
/// от [SingleTickerProviderStateMixin] тем, что под капотом имеет [Set] из [Ticker],
/// который пополняется при каждом вызове [TickerProviderStateMixin.createTicker].
class _ColoredBoxState extends State<_ColoredBox>
    with TickerProviderStateMixin {
  /// Контроллеры.
  ///
  /// Для создания [AnimationController] необходимо указать [Duration],
  /// это длительность за которую будет достигнуто значение [AnimationController.upperBound],
  /// начиная от [AnimationController.value], если оно было указано в конструкторе
  /// или [AnimationController.lowerBound] в противном случае.
  ///
  /// Первостепенным является `vsync` параметр в конструкторе, это [TickerProvider],
  /// для создания [Ticker], который будет использоваться созданным контроллером.
  ///
  /// Контроллеры могут иметь различные нижнюю и верхнюю границу, в том числе
  /// и бесконечность [AnimationController.unbounded] (лично мне ни разу не довелось использовать).
  ///
  /// * [AnimationController.value] - мутируемое поле, можно менять его в любой момент.
  late final _colorAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _opacityAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final _sizeAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: 1.0,
  );

  /// [Tween] для построения анимации смены цвета. Используется [ColorTween].
  ///
  /// Любой [Tween] имеет дженерик тип, который определяет
  /// значения [Tween.begin] и [Tween.end], который также передаётся в дженерик
  /// супер типа [Animatable].
  ///
  /// [Tween] является наследником [Animatable] и, по сути, ключевым
  /// методом является [Tween.lerp], который интерполирует значения
  /// [Tween.begin] и [Tween.end].
  /// * Метод может быть переопределён для каких-то кастомных решений.
  ///
  /// [Tween] переопределяет метод предка [Tween.transform] где и используется
  /// [Tween.lerp].
  /// Делается это для того, чтобы значения из [Tween.lerp] были использованы
  /// при вызове [Animatable.animate] в котором используется [Animatable.evaluate],
  /// для построения конечной анимации.
  ///
  /// Стоит понимать, что [Animatable.evaluate] это просто вспомогательный
  /// метод, использующий [Animatable.transform],
  /// который в качестве аргумента принимает [Animation] и передает
  /// в [Animatable.transform] значение [Animation.value].
  ///
  /// Сам по себе [Animatable.transform] просто возвращает значение на основе
  /// переданного [double] аргумента, как правило это `0.0-1.0`.
  ///
  /// Существуют различные [Tween]'ы из коробки:
  ///
  /// * [SizeTween] - использует под капотом [Size.lerp].
  ///
  /// * [RectTween] - использует под капотом [Rect.lerp].
  ///
  /// * [ReverseTween] - инвертирует переданный [ReverseTween.parent].
  ///
  /// * [ConstantTween] - имеет одинаковое значение для *begin* и *end* значений,
  /// может быть полезно при использовании [TweenSequence].
  ///
  /// * [StepTween] - при интерполяции значений [double] в [StepTween.lerp],
  /// округляет их до меньшего, проще говоря, использует [double.floor].
  ///
  /// * [IntTween] - то же самое, что и [StepTween], но использует [double.round].
  final _colorTween = ColorTween(begin: Colors.purple, end: Colors.teal);

  /// ### 1-ый способ создания анимации с применением кривой.
  ///
  /// Так как [AnimationController] является подтипом [Animation], то
  /// мы также можем использовать метод [AnimationController.drive]
  /// (можно использовать [Tween.animate]/[Animatable.animate] и передавать туда контроллер,
  /// делают эти методы одно и тоже),
  /// в свою очередь у [Tween], который участвует в построении анимации мы
  /// используем метод [Tween.chain], который сначала просчитывает значение
  /// переданного аргумента `parent` типа [Animatable] и на его основе уже
  /// делает финальное вычисление, которое используется для
  /// создания конечной анимации, грубо говоря, делает
  /// последовательную связь/сцепление двух [Animatable].
  late final _colorAnimation = _colorAnimationController.drive(
    _colorTween.chain(
      CurveTween(curve: Curves.easeInOut),
    ),
  );

  final _opacityTween = Tween<double>(begin: 1.0, end: 0.0);

  /// ### Способ создания обычной [Animation].
  ///
  /// Особо нечего тут сказать, кроме того, что в таких простых случаях, можно
  /// напрямую использовать значение [AnimationController.value] в виджетах.
  late final _opacityAnimation =
      _opacityAnimationController.drive(_opacityTween);

  final _sizeTween = Tween<double>(begin: 20.0, end: 150.0);

  late final _sizeAnimation = _sizeAnimationController.drive(
    _sizeTween.chain(
      CurveTween(curve: Curves.fastLinearToSlowEaseIn),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _colorAnimationController,
        _opacityAnimationController,
        _sizeAnimationController,
      ]),
      builder: (context, child) => SizedBox.square(
        dimension: _sizeAnimation.value,
        child: Opacity(
          opacity: _opacityAnimation.value,
          child: ColoredBox(color: _colorAnimation.value!),
        ),
      ),
    );
  }

  void playOpacityAnimation() => _playAnimation(_opacityAnimationController);

  void playColorAnimation() => _playAnimation(_colorAnimationController);

  void playSizeAnimation() => _playAnimation(_sizeAnimationController);

  void _playAnimation(AnimationController controller) =>
      controller.isCompleted ? controller.reverse() : controller.forward();
}
