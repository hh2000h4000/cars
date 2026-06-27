import '../models/paged_result.dart';
import 'api_client.dart';

class ReviewItem {
  final String id;
  final String customerName;
  final double averageRating;
  final int qualityRating;
  final int communicationRating;
  final int commitmentRating;
  final int generalRating;
  final String? comment;
  final DateTime createdAt;

  const ReviewItem({
    required this.id,
    required this.customerName,
    required this.averageRating,
    required this.qualityRating,
    required this.communicationRating,
    required this.commitmentRating,
    required this.generalRating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        id: j['id'] as String? ?? '',
        customerName: j['customerName'] as String? ?? 'عميل',
        averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        qualityRating: j['qualityRating'] as int? ?? 0,
        communicationRating: j['communicationRating'] as int? ?? 0,
        commitmentRating: j['commitmentRating'] as int? ?? 0,
        generalRating: j['generalRating'] as int? ?? 0,
        comment: j['comment'] as String?,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class ReviewService {
  static Future<void> createReview({
    required String requestId,
    required int qualityRating,
    required int communicationRating,
    required int commitmentRating,
    required int generalRating,
    String? comment,
  }) async {
    await ApiClient.dio.post('/api/reviews', data: {
      'requestId': requestId,
      'qualityRating': qualityRating,
      'communicationRating': communicationRating,
      'commitmentRating': commitmentRating,
      'generalRating': generalRating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }

  static Future<PagedResult<ReviewItem>> getShopReviews(
    String shopId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/reviews/shop/$shopId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res.data as Map<String, dynamic>,
      ReviewItem.fromJson,
    );
  }

  static Future<PagedResult<ReviewItem>> getMyShopReviews({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await ApiClient.dio.get(
      '/api/reviews/my-shop',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res.data as Map<String, dynamic>,
      ReviewItem.fromJson,
    );
  }

  static Future<bool> hasReviewed(String requestId) async {
    final res = await ApiClient.dio.get('/api/reviews/request/$requestId');
    return (res.data as Map<String, dynamic>)['hasReviewed'] as bool? ?? false;
  }
}
