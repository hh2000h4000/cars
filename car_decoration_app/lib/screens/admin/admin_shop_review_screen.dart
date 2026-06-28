import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';
import '../../models/pending_shop.dart';
import '../../services/shop_admin_service.dart';
import '../../services/api_client.dart';

class AdminShopReviewScreen extends StatefulWidget {
  final PendingShop shop;
  const AdminShopReviewScreen({super.key, required this.shop});

  @override
  State<AdminShopReviewScreen> createState() => _AdminShopReviewScreenState();
}

class _AdminShopReviewScreenState extends State<AdminShopReviewScreen> {
  late AdminShopStatus _status;
  String? _rejectionReason;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.shop.status;
    _rejectionReason = widget.shop.rejectionReason;
  }

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await ShopAdminService.approveShop(widget.shop.id);
      if (!mounted) return;
      widget.shop.status = AdminShopStatus.approved;
      setState(() { _status = AdminShopStatus.approved; _rejectionReason = null; _loading = false; });
      _snack('تم اعتماد المتجر بنجاح');
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _snack(ApiClient.extractError(e), isError: true); }
    }
  }

  Future<void> _suspend() async {
    setState(() => _loading = true);
    try {
      await ShopAdminService.suspendShop(widget.shop.id);
      if (!mounted) return;
      widget.shop.status = AdminShopStatus.suspended;
      setState(() { _status = AdminShopStatus.suspended; _loading = false; });
      _snack('تم إيقاف المتجر');
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _snack(ApiClient.extractError(e), isError: true); }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
      backgroundColor: isError ? AppColors.red : AppColors.green,
    ));
  }

  void _showRejectSheet() {
    String selectedReason = '';
    final customCtrl = TextEditingController();
    const predefined = [
      'السجل التجاري غير واضح',
      'صورة الهوية غير واضحة',
      'بيانات غير صحيحة',
      'مستندات ناقصة',
      'بيانات صاحب المتجر غير مرفقة',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1912),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.red.withOpacity(.12), borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.cancel_rounded, color: AppColors.red, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('سبب الرفض', style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(widget.shop.name, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white38)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('اختر سبباً جاهزاً',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white38)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: predefined.map((r) {
                    final sel = selectedReason == r;
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        selectedReason = sel ? '' : r;
                        if (!sel) customCtrl.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.red.withOpacity(.18) : Colors.white.withOpacity(.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? AppColors.red.withOpacity(.5) : Colors.white12),
                        ),
                        child: Text(r, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: sel ? AppColors.red : Colors.white60)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('أو اكتب سبباً مخصصاً',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white38)),
                const SizedBox(height: 8),
                TextField(
                  controller: customCtrl,
                  onChanged: (v) => setSheet(() {
                    if (v.isNotEmpty) {
                      selectedReason = v;
                      // clear predefined selection
                    } else if (predefined.contains(selectedReason)) {
                      // keep predefined
                    } else {
                      selectedReason = '';
                    }
                  }),
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white),
                  maxLines: 2,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب السبب هنا...',
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: () async {
                      final reason = customCtrl.text.trim().isNotEmpty
                          ? customCtrl.text.trim()
                          : selectedReason;
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('يرجى اختيار أو كتابة سبب الرفض',
                            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                          backgroundColor: AppColors.red,
                        ));
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await ShopAdminService.rejectShop(widget.shop.id, reason);
                        if (mounted) {
                          widget.shop.status = AdminShopStatus.rejected;
                          setState(() { _status = AdminShopStatus.rejected; _rejectionReason = reason; });
                          _snack('تم رفض المتجر');
                        }
                      } catch (e) {
                        if (mounted) _snack(ApiClient.extractError(e), isError: true);
                      }
                    },
                    child: const Text('تأكيد الرفض',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApproveConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('اعتماد المتجر', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text('هل تريد اعتماد "${widget.shop.name}"؟\nسيتمكن فوراً من استقبال طلبات العملاء.',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { Navigator.pop(context); _approve(); },
            child: const Text('اعتماد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: AppColors.green))),
        ],
      ),
    );
  }

  void _showSuspendConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إيقاف المتجر', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text('هل تريد إيقاف "${widget.shop.name}"؟\nلن يستطيع استقبال طلبات جديدة.',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { Navigator.pop(context); _suspend(); },
            child: const Text('إيقاف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: Color(0xFF9C27B0)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.shop.name,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          overflow: TextOverflow.ellipsis),
                        const Text('مراجعة طلب الاعتماد',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white38)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _status.color.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _status.color.withOpacity(.3)),
                    ),
                    child: Text(_status.label,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: _status.color)),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withOpacity(.06)),

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Status banner ──
                    if (_status == AdminShopStatus.rejected && _rejectionReason != null) ...[
                      _Banner(icon: Icons.cancel_rounded, color: AppColors.red,
                        title: 'سبب الرفض السابق', body: _rejectionReason!),
                      const SizedBox(height: 16),
                    ],
                    if (_status == AdminShopStatus.suspended) ...[
                      _Banner(icon: Icons.block_rounded, color: const Color(0xFF9C27B0),
                        title: 'المتجر موقوف', body: 'تم إيقاف هذا المتجر من قِبل الإدارة.'),
                      const SizedBox(height: 16),
                    ],

                    // ── Submission date ──
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('تاريخ التقديم: ${widget.shop.submittedAt}',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white30)),
                    ),
                    const SizedBox(height: 16),

                    // ── بيانات المالك ──
                    _SectionHeader(title: 'بيانات المالك', icon: Icons.person_rounded),
                    const SizedBox(height: 10),
                    _InfoCard(children: [
                      _Row(label: 'الاسم الكامل', value: widget.shop.ownerName, icon: Icons.badge_rounded),
                      _Divider(),
                      _Row(label: 'جوال المالك', value: widget.shop.ownerPhone, icon: Icons.phone_rounded),
                      if (widget.shop.idNumber != null) ...[
                        _Divider(),
                        _Row(label: 'رقم الهوية الوطنية', value: widget.shop.idNumber!, icon: Icons.credit_card_rounded),
                      ],
                    ]),
                    const SizedBox(height: 20),

                    // ── بيانات المتجر ──
                    _SectionHeader(title: 'بيانات المتجر', icon: Icons.store_rounded),
                    const SizedBox(height: 10),
                    _InfoCard(children: [
                      _Row(label: 'اسم المتجر', value: widget.shop.name, icon: Icons.storefront_rounded),
                      _Divider(),
                      _Row(label: 'المدينة', value: widget.shop.city, icon: Icons.location_city_rounded),
                      _Divider(),
                      _Row(label: 'جوال المتجر', value: widget.shop.phone, icon: Icons.phone_android_rounded),
                      _Divider(),
                      _Row(label: 'رقم السجل التجاري', value: widget.shop.crNumber, icon: Icons.receipt_long_rounded),
                    ]),
                    const SizedBox(height: 20),

                    // ── الوثائق المرفقة ──
                    _SectionHeader(title: 'الوثائق المرفقة', icon: Icons.folder_open_rounded),
                    const SizedBox(height: 12),

                    if (widget.shop.crDocumentUrl == null && widget.shop.idDocumentUrl == null)
                      _Banner(
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFE65100),
                        title: 'لا توجد وثائق مرفقة',
                        body: 'لم يقم صاحب المتجر برفع أي وثائق عند التسجيل.',
                      )
                    else ...[
                      if (widget.shop.crDocumentUrl != null) ...[
                        _DocumentViewer(label: 'السجل التجاري', url: widget.shop.crDocumentUrl!),
                        const SizedBox(height: 12),
                      ],
                      if (widget.shop.idDocumentUrl != null)
                        _DocumentViewer(label: 'هوية المالك', url: widget.shop.idDocumentUrl!),
                    ],

                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Fixed bottom action bar ──
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1912),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(.07))),
          ),
          child: _loading
              ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: AppColors.goldText)))
              : _buildActionBar(),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    switch (_status) {
      case AdminShopStatus.pending:
      case AdminShopStatus.docsRequested:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _ActionBtn(label: 'اعتماد المتجر', color: AppColors.green, icon: Icons.check_circle_rounded, onTap: _showApproveConfirm),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _ActionBtn(label: 'رفض', color: AppColors.red, icon: Icons.cancel_rounded, onTap: _showRejectSheet),
            ),
          ],
        );
      case AdminShopStatus.approved:
        return _ActionBtn(label: 'إيقاف المتجر', color: const Color(0xFF9C27B0), icon: Icons.block_rounded, onTap: _showSuspendConfirm);
      case AdminShopStatus.rejected:
        return _ActionBtn(label: 'إعادة الاعتماد', color: AppColors.green, icon: Icons.check_circle_rounded, onTap: _showApproveConfirm);
      case AdminShopStatus.suspended:
        return _ActionBtn(label: 'رفع الإيقاف وإعادة الاعتماد', color: AppColors.green, icon: Icons.check_circle_rounded, onTap: _showApproveConfirm);
    }
  }
}

