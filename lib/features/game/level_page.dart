import 'package:flutter/material.dart';
import 'package:hellochickgu/features/game/quiz1.dart';
import 'package:hellochickgu/features/game/quiz2.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/quiz3.dart';
import 'package:hellochickgu/features/game/quiz4.dart';
import 'package:hellochickgu/features/game/training_page.dart';
import 'package:hellochickgu/map.dart';
import 'package:hellochickgu/services/quiz_service.dart';
import 'package:hellochickgu/features/game/quiz_review.dart';
import 'package:hellochickgu/features/game/quiz_bank.dart';

class LevelPage extends StatefulWidget {
  final int? initialHighestUnlockedLevel;
  final int? completedLevel;

  const LevelPage({
    super.key,
    this.initialHighestUnlockedLevel,
    this.completedLevel,
  });

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  int highestUnlockedLevel = 1;
  bool _trainingSelected = false;
  Set<int> completedLevels = {}; // Track completed levels

  void _openTraining() {
    Navigator.of(
      context,
    )
        .push(
          MaterialPageRoute(
            builder: (context) => const TrainingPage(),
          ),
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _trainingSelected = false;
        });
      }
    });
  }

  void _onTapLevel(int level) {
    // For levels 5+, always open the unified popup (Coming Soon layout inside)
    if (level >= 5) {
      _showLevelPopup(context, level);
      return;
    }

    // For levels 1-4, only allow access to unlocked levels
    if (level <= highestUnlockedLevel) {
      _showLevelPopup(context, level);
    }
  }

  void _completeLevel(int level) {
    // Mark level as completed
    setState(() {
      completedLevels.add(level);
    });

    // Stop progression at level 4. Show Coming Soon after finishing level 4.
    if (level >= 4) {
      setState(() {
        highestUnlockedLevel = highestUnlockedLevel.clamp(1, 4);
      });
      _showComingSoonDialog();
      return;
    }

    // Only unlock next level if current level was completed and below cap
    if (level == highestUnlockedLevel && level < 4) {
      setState(() {
        highestUnlockedLevel += 1;
      });
    }
  }

  void _showLevelPopup(BuildContext context, int level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // For level 5+, show Coming Soon with same popup layout
        if (level >= 5) {
            return LevelCompletionPopup(
            level: level,
            isCompleted: true,
            onStartGame: () {
              Navigator.of(context).pop();
            },
            overridePointsText: '---',
            overrideTimeText: '---',
            startLabel: 'Coming Soon',
            isComingSoon: true,
            imageAssetOverride: 'assets/comingsoon.png',
            disableStart: false,
              onClose: () {
                Navigator.of(context).pop();
              },
          );
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: QuizService.instance.getLevelSummaryOrResult(level: level),
          builder: (context, snapshot) {
            final hasResult = snapshot.hasData && snapshot.data != null;
            final data = snapshot.data;
            final pointsText = hasResult ? (data!['points_collected'] ?? '-') .toString() : '---';
            final timeText = hasResult ? _formatSeconds(((data!['time_taken_seconds'] ?? 0) as num).toInt()) : '---';
            return LevelCompletionPopup(
              level: level,
              isCompleted: hasResult,
              onStartGame: hasResult ? () => _openReview(level, data!) : () => _navigateToQuiz(level),
              overridePointsText: pointsText,
              overrideTimeText: timeText,
              startLabel: hasResult ? 'Review Questions' : 'Start Game!',
              onClose: () {
                Navigator.of(context).pop();
                // After closing, go to next level if this level is completed
                if (hasResult) {
                  final int nextLevel = level + 1;
                  // If next is <= 4 open its popup, otherwise show Coming Soon popup
                  if (nextLevel <= 4) {
                    _onTapLevel(nextLevel);
                  } else {
                    _showLevelPopup(context, 5);
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _navigateToQuiz(int level) {
    // Block navigation for levels beyond 4
    if (level >= 5) {
      Navigator.of(context).maybePop();
      _showComingSoonDialog();
      return;
    }

    Navigator.of(context).pop(); // Close popup
    Widget destination;
    if (level == 2) {
      destination = const quiz2();
    } else if (level == 3) {
      destination = const quiz3();
    } else if (level == 4) {
      destination = const quiz4();
    } else {
      destination = quiz1(level: level);
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => destination)).then((_) {
      _completeLevel(level);
      // Refresh highest unlocked level from server after returning
      QuizService.instance.getHighestUnlockedLevel().then((lvl) {
        if (!mounted) return;
        setState(() {
          // Cap at level 4 for now
          highestUnlockedLevel = lvl.clamp(1, 4);
        });
      });
    });
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('You\'ve reached the current end of the journey. More levels are coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openReview(int level, Map<String, dynamic> result) {
    Navigator.of(context).pop();
    // Navigate to appropriate review UI based on level
    // Fetch detailed answers from quiz_results
    QuizService.instance.getLatestQuizResult(quizNumber: level).then((detail) {
      if (!mounted) return;
      if (detail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved answers found to review.')),
        );
        return;
      }
      if (level == 1) {
        // Prefer built-in bank for consistent layout
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizReviewPage(
              questions: quiz1Questions(),
              selectedAnswers: List<dynamic>.from(detail['answers'] ?? []),
            ),
          ),
        );
      } else if (level == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizReviewPage(
              questions: quiz2Questions(),
              selectedAnswers: List<dynamic>.from(detail['answers'] ?? []),
            ),
          ),
        );
      } else if (level == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizReviewPage(
              questions: quiz3Questions(),
              selectedAnswers: List<dynamic>.from(detail['answers'] ?? []),
            ),
          ),
        );
      } else if (level == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizReviewPage(
              questions: quiz4Questions(),
              selectedAnswers: List<dynamic>.from(detail['answers'] ?? []),
            ),
          ),
        );
      }
    });
  }

  void _openComputerScienceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _SearchSubjectsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundgame.png', fit: BoxFit.cover),
          // Top controls as a sticky app bar row
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: Responsive.scaleWidth(context, 8),
                  right: Responsive.scaleWidth(context, 8),
                  top: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _openComputerScienceModal,
                          child: Container(
                            padding: Responsive.scalePaddingSymmetric(
                              context,
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4B942),
                              borderRadius: Responsive.scaleBorderRadiusAll(
                                context,
                                8,
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Computer Science',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.home_outlined, size: 20),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MapChickgu(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Level bubbles positioned along the path
                _LevelMap(
                  highestUnlockedLevel: highestUnlockedLevel,
                  onTapLevel: _onTapLevel,
                ),

                // Bottom pill buttons
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BottomPill(
                          label: 'Level',
                          background:
                              _trainingSelected
                                  ? Colors.grey.shade700
                                  : const Color(0xFFFFB6C1),
                          textColor: Colors.black,
                          borderColor: _trainingSelected ? null : Colors.white,
                          borderWidth: _trainingSelected ? null : 2,
                          height: 50,
                          onTap: () {
                            if (_trainingSelected) {
                              setState(() {
                                _trainingSelected = false;
                              });
                            }
                          },
                        ),
                        _BottomPill(
                          label: 'Training',
                          background:
                              _trainingSelected
                                  ? const Color(0xFFFFB6C1)
                                  : Colors.grey.shade300,
                          textColor: Colors.black,
                          borderColor: _trainingSelected ? Colors.white : null,
                          borderWidth: _trainingSelected ? 2 : null,
                          height: 50,
                          onTap: () {
                            if (!_trainingSelected) {
                              setState(() {
                                _trainingSelected = true;
                              });
                            }
                            _openTraining();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialHighestUnlockedLevel != null) {
      highestUnlockedLevel = widget.initialHighestUnlockedLevel!.clamp(1, 11);
    }
    if (widget.completedLevel != null) {
      completedLevels.add(widget.completedLevel!.clamp(1, 11));
    }
    // Also fetch latest unlocked level from Firestore to preserve progress across navigation
    QuizService.instance.getHighestUnlockedLevel().then((lvl) {
      if (!mounted) return;
      setState(() {
        highestUnlockedLevel = lvl.clamp(1, 11);
      });
    });
  }
}

class _LevelMap extends StatelessWidget {
  final int highestUnlockedLevel;
  final void Function(int level) onTapLevel;

  const _LevelMap({
    required this.highestUnlockedLevel,
    required this.onTapLevel,
  });

  @override
  Widget build(BuildContext context) {
    const double bubbleSize = 56;
    final List<Offset> levelPositions = [
      const Offset(0.3, 0.8), // 1
      const Offset(0.59, 0.802), // 2
      const Offset(0.89, 0.7), // 3
      const Offset(0.62, 0.65), // 4
      const Offset(0.3, 0.635), // 5
      const Offset(0.27, 0.5), // 6
      const Offset(0.6, 0.47), // 7
      const Offset(0.81, 0.39), // 8
      const Offset(0.85, 0.29), // 9
      const Offset(0.6, 0.23), // 10
      const Offset(0.2, 0.17),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final int currentIndex = (highestUnlockedLevel - 1).clamp(
          0,
          levelPositions.length - 1,
        );
        // current position computed implicitly where needed

        return Stack(
          children: [
            // Levels placed following the lane (chicken over current level)
            for (int i = 0; i < levelPositions.length; i++)
              Positioned(
                left: width * levelPositions[i].dx - bubbleSize * 0.5,
                top: height * levelPositions[i].dy - bubbleSize * 0.5,
                child: _LevelBubbleFrac(
                  level: i + 1,
                  size: bubbleSize,
                  unlocked: (i + 1) <= highestUnlockedLevel,
                  onTap: onTapLevel,
                  showChicken: i == currentIndex,
                ),
              ),
          ],
        );
      },
    );
  }
}

