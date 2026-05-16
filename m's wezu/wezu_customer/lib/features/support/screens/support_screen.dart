import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../repositories/faq_repository.dart';
import 'live_chat_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final FAQRepository _faqRepository = FAQRepository();
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFaqs = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    final faqs = await _faqRepository.search(_searchController.text);
    if (mounted) {
      setState(() {
        _filteredFaqs = _selectedCategory == 'All'
            ? faqs
            : faqs.where((f) => f.category == _selectedCategory).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildHeroSection(),
          _buildCategoryFilter(),
          Expanded(
            child: _filteredFaqs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) =>
                        _buildFaqItem(_filteredFaqs[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveChatScreen()),
        ),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(LucideIcons.messageCircle),
        label: const Text('Live Chat',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (val) => _loadFaqs(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search FAQ, guides...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon:
                  const Icon(LucideIcons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surfaceDark,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = _faqRepository.getCategories();
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedCategory = cat);
                _loadFaqs();
              },
              backgroundColor: AppTheme.surfaceDark,
              selectedColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(FAQItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(item.question,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        subtitle: Text(item.category,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        iconColor: AppTheme.primaryBlue,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                Text(item.answer,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5)),
                if (item.videoUrl != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {}, // Play video placeholder
                    icon: const Icon(LucideIcons.playCircle, size: 18),
                    label: const Text('Watch Guide Video'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGreen),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.helpCircle, size: 64, color: AppTheme.surfaceDark),
          const SizedBox(height: 16),
          const Text('No FAQs found',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}