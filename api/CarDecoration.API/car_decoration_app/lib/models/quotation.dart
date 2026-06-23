enum QuotationStatus { pending, accepted, rejected }

class Quotation {
  factory Quotation.fromJson(Map<String, dynamic> json) {
    final shop = json['shop'] as Map<String, dynamic>?;
    final shopName = shop?['name'] as String? ?? 'متجر';
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'pending';
    final QuotationStatus status;
    switch (statusStr) {
      case 'accepted': status = QuotationStatus.accepted; break;
      case 'rejected': status = QuotationStatus.rejected; break;
      default: status = QuotationStatus.pending;
    }
    return Quotation(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      shopName: shopName,
      shopMono: shopName.isNotEmpty ? shopName[0] : 'م',
      shopRating: (shop?['rating'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      visitFee: 'مجاناً',
      warranty: json['warranty'] as String? ?? 'لا يوجد',
      executionTime: json['executionTime'] as String? ?? 'غير محدد',
      serviceDetails: json['description'] as String? ?? '',
      parts: [],
      status: status,
    );
  }

// keep existing class body below
  final String id;
  final String shopId;
  final String shopName;
  final String shopMono;
  final double shopRating;
  final int price;
  final String visitFee;
  final String warranty;
  final String executionTime;
  final String serviceDetails;
  final List<String> parts;
  final bool isBestValue;
  QuotationStatus status;

  Quotation({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopMono,
    required this.shopRating,
    required this.price,
    required this.visitFee,
    required this.warranty,
    required this.executionTime,
    required this.serviceDetails,
    required this.parts,
    this.isBestValue = false,
    this.status = QuotationStatus.pending,
  });
}
