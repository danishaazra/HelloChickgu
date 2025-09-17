import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                          'https://media.istockphoto.com/id/1400918939/vector/summer-sunny-clear-sky-orange-and-blue-abstract-defocused-color-gradient-background-vector.jpg?s=612x612&w=0&k=20&c=H7zCHx8fPia02XttG3pkAVhLRm1VQSWEUi7Tl2agHms=',
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
                        child: SizedBox(
                          height: 56,
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
                        itemBuilder: (context, index) => _ProfileItem(
                          icon: icons[index],
                          title: titles[index],
                          onTap: () {
                            if (index == 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PersonalInformationPage(),
                                ),
                              );
                            }
                          },
                        ),
                        separatorBuilder: (context, index) => const Divider(height: 1),
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

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

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
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Nurin Sunoo');
  final TextEditingController _emailController = TextEditingController(text: 'nurin@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+60 12-345 6789');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
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
                          'https://media.istockphoto.com/id/1400918939/vector/summer-sunny-clear-sky-orange-and-blue-abstract-defocused-color-gradient-background-vector.jpg?s=612x612&w=0&k=20&c=H7zCHx8fPia02XttG3pkAVhLRm1VQSWEUi7Tl2agHms=',
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
                          color: Colors.white.withOpacity(0.9),
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
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InfoField(
                          label: 'Name',
                          controller: _nameController,
                          isEditing: _isEditing,
                        ),
                        const SizedBox(height: 20),
                        _InfoField(
                          label: 'Email',
                          controller: _emailController,
                          isEditing: _isEditing,
                        ),
                        const SizedBox(height: 20),
                        _InfoField(
                          label: 'Phone',
                          controller: _phoneController,
                          isEditing: _isEditing,
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isEditing ? () {
                              setState(() {
                                _isEditing = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Information saved!')),
                              );
                            } : null,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            Positioned(
              top: 200 - 48,
              left: 24,
              child: Stack(
                children: [
                  Container(
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height:30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 12),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        color: Colors.white,
                        onPressed: () {},
                        tooltip: 'Edit Photo',
                      ),
                    ),
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

class _InfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  const _InfoField({
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isEditing 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isEditing 
                ? Theme.of(context).colorScheme.surface 
                : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}


