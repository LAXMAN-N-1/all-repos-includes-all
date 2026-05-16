enum DocumentStatus { verified, pending, rejected, missing }

class Document {
  final String id;
  final String title;
  final DocumentStatus status;
  final String? fileUrl; // Mock URL or local path
  final DateTime? lastUpdated;
  final String? rejectionReason;

  Document({
    required this.id,
    required this.title,
    this.status = DocumentStatus.missing,
    this.fileUrl,
    this.lastUpdated,
    this.rejectionReason,
  });

  Document copyWith({
    String? title,
    DocumentStatus? status,
    String? fileUrl,
    DateTime? lastUpdated,
    String? rejectionReason,
  }) {
    return Document(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      fileUrl: fileUrl ?? this.fileUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