// ─────────────────── Helper Widgets ───────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.goldText, size: 15),
      const SizedBox(width: 7),
      Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w900, color: Colors.white)),
    ],
  );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1912),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(.08)),
    ),
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Row({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Icon(icon, color: AppColors.goldText, size: 16),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white38)),
        const Spacer(),
        Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.white.withOpacity(.06));
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Banner({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 3),
              Text(body, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: color.withOpacity(.8))),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DocumentViewer extends StatelessWidget {
  final String label;
  final String url;
  const _DocumentViewer({required this.label, required this.url});

  String get _fullUrl {
    if (url.startsWith('http')) return url;
    return '${ApiClient.baseUrl}$url';
  }

  bool get _isImage {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
        lower.endsWith('.png') || lower.endsWith('.webp');
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (_, __, ___) => _FullscreenDoc(label: label, fullUrl: _fullUrl, isImage: _isImage),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1912),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldText.withOpacity(.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Document preview ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: _isImage
                    ? Image.network(
                        _fullUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                color: Colors.white.withOpacity(.04),
                                child: const Center(child: CircularProgressIndicator(color: AppColors.goldText, strokeWidth: 2))),
                        errorBuilder: (_, __, ___) => _docPlaceholder(),
                      )
                    : _docPlaceholder(),
              ),
            ),
            // ── Footer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.goldText, size: 15),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(label,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  // copy URL
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: _fullUrl));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تم نسخ رابط الوثيقة',
                          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                        backgroundColor: AppColors.green,
                        duration: Duration(seconds: 2),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.copy_rounded, color: Colors.white38, size: 12),
                          SizedBox(width: 4),
                          Text('نسخ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldText.withOpacity(.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.fullscreen_rounded, color: AppColors.goldText, size: 13),
                        SizedBox(width: 4),
                        Text('تكبير', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPlaceholder() => Container(
    color: Colors.white.withOpacity(.04),
    child: const Center(
      child: Icon(Icons.insert_drive_file_rounded, color: Colors.white12, size: 60),
    ),
  );
}

class _FullscreenDoc extends StatelessWidget {
  final String label;
  final String fullUrl;
  final bool isImage;
  const _FullscreenDoc({required this.label, required this.fullUrl, required this.isImage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: InteractiveViewer(
                    child: Center(
                      child: isImage
                          ? Image.network(fullUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.white24, size: 64))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Colors.white24, size: 80),
                                const SizedBox(height: 12),
                                const Text('ملف PDF — انسخ الرابط لفتحه',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white54)),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: fullUrl));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('تم نسخ الرابط',
                                        style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                                      backgroundColor: AppColors.green,
                                    ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldText.withOpacity(.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.goldText.withOpacity(.4)),
                                    ),
                                    child: const Text('نسخ الرابط',
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    ),
  );
}
