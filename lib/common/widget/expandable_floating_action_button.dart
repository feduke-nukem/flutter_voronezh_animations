import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/util/play_animation_mixin.dart';
import 'dart:math' as math;
import 'package:collection/collection.dart';

const _fabSize = 70.0;
const _radius = 180.0;

class ExpandableFloatingActionButton extends StatefulWidget {
  final List<ExpandableFloatingActionButtonChild> children;

  const ExpandableFloatingActionButton({this.children = const [], super.key});

  @override
  State<ExpandableFloatingActionButton> createState() =>
      _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState
    extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin, PlayAnimationMixin {
  @override
  Duration get duration => const Duration(milliseconds: 300);

  late final _animation = CurvedAnimation(
    parent: animationController,
    curve: Curves.fastOutSlowIn,
  );

  @override
  Widget build(BuildContext context) {
    return Flow(
      clipBehavior: Clip.none,
      delegate: _FlowDelegate(animation: _animation),
      children: [
        ...widget.children.mapIndexed(
          (i, e) => _Fab(
            animation: animationController.view,
            key: ValueKey(i),
            onPressed: e.onPressed,
            child: e.child,
          ),
        ),
        _Fab(
          animation: animationController.view,
          key: const Key('1'),
          onPressed: playAnimation,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: animationController.view,
          ),
        ),
      ],
    );
  }
}

// https://www.youtube.com/watch?v=EdJ-43J7HgQ&ab_channel=HeyFlutter%E2%80%A4com
class _FlowDelegate extends FlowDelegate {
  final Animation<double> animation;
  const _FlowDelegate({required this.animation}) : super(repaint: animation);

  @override
  void paintChildren(FlowPaintingContext context) {
    final childCount = context.childCount;
    final xStart = context.size.width - _fabSize;
    final yStart = context.size.height - _fabSize;

    for (var i = 0; i < childCount; i++) {
      final isLast = i == childCount - 1;
      final radius = _radius * animation.value;
      double getValue(double value) => isLast ? 0.0 : value;

      final theta = i * math.pi * 0.5 / (childCount - 2);
      final x = xStart - getValue(radius * math.cos(theta));
      final y = yStart - getValue(radius * math.sin(theta));

      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(x, y, 0.0)
          ..translate(_fabSize / 2, _fabSize / 2)
          ..scale(isLast ? 1.0 : math.max(animation.value, 0.8))
          ..rotateZ(isLast
              ? 0.0
              : _radius * (1 - animation.value) * math.pi / _radius)
          ..translate(-_fabSize / 2, -_fabSize / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}

class _Fab extends AnimatedWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _Fab({
    required Animation<double> animation,
    required this.child,
    required this.onPressed,
    super.key,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (super.listenable as Animation<double>).value;
    final color =
        Color.lerp(Theme.of(context).primaryColor, Colors.amber[800], t);

    return SizedBox.square(
      dimension: _fabSize,
      child: FloatingActionButton(
        heroTag: key,
        elevation: 0.0,
        onPressed: onPressed,
        backgroundColor: color,
        child: child is Text
            ? Text(
                (child as Text).data!,
                textAlign: TextAlign.center,
              )
            : child,
      ),
    );
  }
}

class ExpandableFloatingActionButtonChild {
  final Widget child;
  final VoidCallback onPressed;

  const ExpandableFloatingActionButtonChild({
    required this.child,
    required this.onPressed,
  });

  @override
  bool operator ==(Object? other) =>
      identical(this, other) ||
      other is ExpandableFloatingActionButtonChild &&
          child == other.child &&
          onPressed == other.onPressed;

  @override
  int get hashCode => child.hashCode;
}
