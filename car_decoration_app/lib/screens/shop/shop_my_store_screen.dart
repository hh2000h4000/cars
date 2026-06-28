import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../theme.dart';
import '../../services/shop_profile_service.dart';
import '../../services/review_service.dart';
import '../../services/upload_service.dart';
import '../../services/api_client.dart';
import '../../models/paged_result.dart';
import '../../app_navigator.dart';
import '../../services/signalr_service.dart';
import 'location_picker_screen.dart';
import 'shop_resubmit_screen.dart';

class ShopMyStoreScreen extends StatefulWidget {
  const ShopMyStoreScreen({super.key});

  @override
  State<ShopMyStoreScreen> createState() => _ShopMyStoreScreenState();
}

class _ShopMyStoreScreenState extends State<ShopMyStoreScreen> with WidgetsBindingObserver {
  ShopProfile? _shop;
  bool _loading = true;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _shopStatusSub;

  PagedResult<ReviewItem>? _reviewsResult;
  bool _reviewsLoading = true;
  bool _loadingMoreReviews = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shopStatusSub = SignalRService.instance.onShopStatusChanged.listen((_) => _load());
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shopStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final shop = await ShopProfileService.getMyShop();
      if (mounted) {
        setState(() { _shop = shop; _loading = false; });
        _loadReviews();
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'تعذر تحميل بيانات المتجر'; _loading = false; });
    }
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (loadMore && (_reviewsResult?.hasNextPage != true || _loadingMoreReviews)) return;

    if (loadMore) {
      setState(() => _loadingMoreReviews = true);
    } else {
      setState(() => _reviewsLoading = true);
    }

    try {
      final nextPage = loadMore ? (_reviewsResult?.page ?? 0) + 1 : 1;
      final result = await ReviewService.getMyShopReviews(page: nextPage);
      if (!mounted) return;
      setState(() {
        if (loadMore && _reviewsResult != null) {
          _reviewsResult = PagedResult(
            items: [..._reviewsResult!.items, ...result.items],
            totalCount: result.totalCount,
            page: result.page,
            pageSize: result.pageSize,
            totalPages: result.totalPages,
            hasNextPage: result.hasNextPage,
          );
        } else {
          _reviewsResult = result;
        }
        _reviewsLoading = false;
        _loadingMoreReviews = false;
      });
    } catch (_) {
      if (mounted) setState(() { _reviewsLoading = false; _loadingMoreReviews = false; });
    }
  }

  void _openEditSheet() {
    if (_shop == null) return;
    showModalBottomSheet<ShopProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheetContent(shop: _shop!),
    ).then((updated) {
      if (updated != null && mounted) {
        setState(() => _shop = updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تحديث الملف الشخصي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    });
  }

  void _openResubmitSheet() {
    if (_shop == null) return;
    Navigator.push<ShopProfile>(
      context,
      MaterialPageRoute(builder: (_) => ShopResubmitScreen(shop: _shop!)),
    ).then((updated) {
      if (updated != null && mounted) {
        setState(() => _shop = updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إرسال طلبك للمراجعة ✓', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900)),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(fontFamily: 'Tajawal')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ApiClient.clearUserData();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/auth/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.goldText)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText)),
              ),
            ],
          ),
        ),
      );
    }

    final shop = _shop!;
    final mono = shop.name.isNotEmpty ? shop.name[0] : 'م';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.goldText,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dark header ──────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B1A14), Color(0xFF2E2917)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        child: Column(
                          children: [
                            // Logo
                            _LogoAvatar(logoUrl: shop.logoUrl, mono: mono),
                            const SizedBox(height: 14),
                            // Name
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontFamily: 'Tajawal', fontSize: 20,
                                fontWeight: FontWeight.w900, color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Status badge
                            _StatusBadge(status: shop.status),
                            const SizedBox(height: 20),
                            // Stats row
                            Row(
                              children: [
                                _StatBox(
                                  value: shop.rating > 0 ? shop.rating.toStringAsFixed(1) : '—',
                                  label: 'التقييم',
                                  icon: Icons.star_rounded,
                                  iconColor: AppColors.star,
                                ),
                                const SizedBox(width: 10),
                                _StatBox(
                                  value: (_reviewsResult?.totalCount ?? 0).toString(),
                                  label: 'تقييمات',
                                  icon: Icons.reviews_outlined,
                                  iconColor: AppColors.goldText,
                                ),
                                const SizedBox(width: 10),
                                _StatBox(
                                  value: shop.totalJobs.toString(),
                                  label: 'أعمال',
                                  icon: Icons.check_circle_outline_rounded,
                                  iconColor: AppColors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Rejection / DocsRequested banner ─────────────────
              if (shop.status.toLowerCase() == 'rejected') ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _RejectionBanner(
                    reason: shop.rejectionReason,
                    onResubmit: _openResubmitSheet,
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (shop.status.toLowerCase() == 'docsrequested') ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _DocsRequestedBanner(onResubmit: _openResubmitSheet),
                ),
                const SizedBox(height: 20),
              ],

              // ── معلومات المتجر ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات المتجر',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(icon: Icons.phone_outlined, label: 'الهاتف', value: shop.phone),
                          _Divider(),
                          _InfoRow(icon: Icons.location_city_outlined, label: 'المدينة', value: shop.city),
                          if (shop.district.isNotEmpty) ...[
                            _Divider(),
                            _InfoRow(icon: Icons.holiday_village_outlined, label: 'الحي', value: shop.district),
                          ],
                          if (shop.street.isNotEmpty) ...[
                            _Divider(),
                            _InfoRow(icon: Icons.signpost_outlined, label: 'الشارع', value: shop.street),
                          ],
                          if (shop.postalCode.isNotEmpty) ...[
                            _Divider(),
                            _InfoRow(icon: Icons.markunread_mailbox_outlined, label: 'الرمز البريدي', value: shop.postalCode),
                          ],
                          _Divider(),
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'رقم السجل التجاري',
                            value: shop.crNumber,
                            locked: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Reviews section ──
                    _ReviewsSection(
                      reviewsResult: _reviewsResult,
                      loading: _reviewsLoading,
                      loadingMore: _loadingMoreReviews,
                      onLoadMore: () => _loadReviews(loadMore: true),
                    ),

                    const SizedBox(height: 24),

                    // ── Edit button ──
                    _ActionButton(
                      label: 'تعديل الملف الشخصي',
                      icon: Icons.edit_outlined,
                      onTap: _openEditSheet,
                      dark: true,
                    ),

                    const SizedBox(height: 12),

                    // ── Logout button ──
                    _ActionButton(
                      label: 'تسجيل الخروج',
                      icon: Icons.logout_rounded,
                      onTap: _logout,
                      dark: false,
                      textColor: AppColors.red,
                      borderColor: AppColors.redBorder,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Edit bottom sheet ─────────────────────────────────────────────────────────

class _EditSheetContent extends StatefulWidget {
  final ShopProfile shop;
  const _EditSheetContent({required this.shop});

  @override
  State<_EditSheetContent> createState() => _EditSheetContentState();
}

class _EditSheetContentState extends State<_EditSheetContent> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _street;
  late final TextEditingController _district;
  late final TextEditingController _postalCode;
  late final TextEditingController _buildingNumber;
  late final TextEditingController _additionalNum;
  LatLng? _location;
  String? _logoUrl;
  bool _uploadingLogo = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.shop.name);
    _phone = TextEditingController(text: widget.shop.phone);
    _city = TextEditingController(text: widget.shop.city);
    _street = TextEditingController(text: widget.shop.street);
    _district = TextEditingController(text: widget.shop.district);
    _postalCode = TextEditingController(text: widget.shop.postalCode);
    _buildingNumber = TextEditingController(text: widget.shop.buildingNumber ?? '');
    _additionalNum = TextEditingController(text: widget.shop.additionalNumber ?? '');
    _logoUrl = widget.shop.logoUrl;
    if (widget.shop.latitude != null && widget.shop.longitude != null) {
      _location = LatLng(widget.shop.latitude!, widget.shop.longitude!);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _street.dispose();
    _district.dispose();
    _postalCode.dispose();
    _buildingNumber.dispose();
    _additionalNum.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: _location)),
    );
    if (result != null && mounted) setState(() => _location = result);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final source = await _askImageSource();
    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingLogo = true);
    try {
      final bytes = await picked.readAsBytes();
      final urls = await UploadService.uploadImages([bytes]);
      if (mounted && urls.isNotEmpty) setState(() => _logoUrl = urls.first);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل رفع الشعار', style: TextStyle(fontFamily: 'Tajawal'))),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<ImageSource?> _askImageSource() async {
    if (kIsWeb) return ImageSource.gallery;
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.textPrimary),
              title: const Text('الكاميرا', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.textPrimary),
              title: const Text('معرض الصور', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final city = _city.text.trim();
    final street = _street.text.trim();
    final district = _district.text.trim();
    final postalCode = _postalCode.text.trim();

    if (name.isEmpty || phone.isEmpty || city.isEmpty || street.isEmpty || district.isEmpty || postalCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة', style: TextStyle(fontFamily: 'Tajawal')), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await ShopProfileService.updateMyShop(
        name: name,
        phone: phone,
        city: city,
        street: street,
        district: district,
        postalCode: postalCode,
        buildingNumber: _buildingNumber.text.trim().isEmpty ? null : _buildingNumber.text.trim(),
        additionalNumber: _additionalNum.text.trim().isEmpty ? null : _additionalNum.text.trim(),
        latitude: _location?.latitude,
        longitude: _location?.longitude,
        logoUrl: _logoUrl,
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Tajawal')),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mono = _name.text.isNotEmpty ? _name.text[0] : 'م';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تعديل الملف الشخصي',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),

              // Logo picker
              Center(
                child: GestureDetector(
                  onTap: _uploadingLogo ? null : _pickLogo,
                  child: Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.goldText.withOpacity(.3), width: 2),
                          image: _logoUrl != null
                              ? DecorationImage(image: NetworkImage(_logoUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _logoUrl == null
                            ? Center(
                                child: Text(
                                  mono,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.goldLight),
                                ),
                              )
                            : null,
                      ),
                      if (_uploadingLogo)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(22)),
                            child: const Center(child: CircularProgressIndicator(color: AppColors.goldLight, strokeWidth: 2)),
                          ),
                        )
                      else
                        Positioned(
                          bottom: 0, left: 0,
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.goldText,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('اضغط لتغيير الشعار', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: AppColors.textMuted)),
              ),

              const SizedBox(height: 20),

              _Field(label: 'اسم المتجر', controller: _name, icon: Icons.store_outlined),
              const SizedBox(height: 12),
              _Field(label: 'رقم الهاتف', controller: _phone, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _Field(label: 'المدينة *', controller: _city, icon: Icons.location_city_outlined),
              const SizedBox(height: 12),
              _Field(label: 'الشارع *', controller: _street, icon: Icons.signpost_outlined),
              const SizedBox(height: 12),
              _Field(label: 'الحي *', controller: _district, icon: Icons.holiday_village_outlined),
              const SizedBox(height: 12),
              _Field(label: 'الرمز البريدي *', controller: _postalCode, icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Field(label: 'رقم المبنى', controller: _buildingNumber, icon: Icons.apartment_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _Field(label: 'الرقم الإضافي', controller: _additionalNum, icon: Icons.add_location_alt_outlined, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),

              // Map picker
              GestureDetector(
                onTap: _pickLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: _location != null ? AppColors.green.withOpacity(.06) : AppColors.surface,
                    border: Border.all(
                      color: _location != null ? AppColors.green.withOpacity(.4) : AppColors.border,
                      width: _location != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _location != null
                      ? Row(children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            '${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.green),
                          )),
                          const Text('تغيير', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                        ])
                      : const Row(children: [
                          Icon(Icons.add_location_alt_outlined, color: AppColors.textMuted, size: 18),
                          SizedBox(width: 8),
                          Text('تحديد موقع المتجر على الخريطة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          Spacer(),
                          Icon(Icons.chevron_left, color: AppColors.textMuted, size: 16),
                        ]),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _saving ? AppColors.border : AppColors.dark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldLight))
                      : const Text('حفظ التغييرات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _LogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final String mono;
  const _LogoAvatar({this.logoUrl, required this.mono});

  @override
  Widget build(BuildContext context) => Container(
    width: 84, height: 84,
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.goldText.withOpacity(.4), width: 2),
      image: logoUrl != null
          ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
          : null,
    ),
    child: logoUrl == null
        ? Center(
            child: Text(
              mono,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.goldLight),
            ),
          )
        : null,
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg) = switch (status.toLowerCase()) {
      'approved'      => ('معتمد ✓', AppColors.green),
      'pending'       => ('قيد المراجعة', AppColors.goldText),
      'rejected'      => ('مرفوض', AppColors.red),
      'suspended'     => ('موقوف', const Color(0xFF9C27B0)),
      'docsrequested' => ('مطلوب مستندات', const Color(0xFF0288D1)),
      _               => ('غير معروف', Colors.white54),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: fg.withOpacity(.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _StatBox({required this.value, required this.label, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white54)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool locked;
  const _InfoRow({required this.icon, required this.label, required this.value, this.locked = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 17, color: AppColors.goldText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
        if (locked)
          const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textMuted),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.border, indent: 16, endIndent: 16);
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;
  final Color? textColor;
  final Color? borderColor;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.dark,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: dark ? AppColors.dark : Colors.white,
        border: dark ? null : Border.all(color: borderColor ?? AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: dark ? AppColors.goldLight : (textColor ?? AppColors.textPrimary)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800,
              color: dark ? AppColors.goldLight : (textColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _Field({required this.label, required this.controller, required this.icon, this.keyboardType, this.inputFormatters});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
        ),
      ),
    ],
  );
}

