import '../models/pending_shop.dart';
import 'api_client.dart';

class ShopAdminService {
  static Future<List<PendingShop>> getPendingShops() async {
    final res = await ApiClient.dio.get('/api/shops/pending');
    final list = res.data as List<dynamic>;
    return list.map((e) => PendingShop.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> approveShop(String id) async {
    await ApiClient.dio.put('/api/shops/$id/approve');
  }

  static Future<void> rejectShop(String id) async {
    await ApiClient.dio.put('/api/shops/$id/reject');
  }
}
