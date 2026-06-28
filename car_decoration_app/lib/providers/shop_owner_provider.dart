import 'package:flutter/foundation.dart';
import '../services/shop_profile_service.dart';

/// Single Source of Truth for shop owner profile data.
///
/// Scope: basic profile only (id, name, status, logo, rating, totalJobs, etc.)
/// NOT responsible for: requests, chats, reviews, or any other dynamic lists.
///
/// Public API:
///   load()                              — fetch /api/shops/my (called from ShopShell only)
///   applyStatusChange(status, reason)   — instant update from SignalR payload (zero API calls)
///   applyProfileUpdate(ShopProfile)     — replace profile after a successful edit/resubmit
///   clear()                             — reset on logout
class ShopOwnerProvider extends ChangeNotifier {
  ShopProfile? _shop;
  bool isLoading = false;
  String? error;

  ShopProfile? get shop => _shop;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _shop = await ShopProfileService.getMyShop();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  /// Called when a `ShopStatusChanged` SignalR event arrives.
  /// Updates status and rejectionReason directly from the event payload —
  /// no API call needed since all required fields come with the event.
  void applyStatusChange(String status, String? reason) {
    if (_shop == null) return;
    _shop = _shop!.copyWith(
      status: status,
      rejectionReason: reason,
    );
    notifyListeners();
  }

  /// Called after a successful profile edit or resubmit.
  /// The API response already contains the full updated profile.
  void applyProfileUpdate(ShopProfile updated) {
    _shop = updated;
    notifyListeners();
  }

  void clear() {
    _shop = null;
    isLoading = false;
    error = null;
    notifyListeners();
  }
}
