import 'package:equatable/equatable.dart';

class DashboardReportQueued extends Equatable {
  final String reportId;
  final String status;

  const DashboardReportQueued({required this.reportId, required this.status});

  factory DashboardReportQueued.fromJson(Map<String, dynamic> json) {
    return DashboardReportQueued(
      reportId: json['report_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'queued',
    );
  }

  @override
  List<Object?> get props => [reportId, status];
}

class DashboardReportStatus extends Equatable {
  final String reportId;
  final String status;
  final String? fileUrl;
  final DateTime? expiresAt;
  final String? detail;

  const DashboardReportStatus({
    required this.reportId,
    required this.status,
    this.fileUrl,
    this.expiresAt,
    this.detail,
  });

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isTerminal => isCompleted || isFailed;

  factory DashboardReportStatus.fromJson(Map<String, dynamic> json) {
    final fileUrl = json['file_url']?.toString();
    return DashboardReportStatus(
      reportId: json['report_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'queued',
      fileUrl: fileUrl == null || fileUrl.trim().isEmpty
          ? null
          : fileUrl.trim(),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      detail: json['detail']?.toString(),
    );
  }

  @override
  List<Object?> get props => [reportId, status, fileUrl, expiresAt, detail];
}
