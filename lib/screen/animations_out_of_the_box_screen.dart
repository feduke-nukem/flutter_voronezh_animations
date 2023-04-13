import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/core/multiply_animation.dart';
import 'package:flutter_voronezh_animations/core/play_animation_mixin.dart';

/// На данный момент существует конкретное количество наследников [Animation]
/// из коробки, которые позволяют решать некоторые проблемы.
///
/// * #### [CurvedAnimation]
///   Наследник [Animation], который использует [Curve] для построения анимации.
///   Принцип работы [CurvedAnimation] достаточно простой.
///   Если коротко:
///   Указанный [CurvedAnimation.curve] применяет трансформацию
///   на поле [CurvedAnimation.value] с помощью [Curve.transform]
///   на основе [CurvedAnimation.parent].
///   Сами кривые можно создавать самостоятельно в каких-то ну прям очень кастомных случаях,
///   но в среднем используется готовые из [Curves].
///   Опционально может быть указан [CurvedAnimation.reverseCurve] для проигрывания
///   анимации назад.
///
/// * #### [ProxyAnimation] - Анимация, которая может менять своего [ProxyAnimation.parent].
///   Это может быть полезно, например, когда нам нужно каким-либо образом менять
///   анимации в определенные моменты для каких-то виджетов. Ниже будет пример,
///
/// * #### [ReverseAnimation] - Тут всё просто, инверсия переданной в конструктор анимации.
///
/// * #### [TrainHoppingAnimation] - Интересный вариант анимации. В него передаётся
///   две анимации при создании.
///   Начинает с проксирования (использует значение) [TrainHoppingAnimation.currentTrain],
///   затем, когда значение [TrainHoppingAnimation.currentTrain] пересекается с
///   значением [TrainHoppingAnimation._nextTrain], то начинает проксировать след.
///   анимацию.
///   Честно говоря, не приходилось использовать такой вариант в реальности.
///
/// * #### [CompoundAnimation] - Достаточно полезный вариант, позволяет комбинировать
///   две переданных анимации.
///
/// * #### [AnimationMean], [AnimationMin], [AnimationMax] - Выделяю их в один пункт,
///   так как они имеют общую по смыслу арифметическую нагрузку.
///   Также не доводилось использовать.
///
/// * #### [TweenSequence] - Полезный наследник [Animatable].
///   Позволяет комбинировать список [Tween]'ов последовательно.
///   Каждому [Tween] соответствует свой [TweenSequenceItem] которому задаётся "вес".
///   Для простоты лучше держать в голове 100% и распределять их среди этих [Tween] :
///   20%, 20%, 10%, 10%, 20%.
///   На самом деле, значение веса можно устанавливать выше, так как реальное
///   значение (процент) будет вычисляться по формуле:
///   значение веса/сумма значений весов всех [TweenSequenceItem], но лучше (для удобства)
///   придерживаться рамок 100%, как описано выше.
///   Такая вещь отдалённо похожа по принципу использования на [Interval],
///   но в рамках одной анимации.
class AnimationsOutOfTheBoxScreen extends StatefulWidget {
  const AnimationsOutOfTheBoxScreen({super.key});

  @override
  State<AnimationsOutOfTheBoxScreen> createState() =>
      _AnimationsOutOfTheBoxScreenState();
}

