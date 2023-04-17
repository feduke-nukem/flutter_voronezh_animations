part of 'flutter_easy_dialogs_screen.dart';

const _positionedExpansionAnimator = 'expansion';
const _positionedFadeAnimator = 'fade';
const _positionedVerticalSlideAnimator = 'verticalSlide';

const _positionedDismissibleTap = 'tap';
const _positionedDismissibleNone = 'none';
const _positionedDismissibleHorizontalSwipe = 'swipe';
const _positionedDismissibleAnimatedTap = 'animated tap';

/// Все доступные аниматоры для позиционных диалогов,
const _positionedAnimators = <String, PositionedAnimator>{
  _positionedExpansionAnimator: PositionedAnimator.expansion(),
  _positionedFadeAnimator: PositionedAnimator.fade(),
  _positionedVerticalSlideAnimator: PositionedAnimator.verticalSlide(),
};

/// Все доступные варианты закрытия позиционного диалога взаимодействием пользователя.
const _positionedDismissibles = <String, PositionedDismissible>{
  _positionedDismissibleTap: PositionedDismissible.tap(),
  _positionedDismissibleNone: PositionedDismissible.none(),
  _positionedDismissibleHorizontalSwipe: PositionedDismissible.swipe(),
  _positionedDismissibleAnimatedTap: PositionedDismissible.animatedTap(),
};

class _PositionedExample extends StatefulWidget {
  const _PositionedExample();

  @override
  State<_PositionedExample> createState() => _PositionedExampleState();
}

class _PositionedExampleState extends State<_PositionedExample> {
  final _animatorsDropDownItems = _positionedAnimators.entries
      .map(
        (e) => DropdownMenuItem<PositionedAnimator>(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList();
  final _positionDropDownItems = EasyDialogPosition.values
      .map(
        (e) => DropdownMenuItem<EasyDialogPosition>(
          value: e,
          child: Text(e.name),
        ),
      )
      .toList();
  final _dismissibleDropDownItems = _positionedDismissibles.entries
      .map(
        (e) => DropdownMenuItem<PositionedDismissible>(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList();

  var _selectedAnimator = _positionedAnimators.values.first;
  var _selectedPosition = EasyDialogPosition.top;
  var _selectedDismissible = _positionedDismissibles.values.first;
  var _isAutoHide = false;
  var _autoHideDuration = 300.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Animation type'),
                  DropdownButton<PositionedAnimator>(
                    items: _animatorsDropDownItems,
                    onChanged: (type) =>
                        setState(() => _selectedAnimator = type!),
                    value: _selectedAnimator,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Position'),
                  DropdownButton<EasyDialogPosition>(
                    items: _positionDropDownItems,
                    onChanged: (position) =>
                        setState(() => _selectedPosition = position!),
                    value: _selectedPosition,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Dismissible type'),
                  DropdownButton<PositionedDismissible>(
                    items: _dismissibleDropDownItems,
                    onChanged: (type) =>
                        setState(() => _selectedDismissible = type!),
                    value: _selectedDismissible,
                  ),
                ],
              ),
            ],
          ),
          CheckboxListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            title: const Text('Auto hide'),
            value: _isAutoHide,
            onChanged: (value) => setState(() => _isAutoHide = value!),
          ),
          if (_isAutoHide) ...[
            const Text('Auto hide duration in milliseconds'),
            Slider(
              max: 2000,
              value: _autoHideDuration,
              onChanged: (value) => setState(() => _autoHideDuration = value),
            ),
          ],
          ElevatedButton(
            onPressed: _show,
            child: const Text('Show'),
          ),
          ElevatedButton(
            onPressed: FlutterEasyDialogs.provider.hideAllPositioned,
            child: const Text('Hide all'),
          ),
          ElevatedButton(
            onPressed: () =>
                FlutterEasyDialogs.provider.hidePositioned(_selectedPosition),
            child: const Text('Hide by position'),
          ),
        ],
      ),
    );
  }

  void _show() {
    FlutterEasyDialogs.provider.showPositioned(
      PositionedShowParams(
        dismissible: _selectedDismissible,
        animator: _selectedAnimator,
        hideAfterDuration: _isAutoHide
            ? Duration(milliseconds: _autoHideDuration.toInt())
            : null,
        content: Container(
          height: 150.0,
          color: Colors.amber[900],
          alignment: Alignment.center,
          child: Text('$_selectedPosition'),
        ),
        position: _selectedPosition,
      ),
    );
  }
}
