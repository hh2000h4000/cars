import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/dispute.dart';
import '../../services/dispute_admin_service.dart';

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  List<Dispute> _disputes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final disputes = await DisputeAdminService.getAllDisputes();
      if (mounted) setState(() { _disputes = disputes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'تعذر تحميل النزاعات'; _loading = false; });
    }
  }

  Future<void> _updateStatus(Dispute dispute, DisputeStatus newStatus) async {
    try {
      await DisputeAdminService.updateStatus(dispute.rawId, newStatus);
      if (mounted) setState(() => dispute.status = newStatus);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل تحديث الحالة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  void _showDecisionDialog(Dispute dispute) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('اتخاذ قرار', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusOption(
              label: 'قيد المراجعة',
              color: AppColors.red,
              selected: dispute.status == DisputeStatus.underReview,
              onTap: () { Navigator.pop(context); _updateStatus(dispute, DisputeStatus.underReview); },
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'بانتظار رد المتجر',
              color: AppColors.goldText,
              selected: dispute.status == DisputeStatus.waitingShop,
              onTap: () { Navigator.pop(context); _updateStatus(dispute, DisputeStatus.waitingShop); },
            ),
            const SizedBox(height: 8),
            _StatusOption(
              label: 'تم الحل',
              color: AppColors.green,
              selected: dispute.status == DisputeStatus.resolved,
              onTap: () { Navigator.pop(context); _updateStatus(dispute, DisputeStatus.resolved); },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white38))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _disputes.where((d) => d.status != DisputeStatus.resolved).length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة النزاعات',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('$openCount نزاع مفتوح',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.goldText))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white54)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _load,
                              child: Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
                          ],
                        ))
                      : _disputes.isEmpty
                          ? Center(child: Text('لا توجد نزاعات',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white38)))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _disputes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _DisputeCard(
                                dispute: _disputes[i],
                                onDecision: () => _showDecisionDialog(_disputes[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final VoidCallback onDecision;
  const _DisputeCard({required this.dispute, required this.onDecision});

  Color get _accentColor {
    switch (dispute.status) {
      case DisputeStatus.underReview: return AppColors.red;
      case DisputeStatus.waitingShop: return AppColors.goldText;
      case DisputeStatus.resolved: return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final isResolved = dispute.status == DisputeStatus.resolved;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1912),
            border: Border.all(color: accent.withOpacity(.22)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('#${dispute.id}',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white38)),
                        const Spacer(),
                        _StatusBadge(dispute.status, accent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(dispute.reason,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    if (dispute.details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(dispute.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white54)),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'الطلب #${dispute.requestId} · ${dispute.customerName} ← ${dispute.shopName}',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white38),
                    ),
                  ],
                ),
              ),

              if (!isResolved) ...[
                Container(height: 1, color: Colors.white10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.07),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text('مراجعة المحادثة',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: onDecision,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text('اتخاذ قرار',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DisputeStatus status;
  final Color color;
  const _StatusBadge(this.status, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(status.label,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
  );
}

class _StatusOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _StatusOption({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(.18) : Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? color.withOpacity(.5) : Colors.white10),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          if (selected) Icon(Icons.check_rounded, color: color, size: 18),
        ],
      ),
    ),
  );
}
