import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/ticket_state.dart';

final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, TicketState>((ref) {
  return TicketsNotifier(ref.watch(dioProvider));
});

class TicketsNotifier extends StateNotifier<TicketState> {
  final Dio _dio;
  TicketsNotifier(this._dio) : super(const TicketState()) {
    refresh();
  }

  Future<void> refresh({String? statusFilter}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = <String, dynamic>{
        'page': 1,
        'limit': 50,
      };
      if (statusFilter != null && statusFilter != 'All') {
        queryParams['status_filter'] =
            statusFilter.toLowerCase().replaceAll(' ', '_');
      }

      final response = await _dio.get(
        ApiConstants.tickets,
        queryParameters: queryParams,
      );

      // Support live API variations (PaginatedResponse vs List)
      List<dynamic> items = [];
      if (response.data is List) {
        items = response.data;
      } else if (response.data is Map) {
        items = response.data['items'] ??
            response.data['tickets'] ??
            response.data['data'] ??
            [];
      }

      final tickets =
          items.map((e) => _mapToDto(e as Map<String, dynamic>)).toList();

      // Keeping realistic metrics for visual completion as per spec
      final openCount = tickets.where((t) => t.status == 'Open').length;
      final resolvedCount = tickets
          .where((t) =>
              t.status == 'Resolved' &&
              t.updatedAt != null &&
              DateTime.now().difference(DateTime.parse(t.updatedAt!).toLocal()).inHours <=
                  24)
          .length;
      final escalatedCount =
          tickets.where((t) => t.isCritical || t.status == 'Escalated').length;

      final metrics = [
        TicketMetric(label: 'Total Open', value: '$openCount', color: 'amber'),
        TicketMetric(
            label: 'Resolved Today', value: '$resolvedCount', color: 'green'),
        TicketMetric(
            label: 'Critical / Escalated',
            value: '$escalatedCount',
            color: 'red'),
      ];

      state = state.copyWith(
        isLoading: false,
        tickets: tickets,
        metrics: metrics,
      );

      // If a ticket is currently selected, fetch its detail to hydrate messages
      if (state.selectedTicketId != null) {
        fetchTicketDetail(state.selectedTicketId!);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data?['detail'] ?? e.message;
      log('Tickets API Error [$statusCode]: $detail');
      state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch tickets ($statusCode): $detail');
    } catch (e) {
      log('Tickets Error: $e');
      state = state.copyWith(
          isLoading: false, error: 'Failed to fetch tickets: $e');
    }
  }

  Future<void> fetchTicketDetail(int ticketId) async {
    try {
      final response = await _dio.get(ApiConstants.ticketDetail(ticketId));
      final detailDto = _mapToDto(response.data as Map<String, dynamic>);

      final updatedList =
          state.tickets.map((t) => t.id == ticketId ? detailDto : t).toList();
      state = state.copyWith(tickets: updatedList, error: null);
    } catch (e) {
      log('Ticket Detail Error: $e');
    }
  }

