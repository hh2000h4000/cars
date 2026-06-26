import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/shop_request.dart';
import '../../services/shop_request_service.dart';

class ShopRequestDetailScreen extends StatefulWidget {
  final ShopRequest request;
  const ShopRequestDetailScreen({super.key, required this.request});

  @override
  State<ShopRequestDetailScreen> createState() => _ShopRequestDetailScreenState();
}

class _ShopRequestDetailScreenState extends State<ShopRequestDetailScreen> {
  bool _accepting = false;
  bool _completing = false;
  late ShopRequestShopStatus _shopStatus;
  late String _requestStatus;
  String? _chatRoomId;

  @override
  void initState() {
    super.initState();
    _shopStatus = widget.request.shopStatus;
    _requestStatus = widget.request.status;
    _chatRoomId = widget.request.chatRoomId;
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    try {
      await ShopRequestService.completeRequest(widget.request.id);
      if (mounted) {
        setState(() {
          _requestStatus = 'Completed';
          _completing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إنهاء الطلب بنجاح — سيتلقى العميل إشعاراً للتقييم',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _completing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      final chatId = await ShopRequestService.acceptRequest(widget.request.id);
      if (mounted) {
        setState(() {
          _shopStatus = ShopRequestShopStatus.accepted;
          _chatRoomId = chatId;
          _accepting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم قبول الطلب وفتح المحادثة بنجاح',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل قبول الطلب',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isPending = _shopStatus == ShopRequestShopStatus.pending;
    final isAccepted = _shopStatus == ShopRequestShopStatus.accepted;
    final isActive = _requestStatus == 'Active';
    final isCompleted = _requestStatus == 'Completed';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب وارد',
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${r.timeAgo} · ${r.location}',
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Customer card ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(r.mono,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.customerName,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 3),
                                const Text('عميل',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (_chatRoomId != null)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
                              child: Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(13)),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Service description ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        border: Border.all(color: AppColors.goldLight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الخدمة المطلوبة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          const SizedBox(height: 8),
                          Text(r.description,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Vehicle + Date ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('المركبة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                const SizedBox(height: 5),
                                Text(r.vehicleInfo,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 36, color: AppColors.border),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الموعد المفضّل',
                                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                  const SizedBox(height: 5),
                                  Text(r.appointmentLabel,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Location card ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(r.location,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ),

                    if (isAccepted && _chatRoomId == null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(.07),
                          border: Border.all(color: AppColors.green.withOpacity(.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.green, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('تم قبول الطلب — يمكنك الآن إرسال عرض سعر',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom buttons ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: isCompleted
            ? Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(.08),
                  border: Border.all(color: AppColors.green.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                    SizedBox(width: 8),
                    Text('تم إنهاء الطلب بنجاح',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green)),
                  ],
                ),
              )
            : isPending
                ? DarkButton(
                    label: _accepting ? 'جاري القبول...' : 'قبول الطلب وفتح المحادثة',
                    onTap: _accepting ? null : _accept,
                    height: 50,
                  )
                : isActive && _chatRoomId != null
                    ? Row(
                        children: [
                          Expanded(
                            child: DarkButton(
                              label: _completing ? 'جاري الإنهاء...' : 'إنهاء الطلب',
                              onTap: _completing ? null : _complete,
                              height: 50,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedDarkButton(
                              label: 'المحادثة',
                              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
                              height: 50,
                            ),
                          ),
                        ],
                      )
                    : _chatRoomId != null
                        ? Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DarkButton(
                                  label: 'إرسال عرض سعر',
                                  onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: widget.request),
                                  height: 50,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedDarkButton(
                                  label: 'المحادثة',
                                  onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
                                  height: 50,
                                ),
                              ),
                            ],
                          )
                        : DarkButton(
                            label: 'إرسال عرض سعر',
                            onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: widget.request),
                            height: 50,
                          ),
      ),
    );
  }
}
