import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CommonAccordion extends StatelessWidget {
  final List<CommonAccordionItem> items;
  final bool multiple;

  const CommonAccordion({super.key, required this.items, this.multiple = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _AccordionTile(item: item)).toList(),
    );
  }
}

class CommonAccordionItem {
  final String title;
  final Widget content;
  final bool initiallyExpanded;

  CommonAccordionItem({required this.title, required this.content, this.initiallyExpanded = false});
}

class _AccordionTile extends StatelessWidget {
  final CommonAccordionItem item;

  const _AccordionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))), // Border-b
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          initiallyExpanded: item.initiallyExpanded,
          childrenPadding: const EdgeInsets.only(bottom: 16),
          textColor: Colors.black,
          iconColor: Colors.grey,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(
                 style: const TextStyle(fontSize: 14, color: Colors.black87),
                 child: item.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
