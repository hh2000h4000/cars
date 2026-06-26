import '../models/shop_request.dart';
import 'api_client.dart';

class ShopRequestService {
  static Future<List<ShopRequest>> getShopRequests() async {
    final res = await ApiClient.dio.get('/api/requests/shop');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => ShopRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<String> acceptRequest(String requestId) async {
    final res = await ApiClient.dio.put('/api/requests/$requestId/accept');
    final data = res.data as Map<String, dynamic>;
    return data['chatRoomId'] as String? ?? '';
  }
}
