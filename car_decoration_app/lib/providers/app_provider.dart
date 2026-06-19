import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

enum UserType { customer, shop, admin }

class AppProvider extends ChangeNotifier {
  // Auth state
  UserType userType = UserType.customer;

  // Customer state
  List<Vehicle> vehicles = List.from(MockData.vehicles);
  List<ServiceRequest> requests = List.from(MockData.requests);
  List<Quotation> quotations = MockData.quotations;
  String? acceptedQuoteId;
  List<String> selectedShops = ['sh1', 'sh5'];
  ReviewData reviewData = ReviewData();
  String selectedComplaintReason = '';

  // Chat state
  List<ChatMessage> messages = List.from(MockData.initialMessages);

  // Shop state
  bool sentQuote = false;
  List<ShopInboxItem> shopInbox = List.from(MockData.shopInbox);

  // Admin state
  List<PendingShop> pendingShops = MockData.pendingShops;
  List<Dispute> disputes = List.from(MockData.disputes);

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
    selectedShops = MockData.shops.map((s) => s.id).toList();
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
    requests = requests.map((r) {
      if (r.id == '1042') {
        return ServiceRequest(
          id: r.id,
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

  // ─── Admin ───────────────────────────────────────────────────
  void approveShop(String shopId) {
    for (final s in pendingShops) {
      if (s.id == shopId) s.status = AdminShopStatus.approved;
    }
    notifyListeners();
  }

  void rejectShop(String shopId) {
    for (final s in pendingShops) {
      if (s.id == shopId) s.status = AdminShopStatus.rejected;
    }
    notifyListeners();
  }

  void requestDocsFromShop(String shopId) {
    for (final s in pendingShops) {
      if (s.id == shopId) s.status = AdminShopStatus.docsRequested;
    }
    notifyListeners();
  }

  // ─── Vehicle ─────────────────────────────────────────────────
  void addVehicle(Vehicle v) {
    vehicles = [...vehicles, v];
    notifyListeners();
  }
}
