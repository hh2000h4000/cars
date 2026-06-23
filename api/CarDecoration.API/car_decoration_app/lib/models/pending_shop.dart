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
  final bool hasCompleteDocs;
  final List<String> services;
  AdminShopStatus status;

  PendingShop({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.crNumber,
    required this.city,
    required this.submittedAt,
    required this.hasCompleteDocs,
    required this.services,
    this.status = AdminShopStatus.pending,
  });

  String get mono => name.isNotEmpty ? name[0] : '؟';
}
