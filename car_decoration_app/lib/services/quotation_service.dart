import '../models/quotation.dart';
import 'api_client.dart';

class QuotationService {
  static Future<List<Quotation>> getQuotations(String requestId) async {
    final res = await ApiClient.dio.get('/api/quotations/request/$requestId');
    final list = res.data as List<dynamic>;
    return list.map((e) => Quotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> acceptQuotation(String quotationId) async {
    await ApiClient.dio.put('/api/quotations/$quotationId/accept');
  }

  static Future<void> sendQuote({
    required String requestId,
    required double finalPrice,
    required String duration,
    required String serviceDetails,
    required String parts,
    double visitFee = 0,
    String? warranty,
  }) async {
    await ApiClient.dio.post('/api/quotations', data: {
      'requestId': requestId,
      'serviceDetails': serviceDetails,
      'parts': parts,
      'visitFee': visitFee,
      'duration': duration,
      'finalPrice': finalPrice,
      if (warranty != null && warranty.isNotEmpty) 'warranty': warranty,
    });
  }
}
