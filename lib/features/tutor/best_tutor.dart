import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hellochickgu/services/purchase_service.dart';
import 'widgets/youtube_player.dart';
import 'payment/video_payment_page.dart';

class BestTutorPage extends StatefulWidget {
  final String courseTitle; // e.g. "UI/UX Fundamentals"
  const BestTutorPage({super.key, required this.courseTitle});

  @override
  State<BestTutorPage> createState() => _BestTutorPageState();
}

class _BestTutorPageState extends State<BestTutorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9f3fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black87),
            tooltip: 'Search',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('videos')
                .orderBy('createdAt', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No videos found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final String videoId = doc.id;
              final String title = (data['title'] as String?) ?? 'Untitled';
              final String description = (data['description'] as String?) ?? '';
              final String youtubeUrl = (data['youtube'] as String?) ?? '';
              final int views = _safeIntCast(data['views']);
              final int likes = _safeIntCast(data['likes']);
              final int comments = _safeIntCast(data['comments']);
              final int price = _safeIntCast(data['price']);
              final String status = (data['status'] as String?) ?? '';
              final Timestamp? createdAt = data['createdAt'] as Timestamp?;

              // Format views
              final String viewsText = _formatViews(views);

              // Format creation date
              final String ageText = _formatDate(createdAt);

              // Get thumbnail from YouTube URL
              final String thumbnailUrl = _getYouTubeThumbnail(youtubeUrl);

              // Get video duration (we'll extract from YouTube)
              final String durationText =
                  '00:00'; // Placeholder - would need YouTube API for actual duration
              return _VideoCard(
                title: title,
                description: description,
                durationText: durationText,
                viewsText: viewsText,
                ageText: ageText,
                likes: likes,
                comments: comments,
                price: price,
                status: status,
                thumbnailUrl: thumbnailUrl,
                locked: !PurchaseService.instance.isPurchased(videoId),
                onTap: () async {
                  final isUnlocked = PurchaseService.instance.isPurchased(
                    videoId,
                  );
                  if (!isUnlocked) {
                    final paid = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder:
                            (_) => VideoPaymentPage(
                              videoId: videoId,
                              title: title,
                              priceText: 'RM $price',
                            ),
                      ),
                    );
                    if (paid == true) {
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => _VideoPlayerScaffold(
                                title: title,
                                videoUrl: youtubeUrl,
                              ),
                        ),
                      );
                    }
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => _VideoPlayerScaffold(
                            title: title,
                            videoUrl: youtubeUrl,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // per-video enrollment now handled by VideoPaymentPage
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String durationText;
  final String viewsText;
  final String ageText;
  final int likes;
  final int comments;
  final int price;
  final String status;
  final String thumbnailUrl;
  final bool locked;
  final VoidCallback onTap;

  const _VideoCard({
    required this.title,
    required this.description,
    required this.durationText,
    required this.viewsText,
    required this.ageText,
    required this.likes,
    required this.comments,
    required this.price,
    required this.status,
    required this.thumbnailUrl,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffe6eef6),
                borderRadius: BorderRadius.circular(16),
              ),
              height: 180,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          thumbnailUrl.isEmpty
                              ? const SizedBox()
                              : Image.network(thumbnailUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xfff0473d),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        durationText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewsText,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(likes),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.comment,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(comments),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (status == 'approved')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Approved',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price and date row
                  Row(
                    children: [
                      if (price > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff1492e6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'RM $price',
                            style: const TextStyle(
                              color: Color(0xff1492e6),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (ageText.isNotEmpty)
                        Text(
                          ageText,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerScaffold extends StatelessWidget {
  final String title;
  final String videoUrl;
  const _VideoPlayerScaffold({required this.title, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9f3fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: YouTubePlayer(youtubeUrl: videoUrl, title: title),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: const Text('Enjoy your lesson!'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatViews(int views) {
  if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M views';
  if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
  return '$views views';
}

String _formatNumber(int number) {
  if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
  if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
  return '$number';
}

String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return '';

  final DateTime date = timestamp.toDate();
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

String _getYouTubeThumbnail(String youtubeUrl) {
  if (youtubeUrl.isEmpty) return '';

  // Extract video ID from YouTube URL
  final RegExp regExp = RegExp(
    r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
  );
  final Match? match = regExp.firstMatch(youtubeUrl);

  if (match != null) {
    final String videoId = match.group(1)!;
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  return '';
}

int _safeIntCast(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