class _AnimationsOutOfTheBoxScreenState
    extends State<AnimationsOutOfTheBoxScreen> {
  var _currentIndex = 0;

  final _proxyKey = GlobalKey<__ProxyExampleState>();
  final _trainHoppingKey = GlobalKey<__TrainHopingExampleState>();
  final _compoundKey = GlobalKey<__CompoundExampleState>();
  final _tweenSequence = GlobalKey<__TweenSequenceExampleState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Animations out of the box'),
          bottom: TabBar(
            onTap: (value) => _currentIndex = value,
            isScrollable: true,
            tabs: const [
              Tab(text: 'proxy'),
              Tab(text: 'train hopping'),
              Tab(text: 'compound'),
              Tab(text: 'tween sequence'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ProxyExample(key: _proxyKey),
            _TrainHopingExample(key: _trainHoppingKey),
            _CompoundExample(key: _compoundKey),
            _TweenSequenceExample(key: _tweenSequence)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            switch (_currentIndex) {
              case 0:
                _proxyKey.currentState!.playAnimation();
                break;
              case 1:
                _trainHoppingKey.currentState!.playAnimation();
                break;
              case 2:
                _compoundKey.currentState!.playAnimation();
                break;
              case 3:
                _tweenSequence.currentState!.playAnimation();
                break;
              default:
            }
          },
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

class _ProxyExample extends StatefulWidget {
  const _ProxyExample({super.key});

  @override
  State<_ProxyExample> createState() => __ProxyExampleState();
}

/// Определяем две разных анимации, для простоты это будут анимации, одна
/// воспроизводится вперёд, другая назад.
///
/// [ProxyAnimation] позволяет подменять анимации в любой момент времени,
/// в данном случае это будет происходить в [_animationControllerListener]
/// при достижении [AnimationController.isCompleted] и [AnimationController.isDismissed].
///
/// Когда это может быть полезно?
///
/// Очень утрированный пример:
///
/// Есть виджет, который принимает в себя анимацию и нам нужно, чтобы она была
/// не линейной и простой (одинаковое воспроизведение вперёд/назад), включая кривую
/// и сами значение, а как-то более кастомно и сложно.
///
/// В данном случае это просто увеличение размера виджета. В дальнейшем будет
/// рассмотреть более сложный случай.
class __ProxyExampleState extends State<_ProxyExample>
    with
        SingleTickerProviderStateMixin,
        PlayAnimationMixin,
        AutomaticKeepAliveClientMixin {
  /// ### 2-ый способ создания анимации с применением кривой.
  ///
  /// Используется заранее созданная [CurvedAnimation] и вызывается метод
  /// [Animation.drive] (тоже самое что и [Tween.animate], но разный принцип передачи аргумента),
  /// и на основе этой `кривой` анимации создаётся новая, которая будет с учётом
  /// указанной [Curve] внутри [CurvedAnimation].
  ///
  /// Можно сказать, что это почти то же самое что и [Animatable.chain],
  /// так как в конечном итоге, сперва рассчитывается то что передаётся в метод
  /// [Animation.drive], а потом уже на основе этого строится значение
  /// для построения анимации.
  late final _forwardAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.bounceIn,
  ).drive(Tween<double>(begin: 0.0, end: 200.0));

  late final _reverseAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.easeIn,
  ).drive(
    Tween<double>(begin: 350.0, end: 200.0),
  );

  late final _animation = ProxyAnimation(_forwardAnimation);

  @override
  void initState() {
    animationController.addListener(_animationControllerListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Center(
      child: _Box(animation: _animation),
    );
  }

  void _animationControllerListener() {
    if (animationController.isCompleted) {
      _animation.parent = _reverseAnimation;

      return;
    }

    if (animationController.isDismissed) {
      _animation.parent = _forwardAnimation;

      return;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _TrainHopingExample extends StatefulWidget {
  const _TrainHopingExample({super.key});

  @override
  State<_TrainHopingExample> createState() => __TrainHopingExampleState();
}

class __TrainHopingExampleState extends State<_TrainHopingExample>
    with
        SingleTickerProviderStateMixin,
        PlayAnimationMixin,
        AutomaticKeepAliveClientMixin {
  late final _firstAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.fastOutSlowIn,
  ).drive(
    Tween<double>(begin: 100.0, end: 200.0),
  );

  late final _secondAnimation = CurvedAnimation(
    parent: animationController,
    curve: Curves.bounceInOut,
  ).drive(
    Tween<double>(begin: 150.0, end: 50.0),
  );

  late final _animation = TrainHoppingAnimation(
    _firstAnimation,
    _secondAnimation,
  );
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Center(child: _Box(animation: _animation));
  }

  @override
  bool get wantKeepAlive => true;
}

class _Box extends AnimatedWidget {
  const _Box({
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = super.listenable as Animation<double>;

    return SizedBox.square(
      dimension: animation.value,
      child: const ColoredBox(color: Colors.blue),
    );
  }
}

class _CompoundExample extends StatefulWidget {
  const _CompoundExample({super.key});

  @override
  State<_CompoundExample> createState() => __CompoundExampleState();
}

class __CompoundExampleState extends State<_CompoundExample>
    with
        SingleTickerProviderStateMixin,
        PlayAnimationMixin,
        AutomaticKeepAliveClientMixin {
  /// [Interval] это такой вид [Curve], который выполнит полное воспроизведение
  /// анимации за указанный интервал [Interval.begin] - [Interval.end].
  ///
  /// Это может быть полезно для создания сложных анимаций:
  /// [https://docs.flutter.dev/development/ui/animations/staggered-animations#:~:text=A%20staggered%20animation%20consists%20of,being%20animated%2C%20create%20a%20Tween%20.]
  late final _firstAnimation = CurvedAnimation(
    parent: animationController,
    curve: const Interval(
      0.0,
      0.3,
      curve: Curves.fastOutSlowIn,
    ),
  ).drive(
    Tween<double>(begin: 1.0, end: 1.5),
  );

  late final _secondAnimation = CurvedAnimation(
    parent: animationController,
    curve: const Interval(
      0.7,
      1.0,
      curve: Curves.bounceInOut,
    ),
  ).drive(
    Tween<double>(begin: 1.25, end: 2.0),
  );

  /// По сути может быть использовано в качестве упрощения комбинации нескольких анимаций.
  late final _animation = MultiplyAnimation(
    first: _firstAnimation,
    next: _secondAnimation,
  );
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: const Center(
        child: SizedBox.square(
          dimension: 150.0,
          child: ColoredBox(color: Colors.blue),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TweenSequenceExample extends StatefulWidget {
  const _TweenSequenceExample({super.key});

  @override
  State<_TweenSequenceExample> createState() => __TweenSequenceExampleState();
}

class __TweenSequenceExampleState extends State<_TweenSequenceExample>
    with SingleTickerProviderStateMixin, PlayAnimationMixin {
  final _sequence = TweenSequence([
    // Сначала размер уменьшается
    TweenSequenceItem(
      tween: Tween<double>(begin: 100.0, end: 20.0),
      weight: 30.0,
    ),
    // Затем увеличивается
    TweenSequenceItem(
      tween: Tween<double>(begin: 20.0, end: 300.0),
      weight: 30.0,
    ),
    // Удерживается значение, так как нам больше ничего и не нужно :).
    TweenSequenceItem(
      tween: ConstantTween(300.0),
      weight: 40.0,
    ),
  ]);
  late final _animation = animationController.drive(_sequence);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _Box(
        animation: _animation,
      ),
    );
  }
}
