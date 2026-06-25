import '../models/dispute.dart';
import 'api_client.dart';

class DisputeAdminService {
  static Future<List<Dispute>> getAllDisputes() async {
    final res = await ApiClient.dio.get('/api/disputes');
    final list = res.data as List<dynamic>;
    return list.map((e) => Dispute.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> updateStatus(String disputeId, DisputeStatus status) async {
    await ApiClient.dio.put(
      '/api/disputes/$disputeId/status',
      data: {'status': status.apiValue},
    );
  }
}
