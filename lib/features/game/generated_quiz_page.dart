import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'dart:async';
import 'quiz_review.dart';
import 'folder_selection_dialog.dart';

class GeneratedQuizPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> questions;
  const GeneratedQuizPage({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<GeneratedQuizPage> createState() => _GeneratedQuizPageState();
}

class _GeneratedQuizPageState extends State<GeneratedQuizPage> {
  int current = 0;
  late List<int?> selected;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    selected = List<int?>.filled(widget.questions.length, null);
    _startTimer();
  }

  void _next() {
    if (current < widget.questions.length - 1) {
      setState(() => current++);
    } else {
      _stopTimer();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => QuizEndPage(
                timeTaken: _secondsElapsed,
                questions: widget.questions,
                selectedAnswers: selected,
                onSave: () {
                  // TODO: Save review set
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
        ),
      );
    }
  }

  void _prev() {
    if (current > 0) setState(() => current--);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isCompleted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isCompleted = true;
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remaining.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSmall = Responsive.isSmallScreen(context);
    final isVerySmall = Responsive.isVerySmallScreen(context);
    final q = widget.questions[current];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/quiz.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: isSmall ? 20 : 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: Responsive.scaleWidth(context, 360),
                        padding: Responsive.scalePaddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: Responsive.scaleBorderRadiusAll(
                            context,
                            24,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Question ${current + 1} of ${widget.questions.length}',
                                style: TextStyle(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/clock.png',
                                    width: 28,
                                    height: 28,
                                  ),
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
                              onTap: () => Navigator.pop(context),
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
                                  child: Image.asset('assets/xbutton.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmall ? 8 : 16),
                  Container(
                    width: Responsive.scaleWidth(context, 360),
                    height:
                        isVerySmall
                            ? 300
                            : (isSmall
                                ? 350
                                : Responsive.scaleHeight(context, 370)),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          q['question'],
                          style: const TextStyle(
                            fontFamily: 'Baloo2',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 15 : 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _answer(0, q['answers'][0]),
                      SizedBox(width: Responsive.scaleWidth(context, 20)),
                      _answer(1, q['answers'][1]),
                    ],
                  ),
                  SizedBox(height: isSmall ? 10 : 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _answer(2, q['answers'][2]),
                      SizedBox(width: Responsive.scaleWidth(context, 20)),
                      _answer(3, q['answers'][3]),
                    ],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
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
                    if (current > 0)
                      GestureDetector(
                        onTap: _prev,
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
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 64, height: 44),
                    const SizedBox(width: 1),
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: 64,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              current < widget.questions.length - 1
                                  ? AppTheme.primaryBlue
                                  : Colors.green,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child:
                            current < widget.questions.length - 1
                                ? const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 32,
                                  color: Colors.white,
                                )
                                : const Center(
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

  Widget _answer(int idx, String text) {
    final isSelected = selected[current] == idx;
    final cs = Theme.of(context).colorScheme;
    final isSmall = Responsive.isSmallScreen(context);
    return GestureDetector(
      onTap: () => setState(() => selected[current] = isSelected ? null : idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: Responsive.scaleWidth(context, 160),
        height: isSmall ? 70 : 90,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow : cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.primaryYellow
                    : Colors.black.withOpacity(0.06),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class QuizEndPage extends StatefulWidget {
  final int timeTaken;
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final VoidCallback onSave;

  const QuizEndPage({
    super.key,
    required this.timeTaken,
    required this.questions,
    required this.selectedAnswers,
    required this.onSave,
  });

  @override
  State<QuizEndPage> createState() => _QuizEndPageState();
}

class _QuizEndPageState extends State<QuizEndPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showFolderSelectionDialog(BuildContext context) {
    // Mock existing folders - in real app, these would come from your data source
    final List<String> existingFolders = [
      'OOP',
      'Java',
      'Discrete',
      'Database',
      'Web App',
      'Mobile App',
    ];

    showDialog(
      context: context,
      builder:
          (context) => FolderSelectionDialog(
            existingFolders: existingFolders,
            onFolderSelected: (folderName) {
              _saveQuizToFolder(folderName);
            },
          ),
    );
  }

  void _saveQuizToFolder(String folderName) {
    // TODO: Implement actual saving logic here
    // This would save the quiz data to the selected folder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quiz saved to $folderName folder!',
          style: TextStyle(fontFamily: 'Baloo2'),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to training page
    Navigator.of(context).pop(); // Close end page
    Navigator.of(context).pop(); // Close quiz page
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = Responsive.isSmallScreen(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundgame.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Card
          Center(
            child: Container(
              width: Responsive.scaleWidth(context, 350),
              constraints: BoxConstraints(
                maxHeight:
                    isSmallScreen
                        ? screenSize.height * 0.86
                        : screenSize.height * 0.7,
              ),
              padding: Responsive.scalePaddingAll(context, 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Responsive.scaleBorderRadiusAll(context, 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close (X) button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quiz Completed",
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chicken with floating sparkles animation (bigger)
                  SizedBox(
                    width: 260,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: Image.asset(
                            'assets/chickenYes.png',
                            width: 600,
                            height: 600,
                          ),
                        ),
                        // left sparkle
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            final t = _controller.value;
                            return Opacity(
                              opacity: (0.2 + 0.8 * (1 - (t - 0.1).abs()))
                                  .clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(
                                  -60 + 6 * (1 - t) * 4,
                                  -20 - 14 * t,
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.amber[600],
                                  size: 20 + 6 * t,
                                ),
                              ),
                            );
                          },
                        ),
                        // right sparkle
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            final t = (0.5 + _controller.value) % 1.0;
                            return Opacity(
                              opacity: (0.2 + 0.8 * (1 - (t - 0.1).abs()))
                                  .clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(62 - 4 * t * 6, -10 - 18 * t),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.orange[400],
                                  size: 18 + 8 * t,
                                ),
                              ),
                            );
                          },
                        ),
                        // top sparkle
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            final t = (0.25 + _controller.value) % 1.0;
                            return Opacity(
                              opacity: (0.2 + 0.8 * (1 - (t - 0.1).abs()))
                                  .clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, -40 - 20 * t),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.amber[300],
                                  size: 16 + 10 * t,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time badge (no points)
                  _StatBadge(
                    iconWidget: Image.asset(
                      'assets/clock.png',
                      width: 22,
                      height: 22,
                    ),
                    accentColor: const Color(0xFF4FC3F7),
                    label: 'Time Taken:',
                    value: _formatTime(widget.timeTaken),
                    fullWidth: true,
                  ),
                  const Spacer(),
                  // Review and Save buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4FC3F7),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: Color(0xFF4FC3F7),
                              width: 2,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => QuizReviewPage(
                                      questions: widget.questions,
                                      selectedAnswers: widget.selectedAnswers,
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Review Answers',
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4FC3F7),
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          onPressed: () => _showFolderSelectionDialog(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'SAVE QUIZ',
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _StatBadge extends StatelessWidget {
  final Color? accentColor;
  final Widget? iconWidget;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatBadge({
    this.accentColor,
    this.iconWidget,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? Colors.black54;
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.10), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: accent.withOpacity(0.6), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconWidget ?? Icon(Icons.help, color: accent, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
