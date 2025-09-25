import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';
import 'package:hellochickgu/features/game/level_page.dart';
import 'package:hellochickgu/features/game/quiz_review.dart';

class quiz1end extends StatefulWidget {
  final int correct;
  final int wrong;
  final int timeTaken;
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final int level;

  const quiz1end({
    Key? key,
    required this.correct,
    required this.wrong,
    required this.timeTaken,
    required this.questions,
    required this.selectedAnswers,
    required this.level,
  }) : super(key: key);

  @override
  State<quiz1end> createState() => _Quiz1EndState();
}

class _Quiz1EndState extends State<quiz1end>
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

  int get _points => widget.correct * 10; // simple points rule

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
                        final int nextUnlocked = (widget.level + 1).clamp(
                          1,
                          11,
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (_) => LevelPage(
                                  initialHighestUnlockedLevel: nextUnlocked,
                                  completedLevel: widget.level,
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
                    "Level Completed",
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
                            width: 1000,
                            height: 1000,
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
                  // Points & Time badges styled like level popup (stacked vertically)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatBadge(
                        icon: Icons.stars,
                        accentColor: const Color(0xFFF4B942),
                        label: 'Points:',
                        value: _points.toString(),
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
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
                    ],
                  ),
                  const Spacer(),
                  // Review and Done buttons
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
                              'Review ',
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
                          onPressed: () {
                            final int nextLevel = (widget.level + 1).clamp(
                              1,
                              11,
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (_) => LevelPage(
                                      initialHighestUnlockedLevel: nextLevel,
                                      completedLevel: widget.level,
                                    ),
                              ),
                              (route) => false,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'DONE!',
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
  final IconData? icon;
  final Color? accentColor;
  final Widget? iconWidget;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatBadge({
    this.icon,
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
              child: iconWidget ?? Icon(icon, color: accent, size: 18),
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
