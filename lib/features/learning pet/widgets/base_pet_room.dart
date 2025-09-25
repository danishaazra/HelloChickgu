import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import '../models/room_type.dart';

class BasePetRoom extends StatefulWidget {
  final RoomType roomType;
  final VoidCallback? onPreviousRoom;
  final VoidCallback? onNextRoom;
  final VoidCallback? onMapsPressed;
  final VoidCallback? onShopPressed;
  final VoidCallback? onLeaderboardPressed;

  final VoidCallback? onProfilePressed;

  const BasePetRoom({
    super.key,
    required this.roomType,
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

  String petState =
      'idle'; // idle, happy, hungry, sleepy, dirty, clean, showering

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
    _idleController.dispose();
    _happyController.dispose();
    _hungryController.dispose();
    _showerController.dispose();
    super.dispose();
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
                        "Nurin Sunoo",
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
                            "3455",
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

                    _buildAssetStatusIcon('assets/food.png', 0.7),
                    const SizedBox(width: 8),
                    _buildAssetStatusIcon('assets/sleep.png', 0.5),
                    const SizedBox(width: 8),
                    _buildAssetStatusIcon('assets/shower.png', 0.8),
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
                      onTap: () {
                        // For testing: make chicken dirty when tapped
                        if (petState == 'idle') {
                          _makeChickenDirty();
                        } else if (petState == 'clean') {
                          _playHappyAnimation();
                        }
                      },
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
                    widget.roomType == RoomType.bathroom
                        ? 'assets/soap.png'
                        : widget.roomType.mapIconAsset,
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                  onPressed:
                      widget.roomType == RoomType.bathroom
                          ? _playShowerAnimation
                          : widget.onMapsPressed,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.roomType == RoomType.bathroom
                      ? "Shower"
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
    switch (petState) {
      case 'happy':
        return 'assets/chickenHappy.png';
      case 'hungry':
        return 'assets/chicken_payment.png';
      case 'sleepy':
        return 'assets/chickenLevel.png';
      case 'dirty':
        return 'assets/dirty chick.png';
      case 'clean':
        return 'assets/chickenHappy.png';
      case 'showering':
        return 'assets/shower chick.png';
      default:
        return 'assets/pett.png';
    }
  }
}
