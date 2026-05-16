import 'package:flutter/material.dart';

/// A reusable wrapper that adds infinite scrolling (pagination) capability
/// to a standard layout list. Automatically triggers an async [onLoadMore]
/// when the user scrolls near the bottom.
class InfiniteScrollView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry padding;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final double cacheExtent;

  const InfiniteScrollView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    this.loadingWidget,
    this.emptyWidget,
    this.padding = EdgeInsets.zero,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.cacheExtent = 300,
  });

  @override
  State<InfiniteScrollView<T>> createState() => _InfiniteScrollViewState<T>();
}

class _InfiniteScrollViewState<T> extends State<InfiniteScrollView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_isLoading || !widget.hasMore) return;
    
    // Trigger when scrolled to 80% of max extent
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (mounted) setState(() => _isLoading = true);
      try {
        await widget.onLoadMore();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.hasMore) {
      return widget.emptyWidget ?? const Center(child: Text('No items found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: widget.loadingWidget ?? const Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
