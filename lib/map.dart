import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'features/home/home.dart';
import 'features/game/level_page.dart';
import 'features/library/library_main.dart';
import 'features/tutor/main_tutor.dart';

class MapChickgu extends StatelessWidget {
  const MapChickgu({super.key});

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
            child: _buildLocation(context, "assets/homefinal.png", "Home"),
          ),

          // Library
          Positioned(
            top: 250,
            right: 40,
            child: _buildLocation(
              context,
              "assets/library2_map.png",
              "Library",
            ),
          ),

          // Playground
          Positioned(
            bottom: 200,
            left: 40,
            child: _buildLocation(
              context,
              "assets/playground2_map.png",
              "Playground",
            ),
          ),

          // School
          Positioned(
            bottom: 50,
            right: 40,
            child: _buildLocation(context, "assets/school2_map.png", "School"),
          ),
        ],
      ),
    );
  }

  // Reusable clickable location widget with animation
  Widget _buildLocation(BuildContext context, String image, String label) {
    return GestureDetector(
      onTap: () => navigateTo(context, label),
      child: Column(
        children: [
          Hero(
            tag: label,
            child: AnimatedScale(
              scale: 1.1,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  Image.asset(image, height: 150),
                  // Add a subtle glow effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
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
