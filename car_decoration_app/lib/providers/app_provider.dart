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
  List<String> selectedShops = [];
  ReviewData reviewData = ReviewData();
  String selectedComplaintReason = '';

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

  // ─── Pagination state ─────────────────────────────────────────
  int _requestsPage = 1;
  bool _hasMoreRequests = false;
  bool loadingMoreRequests = false;

  int _shopsPage = 1;
  bool _hasMoreShops = false;
  bool loadingMoreShops = false;

  bool get hasMoreRequests => _hasMoreRequests;
  bool get hasMoreShops => _hasMoreShops;

  Future<void> loadMoreRequests() async {
    if (!_hasMoreRequests || loadingMoreRequests) return;
    loadingMoreRequests = true;
    notifyListeners();
    try {
      final r = await RequestService.getMyRequests(page: _requestsPage + 1);
      requests = [...requests, ...r.items];
      _requestsPage++;
      _hasMoreRequests = r.hasNextPage;
    } catch (_) {}
    loadingMoreRequests = false;
    notifyListeners();
  }

  Future<void> loadMoreShops() async {
    if (!_hasMoreShops || loadingMoreShops) return;
    loadingMoreShops = true;
    notifyListeners();
    try {
      final r = await ShopService.getShops(page: _shopsPage + 1);
      shops = [...shops, ...r.items];
      _shopsPage++;
      _hasMoreShops = r.hasNextPage;
    } catch (_) {}
    loadingMoreShops = false;
    notifyListeners();
  }

  Future<void> reloadRequests() async {
    try {
      final r = await RequestService.getMyRequests();
      requests = r.items;
      _requestsPage = 1;
      _hasMoreRequests = r.hasNextPage;
      notifyListeners();
    } catch (_) {}
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
          .then((r) { vehicles = r.items; })
          .catchError((Object e) { AppLogger.error('initFromApi: vehicles', error: e); errors.add('سيارات: $e'); }),
      ShopService.getShops()
          .then((r) { shops = r.items; _shopsPage = 1; _hasMoreShops = r.hasNextPage; })
          .catchError((Object e) { AppLogger.error('initFromApi: shops', error: e); }),
      RequestService.getMyRequests()
          .then((r) { requests = r.items; _requestsPage = 1; _hasMoreRequests = r.hasNextPage; })
          .catchError((Object e) { AppLogger.error('initFromApi: requests', error: e); errors.add('طلبات: $e'); }),
    ]);

    initLoading = false;
    if (errors.isNotEmpty) initError = errors.first;
    notifyListeners();
  }
}
