import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';
import 'package:billing_app/core/theme/text_styles.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/inventory_health_card.dart';
import 'package:billing_app/core/widgets/recent_transactions_card.dart';
import 'package:billing_app/core/widgets/payment_donut_chart.dart';
import 'package:billing_app/core/widgets/top_products_bar_chart.dart';
import 'package:billing_app/core/widgets/monthly_trend_card.dart';
import 'package:billing_app/core/widgets/press_scale.dart';
import 'package:billing_app/core/widgets/staggered_fade.dart';
import 'package:billing_app/core/widgets/staff_performance_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// App home — a liquid glass dashboard with greeting, today's sales,
/// recent transactions, inventory health, quick actions and a low-stock
/// alert. First run (no bills yet) shows an onboarding card in place of
/// bill-derived analytics.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const int _lowStockThreshold = 5;

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  void _loadDashboardData() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    context.read<ReportBloc>()
      ..add(LoadDailySales(now))
      ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
      ..add(LoadBillHistory(from: weekAgo, to: now, page: 1, limit: 200))
      ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        // Dashboard is the app root — Android back here should close the app,
        // not pop to a blank route. Sub-pages pop normally to land here.
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : AppColors.lightBg,
        body: Stack(
          children: [
            // ── Lime aurora glows (dark mode only) — like Spendly green aura ──
            if (Theme.of(context).brightness == Brightness.dark) ...[
              // Top-center main glow — bright lime halo at the top
              Positioned(
                top: -120,
                left: -60,
                right: -60,
                height: 520,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.35),
                        radius: 1.05,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.38),
                          AppColors.accent.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Secondary soft wash — spreads lime tint across top 40%
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              // Light mode keeps the soft light gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientFor(context),
                  ),
                ),
              ),
            SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ReportBloc>();
                bloc
                  ..add(LoadDailySales(DateTime.now()))
                  ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold));
                // Wait for the ReportBloc to finish reloading (or timeout) so
                // the spinner reflects real work, not a hardcoded delay.
                final now = DateTime.now();
                await bloc.stream
                    .firstWhere((s) => s.status != ReportStatus.loading)
                    .timeout(
                      const Duration(seconds: 2),
                      onTimeout: () => bloc.state,
                    );
                bloc
                  ..add(LoadBillHistory(
                      from: now.subtract(const Duration(days: 6)),
                      to: now,
                      page: 1,
                      limit: 200))
                  ..add(LoadSalesRange(
                      from: DateTime(now.year, now.month, 1), to: now));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── AppBar ──
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const AdaptiveAppBarLeading(),
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => _showProductSearch(context),
                        icon: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Search products',
                      ),
                    ],
                  ),

                  // ── Content ── (skill Native law 8: home indicator clearance)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm / 2,
                      AppSpacing.lg,
                      96 + MediaQuery.of(context).padding.bottom,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        // Lazy build — each section mounts only when scrolled
                        // near; RepaintBoundary isolates glass card repaints.
                        (context, index) => RepaintBoundary(
                          child: sections[index],
                        ),
                        childCount: sections.length,
                      ),
                    ),
                  ),
                ], // slivers
              ), // CustomScrollView
            ), // RefreshIndicator
          ), // SafeArea
          ], // Stack
        ), // Stack
      ), // Scaffold
    ); // PopScope
  }

  /// Top-level dashboard sections, built per frame but mounted lazily by
  /// the [SliverChildBuilderDelegate] above.
  List<Widget> _buildSections(BuildContext context) {
    return [
      // Compact greeting header
      StaggeredFade(
        index: 0,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            if (previous is! Authenticated || current is! Authenticated) return true;
            return previous.user.name != current.user.name;
          },
          builder: (context, state) {
            final name = state is Authenticated ? state.user.name : '';
            return _CompactHeader(userName: name);
          },
        ),
      ),
      SizedBox(height: AppSpacing.lg),

      // Low stock banner
      const StaggeredFade(
        index: 1,
        child: _LowStockBanner(),
      ),
      SizedBox(height: AppSpacing.lg),

      // ── Hero: Today's Sales ──
      const StaggeredFade(
        index: 2,
        child: PressScale(child: _HeroSalesCard()),
      ),
      SizedBox(height: AppSpacing.lg),

      // ── Primary action ──
      const StaggeredFade(
        index: 3,
        child: PressScale(child: _NewBillButton()),
      ),
      SizedBox(height: AppSpacing.xl),

      // ── Quick Actions ──
      StaggeredFade(index: 4, child: _sectionTitle('Quick Actions')),
      SizedBox(height: AppSpacing.md),
      StaggeredFade(
        index: 5,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            if (previous is! Authenticated || current is! Authenticated) return true;
            return previous.user.role != current.user.role;
          },
          builder: (context, state) => _buildQuickTiles(context, state),
        ),
      ),
      SizedBox(height: AppSpacing.xl),

      // ── Insights: first-run onboarding OR bill analytics ──
      _buildInsightsSection(),
    ];
  }

  /// Bill-derived analytics (Recent Transactions, Payment Donut, Top
  /// Products, Monthly Trend, Staff Performance). Until the very first bill
  /// exists (loaded + empty history) they're replaced by a first-run
  /// onboarding card. Inventory Health always renders — products are
  /// independent of bills.
  Widget _buildInsightsSection() {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.billHistory != current.billHistory,
      builder: (context, state) {
        final showEmpty = state.status == ReportStatus.loaded &&
            state.billHistory.isEmpty;
        if (showEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              StaggeredFade(index: 6, child: _FirstRunCard()),
              SizedBox(height: AppSpacing.xl),
              StaggeredFade(index: 7, child: _InventoryHealth()),
              SizedBox(height: AppSpacing.lg),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // ── Recent Transactions ──
            StaggeredFade(index: 6, child: _RecentTransactions()),
            SizedBox(height: AppSpacing.xl),

            // ── Payment Methods Donut ──
            StaggeredFade(index: 7, child: _PaymentMethodsSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Top Products Bar Chart ──
            StaggeredFade(index: 8, child: _TopProductsSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Monthly / 30-Day Trend ──
            StaggeredFade(index: 9, child: _MonthlyTrendSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Inventory Health ──
            StaggeredFade(index: 10, child: _InventoryHealth()),
            SizedBox(height: AppSpacing.xl),

            // ── Staff Performance ──
            StaggeredFade(index: 11, child: _StaffPerformanceSection()),
            SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }

  void _showProductSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _ProductSearchDelegate(),
    );
  }

  Widget _sectionTitle(String text) {
    final b = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textTertiary(b),
        ),
      ),
    );
  }

  Widget _buildQuickTiles(BuildContext context, AuthState authState) {
    final isOwner =
        authState is Authenticated && authState.user.role == 'owner';

    // Build widgets inline to avoid allocating a List that's recreated
    // on every auth change. Only the owner tile is conditional;
    // the rest are direct children with zero alloc.
    // NOTE: Products & Reports tiles removed — bottom nav now owns
    // those destinations. Surface secondary business features instead.
    // v3.1 (ui-ux-pro-max): stagger entrance + semantic wayfinding colors —
    // business-critical tiles get hue, utilities stay muted (labels carry
    // meaning, color only aids scanning).
    final b = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(b);

    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _quickTile(context, AppColors.warningText(b), Icons.payments_outlined, 'Due Payments', '/due-payments', Duration.zero),
        _quickTile(context, AppColors.infoText(b), Icons.people_outline_rounded, 'Customers', '/customers', const Duration(milliseconds: 60)),
        _quickTile(context, AppColors.successText(b), Icons.category_rounded, 'Categories', '/categories', const Duration(milliseconds: 120)),
        _quickTile(context, AppColors.accentText(b), Icons.verified_outlined, 'Warranty', '/warranty', const Duration(milliseconds: 180)),
        _quickTile(context, muted, Icons.store_rounded, 'Shop', '/shop', const Duration(milliseconds: 240)),
        _quickTile(context, muted, Icons.settings_rounded, 'Settings', '/settings', const Duration(milliseconds: 300)),
        if (isOwner)
          _quickTile(context, muted, Icons.people_rounded, 'Staff', '/staff', const Duration(milliseconds: 360)),
      ],
    );
  }

  /// Quick-action tile wrapped with press-scale feedback (Framer `whileTap`
  /// equivalent) on top of the tile's own staggered fade+slide entry + ripple.
  Widget _quickTile(BuildContext context, Color color, IconData icon,
      String label, String route, Duration staggerDelay) {
    return PressScale(
      child: QuickActionTile(
        icon: icon,
        label: label,
        color: color,
        staggerDelay: staggerDelay,
        onTap: () {
          HapticFeedback.lightImpact();
          context.go(route);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Compact header — greeting + name, flat (no glass)
// ═══════════════════════════════════════════════════════════════════════

class _CompactHeader extends StatelessWidget {
  final String userName;
  const _CompactHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary(b),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '·',
              style: TextStyle(color: AppColors.textTertiary(b)),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('EEE, d MMM').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary(b),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          userName.isEmpty ? 'Welcome' : userName,
          style: AppTypography.displaySmall.copyWith(
            fontSize: 24,
            color: AppColors.textPrimary(b),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Hero sales card — today's total front and center (v3 surface card,
// money in IBM Plex Mono), sub-stats: bills / avg / discount.
// Tap → daily sales report.
// ═══════════════════════════════════════════════════════════════════════

class _HeroSalesCard extends StatelessWidget {
  const _HeroSalesCard();

  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// 7-day totals (oldest → today) from billHistory — single-pass
  /// day grouping. Powers the hero sparkline + delta pill.
  static List<double> _weekValues(List<BillSummary> bills) {
    final now = DateTime.now();
    final Map<int, double> dayTotals = {};
    for (int i = 6; i >= 0; i--) {
      dayTotals[i] = 0.0;
    }
    for (final bill in bills) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(
              bill.createdAt.year, bill.createdAt.month, bill.createdAt.day))
          .inDays;
      if (diff >= 0 && diff <= 6) {
        dayTotals[6 - diff] = (dayTotals[6 - diff] ?? 0) + bill.grandTotal;
      }
    }
    return [for (int i = 6; i >= 0; i--) dayTotals[i] ?? 0];
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;

    return BlocBuilder<ReportBloc, ReportState>(
      // billHistory bhi — sparkline + delta usi se bante hain.
      buildWhen: (a, b) =>
          a.dailySales != b.dailySales ||
          a.status != b.status ||
          a.billHistory != b.billHistory,
      builder: (context, state) {
        final sales = state.dailySales;
        final loading = state.status == ReportStatus.loading && sales == null;

        final totalText =
            loading ? '…' : _inrFormat.format(sales?.totalSales ?? 0);
        final billCount = loading ? '—' : (sales?.billCount ?? 0).toString();
        final avgBill = loading ? '—' : _inrFormat.format(sales?.averageBill ?? 0);
        final discount = loading ? '—' : _inrFormat.format(sales?.totalDiscount ?? 0);

        // Trend context from already-loaded billHistory (no extra fetch).
        final week = _weekValues(state.billHistory);
        final hasTrend = week.any((v) => v > 0);
        final today = week.last;
        final prevAvg = week.take(6).isEmpty
            ? 0.0
            : week.take(6).reduce((a, c) => a + c) / 6;
        final hasDelta = prevAvg > 0;
        final deltaPct = hasDelta ? ((today - prevAvg) / prevAvg) * 100 : 0.0;
        final isUp = deltaPct >= 0;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: AppDurations.normal,
          curve: AppDurations.strongEase,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - t)),
              child: child,
            ),
          ),
          child: Semantics(
            button: true,
            label: 'Today sales $totalText. Tap to view daily sales report.',
            child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/reports/daily-sales'),
              borderRadius: AppRadius.rXl,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface(b),
                  borderRadius: AppRadius.rXl,
                  border: Border.all(color: AppColors.border(b)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "TODAY'S SALES",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textTertiary(b),
                          ),
                        ),
                        const Spacer(),
                        if (hasDelta)
                          _DeltaPill(
                            percent: deltaPct.abs(),
                            isUp: isUp,
                            b: b,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      totalText,
                      style: AppMoneyText.sized(
                        34,
                        FontWeight.w700,
                        AppColors.textPrimary(b),
                      ),
                    ),
                    if (hasTrend) ...[
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        child: SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _SparklinePainter(
                              values: week,
                              color: AppColors.accentText(b),
                              fillColor: AppColors.accentSubtle,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.divider(b)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HeroStat(label: 'Bills', value: billCount, b: b),
                        _HeroDivider(b: b),
                        _HeroStat(label: 'Avg Bill', value: avgBill, b: b),
                        _HeroDivider(b: b),
                        _HeroStat(label: 'Discount', value: discount, b: b),
                        _HeroDivider(b: b),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textTertiary(b),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

/// Delta pill — icon + text + tinted bg (hue never alone).
class _DeltaPill extends StatelessWidget {
  final double percent;
  final bool isUp;
  final Brightness b;

  const _DeltaPill({required this.percent, required this.isUp, required this.b});

  @override
  Widget build(BuildContext context) {
    final color = isUp
        ? AppColors.successText(b)
        : AppColors.error(b);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${percent.toStringAsFixed(percent.abs() >= 10 ? 0 : 1)}% vs avg',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal smooth area sparkline — no dots/labels (hero context).
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color fillColor;

  _SparklinePainter({
    required this.values,
    required this.color,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxVal = values.reduce((a, c) => a > c ? a : c);
    final minVal = values.reduce((a, c) => a < c ? a : c);
    final range = (maxVal - minVal).clamp(1, double.infinity);

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final dx = (i / (values.length - 1)) * size.width;
      final dy = size.height - 4 - ((values[i] - minVal) / range) * (size.height - 8);
      points.add(Offset(dx, dy));
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      line.quadraticBezierTo(prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
    }
    line.lineTo(points.last.dx, points.last.dy);

    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor, fillColor.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Brightness b;

  const _HeroStat({required this.label, required this.value, required this.b});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary(b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppMoneyText.sized(15, FontWeight.w600, AppColors.textPrimary(b)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  final Brightness b;
  const _HeroDivider({required this.b});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: AppColors.divider(b),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Primary action — New Bill (lime pill, the one big accent on this screen)
// ═══════════════════════════════════════════════════════════════════════

class _NewBillButton extends StatelessWidget {
  const _NewBillButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppTouchTarget.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.go('/scan');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.rLg,
          ),
        ),
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
        label: const Text(
          'New Bill',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// First-run onboarding card — replaces the bill-derived analytics sections
// until the shop's first bill exists. Inventory Health still renders.
// ═══════════════════════════════════════════════════════════════════════

class _FirstRunCard extends StatelessWidget {
  const _FirstRunCard();

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppColors.border(b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 26,
              color: AppColors.accentText(b),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chalo shuru karein',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(b),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Apna pehla bill banakar sales tracking start karo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppColors.textTertiary(b),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/scan');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(
                'Create First Bill',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Recent Transactions — last 5 bills from billHistory
// ═══════════════════════════════════════════════════════════════════════

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.billHistory != b.billHistory,
      builder: (context, state) {
        final isLoading = state.status == ReportStatus.loading &&
            state.billHistory.isEmpty;

        // Sort by newest first, take top 5
        final txns = List.of(state.billHistory)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final displayed = txns.take(5).map((bill) {
          // Use items.length if itemCount is 0 (DB might not populate it)
          final count = bill.itemCount > 0
              ? bill.itemCount
              : bill.items.length;
          return RecentTransaction(
            id: bill.id,
            staffName: bill.staffName,
            grandTotal: bill.grandTotal,
            paymentMethod: bill.paymentMethod,
            itemCount: count,
            createdAt: bill.createdAt,
          );
        }).toList();

        if (isLoading) {
          return _buildLoadingPlaceholder(context);
        }

        return RecentTransactionsCard(
          transactions: displayed,
          onViewAll: () => context.go('/reports/bills'),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const darkSurface = AppTheme.darkSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? darkSurface.withValues(alpha: 0.70)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? darkSurface.withValues(alpha: 0.50)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Transactions',
              style: AppTextStyles.of(context).txnTitle),
          const SizedBox(height: 20),
          ...List.generate(3, (i) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: _SkeletonBox(radius: 10),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 12,
                        child: _SkeletonBox(radius: 6),
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        width: 50,
                        height: 10,
                        child: _SkeletonBox(radius: 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 14,
                  child: _SkeletonBox(radius: 6),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double radius;
  const _SkeletonBox({required this.radius});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Payment Methods Donut Chart
// ═══════════════════════════════════════════════════════════════════════

class _PaymentMethodsSection extends StatelessWidget {
  const _PaymentMethodsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.billHistory != b.billHistory,
      builder: (context, state) {
        final Map<String, double> totals = {};
        final Map<String, int> counts = {};
        for (final bill in state.billHistory) {
          final method = bill.paymentMethod.isEmpty ? 'Unknown' : bill.paymentMethod;
          totals[method] = (totals[method] ?? 0) + bill.grandTotal;
          counts[method] = (counts[method] ?? 0) + 1;
        }
        return PaymentDonutChart(paymentTotals: totals, paymentCounts: counts);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Top Products Bar Chart
// ═══════════════════════════════════════════════════════════════════════

class _TopProductsSection extends StatelessWidget {
  const _TopProductsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.billHistory != b.billHistory,
      builder: (context, state) {
        final products = ProductAggregator.topProducts(state.billHistory, limit: 5);
        return TopProductsBarChart(products: products);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Monthly / 30-Day Sales Trend
// ═══════════════════════════════════════════════════════════════════════

class _MonthlyTrendSection extends StatelessWidget {
  const _MonthlyTrendSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.salesRange != b.salesRange,
      builder: (context, state) {
        final range = state.salesRange;
        if (range.isEmpty) {
          return const MonthlyTrendCard(values: [], labels: []);
        }
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 29));
        final filtered = range
            .where((d) => d.date.isAfter(thirtyDaysAgo.subtract(const Duration(days: 1))))
            .toList();
        filtered.sort((a, b) => a.date.compareTo(b.date));

        final values = filtered.map((d) => d.totalSales).toList();
        final labels = filtered.map((d) => DateFormat('dd MMM').format(d.date)).toList();
        return MonthlyTrendCard(values: values, labels: labels);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Staff Performance Leaderboard
// ═══════════════════════════════════════════════════════════════════════

class _StaffPerformanceSection extends StatelessWidget {
  const _StaffPerformanceSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (a, b) => a is Authenticated && b is Authenticated && a.user.role != b.user.role,
      builder: (context, authState) {
        final isOwner = authState is Authenticated && authState.user.role == 'owner';
        if (!isOwner) return const SizedBox.shrink();
        return BlocBuilder<ReportBloc, ReportState>(
          buildWhen: (a, b) => a.billHistory != b.billHistory,
          builder: (context, state) {
            final staff = StaffAggregator.weeklyPerformance(state.billHistory, limit: 5);
            return StaffPerformanceCard(staff: staff);
          },
        );
      },
    );
  }
}



// ═══════════════════════════════════════════════════════════════════════
// Inventory Health — product stats from ProductBloc
// ═══════════════════════════════════════════════════════════════════════

class _InventoryHealth extends StatelessWidget {
  const _InventoryHealth();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (a, b) => a.products != b.products,
      builder: (context, state) {
        final products = state.products;
        final total = products.length;
        // Single-pass filter instead of two separate .where() calls
        int lowStock = 0;
        int outOfStock = 0;
        for (final p in products) {
          if (p.stock <= 0) {
            outOfStock++;
          } else if (p.stock <= 5) {
            lowStock++;
          }
        }

        return InventoryHealthCard(
          totalProducts: total,
          lowStockCount: lowStock,
          outOfStockCount: outOfStock,
          onViewDetails: () => context.go('/reports/low-stock'),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Low Stock Banner — glass warning card
// ═══════════════════════════════════════════════════════════════════════

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.lowStockProducts != b.lowStockProducts,
      builder: (context, state) {
        final count = state.lowStockProducts.length;
        if (count == 0) return const SizedBox.shrink();
        final b = Theme.of(context).brightness;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.error(b).withValues(alpha: 0.10),
                AppColors.error(b).withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error(b).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/reports/low-stock'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error(b).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error(b),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$count item${count == 1 ? '' : 's'} running low on stock',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error(b),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.error(b).withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Product Search Delegate
// ═══════════════════════════════════════════════════════════════════════

class _ProductSearchDelegate extends SearchDelegate<Product?> {
  @override
  String get searchFieldLabel => 'Search product name, barcode or description';

  @override
  ThemeData appBarTheme(BuildContext searchContext) {
    final theme = Theme.of(searchContext);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  List<Product> _getAllProducts(BuildContext context) {
    final productState = context.read<ProductBloc>().state;
    return productState.products;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
        tooltip: 'Clear',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: 'Close',
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final allProducts = _getAllProducts(context);
    final queryLower = query.toLowerCase().trim();
    final b = Theme.of(context).brightness;

    if (queryLower.isEmpty) {
      return Center(
        child: Text(
          'Type to search products',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15),
        ),
      );
    }

    final results = allProducts.where((product) {
      return product.name.toLowerCase().contains(queryLower) ||
          product.barcode.toLowerCase().contains(queryLower) ||
          (product.description?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No products found for "$query"',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.accentSubtle,
            child: Icon(Icons.inventory_2_outlined,
                color: AppColors.accentText(b), size: 20),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppColors.accentText(b),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Barcode: ${product.barcode}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (queryLower.isNotEmpty &&
                  product.description != null &&
                  product.description!
                      .toLowerCase()
                      .contains(queryLower)) ...[
                const SizedBox(height: 4),
                _buildDescriptionSnippet(context, product.description!, queryLower),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: () {
            close(context, product);
            context.push('/products/detail/${product.id}', extra: product);
          },
        );
      },
    );
  }

  Widget _buildDescriptionSnippet(BuildContext context, String description, String query) {
    final b = Theme.of(context).brightness;
    final lowerDesc = description.toLowerCase();
    final index = lowerDesc.indexOf(query);

    int start = (index - 10).clamp(0, description.length);
    int end = (index + query.length + 20).clamp(0, description.length);
    String snippet = description.substring(start, end).trim();
    if (start > 0) snippet = '...$snippet';
    if (end < description.length) snippet = '$snippet...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.saved_search_rounded,
              size: 12, color: AppColors.warningText(b)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              snippet,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.warningText(b),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
