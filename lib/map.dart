import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MapChickgu extends StatelessWidget {
  const MapChickgu({super.key});

  void navigateTo(BuildContext context, String place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlacePage(place: place)),
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
              child: Image.asset(image, height: 150),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
