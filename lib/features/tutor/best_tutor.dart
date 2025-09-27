import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hellochickgu/services/purchase_service.dart';
import 'widgets/video_lecture_player.dart';
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
              final String author = (data['author'] as String?) ?? '';
              final String durationText = _readableDuration(data['duration']);
              final String viewsText = _formatViews(data['views']);
              final String ageText = (data['ageText'] as String?) ?? '';
              final List<dynamic> tagsRaw =
                  (data['tags'] as List<dynamic>?) ?? const [];
              final List<String> tags =
                  tagsRaw.map((e) => e.toString()).toList();
              final String thumbnailUrl =
                  (data['thumbnailUrl'] as String?) ?? '';
              final String videoUrl = (data['videoUrl'] as String?) ?? '';
              return _VideoCard(
                title: title,
                author: author,
                durationText: durationText,
                viewsText: viewsText,
                ageText: ageText,
                tags: tags,
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
                                videoUrl: videoUrl,
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
                            videoUrl: videoUrl,
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
  final String author;
  final String durationText;
  final String viewsText;
  final String ageText;
  final List<String> tags;
  final String thumbnailUrl;
  final bool locked;
  final VoidCallback onTap;
  const _VideoCard({
    required this.title,
    required this.author,
    required this.durationText,
    required this.viewsText,
    required this.ageText,
    required this.tags,
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
                  if (author.isNotEmpty)
                    Text(author, style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        viewsText,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ageText,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        tags.take(3).map((t) => _TagChip(text: t)).toList(),
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

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffffeef0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
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
            child: VideoLecturePlayer(source: videoUrl, isAsset: false),
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

String _readableDuration(dynamic raw) {
  if (raw == null) return '00:00';
  if (raw is String && raw.isNotEmpty) return raw; // already formatted
  if (raw is int) {
    final d = Duration(seconds: raw);
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
  return '00:00';
}

String _formatViews(dynamic raw) {
  if (raw == null) return '';
  if (raw is String) return raw;
  if (raw is int) {
    if (raw >= 1000000) return '${(raw / 1000000).toStringAsFixed(1)}M views';
    if (raw >= 1000) return '${(raw / 1000).toStringAsFixed(1)}K views';
    return '$raw views';
  }
  return '';
}
