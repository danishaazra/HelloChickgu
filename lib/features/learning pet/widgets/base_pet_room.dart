import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/services/user_service.dart';
import 'package:hellochickgu/services/notification_service.dart';
import 'package:hellochickgu/services/coin_service.dart';
import '../models/room_type.dart';
import '../outfit_assets.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _idleController;
  late AnimationController _happyController;
  late AnimationController _hungryController;
  late AnimationController _showerController;
  late AnimationController _cornController;
  late Animation<double> _idleAnimation;
  late Animation<double> _happyAnimation;
  late Animation<double> _hungryAnimation;
  late Animation<double> _showerAnimation;
  late Animation<double> _cornAnimation;

  String petState = 'idle'; // idle, happy, hungry, sleepy, dirty
  Timer? _levelReductionTimer;
  Set<String> _pendingNotifications = {};
  Map<String, double> _lastNotificationLevels = {};

  // Sleep mode state
  bool _isSleeping = false;
  Timer? _sleepTimer;

  // Corn animation state
  bool _showCornAnimation = false;
  Timer? _cornAnimationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    // Corn animation (bounce, scale, and rotate)
    _cornController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cornAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cornController, curve: Curves.elasticOut),
    );

    // Start idle animation - DISABLED FOR TESTING
    // _startIdleAnimation();

    // Start streak animation - DISABLED
    // _startStreakAnimation();
  }

  void _playShowerAnimation() {
    setState(() => petState = 'showering');
    _showerController.forward().then((_) {
      if (!mounted) return;
      setState(() => petState = 'idle');
      // Guard against calling controller methods after dispose
      try {
        _showerController.reset();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _levelReductionTimer?.cancel();
    _sleepTimer?.cancel();
    _cornAnimationTimer?.cancel();
    _idleController.dispose();
    _happyController.dispose();
    _hungryController.dispose();
    _showerController.dispose();
    _cornController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Apply any missed decay while the app was away
      UserService.instance.applyDecayNow();
    }
  }

  void _startSleepMode() async {
    if (_isSleeping) return;

    setState(() {
      _isSleeping = true;
    });

    // Check if energy is 50% or below to give points
    double currentEnergy = _getEnergyLevel();
    bool shouldGivePoints = currentEnergy <= 0.5;

    // Set energy to 100 when sleeping
    await UserService.instance.updatePetStats(energy: 100.0);

    // Give points and coins if energy was low (50% or below)
    if (shouldGivePoints) {
      await UserService.instance.updatePoints(
        (widget.userData!['points'] ?? 0) + 10,
      );

      // Also add coins (1 coin per 10 points earned)
      await CoinService.instance.addCoins(10);

      // Update local points
      if (mounted) {
        setState(() {
          widget.userData!['points'] = (widget.userData!['points'] ?? 0) + 10;
        });
      }
    }

    // Wake up after 2 minutes
    _sleepTimer = Timer(const Duration(hours: 8), () {
      _wakeUp();
    });

    // Show appropriate message
    String message =
        shouldGivePoints
            ? 'Chicken is sleeping for 8 hours! +10 points & +10 coin earned! Zzz...'
            : 'Chicken is sleeping for 8 hours! Zzz...';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: shouldGivePoints ? Colors.green : Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _wakeUp() {
    if (!_isSleeping) return;

    setState(() {
      _isSleeping = false;
    });

    _sleepTimer?.cancel();
    _sleepTimer = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chicken woke up! Good morning!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startCornAnimation() {
    if (_showCornAnimation) return;

    setState(() {
      _showCornAnimation = true;
    });

    // Start the corn animation
    _cornController.forward();

    // Hide animation after 3 seconds
    _cornAnimationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showCornAnimation = false;
        });
        try {
          _cornController.reset();
        } catch (_) {}
      }
    });
  }

  void _startLevelReductionTimer() {
    // Reduce levels every 1 minute for testing
    _levelReductionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _reducePetLevels();
    });
  }

  void _reducePetLevels() async {
    if (widget.userData == null) return;

    final currentHunger = (widget.userData!['hunger'] ?? 100).toDouble();
    final currentEnergy = (widget.userData!['energy'] ?? 100).toDouble();
    final currentCleanliness =
        (widget.userData!['cleanliness'] ?? 100).toDouble();

    // Reduce each level by 0.1 points (minimum 0) for testing
    final newHunger = (currentHunger - 0.1).clamp(0.0, 100.0);
    final newEnergy = (currentEnergy - 0.1).clamp(0.0, 100.0);
    final newCleanliness = (currentCleanliness - 0.1).clamp(0.0, 100.0);

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
    if (newCleanliness > 30) {
      _lastNotificationLevels.remove('toilet');
      _lastNotificationLevels.remove('shower');
    }

    print(
      'Pet levels updated - Hunger: $newHunger, Energy: $newEnergy, Cleanliness: $newCleanliness',
    );
  }

  void _scheduleLowLevelNotification(String assetPath) {
    double currentLevel = 0.0;
    if (assetPath.contains('food')) {
      currentLevel = _getHungerLevel();
    } else if (assetPath.contains('sleep')) {
      currentLevel = _getEnergyLevel();
    } else if (assetPath.contains('toilet') || assetPath.contains('shower')) {
      currentLevel = _getCleanlinessLevel();
    }

    // Get the last level we notified about for this asset
    double lastNotifiedLevel = _lastNotificationLevels[assetPath] ?? 1.0;

    // Define notification thresholds (30%, 20%, 10%, 0%)
    List<double> thresholds = [0.3, 0.2, 0.1, 0.0];

    // Check if current level has crossed any threshold
    bool shouldNotify = false;
    double crossedThreshold = 0.0;

    for (double threshold in thresholds) {
      // Check if we've crossed the threshold (current <= threshold AND last was > threshold)
      // This handles the double precision issue where we might skip exact values
      if (currentLevel <= threshold && lastNotifiedLevel > threshold) {
        shouldNotify = true;
        crossedThreshold = threshold;

        // Debug print to see threshold crossings
        print(
          '🔔 NOTIFICATION: ${assetPath} crossed ${(threshold * 100).toInt()}% threshold - Current: ${(currentLevel * 100).toStringAsFixed(1)}%, Last: ${(lastNotifiedLevel * 100).toStringAsFixed(1)}%',
        );
        break;
      }
    }

    // Only notify if:
    // 1. We crossed a threshold
    // 2. We haven't already notified for this level
    // 3. We're not already processing a notification for this asset
    if (shouldNotify && !_pendingNotifications.contains(assetPath)) {
      _pendingNotifications.add(assetPath);
      _lastNotificationLevels[assetPath] = currentLevel;

      // Schedule the notification to show after the current frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showLowLevelNotification(assetPath, crossedThreshold);
      });
    }
  }

  void _showLowLevelNotification(String assetPath, double threshold) {
    // Remove from pending notifications
    _pendingNotifications.remove(assetPath);

    String message = '';
    String action = '';
    String urgency = '';

    // Determine urgency level based on threshold
    if (threshold <= 0.0) {
      urgency = 'CRITICAL';
    } else if (threshold <= 0.1) {
      urgency = 'URGENT';
    } else if (threshold <= 0.2) {
      urgency = 'WARNING';
    } else if (threshold <= 0.3) {
      urgency = 'LOW';
    }

    if (assetPath.contains('food')) {
      message = 'Your pet is hungry! ($urgency)';
      action = 'Feed your pet some food.';
    } else if (assetPath.contains('sleep')) {
      message = 'Your pet is tired! ($urgency)';
      action = 'Let your pet rest.';
    } else if (assetPath.contains('toilet') || assetPath.contains('shower')) {
      message = 'Your pet needs cleaning! ($urgency)';
      action = 'Give your pet a shower.';
    }

    if (message.isNotEmpty) {
      NotificationService.instance.showLowStatNotification(
        title: message,
        body: action,
      );
    }
  }

  // Helper method to handle pet care with point rewards
  Future<void> _handlePetCare(
    String statType,
    double currentLevel,
    String statName,
  ) async {
    try {
      // Check if current level is 50% or below to give points
      bool shouldGivePoints = currentLevel <= 0.5;

      // Update the pet stat to 100
      if (statType == 'hunger') {
        await UserService.instance.updatePetStats(hunger: 100.0);
      } else if (statType == 'energy') {
        await UserService.instance.updatePetStats(energy: 100.0);
      } else if (statType == 'cleanliness') {
        await UserService.instance.updatePetStats(cleanliness: 100.0);
      }

      if (!mounted) return;

      // Update local state
      setState(() {
        widget.userData![statType] = 100.0;
        _lastNotificationLevels.remove(
          statType == 'hunger'
              ? 'food'
              : statType == 'energy'
              ? 'sleep'
              : 'toilet',
        );
        if (statType == 'cleanliness') {
          _lastNotificationLevels.remove('shower');
        }
      });

      // Give points and coins if stat was low (50% or below)
      if (shouldGivePoints) {
        await UserService.instance.updatePoints(
          (widget.userData!['points'] ?? 0) + 10,
        );

        // Also add coins (1 coin per 10 points earned)
        await CoinService.instance.addCoins(10);

        // Update local points
        if (mounted) {
          setState(() {
            widget.userData!['points'] = (widget.userData!['points'] ?? 0) + 10;
          });
        }
      }

      // Show appropriate message
      String message =
          shouldGivePoints
              ? '$statName restored to 100! +10 points & +10 coin earned!'
              : '$statName restored to 100';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: shouldGivePoints ? Colors.green : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
      }
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
                        _buildAssetStatusIcon(
                          'assets/coin.png',
                          1.0,
                        ), // Always full for coins

                        Positioned(
                          bottom: -8,
                          child: StreamBuilder<int>(
                            stream: CoinService.instance.getCoinsStream(),
                            builder: (context, snapshot) {
                              final coins = snapshot.data ?? 0;
                              return Text(
                                '$coins',
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    _buildPetCareIcon(
                      'assets/food.png',
                      _getHungerLevel(),
                      onTap:
                          widget.roomType == RoomType.kitchen
                              ? () async {
                                await _handlePetCare(
                                  'hunger',
                                  _getHungerLevel(),
                                  'Hunger',
                                );
                              }
                              : null,
                    ),
                    const SizedBox(width: 20),
                    _buildPetCareIcon(
                      'assets/sleep.png',
                      _getEnergyLevel(),
                      onTap:
                          widget.roomType == RoomType.bedroom
                              ? () async {
                                await _handlePetCare(
                                  'energy',
                                  _getEnergyLevel(),
                                  'Energy',
                                );
                              }
                              : null,
                    ),
                    const SizedBox(width: 20),
                    _buildPetCareIcon(
                      'assets/shower.png',
                      _getCleanlinessLevel(),
                      onTap:
                          widget.roomType == RoomType.bathroom
                              ? () async {
                                await _handlePetCare(
                                  'cleanliness',
                                  _getCleanlinessLevel(),
                                  'Cleanliness',
                                );
                              }
                              : null,
                    ),

                    const SizedBox(width: 20),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(_getPetImage(), fit: BoxFit.contain),
                            _buildHatOverlay(),
                          ],
                        ),
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

                  onPressed: () async {
                    try {
                      if (widget.roomType == RoomType.bathroom) {
                        await _handlePetCare(
                          'cleanliness',
                          _getCleanlinessLevel(),
                          'Cleanliness',
                        );
                        _playShowerAnimation();
                      } else if (widget.roomType == RoomType.kitchen) {
                        await _handlePetCare(
                          'hunger',
                          _getHungerLevel(),
                          'Hunger',
                        );
                        // Start corn animation
                        _startCornAnimation();
                      } else if (widget.roomType == RoomType.bedroom) {
                        if (_isSleeping) {
                          // If already sleeping, wake up (turn on light)
                          _wakeUp();
                        } else {
                          // Start sleep mode (turn off light)
                          _startSleepMode();
                        }
                      } else {
                        // Default action (e.g., Maps)
                        if (widget.onMapsPressed != null) {
                          widget.onMapsPressed!();
                        }
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

          // Sleep mode dark overlay
          if (_isSleeping)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bedtime,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Chicken is sleeping...',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Zzz... Zzz... Zzz...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tap the lamp to turn on the light',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Corn animation overlay
          if (_showCornAnimation)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _cornAnimation,
                      builder: (context, child) {
                        // Create a more complex animation with multiple effects
                        final scale = 0.3 + (0.7 * _cornAnimation.value);
                        final rotation =
                            _cornAnimation.value * 2 * 3.14159; // Full rotation
                        final bounce =
                            (1.0 + 0.3 * (1.0 - _cornAnimation.value)) *
                            (1.0 + 0.2 * (1.0 - _cornAnimation.value));

                        return Transform.translate(
                          offset: Offset(
                            0,
                            -20 * (1.0 - _cornAnimation.value),
                          ), // Move up slightly
                          child: Transform.scale(
                            scale: scale * bounce,
                            child: Transform.rotate(
                              angle: rotation,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/corncorn.png',
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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

  double _getHungerLevel() {
    if (widget.userData == null) return 0.0;
    final hunger = (widget.userData!['hunger'] ?? 0).toDouble();
    return hunger / 100.0; // Convert to 0.0-1.0 range
  }

  double _getEnergyLevel() {
    if (widget.userData == null) return 0.0;
    final energy = (widget.userData!['energy'] ?? 0).toDouble();
    return energy / 100.0; // Convert to 0.0-1.0 range
  }

  double _getCleanlinessLevel() {
    if (widget.userData == null) return 0.0;
    final cleanliness = (widget.userData!['cleanliness'] ?? 0).toDouble();
    return cleanliness / 100.0; // Convert to 0.0-1.0 range
  }

  String _getUsername() {
    if (widget.userData == null) return "Guest";
    return widget.userData!['username'] ?? "Guest";
  }

  String? _getEquippedHatAsset() {
    final data = widget.userData;
    if (data == null) return null;
    final outfit = (data['currentOutfit'] as Map?) ?? const {};
    final String? hatId = outfit['hat'] as String?;
    if (hatId == null || hatId.isEmpty) return null;
    return OutfitAssets.hatIdToAsset[hatId];
  }

  Widget _buildHatOverlay() {
    // Optionally hide hat during shower animation
    if (petState == 'showering') return const SizedBox.shrink();

    final hatAsset = _getEquippedHatAsset();
    if (hatAsset == null) return const SizedBox.shrink();

    // Default transform
    double offsetX = 0.0;
    double offsetY = -90.0;
    double extraScale = 1.0;

    // Per-hat transform overrides
    final data = widget.userData;
    final String? hatId = (data?['currentOutfit'] as Map?)?['hat'] as String?;
    if (hatId != null) {
      final t = OutfitAssets.hatIdToTransform[hatId];
      if (t != null && t.length == 3) {
        offsetX = t[0];
        offsetY = t[1];
        extraScale = t[2];
      }
    }

    // Global fine-tune: push hat slightly higher on the head
    offsetY -= 10.0;

    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.scale(
        scale: _getPetScale() * extraScale,
        child: Image.asset(
          hatAsset,
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
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
