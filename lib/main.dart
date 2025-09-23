import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';
import 'features/tutor/main_tutor.dart';
import 'features/game/quiz1.dart';
import 'features/tutor/main_tutor.dart';
import 'map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Chickgu!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: const MapChickgu(),
    );
  }
}
