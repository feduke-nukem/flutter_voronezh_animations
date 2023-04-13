import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/core/play_animation_mixin.dart';

const Duration _expandDuration = Duration(milliseconds: 200);

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tips'),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'declarative',
            ),
            Tab(
              text: 'controller value',
            ),
          ]),
        ),
        body: const TabBarView(children: [
          _DeclarativeAnimationExample(),
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
    return Column(
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

/// Состояние виджета [_DeclarativeExpansion]
class _DeclarativeExpansionState extends State<_DeclarativeExpansion>
    with SingleTickerProviderStateMixin {
  late final _curveTween = CurveTween(curve: Curves.easeInOutCubic);

  /// Контроллер анимации
  @protected
  late AnimationController controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: _expandDuration, vsync: this);
    _heightFactor = controller.drive(_curveTween);

    if (widget.isExpanded) controller.value = 1.0;
  }

  @override
  void dispose() {
    controller.dispose();
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
    final closed = !widget.isExpanded && controller.isDismissed;
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
      animation: controller.view,
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
    isExpanded ? controller.forward() : controller.reverse();
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
                child: const Icon(
                  Icons.play_arrow,
                ),
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
