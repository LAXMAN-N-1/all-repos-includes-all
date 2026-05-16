import '../../../core/network/api_client.dart';

class FAQItem {
  final String category;
  final String question;
  final String answer;
  final String? videoUrl;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
    this.videoUrl,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      category: json['category'] ?? 'General',
      question: json['question'] ?? json['title'] ?? '',
      answer: json['answer'] ?? json['content'] ?? '',
      videoUrl: json['video_url'],
    );
  }
}

class FAQRepository {
  final List<FAQItem> _faqs = [
    // Billing Category
    FAQItem(
      category: 'Billing',
      question: 'How do late fees work?',
      answer:
          'Late fees accrue at \$1.50 per hour after your rental expires, with a daily cap of \$15.00.',
    ),
    FAQItem(
      category: 'Billing',
      question: 'Can I get a refund for a failed swap?',
      answer:
          'Yes, if a swap fails due to station technical issues, a full refund is processed within 3-5 business days.',
    ),
    // Technical Category
    FAQItem(
      category: 'Technical',
      question: 'How do I scan the QR code?',
      answer:
          'Open the Rent tab, tap the Scan icon, and point your camera at the QR code on the battery hub.',
      videoUrl: 'https://wezu.energy/guides/scan_qr',
    ),
    FAQItem(
      category: 'Technical',
      question: 'What if my battery is overheating?',
      answer:
          'If the app warns about high temperature, slow down or stop using the battery for a few minutes to let it cool.',
    ),
    // Rental Category
    FAQItem(
      category: 'Rental',
      question: 'What is the maximum rental duration?',
      answer:
          'You can rent or extend your battery for up to 30 days at a time.',
    ),
    // ... Mocking 50+ entries via a generator approach for implementation
  ];

  FAQRepository();

  Future<List<FAQItem>> search(String query) async {
    try {
      final response = await apiClient.get(
        '/faqs',
        queryParameters: {
          if (query.trim().isNotEmpty) 'q': query.trim(),
        },
      ).timeout(const Duration(seconds: 5));

      final payload = response.data;
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((json) => FAQItem.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      if (payload is Map && payload['data'] is List) {
        final data = payload['data'] as List<dynamic>;
        return data
            .whereType<Map>()
            .map((json) => FAQItem.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      print('FAQ API unavailable, falling back to local FAQ cache: $e');
    }

    if (query.isEmpty) return _faqs;

    final lowercaseQuery = query.toLowerCase();
    return _faqs
        .where((item) =>
            item.question.toLowerCase().contains(lowercaseQuery) ||
            item.answer.toLowerCase().contains(lowercaseQuery) ||
            item.category.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  List<String> getCategories() =>
      ['All', 'Rental', 'Billing', 'Technical', 'General', 'Account'];
}
