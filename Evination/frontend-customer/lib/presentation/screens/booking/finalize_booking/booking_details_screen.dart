import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:evination_customer_app/logic/providers/booking_provider.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'dart:ui'; // For BackdropFilter

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const BookingDetailsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  
  final List<String> _selectedServices = [];
  
  // UPDATED: Fresh High-Reliability Images
  final List<Map<String, dynamic>> _serviceOptions = [
    {
      'icon': LucideIcons.utensils, 
      'name': 'Food & Catering', 
      'desc': 'Gourmet dining experiences',
      'image': 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=2070&auto=format&fit=crop'
    },
    {
      'icon': LucideIcons.palette, 
      'name': 'Decoration & Styling', 
      'desc': 'Elegant floral & stage decor',
      'image': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2000&auto=format&fit=crop' // Verified
    },
    {
      'icon': LucideIcons.camera, 
      'name': 'Photography & Video', 
      'desc': 'Capture every moment',
      'image': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=2000&auto=format&fit=crop' // Verified
    },
    {
      'icon': LucideIcons.home, 
      'name': 'Venue Booking', 
      'desc': 'Perfect locations',
      'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop'
    },
    {
      'icon': LucideIcons.music, 
      'name': 'Music & DJ', 
      'desc': 'Live bands & DJs',
      // NEW URL
      // Updated URL
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=2070&auto=format&fit=crop'
    },
    {
      'icon': LucideIcons.car, 
      'name': 'Guest Transport', 
      'desc': 'Luxury fleet services',
      'image': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=2070&auto=format&fit=crop'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Luxury Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bordeauxGradient,
              ),
            ),
          ),
          
          // Glow effect
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.crimsonSilk.withValues(alpha: 0.1), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 10.seconds, begin: const Offset(1,1), end: const Offset(1.2,1.2)),
          ),

          // 2. Main Content
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'Curate Your Occasion',
                        style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuart),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'Define the essence of your ${widget.categoryId}. Our verified artisans will present bespoke proposals for your review.',
                        style: GoogleFonts.outfit(color: Colors.white54, fontSize: 15, height: 1.6),
                      ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                      
                      const SizedBox(height: 48),
                      
                      _buildSectionTitle('Event Particulars')
                        .animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),
                      
                      _buildGlassFormCard()
                        .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 56),
                      
                      _buildSectionTitle('Required Artisans')
                        .animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),
                      
                      _buildServicesGrid(),
                      
                      const SizedBox(height: 80),
                      _buildSubmitButton()
                        .animate().fadeIn(delay: 800.ms).scale(curve: Curves.elasticOut, duration: 800.ms),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3, 
          height: 32, 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.luxuryGradient,
            boxShadow: [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.4), blurRadius: 12)]
          ),
        ),
        const SizedBox(width: 20),
        Text(title, style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    String imageUrl;
    final cat = widget.categoryId.toLowerCase();
    
    if (cat.contains('wedding')) {
      imageUrl = 'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=2000&auto=format&fit=crop';
    } else if (cat.contains('funeral') || cat.contains('memorial')) {
      imageUrl = 'https://images.unsplash.com/photo-1596728337778-9cc35cde3693?q=80&w=2070&auto=format&fit=crop';
    } else if (cat.contains('birthday')) {
      imageUrl = 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2000&auto=format&fit=crop';
    } else if (cat.contains('corporate') || cat.contains('work')) {
       imageUrl = 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=2070&auto=format&fit=crop';
    } else {
      imageUrl = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2070&auto=format&fit=crop';
    }

    return SliverAppBar(
      expandedHeight: 400.0, 
      floating: false,
      pinned: true,
      backgroundColor: AppColors.deepBordeaux,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3), 
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        title: Text(
          widget.categoryId.toUpperCase(), 
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.softBlush, 
            fontWeight: FontWeight.bold, 
            fontSize: 32, 
            letterSpacing: 2.0,
            shadows: [Shadow(color: Colors.black, blurRadius: 20)]
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl, 
              fit: BoxFit.cover,
              loadingBuilder: (c, child, progress) => progress == null ? child : Container(color: AppColors.deepBordeaux),
              errorBuilder: (c,e,s) => Container(color: AppColors.deepBordeaux),
            ),
            // Luxury Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2), 
                    Colors.transparent,
                    AppColors.deepBordeaux.withValues(alpha: 0.8), 
                    AppColors.primaryBlack,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03), 
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)), 
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildDatePicker()),
              const SizedBox(width: 20),
              Expanded(child: _buildTimePicker()),
            ],
          ),
          const SizedBox(height: 32),
          _buildTextField('Event Location', _locationController, LucideIcons.mapPin, 'Exquisite Venue or Address'),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildTextField('Guest Count', _guestsController, LucideIcons.users, 'Expected', isNumber: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Aesthetic Theme', _themeController, LucideIcons.palette, 'Optional styling cues')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9, 
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _serviceOptions.length,
      itemBuilder: (context, index) {
        final service = _serviceOptions[index];
        final isSelected = _selectedServices.contains(service['name']);
        
        return GestureDetector(
          onTap: () {
             setState(() {
              if (isSelected) {
                _selectedServices.remove(service['name']);
              } else {
                _selectedServices.add(service['name']);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? AppColors.crimsonSilk : Colors.white.withValues(alpha: 0.05),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))] : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    service['image'] as String,
                    fit: BoxFit.cover,
                  ),
                  
                  // Luxury Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4), 
                          AppColors.primaryBlack.withValues(alpha: 0.9),
                        ],
                        stops: const [0.2, 0.6, 1.0],
                      ),
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    color: isSelected ? AppColors.crimsonSilk.withValues(alpha: 0.1) : Colors.transparent,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.luxuryGradient : null,
                            color: isSelected ? null : Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Icon(
                            service['icon'] as IconData, 
                            size: 18, 
                            color: Colors.white
                          ),
                        ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1)),
                        
                        const SizedBox(height: 12),
                        Text(
                          service['name'] as String,
                          style: GoogleFonts.cormorantGaramond(
                            color: AppColors.softBlush,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['desc'] as String,
                          style: GoogleFonts.outfit(
                            color: Colors.white38,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSelected)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                         padding: const EdgeInsets.all(6),
                         decoration: BoxDecoration(
                           gradient: AppColors.luxuryGradient, 
                           shape: BoxShape.circle,
                           boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
                         ),
                         child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
                      ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                    )
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 600 + (100 * index))).slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
      },
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE', style: GoogleFonts.outfit(color: AppColors.softBlush.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.crimsonSilk,
                      onPrimary: Colors.white,
                      surface: AppColors.deepBordeaux,
                      onSurface: AppColors.softBlush,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), 
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.calendar, color: AppColors.crimsonSilk, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedDate == null ? 'Select Date' : DateFormat('dd MMM yyyy').format(_selectedDate!).toUpperCase(),
                    style: GoogleFonts.outfit(color: _selectedDate == null ? Colors.white24 : AppColors.softBlush, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TIME', style: GoogleFonts.outfit(color: AppColors.softBlush.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 18, minute: 0),
              builder: (context, child) {
                 return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.crimsonSilk,
                      onPrimary: Colors.white,
                      surface: AppColors.deepBordeaux,
                      onSurface: AppColors.softBlush,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedTime = picked);
            }
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, color: AppColors.crimsonSilk, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedTime == null ? 'Select Time' : _selectedTime!.format(context).toUpperCase(),
                    style: GoogleFonts.outfit(color: _selectedTime == null ? Colors.white24 : AppColors.softBlush, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: AppColors.softBlush.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
            cursorColor: AppColors.crimsonSilk,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.white12, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.softBlush.withValues(alpha: 0.3), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.crimsonSilk, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        gradient: AppColors.luxuryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.crimsonSilk.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text('Generate Bespoke Proposals', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
      ),
    );
  }

  void _submitBooking() async {
     if (_selectedDate == null || _locationController.text.isEmpty || _guestsController.text.isEmpty || _selectedServices.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Please define essential event particulars', style: GoogleFonts.outfit()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
         )
       );
       return;
     }

     // Show loading dialog
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => Center(
         child: Container(
           padding: const EdgeInsets.all(32),
           decoration: BoxDecoration(
             color: AppColors.deepBordeaux,
             borderRadius: BorderRadius.circular(24),
             border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.2)),
           ),
           child: const CircularProgressIndicator(color: AppColors.crimsonSilk),
         ),
       ),
     );

     try {
       final eventDateTime = DateTime(
         _selectedDate!.year,
         _selectedDate!.month,
         _selectedDate!.day,
         _selectedTime?.hour ?? 18,
         _selectedTime?.minute ?? 0,
       );

       final bookingController = ref.read(bookingControllerProvider.notifier);
       await bookingController.createBooking(
         eventName: widget.categoryId,
         eventType: widget.categoryId,
         eventDate: eventDateTime,
         location: _locationController.text,
         budget: 100000.0, 
         services: _selectedServices,
         requirements: _themeController.text.isEmpty ? 'Luxury event standards' : _themeController.text,
       );

       // Close loading dialog
       if (mounted) Navigator.pop(context);

       // Show success dialog
       if (mounted) {
         showGeneralDialog(
           context: context,
           barrierDismissible: false, // Force user to use the button
           barrierLabel: 'Excellence',
           transitionDuration: const Duration(milliseconds: 600),
           pageBuilder: (context, a1, a2) => const SizedBox(),
           transitionBuilder: (context, a1, a2, child) {
             return ScaleTransition(
               scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
               child: FadeTransition(
                 opacity: a1,
                 child: Center(
                   child: Material(
                     color: Colors.transparent,
                     child: Container(
                        width: 380,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: AppColors.bordeauxGradient,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 50)]
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: AppColors.luxuryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.4), blurRadius: 30)]
                              ),
                              child: const Icon(LucideIcons.check, size: 48, color: Colors.white),
                            ).animate().scale(curve: Curves.elasticOut, delay: 300.ms),
                            const SizedBox(height: 40),
                            Text(
                              'SENT FOR BIDDING', 
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.softBlush, letterSpacing: 1.5)
                            ).animate().fadeIn(delay: 400.ms),
                            const SizedBox(height: 20),
                            Text(
                              'Your request has been posted. Verified vendors will now place their bids. You can review them in "My Bookings".',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16, height: 1.6),
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.softBlush.withValues(alpha: 0.2)),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.pop(); // Close dialog
                                    // Navigate to My Bookings
                                    ref.invalidate(myBookingsProvider); // Refresh bookings
                                    context.go(AppRouter.bookings);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                                    foregroundColor: AppColors.softBlush,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
                                  ),
                                  child: Text('VIEW MY BOOKINGS', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                ),
                              ),
                            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0)
                          ],
                        ),
                     ),
                   ),
                 ),
               ),
             );
           },
         );
       }
     } catch (e) {
       // Close loading dialog if open
       if (mounted) Navigator.pop(context);
       
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking failed: ${e.toString()}', style: GoogleFonts.outfit()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
       }
    }
  }
}
