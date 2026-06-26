enum QuotationStatus { pending, accepted, rejected }

class Quotation {
  final String id;
  final String shopId;
  final String shopName;
  final String shopMono;
  final double shopRating;
  final double finalPrice;
  final String visitFee;
  final String warranty;
  final String duration;
  final String serviceDetails;
  final List<String> parts;
  final bool isBestValue;
  final String? chatRoomId;
  QuotationStatus status;

  Quotation({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopMono,
    required this.shopRating,
    required this.finalPrice,
    required this.visitFee,
    required this.warranty,
    required this.duration,
    required this.serviceDetails,
    required this.parts,
    this.isBestValue = false,
    this.status = QuotationStatus.pending,
    this.chatRoomId,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    final shopName = json['shopName'] as String? ?? 'متجر';
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'pending';
    final QuotationStatus status;
    switch (statusStr) {
      case 'accepted': status = QuotationStatus.accepted; break;
      case 'rejected': status = QuotationStatus.rejected; break;
      default: status = QuotationStatus.pending;
    }
    final visitFeeVal = (json['visitFee'] as num?)?.toDouble() ?? 0;
    final partsRaw = json['parts'] as String? ?? '';
    return Quotation(
      id: json['id'] as String,
      shopId: json['shopId'] as String? ?? '',
      shopName: shopName,
      shopMono: shopName.isNotEmpty ? shopName[0] : 'م',
      shopRating: 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      visitFee: visitFeeVal == 0 ? 'مجاناً' : '${visitFeeVal.toStringAsFixed(0)} ريال',
      warranty: json['warranty'] as String? ?? 'لا يوجد',
      duration: json['duration'] as String? ?? 'غير محدد',
      serviceDetails: json['serviceDetails'] as String? ?? '',
      parts: partsRaw.isNotEmpty ? partsRaw.split(',').map((e) => e.trim()).toList() : [],
      status: status,
      chatRoomId: json['chatRoomId'] as String?,
    );
  }
}
