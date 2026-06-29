enum ShopRequestShopStatus { pending, accepted, rejected, withdrawn }

class ShopRequest {
  final String id;
  final String customerName;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final String description;
  final String location;
  final DateTime? appointmentDate;
  final String status;
  final ShopRequestShopStatus shopStatus;
  final String? chatRoomId;
  final DateTime createdAt;
  final String? quotationStatus;

  const ShopRequest({
    required this.id,
    required this.customerName,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.description,
    required this.location,
    this.appointmentDate,
    required this.status,
    required this.shopStatus,
    this.chatRoomId,
    required this.createdAt,
    this.quotationStatus,
  });

  String get mono => customerName.isNotEmpty ? customerName[0] : '؟';
  String get vehicleInfo => '$vehicleBrand $vehicleModel $vehicleYear';

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} يوم';
  }

  String get appointmentLabel {
    if (appointmentDate == null) return 'غير محدد';
    final d = appointmentDate!.toLocal();
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final hour = d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour;
    final ampm = d.hour >= 12 ? 'م' : 'ص';
    return '${d.day} ${months[d.month - 1]} · $hour:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  factory ShopRequest.fromJson(Map<String, dynamic> json) {
    final shopStatusStr = json['shopStatus'] as String? ?? 'Pending';
    final shopStatus = shopStatusStr == 'Accepted'
        ? ShopRequestShopStatus.accepted
        : shopStatusStr == 'Rejected'
            ? ShopRequestShopStatus.rejected
            : shopStatusStr == 'Withdrawn'
                ? ShopRequestShopStatus.withdrawn
                : ShopRequestShopStatus.pending;

    return ShopRequest(
      id: (json['id'] as String?) ?? '',
      customerName: json['customerName'] as String? ?? '',
      vehicleBrand: json['vehicleBrand'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleYear: json['vehicleYear'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.tryParse(json['appointmentDate'] as String)
          : null,
      status: json['status'] as String? ?? 'Pending',
      shopStatus: shopStatus,
      chatRoomId: json['chatRoomId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      quotationStatus: json['quotationStatus'] as String?,
    );
  }
}
