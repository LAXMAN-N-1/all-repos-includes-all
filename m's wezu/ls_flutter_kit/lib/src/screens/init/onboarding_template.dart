import 'package:flutter/material.dart';

class OnboardingPageData {
  final Widget image;
  final String title;
  final String description;

  const OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Reusable Onboarding Page View extracted from Meat2Restaurant app.
/// Features a swipeable page view, animated dot indicator, and completion action.
class OnboardingTemplate extends StatefulWidget {
  final List<OnboardingPageData> pages;
  final VoidCallback onCompleted;
  final String skipLabel;
  final String nextLabel;
  final String startLabel;
  final bool showSkip;

  const OnboardingTemplate({
    super.key,
    required this.pages,
    required this.onCompleted,
    this.skipLabel = 'Skip',
    this.nextLabel = 'Next',
    this.startLabel = 'Get Started',
    this.showSkip = true,
  });

  @override
  State<OnboardingTemplate> createState() => _OnboardingTemplateState();
}

class _OnboardingTemplateState extends State<OnboardingTemplate> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isLastPage = _currentPage == widget.pages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.showSkip && !isLastPage)
            TextButton(
              onPressed: widget.onCompleted,
              child: Text(widget.skipLabel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: widget.pages.length,
                itemBuilder: (context, index) {
                  final page = widget.pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Center(child: page.image)),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      widget.pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text(isLastPage ? widget.startLabel : widget.nextLabel),
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
