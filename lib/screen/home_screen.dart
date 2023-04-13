import 'package:flutter/material.dart';
import 'package:flutter_voronezh_animations/screen/complex_animations_screen.dart';
import 'package:flutter_voronezh_animations/screen/animations_out_of_the_box_screen.dart';
import 'package:flutter_voronezh_animations/screen/tips_screen.dart';

import 'basics_screen.dart';
import 'flutter_easy_dialogs_screen/flutter_easy_dialogs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Voronezh Animations'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BasicsScreen(),
                ),
              ),
              child: const Text('basics'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AnimationsOutOfTheBoxScreen(),
                ),
              ),
              child: const Text('animations out of the box'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ComplexAnimationsScreen(),
                ),
              ),
              child: const Text('complex'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TipsScreen(),
                ),
              ),
              child: const Text('tips'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FlutterEasyDialogsScreen(),
                ),
              ),
              child: const Text('flutter easy dialogs'),
            )
          ],
        ),
      ),
    );
  }
}
