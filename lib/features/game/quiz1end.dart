import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';

class quiz1end extends StatelessWidget {
  final int correct;
  final int wrong;
  final int timeTaken;

  const quiz1end({
    Key? key,
    required this.correct,
    required this.wrong,
    required this.timeTaken,
  }) : super(key: key);

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = Responsive.isSmallScreen(context);
    
    return Scaffold(
      body: 
      Stack( children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/level.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
          Container(
      color: Colors.black.withOpacity(0.4), // adjust opacity (0.3 - 0.6 works well)
    ),
      Center(
        child: 
      Container(
          width: Responsive.scaleWidth(context, 350),
          constraints: BoxConstraints(
            maxHeight: isSmallScreen ? screenSize.height * 0.8 : screenSize.height * 0.85,
          ),
          padding: Responsive.scalePaddingAll(context, 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Responsive.scaleBorderRadiusAll(context, 30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(
                "Quiz Completed!",
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Time Taken: ${_formatTime(timeTaken)}",
                style: TextStyle(
                  fontFamily: 'Baloo2',fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                "Correct Answers: $correct",
                style: TextStyle(
                  fontFamily: 'Baloo2',fontSize: 20, color: Colors.blue),
              ),
              SizedBox(height: 10),
              Text(
                "Wrong Answers: $wrong",
                style: TextStyle(
                  fontFamily: 'Baloo2',fontSize: 20, color: Colors.red),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Return to level page and mark level as completed
                  Navigator.pop(context); // Go back to quiz1
                  Navigator.pop(context); // Go back to level page
                },
                child: Text("Continue"),
              ),
              ],
            ),
          ),
        ),
      ),
      ],
      ),
    );
  }
}