import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_support.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AuraColors.background,
      child: Row(
        children: [
          // Sidebar: Chat List
          Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AuraColors.glassBorder)),
              color: AuraColors.surface.withOpacity(0.5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search chats...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AuraColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: mockChatSessions.length,
                    separatorBuilder: (c, i) => Divider(color: AuraColors.glassBorder, height: 1),
                    itemBuilder: (context, index) {
                      final chat = mockChatSessions[index];
                      // Highlight first one as active demo
                      bool isActive = index == 0;
                      
                      return ListTile(
                        tileColor: isActive ? AuraColors.primary.withOpacity(0.1) : null,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Text(chat.orgName[0], style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(chat.user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(chat.time, style: const TextStyle(color: Colors.white30, fontSize: 10)),
                            if(chat.unread > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AuraColors.primary, shape: BoxShape.circle),
                                child: Text(chat.unread.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                          ],
                        ),
                        onTap: (){},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Area: Chat Window
          Expanded(
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AuraColors.glassBorder))),
                  child: Row(
                    children: [
                       const CircleAvatar(child: Text("DR")),
                       const SizedBox(width: 12),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Dr. Rajesh (Apollo Hospitals)", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                           const Row(
                             children: [
                               CircleAvatar(radius: 4, backgroundColor: Colors.green),
                               SizedBox(width: 4),
                               Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
                             ],
                           ),
                         ],
                       ),
                       const Spacer(),
                       IconButton(icon: const Icon(Icons.more_horiz), onPressed: (){}),
                    ],
                  ),
                ),
                
                // Messages
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildMessageBubble("Hello, I am facing an issue with the live map.", false),
                      _buildMessageBubble("Hi Dr. Rajesh! I can help with that. What seems to be the problem?", true),
                      _buildMessageBubble("It's not updating the driver locations in real-time.", false),
                      _buildMessageBubble("I see. Let me check the WebSocket connection for your tenant instance.", true),
                      const SizedBox(height: 8),
                      // Typing indicator simulation
                      const Row(children: [Text("Dr. Rajesh is typing...", style: TextStyle(color: Colors.white30, fontSize: 10))]),
                    ],
                  ),
                ),
                
                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: AuraColors.glassBorder))),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.attach_file, color: Colors.white54), onPressed: (){}),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Type a reply...",
                            filled: true,
                            fillColor: AuraColors.surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(backgroundColor: AuraColors.primary, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: (){})),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isMe ? AuraColors.primary : AuraColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          border: isMe ? null : Border.all(color: AuraColors.glassBorder),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
