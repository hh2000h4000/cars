import '../models/pending_shop.dart';
import 'api_client.dart';

class ShopAdminService {
  static Future<List<PendingShop>> getAllShops({String? status, String? search}) async {
    final params = <String, dynamic>{'pageSize': 200};
    if (status != null && status != 'all') params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await ApiClient.dio.get('/api/shops/admin/all', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((e) => PendingShop.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> approveShop(String id) async {
    await ApiClient.dio.put('/api/shops/$id/approve');
  }

  static Future<void> rejectShop(String id, String reason) async {
    await ApiClient.dio.put('/api/shops/$id/reject', data: {'reason': reason});
  }

  static Future<void> suspendShop(String id) async {
    await ApiClient.dio.put('/api/shops/$id/suspend');
  }
}
