part of 'flutter_easy_dialogs_screen.dart';

class _MyDialogManagerExample extends StatelessWidget {
  const _MyDialogManagerExample();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () =>
            FlutterEasyDialogs.provider.use<MyDialogManager>().show(
                  params: EasyDialogManagerShowParams(
                    content: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.6),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(30.0),
                      child: const Text(
                        'My custom manager',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        child: const Text('Show'),
      ),
    );
  }
}
