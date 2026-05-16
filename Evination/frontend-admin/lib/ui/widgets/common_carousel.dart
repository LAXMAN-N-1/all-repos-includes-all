import 'package:flutter/material.dart';

class CommonCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool autoPlay;

  const CommonCarousel({
    super.key,
    required this.items,
    this.height = 200,
    this.autoPlay = false,
  });

  @override
  State<CommonCarousel> createState() => _CommonCarouselState();
}

class _CommonCarouselState extends State<CommonCarousel> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.items.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: widget.items,
          ),
          if (_currentIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: _prev,
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.7)),
                ),
              ),
            ),
          if (_currentIndex < widget.items.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: _next,
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.7)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
