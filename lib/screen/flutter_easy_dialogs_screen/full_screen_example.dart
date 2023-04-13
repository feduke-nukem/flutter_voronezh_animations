part of 'flutter_easy_dialogs_screen.dart';

const _foregroundBounce = 'bounce';
const _foregroundFade = 'fade';
const _foregroundExpansion = 'expansion';
const _foregroundNone = 'none';

const _backgroundFade = 'fade';
const _backgroundBlur = 'blur';
const _backgroundNone = 'none';

const _dismissibleFullScreenTap = 'tap';
const _dismissibleNone_ = 'none';

const _content = SizedBox.square(
  dimension: 200.0,
  child: Center(
    child: SizedBox.square(
      dimension: 150,
      child: CircularProgressIndicator(
        strokeWidth: 10.0,
      ),
    ),
  ),
);

const _foregroundAnimators = <String, FullScreenForegroundAnimator>{
  _foregroundBounce: FullScreenForegroundAnimator.bounce(),
  _foregroundFade: FullScreenForegroundAnimator.fade(),
  _foregroundExpansion: FullScreenForegroundAnimator.expansion(),
  _foregroundNone: FullScreenForegroundAnimator.none(),
};

final _backgroundAnimators = <String, FullScreenBackgroundAnimator>{
  _backgroundBlur: FullScreenBackgroundAnimator.blur(
    start: 0.0,
    end: 10.0,
    backgroundColor: Colors.black.withOpacity(0.5),
  ),
  _backgroundFade: FullScreenBackgroundAnimator.fade(
    backgroundColor: Colors.black.withOpacity(0.5),
  ),
  _backgroundNone: const FullScreenBackgroundAnimator.none(),
};

const _fullScreenDismissibles = <String, FullScreenDismissible>{
  _dismissibleFullScreenTap: FullScreenDismissible.tap(),
  _dismissibleNone_: FullScreenDismissible.none(),
};

class _FullScreenExample extends StatefulWidget {
  const _FullScreenExample();

  @override
  State<_FullScreenExample> createState() => _FullScreenExampleState();
}

class _FullScreenExampleState extends State<_FullScreenExample> {
  final _easyDialogManagerProvider = FlutterEasyDialogs.provider;

  final _contentAnimationTypeDropDownItems = _foregroundAnimators.entries
      .map(
        (e) => DropdownMenuItem<FullScreenForegroundAnimator>(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList();
  final _backgroundAnimationTypeDropDownItems = _backgroundAnimators.entries
      .map(
        (e) => DropdownMenuItem<FullScreenBackgroundAnimator>(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList();

  final _dismissibleDropDownItems = _fullScreenDismissibles.entries
      .map(
        (e) => DropdownMenuItem<FullScreenDismissible>(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList();

  var _selectedForegroundAnimator = _foregroundAnimators.entries.first.value;
  var _selectedBackgroundAnimator = _backgroundAnimators.entries.first.value;
  var _selectedDismissible = _fullScreenDismissibles.entries.first.value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Content animation type'),
                  DropdownButton<FullScreenForegroundAnimator>(
                    items: _contentAnimationTypeDropDownItems,
                    onChanged: (type) => setState(
                      () => _selectedForegroundAnimator = type!,
                    ),
                    value: _selectedForegroundAnimator,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Background animation type'),
                  DropdownButton<FullScreenBackgroundAnimator>(
                    items: _backgroundAnimationTypeDropDownItems,
                    onChanged: (type) => setState(
                      () => _selectedBackgroundAnimator = type!,
                    ),
                    value: _selectedBackgroundAnimator,
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dismissible type'),
              DropdownButton<FullScreenDismissible>(
                items: _dismissibleDropDownItems,
                onChanged: (type) => setState(
                  () => _selectedDismissible = type!,
                ),
                value: _selectedDismissible,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              await _easyDialogManagerProvider.showFullScreen(
                FullScreenShowParams(
                  content: _content,
                  foregroundAnimator: _selectedForegroundAnimator,
                  backgroundAnimator: _selectedBackgroundAnimator,
                  shell: FullScreenDialogShell.modalBanner(
                    boxDecoration: BoxDecoration(
                      color: Colors.grey.shade200.withOpacity(0.3),
                    ),
                  ),
                  dismissible: _selectedDismissible,
                ),
              );
            },
            child: const Text('Show'),
          ),
        ],
      ),
    );
  }
}
