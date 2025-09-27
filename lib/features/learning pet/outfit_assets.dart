class OutfitAssets {
  // Keys MUST match Shop item IDs in HatsShopPage
  static const Map<String, String> hatIdToAsset = {
    'pirate': 'assets/pirate hat.png',
    'grad_cap': 'assets/graduation hat.png',
    'party': 'assets/birthday hat.png',
    'crown': 'assets/crown.png',
  };

  static const Map<String, List<double>> hatIdToTransform = {
    // [offsetX, offsetY, scale]
    'pirate': [13.0, -120.0, 1.5],
    'grad_cap': [-25.0, -100.0, 1.8],
    'party': [10.0, -140.0, 1.0],
    'crown': [-18.0, -125.0, 1.05],
  };
}
