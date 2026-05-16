import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class HelpSupportViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<FaqItem> _faqs = [
    FaqItem(
      question: 'How do I change my vehicle details?',
      answer:
          'Go to your Profile, click on the edit icon next to Vehicle Information to update your details.',
    ),
    FaqItem(
      question: 'When will I receive my payout?',
      answer:
          ' payouts are processed every Wednesday for the previous week\'s earnings.',
    ),
    FaqItem(
      question: 'How do I cancel an order?',
      answer:
          'You can cancel an order only if you haven\'t picked it up yet. Contact support for assistance.',
    ),
    FaqItem(
      question: 'Where can I find my completed deliveries?',
      answer:
          'Open Earnings and tap "See details" to view your earnings activity and completed deliveries.',
    ),
  ];

  List<FaqItem> get faqs => _faqs;

  void toggleFaq(int index) {
    _faqs[index].isExpanded = !_faqs[index].isExpanded;
    notifyListeners();
  }

  Future<bool> submitTicket(String subject, String description) async {
    _isLoading = true;
    notifyListeners();

    // Mock API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
