import 'package:flutter/material.dart';
import 'package:hellochickgu/features/tutor/widgets/youtube_video_list.dart';
import 'package:hellochickgu/features/tutor/data/youtube_video_data.dart';

class Course {
  final String title;
  final String university;
  final String description;
  final String lecturesText; // e.g., 50+ Lectures
  final String durationText; // e.g., 4 Weeks
  final String certificationText; // e.g., Online Certificate
  final List<String> skills;
  final String headerImageAssetPath;

  const Course({
    required this.title,
    required this.university,
    required this.description,
    required this.lecturesText,
    required this.durationText,
    required this.certificationText,
    required this.skills,
    required this.headerImageAssetPath,
  });
}

class TutorDetailPage extends StatelessWidget {
  final Course course;
  const TutorDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9f3fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'My School',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          _headerImage(course.headerImageAssetPath),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        course.university,
                        style: const TextStyle(color: Color(0xff1492e6)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Course Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: const TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _iconBullet(
                    'Lectures',
                    course.lecturesText,
                    Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: 10),
                  _iconBullet(
                    'Learning Time',
                    course.durationText,
                    Icons.schedule_rounded,
                  ),
                  const SizedBox(height: 10),
                  _iconBullet(
                    'Certification',
                    course.certificationText,
                    Icons.verified_rounded,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Skills',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: course.skills.map((s) => _SkillChip(s)).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: const Color(0xffe9f3fa),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final videos = YouTubeVideoData.getVideosByCourse(
                    course.title,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => YouTubeVideoList(
                            videos: videos,
                            courseTitle: course.title,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff47b2ff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Learn Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerImage(String assetPath) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.asset(assetPath, fit: BoxFit.cover),
    );
  }

  Widget _iconBullet(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
