import 'package:flutter/material.dart';
import '../widgets/base_pet_room.dart';
import '../models/room_type.dart';

class PetLivingRoomPage extends StatelessWidget {
  final VoidCallback? onPreviousRoom;
  final VoidCallback? onNextRoom;
  final VoidCallback? onMapsPressed;
  final VoidCallback? onShopPressed;
  final VoidCallback? onLeaderboardPressed;

  const PetLivingRoomPage({
    super.key,
    this.onPreviousRoom,
    this.onNextRoom,
    this.onMapsPressed,
    this.onShopPressed,
    this.onLeaderboardPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BasePetRoom(
      roomType: RoomType.livingRoom,
      onPreviousRoom: onPreviousRoom,
      onNextRoom: onNextRoom,
      onMapsPressed: onMapsPressed,
      onShopPressed: onShopPressed,
      onLeaderboardPressed: onLeaderboardPressed,
    );
  }
}

