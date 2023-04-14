import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:flutter_voronezh_animations/common/service/my_dialog_manager.dart';
import 'package:flutter_voronezh_animations/screen/home_screen.dart';
import 'package:full_screen_dialog_manager/full_screen_dialog_manager.dart';
import 'package:positioned_dialog_manager/positioned_dialog_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FlutterEasyDialogs.builder(
        setupManagers: (overlayController, managerRegistry) {
          managerRegistry
            ..registerFullScreen(overlayController)
            ..registerPositioned(overlayController)
            ..register(
              () => MyDialogManager(overlayController: overlayController),
            );
        },
      ),
      title: 'Flutter Voronezh Animations',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
