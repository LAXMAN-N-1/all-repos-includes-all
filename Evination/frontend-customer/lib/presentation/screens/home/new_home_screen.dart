import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/utils/responsive_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NewHomeScreen extends ConsumerWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Light Background
          Positioned.fill(
            child: Container(
              color: AppColors.white,
            ),
          ),
          
          // Subtle Glow effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.sunflowerYellow.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 10.seconds, begin: const Offset(1,1), end: const Offset(1.2,1.2)),
          ),
          
          // 2. Content
          CustomScrollView(
            slivers: [
              // Custom App Bar with Logo
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                floating: true,
                pinned: true,
                actions: [
                  IconButton(icon: const Icon(LucideIcons.search, color: AppColors.darkCharcoal), onPressed: () {}),
                  IconButton(icon: const Icon(LucideIcons.bell, color: AppColors.darkCharcoal), onPressed: () => context.push('/notifications')),
                ],
              ),
              
              const SliverToBoxAdapter(
                child: HeroCarousel(),
              ),
              
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.valueByDevice(context, mobile: 16, tablet: 32, desktop: 64),
                  vertical: 32,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWhatWeDo(context).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 64),
                    _buildHowWeWork(context).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 64),
                    _buildCelebrationsSection(context).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                    const SizedBox(height: 64),
                    _buildSolemnSection(context).animate().fadeIn(duration: 800.ms, delay: 600.ms),
                    const SizedBox(height: 96),
                    _buildDownloadAppSection(context).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                    const SizedBox(height: 64),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.luxuryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.sunflowerYellow.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.cormorantGaramond(
              fontSize: ResponsiveHelper.isMobile(context) ? 28 : 36, 
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
              letterSpacing: 1.0,
            )),
            Text(subtitle, style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.greyMedium,
              fontWeight: FontWeight.w400,
            )),
          ],
        )
      ],
    );
  }

  Widget _buildWhatWeDo(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(
          context,
          title: 'Our Services', 
          subtitle: 'Making every detail of your special occasion perfect', 
          icon: LucideIcons.zap
        ),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildWhatWeDoCard(
                context,
                icon: LucideIcons.trendingUp,
                title: 'Best Price Bids',
                desc: 'Compare vendor bids to get the best quality at the best price for your event.',
                width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 3,
              ),
              _buildWhatWeDoCard(
                context,
                icon: LucideIcons.layoutGrid,
                title: 'All Event Types',
                desc: 'From grand weddings to birthday parties, we cover all celebrations.',
                width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 3,
              ),
              _buildWhatWeDoCard(
                context,
                icon: LucideIcons.shieldCheck,
                title: 'Trusted Vendors',
                desc: 'All our vendors are verified and rated by real customers like you.',
                width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 3,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildWhatWeDoCard(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String desc, 
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sunflowerYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.sunflowerYellow, size: 24),
          ),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.greyMedium, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildHowWeWork(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(
          context,
          title: 'How It Works',
          subtitle: 'Simple steps to your perfect event',
          icon: LucideIcons.workflow,
        ),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          double width = isMobile ? constraints.maxWidth : (constraints.maxWidth - 72) / 4;
          
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildHowWeWorkCard(step: 'I', title: 'Choose Event', desc: 'Select your event type.', width: width),
              _buildHowWeWorkCard(step: 'II', title: 'Get Bids', desc: 'Vendors send their best offers.', width: width),
              _buildHowWeWorkCard(step: 'III', title: 'Pick Vendor', desc: 'Choose the one you like.', width: width),
              _buildHowWeWorkCard(step: 'IV', title: 'Enjoy!', desc: 'Sit back and enjoy your event.', width: width),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHowWeWorkCard({
    required String step,
    required String title,
    required String desc,
    required double width,
  }) {
    return Container(
      width: width,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.sunflowerYellow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(step, style: GoogleFonts.cormorantGaramond(color: AppColors.sunflowerYellow.withValues(alpha: 0.4), fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
           const Spacer(),
           Text(title, style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 20, fontWeight: FontWeight.bold)),
           const SizedBox(height: 6),
           Text(desc, style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 13)),
         ],
      ),
    );
  }

  Widget _buildCelebrationsSection(BuildContext context) {
    final celebrations = [
      {
        'title': 'Weddings', 
        'subtitle': 'Your dream celebration', 
        'image': 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=1200&auto=format&fit=crop' 
      },
      {
        'title': 'Birthday Parties', 
        'subtitle': 'Joy in every moment', 
        'image': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'title': 'Anniversaries', 
        'subtitle': 'Celebrating your milestones', 
        'image': 'https://images.unsplash.com/photo-1529543544282-ea7407407c44?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'title': 'Corporate Events', 
        'subtitle': 'Professional gatherings', 
        'image': 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'title': 'Product Launches', 
        'subtitle': 'Make it memorable', 
        'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'title': 'Team Outings', 
        'subtitle': 'Building bonds together', 
        'image': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?q=80&w=1200&auto=format&fit=crop'
      },
    ];

    return Column(
      children: [
        _buildSectionHeader(
          context,
          title: 'Celebrations',
          subtitle: 'Making your special moments unforgettable',
          icon: LucideIcons.partyPopper,
        ),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final isTablet = ResponsiveHelper.isTablet(context);
          final cols = isMobile ? 1 : (isTablet ? 2 : 3);
          final width = (constraints.maxWidth - (24 * (cols - 1))) / cols;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: celebrations.map((item) => _buildEventCard(
              context,
              title: item['title']!, 
              subtitle: item['subtitle']!, 
              imageUrl: item['image']!, 
              width: width,
              onPressed: () => context.push('/book/${item['title']}'), 
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSolemnSection(BuildContext context) {
    final events = [
      {
        'title': 'Memorial Services', 
        'subtitle': 'Honoring loved ones', 
        'image': 'https://images.unsplash.com/photo-1494972308805-463bc619d34e?q=80&w=1200&auto=format&fit=crop'
      },
      {
        'title': 'Prayer Meetings', 
        'subtitle': 'Coming together in remembrance', 
        'image': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?q=80&w=1200&auto=format&fit=crop'
      },
    ];

    return Column(
      children: [
        _buildSectionHeader(
          context,
          title: 'Solemn Occasions',
          subtitle: 'Respectful support when it matters most',
          icon: LucideIcons.heartHandshake,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.sunflowerYellow.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.star, color: AppColors.sunflowerYellow, size: 24),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  "We handle these occasions with the utmost care, sensitivity, and respect.",
                  style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final cols = isMobile ? 1 : 2; 
          final width = (constraints.maxWidth - (24 * (cols - 1))) / cols;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: events.map((item) => _buildEventCard(
              context,
              title: item['title']!, 
              subtitle: item['subtitle']!, 
              imageUrl: item['image']!, 
              width: width,
              onPressed: () => context.push('/book/${item['title']}'),
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required double width,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), 
              blurRadius: 20, 
              offset: const Offset(0,10)
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.network(
                imageUrl, 
                width: double.infinity, 
                height: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.greyLight,
                  child: Center(
                    child: Icon(LucideIcons.image, color: AppColors.greyMedium.withValues(alpha: 0.3), size: 48),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.greyLight,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.sunflowerYellow, strokeWidth: 2),
                    ),
                  );
                },
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, 
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, letterSpacing: 0.5)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Book Now', style: GoogleFonts.outfit(color: AppColors.sunflowerYellow, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.arrowRight, color: AppColors.sunflowerYellow, size: 16),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDownloadAppSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36), 
        gradient: LinearGradient(
          colors: [AppColors.sunflowerYellow.withValues(alpha: 0.08), AppColors.sunflowerYellow.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.15)),
      ),
      child: Column(
         children: [
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: AppColors.sunflowerYellow.withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: const Icon(LucideIcons.smartphone, color: AppColors.sunflowerYellow, size: 42),
           ),
           const SizedBox(height: 32),
           Text(
             'Get the EVE NATION App', 
             textAlign: TextAlign.center, 
             style: GoogleFonts.cormorantGaramond(
               color: AppColors.darkCharcoal, 
               fontSize: 32, 
               fontWeight: FontWeight.bold,
               letterSpacing: 1.0,
             )
           ),
           const SizedBox(height: 12),
           Text(
             'Plan your events on the go with our mobile app.',
             textAlign: TextAlign.center,
             style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 15, height: 1.6),
           ),
           const SizedBox(height: 40),
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               _buildStoreButton(LucideIcons.apple, 'App Store'),
               const SizedBox(width: 16),
               _buildStoreButton(LucideIcons.play, 'Play Store'),
             ],
           ),
         ],
      ),
    );
  }

  Widget _buildStoreButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCharcoal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveHelper.valueByDevice<double>(context, mobile: 550, tablet: 600, desktop: 700);

    final List<Map<String, dynamic>> slides = [
      {
        'title': 'PLAN YOUR\nDREAM EVENT',
        'subtitle': 'Verified Vendors. Best Prices. Hassle-Free Planning.',
        'image': 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=1200&auto=format&fit=crop', 
      },
      {
        'title': 'BEAUTIFUL\nWEDDINGS',
        'subtitle': 'From venue to catering, we make your wedding perfect.',
        'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=1200&auto=format&fit=crop',
      },
      {
        'title': 'CORPORATE\nEVENTS',
        'subtitle': 'Professional events managed with care and precision.',
        'image': 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=1200&auto=format&fit=crop',
      },
    ];

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: slides.map((slide) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    slide['image'], fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                       color: AppColors.greyLight,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                       return Container(
                          color: AppColors.greyLight,
                          child: const Center(
                             child: CircularProgressIndicator(color: AppColors.sunflowerYellow, strokeWidth: 2),
                          ),
                       );
                    },
                  ),
                  // Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1), 
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.6)
                        ],
                        stops: const [0.2, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide['title'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.isMobile(context) ? 48 : 84,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: -1.0,
                          ),
                        ).animate().scale(duration: 1200.ms, curve: Curves.easeOut).fadeIn(),
                        const SizedBox(height: 24),
                        Text(
                          slide['subtitle'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppColors.sunflowerYellow,
                            fontSize: ResponsiveHelper.isMobile(context) ? 14 : 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          
          // Indicators
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: slides.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _currentIndex == entry.key ? 40.0 : 6.0,
                  height: 3.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _currentIndex == entry.key ? AppColors.sunflowerYellow : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
