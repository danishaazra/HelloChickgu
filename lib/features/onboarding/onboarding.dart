import 'package:flutter/material.dart';
import '../profile/profile.dart';

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
    if (_currentPage < _onboardingImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to profile page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
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
    // Navigate to profile page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            itemCount: _onboardingImages.length,
            itemBuilder: (context, index) {
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
            },
          ),
          
          // Back button (top left - round outline)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 20,
            child: GestureDetector(
              onTap: _previousPage,
              child: Container(
                width: 50,
                height: 50,
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
          
          // Skip button (top right)
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
          
          // Bottom navigation area
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
                  
                  // Next/Start button (for all screens)
                  if (_nextButtonImages[_currentPage].isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: 160,
                            height: 60,
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
                                width: 100,
                                height: 38,
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