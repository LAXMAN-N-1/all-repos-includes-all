import 'package:flutter/material.dart';

class CommonSidebar extends StatefulWidget {
  final Widget child;
  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CommonSidebar({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CommonSidebar> createState() => _CommonSidebarState();
}

class _CommonSidebarState extends State<CommonSidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isCollapsed ? 60 : 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 60,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                  icon: Icon(_isCollapsed ? Icons.menu : Icons.menu_open),
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = widget.selectedIndex == index;
                    return InkWell(
                      onTap: () => widget.onItemSelected(index),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: isSelected ? Colors.grey[100] : null,
                        child: Row(
                          children: [
                            Icon(item.icon, color: isSelected ? Colors.black : Colors.grey),
                            if (!_isCollapsed) ...[
                              const SizedBox(width: 12),
                              Text(item.label, style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? Colors.black : Colors.grey[700],
                              )),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: widget.child),
      ],
    );
  }
}

class SidebarItem {
  final String label;
  final IconData icon;

  SidebarItem({required this.label, required this.icon});
}
