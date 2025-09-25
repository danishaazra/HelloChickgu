
import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/services/quiz_service.dart';
import 'package:hellochickgu/features/game/level_page.dart';
// import removed: was used by old close button
import 'package:hellochickgu/features/game/quiz1end.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';

import 'dart:async';


class quiz1 extends StatefulWidget {
  final int level;
  const quiz1({super.key, this.level = 1});

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
  late List<int?> selectedAnswers;
  // Progress no longer shown in UI
  // double get _progress => (currentQuestionIndex + 1) / questions.length;
  
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
    selectedAnswers = List<int?>.filled(questions.length, null);
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
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = selectedAnswers[currentQuestionIndex];
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

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        selectedAnswer = selectedAnswers[currentQuestionIndex];
        hoveredAnswer = null;
      });
    }
  }

  void _onDone() {
    // Calculate scores only at the end
    correctCount = 0;
    wrongCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final int? userAnswer = selectedAnswers[i];
      final int correctAnswer = questions[i]['correctAnswer'];
      if (userAnswer != null && userAnswer == correctAnswer) {
        correctCount++;
      }
    }
    wrongCount = questions.length - correctCount;
    // Save result
    final points = correctCount * 10; // simple scoring: 10 per correct
    QuizService.instance.saveQuizResult(
      quizNumber: 1,
      correct: correctCount,
      incorrect: wrongCount,
      pointsCollected: points,
      answers: selectedAnswers,
      timeTakenSeconds: _secondsElapsed,
    );
    QuizService.instance.saveLevelSummary(
      level: widget.level,
      pointsCollected: points,
      timeTakenSeconds: _secondsElapsed,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => quiz1end(
          correct: correctCount,
          wrong: wrongCount,
          timeTaken: _secondsElapsed,
          questions: questions,
          selectedAnswers: selectedAnswers,
          level: widget.level,
        ),
      ),
    );
  }

  @override
 Widget build(BuildContext context) {
   final theme = Theme.of(context);
   final cs = theme.colorScheme;
   final isSmallScreen = Responsive.isSmallScreen(context);
   final isVerySmallScreen = Responsive.isVerySmallScreen(context);
   
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
        // Soft gradient overlay to make content pop and look cute
        // Removed glowing gradient overlay to keep background flat per request
        SingleChildScrollView(
          child: Center(
            child: Column(
               children: [
                 SizedBox(height: isSmallScreen ? 20 : 40),
                 // Top row: header container + side-by-side X button
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Container(
                       width: Responsive.scaleWidth(context, 360),
                        padding: Responsive.scalePaddingSymmetric(context, horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: Responsive.scaleBorderRadiusAll(context, 24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Question ${currentQuestionIndex + 1} of ${questions.length}",
                                    style: TextStyle(
                                  fontFamily: 'Baloo2',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset("assets/clock.png", width: 28, height: 28),
                                      const SizedBox(width: 10),
                                      Text(
                                        _formatTime(_secondsElapsed),
                                        style: TextStyle(
                                  fontFamily: 'Baloo2',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const LevelPage()),
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'assets/xbutton.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (currentQuestionIndex + 1) / questions.length,
                                minHeight: 10,
                                backgroundColor: Colors.green.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                 SizedBox(height: isSmallScreen ? 8 : 16),
                 Container(
                   width: Responsive.scaleWidth(context, 360),
                   height: isVerySmallScreen ? 300 : (isSmallScreen ? 350 : Responsive.scaleHeight(context, 370)),
                  decoration: BoxDecoration(
                    color: cs.surface,
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("💡", style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  "Let’s think about this",
                                  style: TextStyle(
                                  fontFamily: 'Baloo2',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            questions[currentQuestionIndex]['question'],
                            style: TextStyle(
                              fontFamily: 'Baloo2',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: isSmallScreen ? 15 : 30),
                 // Answer options in 2x2 grid
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     _buildAnswerContainer(0, questions[currentQuestionIndex]['answers'][0]),
                     SizedBox(width: Responsive.scaleWidth(context, 20)),
                     _buildAnswerContainer(1, questions[currentQuestionIndex]['answers'][1]),
                   ],
                 ),
                 SizedBox(height: isSmallScreen ? 10 : 20),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     _buildAnswerContainer(2, questions[currentQuestionIndex]['answers'][2]),
                     SizedBox(width: Responsive.scaleWidth(context, 20)),
                     _buildAnswerContainer(3, questions[currentQuestionIndex]['answers'][3]),
                   ],
                 ),
                 SizedBox(height: isSmallScreen ? 80 : 120), // bottom padding so fixed buttons don't cover content
              ],
            ),
          ),
        ),
        // Removed duplicate top X button (now inside header row)
        // Fixed bottom navigation so buttons are always visible without scrolling
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow button (hidden on first question)
                  if (currentQuestionIndex > 0)
                    GestureDetector(
                      onTap: _previousQuestion,
                      child: Container(
                        width: 64,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Transform.rotate(
                          angle: 3.1415926535,
                          child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64, height: 44),
                  // Center spacer
                  const SizedBox(width: 1),
                  // Right button: arrow on non-last pages; green Done on last
                  GestureDetector(
                    onTap: currentQuestionIndex < questions.length - 1 ? _nextQuestion : _onDone,
                    child: Container(
                      width: 64,
                      height: 44,
                      decoration: BoxDecoration(
                        color: currentQuestionIndex < questions.length - 1 ? AppTheme.primaryBlue : Colors.green,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: currentQuestionIndex < questions.length - 1
                          ? const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white)
                          : Center(
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  fontFamily: 'Baloo2',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
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

  Widget _buildAnswerContainer(int answerIndex, String answerText) {
    final bool isSelected = selectedAnswers[currentQuestionIndex] == answerIndex;
    final bool isHover = hoveredAnswer == answerIndex;
    final Color selectedColor = AppTheme.primaryYellow; // Use theme orange for all selected
    final isSmallScreen = Responsive.isSmallScreen(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredAnswer = answerIndex;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredAnswer = null;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (selectedAnswers[currentQuestionIndex] == answerIndex) {
              selectedAnswer = null;
              selectedAnswers[currentQuestionIndex] = null;
            } else {
              selectedAnswer = answerIndex;
              selectedAnswers[currentQuestionIndex] = answerIndex;
            }
            hoveredAnswer = null; // Clear hover when answered
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: isSelected ? 1.02 : 1.0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 220),
            width: Responsive.scaleWidth(context, 160),
            height: isSmallScreen ? 70 : 90,
            decoration: BoxDecoration(
              gradient: isSelected ? null : null,
              color: isSelected ? selectedColor : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : (isHover ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.black.withOpacity(0.06)),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode('A'.codeUnitAt(0) + answerIndex),
                      style: TextStyle(
                              fontFamily: 'Baloo2',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? selectedColor : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    answerText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                              fontFamily: 'Baloo2',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

