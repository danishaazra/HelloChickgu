import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isSmallScreen(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Training',
          style: TextStyle(
            fontSize: Responsive.scaleFont(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: Responsive.scalePaddingAll(context, 20),
          child: Text(
            'Training content will be here',
            style: TextStyle(
              fontSize: Responsive.scaleFont(context, 16),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


