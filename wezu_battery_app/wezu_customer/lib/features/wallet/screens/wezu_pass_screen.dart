import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';
import '../widgets/plan_comparison.dart';
import '../screens/subscription_purchase_screen.dart';
import '../../../core/theme/app_theme.dart';

class WezuPassScreen extends ConsumerStatefulWidget {
  const WezuPassScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WezuPassScreen> createState() => _WezuPassScreenState();
}

class _WezuPassScreenState extends ConsumerState<WezuPassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _expandedFAQIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(subscriptionNotifierProvider.notifier).refetchPlans();
          await ref
              .read(subscriptionNotifierProvider.notifier)
              .refetchActiveSubscription();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Hero Section
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Wezu Pass',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.zap,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unlimited Battery Swaps',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Benefits Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Why Choose Wezu Pass?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitsGrid(isDark),
                ],
              ),
            ),

            // Tab Bar
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor:
                  isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
              elevation: 0,
              pinned: true,
              toolbarHeight: 60,
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor:
                      isDark ? Colors.grey[400] : Colors.grey[600],
                  indicatorColor: AppTheme.primaryBlue,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Plans'),
                    Tab(text: 'Compare'),
                  ],
                ),
              ),
            ),

            // Tab Views
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Plans Tab
                    _buildPlansTab(subscriptionState, isDark),
                    // Comparison Tab
                    _buildComparisonTab(subscriptionState, isDark),
                  ],
                ),
              ),
            ),

            // FAQ Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFAQAccordion(isDark),
                  ],
                ),
              ),
            ),

            // Testimonials Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Users Say',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTestimonials(isDark),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid(bool isDark) {
    final benefits = [
      {
        'icon': LucideIcons.infinity,
        'title': 'Unlimited Swaps',
        'description': 'Swap batteries as many times as you want',
      },
      {
        'icon': LucideIcons.star,
        'title': 'Priority Access',
        'description': 'Priority queue at all battery stations',
      },
      {
        'icon': LucideIcons.gift,
        'title': 'Exclusive Offers',
        'description': 'Member-only discounts and promotions',
      },
      {
        'icon': LucideIcons.phone,
        'title': '24/7 Support',
        'description': 'Dedicated customer support',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                benefit['icon'] as IconData,
                size: 32,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              Text(
                benefit['title'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                benefit['description'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlansTab(SubscriptionState state, bool isDark) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.plans.isEmpty) {
      return Center(
        child: Text(
          'No plans available',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...state.plans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PlanCard(
                  plan: plan,
                  isCurrentPlan: state.activeSubscription?.planId == plan.id,
                  onSelect: () => _handlePlanSelection(plan),
                  isPopular: plan.isPopular,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(SubscriptionState state, bool isDark) {
    if (state.isLoading || state.plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanComparisonTable(
          plans: state.plans,
          onSelectPlan: _handlePlanSelection,
        ),
      ],
    );
  }

  Widget _buildFAQAccordion(bool isDark) {
    final faqs = [
      {
        'question': 'Can I cancel anytime?',
        'answer':
            'Yes, you can cancel your subscription anytime. Your access will continue until the end of your billing period.',
      },
      {
        'question': 'What happens if I upgrade my plan?',
        'answer':
            'When you upgrade, your new plan benefits will be immediately available. Any unused portion of your previous plan will be credited.',
      },
      {
        'question': 'How does auto-renewal work?',
        'answer':
            'Your subscription will automatically renew on the renewal date using your saved payment method. You can toggle auto-renewal on/off anytime.',
      },
      {
        'question': 'Do I get a refund if I cancel?',
        'answer':
            'If you cancel before your period ends, you\'re eligible for a prorated refund based on the remaining days of your subscription.',
      },
    ];

    return Column(
      children: List.generate(faqs.length, (index) {
        final faq = faqs[index];
        final isExpanded = _expandedFAQIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _expandedFAQIndex = isExpanded ? -1 : index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.grey[850] : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            faq['question'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[200]!,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        faq['answer'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTestimonials(bool isDark) {
    final testimonials = [
      {
        'name': 'Rajesh Kumar',
        'text':
            'Wezu Pass has changed my daily commute. Unlimited swaps mean I never worry about battery availability.',
        'rating': 5,
      },
      {
        'name': 'Priya Sharma',
        'text':
            'The priority access feature is amazing. No more waiting in long queues at peak hours!',
        'rating': 5,
      },
      {
        'name': 'Amit Patel',
        'text':
            'Great value for money. The monthly plan is cheaper than my previous pay-per-use expenses.',
        'rating': 4,
      },
    ];

    return Column(
      children: testimonials.map((testimonial) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.grey[850] : Colors.white,
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        LucideIcons.star,
                        size: 16,
                        color: index < (testimonial['rating'] as int)
                            ? Colors.amber
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  testimonial['text'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '- ${testimonial['name']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handlePlanSelection(dynamic plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPurchaseScreen(selectedPlan: plan),
      ),
    );
  }
}