// Removed old absolute-position bubble widget; now using fraction-based positions.

class _LevelBubbleFrac extends StatelessWidget {
  final int level;
  final double size;
  final bool unlocked;
  final void Function(int level) onTap;
  final bool showChicken;

  const _LevelBubbleFrac({
    required this.level,
    required this.size,
    required this.unlocked,
    required this.onTap,
    this.showChicken = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor = unlocked ? const Color(0xFF4FC3F7) : Colors.white;
    final Color ringColor = unlocked ? Colors.white : const Color(0xFF4FC3F7);
    final Color numberColor = unlocked ? Colors.white : const Color(0xFF4FC3F7);

    // bubble is inlined below to allow dynamic colors

    return Opacity(
      opacity: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () => onTap(level),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Bubble with correct color scheme
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: fillColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: ringColor, width: 3),
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: TextStyle(
                    color: numberColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (showChicken)
              Positioned(
                bottom: size * 0.6,
                child: Builder(
                  builder: (context) {
                    final bool shouldFlip =
                        level == 4 || level == 5 || level == 9 || level == 10;
                    final Widget chicken = _AnimatedChicken(
                      image: Image.asset(
                        'assets/chickenLevel.png',
                        width: size * 0.9,
                        height: size * 0.9,
                      ),
                    );
                    return shouldFlip
                        ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                          child: chicken,
                        )
                        : chicken;
                  },
                ),
              ),
            Positioned(
              right: -2,
              top: -2,
              child:
                  unlocked
                      ? const SizedBox.shrink()
                      : const Icon(
                        Icons.lock,
                        size: 18,
                        color: Color(0xFF4FC3F7),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;
  final Color? borderColor;
  final double? borderWidth;
  final double? height;

  const _BottomPill({
    required this.label,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
    this.borderWidth,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border:
              (borderColor != null && borderWidth != null)
                  ? Border.all(color: borderColor!, width: borderWidth!)
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SearchSubjectsSheet extends StatefulWidget {
  const _SearchSubjectsSheet();

  @override
  State<_SearchSubjectsSheet> createState() => _SearchSubjectsSheetState();
}

class _SearchSubjectsSheetState extends State<_SearchSubjectsSheet> {
  final TextEditingController _queryController = TextEditingController();
  final List<String> subjects = const [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Software Engineering',
    'Data Structures',
    'Algorithms',
    'Operating Systems',
    'Databases',
    'Networks',
  ];

  @override
  Widget build(BuildContext context) {
    final String q = _queryController.text.toLowerCase();
    final List<String> filtered =
        subjects.where((s) => s.toLowerCase().contains(q)).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Text(
                'Search Subjects & Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search subject or course...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final String item = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.book_outlined),
                      title: Text(item),
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LevelCompletionPopup extends StatefulWidget {
  final int level;
  final bool isCompleted;
  final VoidCallback onStartGame;
  final String? overridePointsText;
  final String? overrideTimeText;
  final String? startLabel;
  final bool isComingSoon;
  final String? imageAssetOverride;
  final String? titleOverride;
  final bool disableStart;
  final VoidCallback? onClose;

  const LevelCompletionPopup({
    super.key,
    required this.level,
    required this.isCompleted,
    required this.onStartGame,
    this.overridePointsText,
    this.overrideTimeText,
    this.startLabel,
    this.isComingSoon = false,
    this.imageAssetOverride,
    this.titleOverride,
    this.disableStart = false,
    this.onClose,
  });

  @override
  State<LevelCompletionPopup> createState() => _LevelCompletionPopupState();
}

class _LevelCompletionPopupState extends State<LevelCompletionPopup>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = Responsive.isSmallScreen(context);
    final isVerySmallScreen = Responsive.isVerySmallScreen(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              width:
                  isVerySmallScreen
                      ? screenSize.width * 0.9
                      : isSmallScreen
                      ? screenSize.width * 0.85
                      : Responsive.scaleWidth(context, 320),
              constraints: BoxConstraints(
                maxHeight:
                    isVerySmallScreen
                        ? screenSize.height * 0.8
                        : isSmallScreen
                        ? screenSize.height * 0.85
                        : screenSize.height * 0.9,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFFF8E1)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFFF4B942).withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content - make it scrollable with top padding for close button
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: Responsive.scaleHeight(
                          context,
                          70,
                        ), // Space for close button
                        left: Responsive.scaleWidth(context, 25),
                        right: Responsive.scaleWidth(context, 25),
                        bottom: Responsive.scaleHeight(context, 25),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top image (supports coming soon override)
                          Container(
                            width: Responsive.scaleWidth(context, widget.isComingSoon ? 170 : 130),
                            height: Responsive.scaleHeight(context, widget.isComingSoon ? 170 : 130),
                            child: ClipOval(
                              child: Image.asset(
                                widget.imageAssetOverride ??
                                    (widget.isComingSoon
                                        ? 'assets/comingsoon.png'
                                        : 'assets/chickenHappy.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 15 : 25),

                          // Title with cute styling (supports coming soon override)
                          Container(
                            padding: Responsive.scalePaddingSymmetric(
                              context,
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                              ),
                              borderRadius: Responsive.scaleBorderRadiusAll(
                                context,
                                20,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.titleOverride ?? 'Level ${widget.level}',
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontSize: Responsive.scaleFont(context, 26),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 15 : 25),

                          // Points removed for Coming Soon
                          if (!widget.isComingSoon) Container(
                            padding: Responsive.scalePaddingSymmetric(
                              context,
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF4B942).withOpacity(0.2),
                                  const Color(0xFFFFD54F).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: Responsive.scaleBorderRadiusAll(
                                context,
                                16,
                              ),
                              border: Border.all(
                                color: const Color(0xFFF4B942),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: const Color(0xFFF4B942),
                                  size: Responsive.scaleFont(context, 24),
                                ),
                                SizedBox(
                                  width: Responsive.scaleWidth(context, 8),
                                ),
                                Text(
                                  widget.isCompleted
                                      ? 'Points: ${widget.overridePointsText ?? '---'}'
                                      : 'Points: ---',
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontSize: Responsive.scaleFont(context, 20),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 10 : 15),

                          // Time removed for Coming Soon
                          if (!widget.isComingSoon) Container(
                            padding: Responsive.scalePaddingSymmetric(
                              context,
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF4FC3F7).withOpacity(0.2),
                                  const Color(0xFF29B6F6).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: Responsive.scaleBorderRadiusAll(
                                context,
                                16,
                              ),
                              border: Border.all(
                                color: const Color(0xFF4FC3F7),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: const Color(0xFF4FC3F7),
                                  size: Responsive.scaleFont(context, 24),
                                ),
                                SizedBox(
                                  width: Responsive.scaleWidth(context, 8),
                                ),
                                Text(
                                  widget.isCompleted
                                      ? 'Time Taken: ${widget.overrideTimeText ?? '---'}'
                                      : 'Time Taken: ---',
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontSize: Responsive.scaleFont(context, 20),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Start game button (disabled for coming soon)
                          GestureDetector(
                            onTap: widget.disableStart ? null : widget.onStartGame,
                            child: Container(
                              width: double.infinity,
                              padding: Responsive.scalePaddingSymmetric(
                                context,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: widget.disableStart
                                    ? Colors.grey.shade400
                                    : const Color(0xFFF4B942),
                                borderRadius: Responsive.scaleBorderRadiusAll(
                                  context,
                                  16,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.startLabel ?? (widget.isComingSoon ? 'Coming Soon' : 'Start Game!'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Baloo2',
                                  color: Colors.white,
                                  fontSize: Responsive.scaleFont(context, 20),
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Neatly positioned sparkles with random timing
                  ...List.generate(36, (index) {
                    // Create a neat grid pattern but with slight randomization
                    final int cols = 6;
                    final int row = index ~/ cols;
                    final int col = index % cols;

                    // Base grid positions with some randomization - make responsive
                    final double baseX = Responsive.scaleWidth(
                      context,
                      (col * 50.0) + 15,
                    );
                    final double baseY = Responsive.scaleHeight(
                      context,
                      (row * 30.0) + 10,
                    );

                    // Add slight randomization to make it look more natural
                    final double randomOffsetX = Responsive.scaleWidth(
                      context,
                      (index * 7.3) % 20.0 - 10.0,
                    );
                    final double randomOffsetY = Responsive.scaleHeight(
                      context,
                      (index * 11.7) % 15.0 - 7.5,
                    );

                    final double finalX = baseX + randomOffsetX;
                    final double finalY = baseY + randomOffsetY;

                    // Ensure stars stay within bounds and avoid chicken area
                    final double chickenCenterX = Responsive.scaleWidth(
                      context,
                      160,
                    );
                    final double chickenCenterY = Responsive.scaleHeight(
                      context,
                      155,
                    );
                    final double chickenRadius = Responsive.scaleWidth(
                      context,
                      75,
                    );

                    final double distanceFromChicken =
                        ((finalX - chickenCenterX) * (finalX - chickenCenterX) +
                            (finalY - chickenCenterY) *
                                (finalY - chickenCenterY));

                    // If too close to chicken, move to a safe position
                    if (distanceFromChicken < (chickenRadius * chickenRadius)) {
                      // Move to edges of the container
                      final double safeX =
                          finalX < chickenCenterX
                              ? Responsive.scaleWidth(context, 20.0)
                              : Responsive.scaleWidth(context, 280.0);
                      final double safeY =
                          finalY < chickenCenterY
                              ? Responsive.scaleHeight(context, 20.0)
                              : Responsive.scaleHeight(context, 180.0);

                      return Positioned(
                        left: safeX,
                        top: safeY,
                        child: _RandomStarAnimation(
                          index: index,
                          size: Responsive.scaleFont(context, 12 + (index % 6)),
                        ),
                      );
                    }

                    // Create individual animation for each star with random timing
                    return Positioned(
                      left: finalX,
                      top: finalY,
                      child: _RandomStarAnimation(
                        index: index,
                        size: Responsive.scaleFont(context, 12 + (index % 6)),
                      ),
                    );
                  }),

                  // Close button - positioned at the very end for highest z-index
                  Positioned(
                    top: Responsive.scaleHeight(context, 10),
                    right: Responsive.scaleWidth(context, 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: Responsive.scaleBorderRadiusAll(
                          context,
                          20,
                        ),
                        child: Container(
                          width: Responsive.scaleWidth(context, 40),
                          height: Responsive.scaleHeight(context, 40),
                          decoration: BoxDecoration(
                            borderRadius: Responsive.scaleBorderRadiusAll(
                              context,
                              20,
                            ),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/xbutton.png',
                              width: Responsive.scaleWidth(context, 24),
                              height: Responsive.scaleHeight(context, 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RandomStarAnimation extends StatefulWidget {
  final int index;
  final double size;

  const _RandomStarAnimation({required this.index, required this.size});

  @override
  State<_RandomStarAnimation> createState() => _RandomStarAnimationState();
}

class _RandomStarAnimationState extends State<_RandomStarAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create unique animation timing for each star
    final double randomDelay =
        (widget.index * 0.3) % 2.0; // Random delay up to 2 seconds
    final double randomDuration =
        1.5 +
        (widget.index * 0.2) % 1.5; // Random duration between 1.5-3 seconds

    _controller = AnimationController(
      duration: Duration(milliseconds: (randomDuration * 1000).round()),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation with random delay
    Future.delayed(Duration(milliseconds: (randomDelay * 1000).round()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 6.28,
          child: Opacity(
            opacity: 0.1 + (0.9 * _animation.value),
            child: Icon(
              Icons.star,
              color: const Color(0xFFF4B942),
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedChicken extends StatefulWidget {
  final Widget image;

  const _AnimatedChicken({required this.image});

  @override
  State<_AnimatedChicken> createState() => _AnimatedChickenState();
}

class _AnimatedChickenState extends State<_AnimatedChicken>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ), // 0.8 seconds for super fast, energetic movement
      vsync: this,
    );

    // Vertical floating movement
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -15.0, // Move up 15 pixels (more noticeable movement)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Horizontal wiggling movement
    _wiggleAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0, // Wiggle left and right (more range)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Slight rotation for more dynamic movement
    _rotateAnimation = Tween<double>(
      begin: -0.15, // More noticeable left tilt
      end: 0.15, // More noticeable right tilt
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true); // Continuous movement
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_wiggleAnimation.value, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: widget.image,
          ),
        );
      },
    );
  }
}

