import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/util/play_animation_mixin.dart';

const Duration _expandDuration = Duration(milliseconds: 200);

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tips'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'declarative',
              ),
              Tab(
                text: 'tween animation builder',
              ),
              Tab(
                text: 'controller value',
              ),
            ],
            isScrollable: true,
          ),
        ),
        body: const TabBarView(children: [
          _DeclarativeAnimationExample(),
          _TweenBuilderExample(),
          _AnimationControllerValueMutationExample(),
        ]),
      ),
    );
  }
}

class _DeclarativeAnimationExample extends StatefulWidget {
  const _DeclarativeAnimationExample();

  @override
  State<_DeclarativeAnimationExample> createState() =>
      _DeclarativeAnimationExampleState();
}

class _DeclarativeAnimationExampleState
    extends State<_DeclarativeAnimationExample> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(_isExpanded ? 'collapse' : 'expand')),
              _DeclarativeExpansion(
                isExpanded: _isExpanded,
                children: [
                  Container(
                    height: 100.0,
                    width: double.infinity,
                    color: Colors.red,
                  ),
                  Container(
                    height: 100.0,
                    width: double.infinity,
                    color: Colors.purple,
                  ),
                ],
              )
            ],
          ),
        ),
        const Positioned(
          bottom: 100.0,
          right: 0.0,
          left: 0.0,
          child: _FavoriteButton(),
        ),
      ],
    );
  }
}

/// Виджет, анимация которого воспроизводится относительно [isExpanded].
class _DeclarativeExpansion extends StatefulWidget {
  final bool isExpanded;

  final List<Widget> children;

  final Widget Function(BuildContext context, Widget? child) builder;

  const _DeclarativeExpansion({
    required this.isExpanded,
    this.builder = _defaultBuilder,
    this.children = const [],
  });

  @override
  _DeclarativeExpansionState createState() => _DeclarativeExpansionState();

  static Widget _defaultBuilder(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();
}

class _DeclarativeExpansionState extends State<_DeclarativeExpansion>
    with SingleTickerProviderStateMixin {
  late final _curveTween = CurveTween(curve: Curves.easeInOutCubic);

  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _expandDuration, vsync: this);
    _heightFactor = _controller.drive(_curveTween);

    if (widget.isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Реагируем в данном методе на изменение поля [_DeclarativeExpansion.isExpanded].
  @override
  void didUpdateWidget(covariant _DeclarativeExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isExpanded != widget.isExpanded) {
      _makeExpand(widget.isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final closed = !widget.isExpanded && _controller.isDismissed;
    final shouldRemoveChildren = closed;

    final result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: widget.children.length == 1
            ? widget.children.first
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, child) => widget.builder.call(
        context,
        child == null
            ? child
            : ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              ),
      ),
      child: shouldRemoveChildren ? null : result,
    );
  }

  void _makeExpand(bool isExpanded) {
    isExpanded ? _controller.forward() : _controller.reverse();
  }
}

/// Еще один пример анимации, которая активируется декларативно.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton();

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 80,
      onPressed: _onPressed,
      icon: _FavoriteIcon(isEnabled: _value),
    );
  }

  void _onPressed() {
    setState(() {
      _value = !_value;
    });
  }
}

class _FavoriteIcon extends StatefulWidget {
  final bool isEnabled;

  const _FavoriteIcon({required this.isEnabled});

  @override
  State<_FavoriteIcon> createState() => __FavoriteIconState();
}

class __FavoriteIconState extends State<_FavoriteIcon>
    with TickerProviderStateMixin {
  /// Контроллер добавления в избранное.
  late final _enableController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  /// Контроллер снятия избранного.
  late final _disableController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  /// Tween кривой.
  final _curveTween = CurveTween(curve: Curves.fastOutSlowIn);

  /// Анимация цвета иконки.
  late final _colorAnimation =
      ColorTween(begin: Colors.grey.shade400, end: Colors.red.shade900)
          .chain(_curveTween)
          .animate(_enableController);

  /// Анимация увеличения иконки.
  late final _innerScaleUpAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 20.0),
    TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.4), weight: 20.0),
    TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20.0),
  ]).chain(_curveTween).animate(_enableController);

  /// Анимация увеличения внешней иконки (эффект пульсации).
  late final _outerScaleUpAnimation =
      Tween(begin: 1.0, end: 4.0).chain(_curveTween).animate(_enableController);

  /// Анимация фэйда (эффект пульсации).
  late final _outerFadeAnimation =
      Tween(begin: 1.0, end: 0.0).chain(_curveTween).animate(_enableController);

  /// Анимация "тряски", которая применяется при снятии "избранного".
  late final _shakeAnimation = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 20.0),
    TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 20.0),
    TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 20.0),
    TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 20.0),
  ]).chain(_curveTween).animate(_disableController);

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) _enableController.forward();
  }

  @override
  void didUpdateWidget(covariant _FavoriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEnabled == widget.isEnabled) return;

    _playAnimation(widget.isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _enableController,
        _disableController,
      ]),
      builder: (_, __) {
        final icon = AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstCurve: Curves.fastOutSlowIn,
          secondCurve: Curves.fastOutSlowIn,
          firstChild: Icon(
            Icons.favorite_border,
            color: _colorAnimation.value,
          ),
          secondChild: Icon(
            Icons.favorite,
            color: _colorAnimation.value,
          ),
          crossFadeState: !widget.isEnabled
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        );

        return RotationTransition(
          turns: _shakeAnimation,
          child: Stack(
            children: [
              FadeTransition(
                opacity: _outerFadeAnimation,
                child: ScaleTransition(
                  scale: _outerScaleUpAnimation,
                  child: icon,
                ),
              ),
              ScaleTransition(
                scale: _innerScaleUpAnimation,
                child: icon,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playAnimation(bool isEnabled) async {
    if (isEnabled) {
      _enableController.forward();

      return;
    }
    _enableController.reset();
    await _disableController.forward();
    _disableController.reset();
  }
}

class _AnimationControllerValueMutationExample extends StatefulWidget {
  const _AnimationControllerValueMutationExample();

  @override
  State<_AnimationControllerValueMutationExample> createState() =>
      _AnimationControllerStateValueMutationExample();
}

class _AnimationControllerStateValueMutationExample
    extends State<_AnimationControllerValueMutationExample>
    with SingleTickerProviderStateMixin, PlayAnimationMixin {
  late final _animation = Tween<double>(begin: -1.0, end: 1.0)
      .chain(CurveTween(curve: Curves.fastOutSlowIn))
      .animate(animationController);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => Align(
              alignment: Alignment(0, _animation.value),
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  width: double.infinity,
                  color: Colors.red,
                  child: Text('Value: ${_animation.value}'),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: playAnimation,
                child: const Icon(Icons.play_arrow),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// [AnimationController.value] является мутабельным полем и мы можем проводить
  /// какие либо изменения над ним, когда нам это нужно.
  ///
  /// Таким образом можно иметь весьма интерактивные анимации как эта.
  void _onPanUpdate(DragUpdateDetails details) =>
      animationController.value += details.delta.dy / 100;
}

class _TweenBuilderExample extends StatelessWidget {
  const _TweenBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder(
        curve: Curves.bounceOut,
        onEnd: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tween has been animated'),
          ),
        ),
        builder: (context, value, child) => ColoredBox(
          color: value!,
          child: child,
        ),
        duration: const Duration(seconds: 1),
        tween: ColorTween(begin: Colors.brown, end: Colors.red),
        child: const SizedBox(
          width: 150,
          height: 150.0,
        ),
      ),
    );
  }
}
