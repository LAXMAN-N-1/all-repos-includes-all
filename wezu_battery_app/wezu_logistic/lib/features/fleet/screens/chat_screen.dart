import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../config/app_text_styles.dart';
import '../providers/logistics_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String driverId;

  const ChatScreen({super.key, required this.driverId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [
    'Hey, are you near the warehouse?',
    'Yes, I will be there in 5 minutes.',
    'Traffic is a bit heavy on Main St.',
    'No worries, drive safely.',
  ];

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(fleetListProvider);
    final driver = driversAsync.value?.where((d) => d.id == widget.driverId).firstOrNull;

    return AppScaffold(
      appBar: AppBar(
        title: Text(driver?.name ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isMe = index % 2 == 0; // Mock: alternating messages
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                      ),
                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Text(
                      _messages[index],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _messages.add(_controller.text);
                  _controller.clear();
                });
              }
            },
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
