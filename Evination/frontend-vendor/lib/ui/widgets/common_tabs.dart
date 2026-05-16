import 'package:flutter/material.dart';

class CommonTabs extends StatefulWidget {
  final List<CommonTabItem> tabs;
  final ValueChanged<int>? onTabChanged;
  final int initialIndex;

  const CommonTabs({
    super.key,
    required this.tabs,
    this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  State<CommonTabs> createState() => _CommonTabsState();
}

class _CommonTabsState extends State<CommonTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            tabs: widget.tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // We aren't using TabBarView strictly here to allow flexible layouts, 
        // but if content is provided in items, we could. 
        // For now, let's assume the user handles content switching or we just render active content.
        // But to be robust, let's use TabBarView if content is available.
        if (widget.tabs.every((t) => t.content != null))
          SizedBox(
            height: 400, // constrained height or use Expanded parent
            child: TabBarView(
              controller: _tabController,
              children: widget.tabs.map((t) => t.content ?? const SizedBox()).toList(),
            ),
          ),
      ],
    );
  }
}

class CommonTabItem {
  final String label;
  final Widget? content;

  CommonTabItem({required this.label, this.content});
}
