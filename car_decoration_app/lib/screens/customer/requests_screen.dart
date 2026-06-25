import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';
import '../../models/service_request.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _filterIndex = 0;

  List<ServiceRequest> _filtered(List<ServiceRequest> all) {
    if (_filterIndex == 1) {
      return all.where((r) => r.status != RequestStatus.completed && r.status != RequestStatus.cancelled).toList();
    }
    if (_filterIndex == 2) {
      return all.where((r) => r.status == RequestStatus.completed).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtered = _filtered(provider.requests);
    final loading = provider.initLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (loading)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.goldLight, size: 17),
                          SizedBox(width: 5),
                          Text('طلب جديد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text('طلباتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
            ),
            // ── Filter tabs ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _FilterTab(label: 'مكتملة', active: _filterIndex == 2, onTap: () => setState(() => _filterIndex = 2)),
                  const SizedBox(width: 8),
                  _FilterTab(label: 'نشطة', active: _filterIndex == 1, onTap: () => setState(() => _filterIndex = 1)),
                  const SizedBox(width: 8),
                  _FilterTab(label: 'الكل', active: _filterIndex == 0, onTap: () => setState(() => _filterIndex = 0)),
                ],
              ),
            ),
            // ── List ────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty && !loading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 52),
                          const SizedBox(height: 12),
                          Text('لا توجد طلبات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _RequestCard(request: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.dark : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: active ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  const _RequestCard({required this.request});

  String _formatDate(String dateLabel) {
    try {
      final parts = dateLabel.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '$day ${months[month - 1]}';
    } catch (_) {
      return dateLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuotes = request.quotationCount > 0;
    final showViewLink = request.status == RequestStatus.pending ||
        request.status == RequestStatus.offers;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/customer/request-detail', arguments: request.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // ── Top section ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status chip + date row
                  Row(
                    children: [
                      Text(
                        '${_formatDate(request.dateLabel)} · #${request.requestNumber}',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      _StatusChip(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Service description
                  Text(
                    request.serviceType,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  // Vehicle info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${request.vehicleBrand} ${request.vehicleModel} ${request.vehicleYear}',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
            // ── Bottom section (quotes / action) ─────────────────
            if (hasQuotes || showViewLink) ...[
              Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
                child: Row(
                  children: [
                    if (showViewLink)
                      Text(
                        'عرض العروض ›',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText),
                      ),
                    const Spacer(),
                    if (hasQuotes)
                      Text(
                        '${request.quotationCount} عروض جديدة',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    switch (status.colorType) {
      case 'green':
        bg = AppColors.greenLight; textColor = AppColors.green; break;
      case 'red':
        bg = AppColors.redLight; textColor = AppColors.red; break;
      default:
        bg = AppColors.goldBg; textColor = AppColors.goldText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: textColor)),
    );
  }
}
