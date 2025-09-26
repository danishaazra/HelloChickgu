enum RoomType { home, kitchen, bedroom, bathroom, livingRoom }

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.home:
        return 'Home';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.bedroom:
        return 'Bedroom';
      case RoomType.bathroom:
        return 'Bathroom';
      case RoomType.livingRoom:
        return 'Living Room';
    }
  }

  String get backgroundAsset {
    switch (this) {
      case RoomType.home:
        return 'assets/homepet.png';
      case RoomType.kitchen:
        return 'assets/pet kitchen bg.png';
      case RoomType.bedroom:
        return 'assets/pet bedroom bg.png';
      case RoomType.bathroom:
        return 'assets/pet bathroom bg.png';
      case RoomType.livingRoom:
        return 'assets/pet home bg.png'; // Using home bg as default for living room
    }
  }

  String get mapIconAsset {
    switch (this) {
      case RoomType.home:
        return 'assets/maps icon.png';
      case RoomType.kitchen:
        return 'assets/food icon (2).png';
      case RoomType.bedroom:
        return 'assets/lamp.png';
      case RoomType.bathroom:
        return 'assets/soap.png'; // Using soap icon for bathroom
      case RoomType.livingRoom:
        return 'assets/home2_map.png'; // Using alternative home map for living room
    }
  }

  String get mapButtonText {
    switch (this) {
      case RoomType.bedroom:
        return 'Lamp';
      case RoomType.kitchen:
        return 'Food';
      case RoomType.bathroom:
        return 'Shower';
      case RoomType.bedroom:
        return 'Lamp';
      default:
        return 'Maps';
    }
  }
}
