enum DisputeStatus { underReview, waitingShop, resolved }

extension DisputeStatusInfo on DisputeStatus {
  String get label {
    switch (this) {
      case DisputeStatus.underReview: return 'قيد المراجعة';
      case DisputeStatus.waitingShop: return 'بانتظار رد المتجر';
      case DisputeStatus.resolved: return 'تم الحل';
    }
  }

  String get apiValue {
    switch (this) {
      case DisputeStatus.underReview: return 'UnderReview';
      case DisputeStatus.waitingShop: return 'WaitingShop';
      case DisputeStatus.resolved: return 'Resolved';
    }
  }
}

class Dispute {
  final String id;
  final String reason;
  final String details;
  final String requestId;
  final String customerName;
  final String shopName;
  final String submittedAt;
  DisputeStatus status;

  Dispute({
    required this.id,
    required this.reason,
    required this.details,
    required this.requestId,
    required this.customerName,
    required this.shopName,
    required this.submittedAt,
    required this.status,
  });

  factory Dispute.fromJson(Map<String, dynamic> j) {
    String parseReason(String r) {
      switch (r) {
        case 'ServiceQuality': return 'جودة الخدمة';
        case 'Pricing': return 'خلاف على السعر';
        case 'Delay': return 'التأخير في التسليم';
        default: return 'أخرى';
      }
    }

    DisputeStatus parseStatus(String s) {
      switch (s) {
        case 'WaitingShop': return DisputeStatus.waitingShop;
        case 'Resolved': return DisputeStatus.resolved;
        default: return DisputeStatus.underReview;
      }
    }

    final createdAt = DateTime.tryParse(j['createdAt'] as String? ?? '');
    final submittedAt = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '–';

    return Dispute(
      id: (j['id'] as String? ?? '').substring(0, 8).toUpperCase(),
      reason: parseReason(j['reason'] as String? ?? ''),
      details: j['details'] as String? ?? '',
      requestId: (j['requestId'] as String? ?? '').substring(0, 8).toUpperCase(),
      customerName: j['customerName'] as String? ?? '',
      shopName: j['shopName'] as String? ?? '',
      submittedAt: submittedAt,
      status: parseStatus(j['status'] as String? ?? ''),
    );
  }

  String get rawId => id;
}

