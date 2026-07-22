import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liquid-glass stat card — semi-transparent colour-tinted container.
class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // soft colored glow
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          // subtle ambient shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          // semi-transparent tinted glass fill
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon chip + label row
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color.withValues(alpha: 0.85),
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Big value
                  Text(
                    value,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            // Watermark icon (bottom-right, extra subtle)
            if (icon != null)
              Positioned(
                bottom: -6,
                right: -6,
                child: Icon(
                  icon,
                  size: 58,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
