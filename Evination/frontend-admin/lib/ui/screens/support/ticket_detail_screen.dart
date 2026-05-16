import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket #T-12345', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Payment Issue • Rajesh Kumar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.print)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert)),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.red.withOpacity(0.05),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.info, color: Colors.red, size: 16), SizedBox(width: 8), Text('Status: OPEN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
                Text('SLA: Within Target ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Chat View
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildMessageBubble('Rajesh Kumar (Customer)', '5-Feb 10:30 AM', 'Hi Support Team,\n\nI completed my wedding event (#BK-9877) on 3rd Feb, but haven\'t received the payout of ₹6.5L yet. Can you check?', false),
                _buildSystemEvent('Ticket auto-assigned to Karthik Rao (Support Mgr)'),
                _buildInternalNote('Karthik Rao (Admin)', 'Checked booking. Event completed 3-Feb. Payout scheduled for 6-Feb (Event + 3 days). No issues found.'),
                _buildMessageBubble('Karthik Rao (Support Mgr)', '5-Feb 2:15 PM', 'Hi Rajesh,\n\nI\'ve checked everything. The payout is scheduled for 6th Feb as per our 3-day policy. You should receive it tomorrow.\n\nBest,\nKarthik', true),
              ],
            ),
          ),

          // Action Bar
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,-2))]),
             child: Column(
               children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your response...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      suffixIcon: const Icon(Icons.send),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(onPressed: (){}, icon: const Icon(Icons.attach_file)),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.image)),
                          const SizedBox(width: 8),
                          ActionChip(label: const Text('Internal Note'), backgroundColor: Colors.amber[50], onPressed: (){}),
                        ],
                      ),
                      ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white), child: const Text('Resolve Ticket')),
                    ],
                  ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String sender, String time, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary50 : Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ]),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemEvent(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ),
    );
  }

  Widget _buildInternalNote(String sender, String text) {
     return Container(
       margin: const EdgeInsets.symmetric(vertical: 8),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.amber[50],
         border: Border.all(color: Colors.amber[200]!),
         borderRadius: BorderRadius.circular(8),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(children: [const Icon(Icons.lock, size: 12, color: Colors.amber), const SizedBox(width: 4), Text('$sender (Internal Note)', style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 12))]),
           const SizedBox(height: 8),
           Text(text, style: TextStyle(color: Colors.brown[700], fontStyle: FontStyle.italic)),
         ],
       ),
     );
  }
}
