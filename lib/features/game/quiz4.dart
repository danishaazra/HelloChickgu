import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/quiz4end.dart';
import 'package:hellochickgu/features/game/level_page.dart';
import 'package:hellochickgu/services/quiz_service.dart';

class quiz4 extends StatefulWidget {
  const quiz4({super.key});

  @override
  State<quiz4> createState() => _Quiz4State();
}

class _Quiz4State extends State<quiz4> {
  // Fixed 15 answer tiles that remain the same throughout the game
  static const List<String> fixedTiles = [
     'Queue',
    'Binary Search', 
    'Stack',
    'MongoDB',
    'Application Programming Interface',
    'Structured Query Language',
    'Merge Sort',
    'O(log n)',
    'O(n²)',
    'Cascading Style Sheets',
    'Singleton',
    'HTTPS',
    'Git',
    '2ʰ⁺¹ - 1',
    'Not Found',
  ];

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which algorithm has O(log n) time complexity for search operations?',
      'correctTileIndex': 1, // Binary Search
    },
    {
      'question': 'What does HTTP status code 404 mean?',
      'correctTileIndex': 14, // Not Found (random position)
    },
    {
      'question': 'Which data structure follows LIFO principle?',
      'correctTileIndex': 2, // Stack
    },
    {
      'question': 'What is the time complexity of quicksort in the worst case?',
      'correctTileIndex': 8, // O(n²) (random position)
    },
    {
      'question': 'Which protocol is used for secure web communication?',
      'correctTileIndex': 11, // HTTPS (random position)
    },
    {
      'question': 'What does SQL stand for?',
      'correctTileIndex': 5, // Structured Query Language
    },
    {
      'question': 'Which sorting algorithm is stable?',
      'correctTileIndex': 6, // Merge Sort
    },
    {
      'question': 'What is the maximum number of nodes in a binary tree of height h?',
      'correctTileIndex': 13, // 2ʰ⁺¹ - 1 (random position)
    },
    {
      'question': 'Which is a NoSQL database?',
      'correctTileIndex': 3, // MongoDB (random position)
    },
    {
      'question': 'What does CSS stand for?',
      'correctTileIndex': 9, // Cascading Style Sheets
    },
    {
      'question': 'Which is a design pattern?',
      'correctTileIndex': 10, // Singleton
    },
    {
      'question': 'What is the time complexity of binary search?',
      'correctTileIndex': 7, // O(log n) (random position)
    },
    {
      'question': 'Which is a version control system?',
      'correctTileIndex': 12, // Git
    },
    {
      'question': 'What does API stand for?',
      'correctTileIndex': 4, // Application Programming Interface (random position)
    },
    {
      'question': 'Which data structure is used in breadth-first search?',
      'correctTileIndex': 0, // Queue (random position)
    },
  ];

  int current = 0;
  int correct = 0;
  int wrong = 0;
  int _secondsElapsed = 0;
  Timer? _timer;

  // UI state
  int? tappedIndex; // which tile user tapped
  bool showWrong = false; // temp red feedback
  bool showRight = false; // green feedback
  bool showLightGreen = false; // light green for correct tile after 0.5s
  Set<int> permanentBlueTiles = {}; // tiles that are permanently blue (correctly answered)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onTapOption(int index) {
    if (tappedIndex != null || permanentBlueTiles.contains(index)) return; // avoid multiple taps and prevent tapping blue tiles
    final int correctTileIndex = questions[current]['correctTileIndex'] as int;
    setState(() {
      tappedIndex = index;
      showRight = index == correctTileIndex;
      showWrong = index != correctTileIndex;
    });
    
    if (index == correctTileIndex) {
      correct++;
      // Show green for 0.5s, then light green, then blue (permanent), then advance
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          showRight = false;
          showLightGreen = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showLightGreen = false;
            permanentBlueTiles.add(index); // Make tile permanently blue
          });
          Future.delayed(const Duration(milliseconds: 700), _nextQuestion);
        });
      });
    } else {
      wrong++;
      // show red for ~2 seconds then advance and reset tile color
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _nextQuestion() {
    if (current < questions.length - 1) {
      setState(() {
        current++;
        tappedIndex = null;
        showWrong = false;
        showRight = false;
        showLightGreen = false; // reset light green state
        // Keep permanentBlueTiles - don't reset them
      });
    } else {
      _stopTimer();
      // Save result
      final points = correct * 10;
      QuizService.instance.saveQuizResult(
        quizNumber: 4,
        correct: correct,
        incorrect: wrong,
        pointsCollected: points,
        answers: List<String?>.from(questions.map((q) => (q['correctTileIndex']).toString())),
        timeTakenSeconds: _secondsElapsed,
      );
      QuizService.instance.saveLevelSummary(
        level: 4,
        pointsCollected: points,
        timeTakenSeconds: _secondsElapsed,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => quiz4end(
            correct: correct,
            wrong: wrong,
            timeTaken: _secondsElapsed,
            level: 4,
            questions: questions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSmallScreen = Responsive.isSmallScreen(context);

    final q = questions[current];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                  SizedBox(height: isSmallScreen ? 20 : 40),
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
                                    "Question ${current + 1} of ${questions.length}",
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
                                        style: const TextStyle(
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
                                    _timer?.cancel();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => LevelPage(
                                          initialHighestUnlockedLevel: 4, // Current level
                                          completedLevel: null, // Don't mark as completed since quitting early
                                        ),
                                      ),
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
                                      child: Image.asset('assets/xbutton.png', fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (current + 1) / questions.length,
                                minHeight: 10,
                                backgroundColor: Colors.green.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
              // Question container (fixed size)
              Container(
                width: Responsive.scaleWidth(context, 360),
                height: 140, // Fixed height to prevent tiles from moving
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    q['question'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
                  const SizedBox(height: 20),
                  // 15-tile grid (5 rows x 3 columns) - fixed tiles
                  Container(
                    width: Responsive.scaleWidth(context, 360),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 15,
                      itemBuilder: (context, i) {
                        final bool isTapped = tappedIndex == i;
                        final String tileValue = fixedTiles[i];
                        final int correctTileIndex = questions[current]['correctTileIndex'] as int;
                        final bool isPermanentBlue = permanentBlueTiles.contains(i);
                        
                        Color bg = Colors.white;
                        Color textColor = Colors.black87;
                        bool isClickable = true;
                        
                        if (isPermanentBlue) {
                          bg = Colors.blue;
                          textColor = Colors.white;
                          isClickable = false;
                        } else if (isTapped && showWrong) {
                          bg = Colors.red;
                          textColor = Colors.white;
                        } else if (isTapped && showRight) {
                          bg = Colors.green;
                          textColor = Colors.white;
                        } else if (showLightGreen && i == correctTileIndex) {
                          bg = Colors.lightGreen;
                          textColor = Colors.white;
                        }
                        
                        return GestureDetector(
                          onTap: isClickable ? () => _onTapOption(i) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isTapped || isPermanentBlue ? Colors.black : Colors.black26, 
                                width: 1
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tileValue,
                                style: TextStyle(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 80 : 120),
                ],
              ),
            ),
          ),
          // back/next buttons removed
        ],
      ),
    );
  }
}


