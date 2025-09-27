import 'package:flutter/material.dart';
import 'tutor2.dart';
import 'package:hellochickgu/services/purchase_service.dart';
import 'course_outline.dart';
import 'best_tutor.dart';

class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});

  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  final List<_CategoryChip> _categories = const [
    _CategoryChip(label: 'Computer Science', icon: Icons.computer),
    _CategoryChip(label: 'Mathematics', icon: Icons.calculate),
    _CategoryChip(label: 'Design', icon: Icons.brush),
    _CategoryChip(label: 'Business', icon: Icons.business_center),
  ];

  late final List<_TutorItem> _tutors = [
    _TutorItem(
      name: 'User Interface & User Experience',
      university: 'Universiti Putra Malaysia',
      rating: 4.7,
      students: 3120,
      imageAssetPath: 'assets/game_tutor2.png',
      course: Course(
        title: 'UI/UX Fundamentals',
        university: 'Universiti Putra Malaysia',
        description:
            'Learn human-centered design, wireframing, prototyping, and usability testing. This course helps you craft intuitive experiences with solid visual hierarchies and interaction patterns.',
        lecturesText: '40+ Lectures',
        durationText: '3 Weeks',
        certificationText: 'Certificate of Completion',
        skills: const [
          'Wireframing',
          'Prototyping',
          'Usability',
          'Design Systems',
        ],
        headerImageAssetPath: 'assets/uiux_tutor_2.webp',
      ),
    ),
    _TutorItem(
      name: 'Python Programming',
      university: 'Universiti Putra Malaysia',
      rating: 4.8,
      students: 2457,
      imageAssetPath: 'assets/python_tutor2.png',
      course: Course(
        title: 'Python Programming',
        university: 'Universiti Sains Malaysia',
        description:
            'Start from the basics and progress to data structures, OOP, and problem solving with Python. Build a solid foundation to tackle scripting and backend tasks.',
        lecturesText: '50+ Lectures',
        durationText: '4 Weeks',
        certificationText: 'Online Certificate',
        skills: const [
          'Web',
          'Data Science',
          'ML',
          'Basic Programming',
          'Graph',
        ],
        headerImageAssetPath: 'assets/python_tutor2.jpg',
      ),
    ),
    _TutorItem(
      name: 'Game Development',
      university: 'Universiti Putra Malaysia',
      rating: 4.6,
      students: 1890,
      imageAssetPath: 'assets/game_tutor.png',
      course: Course(
        title: 'Game Development',
        university: 'Universiti Putra Malaysia',
        description:
            'Explore game design pipelines, 2D/3D rendering basics, physics, and scripting. Build a small game project and learn to iterate on gameplay and user feedback.',
        lecturesText: '60+ Lectures',
        durationText: '5 Weeks',
        certificationText: 'Project Certificate',
        skills: const ['Unity', 'C#', 'Level Design', 'Animation'],
        headerImageAssetPath: 'assets/game_tutor_2.png',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'My School',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroCard(context),
          const SizedBox(height: 16),
          const Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final c = _categories[index];
                return Chip(
                  label: Text(c.label),
                  avatar: Icon(c.icon, size: 16),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tutor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._tutors.map(
            (t) => _TutorCard(
              item: t,
              onTap: () {
                final purchased = PurchaseService.instance.isPurchased(
                  t.course.title,
                );
                if (purchased) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => CourseOutlinePage(
                            courseTitle: t.course.title,
                            university: t.course.university,
                          ),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TutorDetailPage(course: t.course),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff9fd9ff),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Your Best\nTutor!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => const BestTutorPage(courseTitle: 'Best Tutor'),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('Best Tutor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff1492e6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final _TutorItem item;
  final VoidCallback onTap;
  const _TutorCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.imageAssetPath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.university,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffdff3ff),
                          foregroundColor: const Color(0xff1492e6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Learn Now'),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: Color(0xffffb800),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(item.rating.toStringAsFixed(1)),
                      const SizedBox(width: 12),
                      const Icon(Icons.group, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(item.students.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip {
  final String label;
  final IconData icon;
  const _CategoryChip({required this.label, required this.icon});
}

class _TutorItem {
  final String name;
  final String university;
  final double rating;
  final int students;
  final String imageAssetPath;
  final Course course;
  _TutorItem({
    required this.name,
    required this.university,
    required this.rating,
    required this.students,
    required this.imageAssetPath,
    required this.course,
  });
}
