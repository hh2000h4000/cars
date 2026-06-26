import 'api_client.dart';

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
}
