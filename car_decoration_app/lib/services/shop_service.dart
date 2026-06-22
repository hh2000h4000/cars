import '../models/shop.dart';
import 'api_client.dart';

class ShopService {
  static Future<List<Shop>> getShops() async {
    final res = await ApiClient.dio.get('/api/shops');
    final list = res.data as List<dynamic>;
    return list.map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Shop> getShopById(String id) async {
    final res = await ApiClient.dio.get('/api/shops/$id');
    return Shop.fromJson(res.data as Map<String, dynamic>);
  }
}
