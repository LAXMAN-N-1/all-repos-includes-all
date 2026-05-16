import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/network/api_client.dart';
import '../models/support_message.dart';

class ChatService {
  final _messageController = StreamController<List<SupportMessage>>.broadcast();
  final List<SupportMessage> _messages = [];
  int? _activeTicketId;
  int? _currentUserId;
  Timer? _pollingTimer;

  Stream<List<SupportMessage>> get messageStream => _messageController.stream;

  ChatService() {
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final response = await apiClient.get(
        '/support/tickets/my',
        queryParameters: {'page': 1, 'limit': 20},
      );
      final data = response.data;
      final List<dynamic> tickets = data is Map && data['data'] is List
          ? data['data'] as List<dynamic>
          : const [];

      if (tickets.isNotEmpty) {
        final latest = Map<String, dynamic>.from(tickets.first as Map);
        _activeTicketId = (latest['id'] as num?)?.toInt();
        _currentUserId = (latest['user_id'] as num?)?.toInt();
        await _fetchMessages();
      } else {
        final createResponse = await apiClient.post('/support/tickets', data: {
          'subject': 'General Support Session',
          'category': 'general',
          'priority': 'medium',
          'description': 'Support conversation started from customer app.',
        });
        final created = createResponse.data;
        if (created is Map) {
          _activeTicketId = (created['id'] as num?)?.toInt();
          _currentUserId = (created['user_id'] as num?)?.toInt();
          _addMessage(SupportMessage(
            id: 'bot-welcome',
            content: 'Hi! I am the WEZU Bot. How can I help you today?',
            timestamp: DateTime.now(),
            sender: MessageSender.bot,
          ));
        }
      }

      _startPolling();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }
  }

  void _startPolling() {
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _fetchMessages());
  }

  Future<void> _fetchMessages() async {
    if (_activeTicketId == null) return;

    try {
      final response = await apiClient.get('/support/tickets/$_activeTicketId');
      final data = response.data;
      if (data is Map) {
        _currentUserId ??= (data['user_id'] as num?)?.toInt();
        final List<dynamic> messagesJson =
            (data['messages'] as List<dynamic>?) ?? const [];
        final List<SupportMessage> remoteMessages = messagesJson
            .whereType<Map>()
            .map((json) => SupportMessage.fromJson(
                  Map<String, dynamic>.from(json),
                  currentUserId: _currentUserId,
                ))
            .toList();

        _messages.clear();
        _messages.addAll(remoteMessages);
        _messageController.add(List.from(_messages.reversed));
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void _addMessage(SupportMessage msg) {
    _messages.add(msg);
    _messageController.add(List.from(_messages.reversed));
  }

  Future<void> sendMessage(String text, {String? attachmentPath}) async {
    if (_activeTicketId == null) return;

    // Optimistic UI update
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = SupportMessage(
      id: tempId,
      content: text,
      timestamp: DateTime.now(),
      sender: MessageSender.user,
    );
    _addMessage(userMsg);

    try {
      final response = await apiClient
          .post('/support/tickets/$_activeTicketId/reply', data: {
        'message': text,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchMessages();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _messageController.close();
  }
}
