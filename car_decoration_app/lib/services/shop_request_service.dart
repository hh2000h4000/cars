import '../models/shop_request.dart';
import '../models/paged_result.dart';
import 'api_client.dart';

class ShopRequestService {
  static Future<PagedResult<ShopRequest>> getShopRequests({int page = 1, int pageSize = 20}) async {
    final res = await ApiClient.dio.get('/api/requests/shop', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(
      res.data as Map<String, dynamic>,
      ShopRequest.fromJson,
    );
  }

  static Future<String> acceptRequest(String requestId) async {
    final res = await ApiClient.dio.put('/api/requests/$requestId/accept');
    final data = res.data as Map<String, dynamic>;
    return data['chatRoomId'] as String? ?? '';
  }

  static Future<void> startWork(String requestId) async {
    await ApiClient.dio.put('/api/requests/$requestId/start');
  }

  static Future<void> completeRequest(String requestId) async {
    await ApiClient.dio.put('/api/requests/$requestId/complete');
  }
}
