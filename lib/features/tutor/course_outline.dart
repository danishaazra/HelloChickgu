import 'package:flutter/material.dart';
import 'learning_page.dart';

class CourseOutlinePage extends StatelessWidget {
  final String courseTitle;
  final String university;
  const CourseOutlinePage({super.key, required this.courseTitle, required this.university});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe9f3fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('Course Outline', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(courseTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(university, style: const TextStyle(color: Color(0xff1492e6))),
            ]),
          ),
          const SizedBox(height: 12),
          _lectureTile(context, 'Lists', 'How to create, access, and modify lists.'),
          _lectureTile(context, 'Tuples', 'Differences between list and tuple.'),
          _lectureTile(context, 'Dictionaries', 'Key-value pairs to store and retrieve data.'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _lectureTile(BuildContext context, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: Color(0xfff7a8b8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Text('0%'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LearningPage(courseTitle: courseTitle, lectureTitle: title)),
          );
        },
      ),
    );
  }
}


