import 'package:flutter/material.dart';
// Auth forms will be embedded as pages inside onboarding
import 'package:hellochickgu/shared/utils/responsive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _helloAnimationController;
  late AnimationController _chickguAnimationController;
  late Animation<double> _helloScaleAnimation;
  late Animation<double> _chickguFadeAnimation;

  final List<String> _onboardingImages = [
    'assets/onboardingp1.png',
    'assets/onboardingp2.png',
    'assets/onboardingp3.png',
    'assets/onboardingp4.png',
  ];

  final List<String> _nextButtonImages = [
    'assets/next1.png',
    'assets/next2.png',
    'assets/next3.png',
    'assets/start.png', // Start button for the last screen
  ];

  @override
  void initState() {
    super.initState();
    _helloAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chickguAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _helloScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _helloAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _chickguFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chickguAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _helloAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _chickguAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _helloAnimationController.dispose();
    _chickguAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 3) {
      _pageController.animateToPage(4,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _pageController.animateToPage(4,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    // Using responsive helpers here in case future layout tweaks need them
    // ignore: unused_local_variable
    final isSmallScreen = Responsive.isSmallScreen(context);
    // ignore: unused_local_variable
    final isVerySmallScreen = Responsive.isVerySmallScreen(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen image background
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              
              // Restart animations when reaching the last screen
              if (index == 3) {
                _helloAnimationController.reset();
                _chickguAnimationController.reset();
                _helloAnimationController.forward();
                Future.delayed(const Duration(milliseconds: 350), () {
                  _chickguAnimationController.forward();
                });
              }
            },
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index < 4) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_onboardingImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              } else if (index == 4) {
                return _buildLoginPage(context, _pageController);
              } else {
                return _buildSignUpPage(context, _pageController);
              }
            },
          ),
          
          // Back button (top left - round outline)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: Responsive.scaleWidth(context, 20),
            child: GestureDetector(
              onTap: _previousPage,
              child: Container(
                width: Responsive.scaleWidth(context, 50),
                height: Responsive.scaleHeight(context, 50),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          
           if (_currentPage == 3)
             Positioned(
               top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Hello image with popup animation
                  AnimatedBuilder(
                    animation: _helloScaleAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: const Offset(0, 52),
                        child: Transform.scale(
                          scale: _helloScaleAnimation.value,
                          child: Image.asset(
                            'assets/hello.png',
                            width: 200,
                            height: 150,
                          ),
                        ),
                      );
                    },
                   ),
                   
                   
                   
                   // Chickgu image with fade animation
                  AnimatedBuilder(
                    animation: _chickguFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _chickguFadeAnimation.value,
                        child: Transform.translate(
                          offset: const Offset(0, -12),
                          child: Image.asset(
                            'assets/chickgu.png',
                            width: 250,
                            height: 150,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          
          // Skip button (top right) only for first 4 pages
          if (_currentPage < 4)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          // Bottom navigation area only for first 4 pages
          if (_currentPage < 4)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: Responsive.scaleWidth(context, 160),
                            height: Responsive.scaleHeight(context, 60),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: const Alignment(0, -0.3),
                              child: Image.asset(
                                _nextButtonImages[_currentPage],
                                width: Responsive.scaleWidth(context, 100),
                                height: Responsive.scaleHeight(context, 38),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Embedded auth pages
Widget _buildLoginPage(BuildContext context, PageController pageController) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter your email';
                      if (!value.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter your password';
                      if (value.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() => isSubmitting = true);
                              await Future.delayed(const Duration(milliseconds: 800));
                              setState(() => isSubmitting = false);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: const Color(0xFF4FC3F7),
                        foregroundColor: Colors.white,
                      ),
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign In', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        pageController.animateToPage(
                          5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: const BorderSide(color: Colors.transparent),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFF4B942),
                      ),
                      child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSignUpPage(BuildContext context, PageController pageController) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          // Very top-left back button with white circular outline
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () {
                pageController.animateToPage(
                  4,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your email';
                            if (!value.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4FC3F7), width: 2),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your password';
                            if (value.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setState(() => isSubmitting = true);
                                  await Future.delayed(const Duration(milliseconds: 800));
                                  setState(() => isSubmitting = false);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF4FC3F7),
                            foregroundColor: Colors.white,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Create Account', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}