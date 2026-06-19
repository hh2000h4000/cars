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
  final String serviceType;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final RequestStatus status;
  final String dateLabel;
  final int quotationCount;
  final String? notes;
  final String? selectedShopName;

  const ServiceRequest({
    required this.id,
    required this.serviceType,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.status,
    required this.dateLabel,
    this.quotationCount = 0,
    this.notes,
    this.selectedShopName,
  });
}
