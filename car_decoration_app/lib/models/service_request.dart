enum RequestStatus {
  draft,
  pending,
  offers,
  shopSelected,
  scheduled,
  inProgress,
  completed,
  cancelled,
  disputed,
}

extension RequestStatusLabel on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.draft: return 'مسودة';
      case RequestStatus.pending: return 'بانتظار رد المتاجر';
      case RequestStatus.offers: return 'عروض مستلمة';
      case RequestStatus.shopSelected: return 'تم اختيار المتجر';
      case RequestStatus.scheduled: return 'موعد مجدول';
      case RequestStatus.inProgress: return 'قيد التنفيذ';
      case RequestStatus.completed: return 'مكتمل';
      case RequestStatus.cancelled: return 'ملغي';
      case RequestStatus.disputed: return 'نزاع مفتوح';
    }
  }

  String get colorType {
    switch (this) {
      case RequestStatus.completed: return 'green';
      case RequestStatus.disputed: return 'red';
      default: return 'gold';
    }
  }
}

class ServiceRequest {
  final String id;
  final int requestNumber;
  final String vehicleId;
  final String serviceType;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final String location;
  final RequestStatus status;
  final String dateLabel;
  final int quotationCount;
  final String? notes;
  final String? selectedShopName;
  final DateTime? appointmentDate;
  final List<String> imageUrls;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'pending';
    final RequestStatus status;
    switch (statusStr) {
      case 'active': status = RequestStatus.inProgress; break;
      case 'completed': status = RequestStatus.completed; break;
      case 'cancelled': status = RequestStatus.cancelled; break;
      default: status = RequestStatus.pending;
    }
    final createdAt = json['createdAt'] as String?;
    String dateLabel = '';
    if (createdAt != null) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        dateLabel = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }
    DateTime? appointmentDate;
    final apptStr = json['appointmentDate'] as String?;
    if (apptStr != null) {
      try { appointmentDate = DateTime.parse(apptStr).toLocal(); } catch (_) {}
    }
    final rawUrls = json['imageUrls'] as List<dynamic>?;
    return ServiceRequest(
      id: json['id'] as String,
      requestNumber: json['requestNumber'] as int? ?? 0,
      vehicleId: (json['vehicleId'] as String?) ?? '',
      serviceType: json['description'] as String? ?? '',
      vehicleBrand: json['vehicleBrand'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleYear: json['vehicleYear'] as int? ?? 0,
      vehicleColor: json['vehicleColor'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: status,
      dateLabel: dateLabel,
      quotationCount: json['quotationCount'] as int? ?? 0,
      notes: json['notes'] as String?,
      appointmentDate: appointmentDate,
      imageUrls: rawUrls?.cast<String>() ?? [],
    );
  }

  const ServiceRequest({
    required this.id,
    required this.requestNumber,
    this.vehicleId = '',
    required this.serviceType,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    this.location = '',
    required this.status,
    required this.dateLabel,
    this.quotationCount = 0,
    this.notes,
    this.selectedShopName,
    this.appointmentDate,
    this.imageUrls = const [],
  });
}
