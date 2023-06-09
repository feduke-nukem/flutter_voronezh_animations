part of 'flutter_easy_dialogs_screen.dart';

const _customFullScreenContent = SizedBox.square(
  dimension: 200.0,
  child: Center(
    child: Text(
      'Custom',
      style: TextStyle(fontSize: 30),
    ),
  ),
);

class _FullScreenCustomizationExample extends StatelessWidget {
  const _FullScreenCustomizationExample();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await FlutterEasyDialogs.provider.showFullScreen(
                const FullScreenShowParams(
                  content: _customFullScreenContent,
                  foregroundAnimator: _ForegroundAnimator(),
                  backgroundAnimator: _BackgroundAnimator(),
                  shell: _Shell(),
                ),
              );
            },
            child: const Text('Show custom'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FlutterEasyDialogs.provider.showFullScreen(
                FullScreenShowParams(
                  animationConfiguration: const EasyDialogAnimatorConfiguration(
                    reverseDuration: Duration(milliseconds: 50),
                  ),
                  content: _customFullScreenContent,
                  customAnimator: const CustomAnimator(),
                  shell: const FullScreenDialogShell.modalBanner(),
                  dismissible: _Dismissible(
                    onDismissed: () {},
                  ),
                ),
              );
            },
            child: const Text('fully custom'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FlutterEasyDialogs.provider.showFullScreen(
                FullScreenShowParams(
                  content: Center(
                    child: Image.asset('assets/cookie.png'),
                  ),
                  customAnimator: _FlutterAnimateDecorator(),
                  shell: const FullScreenDialogShell.modalBanner(),
                ),
              );
            },
            child: const Text('with flutter animate'),
          )
        ],
      ),
    );
  }
}

class _Dismissible extends FullScreenDismissible {
  const _Dismissible({super.onDismissed});

  @override
  Widget decorate(EasyDismissibleData data) {
    return Dismissible(
      key: UniqueKey(),
      resizeDuration: null,
      confirmDismiss: (direction) async {
        await data.dismissHandler
            ?.call(const EasyDismissiblePayload(instantDismiss: true));

        return true;
      },
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDismissed?.call();
      },
      child: data.dialog,
    );
  }
}

class _ForegroundAnimator extends FullScreenForegroundAnimator {
  const _ForegroundAnimator();

  @override
  Widget decorate(EasyDialogAnimatorData data) {
    final rotate = Tween<double>(begin: math.pi, end: math.pi / 360);

    return AnimatedBuilder(
      animation: data.parent,
      builder: (context, child) => Transform.scale(
        scale: data.parent.value,
        child: Opacity(
          opacity: data.parent.value,
          child: Transform.rotate(
            angle: data.parent
                .drive(rotate.chain(CurveTween(curve: Curves.fastOutSlowIn)))
                .value,
            child: child,
          ),
        ),
      ),
      child: data.dialog,
    );
  }
}

class _BackgroundAnimator extends FullScreenBackgroundAnimator {
  const _BackgroundAnimator();

  @override
  Widget decorate(EasyDialogAnimatorData data) {
    return AnimatedBuilder(
      animation: data.parent,
      builder: (_, child) => Container(
        height: double.infinity,
        width: double.infinity,
        color: Color.lerp(Colors.transparent, Colors.purple.withOpacity(0.6),
            data.parent.value),
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: child,
      ),
      child: data.dialog,
    );
  }
}

class CustomAnimator extends EasyDialogAnimator {
  const CustomAnimator();

  @override
  Widget decorate(EasyDialogAnimatorData data) {
    final offset = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    );

    final blur = data.parent.drive(
      Tween<double>(begin: 0.0, end: 7.0),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: data.parent,
            builder: (_, __) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur.value,
                sigmaY: blur.value,
              ),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
        ),
        SlideTransition(
          position: data.parent.drive(
            offset.chain(
              CurveTween(curve: Curves.fastOutSlowIn),
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            height: double.infinity,
            width: double.infinity,
            child: data.dialog,
          ),
        ),
      ],
    );
  }
}

class _Shell extends FullScreenDialogShell {
  const _Shell();

  @override
  Widget decorate(EasyDialogDecoratorData data) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.cyanAccent.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.0)),
      child: data.dialog,
    );
  }
}

class _FlutterAnimateDecorator extends EasyDialogAnimator {
  @override
  Widget decorate(EasyDialogAnimatorData data) {
    return AnimatedBuilder(
      animation: data.parent,
      builder: (context, child) => ColoredBox(
        color: Colors.yellow.withOpacity(
          data.parent.value.clamp(0.0, 0.5),
        ),
        child: child,
      ),
      child: data.dialog
          .animate(controller: data.parent as AnimationController)
          .fade()
          .rotate()
          .scale()
          .blur(
            begin: const Offset(20.0, 20.0),
            end: const Offset(0.0, 0.0),
          ),
    );
  }
}
