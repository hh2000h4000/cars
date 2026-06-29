import '../models/quotation.dart';
import 'api_client.dart';

class QuotationService {
  static Future<List<Quotation>> getQuotations(String requestId) async {
    final res = await ApiClient.dio.get('/api/quotations/request/$requestId');
    final list = res.data as List<dynamic>;
    return list.map((e) => Quotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<String> acceptQuotation(String quotationId) async {
    final res = await ApiClient.dio.put('/api/quotations/$quotationId/accept');
    return res.data['chatRoomId'] as String;
  }

  static Future<Quotation> updateQuotation(String quotationId, {
    required double finalPrice,
    required String duration,
    required String serviceDetails,
    required String parts,
    double visitFee = 0,
    String? warranty,
  }) async {
    final res = await ApiClient.dio.put('/api/quotations/$quotationId', data: {
      'serviceDetails': serviceDetails,
      'parts': parts,
      'visitFee': visitFee,
      'duration': duration,
      'finalPrice': finalPrice,
      if (warranty != null && warranty.isNotEmpty) 'warranty': warranty,
    });
    return Quotation.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<Quotation?> getMyQuotation(String requestId) async {
    try {
      final res = await ApiClient.dio.get('/api/quotations/my/$requestId');
      if (res.statusCode == 204 || res.data == null) return null;
      return Quotation.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
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
