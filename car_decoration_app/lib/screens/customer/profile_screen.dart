import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _phone = '';
  String _email = '';
  int _vehicleCount = 0;
  int _activeRequestCount = 0;
  int _reviewCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCached();
    _loadFromApi();
  }

  Future<void> _loadCached() async {
    final name = await ApiClient.getFullName();
    final phone = await ApiClient.getPhone();
    final email = await ApiClient.getEmail();
    if (!mounted) return;
    setState(() {
      _fullName = name ?? '';
      _phone = phone ?? '';
      _email = email ?? '';
    });
  }

  Future<void> _loadFromApi() async {
    try {
      final profile = await UserService.getProfile();
      if (!mounted) return;
      setState(() {
        _fullName = profile.fullName;
        _phone = profile.phone;
        _email = profile.email;
        _vehicleCount = profile.vehicleCount;
        _activeRequestCount = profile.activeRequestCount;
        _reviewCount = profile.reviewCount;
        _statsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  String get _mono => _fullName.isNotEmpty ? _fullName[0] : 'أ';

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<UserProfileData>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialName: _fullName, initialPhone: _phone),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _fullName = updated.fullName;
        _phone = updated.phone;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900)),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService.logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Dark header ─────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(_mono,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_fullName.isNotEmpty ? _fullName : '...',
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                    const SizedBox(height: 3),
                                    Text(_phone.isNotEmpty ? _phone : (_email.isNotEmpty ? _email : '...'),
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white54)),
                                  ],
                                ),
                              ),
                              // Edit button
                              GestureDetector(
                                onTap: _openEditProfile,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(
                            children: [
                              _DarkStat(
                                _statsLoading ? '—' : '$_reviewCount',
                                'تقييمات',
                                loading: _statsLoading,
                              ),
                              _DarkDivider(),
                              _DarkStat(
                                _statsLoading ? '—' : '$_activeRequestCount',
                                'طلبات نشطة',
                                loading: _statsLoading,
                              ),
                              _DarkDivider(),
                              _DarkStat(
                                _statsLoading ? '—' : '$_vehicleCount',
                                'مركبات',
                                loading: _statsLoading,
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

            const SizedBox(height: 16),

            // ── Menu ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'المعلومات الشخصية',
                    onTap: _openEditProfile,
                  ),
                  _MenuItem(
                    icon: Icons.directions_car_outlined,
                    label: 'سياراتي',
                    onTap: () => Navigator.pushNamed(context, '/customer/vehicles'),
                  ),
                  _MenuItem(
                    icon: Icons.list_alt_outlined,
                    label: 'طلباتي وسجل الطلبات',
                    onTap: () => Navigator.pushNamed(context, '/customer/requests'),
                  ),
                  _MenuItem(
                    icon: Icons.star_outline_rounded,
                    label: 'تقييماتي',
                    badge: _reviewCount > 0 ? '$_reviewCount' : null,
                  ),
                  _MenuItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'شكاوي ونزاعاتي',
                    onTap: () => Navigator.pushNamed(context, '/customer/complaint', arguments: ''),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'العناوين المحفوظة',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── App version ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.info_outline, color: AppColors.goldText, size: 18),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('زينة كارز', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('الإصدار 1.0.0', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Logout ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
              child: GestureDetector(
                onTap: _logout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.redBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_outlined, color: AppColors.red, size: 18),
                      SizedBox(width: 8),
                      Text('تسجيل الخروج',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: AppColors.goldText, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(label,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                      child: Text(badge!,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                    ),
                  const SizedBox(width: 4),
                  Icon(enabled ? Icons.chevron_left : Icons.lock_outline,
                    color: enabled ? AppColors.textMuted : AppColors.border, size: enabled ? 20 : 16),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _DarkStat extends StatelessWidget {
  final String value;
  final String label;
  final bool loading;
  const _DarkStat(this.value, this.label, {this.loading = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        loading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38))
            : Text(value,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white54)),
      ],
    ),
  );
}

class _DarkDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 30, color: Colors.white12);
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B96A).withOpacity(0.09)
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
