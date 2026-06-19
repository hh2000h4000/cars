enum DisputeStatus { underReview, waitingShop, resolved }
enum DisputeSeverity { high, medium, low }

extension DisputeStatusInfo on DisputeStatus {
  String get label {
    switch (this) {
      case DisputeStatus.underReview: return 'قيد المراجعة';
      case DisputeStatus.waitingShop: return 'بانتظار رد المتجر';
      case DisputeStatus.resolved: return 'تم الحل';
    }
  }
}

class Dispute {
  final String id;
  final String reason;
  final String description;
  final String requestId;
  final String customerName;
  final String shopName;
  final String submittedAt;
  final DisputeStatus status;
  final DisputeSeverity severity;

  const Dispute({
    required this.id,
    required this.reason,
    required this.description,
    required this.requestId,
    required this.customerName,
    required this.shopName,
    required this.submittedAt,
    required this.status,
    required this.severity,
  });
}
