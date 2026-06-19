enum QuotationStatus { pending, accepted, rejected }

class Quotation {
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
