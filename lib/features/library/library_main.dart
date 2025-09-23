import 'package:flutter/material.dart';
import '../../shared/theme/theme.dart';
import 'library_courseoutline.dart';
import '../chatbot/chippy_chatbot.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = Responsive.isSmallScreen(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.textTheme.bodyMedium?.color,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'My Library',
          style: TextStyle(
            fontSize: Responsive.scaleFont(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Responsive.scalePaddingAll(context, 16),
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
    final isSmallScreen = Responsive.isSmallScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryBanner(
          titleText: 'Start your lesson today!',
          backgroundColor: AppTheme.primaryBlue,
        ),
        const SizedBox(height: 24),
        _AskChippySection(),
        const SizedBox(height: 24),
        SizedBox(height: Responsive.scaleHeight(context, 24)),
        Text(
          'Continue Lesson',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        const _ContinueLessonCard(),
        const SizedBox(height: 24),
        Text(
          'Categories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const _CategoriesRow(),
        const SizedBox(height: 24),
        Text(
          'Courses',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        const _CoursesGrid(),
      ],
    );
  }
}

class _AskChippySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ChippyChatbotPage()));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.18),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryMint.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: -6,
              child: SizedBox(
                width: 140,
                height: 140,
                child: Image.asset(
                  'assets/chippy chatbot.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask Chippy!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Our AI chatbot helps answer your study questions and keep you motivated.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChippyChatbotPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Ask Now!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(20),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 0),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: OverflowBox(
                      alignment: Alignment.centerRight,
                      maxWidth: 200,
                      maxHeight: 200,
                      child: Image.asset(
                        'assets/library banner.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.6),
        ),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _CategoriesRow extends StatefulWidget {
  const _CategoriesRow();

  @override
  State<_CategoriesRow> createState() => _CategoriesRowState();
}

class _CategoriesRowState extends State<_CategoriesRow> {
  final List<_CategoryData> _categories = const [
    _CategoryData('All', Colors.white),
    _CategoryData('Bookmark', AppTheme.primaryYellow),
    _CategoryData('Coding', AppTheme.secondaryPink),
    _CategoryData('Green', AppTheme.secondaryMint),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final item = _categories[index];
          final isSelected = index == _selectedIndex;
          return Row(
            children: [
              CategoryChip(
                label: item.label,
                dotColor: item.dotColor,
                selected: isSelected,
                onTap: () => setState(() => _selectedIndex = index),
              ),
              const SizedBox(width: 8),
            ],
          );
        }),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color dotColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color background = selected ? AppTheme.primaryBlue : Colors.white;
    final Color labelColor = selected ? Colors.white : Colors.black87;
    final Color? borderColor = selected ? null : Colors.grey.shade300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 96,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: borderColor == null ? null : Border.all(color: borderColor),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String label;
  final Color dotColor;
  const _CategoryData(this.label, this.dotColor);
}

class _ContinueLessonCard extends StatelessWidget {
  const _ContinueLessonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double progress = 1 / 5;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: Image.asset(
                    'assets/learning process python.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Python Programming',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 out of 5 modules',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 16,
                              color: AppTheme.primaryBlue,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(progress * 100).round()}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Removed Ask Chippy button
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
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final course = items[index];
        return CourseCard(
          title: course.title,
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
    required this.imageWidget,
    required this.modulesText,
    required this.timeText,
    this.isActive = false,
  });

  final String title;
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
              height: 84,
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
          const SizedBox(height: 6),
          const Spacer(),
          Text('$modulesText • $timeText', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                side: MaterialStateProperty.all(
                  BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered) ||
                      states.contains(MaterialState.pressed) ||
                      states.contains(MaterialState.focused)) {
                    return AppTheme.primaryBlue;
                  }
                  return Colors.white;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered) ||
                      states.contains(MaterialState.pressed) ||
                      states.contains(MaterialState.focused)) {
                    return Colors.white;
                  }
                  return AppTheme.primaryBlue;
                }),
                overlayColor: MaterialStateProperty.all(
                  AppTheme.primaryBlue.withOpacity(0.1),
                ),
                elevation: MaterialStateProperty.all(0),
              ),
              onPressed: () {
                final int moduleCount =
                    int.tryParse(modulesText.split(' ').first) ?? 0;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => CourseOutlinePage(
                          courseTitle: title,
                          modules: moduleCount,
                          duration: timeText,
                        ),
                  ),
                );
              },
              child: Text(
                isActive ? 'Continue' : 'Start',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseItemData {
  _CourseItemData({
    required this.title,
    required this.imageWidget,
    required this.modulesText,
    required this.timeText,
    required this.isActive,
  });

  final String title;
  final Widget imageWidget;
  final String modulesText;
  final String timeText;
  final bool isActive;
}

final List<_CourseItemData> _sampleCourses = [
  _CourseItemData(
    title: 'Python Programming',
    imageWidget: const Icon(Icons.code, size: 36, color: Colors.black87),
    modulesText: '5 modules',
    timeText: '3h 10m',
    isActive: true,
  ),
  _CourseItemData(
    title: 'Computer Architecture',
    imageWidget: const Icon(Icons.memory, size: 36, color: Colors.black87),
    modulesText: '8 modules',
    timeText: '6h 40m',
    isActive: false,
  ),
  _CourseItemData(
    title: 'Data Structures',
    imageWidget: const Icon(Icons.hub, size: 36, color: Colors.black87),
    modulesText: '6 modules',
    timeText: '4h 25m',
    isActive: false,
  ),
  _CourseItemData(
    title: 'Intro to Networking',
    imageWidget: const Icon(Icons.router, size: 36, color: Colors.black87),
    modulesText: '7 modules',
    timeText: '5h 05m',
    isActive: false,
  ),
];