// ── Reviews Section ───────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  final PagedResult<ReviewItem>? reviewsResult;
  final bool loading;
  final bool loadingMore;
  final VoidCallback onLoadMore;

  const _ReviewsSection({
    required this.reviewsResult,
    required this.loading,
    required this.loadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final reviews = reviewsResult?.items ?? [];
    final totalCount = reviewsResult?.totalCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            const Text('تقييمات عملائي',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                child: Text('$totalCount',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.goldText, strokeWidth: 2),
            ),
          )
        else if (reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.star_border_rounded, color: AppColors.border, size: 32),
                SizedBox(height: 8),
                Text('لا توجد تقييمات بعد',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                SizedBox(height: 4),
                Text('ستظهر تقييمات العملاء هنا بعد إتمام الطلبات',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              ],
            ),
          )
        else ...[
          ...reviews.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ShopReviewCard(review: r),
          )),
          if (reviewsResult?.hasNextPage == true)
            GestureDetector(
              onTap: onLoadMore,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: loadingMore
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                    : const Text('عرض المزيد',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
              ),
            ),
        ],
      ],
    );
  }
}

class _ShopReviewCard extends StatelessWidget {
  final ReviewItem review;
  const _ShopReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final firstName = review.customerName.split(' ').first;
    final mono = firstName.isNotEmpty ? firstName[0] : 'ع';
    final avg = review.averageRating;
    final dateStr = _formatDate(review.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(mono, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.dark)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstName, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < avg.floor() ? Icons.star_rounded
                              : (i < avg ? Icons.star_half_rounded : Icons.star_border_rounded),
                          color: AppColors.star, size: 13,
                        )),
                        const SizedBox(width: 4),
                        Text(avg.toStringAsFixed(1),
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(dateStr, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment!,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(label: 'الجودة', value: review.qualityRating),
              const SizedBox(width: 6),
              _MiniStat(label: 'التواصل', value: review.communicationRating),
              const SizedBox(width: 6),
              _MiniStat(label: 'الالتزام', value: review.commitmentRating),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    return '${dt.year}/${dt.month}/${dt.day}';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.goldBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 11, color: AppColors.star),
        const SizedBox(width: 3),
        Text('$value', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldText)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    ),
  );
}

