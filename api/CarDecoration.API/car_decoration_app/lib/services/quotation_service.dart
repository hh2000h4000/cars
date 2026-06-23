import '../models/quotation.dart';
import 'api_client.dart';

class QuotationService {
  static Future<List<Quotation>> getQuotations(String requestId) async {
    final res = await ApiClient.dio.get('/api/requests/$requestId/quotations');
    final list = res.data as List<dynamic>;
    return list.map((e) => Quotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> acceptQuotation(String quotationId) async {
    await ApiClient.dio.post('/api/quotations/$quotationId/accept');
  }

  static Future<void> sendQuote({
    required String requestId,
    required int price,
    required String executionTime,
    String? warranty,
    String? description,
  }) async {
    await ApiClient.dio.post('/api/requests/$requestId/quotations', data: {
      'price': price,
      'executionTime': executionTime,
      if (warranty != null) 'warranty': warranty,
      if (description != null) 'description': description,
    });
  }
}
