part of 'flutter_easy_dialogs_screen.dart';

const _customPositionedContent = SizedBox.square(
  dimension: 250,
  child: Center(
    child: Text(
      'custom banner',
    ),
  ),
);

class _PositionedCustomizationExample extends StatelessWidget {
  const _PositionedCustomizationExample();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _show,
            child: const Text('show'),
          ),
          ElevatedButton(
            onPressed: _showFlutterAnimate,
            child: const Text('show flutter animate'),
          ),
        ],
      ),
    );
  }

  void _show() => FlutterEasyDialogs.provider.showPositioned(
        PositionedShowParams(
          animationConfiguration: const EasyDialogAnimatorConfiguration(
            duration: Duration(seconds: 1),
            reverseDuration: Duration(milliseconds: 200),
          ),
          shell: const _CustomPositionedShell(),
          content: _customPositionedContent,
          animator: _CustomPositionedAnimator(),
          dismissible: const _CustomPositionedDismissible(),
        ),
      );

  void _showFlutterAnimate() => FlutterEasyDialogs.provider.showPositioned(
        PositionedShowParams(
          content:
              const SizedBox(height: 100.0, child: _customPositionedContent),
          shell: const PositionedDialogShell.banner(
            backgroundColor: Colors.purple,
          ),
          animator: _FlutterAnimateAnimator(),
        ),
      );
}

class _CustomPositionedShell extends PositionedDialogShell {
  const _CustomPositionedShell();

  @override
  Widget decorate(PositionedDialogShellData data) {
    return ColoredBox(
      color: Colors.amber,
      child: data.dialog,
    );
  }
}

class _CustomPositionedAnimator extends PositionedAnimator {
  @override
  Widget decorate(PositionedAnimatorData data) {
    return FadeTransition(
      opacity: data.parent,
      child: data.dialog,
    );
  }
}

class _CustomPositionedDismissible extends PositionedDismissible {
  const _CustomPositionedDismissible() : super(onDismissed: null);

  @override
  Widget decorate(EasyDismissibleData data) {
    return ElevatedButton(
      onPressed: () {
        data.dismissHandler?.call(const EasyDismissiblePayload());
        onDismissed?.call();
      },
      child: data.dialog,
    );
  }
}

class _FlutterAnimateAnimator extends PositionedAnimator {
  @override
  Widget decorate(PositionedAnimatorData data) {
    return data.dialog

        /// Небольшой хак. Так как фактически manager передаёт [AnimationController]
        /// как [Animation<double>] то можно сделать downcast.
        .animate(controller: data.parent as AnimationController)
        .scale(curve: Curves.fastOutSlowIn)
        .shake()
        .elevation()
        .slide()
        .fadeIn();
  }
}
