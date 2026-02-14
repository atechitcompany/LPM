import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/intro_page_model.dart';
import '../widgets/intro_page_view.dart';
import '../widgets/page_indicator.dart';
import '../widgets/next_button.dart';
import '../widgets/skip_button.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<IntroPageModel> pages = const [
    IntroPageModel(
      title: "CRM App to Manage Business",
      subtitle:
      "We Provide Classes Online Classes and Pre Recorded Lectures!",
      imageAsset: "assets/intro/intro1.png",
    ),
    IntroPageModel(
      title: "Monitor All Departments",
      subtitle: "Booked or Save the Lectures for Future",
      imageAsset: "assets/intro/intro2.png",
    ),
    IntroPageModel(
      title: "Manage All Clients",
      subtitle: "Analyse your scores and Track your results",
      imageAsset: "assets/intro/intro3.png",
    ),
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      /// 👉 Later this will go to Auth flow
      context.go('/login'); // temporary
    }
  }

  void _skip() {
    _controller.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// Pages
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return IntroPageView(page: pages[index]);
              },
            ),

            /// Skip Button (Top Right)
            Positioned(
              top: 12,
              right: 20,
              child: SkipButton(onTap: _skip),
            ),

            /// Bottom Controls
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageIndicator(
                    count: pages.length,
                    currentIndex: _currentPage,
                  ),
                  NextButton(
                    isLast: isLast,
                    onTap: _nextPage,
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
