import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: const Center(child: Text('Welcome to Hello Chickgu! try jeeee')),
    );
  }
}