  Future<bool> createTicket(
      String subject, String description, String category, String priority,
      {String? attachmentUrl}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _dio.post(
        ApiConstants.tickets,
        data: {
          "subject": subject,
          "description": description,
          "category": category.toLowerCase().replaceAll(' ', '_'),
          "priority": priority.toLowerCase(),
          if (attachmentUrl != null && attachmentUrl.isNotEmpty)
            "attachment_url": attachmentUrl,
        },
      );
      await refresh();
      return true;
    } catch (e) {
      log('Create Ticket Error: $e');
      state = state.copyWith(
          isLoading: false, error: 'Failed to create ticket: $e');
      return false;
    }
  }

  Future<void> replyToTicket(int ticketId, String message,
      {String? attachmentUrl}) async {
    try {
      await _dio.post(
        ApiConstants.ticketReply(ticketId),
        data: {
          "message": message,
          if (attachmentUrl != null && attachmentUrl.isNotEmpty)
            "attachment_url": attachmentUrl,
        },
      );

      await fetchTicketDetail(ticketId);
    } catch (e) {
      log('Reply Ticket Error: $e');
      state = state.copyWith(error: 'Failed to reply: $e');
    }
  }

  Future<void> closeTicket(int ticketId) async {
    try {
      await _dio.patch(ApiConstants.ticketClose(ticketId));
      await refresh();
    } catch (e) {
      log('Close Ticket Error: $e');
      state = state.copyWith(error: 'Failed to close ticket: $e');
    }
  }

  void selectTicket(int? id) {
    state = state.copyWith(selectedTicketId: id);
    if (id != null) {
      fetchTicketDetail(id);
    }
  }

  void toggleFilterPanel() {
    state = state.copyWith(isFilterPanelOpen: !state.isFilterPanelOpen);
  }

  void toggleMetricsView() {
    state = state.copyWith(isMetricsView: !state.isMetricsView);
  }

  // --- Helpers ---

  TicketDto _mapToDto(Map<String, dynamic> json) {
    final id = json['id'] ??
        json['ticket_id'] ??
        DateTime.now().millisecondsSinceEpoch;
    return TicketDto(
      id: id is int
          ? id
          : int.tryParse(id.toString()) ??
              DateTime.now().millisecondsSinceEpoch,
      subject: json['subject'] ?? 'No Subject',
      description: json['description'] ?? '',
      customerName: json['customer_name'] ?? 'System',
      customerPhone: json['customer_phone'] ?? '',
      customerAvatar: _getInitials(json['customer_name']),
      priority: _capitalize(json['priority'] ?? 'Low'),
      status: _mapStatus(json['status'] ?? 'open'),
      category: json['category'] ?? 'General',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'],
      assignedToName: json['assigned_to_name'],
      assignedToAvatar: _getInitials(json['assigned_to_name']),
      slaDeadline: json['sla_deadline'] != null
          ? DateTime.parse(json['sla_deadline']).toLocal()
          : null,
      stationName: json['station_name'],
      batteryId: json['battery_id'],
      transactionId: json['transaction_id'],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      sourceChannel: json['source_channel'] ?? 'Mobile App',
      isCritical: (json['priority'] ?? '').toLowerCase() == 'critical',
      isResolved: (json['status'] ?? '').toLowerCase() == 'resolved' ||
          (json['status'] ?? '').toLowerCase() == 'closed',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => _mapMessage(m as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory: (json['status_history'] as List<dynamic>?)
              ?.map((s) => _mapStatusHistory(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  TicketMessage _mapMessage(Map<String, dynamic> json) {
    final id = json['id'] ?? DateTime.now().millisecondsSinceEpoch;
    // Backend returns sender_id (int) not sender_name; derive a display name
    final senderName = json['sender_name'] ??
        (json['is_internal'] == true ? 'Support Agent' : 'You');
    final role =
        json['role'] ?? (json['is_internal'] == true ? 'agent' : 'customer');
    return TicketMessage(
      id: id is int
          ? id
          : int.tryParse(id.toString()) ??
              DateTime.now().millisecondsSinceEpoch,
      senderName: senderName,
      senderAvatar: _getInitials(senderName),
      text: json['message'] ?? json['text'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString())?.toLocal() ??
                  DateTime.now()
              : DateTime.now()),
      type: role,
    );
  }

  StatusChangeEvent _mapStatusHistory(Map<String, dynamic> json) {
    return StatusChangeEvent(
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp']).toLocal()
          : DateTime.now(),
      description: json['description'] ?? 'Status updated',
      dotColor: _getStatusColor(json['new_status'] ?? json['status']),
    );
  }

  String _mapStatus(String s) {
    switch (s.toLowerCase().replaceAll('_', ' ')) {
      case 'open':
        return 'Open';
      case 'in progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  String _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase().replaceAll('_', ' ')) {
      case 'critical':
        return 'red';
      case 'resolved':
        return 'green';
      case 'escalated':
        return 'red';
      case 'in progress':
        return 'cyan';
      default:
        return 'amber';
    }
  }
}
