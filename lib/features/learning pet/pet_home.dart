import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'package:hellochickgu/services/user_service.dart';
import 'widgets/base_pet_room.dart';
import 'models/room_type.dart';
import 'package:hellochickgu/map.dart';
import 'package:hellochickgu/features/profile/profile.dart';
import 'package:hellochickgu/features/leaderboard/leaderboard.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  RoomType _currentRoom = RoomType.home;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await UserService.instance.getCurrentUserData();
    if (mounted) {
      setState(() {
        _userData = userData?.data() as Map<String, dynamic>?;
      });
    }
  }

  void _navigateToRoom(RoomType roomType) {
    setState(() {
      _currentRoom = roomType;
    });
  }

  void _goToPreviousRoom() {
    final rooms = RoomType.values;
    final currentIndex = rooms.indexOf(_currentRoom);
    final previousIndex = (currentIndex - 1 + rooms.length) % rooms.length;
    _navigateToRoom(rooms[previousIndex]);
  }

  void _goToNextRoom() {
    final rooms = RoomType.values;
    final currentIndex = rooms.indexOf(_currentRoom);
    final nextIndex = (currentIndex + 1) % rooms.length;
    _navigateToRoom(rooms[nextIndex]);
  }

  void _onMapsPressed() {
    if (_currentRoom == RoomType.home) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapChickgu()),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Maps pressed from ${_currentRoom.displayName}')),
    );
  }

  void _onShopPressed() {
    // TODO: Navigate to shop page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shop pressed from ${_currentRoom.displayName}')),
    );
  }

  void _onLeaderboardPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  void _onProfilePressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePetRoom(
      roomType: _currentRoom,
      userData: _userData,
      onPreviousRoom: _goToPreviousRoom,
      onNextRoom: _goToNextRoom,
      onMapsPressed: _onMapsPressed,
      onShopPressed: _onShopPressed,
      onLeaderboardPressed: _onLeaderboardPressed,
      onProfilePressed: _onProfilePressed,
    );
  }
}
