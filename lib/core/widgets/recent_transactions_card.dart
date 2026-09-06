import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/text_styles.dart';
import 'package:billing_app/core/widgets/press_scale.dart';
import 'package:billing_app/core/widgets/sliding_capsule_selector.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';

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

/// A tactile Thermal Receipt Paper Roll dispenser card.
///
/// Simulates an authentic shop thermal billing printer embedding inside the chassis:
/// - Metal cutter dispenser mouth with serrated blade highlights
/// - Internally scrollable thermal paper feed roll (BouncingScrollPhysics)
/// - Dynamic shop name in the receipt header banner
/// - Dotted perforation lines, thermal store banner, and scannable micro-barcode
/// - Realistic zigzag serrated tear edge at the bottom of the roll
/// - Full interactive support: Slidable actions (Print/Share), tap preview, filters
class RecentTransactionsCard extends StatefulWidget {
  final List<RecentTransaction> transactions;
  final VoidCallback? onViewAll;
  final void Function(RecentTransaction txn)? onTransactionTap;
  final String? shopName;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    this.onViewAll,
    this.onTransactionTap,
    this.shopName,
  });

  @override
  State<RecentTransactionsCard> createState() => _RecentTransactionsCardState();
}

// ── Helpers ──────────────────────────────────────────────────────────