// ── Rejection Banner ─────────────────────────────────────────────────────────

class _RejectionBanner extends StatelessWidget {
  final String? reason;
  final VoidCallback onResubmit;
  const _RejectionBanner({this.reason, required this.onResubmit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.red.withOpacity(.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.red.withOpacity(.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.red.withOpacity(.12), borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.cancel_rounded, color: AppColors.red, size: 17),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('تم رفض طلب الاعتماد',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.red)),
            ),
          ],
        ),
        if (reason != null && reason!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('سبب الرفض:',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.red)),
                const SizedBox(height: 3),
                Text(reason!,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red, height: 1.5)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        const Text('يمكنك تصحيح البيانات والوثائق ثم إعادة التقديم للمراجعة.',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onResubmit,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, color: AppColors.goldLight, size: 16),
                SizedBox(width: 8),
                Text('تصحيح وإعادة التقديم',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _DocsRequestedBanner extends StatelessWidget {
  final VoidCallback onResubmit;
  const _DocsRequestedBanner({required this.onResubmit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0288D1).withOpacity(.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF0288D1).withOpacity(.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.folder_open_rounded, color: Color(0xFF0288D1), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text('مطلوب مستندات إضافية',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0288D1))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('طلب المشرف تحديث الوثائق المرفقة. يرجى رفع المستندات الصحيحة وإعادة التقديم.',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onResubmit,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('رفع المستندات وإعادة التقديم',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B96A).withOpacity(0.07)
      ..strokeWidth = 1.0;
    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = 0; i < count; i++) {
      final x = i * spacing - size.height;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * math.tan(math.pi / 4), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => false;
}
