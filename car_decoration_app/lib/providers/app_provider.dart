import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/app_logger.dart';
import '../models/models.dart';
import '../services/vehicle_service.dart';
import '../services/shop_service.dart';
import '../services/request_service.dart';
import '../services/upload_service.dart';

enum UserType { customer, shop, admin }

class AppProvider extends ChangeNotifier {
  // Auth state
  UserType userType = UserType.customer;

  // Customer state
  List<Vehicle> vehicles = [];
  List<Shop> shops = [];
  List<ServiceRequest> requests = [];
  List<Quotation> quotations = [];
  String? acceptedQuoteId;
  List<String> selectedShops = [];
  ReviewData reviewData = ReviewData();
  String selectedComplaintReason = '';

  // Chat state
  List<ChatMessage> messages = [];

  // Shop state
  bool sentQuote = false;
  List<ShopInboxItem> shopInbox = [];

  // Admin state
  List<PendingShop> pendingShops = [];
  List<Dispute> disputes = [];

  // ─── Shop selection ───────────────────────────────────────────
  bool isShopSelected(String shopId) => selectedShops.contains(shopId);

  void toggleShop(String shopId) {
    if (selectedShops.contains(shopId)) {
      selectedShops = selectedShops.where((id) => id != shopId).toList();
    } else {
      selectedShops = [...selectedShops, shopId];
    }
    notifyListeners();
  }

  void selectAllShops() {
    selectedShops = shops.map((s) => s.id).toList();
    notifyListeners();
  }

  // ─── Quotation acceptance ─────────────────────────────────────
  void acceptQuote(String quoteId) {
    acceptedQuoteId = quoteId;
    for (final q in quotations) {
      if (q.id == quoteId) {
        q.status = QuotationStatus.accepted;
      } else {
        q.status = QuotationStatus.rejected;
      }
    }
    // Update request status
    requests = requests.map<ServiceRequest>((r) {
      if (r.id == '1042') {
        return ServiceRequest(
          id: r.id,
          requestNumber: r.requestNumber,
          serviceType: r.serviceType,
          vehicleBrand: r.vehicleBrand,
          vehicleModel: r.vehicleModel,
          vehicleYear: r.vehicleYear,
          vehicleColor: r.vehicleColor,
          status: RequestStatus.shopSelected,
          dateLabel: r.dateLabel,
          quotationCount: r.quotationCount,
          notes: r.notes,
          selectedShopName: quotations.firstWhere((q) => q.id == quoteId).shopName,
        );
      }
      return r;
    }).toList();
    notifyListeners();
  }

  Quotation? get acceptedQuotation =>
      acceptedQuoteId != null ? quotations.firstWhere((q) => q.id == acceptedQuoteId) : null;

  // ─── Review ──────────────────────────────────────────────────
  void setReviewRating(String dimension, int value) {
    switch (dimension) {
      case 'quality': reviewData.quality = value; break;
      case 'communication': reviewData.communication = value; break;
      case 'timeliness': reviewData.timeliness = value; break;
      case 'overall': reviewData.overall = value; break;
    }
    notifyListeners();
  }

  // ─── Complaint ───────────────────────────────────────────────
  void selectComplaintReason(String reason) {
    selectedComplaintReason = reason;
    notifyListeners();
  }

  // ─── Chat ────────────────────────────────────────────────────
  void sendMessage(String text) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    messages = [
      ...messages,
      ChatMessage(id: id, isMe: true, text: text, time: 'الآن'),
    ];
    notifyListeners();

    // Auto-reply
    Future.delayed(const Duration(milliseconds: 1100), () {
      messages = [
        ...messages,
        ChatMessage(id: '${id}_r', isMe: false, text: 'تمام، تم تسجيل ملاحظتك. سنحدّث عرض السعر فوراً.', time: 'الآن'),
      ];
      notifyListeners();
    });
  }

  void sendImageMessage() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    messages = [
      ...messages,
      ChatMessage(id: id, isMe: true, text: 'صورة مرفقة', time: 'الآن', hasImage: true),
    ];
    notifyListeners();
  }

  // ─── Shop Quote ──────────────────────────────────────────────
  void submitQuote() {
    sentQuote = true;
    notifyListeners();
  }

  void resetSentQuote() {
    sentQuote = false;
    notifyListeners();
  }

  // ─── Vehicle ─────────────────────────────────────────────────
  void addVehicle(Vehicle v) {
    vehicles = [...vehicles, v];
    notifyListeners();
  }

  void removeVehicle(String id) {
    vehicles = vehicles.where((v) => v.id != id).toList();
    notifyListeners();
  }

  void updateVehicle(Vehicle updated) {
    vehicles = vehicles.map((v) => v.id == updated.id ? updated : v).toList();
    notifyListeners();
  }

  Future<Vehicle> addVehicleFromApi({
    required String brand,
    required String model,
    required int year,
    required String color,
    String? plateNumber,
    List<Uint8List>? imageBytes,
  }) async {
    final imageUrls = imageBytes != null && imageBytes.isNotEmpty
        ? await UploadService.uploadImages(imageBytes)
        : null;
    final v = await VehicleService.addVehicle(
      brand: brand, model: model, year: year, color: color,
      plateNumber: plateNumber, imageUrls: imageUrls,
    );
    vehicles = [...vehicles, v];
    notifyListeners();
    return v;
  }

  void updateRequest(ServiceRequest updated) {
    requests = requests.map((r) => r.id == updated.id ? updated : r).toList();
    notifyListeners();
  }

  // ─── Request ──────────────────────────────────────────────────
  Future<ServiceRequest> addRequestFromApi({
    required String vehicleId,
    required String description,
    required String location,
    required List<String> shopIds,
    String? notes,
    DateTime? preferredDate,
    TimeOfDay? preferredTime,
    List<Uint8List>? imageBytes,
  }) async {
    final imageUrls = imageBytes != null && imageBytes.isNotEmpty
        ? await UploadService.uploadImages(imageBytes)
        : null;
    final r = await RequestService.createRequest(
      vehicleId: vehicleId,
      description: description,
      location: location,
      shopIds: shopIds,
      notes: notes,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      imageUrls: imageUrls,
    );
    requests = [...requests, r];
    notifyListeners();
    return r;
  }

  // ─── API bootstrap ────────────────────────────────────────────
  bool initLoading = false;
  String? initError;

  Future<void> initFromApi() async {
    initLoading = true;
    initError = null;
    notifyListeners();

    final errors = <String>[];

    await Future.wait([
      VehicleService.getMyVehicles()
          .then((v) => vehicles = v)
          .catchError((Object e) { AppLogger.error('initFromApi: vehicles', error: e); errors.add('سيارات: $e'); return <Vehicle>[]; }),
      ShopService.getShops()
          .then((s) => shops = s)
          .catchError((Object e) { AppLogger.error('initFromApi: shops', error: e); return <Shop>[]; }),
      RequestService.getMyRequests()
          .then((r) => requests = r)
          .catchError((Object e) { AppLogger.error('initFromApi: requests', error: e); errors.add('طلبات: $e'); return <ServiceRequest>[]; }),
    ]);

    initLoading = false;
    if (errors.isNotEmpty) initError = errors.first;
    notifyListeners();
  }
}
