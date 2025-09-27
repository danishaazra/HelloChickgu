import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';
import 'library_content.dart';
import '../../services/library_service.dart';

class CourseOutlinePage extends StatelessWidget {
  final String courseTitle;
  final int modules;
  final String duration;
  final String? courseId; // Optional courseId for database fetching

  const CourseOutlinePage({
    super.key,
    required this.courseTitle,
    required this.modules,
    required this.duration,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          courseTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$modules Modules',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chickgu image
                  Image.asset(
                    'assets/learning process python.png',
                    width: 90,
                    height: 90,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Course Outline",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),

            // Module list from database
            FutureBuilder<List<Map<String, dynamic>>>(
              future: courseId != null 
                  ? LibraryService().getCourseModules(courseId!)
                  : Future.value([]), // Fallback to empty list if no courseId
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading modules',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final modules = snapshot.data ?? [];

                if (modules.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No modules available',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Modules will appear here when they are added to this course.',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: modules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final module = entry.value;
                    return _ModuleTile(
                      number: index + 1,
                      title: module['title'] ?? 'Untitled Module',
                      progress: _getModuleProgress(module), // You can implement this based on user progress
                      moduleData: module,
                      courseId: courseId,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to get module progress (you can implement this based on user progress tracking)
  double _getModuleProgress(Map<String, dynamic> module) {
    // For now, return 0 (not started) for all modules
    // You can implement this to fetch actual user progress from the database
    return 0.0;
  }
}

class _ModuleTile extends StatelessWidget {
  final int number;
  final String title;
  final double progress;
  final Map<String, dynamic>? moduleData;
  final String? courseId;

  const _ModuleTile({
    required this.number,
    required this.title,
    required this.progress,
    this.moduleData,
    this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = progress >= 1.0;
    Color colorForNumber(int n) {
      switch ((n - 1) % 4) {
        case 0:
          return AppTheme.primaryBlue; // 1,5,9
        case 1:
          return AppTheme.primaryYellow; // 2,6,10
        case 2:
          return AppTheme.secondaryPink; // 3,7,11
        default:
          return AppTheme.secondaryMint; // 4,8,12
      }
    }

    final Color baseColor = colorForNumber(number);
    final bool inProgress = progress > 0 && progress < 1.0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => ModuleContentPage(
                  courseTitle:
                      (ModalRoute.of(context)?.settings.arguments as String?) ??
                      'Module',
                  moduleTitle: title,
                  backgroundImage: 'assets/librarybg.png',
                  subtopicTitle: 'Understanding Python',
                  progress: progress,
                  currentPage: 3, // set to last page for testing popup
                  totalPages: 3,
                ),
            builder: (_) => ModuleContentPage(
              courseTitle: courseId != null 
                  ? (moduleData?['courseTitle'] ?? 'Course')
                  : 'Module',
              moduleTitle: title,
              backgroundImage: 'assets/librarybg.png',
              subtopicTitle: moduleData?['content'] != null 
                  ? 'Module Content' 
                  : 'Understanding Python',
              progress: progress,
              currentPage: 1,
              totalPages: 1,
              courseId: courseId,
              moduleId: moduleData?['id'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (inProgress || completed)
              const _CutePlayBadge(size: 40)
            else
              CircleAvatar(
                radius: 20,
                backgroundColor: baseColor.withOpacity(0.25),
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: baseColor,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                color:
                    inProgress || completed ? AppTheme.primaryBlue : baseColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CutePlayBadge extends StatelessWidget {
  final double size;

  const _CutePlayBadge({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF7EC8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3357A6FF),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.48,
          height: size * 0.48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
          ),
          child: const Icon(
            Icons.play_arrow,
            color: AppTheme.primaryBlue,
            size: 18,
          ),
        ),
      ),
    );
  }
}
