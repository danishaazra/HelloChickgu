import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'features/home/home.dart';
import 'features/game/level_page.dart';
import 'features/library/library_main.dart';
import 'features/tutor/main_tutor.dart';

class MapChickgu extends StatefulWidget {
  const MapChickgu({super.key});

  @override
  State<MapChickgu> createState() => _MapChickguState();
}

class _MapChickguState extends State<MapChickgu> with TickerProviderStateMixin {
  late AnimationController _homeController;
  late AnimationController _libraryController;
  late AnimationController _playgroundController;
  late AnimationController _schoolController;

  late Animation<double> _homeFloatAnimation;
  late Animation<double> _libraryFloatAnimation;
  late Animation<double> _playgroundFloatAnimation;
  late Animation<double> _schoolFloatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each location
    _homeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _libraryController = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 500),
      vsync: this,
    );
    _playgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _schoolController = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 200),
      vsync: this,
    );

    // Create floating animations
    _homeFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _homeController, curve: Curves.easeInOut),
    );

    _libraryFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _libraryController, curve: Curves.easeInOut),
    );

    _playgroundFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _playgroundController, curve: Curves.easeInOut),
    );

    _schoolFloatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _schoolController, curve: Curves.easeInOut),
    );

    // Start animations with staggered delays
    _startAnimations();
  }

  void _startAnimations() {
    _homeController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 500), () {
      _libraryController.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _playgroundController.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      _schoolController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    _libraryController.dispose();
    _playgroundController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void navigateTo(BuildContext context, String place) {
    Widget targetPage;

    switch (place) {
      case "Home":
        targetPage = const HomePage();
        break;
      case "Library":
        targetPage = const LibraryPage();
        break;
      case "Playground":
        targetPage = const LevelPage();
        break;
      case "School":
        targetPage = const TutorListPage();
        break;
      default:
        targetPage = PlacePage(place: place);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Stack(
        children: [
          // Background map image
          Positioned.fill(
            child: Image.asset(
              "assets/background_map_2.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          // iPhone-style back button inside black circular container
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Home
          Positioned(
            top: 80,
            left: 40,
            child: _buildAnimatedLocation(
              context,
              "assets/homefinal.png",
              "Home",
              _homeFloatAnimation,
            ),
          ),

          // Library
          Positioned(
            top: 250,
            right: 40,
            child: _buildAnimatedLocation(
              context,
              "assets/library2_map.png",
              "Library",
              _libraryFloatAnimation,
            ),
          ),

          // Playground
          Positioned(
            bottom: 200,
            left: 40,
            child: _buildAnimatedLocation(
              context,
              "assets/playground2_map.png",
              "Playground",
              _playgroundFloatAnimation,
            ),
          ),

          // School
          Positioned(
            bottom: 50,
            right: 40,
            child: _buildAnimatedLocation(
              context,
              "assets/school2_map.png",
              "School",
              _schoolFloatAnimation,
            ),
          ),
        ],
      ),
    );
  }

  // Animated location widget with motion effects
  Widget _buildAnimatedLocation(
    BuildContext context,
    String image,
    String label,
    Animation<double> floatAnimation,
  ) {
    return GestureDetector(
      onTap: () => navigateTo(context, label),
      child: AnimatedBuilder(
        animation: floatAnimation,
        builder: (context, child) {
          return Column(
            children: [
              Hero(
                tag: label,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -8 * (0.5 - (floatAnimation.value - 0.5).abs()),
                  ),
                  child: Transform.scale(
                    scale:
                        1.0 +
                        (0.1 * (0.5 - (floatAnimation.value - 0.5).abs())),
                    child: Stack(
                      children: [
                        Image.asset(
                          image,
                          height: 135,
                          width: 135,
                          fit: BoxFit.cover,
                        ),
                        // Enhanced glow effect that pulses with animation
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha:
                                        0.4 +
                                        (0.2 *
                                            (0.5 -
                                                (floatAnimation.value - 0.5)
                                                    .abs())),
                                  ),
                                  blurRadius:
                                      15 +
                                      (5 *
                                          (0.5 -
                                              (floatAnimation.value - 0.5)
                                                  .abs())),
                                  spreadRadius:
                                      5 +
                                      (2 *
                                          (0.5 -
                                              (floatAnimation.value - 0.5)
                                                  .abs())),
                                ),
                                BoxShadow(
                                  color: Colors.blue.withValues(
                                    alpha:
                                        0.2 *
                                        (0.5 -
                                            (floatAnimation.value - 0.5).abs()),
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Animated label with subtle motion
              Transform.translate(
                offset: Offset(
                  0,
                  -2 * (0.5 - (floatAnimation.value - 0.5).abs()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Example PlacePage
class PlacePage extends StatelessWidget {
  final String place;
  const PlacePage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place)),
      body: Center(
        child: Hero(
          tag: place,
          child: Text(
            "Welcome to $place!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
