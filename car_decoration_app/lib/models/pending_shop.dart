import 'package:flutter/material.dart';

enum AdminShopStatus { pending, approved, rejected, docsRequested }

extension AdminShopStatusInfo on AdminShopStatus {
  String get label {
    switch (this) {
      case AdminShopStatus.pending: return 'بانتظار المراجعة';
      case AdminShopStatus.approved: return 'معتمد';
      case AdminShopStatus.rejected: return 'مرفوض';
      case AdminShopStatus.docsRequested: return 'طلب مستندات';
    }
  }

  Color get color {
    switch (this) {
      case AdminShopStatus.pending: return const Color(0xFFFF9800);
      case AdminShopStatus.approved: return const Color(0xFF4CAF50);
      case AdminShopStatus.rejected: return const Color(0xFFF44336);
      case AdminShopStatus.docsRequested: return const Color(0xFF2196F3);
    }
  }
}

class PendingShop {
  final String id;
  final String name;
  final String ownerName;
  final String phone;
  final String crNumber;
  final String city;
  final String submittedAt;
  AdminShopStatus status;

  PendingShop({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.crNumber,
    required this.city,
    required this.submittedAt,
    this.status = AdminShopStatus.pending,
  });

  factory PendingShop.fromJson(Map<String, dynamic> j) {
    AdminShopStatus parseStatus(String s) {
      switch (s) {
        case 'Approved': return AdminShopStatus.approved;
        case 'Rejected': return AdminShopStatus.rejected;
        case 'DocsRequested': return AdminShopStatus.docsRequested;
        default: return AdminShopStatus.pending;
      }
    }

    final createdAt = DateTime.tryParse(j['createdAt'] as String? ?? '');
    final submittedAt = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '–';

    return PendingShop(
      id: (j['id'] as String? ?? ''),
      name: j['name'] as String? ?? '',
      ownerName: j['ownerName'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      crNumber: j['crNumber'] as String? ?? '',
      city: j['city'] as String? ?? '',
      submittedAt: submittedAt,
      status: parseStatus(j['status'] as String? ?? ''),
    );
  }

  String get mono => name.isNotEmpty ? name[0] : '؟';
}
