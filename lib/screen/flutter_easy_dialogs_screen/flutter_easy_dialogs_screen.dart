import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:flutter_voronezh_animations/common/service/my_dialog_manager.dart';
import 'package:full_screen_dialog_manager/full_screen_dialog_manager.dart';
import 'package:positioned_dialog_manager/positioned_dialog_manager.dart';
import 'dart:math' as math;

part 'positioned_example.dart';
part 'full_screen_example.dart';
part 'positioned_customization_example.dart';
part 'full_screen_customization_example.dart';
part 'my_dialog_manager_example.dart';

class FlutterEasyDialogsScreen extends StatelessWidget {
  const FlutterEasyDialogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Easy Dialogs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'positioned'),
              Tab(text: 'positioned customization'),
              Tab(text: 'full screen'),
              Tab(text: 'full screen customization'),
              Tab(text: 'my dialog manager'),
            ],
            isScrollable: true,
          ),
        ),
        body: const TabBarView(
          children: [
            _PositionedExample(),
            _PositionedCustomizationExample(),
            _FullScreenExample(),
            _FullScreenCustomizationExample(),
            _MyDialogManagerExample(),
          ],
        ),
      ),
    );
  }
}
