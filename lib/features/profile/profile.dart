import 'package:flutter/material.dart';
import 'package:hellochickgu/shared/utils/responsive.dart';

import 'dart:math' as math;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final isSmallScreen = Responsive.isSmallScreen(context);
    final isVerySmallScreen = Responsive.isVerySmallScreen(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://i.pinimg.com/1200x/6a/61/db/6a61db73fcbe1fdf53ae05f53fa10c47.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.black,
                                  onPressed:
                                      () => Navigator.of(context).maybePop(),
                                  tooltip: 'Back',
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Profile',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 72),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Nurin Sunoo',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final List<IconData> icons = <IconData>[
                        Icons.person,
                        Icons.subscriptions,
                        Icons.emoji_events,
                        Icons.bar_chart,
                        Icons.settings,
                      ];
                      final List<String> titles = <String>[
                        'Personal Information',
                        'Subscription',
                        'Badges',
                        'Statistic',
                        'Settings',
                      ];
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: titles.length,
                        itemBuilder:
                            (context, index) => _ProfileItem(
                              icon: icons[index],
                              title: titles[index],
                              onTap: () {
                                if (index == 0) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const PersonalInformationPage(),
                                    ),
                                  );
                                } else if (index == 1) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SubscriptionsPage(),
                                    ),
                                  );
                                } else if (index == 2) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const BadgesPage(),
                                    ),
                                  );
                                } else if (index == 3) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const StatisticsPage(),
                                    ),
                                  );
                                } else if (index == 4) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  );
                                }
                              },
                            ),
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 200 - 48,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 5),
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(
                      'https://i.pinimg.com/736x/2e/16/fc/2e16fce4b74cb63468147a2a0b54bd90.jpg',
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final String _bio =
      'Curious learner and community member. I enjoy reading, writing, and collecting badges along the journey!';
  late final List<_Post> _posts = <_Post>[
    _Post(
      authorName: 'Nurin Sunoo',
      authorAvatarUrl:
          'https://i.pinimg.com/736x/2e/16/fc/2e16fce4b74cb63468147a2a0b54bd90.jpg',
      timeAgo: '1s',
      content:
          "I'm learning Java and I don't really get the difference between == and .equals(). When I compare two strings, sometimes == doesn't work but .equals() does. Can someone explain why?",
      likes: 10,
      comments: 2,
      badgeColor: Colors.orange,
    ),
    _Post(
      authorName: 'Nurin Sunoo',
      authorAvatarUrl:
          'https://i.pinimg.com/736x/2e/16/fc/2e16fce4b74cb63468147a2a0b54bd90.jpg',
      timeAgo: '30m',
      content: 'How do I make a button component in Figma?',
      likes: 10,
      comments: 2,
      badgeColor: Colors.amber,
    ),
    _Post(
      authorName: 'Nurin Sunoo',
      authorAvatarUrl:
          'https://i.pinimg.com/736x/2e/16/fc/2e16fce4b74cb63468147a2a0b54bd90.jpg',
      timeAgo: '1h',
      content:
          "I'm learning Java and a bit confused... what's the difference between an array and an ArrayList? When should I use one over the other?",
      likes: 30,
      comments: 11,
      badgeColor: Colors.purple,
    ),
  ];
  int _activeTabIndex = 0; // 0 = Recent Posts, 1 = Achievements

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFECF4F9),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://i.pinimg.com/1200x/6a/61/db/6a61db73fcbe1fdf53ae05f53fa10c47.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.black,
                                  onPressed:
                                      () => Navigator.of(context).maybePop(),
                                  tooltip: 'Back',
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Personal Information',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Nurin Sunoo',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bio',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Recent Posts',
                          isActive: _activeTabIndex == 0,
                          onTap: () => setState(() => _activeTabIndex = 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TabButton(
                          label: 'Journey',
                          isActive: _activeTabIndex == 1,
                          onTap: () => setState(() => _activeTabIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child:
                        _activeTabIndex == 0
                            ? ListView.separated(
                              key: const ValueKey('posts'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              itemCount: _posts.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder:
                                  (context, index) =>
                                      _PostCard(post: _posts[index]),
                            )
                            : SingleChildScrollView(
                              key: const ValueKey('journey'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Achievements',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 110,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 10,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(width: 12),
                                      itemBuilder:
                                          (context, index) =>
                                              const _BadgeThumbnail(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Performance',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 280,
                                          child: _RadarChart(
                                            categories: const [
                                              'Memory',
                                              'Solving',
                                              'Patterns',
                                              'Logic',
                                              'Understanding',
                                            ],
                                            values: const [
                                              0.7,
                                              0.55,
                                              0.8,
                                              0.65,
                                              0.5,
                                            ],
                                            categoryColors: const [
                                              Color(0xFF6C63FF),
                                              Color(0xFFFF6584),
                                              Color(0xFF00BFA6),
                                              Color(0xFFFFC107),
                                              Color(0xFF29B6F6),
                                            ],
                                            levels: 5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 16,
                                          runSpacing: 8,
                                          children: const [
                                            _LegendDot(
                                              color: Color(0xFF6C63FF),
                                              label: 'Memory',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFFFF6584),
                                              label: 'Solving',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFF00BFA6),
                                              label: 'Patterns',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFFFFC107),
                                              label: 'Logic',
                                            ),
                                            _LegendDot(
                                              color: Color(0xFF29B6F6),
                                              label: 'Understanding',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 200 - 48,
              left: 24,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 5),
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    'https://i.pinimg.com/736x/2e/16/fc/2e16fce4b74cb63468147a2a0b54bd90.jpg',
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removed editable field widget since PersonalInformationPage is now view-only

class _BadgeThumbnail extends StatelessWidget {
  const _BadgeThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 32),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.black;
    final Color inactiveColor = Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isActive ? Colors.black : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isActive ? activeColor : inactiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// removed _PerformanceMeter (replaced by radar chart in Journey)

class _Post {
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final Color badgeColor;

  _Post({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.badgeColor,
  });
}

class _PostCard extends StatelessWidget {
  final _Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(post.authorAvatarUrl),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: post.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text('${post.likes}'),
                const SizedBox(width: 16),
                Icon(
                  Icons.mode_comment_outlined,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text('${post.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.black,
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Back',
                        ),
                      ),
                      Center(
                        child: Text(
                          'Subscription',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active subscription card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Tutor Subscription',
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Active',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Active until Oct 31, 2025',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: const [
                                        _SubChip(
                                          icon: Icons.play_circle_outline,
                                          label: 'Unlimited sessions',
                                        ),
                                        _SubChip(
                                          icon: Icons.download_outlined,
                                          label: 'Download notes',
                                        ),
                                        _SubChip(
                                          icon: Icons.support_agent_outlined,
                                          label: 'Priority support',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SubChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}

// Suggestions section removed per request

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFECF4F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                    ),
                  ),
                  Center(
                    child: Text(
                      'Badges',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: 10, // You can adjust this based on your badges
                  itemBuilder: (context, index) {
                    return _BadgeItem(badgeIndex: index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final int badgeIndex;

  const _BadgeItem({required this.badgeIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for badge image
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Badge ${badgeIndex + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFECF4F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                    ),
                  ),
                  Center(
                    child: Text(
                      'Statistics',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 320,
                            child: _RadarChart(
                              categories: const [
                                'Memory',
                                'Solving',
                                'Patterns',
                                'Logic',
                                'Understanding',
                              ],
                              values: const [
                                0.7, // Memory
                                0.55, // Solving
                                0.8, // Patterns
                                0.65, // Logic
                                0.5, // Understanding
                              ],
                              categoryColors: const [
                                Color(0xFF6C63FF),
                                Color(0xFFFF6584),
                                Color(0xFF00BFA6),
                                Color(0xFFFFC107),
                                Color(0xFF29B6F6),
                              ],
                              levels: 5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: const [
                              _LegendDot(
                                color: Color(0xFF6C63FF),
                                label: 'Memory',
                              ),
                              _LegendDot(
                                color: Color(0xFFFF6584),
                                label: 'Solving',
                              ),
                              _LegendDot(
                                color: Color(0xFF00BFA6),
                                label: 'Patterns',
                              ),
                              _LegendDot(
                                color: Color(0xFFFFC107),
                                label: 'Logic',
                              ),
                              _LegendDot(
                                color: Color(0xFF29B6F6),
                                label: 'Understanding',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _RadarChart extends StatelessWidget {
  final List<String> categories;
  final List<double> values; // 0..1
  final List<Color> categoryColors;
  final int levels;

  const _RadarChart({
    required this.categories,
    required this.values,
    required this.categoryColors,
    this.levels = 5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size =
            constraints.biggest.shortestSide == double.infinity
                ? 300
                : constraints.biggest.shortestSide;
        return CustomPaint(
          painter: _RadarChartPainter(
            categories: categories,
            values: values,
            categoryColors: categoryColors,
            levels: levels,
            labelStyle:
                Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.black87) ??
                const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          size: Size.square(size),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<String> categories;
  final List<double> values; // 0..1 length == categories
  final List<Color> categoryColors;
  final int levels;
  final TextStyle labelStyle;

  _RadarChartPainter({
    required this.categories,
    required this.values,
    required this.categoryColors,
    required this.levels,
    required this.labelStyle,
  }) : assert(categories.length == values.length),
       assert(categories.length == categoryColors.length);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide / 2) - 24; // padding for labels
    final int count = categories.length;
    final double angleStep = (2 * 3.141592653589793) / count;

    final Paint gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw concentric polygons (levels)
    for (int level = 1; level <= levels; level++) {
      final double r = radius * (level / levels);
      final Path ring = Path();
      for (int i = 0; i < count; i++) {
        final double angle = -3.141592653589793 / 2 + i * angleStep;
        final Offset p =
            center + Offset(r * math.cos(angle), r * math.sin(angle));
        if (i == 0) {
          ring.moveTo(p.dx, p.dy);
        } else {
          ring.lineTo(p.dx, p.dy);
        }
      }
      ring.close();
      canvas.drawPath(ring, gridPaint);
    }

    // Draw axes and labels
    final Paint axisPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final double angle = -3.141592653589793 / 2 + i * angleStep;
      final Offset tip =
          center + Offset(radius * math.cos(angle), radius * math.sin(angle));
      canvas.drawLine(center, tip, axisPaint);

      // Label
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: categories[i],
          style: labelStyle.copyWith(color: categoryColors[i]),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final double labelPadding = 8;
      Offset labelOffset = tip;
      // Adjust label position outward a bit
      labelOffset =
          center +
          Offset(
            (radius + labelPadding) * math.cos(angle),
            (radius + labelPadding) * math.sin(angle),
          );
      labelOffset = labelOffset - Offset(tp.width / 2, tp.height / 2);
      tp.paint(canvas, labelOffset);
    }

    // Data polygon
    final Path dataPath = Path();
    final List<Offset> dataPoints = <Offset>[];
    for (int i = 0; i < count; i++) {
      final double angle = -3.141592653589793 / 2 + i * angleStep;
      final double r = radius * values[i].clamp(0.0, 1.0);
      final Offset p =
          center + Offset(r * math.cos(angle), r * math.sin(angle));
      dataPoints.add(p);
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    final Paint fillPaint =
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.15)
          ..style = PaintingStyle.fill;
    final Paint strokePaint =
        Paint()
          ..color = const Color(0xFF6C63FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Colored vertices per category
    for (int i = 0; i < count; i++) {
      final Paint dotPaint = Paint()..color = categoryColors[i];
      canvas.drawCircle(dataPoints[i], 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.categories != categories ||
        oldDelegate.levels != levels;
  }
}

// Minimal math helpers
// removed placeholder Math class; using dart:math instead

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFECF4F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.white,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                    ),
                  ),
                  Center(
                    child: Text(
                      'Settings',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SettingsSection(
                      title: 'Account',
                      children: [
                        _SettingsItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.email_outlined,
                          title: 'Email Settings',
                          subtitle: 'Manage email notifications',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Preferences',
                      children: [
                        _SettingsItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Security',
                      children: [
                        _SettingsItem(
                          icon: Icons.security_outlined,
                          title: 'Privacy Settings',
                          subtitle: 'Control your privacy and data',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.logout_outlined,
                          title: 'Sign Out',
                          subtitle: 'Sign out of your account',
                          onTap: () {
                            _showSignOutDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Support',
                      children: [
                        _SettingsItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'Get help and support',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.feedback_outlined,
                          title: 'Send Feedback',
                          subtitle: 'Share your thoughts with us',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and information',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Add sign out logic here
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
