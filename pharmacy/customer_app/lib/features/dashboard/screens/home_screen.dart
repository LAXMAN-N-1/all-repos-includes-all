import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:customer_app/core/services/ai_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _openVoiceAssistant() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AIVoiceSheet()
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(builder: (context) {
              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"), // Mock User
                ),
              );
            })
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), 
            onPressed: () {}
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const ProfileDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
             // Search Bar
             Container(
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(12)
               ),
               child: TextField(
                 controller: _searchController,
                 decoration: InputDecoration(
                   prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                   hintText: "Search medicines, doctors...",
                   hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                   border: InputBorder.none,
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                 ),
               ),
             ),
             
             const SizedBox(height: 16),
             
             // Tabs
             TabBar(
               controller: _tabController,
               labelColor: const Color(0xFF6200EE),
               unselectedLabelColor: Colors.grey,
               labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
               indicatorColor: const Color(0xFF6200EE),
               tabs: const [
                 Tab(text: "Medicines"),
                 Tab(text: "Consult Doctor"),
               ],
             ),
             
             const SizedBox(height: 24),
             
             // AI Mic Area
             Expanded(
               child: Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Text("Ask AI for help with your health"),
                     const SizedBox(height: 16),
                     GestureDetector(
                       onTap: _openVoiceAssistant,
                       child: Container(
                         width: 80,
                         height: 80,
                         decoration: BoxDecoration(
                           color: const Color(0xFF6200EE),
                           shape: BoxShape.circle,
                           boxShadow: [
                             BoxShadow(color: const Color(0xFF6200EE).withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
                           ]
                         ),
                         child: const Icon(Icons.mic, color: Colors.white, size: 32),
                       ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scaleXY(begin: 1.0, end: 1.1, duration: 1.seconds),
                     ),
                     const SizedBox(height: 12),
                     Text("Tap to Speak", style: GoogleFonts.inter(color: Colors.grey[600]))
                   ],
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }
}

// Profile Drawer
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF6200EE)),
            accountName: Text("Murari"),
            accountEmail: Text("+91 9876543210"),
            currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Orders'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.medical_services_outlined),
            title: const Text('Prescriptions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.video_camera_front_outlined),
            title: const Text('My Consultations'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Wallet'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Need Help'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Manage Address'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Saved for Later'),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Legal'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// AI Voice Sheet (Overlay)
class AIVoiceSheet extends StatefulWidget {
  const AIVoiceSheet({super.key});

  @override
  State<AIVoiceSheet> createState() => _AIVoiceSheetState();
}

class _AIVoiceSheetState extends State<AIVoiceSheet> {
  String _liveText = "Listening...";
  
  @override
  void initState() {
    super.initState();
    // Start listening on mount
    final ai = Provider.of<AIService>(context, listen: false);
    ai.startListening((text) {
        if(mounted) setState(() => _liveText = text);
    });
  }
  
  void _changeLanguage(String? lang) {
      if (lang != null) {
          Provider.of<AIService>(context, listen: false).setLanguage(lang);
          // Restart listening with new language
          Provider.of<AIService>(context, listen: false).stopListening().then((_) {
               Provider.of<AIService>(context, listen: false).startListening((text) {
                    if(mounted) setState(() => _liveText = text);
               });
          });
      }
  }

  void _sendMessage() async {
      final ai = Provider.of<AIService>(context, listen: false);
      await ai.stopListeningAndSend(_liveText);
      if(mounted) Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final ai = Provider.of<AIService>(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text("AI Health Assistant", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                        value: ai.currentLanguage,
                        items: const [
                            DropdownMenuItem(value: 'en', child: Text("English")),
                            DropdownMenuItem(value: 'te', child: Text("Telugu (తెలుగు)")),
                            DropdownMenuItem(value: 'hi', child: Text("Hindi (हिंदी)")),
                            DropdownMenuItem(value: 'ta', child: Text("Tamil (தமிழ்)")),
                            DropdownMenuItem(value: 'kn', child: Text("Kannada (कन्नड़)")),
                        ],
                        onChanged: _changeLanguage,
                    )
                ],
            ),
            const Spacer(),
            // Waveform Animation (Active State)
            if (ai.isListening)
                SizedBox(
                    height: 60,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => 
                            Container(
                                width: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(color: const Color(0xFF6200EE), borderRadius: BorderRadius.circular(4)),
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                             .scaleY(begin: 0.5, end: 1.5, duration: Duration(milliseconds: 300 + (index * 100)))
                        ),
                    ),
                )
            else if (ai.isLoading)
                 const CircularProgressIndicator()
            else
                 GestureDetector(
                     onTap: () {
                         // Manual Trigger if needed
                         ai.startListening((text) => setState(() => _liveText = text));
                     },
                     child: const Icon(Icons.mic, size: 60, color: Colors.grey),
                 ),

            const SizedBox(height: 20),
            
            // Live Transcript
            Text(
                ai.isListening ? _liveText : (ai.isLoading ? "Thinking..." : "Tap Mic to Speak"), 
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w500), 
                textAlign: TextAlign.center
            ),
            
            const Spacer(),
            
            // Close Button Only
            FloatingActionButton(
                backgroundColor: Colors.redAccent,
                onPressed: () {
                    ai.stopListening();
                    Navigator.pop(context);
                },
                child: const Icon(Icons.close, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
