
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hellochickgu/features/game/quiz2.dart';
import 'package:hellochickgu/features/game/quiz1end.dart';

import 'dart:async';


class quiz1 extends StatefulWidget {
  const quiz1({super.key});

  @override
  State<quiz1> createState() => _Quiz1State();
}

class _Quiz1State extends State<quiz1> {
  int? selectedAnswer;
  bool isAnswered = false;
  int currentQuestionIndex = 0;
  int? hoveredAnswer;
  
  
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isQuizCompleted = false;

  int correctCount = 0;
  int wrongCount = 0;
  
  // 15 Dart code questions
  final List<Map<String, dynamic>> questions = [
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> numbers = [1, 2, 3];\n"
          "  var result = numbers.map((n) => n * n).toList();\n\n"
          "  numbers.add(4);\n"
          "  print(result);\n"
          "}",
      'answers': [
        "A) [1, 4, 9, 16]",
        "B) [1, 4, 9]", 
        "C) [1, 2, 3, 4]",
        "D) 2, 3, 4"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String name = 'Flutter';\n"
          "  print(name.length);\n"
          "}",
      'answers': [
        "A) 7",
        "B) 9", 
        "C) 6",
        "D) 8"
      ],
      'correctAnswer': 0, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int x = 5;\n"
          "  int y = x++;\n"
          "  print(y);\n"
          "}",
      'answers': [
        "A) 5",
        "B) 6", 
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0, // Answer A is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<String> fruits = ['apple', 'banana'];\n"
          "  fruits.add('orange');\n"
          "  print(fruits.length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 4", 
        "C) 3",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int a = 10;\n"
          "  int b = 3;\n"
          "  print(a ~/ b);\n"
          "}",
      'answers': [
        "A) 3.33",
        "B) 3", 
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  bool flag = true;\n"
          "  print(!flag);\n"
          "}",
      'answers': [
        "A) true",
        "B) false", 
        "C) null",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  Map<String, int> ages = {'John': 25, 'Jane': 30};\n"
          "  print(ages['John']);\n"
          "}",
      'answers': [
        "A) John",
        "B) 25", 
        "C) null",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String text = 'Hello';\n"
          "  print(text.toUpperCase());\n"
          "}",
      'answers': [
        "A) hello",
        "B) HELLO", 
        "C) Hello",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> nums = [1, 2, 3, 4, 5];\n"
          "  print(nums.where((n) => n > 3).length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 3", 
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0, // Answer A is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int? value;\n"
          "  print(value ?? 42);\n"
          "}",
      'answers': [
        "A) null",
        "B) 42", 
        "C) 0",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  Set<String> colors = {'red', 'blue', 'red'};\n"
          "  print(colors.length);\n"
          "}",
      'answers': [
        "A) 2",
        "B) 3", 
        "C) 4",
        "D) Error"
      ],
      'correctAnswer': 0, // Answer A is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  String name = 'Dart';\n"
          "  print(name.substring(1, 3));\n"
          "}",
      'answers': [
        "A) Da",
        "B) ar", 
        "C) rt",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<int> numbers = [1, 2, 3];\n"
          "  numbers.removeAt(1);\n"
          "  print(numbers);\n"
          "}",
      'answers': [
        "A) [1, 3]",
        "B) [2, 3]", 
        "C) [1, 2]",
        "D) Error"
      ],
      'correctAnswer': 0, // Answer A is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  int x = 10;\n"
          "  int y = 20;\n"
          "  print(x > y ? 'Greater' : 'Smaller');\n"
          "}",
      'answers': [
        "A) Greater",
        "B) Smaller", 
        "C) Equal",
        "D) Error"
      ],
      'correctAnswer': 1, // Answer B is correct
    },
    {
      'question': "What will be the output of this Dart code?\n\n"
          "void main() {\n"
          "  List<String> items = ['a', 'b', 'c'];\n"
          "  print(items.join('-'));\n"
          "}",
      'answers': [
        "A) a-b-c",
        "B) abc", 
        "C) a,b,c",
        "D) Error"
      ],
      'correctAnswer': 0, // Answer A is correct
    },
  ];
  

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isQuizCompleted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isQuizCompleted = true;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  void _nextQuestion() {
    int correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    if (selectedAnswer == correctAnswer) {
      correctCount++;
    } else {
      wrongCount++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        isAnswered = false;
        hoveredAnswer = null; // Reset hover state
      });
    } else {
      // Quiz finished - stop timer and show Done button
      _stopTimer();
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _onDone() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => quiz1end(
          correct: correctCount,
          wrong: wrongCount,
          timeTaken: _secondsElapsed,
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/quiz.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/clock.png"),
                          const SizedBox(width: 10),
                          Text(
                            _formatTime(_secondsElapsed),
                            style: GoogleFonts.baloo2(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  width: 350,
                  height: 410,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "Question ${currentQuestionIndex + 1} of ${questions.length}",
                            style: GoogleFonts.baloo2(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            questions[currentQuestionIndex]['question'],
                            style: GoogleFonts.baloo2(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Answer options in 2x2 grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnswerContainer(0, questions[currentQuestionIndex]['answers'][0]),
                    SizedBox(width: 20),
                    _buildAnswerContainer(1, questions[currentQuestionIndex]['answers'][1]),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnswerContainer(2, questions[currentQuestionIndex]['answers'][2]),
                    SizedBox(width: 20),
                    _buildAnswerContainer(3, questions[currentQuestionIndex]['answers'][3]),
                  ],
                ),
                // Next/Done button logic
                if (isAnswered) ...[
                  SizedBox(height: 30),
                  if (currentQuestionIndex < questions.length - 1)
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Next Question",
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Done",
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          top: 70,
          right: 16,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const quiz2())),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '×',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildAnswerContainer(int answerIndex, String answerText) {
    Color containerColor = Colors.white;
    int correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    
    if (isAnswered) {
      if (selectedAnswer == answerIndex) {
        // Show green if correct answer was selected, red if wrong
        containerColor = answerIndex == correctAnswer 
            ? const Color.fromARGB(255, 0, 255, 8)  // Green for correct
            : const Color.fromARGB(255, 255, 17, 0); // Red for wrong
      } else if (answerIndex == correctAnswer) {
        // Show green for correct answer even if not selected
        containerColor = const Color.fromARGB(255, 0, 255, 8);
      }
    } else if (hoveredAnswer == answerIndex) {
      // Show blue on hover (only when not answered)
      containerColor = Colors.blue;
    }

    return MouseRegion(
      onEnter: (_) {
        if (!isAnswered) {
          setState(() {
            hoveredAnswer = answerIndex;
          });
        }
      },
      onExit: (_) {
        if (!isAnswered) {
          setState(() {
            hoveredAnswer = null;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          if (!isAnswered) {
            setState(() {
              selectedAnswer = answerIndex;
              isAnswered = true;
              hoveredAnswer = null; // Clear hover when answered
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 150,
          height: 80,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              answerText,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

}