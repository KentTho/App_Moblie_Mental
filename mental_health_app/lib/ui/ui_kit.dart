import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF3F6F9);
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF3B82F6);
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A));
  static const TextStyle h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A));
  static const TextStyle subtitle = TextStyle(fontSize: 15, color: Color(0xFF6B7280), fontWeight: FontWeight.w400);
}

class AppSpacing {
  static const double pagePadding = 24.0;
  static const double cardRadius = 20.0;
}

// Reusable gradient header used across pages
class GradientHeader extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget? trailing;

  const GradientHeader({super.key, required this.leading, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          leading,
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
          ),
          const Spacer(),
          trailing ?? const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// Info card unlike original but uses same parameters
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final List<Color> colors;
  final bool? isVerified;

  const InfoCard({super.key, required this.icon, required this.title, required this.value, required this.subtitle, required this.colors, this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [BoxShadow(color: colors.first.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))],
        border: Border.all(color: colors.first.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                    if (isVerified != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: isVerified! ? AppColors.primary : Colors.orangeAccent, borderRadius: BorderRadius.circular(10)),
                        child: Icon(isVerified! ? Icons.verified_rounded : Icons.pending_rounded, size: 12, color: Colors.white),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF4A5568)), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Simple action button used in profile page
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: colors.first.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))]),
      ),
    );
  }
}
