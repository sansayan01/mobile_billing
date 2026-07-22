import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simple data class representing a recent transaction/bill.
class RecentTransaction {
  final String id;
  final String staffName;
  final double grandTotal;
  final String paymentMethod;
  final int itemCount;
  final DateTime createdAt;

  const RecentTransaction({
    required this.id,
    required this.staffName,
    required this.grandTotal,
    required this.paymentMethod,
    required this.itemCount,
    required this.createdAt,
  });
}

/// A frosted glass-effect card that displays the most recent transactions.
///
/// Shows up to 5 transactions with staff name, time ago, amount,
/// item count, and a colored payment-method badge.
class RecentTransactionsCard extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Formats a [DateTime] into a human-readable "time ago" string.
  static String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative) return 'Just now';
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d days ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w week${w > 1 ? 's' : ''} ago';
    }
    final months = (diff.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  }

  /// Formats amount as ₹ — whole numbers without decimals, otherwise 2 decimals.
  static String _formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toStringAsFixed(0)}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Returns a color associated with the payment method string.
  static Color _paymentColor(String method) {
    final m = method.toLowerCase();
    if (m == 'upi') return const Color(0xFF4CAF50);
    if (m == 'cash') return const Color(0xFFFF9800);
    if (m == 'card') return const Color(0xFF2196F3);
    if (m == 'credit') return const Color(0xFF9C27B0);
    return const Color(0xFF78909C);
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayTransactions =
        transactions.length > 5 ? transactions.sublist(0, 5) : transactions;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    GestureDetector(
                      onTap: onViewAll,
                      child: Text(
                        'See All',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Transaction list or empty state ──
                if (displayTransactions.isEmpty)
                  _buildEmptyState()
                else
                  ...displayTransactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final txn = entry.value;
                    final isLast = index == displayTransactions.length - 1;

                    return Column(
                      children: [
                        _buildTransactionItem(txn),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Divider(
                              height: 1,
                              thickness: 0.8,
                              color: Colors.grey.shade300.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Individual transaction row ───────────────────────────────────────

  Widget _buildTransactionItem(RecentTransaction txn) {
    final badgeColor = _paymentColor(txn.paymentMethod);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // ── Left: staff info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Staff name
                    Flexible(
                      child: Text(
                        txn.staffName,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Payment badge
                    _buildPaymentBadge(txn.paymentMethod, badgeColor),
                  ],
                ),
                const SizedBox(height: 3),
                // Time ago + item count
                Text(
                  '${_timeAgo(txn.createdAt)}  •  ${txn.itemCount} item${txn.itemCount != 1 ? 's' : ''}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E9A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: amount ──
          Text(
            _formatCurrency(txn.grandTotal),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment badge chip ───────────────────────────────────────────────

  Widget _buildPaymentBadge(String method, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'No transactions yet',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8E8E9A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Completed bills will appear here',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB0B0BA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
