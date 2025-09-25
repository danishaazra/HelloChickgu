import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/services/user_service.dart';
import '../models/room_type.dart';

class BasePetRoom extends StatefulWidget {
  final RoomType roomType;
  final Map<String, dynamic>? userData;
  final VoidCallback? onPreviousRoom;
  final VoidCallback? onNextRoom;
  final VoidCallback? onMapsPressed;
  final VoidCallback? onShopPressed;
  final VoidCallback? onLeaderboardPressed;

  final VoidCallback? onProfilePressed;


  const BasePetRoom({
    super.key,
    required this.roomType,
    this.userData,
    this.onPreviousRoom,
    this.onNextRoom,
    this.onMapsPressed,
    this.onShopPressed,
    this.onLeaderboardPressed,
    this.onProfilePressed,
  });

  @override
  State<BasePetRoom> createState() => _BasePetRoomState();
}

class _BasePetRoomState extends State<BasePetRoom>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _happyController;
  late AnimationController _hungryController;
  late Animation<double> _idleAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _hungryAnimation;

  String petState = 'idle'; // idle, happy, hungry, sleepy, dirty
  Timer? _levelReductionTimer;
  Set<String> _pendingNotifications = {};
  Map<String, double> _lastNotificationLevels = {};

  @override
  void initState() {
    super.initState();

    // Idle animation (gentle bounce)
    _idleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _idleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Happy animation (bigger bounce)
    _happyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _happyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _happyController, curve: Curves.elasticOut),
    );

    // Hungry animation (subtle shake)
    _hungryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hungryAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _hungryController, curve: Curves.easeInOut),
    );


    // Start level reduction timer
    _startLevelReductionTimer();


    // Start idle animation - DISABLED FOR TESTING
    // _startIdleAnimation();

    // Start streak animation - DISABLED
    // _startStreakAnimation();
  }

  void _startIdleAnimation() {
    _idleController.repeat(reverse: true);
  }

  void _playHappyAnimation() {
    setState(() => petState = 'happy');
    _happyController.forward().then((_) {
      _happyController.reverse().then((_) {
        setState(() => petState = 'idle');
        _startIdleAnimation();
      });
    });
  }


  @override
  void dispose() {
    _levelReductionTimer?.cancel();
    _idleController.dispose();
    _happyController.dispose();
    _hungryController.dispose();
    super.dispose();
  }

  void _startLevelReductionTimer() {
    // Reduce levels every 1 minute for testing
    _levelReductionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _reducePetLevels();
    });
  }

  void _reducePetLevels() async {
    if (widget.userData == null) return;

    final currentHunger = widget.userData!['hunger'] ?? 100;
    final currentEnergy = widget.userData!['energy'] ?? 100;
    final currentCleanliness = widget.userData!['cleanliness'] ?? 100;

    // Reduce each level by 3 points (minimum 0) for testing
    final newHunger = (currentHunger - 3).clamp(0, 100);
    final newEnergy = (currentEnergy - 3).clamp(0, 100);
    final newCleanliness = (currentCleanliness - 3).clamp(0, 100);

    // Update in Firebase
    await UserService.instance.updatePetStats(
      hunger: newHunger,
      energy: newEnergy,
      cleanliness: newCleanliness,
    );

    // Update local userData to reflect changes
    if (mounted) {
      setState(() {
        widget.userData!['hunger'] = newHunger;
        widget.userData!['energy'] = newEnergy;
        widget.userData!['cleanliness'] = newCleanliness;
      });
    }

    // Reset notification tracking if levels are restored above 30%
    if (newHunger > 30) _lastNotificationLevels.remove('food');
    if (newEnergy > 30) _lastNotificationLevels.remove('sleep');
    if (newCleanliness > 30) _lastNotificationLevels.remove('toilet');

    print('Pet levels updated - Hunger: $newHunger, Energy: $newEnergy, Cleanliness: $newCleanliness');
  }

  void _scheduleLowLevelNotification(String assetPath) {
    // Only show notification if level is exactly 30% or below
    double currentLevel = 0.0;
    if (assetPath.contains('food')) {
      currentLevel = _getHungerLevel();
    } else if (assetPath.contains('sleep')) {
      currentLevel = _getEnergyLevel();
    } else if (assetPath.contains('toilet')) {
      currentLevel = _getCleanlinessLevel();
    }
    
    // Get the last level we notified about for this asset
    double lastNotifiedLevel = _lastNotificationLevels[assetPath] ?? 1.0;
    
    // Only notify if:
    // 1. Current level is 30% or below
    // 2. We haven't already notified for this level
    // 3. The level has actually dropped (not just a rebuild)
    if (currentLevel <= 0.3 && 
        !_pendingNotifications.contains(assetPath) &&
        lastNotifiedLevel > 0.3) {
      
      _pendingNotifications.add(assetPath);
      _lastNotificationLevels[assetPath] = currentLevel;
      
      // Schedule the notification to show after the current frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showLowLevelNotification(assetPath);
      });
    }
  }

  void _showLowLevelNotification(String assetPath) {
    // Remove from pending notifications
    _pendingNotifications.remove(assetPath);
    
    String message = '';
    String action = '';

    if (assetPath.contains('food')) {
      message = 'Your pet is hungry!';
      action = 'Feed your pet some food';
    } else if (assetPath.contains('sleep')) {
      message = 'Your pet is tired!';
      action = 'Let your pet rest';
    } else if (assetPath.contains('toilet')) {
      message = 'Your pet needs cleaning!';
      action = 'Clean your pet';
    }

    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(action),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Room Background
          Positioned.fill(

            child: Image.asset(
              widget.roomType.backgroundAsset,
              fit: BoxFit.cover,
            ),

          ),

          // Top Bar - Centered
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _getUsername(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(offset: Offset(-1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, -1), color: Colors.black),
                            Shadow(offset: Offset(1, 1), color: Colors.black),
                            Shadow(offset: Offset(-1, 1), color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: widget.onProfilePressed,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/user1.png',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status icons with circular borders - centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        _buildAssetStatusIcon('assets/coin.png', 0.9),
                        Positioned(
                          bottom: -8,
                          child: Text(
                            _getPointsText(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(-1, -1),
                                  color: AppTheme.primaryYellow,
                                ),
                                Shadow(
                                  offset: Offset(1, -1),
                                  color: AppTheme.primaryYellow,
                                ),
                                Shadow(
                                  offset: Offset(1, 1),
                                  color: AppTheme.primaryYellow,
                                ),
                                Shadow(
                                  offset: Offset(-1, 1),
                                  color: AppTheme.primaryYellow,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    _buildPetCareIcon('assets/food icon.png', _getHungerLevel()),
                    const SizedBox(width: 8),
                    _buildPetCareIcon('assets/sleep icon.png', _getEnergyLevel()),
                    const SizedBox(width: 8),
                    _buildPetCareIcon('assets/toilet icon.png', _getCleanlinessLevel()),

                    const SizedBox(width: 8),
                    _buildStreakIcon(3),
                  ],
                ),
              ],
            ),
          ),

          // Room Title with Navigation
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Text(
                    "‹",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          offset: Offset(-2, -2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(2, -2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(2, 2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(-2, 2),
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  onPressed: widget.onPreviousRoom,
                ),
                Text(
                  widget.roomType.displayName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(-2, -2),
                        color: AppTheme.primaryBlue,
                      ),
                      Shadow(
                        offset: Offset(2, -2),
                        color: AppTheme.primaryBlue,
                      ),
                      Shadow(offset: Offset(2, 2), color: AppTheme.primaryBlue),
                      Shadow(
                        offset: Offset(-2, 2),
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Text(
                    "›",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          offset: Offset(-2, -2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(2, -2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(2, 2),
                          color: AppTheme.primaryBlue,
                        ),
                        Shadow(
                          offset: Offset(-2, 2),
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  onPressed: widget.onNextRoom,
                ),
              ],
            ),
          ),

          // Leaderboard Icon - Right side below Room Title
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: 15,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.leaderboard, color: Colors.white, size: 60),
                  onPressed: widget.onLeaderboardPressed,
                ),
                const SizedBox(height: 1),
                Text(
                  "Leaderboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Animated Chick Pet
          Align(
            alignment: Alignment(
              0,
              0.4,
            ), // Move up a bit and center vertically (0.4 = 40% from center toward bottom)
            child: AnimatedBuilder(
              animation: _getCurrentAnimation(),
              builder: (context, child) {
                return Transform.translate(
                  offset: _getPetOffset(),
                  child: Transform.scale(
                    scale: _getPetScale(),
                    child: GestureDetector(
                      onTap: _playHappyAnimation,
                      child: Container(
                        height: 350, // Much bigger size (was 300)
                        child: Image.asset(_getPetImage(), fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Buttons
          Positioned(
            bottom: 40,
            left: 40,
            child: Column(
              children: [
                IconButton(
                  icon: Image.asset(
                    widget.roomType.mapIconAsset,
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                  onPressed: widget.onMapsPressed,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.roomType.mapButtonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            right: 40,
            child: Column(
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/shop icon.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  onPressed: widget.onShopPressed,
                ),
                const SizedBox(height: 8),
                Text(
                  "Shop",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(offset: Offset(-1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, -1), color: Colors.black),
                      Shadow(offset: Offset(1, 1), color: Colors.black),
                      Shadow(offset: Offset(-1, 1), color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetStatusIcon(String assetPath, double fillLevel) {
    final bool isCoin = assetPath.endsWith('coin.png');
    final bool isFoodSleepShower =
        assetPath.contains('food') ||
        assetPath.contains('sleep') ||
        assetPath.contains('shower') ||
        assetPath.contains('toilet') ||
        assetPath.contains('soap');
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isCoin ? Colors.transparent : Colors.white,
        shape: BoxShape.circle,
        border: isCoin ? null : Border.all(color: Colors.black, width: 3),
      ),
      child: Center(
        child: Image.asset(
          assetPath,

          width: isCoin ? 45 : (isFoodSleepShower ? 34 : 38),
          height: isCoin ? 45 : (isFoodSleepShower ? 34 : 38),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPetCareIcon(String assetPath, double fillLevel) {
    // Determine color based on level
    Color progressColor;
    if (fillLevel <= 0.3) {
      progressColor = Colors.red.shade600; // Bright red for low levels (≤30%)
      _scheduleLowLevelNotification(assetPath);
    } else if (fillLevel <= 0.6) {
      progressColor = Colors.yellow.shade600; // Bright yellow for medium levels (31-60%)
    } else {
      progressColor = Colors.green.shade600; // Bright green for high levels (61-100%)
    }

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          // Background circle (always grey)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          // Progress circle (color based on level)
          if (fillLevel > 0)
            Container(
              width: 70,
              height: 70,
              child: CustomPaint(
                painter: CircleProgressPainter(
                  progress: fillLevel,
                  color: progressColor,
                ),
              ),
            ),
          // Icon
          Center(
            child: Image.asset(
              assetPath,
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakIcon(int streak) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          // Fire icon
          Center(
            child: Icon(
              Icons.local_fire_department,
              color: Colors.orange[600],
              size: 35,
            ),
          ),
          // Streak number
          Positioned(
            bottom: 12,
            right: 12,
            child: Text(
              streak.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(offset: Offset(-1, -1), color: Colors.black),
                  Shadow(offset: Offset(1, -1), color: Colors.black),
                  Shadow(offset: Offset(1, 1), color: Colors.black),
                  Shadow(offset: Offset(-1, 1), color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Animation helper methods
  Animation _getCurrentAnimation() {
    switch (petState) {
      case 'happy':
        return _happyAnimation;
      case 'hungry':
        return _hungryAnimation;
      default:
        return _idleAnimation;
    }
  }

  Offset _getPetOffset() {
    switch (petState) {
      case 'hungry':
        return Offset(_hungryAnimation.value * 20, 0);
      default:
        return Offset.zero;
    }
  }

  double _getPetScale() {
    switch (petState) {
      case 'happy':
        return 1.0 + (_happyAnimation.value * 0.2);
      case 'idle':
        return 1.0 + (_idleAnimation.value * 0.05);
      default:
        return 1.0;
    }
  }

  String _getPetImage() {
    switch (petState) {
      case 'happy':
        return 'assets/chickenHappy.png';
      case 'hungry':
        return 'assets/chicken_payment.png';
      case 'sleepy':
        return 'assets/chickenLevel.png';
      default:
        return 'assets/pett.png';
    }
  }

  // Helper methods to get data from userData
  String _getPointsText() {
    if (widget.userData == null) return "0";
    return (widget.userData!['points'] ?? 0).toString();
  }

  double _getHungerLevel() {
    if (widget.userData == null) return 0.0;
    final hunger = widget.userData!['hunger'] ?? 0;
    return hunger / 100.0; // Convert to 0.0-1.0 range
  }

  double _getEnergyLevel() {
    if (widget.userData == null) return 0.0;
    final energy = widget.userData!['energy'] ?? 0;
    return energy / 100.0; // Convert to 0.0-1.0 range
  }

  double _getCleanlinessLevel() {
    if (widget.userData == null) return 0.0;
    final cleanliness = widget.userData!['cleanliness'] ?? 0;
    return cleanliness / 100.0; // Convert to 0.0-1.0 range
  }

  String _getUsername() {
    if (widget.userData == null) return "Guest";
    return widget.userData!['username'] ?? "Guest";
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create a circular progress indicator with vibrant colors
    final paint = Paint()
      ..color = color.withOpacity(0.9) // Increased opacity for better visibility
      ..style = PaintingStyle.fill;
    
    // Calculate the angle for the progress (0 to 2π)
    final sweepAngle = 2 * 3.14159 * progress;
    
    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top (-π/2)
      sweepAngle,
      true, // Use center to create a filled arc
      paint, // Add the paint parameter
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircleProgressPainter && 
           (oldDelegate.progress != progress || oldDelegate.color != color);
  }
}
