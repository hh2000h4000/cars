class ShopService {
  final String name;
  final int price;
  final String duration;
  final String? description;

  const ShopService({required this.name, required this.price, required this.duration, this.description});
}

class Shop {
  final String id;
  final String name;
  final String mono;
  final String area;
  final String city;
  final String address;
  final String description;
  final double rating;
  final int reviewCount;
  final int completedJobs;
  final String distance;
  final List<String> tags;
  final List<ShopService> services;
  final List<String> gallery;
  final bool verified;
  final List<ShopReview> reviews;

  const Shop({
    required this.id,
    required this.name,
    required this.mono,
    required this.area,
    required this.city,
    required this.address,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
    required this.distance,
    required this.tags,
    required this.services,
    required this.gallery,
    required this.verified,
    required this.reviews,
  });
}

class ShopReview {
  final String author;
  final String mono;
  final double rating;
  final String comment;
  final String date;

  const ShopReview({
    required this.author,
    required this.mono,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ShopInboxItem {
  final String requestId;
  final String customerName;
  final String mono;
  final String serviceType;
  final String vehicleInfo;
  final String distance;
  final String timeAgo;
  final String area;
  final String urgency;

  const ShopInboxItem({
    required this.requestId,
    required this.customerName,
    required this.mono,
    required this.serviceType,
    required this.vehicleInfo,
    required this.distance,
    required this.timeAgo,
    required this.area,
    this.urgency = 'normal',
  });
}
