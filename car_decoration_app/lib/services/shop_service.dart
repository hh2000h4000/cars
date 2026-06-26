import '../models/shop.dart';
import '../models/paged_result.dart';
import 'api_client.dart';

class ShopService {
  static Future<PagedResult<Shop>> getShops({int page = 1, int pageSize = 20}) async {
    final res = await ApiClient.dio.get('/api/shops', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(
      res.data as Map<String, dynamic>,
      Shop.fromJson,
    );
  }

  static Future<Shop> getShopById(String id) async {
    final res = await ApiClient.dio.get('/api/shops/$id');
    return Shop.fromJson(res.data as Map<String, dynamic>);
  }
}
