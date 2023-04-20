import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/util/multiply_animation.dart';

const _cookieDuration = Duration(milliseconds: 1550);
const _abobusDuration = Duration(milliseconds: 1500);

class ComplexAnimationsScreen extends StatelessWidget {
  const ComplexAnimationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complex'),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'cookie',
            ),
            Tab(
              text: 'abobus',
            ),
          ]),
        ),
        body: const TabBarView(children: [
          Center(
            child: _CookieLoader(),
          ),
          Center(
            child: _Abobus(),
          ),
        ]),
      ),
    );
  }
}

/// Крепкое печево.
///
/// Пример Staggered анимаций.
///
/// Эффект волны/пульсации вдохновлён из https://youtu.be/YqzUIGsAJQA?t=4618
class _CookieLoader extends StatefulWidget {
  const _CookieLoader({Key? key}) : super(key: key);

  @override
  State<_CookieLoader> createState() => _CookieLoaderState();
}

class _CookieLoaderState extends State<_CookieLoader>
    with TickerProviderStateMixin {
  late final _cookieAnimationController = AnimationController(
    vsync: this,
    duration: _cookieDuration,
    animationBehavior: AnimationBehavior.preserve,
  );
  late final _textAnimationController = AnimationController(
    vsync: this,
    duration: _cookieDuration,
    animationBehavior: AnimationBehavior.preserve,
  );

  /// Используем [CurvedAnimation] в связке с [Interval] и добиваемся эффекта
  /// пошатывания туда-сюда у печенюхи.
  late final _rotateRightAnimation = CurvedAnimation(
    parent: _cookieAnimationController,
    curve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
  ).drive(Tween<double>(begin: -0.2, end: 0.2));

  late final _rotateLeftAnimation = CurvedAnimation(
    parent: _cookieAnimationController,
    curve: const Interval(0.6, 1.0, curve: Curves.fastOutSlowIn),
  ).drive(Tween<double>(begin: 0.2, end: -0.2));

  /// Комбинируем анимации для упрощения их применения в [AnimatedBuilder]
  late final _rotateAnimation = MultiplyAnimation(
    next: _rotateLeftAnimation,
    first: _rotateRightAnimation,
  );

  late final _scaleUpInnerAnimation = CurvedAnimation(
    parent: _cookieAnimationController,
    curve: const Interval(
      0.0,
      0.3,
      curve: Curves.fastOutSlowIn,
    ),
  ).drive(
    Tween<double>(
      begin: 1.0,
      end: 1.3,
    ),
  );

  /// Есть некоторая практика для объявления значений для интервальных анимаций,
  /// которые затем комбинируются, чтобы они между собой лучше сочетались
  /// путём указания дробных значений относительно предыдущих интервала.
  ///
  /// В данном случае предыдущей интервальной анимацией выступает
  /// [_scaleUpInnerAnimation] у которой [Tween.begin] будет 1.0 и [Tween.end] - 1.3
  /// соответственно.
  ///
  /// Следовательно, для плавного уменьшения в качестве [Tween.begin]
  /// мы укажем начальное значение [Tween.begin] первого интервала разделённое
  /// на конечное значение [Tween.end] первого интервала (1.0/1.3).
  ///
  /// Для [Tween.begin] значение данной анимации мы указываем 1.0,
  /// так как нужно помнить, что [MultiplyAnimation] выполняет умножение
  /// [Animation.value] значений двух указанных анимаций и, чтобы не было
  /// никаких грубых/резких скачков при переходе от одного интервала к
  /// другому (в подобном случае) используется именно 1.0.
  ///
  /// Мы получим примерно следующую картину:
  ///
  /// Увеличиваемся с 1.0 до 1.3 в интервал 0.0ms - 0.3ms и уменьшаемся с
  /// 1.0 (фактически 1.3 так как умножается значение первой анимации) до 1.0/1.3
  /// в интервал 0.3ms - 1.0ms.
  late final _scaleDownInnerAnimation = CurvedAnimation(
    parent: _cookieAnimationController,
    curve: const Interval(
      0.3,
      1.0,
      curve: Curves.fastOutSlowIn,
    ),
  ).drive(
    Tween<double>(
      begin: 1.0,
      end: 1.0 / 1.3,
    ),
  );

  late final _scaleInnerAnimation = MultiplyAnimation(
    first: _scaleUpInnerAnimation,
    next: _scaleDownInnerAnimation,
  );

  late final _outerFadeAnimation = CurvedAnimation(
    parent: _cookieAnimationController,
    curve: Curves.fastOutSlowIn,
  ).drive(
    Tween<double>(
      begin: 1.0,
      end: 0.0,
    ),
  );

  late final _outerScaleAnimation = Tween<double>(
    begin: 1.0,
    end: 2.5,
  ).animate(_cookieAnimationController);

  @override
  void initState() {
    _cookieAnimationController.repeat();
    _textAnimationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _cookieAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/cookie.png',
      width: 100.0,
      height: 100.0,
    );
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: _outerScaleAnimation,
            child: FadeTransition(
              opacity: _outerFadeAnimation,
              child: image,
            ),
          ),
          RotationTransition(
            turns: _rotateAnimation,
            child: ScaleTransition(
              scale: _scaleInnerAnimation,
              child: image,
            ),
          ),
          Positioned(
            bottom: -80.0,
            child: AnimatedBuilder(
              animation: _textAnimationController.view,
              builder: (_, child) => Opacity(
                opacity: _textAnimationController.value,
                child: child,
              ),
              child: const Text('pechevo'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Пример с использованием оверлея.
class _Abobus extends StatefulWidget {
  const _Abobus();

  @override
  State<_Abobus> createState() => _AbobusState();
}

class _AbobusState extends State<_Abobus> with TickerProviderStateMixin {
  /// Создаём контроллер для анимирования всего, что связано с изображением и
  /// фоном.
  late final _abobusAnimationController = AnimationController(
    vsync: this,
    duration: _abobusDuration,
  );

  /// И ещё один для анимирования всего, что связано с текстом.
  late final _textAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
    reverseDuration: const Duration(milliseconds: 350),
  );

  /// Интервал анимации цвета изображения и фона.
  final _colorAnimationInterval = const Interval(
    0.2,
    0.35,
  );

  /// Кривая [CurveTween] на основе интервала [_colorAnimationInterval].
  ///
  /// В принципе, почти одно и тоже, что и [CurvedAnimation] в смысловом использовании.
  /// Функциональное отличие в том, что у [CurvedAnimation] можно определить
  /// кривую [CurvedAnimation.reverseCurve], которая будет использоваться при
  /// обратном воспроизведении.
  ///
  /// Примеры можно увидеть в [_CookieLoaderState].
  ///
  /// Лично мне больше нравится использовать [CurveTween] так как форма записи
  /// выглядит не так нагружено.
  late final _colorCurveTween = CurveTween(curve: _colorAnimationInterval);

  /// [Tween] цвета абобуса.
  late final _abobusColorTween = ColorTween(
    begin: Colors.black,
    end: Colors.white,
  );

  /// [Tween] цвета фона.
  late final _backgroundColorTween = ColorTween(
    begin: Colors.amber,
    end: Colors.pinkAccent[700],
  );

  /// Создаём анимацию цвета абобуса на основе [_abobusColorTween] и [_colorCurveTween].
  late final _abobusColorAnimation = _abobusColorTween
      .chain(_colorCurveTween)
      .animate(_abobusAnimationController);

  /// Также создаём анимацию цвета фона.
  late final _backgroundColorAnimation = _backgroundColorTween
      .chain(_colorCurveTween)
      .animate(_abobusAnimationController);

  /// Анимация увеличения абобуса. Добиваемся bounce эффекта с помощью [TweenSequence].
  late final _abobusScaleAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 0.4),
    TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.2), weight: 0.2),
    TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.3),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 0.2),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 0.2),
  ])
      .chain(CurveTween(curve: Curves.fastOutSlowIn))
      .animate(_abobusAnimationController);

  /// Создаём [CurveTween].
  final _textCurveTween = CurveTween(curve: Curves.fastOutSlowIn);

  /// Создаём анимацию прозрачности текста с использованием [_textCurveTween].
  late final _textOpacityAnimation = Tween(begin: 0.0, end: 1.0)
      .chain(_textCurveTween)
      .animate(_textAnimationController);

  /// Создаём анимацию размытия фона.
  late final _backgroundBlurAnimation = Tween(begin: 0.0, end: 10.0)
      .chain(_textCurveTween)
      .animate(_textAnimationController);

  /// Создаём анимацию появления текста с bounce эффектом.
  ///
  /// Подобно [_abobusScaleAnimation].
  late final _textAppearScaleAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.7, end: 0.9), weight: 0.8),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 0.2),
    TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 0.2),
  ]).chain(CurveTween(curve: Curves.easeOut)).animate(_textAnimationController);

  /// Также анимация исчезновения текста.
  late final Animation<double> _textScaleDisappearAnimation =
      Tween(begin: 1.7, end: 1.0)
          .chain(_textCurveTween)
          .animate(_textAnimationController);

  /// Проксирующая анимация для анимации размера текста, чтобы подменить
  /// [_textAppearScaleAnimation] на [_textScaleDisappearAnimation], перед
  /// вызовом [_textAnimationController.reverse].
  late final _textScaleAnimation = ProxyAnimation(_textAppearScaleAnimation);

  /// Entry для оверлея, который будет перекрывать всё, размывать фон и отображать текст.
  OverlayEntry get _overlayEntry => OverlayEntry(
        builder: (_) => Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _textAnimationController,
            builder: (_, child) => Center(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _backgroundBlurAnimation.value,
                        sigmaY: _backgroundBlurAnimation.value,
                      ),
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                  Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _textScaleAnimation.value,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
            child: const Text(
              'ABOBUS',
              style: TextStyle(fontSize: 150.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _backgroundColorAnimation,
            builder: (context, child) => ColoredBox(
              color: _backgroundColorAnimation.value!,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _abobusAnimationController,
                      builder: (context, child) => Transform.scale(
                        scale: _abobusScaleAnimation.value,

                        /// Таким образом мы можем применять цвет к виджетам
                        /// контроля над которыми мы фактически не имеем.
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            _abobusColorAnimation.value!,
                            BlendMode.srcIn,
                          ),
                          child: child,
                        ),
                      ),
                      child: Image.asset('assets/abobus.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 50.0,
          right: 20.0,
          child: FloatingActionButton(
            onPressed: _playAnimation,
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _abobusAnimationController,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _abobusAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    if (!_abobusAnimationController.isDismissed) return;

    /// Находим оверлей
    final overlay = Overlay.of(context);

    /// Запускаем воспроизведение контроллера связанного с иконкой
    await _abobusAnimationController.forward();

    /// Строим [OverlayEntry]
    final overlayEntry = _overlayEntry;

    /// Встраиваем Entry в оверлей
    overlay.insert(overlayEntry);

    /// Воспроизводим контроллер связанный с текстом
    await _textAnimationController.forward();

    /// Задержка перед обратным воспроизведением
    await Future<void>.delayed(const Duration(seconds: 1));

    /// Подменяем анимацию текста, так как хотим, чтобы на [reverse] было другое поведение
    _textScaleAnimation.parent = _textScaleDisappearAnimation;

    /// Воспроизводим анимацию текста назад
    await _textAnimationController.reverse();

    /// Ждем немного
    await Future<void>.delayed(const Duration(milliseconds: 500));

    /// Воспроизводим контроллер связанный с иконкой и фоном обратно
    await _abobusAnimationController.reverse();

    /// Возвращаем анимацию текста
    _textScaleAnimation.parent = _textAppearScaleAnimation;

    /// Убираем entry из оверлея
    overlayEntry.remove();
  }
}
