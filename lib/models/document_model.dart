enum DocumentStatus { missing, uploaded, verified, rejected }

class DocumentItem {
  final String name;
  final String description;
  DocumentStatus status;
  String? fileName;
  DateTime? uploadedAt;

  DocumentItem({
    required this.name,
    required this.description,
    this.status = DocumentStatus.missing,
    this.fileName,
    this.uploadedAt,
  });

  bool get isUploaded => status == DocumentStatus.uploaded || status == DocumentStatus.verified;
  bool get isMissing => status == DocumentStatus.missing;

  String get statusLabel {
    switch (status) {
      case DocumentStatus.missing:
        return 'Missing';
      case DocumentStatus.uploaded:
        return 'Uploaded';
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }

  DocumentItem copyWith({DocumentStatus? status, String? fileName, DateTime? uploadedAt}) {
    return DocumentItem(
      name: name,
      description: description,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
