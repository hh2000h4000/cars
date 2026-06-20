import 'package:flutter/material.dart';

import '../theme.dart';

// ─── Gold gradient button ─────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const GoldButton({super.key, required this.label, required this.onTap, this.height = 54});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.goldLight.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.dark)),
      ),
    );
  }
}

// ─── Dark button ─────────────────────────────────────────────────────────────
class DarkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final Widget? leading;

  const DarkButton({super.key, required this.label, required this.onTap, this.height = 54, this.leading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Outlined button ──────────────────────────────────────────────────────────
class OutlinedDarkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? textColor;
  final double height;

  const OutlinedDarkButton({super.key, required this.label, required this.onTap, this.borderColor, this.textColor, this.height = 54});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? AppColors.dark, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: textColor ?? AppColors.dark)),
      ),
    );
  }
}

// ─── App logo mark ────────────────────────────────────────────────────────────
class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.goldLight, AppColors.gold]),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Transform.rotate(
          angle: 0.785,
          child: Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(size * 0.065)),
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
            ),
        ],
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final String type; // gold | green | red

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    switch (type) {
      case 'green': color = AppColors.green; bg = AppColors.greenLight; break;
      case 'red': color = AppColors.red; bg = AppColors.redLight; break;
      default: color = AppColors.goldText; bg = AppColors.goldBg; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

// ─── Shop mono avatar ─────────────────────────────────────────────────────────
class ShopAvatar extends StatelessWidget {
  final String mono;
  final double size;
  final double fontSize;
  final bool light;

  const ShopAvatar({super.key, required this.mono, this.size = 48, this.fontSize = 18, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: light
            ? const LinearGradient(colors: [Color(0xFFF6EFDD), Color(0xFFEADFC2)])
            : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2A2618), Color(0xFF15140F)]),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: fontSize, fontWeight: FontWeight.w900, color: light ? AppColors.goldText : AppColors.goldLight)),
    );
  }
}

// ─── Star rating row ──────────────────────────────────────────────────────────
class StarRatingRow extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const StarRatingRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const Spacer(),
        Row(
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => onChanged(i + 1),
            child: Text('★', style: TextStyle(fontSize: 26, color: value >= i + 1 ? AppColors.star : const Color(0xFFE2DCCF))),
          )),
        ),
      ],
    );
  }
}

// ─── Form field label + box ───────────────────────────────────────────────────
class FormFieldBox extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;

  const FormFieldBox({super.key, required this.label, required this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          constraints: multiline ? const BoxConstraints(minHeight: 52) : const BoxConstraints(minHeight: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          alignment: Alignment.centerRight,
          child: Text(value, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}

// ─── Back button ─────────────────────────────────────────────────────────────
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.chevron_right, color: AppColors.dark, size: 22),
      ),
    );
  }
}

// ─── Info green banner ───────────────────────────────────────────────────────
class GreenInfoBanner extends StatelessWidget {
  final String text;
  const GreenInfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.greenBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.green, size: 20),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.green))),
        ],
      ),
    );
  }
}
