import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          width: 350,
         
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Quiz Completed!",
                style: GoogleFonts.baloo2(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Time Taken: ${_formatTime(timeTaken)}",
                style: GoogleFonts.baloo2(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                "Correct Answers: $correct",
                style: GoogleFonts.baloo2(fontSize: 20, color: Colors.blue),
              ),
              SizedBox(height: 10),
              Text(
                "Wrong Answers: $wrong",
                style: GoogleFonts.baloo2(fontSize: 20, color: Colors.red),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back"),
              ),
            ],
          ),
        ),
      ),
      ],
      ),
    );
  }
}