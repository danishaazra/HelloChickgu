import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/services/user_service.dart';
import 'package:hellochickgu/services/notification_service.dart';
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
  late AnimationController _showerController;
  late Animation<double> _idleAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _hungryAnimation;
  late Animation<double> _showerAnimation;

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

    // Shower animation (bubbling effect)
    _showerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _showerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _showerController, curve: Curves.easeInOut),
    );

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

  void _playShowerAnimation() {
    setState(() => petState = 'showering');
    _showerController.forward().then((_) {
      setState(() => petState = 'idle');
      _showerController.reset();
    });
  }

  void _makeChickenDirty() {
    setState(() => petState = 'dirty');
  }

  @override
  void dispose() {
    _levelReductionTimer?.cancel();
    _idleController.dispose();
    _happyController.dispose();
    _hungryController.dispose();
    _showerController.dispose();
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

    print(
      'Pet levels updated - Hunger: $newHunger, Energy: $newEnergy, Cleanliness: $newCleanliness',
    );
  }

  void _scheduleLowLevelNotification(String assetPath) {
    // Only show system notification if level is <= 50%
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
    // 1. Current level is 50% or below
    // 2. We haven't already notified for this level
    // 3. The level has actually dropped (not just a rebuild)
    if (currentLevel <= 0.5 &&
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
      action = 'Feed your pet some food.';
    } else if (assetPath.contains('sleep')) {
      message = 'Your pet is tired!';
      action = 'Let your pet rest.';
    } else if (assetPath.contains('toilet')) {
      message = 'Your pet needs cleaning!';
      action = 'Give your pet a shower.';
    }

    if (message.isNotEmpty) {
      NotificationService.instance.showLowStatNotification(
        title: message,
        body: action,
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
                        _buildPetCareIcon('assets/coin.png', _getPointsLevel()),
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

                    _buildPetCareIcon(
                      'assets/food.png',
                      _getHungerLevel(),
                      onTap:
                          widget.roomType == RoomType.kitchen
                              ? () async {
                                // Set cleanliness to 100 in Firebase and locally
                                await UserService.instance.updatePetStats(
                                  hunger: 100,
                                );
                                if (mounted && widget.userData != null) {
                                  setState(() {
                                    widget.userData!['hunger'] = 100;
                                  });
                                }
                              }
                              : null,
                    ),
                    const SizedBox(width: 8),
                    _buildPetCareIcon(
                      'assets/sleep.png',
                      _getEnergyLevel(),
                      onTap:
                          widget.roomType == RoomType.bedroom
                              ? () async {
                                // Set cleanliness to 100 in Firebase and locally
                                await UserService.instance.updatePetStats(
                                  energy: 100,
                                );
                                if (mounted && widget.userData != null) {
                                  setState(() {
                                    widget.userData!['energy'] = 100;
                                  });
                                }
                              }
                              : null,
                    ),
                    const SizedBox(width: 8),
                    _buildPetCareIcon(
                      'assets/shower.png',
                      _getCleanlinessLevel(),
                      onTap:
                          widget.roomType == RoomType.bathroom
                              ? () async {
                                // Set cleanliness to 100 in Firebase and locally
                                await UserService.instance.updatePetStats(
                                  cleanliness: 100,
                                );
                                if (mounted && widget.userData != null) {
                                  setState(() {
                                    widget.userData!['cleanliness'] = 100;
                                  });
                                }
                              }
                              : null,
                    ),

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
                  icon: Image.asset(
                    'assets/leaderboard icon.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
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

          // Animated Chick Pet (ignore pointer so it doesn't block taps)
          IgnorePointer(
            ignoring: true,
            child: Align(
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
                      child: Container(
                        height: 350, // Much bigger size (was 300)
                        child: Image.asset(_getPetImage(), fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
              ),
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
                    widget.roomType == RoomType.bathroom
                        ? 'assets/soap.png'
                        : widget.roomType == RoomType.kitchen
                        ? 'assets/corn.png'
                        : widget.roomType == RoomType.bedroom
                        ? 'assets/lamp.png'
                        : widget.roomType.mapIconAsset,
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                  onPressed:
                      widget.roomType == RoomType.bathroom
                          ? () async {
                            try {
                              await UserService.instance.updatePetStats(
                                cleanliness: 100,
                              );
                              if (!mounted) return;
                              setState(() {
                                widget.userData!['cleanliness'] = 100;
                                _lastNotificationLevels.remove('toilet');
                              });
                              _playShowerAnimation();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cleanliness restored to 100'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to update cleanliness: $e',
                                  ),
                                ),
                              );
                            }
                          }
                          : widget.onMapsPressed,
                  onPressed: () async {
                    try {
                      if (widget.roomType == RoomType.bathroom) {
                        await UserService.instance.updatePetStats(
                          cleanliness: 100,
                        );
                        if (!mounted) return;
                        setState(() {
                          widget.userData!['cleanliness'] = 100;
                          _lastNotificationLevels.remove('toilet');
                        });
                        _playShowerAnimation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cleanliness restored to 100'),
                          ),
                        );
                      } else if (widget.roomType == RoomType.kitchen) {
                        await UserService.instance.updatePetStats(hunger: 100);
                        if (!mounted) return;
                        setState(() {
                          widget.userData!['hunger'] = 100;
                          _lastNotificationLevels.remove('food');
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hunger restored to 100'),
                          ),
                        );
                      } else if (widget.roomType == RoomType.bedroom) {
                        await UserService.instance.updatePetStats(energy: 100);
                        if (!mounted) return;
                        setState(() {
                          widget.userData!['energy'] = 100;
                          _lastNotificationLevels.remove('sleep');
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Energy restored to 100'),
                          ),
                        );
                      } else {
                        // Default action (e.g., Maps)
                        if (widget.onMapsPressed != null)
                          widget.onMapsPressed!();
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Action failed: $e')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  widget.roomType == RoomType.bathroom
                      ? "Shower"
                      : widget.roomType == RoomType.kitchen
                      ? "Feed"
                      : widget.roomType == RoomType.bedroom
                      ? "Sleep"
                      : widget.roomType.mapButtonText,
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

    Widget iconWidget = Container(
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

    // Status icons are not clickable

    return iconWidget;
  }

  Widget _buildPetCareIcon(
    String assetPath,
    double fillLevel, {
    VoidCallback? onTap,
  }) {
    // Determine color based on level
    Color progressColor;
    if (fillLevel <= 0.3) {
      progressColor = const Color.fromARGB(
        255,
        255,
        4,
        0,
      ); // Bright red for low levels (≤30%)
      _scheduleLowLevelNotification(assetPath);
    } else if (fillLevel <= 0.6) {
      progressColor =
          Colors.yellow.shade600; // Bright yellow for medium levels (31-60%)
      progressColor = const Color.fromARGB(
        255,
        248,
        202,
        0,
      ); // Bright yellow for medium levels (31-60%)
    } else {
      progressColor =
          Colors.green.shade600; // Bright green for high levels (61-100%)
      progressColor = const Color.fromARGB(
        255,
        0,
        208,
        10,
      ); // Bright green for high levels (61-100%)
    }

    final content = Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring progress painted between outer and inner borders
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: CircleProgressPainter(
                progress: fillLevel.clamp(0.0, 1.0),
                color: progressColor,
                strokeWidth: 10, // thickness of the progress ring
                backgroundColor: Colors.white.withOpacity(0.15),
                inset: 3, // match outer border width
              ),
            ),
          ),
          // Inner circle border to create the inner edge of the ring
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // solid white background behind the icon
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
          // Icon inside the inner circle
          Center(
            child: Image.asset(
              assetPath,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
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
      case 'showering':
        return _showerAnimation;
      default:
        return _idleAnimation;
    }
  }

  Offset _getPetOffset() {
    switch (petState) {
      case 'hungry':
        return Offset(_hungryAnimation.value * 20, 0);
      case 'showering':
        return Offset(0, _showerAnimation.value * 10);
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
      case 'showering':
        return 1.0 + (_showerAnimation.value * 0.1);
      default:
        return 1.0;
    }
  }

  String _getPetImage() {
    // Priority states first
    if (petState == 'showering') return 'assets/shower chick.png';
    if (petState == 'happy') return 'assets/chickenHappy.png';
    if (petState == 'hungry') return 'assets/chicken_payment.png';
    if (petState == 'sleepy') return 'assets/chickenLevel.png';

    // Automatic dirty state based on cleanliness level
    final cleanlinessLevel = _getCleanlinessLevel(); // 0.0 - 1.0
    if (cleanlinessLevel < 0.5) {
      return 'assets/dirty chick.png';
    }

    // Default/clean image
    return 'assets/pett.png';
  }

  // Helper methods to get data from userData
  String _getPointsText() {
    if (widget.userData == null) return "0";
    return (widget.userData!['points'] ?? 0).toString();
  }

  double _getPointsLevel() {
    if (widget.userData == null) return 0.0;
    final points = (widget.userData!['points'] ?? 0) as int;
    // Map points to 0.0 - 1.0 range for ring fill. Assuming 0-100 baseline.
    // If your economy allows more than 100 coins, cap at 1.0.
    return (points / 100.0).clamp(0.0, 1.0);
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
  final double progress; // 0.0 - 1.0
  final Color color;
  final double strokeWidth; // ring thickness
  final Color? backgroundColor; // optional background ring color
  final double inset; // inset from outer bounds to align with outer border

  CircleProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.inset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final startAngle = -3.14159 / 2; // start at top
    final sweepAngle = 2 * 3.14159 * progress;

    // Background ring (optional)
    if (backgroundColor != null) {
      final bgPaint =
          Paint()
            ..color = backgroundColor!
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, 0, 2 * 3.14159, false, bgPaint);
    }

    // Progress ring
    final fgPaint =
        Paint()
          ..color = color.withOpacity(0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is CircleProgressPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth ||
            oldDelegate.inset != inset ||
            oldDelegate.backgroundColor != backgroundColor);
  }
}
