import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.textTheme.bodyMedium?.color,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'My Library',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _LibraryContent(),
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryBanner(
          titleText: 'Start your lesson today!',
          backgroundColor: AppTheme.primaryBlue,
        ),
        const SizedBox(height: 24),
        Text(
          'Categories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const _CategoriesRow(),
        const SizedBox(height: 24),
        Text(
          'Continue Lesson',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _ContinueLessonCard(),
        const SizedBox(height: 24),
        Text(
          'Courses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _CoursesGrid(),
      ],
    );
  }
}

class LibraryBanner extends StatelessWidget {
  const LibraryBanner({
    super.key,
    required this.titleText,
    required this.backgroundColor,
  });

  final String titleText;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_nature,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SearchField(hintText: 'Search Lesson...'),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.6),
        ),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          CategoryChip(
            label: 'All',
            backgroundColor: AppTheme.primaryBlue,
            textColor: Colors.white,
          ),
          SizedBox(width: 8),
          CategoryChip(
            label: 'Bookmark',
            backgroundColor: AppTheme.primaryYellow,
            textColor: Colors.black,
          ),
          SizedBox(width: 8),
          CategoryChip(
            label: 'Coding',
            backgroundColor: AppTheme.secondaryPink,
            textColor: Colors.white,
          ),
          SizedBox(width: 8),
          CategoryChip(
            label: 'Green',
            backgroundColor: AppTheme.secondaryMint,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ContinueLessonCard extends StatelessWidget {
  const _ContinueLessonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const FlutterLogo(size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Python Programming',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 out of 5 modules',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 1 / 5,
                        minHeight: 8,
                        color: AppTheme.primaryBlue,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Ask Chippy'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursesGrid extends StatelessWidget {
  const _CoursesGrid();

  @override
  Widget build(BuildContext context) {
    final items = _sampleCourses;
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final course = items[index];
        return CourseCard(
          title: course.title,
          instructor: course.instructor,
          imageWidget: course.imageWidget,
          modulesText: course.modulesText,
          timeText: course.timeText,
          isActive: course.isActive,
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.imageWidget,
    required this.modulesText,
    required this.timeText,
    this.isActive = false,
  });

  final String title;
  final String instructor;
  final Widget imageWidget;
  final String modulesText;
  final String timeText;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: ColoredBox(
                color: AppTheme.bgLightBlue,
                child: Center(child: imageWidget),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            instructor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$modulesText • $timeText',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (isActive)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text('Continue'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseItemData {
  _CourseItemData({
    required this.title,
    required this.instructor,
    required this.imageWidget,
    required this.modulesText,
    required this.timeText,
    required this.isActive,
  });

  final String title;
  final String instructor;
  final Widget imageWidget;
  final String modulesText;
  final String timeText;
  final bool isActive;
}

final List<_CourseItemData> _sampleCourses = [
  _CourseItemData(
    title: 'Python Programming',
    instructor: 'By Alex Chen',
    imageWidget: const Icon(Icons.code, size: 36, color: Colors.black87),
    modulesText: '5 modules',
    timeText: '3h 10m',
    isActive: true,
  ),
  _CourseItemData(
    title: 'Computer Architecture',
    instructor: 'By Dr. Rivera',
    imageWidget: const Icon(Icons.memory, size: 36, color: Colors.black87),
    modulesText: '8 modules',
    timeText: '6h 40m',
    isActive: false,
  ),
  _CourseItemData(
    title: 'Data Structures',
    instructor: 'By Priya N.',
    imageWidget: const Icon(Icons.hub, size: 36, color: Colors.black87),
    modulesText: '6 modules',
    timeText: '4h 25m',
    isActive: false,
  ),
  _CourseItemData(
    title: 'Intro to Networking',
    instructor: 'By Omar K.',
    imageWidget: const Icon(Icons.router, size: 36, color: Colors.black87),
    modulesText: '7 modules',
    timeText: '5h 05m',
    isActive: false,
  ),
];
