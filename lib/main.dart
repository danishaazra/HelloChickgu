import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';
import 'features/game/level_page.dart';
import 'features/game/training_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
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
      home: const LevelPage(),
      routes: {
        '/training': (_) => const TrainingPage(),
      },
    );
  }
}