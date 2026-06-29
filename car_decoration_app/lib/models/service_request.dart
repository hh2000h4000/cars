enum RequestStatus { open, shopSelected, inProgress, completed, cancelled, expired }

class AcceptedShopSummary {
  final String shopName;
  final String shopId;
  final String? chatRoomId;

  const AcceptedShopSummary({required this.shopName, required this.shopId, this.chatRoomId});

  factory AcceptedShopSummary.fromJson(Map<String, dynamic> json) => AcceptedShopSummary(
    shopName: json['shopName'] as String? ?? '',
    shopId: json['shopId'] as String? ?? '',
    chatRoomId: json['chatRoomId'] as String?,
  );
}

extension RequestStatusLabel on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.open:         return 'مفتوح — بانتظار العروض';
      case RequestStatus.shopSelected: return 'تم اختيار المتجر';
      case RequestStatus.inProgress:   return 'قيد التنفيذ';
      case RequestStatus.completed:    return 'مكتمل';
      case RequestStatus.cancelled:    return 'ملغي';
      case RequestStatus.expired:      return 'منتهي الصلاحية';
    }
  }

  String get colorType {
    switch (this) {
      case RequestStatus.completed:    return 'green';
      case RequestStatus.cancelled:
      case RequestStatus.expired:      return 'red';
      case RequestStatus.inProgress:   return 'blue';
      default:                         return 'gold';
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
  final List<AcceptedShopSummary> acceptedShops;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'open';
    final RequestStatus status;
    switch (statusStr) {
      case 'shopselected': status = RequestStatus.shopSelected; break;
      case 'inprogress':   status = RequestStatus.inProgress;   break;
      case 'completed':    status = RequestStatus.completed;     break;
      case 'cancelled':    status = RequestStatus.cancelled;     break;
      case 'expired':      status = RequestStatus.expired;       break;
      default:             status = RequestStatus.open;
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
    final rawAccepted = json['acceptedShops'] as List<dynamic>?;
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
      acceptedShops: rawAccepted
          ?.map((e) => AcceptedShopSummary.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
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
    this.acceptedShops = const [],
  });
}
