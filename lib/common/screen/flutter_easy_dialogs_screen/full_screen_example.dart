part of 'flutter_easy_dialogs_screen.dart';

const _fullScreenForegroundBounce = 'bounce';
const _fullScreenForegroundFade = 'fade';
const _fullScreenForegroundExpansion = 'expansion';
const _fullScreenForegroundNone = 'none';

const _fullScreenBackgroundFade = 'fade';
const _fullScreenBackgroundBlur = 'blur';
const _fullScreenBackgroundNone = 'none';

const _fullScreenDismissibleTap = 'tap';
const _fullScreenDismissibleNone = 'none';

const _fullScreenContent = SizedBox.square(
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

/// Перечисление всех доступных аниматоров для переднего плана.
///
/// * [FullScreenForegroundAnimator.bounce] - Анимация с эффектом "прыжка".
///
/// * [FullScreenForegroundAnimator.fade] - Fade эффект.
///
/// * [FullScreenForegroundAnimator.expansion] - Эффект разворачивания.
///
/// * [FullScreenForegroundAnimator.none] - Без анимации.
const _foregroundAnimators = <String, FullScreenForegroundAnimator>{
  _fullScreenForegroundBounce: FullScreenForegroundAnimator.bounce(),
  _fullScreenForegroundFade: FullScreenForegroundAnimator.fade(),
  _fullScreenForegroundExpansion: FullScreenForegroundAnimator.expansion(),
  _fullScreenForegroundNone: FullScreenForegroundAnimator.none(),
};

/// Перечисление всех доступных аниматоров для фона.
///
/// * [FullScreenBackgroundAnimator.blur] - Размытие фона.
///
/// * [FullScreenBackgroundAnimator.fade] - Fade эффект.
///
/// * [FullScreenBackgroundAnimator.none] - Без анимации.
final _backgroundAnimators = <String, FullScreenBackgroundAnimator>{
  _fullScreenBackgroundBlur: FullScreenBackgroundAnimator.blur(
    start: 0.0,
    end: 10.0,
    backgroundColor: Colors.black.withOpacity(0.5),
  ),
  _fullScreenBackgroundFade: FullScreenBackgroundAnimator.fade(
    backgroundColor: Colors.black.withOpacity(0.5),
  ),
  _fullScreenBackgroundNone: const FullScreenBackgroundAnimator.none(),
};

/// Перечисление всех доступных способов закрыть диалог взаимодействием пользователя.
///
/// * [FullScreenDismissible.tap] - Обычное нажатие.
///
/// * [FullScreenDismissible.none] - Без возможности закрытия взаимодействием.
const _fullScreenDismissibles = <String, FullScreenDismissible>{
  _fullScreenDismissibleTap: FullScreenDismissible.tap(),
  _fullScreenDismissibleNone: FullScreenDismissible.none(),
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

  var _selectedForegroundAnimator = _foregroundAnimators.values.first;
  var _selectedBackgroundAnimator = _backgroundAnimators.values.first;
  var _selectedDismissible = _fullScreenDismissibles.values.first;

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
                  content: _fullScreenContent,
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
