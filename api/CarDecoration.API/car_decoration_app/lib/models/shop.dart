class ShopServiceItem {
  final String name;
  final int price;
  final String duration;
  final String? description;

  const ShopServiceItem({required this.name, required this.price, required this.duration, this.description});
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
  final List<ShopServiceItem> services;
  final List<String> gallery;
  final bool verified;
  final List<ShopReview> reviews;
  final String? profileImageUrl;

  factory Shop.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return Shop(
      id: json['id'] as String,
      name: name,
      mono: name.isNotEmpty ? name[0] : '؟',
      area: json['area'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['area'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: 0,
      completedJobs: json['completedJobs'] as int? ?? 0,
      distance: '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      services: [],
      gallery: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      verified: json['isApproved'] as bool? ?? false,
      reviews: [],
      profileImageUrl: json['logoUrl'] as String?,
    );
  }

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
    required this.services, // List<ShopServiceItem>
    required this.gallery,
    required this.verified,
    required this.reviews,
    this.profileImageUrl,
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