/// Formats a [DateTime] into a human-readable "time ago" string.
String _timeAgo(DateTime dt) {
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
String _formatCurrency(double amount) {
  if (amount == amount.roundToDouble()) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  return '₹${amount.toStringAsFixed(2)}';
}

/// Returns a color associated with the payment method string.
Color _paymentColor(String method, Brightness b) {
  final m = method.toLowerCase();
  if (m.contains('upi')) return AppColors.successText(b);
  if (m.contains('cash')) return AppColors.warningText(b);
  if (m.contains('card')) return AppColors.infoText(b);
  if (m.contains('credit')) return AppColors.accentText(b);
  return AppColors.textTertiary(b);
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  String _selectedFilter = 'All';
  static const _filters = ['All', 'UPI', 'Cash', 'Card'];

  List<RecentTransaction> _getFilteredTransactions() {
    if (_selectedFilter == 'All') {
      return widget.transactions.length > 15
          ? widget.transactions.sublist(0, 15)
          : widget.transactions;
    }
    final lower = _selectedFilter.toLowerCase();
    final matched = widget.transactions
        .where((t) => t.paymentMethod.toLowerCase().contains(lower))
        .toList();
    return matched.length > 15 ? matched.sublist(0, 15) : matched;
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    final displayTransactions = _getFilteredTransactions();

    // Resolve dynamic shop name
    String dynamicShopName = widget.shopName?.trim() ?? '';
    if (dynamicShopName.isEmpty) {
      try {
        final shopState = context.watch<ShopBloc?>()?.state;
        if (shopState is ShopLoaded && shopState.shop.name.trim().isNotEmpty) {
          dynamicShopName = shopState.shop.name.trim();
        }
      } catch (_) {
        // Fallback if ShopBloc is not available in tree
      }
    }
    if (dynamicShopName.isEmpty) {
      dynamicShopName = 'MY SHOP';
    }

    // Chassis housing colors (Printer Machine Enclosure)
    final chassisColor = isDark ? const Color(0xFF141720) : const Color(0xFFF0F2F6);
    final chassisBorder = isDark ? const Color(0xFF222836) : const Color(0xFFD8DDE6);

    // Thermal Receipt Paper colors
    final paperBg = isDark ? const Color(0xFF0D1017) : const Color(0xFFFCFCFB);
    final paperBorder = isDark ? const Color(0xFF1D2330) : const Color(0xFFE5E7EB);
    final paperTextPrimary = isDark ? const Color(0xFFECEFF4) : const Color(0xFF1A1D24);
    final paperTextMuted = isDark ? const Color(0xFF7E889B) : const Color(0xFF717A8A);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: chassisColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: chassisBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Printer Chassis Head (Controls & Status) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Live Feed LED + See All
                Row(
                  children: [
                    // Live Status LED
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.9),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECEIPT FEED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: AppColors.accentText(b),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• 58MM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: paperTextMuted.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    PressScale(
                      pressedScale: 0.92,
                      enableHaptic: false,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onViewAll,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'All Bills',
                                style: AppTextStyles.of(context).txnSeeAll.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: AppColors.accentText(b),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment method sliding filter capsule
                if (widget.transactions.isNotEmpty)
                  SlidingCapsuleSelector(
                    items: _filters,
                    selectedIndex: _filters.indexOf(_selectedFilter),
                    height: 30,
                    fontSize: 11.0,
                    onSelected: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = _filters[i]);
                    },
                  ),
              ],
            ),
          ),

          // ── The Mechanical Printer Mouth / Cutter Slit ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _PrinterCutterSlot(isDark: isDark),
          ),

          // ── Internally Scrollable Thermal Receipt Paper Roll ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: ClipPath(
              clipper: const _ZigZagTearClipper(toothWidth: 10.0, toothHeight: 6.0),
              child: Container(
                width: double.infinity,
                height: displayTransactions.isEmpty ? 220 : 360,
                decoration: BoxDecoration(
                  color: paperBg,
                  border: Border(
                    left: BorderSide(color: paperBorder, width: 1.0),
                    right: BorderSide(color: paperBorder, width: 1.0),
                    top: BorderSide(color: paperBorder.withValues(alpha: 0.5), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Internal Paper Scroll View
                    Scrollbar(
                      thickness: 3,
                      radius: const Radius.circular(2),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Thermal Store Banner Header with Dynamic Shop Name
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                children: [
                                  Text(
                                    '★ ${dynamicShopName.toUpperCase()} ★',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: paperTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'REGISTER #01 • LIVE FEED',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                      color: paperTextMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _ReceiptDashedLine(
                                    color: paperTextMuted.withValues(alpha: 0.35),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),

                            // Transaction Rows / Empty State
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: displayTransactions.isEmpty
                                  ? _buildEmptyFilteredState(
                                      context,
                                      _selectedFilter,
                                      paperTextMuted,
                                    )
                                  : Column(
                                      key: ValueKey('list-$_selectedFilter'),
                                      children: displayTransactions.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final txn = entry.value;
                                        final isLast = index == displayTransactions.length - 1;

                                        return Column(
                                          children: [
                                            Slidable(
                                              key: ValueKey(txn.id),
                                              startActionPane: ActionPane(
                                                motion: const BehindMotion(),
                                                extentRatio: 0.28,
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (ctx) {
                                                      HapticFeedback.mediumImpact();
                                                      widget.onTransactionTap?.call(txn);
                                                    },
                                                    backgroundColor: Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    child: _buildTornActionSlot(
                                                      label: 'PRINT',
                                                      icon: Icons.print_rounded,
                                                      color: AppColors.accent,
                                                      onColor: AppColors.onAccent,
                                                      isLeft: true,
                                                      isDark: isDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              endActionPane: ActionPane(
                                                motion: const BehindMotion(),
                                                extentRatio: 0.28,
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (ctx) {
                                                      HapticFeedback.mediumImpact();
                                                      widget.onTransactionTap?.call(txn);
                                                    },
                                                    backgroundColor: Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    child: _buildTornActionSlot(
                                                      label: 'SHARE',
                                                      icon: Icons.share_rounded,
                                                      color: AppColors.infoText(b),
                                                      onColor: Colors.white,
                                                      isLeft: false,
                                                      isDark: isDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: paperBg,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(
                                                          alpha: isDark ? 0.35 : 0.10),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // Left Jagged Perforated Tear Edge (revealed when pulled right)
                                                    Positioned(
                                                      left: 0,
                                                      top: 0,
                                                      bottom: 0,
                                                      width: 5,
                                                      child: CustomPaint(
                                                        painter: _VerticalZigZagPainter(
                                                          paperColor: paperBg,
                                                          shadowColor: paperTextMuted
                                                              .withValues(alpha: 0.30),
                                                          isLeft: true,
                                                        ),
                                                      ),
                                                    ),

                                                    // Right Jagged Perforated Tear Edge (revealed when pulled left)
                                                    Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      bottom: 0,
                                                      width: 5,
                                                      child: CustomPaint(
                                                        painter: _VerticalZigZagPainter(
                                                          paperColor: paperBg,
                                                          shadowColor: paperTextMuted
                                                              .withValues(alpha: 0.30),
                                                          isLeft: false,
                                                        ),
                                                      ),
                                                    ),

                                                    // Transaction Row Content
                                                    PressScale(
                                                      pressedScale: 0.97,
                                                      enableHaptic: false,
                                                      child: GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: widget.onTransactionTap == null
                                                            ? null
                                                            : () => widget.onTransactionTap!(txn),
                                                        child: _buildReceiptTransactionItem(
                                                          context,
                                                          txn,
                                                          paperTextPrimary,
                                                          paperTextMuted,
                                                          index + 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (!isLast)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 18, vertical: 4),
                                                child: _ReceiptDashedLine(
                                                  color: paperTextMuted.withValues(alpha: 0.25),
                                                ),
                                              ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                            ),

                            // Thermal Footer & Barcode
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                              child: Column(
                                children: [
                                  _ReceiptDashedLine(
                                    color: paperTextMuted.withValues(alpha: 0.35),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '*** THANK YOU • VISIT AGAIN ***',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: paperTextMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // High-tech Scannable Thermal Micro-Barcode
                                  SizedBox(
                                    height: 22,
                                    width: 190,
                                    child: CustomPaint(
                                      painter: _ThermalBarcodePainter(
                                        color: paperTextPrimary.withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'BILLING-SECURE-SYNC',
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.0,
                                      color: paperTextMuted.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Fixed Top 3D Cutter Slit Shadow Overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 18,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: isDark ? 0.55 : 0.20),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fixed Bottom Zigzag Cut Shadow Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 14,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Authentic Thermal Receipt Row ───────────────────────────────────

  Widget _buildReceiptTransactionItem(
    BuildContext context,
    RecentTransaction txn,
    Color textPrimary,
    Color textMuted,
    int itemNumber,
  ) {
    final b = Theme.of(context).brightness;
    final badgeColor = _paymentColor(txn.paymentMethod, b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Receipt Item Counter Pod
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: textMuted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                itemNumber < 10 ? '0$itemNumber' : '$itemNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Left: Staff Name + Time ago + Item count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        txn.staffName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildReceiptPaymentBadge(context, txn.paymentMethod, badgeColor),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${_timeAgo(txn.createdAt).toUpperCase()}  •  ${txn.itemCount} ITEM${txn.itemCount != 1 ? 'S' : ''}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right: Monospaced Currency Amount
          Text(
            _formatCurrency(txn.grandTotal),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              letterSpacing: -0.2,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Thermal Payment Badge ───────────────────────────────────────────

  Widget _buildReceiptPaymentBadge(BuildContext context, String method, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? color.withValues(alpha: 0.18) : color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────

  Widget _buildEmptyFilteredState(BuildContext context, String filter, Color textMuted) {
    final b = Theme.of(context).brightness;
    final isSpecificFilter = filter != 'All';

    return Padding(
      key: ValueKey('empty-$filter'),
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(
              isSpecificFilter ? Icons.filter_alt_off_rounded : Icons.receipt_long_rounded,
              size: 34,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              isSpecificFilter ? 'NO $filter TRANSACTIONS' : 'NO TRANSACTIONS YET',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.textPrimary(b),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Awaiting printer spool data',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Paper Cutout Tear Action Slot (BehindMotion cavity) ───────────────

  Widget _buildTornActionSlot({
    required String label,
    required IconData icon,
    required Color color,
    required Color onColor,
    required bool isLeft,
    required bool isDark,
  }) {
    final cavityBg = isDark ? const Color(0xFF07090E) : const Color(0xFFE2E5EC);
    final cavityBorder = isDark ? const Color(0xFF181C26) : const Color(0xFFCCD1DC);

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: cavityBg,
        border: Border(
          top: BorderSide(color: cavityBorder, width: 0.8),
          bottom: BorderSide(color: cavityBorder, width: 0.8),
          left: isLeft ? BorderSide(color: cavityBorder, width: 0.8) : BorderSide.none,
          right: !isLeft ? BorderSide(color: cavityBorder, width: 0.8) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.60 : 0.15),
            blurRadius: 4,
            offset: isLeft ? const Offset(2, 0) : const Offset(-2, 0),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: onColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: onColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Thermal Printer Visual Components (Cutter, ZigZag, Dashed Line, Barcode)
// ═══════════════════════════════════════════════════════════════════════

/// Metallic Cutter Slot where the receipt emerges from the chassis.
class _PrinterCutterSlot extends StatelessWidget {
  final bool isDark;
  const _PrinterCutterSlot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080A10) : const Color(0xFFD8DCE4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2432) : const Color(0xFFCBD0DC),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.70 : 0.20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          height: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF020305) : const Color(0xFFB0B6C2),
            borderRadius: BorderRadius.circular(1.0),
          ),
        ),
      ),
    );
  }
}

/// Dotted perforation line between receipt entries.
class _ReceiptDashedLine extends StatelessWidget {
  final Color color;
  const _ReceiptDashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.5;
        const dashSpace = 3.5;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(0.5),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// High-tech vector barcode rendered at the bottom of the receipt roll.
class _ThermalBarcodePainter extends CustomPainter {
  final Color color;

  const _ThermalBarcodePainter({required this.color});

  static const List<double> _barPattern = [
    2, 1, 3, 2, 1, 4, 2, 1, 2, 3, 1, 2, 4, 1, 2, 1, 3, 2, 1, 4, 2, 2, 1, 3, 1, 2, 4, 1, 2, 3
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double x = (size.width - 170) / 2;
    if (x < 0) x = 0;

    for (int i = 0; i < _barPattern.length; i++) {
      final width = _barPattern[i];
      if (i % 2 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, 0, width, size.height),
            const Radius.circular(0.5),
          ),
          paint,
        );
      }
      x += width + 1.8;
      if (x > size.width) break;
    }
  }

  @override
  bool shouldRepaint(_ThermalBarcodePainter oldDelegate) => oldDelegate.color != color;
}

/// Custom clipper that cuts the bottom of the thermal paper into jagged zigzag teeth.
class _ZigZagTearClipper extends CustomClipper<Path> {
  final double toothWidth;
  final double toothHeight;

  const _ZigZagTearClipper({
    this.toothWidth = 10.0,
    this.toothHeight = 6.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - toothHeight);

    double x = size.width;
    bool up = true;
    while (x > 0) {
      x -= toothWidth;
      if (x < 0) x = 0;
      final y = up ? size.height : size.height - toothHeight;
      path.lineTo(x, y);
      up = !up;
    }

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ZigZagTearClipper oldClipper) =>
      oldClipper.toothWidth != toothWidth || oldClipper.toothHeight != toothHeight;
}

/// Custom painter rendering a vertical serrated jagged tear edge on the side
/// of a receipt slip being pulled/cut out.
class _VerticalZigZagPainter extends CustomPainter {
  final Color paperColor;
  final Color shadowColor;
  final bool isLeft;

  static const double _toothDepth = 3.5;
  static const double _toothHeight = 5.0;

  const _VerticalZigZagPainter({
    required this.paperColor,
    required this.shadowColor,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || size.width <= 0) return;

    final path = Path();
    final teethPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = paperColor
      ..style = PaintingStyle.fill;

    if (isLeft) {
      path.moveTo(_toothDepth, 0);
      double y = 0;
      bool out = true;
      while (y < size.height) {
        y += _toothHeight;
        if (y > size.height) y = size.height;
        final x = out ? 0.0 : _toothDepth;
        path.lineTo(x, y);
        out = !out;
      }
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width - _toothDepth, 0);
      double y = 0;
      bool out = true;
      while (y < size.height) {
        y += _toothHeight;
        if (y > size.height) y = size.height;
        final x = out ? size.width : size.width - _toothDepth;
        path.lineTo(x, y);
        out = !out;
      }
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, teethPaint);
  }

  @override
  bool shouldRepaint(_VerticalZigZagPainter oldDelegate) =>
      oldDelegate.paperColor != paperColor ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.isLeft != isLeft;
}

