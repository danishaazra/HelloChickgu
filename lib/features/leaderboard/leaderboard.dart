import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/theme/theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeInAnimation;
  bool _showConfetti = false;
  List<Map<String, dynamic>> allUsers = [];
  bool _isLoading = true;

  // List of available profile pictures
  final List<String> profilePictures = [
    'assets/user1.png',
    'assets/user2.png',
    'assets/user3.png',
    'assets/user4.png',
    'assets/user5.png',
    'assets/user6.png',
    'assets/user7.png',
    'assets/user8.png',
    'assets/user10.png',
    'assets/user11.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsersFromFirestore();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showConfetti = true;
      });
    });
  }

  Future<void> _loadUsersFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50) // Limit to top 50 users
          .get();

      final users = <Map<String, dynamic>>[];
      final random = Random();
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        
        // Skip users without username or points
        if (data['username'] == null || data['points'] == null) continue;
        
        users.add({
          'name': data['username'] as String,
          'points': data['points'] as int,
          'avatar': profilePictures[i % profilePictures.length],
          'color': _getRandomColor(random),
        });
      }

      setState(() {
        allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getRandomColor(Random random) {
    final colors = [
      Colors.blue[200],
      Colors.purple[200],
      Colors.teal[200],
      Colors.red[200],
      Colors.orange[200],
      Colors.green[200],
      Colors.pink[200],
      Colors.amber[200],
      const Color(0xFFFFE066),
      const Color.fromARGB(255, 225, 187, 248),
      const Color.fromARGB(255, 203, 248, 187),
      const Color.fromARGB(255, 248, 202, 187),
      const Color.fromARGB(255, 248, 187, 216),
      const Color.fromARGB(255, 227, 248, 187),
    ];
    return colors[random.nextInt(colors.length)]!;
  }

  List<Map<String, dynamic>> get topUsers {
    return allUsers.take(3).toList();
  }

  List<Map<String, dynamic>> get otherUsers {
    return allUsers.skip(3).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPodium() {
    if (topUsers.length < 3) {
      return Center(
        child: Text(
          'Not enough users for leaderboard',
          style: TextStyle(fontSize: 18, color: Color(0xFF3A2C0F)),
        ),
      );
    }

    final double baseHeight = 160.0;
    final List<double> heights = [140, 180, 120];
    final List<Gradient> gradients = [
      LinearGradient(
        colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.75)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      LinearGradient(
        colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ];
    final List<BorderRadius> radii = [
      const BorderRadius.only(topLeft: Radius.circular(18)),
      BorderRadius.zero,
      const BorderRadius.only(topRight: Radius.circular(18)),
    ];
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (_showConfetti)
          Positioned(
            left: 0,
            right: 0,
            child: IgnorePointer(child: _ConfettiAnimation()),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedPodium(
              place: 2,
              user: topUsers[1],
              height: heights[0],
              width: 85,
              baseHeight: baseHeight,
              animation: _animation,
              gradient: gradients[0],
              borderRadius: radii[0],
            ),
            _AnimatedPodium(
              place: 1,
              user: topUsers[0],
              height: heights[1],
              width: 100,
              baseHeight: baseHeight,
              animation: _animation,
              gradient: gradients[1],
              borderRadius: radii[1],
            ),
            _AnimatedPodium(
              place: 3,
              user: topUsers[2],
              height: heights[2],
              width: 100,
              baseHeight: baseHeight,
              animation: _animation,
              gradient: gradients[2],
              borderRadius: radii[2],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLightBlue,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Color(0xFF3A2C0F),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: _isLoading 
                          ? const CircularProgressIndicator()
                          : _buildPodium()
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container()), // This will take remaining space
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return GlassCard(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : otherUsers.isEmpty
                                  ? Center(
                                    child: Text(
                                      'No other users yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF3A2C0F),
                                      ),
                                    ),
                                  )
                                  : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    itemCount: otherUsers.length,
                                    separatorBuilder:
                                        (context, index) =>
                                            const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final user = otherUsers[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    202,
                                                    201,
                                                    201,
                                                  ),
                                                  width: 1.5,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${index + 4}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundColor: user['color'],
                                              child: Image.asset(
                                                user['avatar'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color(0xFF23213A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${user['points']} points',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color.fromARGB(
                                                        255,
                                                        142,
                                                        140,
                                                        140,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedPodium extends StatelessWidget {
  final int place;
  final Map<String, dynamic> user;
  final double height;
  final double baseHeight;
  final Animation<double> animation;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final double width;

  const _AnimatedPodium({
    required this.place,
    required this.user,
    required this.height,
    required this.baseHeight,
    required this.animation,
    required this.gradient,
    required this.borderRadius,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final animatedHeight = Tween<double>(
      begin: 0,
      end: height,
    ).animate(animation);
    final animatedOffset = Tween<double>(
      begin: baseHeight,
      end: (baseHeight - height).clamp(0.0, double.infinity),
    ).animate(animation);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: animatedOffset.value.clamp(0.0, double.infinity)),
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: user['color'],
                        child: Image.asset(
                          user['avatar'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -34,
                      child: Icon(
                        place == 1 ? Icons.emoji_events : Icons.military_tech,
                        color:
                            place == 1
                                ? const Color(0xFFFFD54F)
                                : const Color(0xFFFFE082),
                        size: place == 1 ? 28 : 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF3A2C0F),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${user['points']} pts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            // 2D podium box (no 3D side)
            SizedBox(
              width: width,
              height: animatedHeight.value.clamp(0.0, double.infinity),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: borderRadius,
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          '$place',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 38,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
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
          ],
        );
      },
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ConfettiAnimation extends StatefulWidget {
  @override
  State<_ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<_ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only cover the area under the Leaderboard title (e.g., top 220px)
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(_controller.value),
            child: Container(),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.amber,
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.yellow,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightGreen,
      Colors.deepPurple,
      Colors.lime,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.white,
      Colors.black,
      Colors.lightBlueAccent,
      Colors.deepPurpleAccent,
    ];
    final int confettiCount = 120;
    final random = Random(42);
    for (int i = 0; i < confettiCount; i++) {
      final color = colors[i % colors.length].withOpacity(0.9);
      final paint = Paint()..color = color;
      // Add glow to some confetti
      if (i % 7 == 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
      }
      // Randomize horizontal start, sway, and size
      final baseX = random.nextDouble() * size.width;
      final swayType = i % 4;
      double sway = 0;
      if (swayType == 0) {
        sway = 32 * sin(progress * 2 * pi + i);
      } else if (swayType == 1) {
        sway = -24 * cos(progress * 2 * pi + i * 2);
      } else if (swayType == 2) {
        sway = 12 * sin(progress * 4 * pi + i * 3);
      }
      final dx = baseX + sway;
      // Make each confetti fall in a loop, so when it reaches the bottom, it starts again
      final fallSpeed = 0.7 + (i % 7) * 0.09; // some fall faster
      final loopedProgress = (progress * fallSpeed + (i * 0.05)) % 1.0;
      final dy = loopedProgress * size.height;
      final shapeType = i % 3;
      final radius = 3.0 + random.nextDouble() * 6.0;
      final angle = progress * 2 * pi * (i % 2 == 0 ? 1 : -1) + i;
      if (shapeType == 0) {
        // Circle
        canvas.drawCircle(Offset(dx, dy), radius, paint);
      } else if (shapeType == 1) {
        // Rectangle (spinning)
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(angle);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 2,
            height: radius,
          ),
          paint,
        );
        canvas.restore();
      } else {
        // Star (spinning)
        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(angle);
        final path = Path();
        const int points = 5;
        for (int j = 0; j < points * 2; j++) {
          final isEven = j % 2 == 0;
          final r = isEven ? radius : radius / 2.2;
          final a = j * pi / points;
          path.lineTo(cos(a) * r, sin(a) * r);
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 20);
    path.quadraticBezierTo(size.width * 0.75, 40, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SlantTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 12);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ScallopTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 16);
    for (double i = 0; i < size.width; i += 16) {
      path.arcToPoint(
        Offset(i + 16, 16),
        radius: const Radius.circular(8),
        clockwise: false,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
