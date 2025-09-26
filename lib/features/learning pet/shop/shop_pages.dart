import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            shadows: [
                              Shadow(
                                offset: Offset(-1, -1),
                                color: Colors.black,
                              ),
                              Shadow(
                                offset: Offset(1, -1),
                                color: Colors.black,
                              ),
                              Shadow(offset: Offset(1, 1), color: Colors.black),
                              Shadow(
                                offset: Offset(-1, 1),
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          children: [
                            _CategoryCard(
                              title: 'Hats',
                              imageAsset: 'assets/graduation hat.png',
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HatsShopPage(),
                                    ),
                                  ),
                            ),
                            _CategoryCard(
                              title: 'Glasses',
                              imageAsset: 'assets/spec.png',
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GlassesShopPage(),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAsset, width: 56, height: 56, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HatsShopPage extends StatelessWidget {
  const HatsShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _ShopItem(
        id: 'grad_cap',
        title: 'Graduation Cap',
        price: 10,
        asset: 'assets/graduation hat.png',
      ),
      _ShopItem(
        id: 'pirate',
        title: 'Pirate Hat',
        price: 20,
        asset: 'assets/pirate hat.png',
      ),
      _ShopItem(
        id: 'party',
        title: 'Party Hat',
        price: 35,
        asset: 'assets/birthday hat.png',
      ),
      _ShopItem(
        id: 'crown',
        title: 'Crown',
        price: 40,
        asset: 'assets/crown.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      _titleBadge('Hats'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: StreamBuilder<DocumentSnapshot?>(
                        stream:
                            FirebaseAuth.instance.currentUser == null
                                ? const Stream.empty()
                                : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                        builder: (context, snapshot) {
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          final points = (data?['points'] ?? 0) as int;
                          final owned =
                              (data?['ownedItems']?['hat'] as List?)
                                  ?.cast<String>() ??
                              <String>[];
                          final equipped =
                              (data?['currentOutfit']?['hat']) as String?;

                          return Column(
                            children: [
                              _pointsRow(points),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    final crossAxisCount = width < 380 ? 2 : 3;
                                    final aspect = width < 380 ? 0.75 : 0.82;
                                    return GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      itemCount: items.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            childAspectRatio: aspect,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                          ),
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        final isOwned = owned.contains(item.id);
                                        final isEquipped = equipped == item.id;
                                        return _HatCard(
                                          item: item,
                                          isOwned: isOwned,
                                          isEquipped: isEquipped,
                                          canAfford: points >= item.price,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HatCard extends StatelessWidget {
  final _ShopItem item;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;

  const _HatCard({
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  item.asset!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (!isOwned)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/coin.png', width: 18, height: 18),
                const SizedBox(width: 4),
                Text(item.price.toString()),
              ],
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                final doc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid);

                await FirebaseFirestore.instance.runTransaction((txn) async {
                  final snap = await txn.get(doc);
                  final data = snap.data() as Map<String, dynamic>;
                  final points = (data['points'] ?? 0) as int;
                  final owned =
                      (data['ownedItems']?['hat'] as List?)?.cast<String>() ??
                      <String>[];
                  final currentOutfit = Map<String, dynamic>.from(
                    data['currentOutfit'] ?? {},
                  );

                  if (!isOwned) {
                    if (points < item.price) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient funds!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // insufficient funds
                    }
                    owned.add(item.id);
                    txn.update(doc, {
                      'points': points - item.price,
                      'ownedItems.hat': owned,
                      'lastUpdated': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.title} purchased for ${item.price} coins!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Toggle equip
                    currentOutfit['hat'] = isEquipped ? null : item.id;
                    txn.update(doc, {
                      'currentOutfit': currentOutfit,
                      'lastUpdated': FieldValue.serverTimestamp(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEquipped
                              ? '${item.title} unequipped!'
                              : '${item.title} equipped!',
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                !isOwned
                    ? (canAfford ? 'Buy' : 'Locked')
                    : (isEquipped ? 'Unequip' : 'Equip'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopItem {
  final String id;
  final String title;
  final int price;
  final String? asset;
  const _ShopItem({
    required this.id,
    required this.title,
    required this.price,
    this.asset,
  });
}

// Glasses (Specs) page
class GlassesShopPage extends StatelessWidget {
  const GlassesShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      _titleBadge('Glasses'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: StreamBuilder<DocumentSnapshot?>(
                        stream:
                            FirebaseAuth.instance.currentUser == null
                                ? const Stream.empty()
                                : FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                        builder: (context, snapshot) {
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          final points = (data?['points'] ?? 0) as int;

                          return Column(
                            children: [
                              _pointsRow(points),
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.construction,
                                        size: 64,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Coming Soon',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Glasses collection will be available soon!',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable UI bits
Widget _titleBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 24,
        shadows: [
          Shadow(offset: Offset(-1, -1), color: Colors.black),
          Shadow(offset: Offset(1, -1), color: Colors.black),
          Shadow(offset: Offset(1, 1), color: Colors.black),
          Shadow(offset: Offset(-1, 1), color: Colors.black),
        ],
      ),
    ),
  );
}

Widget _pointsRow(int points) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        Image.asset('assets/coin.png', width: 22, height: 22),
        const SizedBox(width: 6),
        Text(
          points.toString(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
