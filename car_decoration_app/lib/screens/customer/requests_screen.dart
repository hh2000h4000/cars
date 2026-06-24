import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/service_request.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final requests = provider.requests;
    final loading = provider.initLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (loading)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                children: [
                  Text('طلباتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('طلب جديد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          const SizedBox(width: 4),
                          const Icon(Icons.add, color: AppColors.dark, size: 17),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: requests.isEmpty && !loading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 52),
                          const SizedBox(height: 12),
                          Text('لا توجد طلبات بعد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _RequestCard(request: requests[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/customer/request-detail', arguments: request.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // Top colored bar by status
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _statusColor(request.status),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('طلب #${request.requestNumber}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const Spacer(),
                      StatusBadge(label: request.status.label, type: request.status.colorType),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.serviceType, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text('${request.vehicleBrand} ${request.vehicleModel}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (request.quotationCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${request.quotationCount} عروض', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                              const SizedBox(width: 4),
                              const Icon(Icons.local_offer_outlined, color: AppColors.goldText, size: 13),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(request.dateLabel, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      const SizedBox(width: 5),
                      const Icon(Icons.access_time, color: AppColors.textMuted, size: 13),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(RequestStatus status) {
    switch (status.colorType) {
      case 'gold': return AppColors.gold;
      case 'green': return AppColors.green;
      case 'red': return AppColors.red;
      default: return AppColors.border;
    }
  }
}
