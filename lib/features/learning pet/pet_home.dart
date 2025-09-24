import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/theme/theme.dart';
import 'widgets/base_pet_room.dart';
import 'models/room_type.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  RoomType _currentRoom = RoomType.home;

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
    // TODO: Navigate to maps page
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
    // TODO: Navigate to leaderboard page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leaderboard pressed from ${_currentRoom.displayName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePetRoom(
      roomType: _currentRoom,
      onPreviousRoom: _goToPreviousRoom,
      onNextRoom: _goToNextRoom,
      onMapsPressed: _onMapsPressed,
      onShopPressed: _onShopPressed,
      onLeaderboardPressed: _onLeaderboardPressed,
    );
  }

}
