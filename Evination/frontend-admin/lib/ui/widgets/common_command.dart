import 'package:flutter/material.dart';

class CommonCommand extends StatefulWidget {
  final List<CommandItem> items;
  final Function(CommandItem) onItemSelected;

  const CommonCommand({super.key, required this.items, required this.onItemSelected});

  static Future<void> show(BuildContext context, List<CommandItem> items, Function(CommandItem) onItemSelected) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.only(top: 100, left: 16, right: 16),
        child: CommonCommand(items: items, onItemSelected: onItemSelected),
      ),
    );
  }

  @override
  State<CommonCommand> createState() => _CommonCommandState();
}

class _CommonCommandState extends State<CommonCommand> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) => item.label.toLowerCase().contains(_query.toLowerCase())).toList();

    return Container(
      width: 600,
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration.collapsed(hintText: 'Type a command or search...'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (filtered.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No results found.', style: TextStyle(color: Colors.grey)))
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    leading: item.icon != null ? Icon(item.icon, size: 18) : null,
                    title: Text(item.label, style: const TextStyle(fontSize: 14)),
                    trailing: item.shortcut != null ? Text(item.shortcut!, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
                    onTap: () {
                      widget.onItemSelected(item);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class CommandItem {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final String value;

  CommandItem({required this.label, required this.value, this.icon, this.shortcut});
}
