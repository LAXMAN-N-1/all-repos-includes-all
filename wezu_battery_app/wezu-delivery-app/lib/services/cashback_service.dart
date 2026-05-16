import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cashback_offer.dart';

class CashbackService {
  static const _base = 'https://api.wezu.app';
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;
  CashbackService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CashbackOffer>> fetchOffers(String authToken) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_base/wallet/cashback'),
            headers: {
              'Accept': 'application/json',
              if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((e) => CashbackOffer.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // fall through to mock
    }
    return _mockOffers();
  }

  List<CashbackOffer> _mockOffers() => [
    CashbackOffer(
      id: 'offer-1',
      title: 'Recharge ₹500, Get ₹50 Cashback',
      description:
          'Top up your wallet with ₹500 or more and earn ₹50 instant cashback.',
      terms:
          '• Minimum recharge amount: ₹500\n'
          '• Cashback credited within 24 hours\n'
          '• Valid once per user\n'
          '• Cannot be combined with other offers\n'
          '• Wezu reserves the right to modify or cancel this offer',
      expiryDate: DateTime(2026, 3, 31),
      category: OfferCategory.recharge,
    ),
    CashbackOffer(
      id: 'offer-2',
      title: '10% Off on Your Next 3 Rentals',
      description: 'Get 10% cashback on every rental for your next 3 rides.',
      terms:
          '• Applicable on rentals above ₹200\n'
          '• Maximum cashback per rental: ₹100\n'
          '• Valid for 3 successive rentals\n'
          '• Offer expires March 31, 2026',
      expiryDate: DateTime(2026, 3, 31),
      category: OfferCategory.rental,
    ),
    CashbackOffer(
      id: 'offer-3',
      title: 'Recharge ₹1000, Get ₹120 Cashback',
      description: 'Recharge ₹1000 at once and enjoy ₹120 bonus.',
      terms:
          '• Minimum single recharge: ₹1000\n'
          '• Cashback credited within 48 hours\n'
          '• One time offer per account\n'
          '• Valid until March 31, 2026',
      expiryDate: DateTime(2026, 3, 31),
      category: OfferCategory.recharge,
    ),
  ];

  void dispose() => _client.close();
}
