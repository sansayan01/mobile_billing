import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/core/theme/app_dimensions.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/count_up_money.dart';
import 'package:billing_app/core/widgets/inventory_health_card.dart';
import 'package:billing_app/core/widgets/recent_transactions_card.dart';
import 'package:billing_app/core/widgets/payment_donut_chart.dart';
import 'package:billing_app/core/widgets/top_products_bar_chart.dart';
import 'package:billing_app/core/widgets/monthly_trend_card.dart';
import 'package:billing_app/core/widgets/press_scale.dart';
import 'package:billing_app/core/widgets/dashboard_skeletons.dart';
import 'package:billing_app/core/widgets/staggered_fade.dart';
import 'package:billing_app/core/widgets/sliding_capsule_selector.dart';
import 'package:billing_app/core/widgets/staff_performance_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/domain/entities/user.dart';
import 'package:billing_app/features/due_payments/presentation/bloc/due_payments_bloc.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:flutter/material.dart';
import 'package:billing_app/core/widgets/adaptive_app_bar_leading.dart';
import 'package:billing_app/core/widgets/aurora_glow.dart';
import 'package:billing_app/core/widgets/sheen_effect.dart';
import 'package:billing_app/core/widgets/live_pulse_badge.dart';
import 'package:billing_app/core/widgets/interactive_sparkline.dart';
import 'package:billing_app/core/widgets/animated_switcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui' show lerpDouble;
import 'dart:math' as math;

/// App home — a liquid glass dashboard with greeting, today's sales,
/// recent transactions, inventory health, quick actions and a low-stock
/// alert. First run (no bills yet) shows an onboarding card in place of
/// bill-derived analytics.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const int _lowStockThreshold = 5;

  @override
  Widget build(BuildContext context) {
    // Own bloc instance — feeds the Due Payments badge on the quick tile
    // (fresh load on dashboard entry, disposed with the page).
    return BlocProvider<DuePaymentsBloc>(
      create: (_) => sl<DuePaymentsBloc>()..add(const LoadDuePayments()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with WidgetsBindingObserver {
  /// Tracks the calendar day the dashboard data was loaded for — when the
  /// app resumes and the day has rolled over (overnight idle), data reloads
  /// so "Today's Sales" reflects the new day.
  DateTime _loadedForDay = DateTime.now();

  /// Scroll depth of the hero card — matches the Android single punch-hole tuck-in depth
  static const double _heroFoldOffset = 245;
  late final ScrollController _scrollCtrl = ScrollController()
    ..addListener(_onScroll);
  double _lastOffset = 0;
  bool _isScrollingDown = false;
  bool _notchIslandVisible = false;
  bool _showTodayPill = false;
  String _quickActionFilter = 'All';

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final currentOffset = _scrollCtrl.offset;
    final isDown = currentOffset > _lastOffset && currentOffset > 30;
    final showIsland = currentOffset > _heroFoldOffset;

    if (showIsland != _notchIslandVisible || (showIsland && isDown != _isScrollingDown)) {
      setState(() {
        _notchIslandVisible = showIsland;
        _isScrollingDown = isDown;
        _showTodayPill = showIsland;
      });
    }
    _lastOffset = currentOffset;
  }

  void _loadDashboardData() {
    final now = DateTime.now();
    _loadedForDay = now;
    final weekAgo = now.subtract(const Duration(days: 6));
    context.read<ReportBloc>()
      ..add(LoadDailySales(now))
      ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
      ..add(LoadFullBillHistory(from: weekAgo, to: now))
      ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now));
    // Inventory Health card reads from ProductBloc — refresh it too so
    // stock counts aren't stale.
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App resumed from background — if the calendar day changed while we
    // were away, reload so "Today's Sales" isn't yesterday's numbers.
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (!_isSameDay(now, _loadedForDay)) {
        _loadDashboardData();
      }
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
            // ── Lime aurora glow (dark mode only) — slow breathing drift ──
            if (Theme.of(context).brightness == Brightness.dark) ...[
              // Main halo — bright lime breathing glow at the top
              Positioned(
                top: -180,
                left: -60,
                right: -60,
                height: 520,
                child: IgnorePointer(
                  child: Center(
                    child: AuroraGlow(
                      color: AppColors.accent,
                      size: 560,
                      period: const Duration(seconds: 10),
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
                HapticFeedback.mediumImpact();
                // Fire ALL refresh events up front — the spinner covers the
                // entire reload, not just the first two queries.
                final now = DateTime.now();
                final bloc = context.read<ReportBloc>();
                final productBloc = context.read<ProductBloc>();
                bloc
                  ..add(LoadDailySales(now))
                  ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
                  ..add(LoadFullBillHistory(from: now.subtract(const Duration(days: 6)), to: now))
                  ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now));
                productBloc.add(LoadProducts());

                // Wait until the ReportBloc is no longer loading (or timeout)
                // so the spinner reflects real work, not a hardcoded delay.
                // Timeout guard: one dropped request shouldn't spin forever.
                await bloc.stream
                    .firstWhere((s) => s.status != ReportStatus.loading)
                    .timeout(
                      const Duration(seconds: 5),
                      onTimeout: () => bloc.state,
                    );
              },
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── AppBar ── (title morphs to a live "Today: ₹X" pill
                  // once the hero scrolls out of view — number stays visible)
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const AdaptiveAppBarLeading(),
                    title: _DashAppBarTitle(showPill: _showTodayPill),
                    actions: [
                      PressScale(
                        pressedScale: 0.90,
                        child: IconButton(
                          onPressed: () => _showProductSearch(context),
                          icon: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          tooltip: 'Search products',
                        ),
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

          // ── Camera Notch Dynamic Island (Hero Sales Morph) ──
          AnimatedBuilder(
            animation: _scrollCtrl,
            builder: (context, _) => _DynamicNotchIsland(
              visible: _notchIslandVisible,
              isCompact: _isScrollingDown,
              scrollOffset: _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0,
              onTap: () {
                HapticFeedback.mediumImpact();
                _scrollCtrl.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              onLongPress: () {
              HapticFeedback.heavyImpact();
              final state = context.read<ReportBloc>().state;
              final total = state.dailySales?.totalSales ?? 0.0;
              final billCount = state.dailySales?.billCount ?? 0;
              final avg = state.dailySales?.averageBill ?? 0.0;
              final discount = state.dailySales?.totalDiscount ?? 0.0;
              _showHeroInsightSheet(
                context,
                periodTitle: "TODAY'S SALES",
                totalSales: total,
                billCount: billCount,
                avgBill: avg,
                discount: discount,
                bills: state.billHistory,
              );
            },
          ),
        ),
          ], // Stack
        ), // Stack
      ), // Scaffold
    ); // PopScope
  }

  /// Top-level dashboard sections, built per frame but mounted lazily by
  /// the [SliverChildBuilderDelegate] above.
  List<Widget> _buildSections(BuildContext context) {
    return [
      // Error banner — network failure on any report query
      const StaggeredFade(
        index: 0,
        child: _ErrorBanner(),
      ),
      SizedBox(height: AppSpacing.md),

      // Compact greeting header
      StaggeredFade(
        index: 1,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            if (previous is! Authenticated || current is! Authenticated) return true;
            return previous.user.name != current.user.name;
          },
          builder: (context, state) {
            final name = state is Authenticated ? state.user.name : '';
            return _CompactHeader(
              userName: name,
              onAvatarTap: () {
                HapticFeedback.lightImpact();
                if (state is Authenticated) {
                  _showCashierStatusSheet(context, state.user);
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            );
          },
        ),
      ),
      SizedBox(height: AppSpacing.lg),

      // Low stock banner
      const StaggeredFade(
        index: 2,
        child: _LowStockBanner(),
      ),
      SizedBox(height: AppSpacing.lg),

      // ── Hero: Today's Sales ──
      StaggeredFade(
        index: 3,
        child: PressScale(
          child: _HeroSalesCard(scrollController: _scrollCtrl),
        ),
      ),
      SizedBox(height: AppSpacing.lg),

      // ── Primary action ──
      const StaggeredFade(
        index: 4,
        child: _NewBillButton(),
      ),
      SizedBox(height: AppSpacing.xl),

      // ── Quick Actions ──
      StaggeredFade(
        index: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Quick Actions'),
            _buildQuickActionFilterBar(context),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      StaggeredFade(
        index: 6,
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
              StaggeredFade(index: 7, child: _FirstRunCard()),
              SizedBox(height: AppSpacing.xl),
              StaggeredFade(index: 8, child: _InventoryHealth()),
              SizedBox(height: AppSpacing.lg),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // ── Recent Transactions ──
            StaggeredFade(index: 7, child: _RecentTransactions()),
            SizedBox(height: AppSpacing.xl),

            // ── Payment Methods Donut ──
            StaggeredFade(index: 8, child: _PaymentMethodsSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Top Products Bar Chart ──
            StaggeredFade(index: 9, child: _TopProductsSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Monthly / 30-Day Trend ──
            StaggeredFade(index: 10, child: _MonthlyTrendSection()),
            SizedBox(height: AppSpacing.xl),

            // ── Inventory Health ──
            StaggeredFade(index: 11, child: _InventoryHealth()),
            SizedBox(height: AppSpacing.xl),

            // ── Staff Performance ──
            StaggeredFade(index: 12, child: _StaffPerformanceSection()),
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

  Widget _buildQuickActionFilterBar(BuildContext context) {
    const categories = ['All', 'Sales', 'Stock', 'Shop'];
    final idx = categories.indexOf(_quickActionFilter);

    return SizedBox(
      width: 196,
      child: SlidingCapsuleSelector(
        items: categories,
        selectedIndex: idx >= 0 ? idx : 0,
        height: 28,
        fontSize: 10.5,
        onSelected: (i) {
          setState(() => _quickActionFilter = categories[i]);
        },
      ),
    );
  }

  Widget _buildQuickTiles(BuildContext context, AuthState authState) {
    final isOwner =
        authState is Authenticated && authState.user.role == 'owner';
    final b = Theme.of(context).brightness;
    final accent = AppColors.accentText(b);
    final muted = AppColors.textSecondary(b);

    final allTiles = <(String, Widget)>[
      ('Sales', _quickTile(
        context,
        AppColors.warningText(b),
        Icons.payments_rounded,
        'Due Payments',
        '/due-payments',
        Duration.zero,
        badge: const _DueBadge(),
      )),
      ('Sales', _quickTile(
        context,
        accent,
        Icons.people_alt_rounded,
        'Customers',
        '/customers',
        const Duration(milliseconds: 40),
      )),
      ('Stock', _quickTile(
        context,
        accent,
        Icons.category_rounded,
        'Categories',
        '/categories',
        const Duration(milliseconds: 80),
      )),
      ('Sales', _quickTile(
        context,
        accent,
        Icons.verified_rounded,
        'Warranty',
        '/warranty',
        const Duration(milliseconds: 120),
      )),
      ('Stock', _quickTile(
        context,
        accent,
        Icons.broken_image_rounded,
        'Damaged',
        '/damaged-products',
        const Duration(milliseconds: 160),
      )),
      ('Shop', _quickTile(
        context,
        muted,
        Icons.storefront_rounded,
        'Shop',
        '/shop',
        const Duration(milliseconds: 200),
      )),
      ('Shop', _quickTile(
        context,
        muted,
        isOwner ? Icons.badge_rounded : Icons.history_rounded,
        isOwner ? 'Staff' : 'Stock Log',
        isOwner ? '/staff' : '/reports/stock-movements',
        const Duration(milliseconds: 240),
      )),
      ('Shop', _quickTile(
        context,
        muted,
        Icons.settings_rounded,
        'Settings',
        '/settings',
        const Duration(milliseconds: 280),
      )),
    ];

    final filteredTiles = _quickActionFilter == 'All'
        ? allTiles.map((e) => e.$2).toList()
        : allTiles
            .where((e) => e.$1 == _quickActionFilter)
            .map((e) => e.$2)
            .toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: GridView.count(
        key: ValueKey('grid-$_quickActionFilter'),
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm * 1.5,
        crossAxisSpacing: AppSpacing.sm * 1.5,
        childAspectRatio: 0.80,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: filteredTiles,
      ),
    );
  }

  /// Quick-action tile wrapped with press-scale feedback (Framer `whileTap`
  /// equivalent) on top of the tile's own staggered fade+slide entry + ripple.
  Widget _quickTile(BuildContext context, Color color, IconData icon,
      String label, String route, Duration staggerDelay,
      {Widget? badge}) {
    return PressScale(
      child: QuickActionTile(
        icon: icon,
        label: label,
        color: color,
        staggerDelay: staggerDelay,
        badge: badge,
        onTap: () {
          HapticFeedback.lightImpact();
          context.go(route);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AppBar title — "Dashboard", crossfading to a live "Today: ₹X" pill
// once the hero card scrolls out of view (sticky number, Monex-style).
// ═══════════════════════════════════════════════════════════════════════

class _DashAppBarTitle extends StatelessWidget {
  final bool showPill;
  const _DashAppBarTitle({required this.showPill});

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (p, c) => p.dailySales?.totalSales != c.dailySales?.totalSales,
      builder: (context, state) {
        final total = state.dailySales?.totalSales ?? 0.0;
        final fmt = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: showPill
              ? Container(
                  key: ValueKey('today-pill-$total'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentText(b),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Today ${fmt.format(total)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentText(b),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  'Dashboard',
                  key: const ValueKey('title'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Android Single Punch-Hole Camera Circle Notch (1:1 Aspect Ratio)
// Docks directly over the front camera punch-hole cutout;
// displays active electric lime energy ring indicating consumed sales card.
// ═══════════════════════════════════════════════════════════════════════

class _DynamicNotchIsland extends StatelessWidget {
  final bool visible;
  final bool isCompact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double scrollOffset;

  const _DynamicNotchIsland({
    required this.visible,
    required this.isCompact,
    required this.onTap,
    this.onLongPress,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.of(context).padding.top;
    final topPosition = topInset > 0
        ? ((topInset - 24) / 2).clamp(4.0, 10.0)
        : 6.0;

    // Razor lighting only activates during card compaction/expansion:
    // When scrollOffset <= 120 (card uncompacted): razor OFF (0.0)
    // When 120 < scrollOffset < 245 (active suction/expansion zone): razor ON
    // When scrollOffset >= 245 (card fully compacted): razor OFF (0.0)
    // The razor beam cone contracts both in width and height to match the card!
    final double beamProgress;
    final double cardHalfWidth;
    final double beamHeight;
    if (scrollOffset <= 120.0 || scrollOffset >= 245.0) {
      beamProgress = 0.0;
      cardHalfWidth = 0.0;
      beamHeight = 0.0;
    } else {
      final t = ((scrollOffset - 120.0) / 125.0).clamp(0.0, 1.0);
      final curveT = Curves.easeInOutCubic.transform(t);
      final strikeIn = (t / 0.12).clamp(0.0, 1.0);
      final strikeOut = ((1.0 - t) / 0.12).clamp(0.0, 1.0);
      beamProgress = (strikeIn * strikeOut).clamp(0.0, 1.0);

      // Card scales from 1.0 down to 0.08:
      final scaleX = lerpDouble(1.0, 0.08, curveT)!;
      final uncompactedHalfWidth = (screenWidth - 32.0) / 2;
      cardHalfWidth = uncompactedHalfWidth * scaleX;

      // Distance from notch aperture down to top edge of card:
      beamHeight = lerpDouble(175.0, 10.0, curveT)!;
    }

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ── Alien Tractor Beam (Razor Laser Cone Light) ──
          // Strictly spans from notch aperture to the card's exact bounds — zero spill onto other elements!
          if (beamProgress > 0.01)
            Positioned(
              top: 12,
              child: IgnorePointer(
                child: Opacity(
                  opacity: beamProgress,
                  child: CustomPaint(
                    size: Size(screenWidth, beamHeight),
                    painter: _TractorBeamPainter(
                      color: AppColors.accent,
                      progress: beamProgress,
                      cardHalfWidth: cardHalfWidth,
                      beamHeight: beamHeight,
                    ),
                  ),
                ),
              ),
            ),

          // ── The Notch Emitter Core (Alien Mothership Aperture) ──
          Center(
            child: AnimatedSlide(
              offset: (visible || beamProgress > 0.01)
                  ? Offset.zero
                  : const Offset(0, -1.6),
              duration: const Duration(milliseconds: 200),
              curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
              child: AnimatedOpacity(
                opacity: (visible || beamProgress > 0.01) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !visible,
                  child: PressScale(
                    pressedScale: 0.86,
                    child: GestureDetector(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF04060A) : Colors.black,
                          border: Border.all(
                            color: beamProgress > 0.05
                                ? Colors.white
                                : AppColors.accent.withValues(alpha: 0.85),
                            width: beamProgress > 0.05 ? 2.2 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(
                                alpha: beamProgress > 0.05 ? 0.95 : 0.45,
                              ),
                              blurRadius: beamProgress > 0.05 ? 16 : 6,
                              spreadRadius: beamProgress > 0.05 ? 3 : 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.95),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering a luminous alien tractor beam / razor cone
/// shooting downwards from the notch to the card.
/// Strictly tracks the card's width and distance so light never spills onto other elements.
class _TractorBeamPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double cardHalfWidth;
  final double beamHeight;

  const _TractorBeamPainter({
    required this.color,
    required this.progress,
    required this.cardHalfWidth,
    required this.beamHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001 || beamHeight <= 2.0) return;

    final centerX = size.width / 2;
    // Notch aperture emitter width (starts at 6px, narrows slightly as card enters)
    final topHalfWidth = lerpDouble(6.0, 2.0, (1.0 - progress).clamp(0.0, 1.0))!;
    final bottomSpread = cardHalfWidth.clamp(topHalfWidth, size.width / 2);

    // 1. Volumetric Light Cone — strictly bounded to the card's width and current height!
    final conePath = Path()
      ..moveTo(centerX - topHalfWidth, 0)
      ..lineTo(centerX - bottomSpread, beamHeight)
      ..lineTo(centerX + bottomSpread, beamHeight)
      ..lineTo(centerX + topHalfWidth, 0)
      ..close();

    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.60 * progress),
          color.withValues(alpha: 0.20 * progress),
          color.withValues(alpha: 0.02 * progress),
        ],
        stops: const [0.0, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(centerX - bottomSpread, 0, bottomSpread * 2, beamHeight));

    canvas.drawPath(conePath, conePaint);

    // 2. Central Ultra-Sharp Razor Laser Ray
    final razorBottomSpread = (bottomSpread * 0.28).clamp(2.0, bottomSpread);
    final razorPath = Path()
      ..moveTo(centerX - 1.5, 0)
      ..lineTo(centerX - razorBottomSpread, beamHeight)
      ..lineTo(centerX + razorBottomSpread, beamHeight)
      ..lineTo(centerX + 1.5, 0)
      ..close();

    final razorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.95 * progress),
          color.withValues(alpha: 0.55 * progress),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(centerX - razorBottomSpread, 0, razorBottomSpread * 2, beamHeight));

    canvas.drawPath(razorPath, razorPaint);

    // 3. Razor Boundary Lines (hard holographic light edges terminating exactly at card left & right)
    final edgePaint = Paint()
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.95 * progress),
          color.withValues(alpha: 0.65 * progress),
          color.withValues(alpha: 0.10 * progress),
        ],
      ).createShader(Rect.fromLTWH(centerX - bottomSpread, 0, bottomSpread * 2, beamHeight));

    canvas.drawLine(
      Offset(centerX - topHalfWidth, 0),
      Offset(centerX - bottomSpread, beamHeight),
      edgePaint,
    );
    canvas.drawLine(
      Offset(centerX + topHalfWidth, 0),
      Offset(centerX + bottomSpread, beamHeight),
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(_TractorBeamPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.cardHalfWidth != cardHalfWidth ||
      oldDelegate.beamHeight != beamHeight ||
      oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════════════
// Compact header — greeting + name + interactive profile avatar
// ═══════════════════════════════════════════════════════════════════════

class _CompactHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  const _CompactHeader({required this.userName, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final (greetingIcon, greetingColor) = hour < 12
        ? (Icons.wb_twilight_rounded, const Color(0xFFF59E0B))
        : hour < 17
            ? (Icons.wb_sunny_rounded, const Color(0xFFEAB308))
            : (Icons.nightlight_round, const Color(0xFF818CF8));
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'B';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetingIcon, size: 16, color: greetingColor),
                  const SizedBox(width: 6),
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
              const SizedBox(height: 4),
              Text(
                userName.isEmpty ? 'Welcome' : userName,
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary(b),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const LivePulseBadge(label: 'Live Sync'),
            const SizedBox(height: 6),
            PressScale(
              pressedScale: 0.90,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAvatarTap ??
                    () {
                      HapticFeedback.lightImpact();
                      Scaffold.of(context).openDrawer();
                    },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent.withValues(alpha: isDark ? 0.30 : 0.40),
                        AppColors.accent.withValues(alpha: isDark ? 0.10 : 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: isDark ? 0.60 : 0.50),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentText(b),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Hero sales card — today's / 7-day / 30-day totals with interactive
// segmented pill switcher, sparkline, interactive sub-stats, and modal
// breakdown sheet with spring entrance.
// ═══════════════════════════════════════════════════════════════════════

class _HeroSalesCard extends StatefulWidget {
  final ScrollController? scrollController;
  const _HeroSalesCard({this.scrollController});

  @override
  State<_HeroSalesCard> createState() => _HeroSalesCardState();
}

class _HeroSalesCardState extends State<_HeroSalesCard> {
  int _selectedRange = 0; // 0: Today, 1: 7 Days, 2: 30 Days
  int _activeStatIndex = -1; // 0: Bills, 1: Avg Bill, 2: Discount

  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// 7-day day-by-day stats (oldest → today) from billHistory.
  /// Powers the interactive hero sparkline + delta pill.
  static List<SparkDayData> _weekDayData(List<BillSummary> bills) {
    final now = DateTime.now();
    final Map<int, double> dayTotals = {for (int i = 0; i < 7; i++) i: 0.0};
    final Map<int, int> dayCounts = {for (int i = 0; i < 7; i++) i: 0};
    for (final bill in bills) {
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(
              bill.createdAt.year, bill.createdAt.month, bill.createdAt.day))
          .inDays;
      if (diff >= 0 && diff <= 6) {
        final idx = 6 - diff;
        dayTotals[idx] = (dayTotals[idx] ?? 0) + bill.grandTotal;
        dayCounts[idx] = (dayCounts[idx] ?? 0) + 1;
      }
    }
    return [
      for (int i = 6; i >= 0; i--)
        SparkDayData(
          date: now.subtract(Duration(days: i)),
          total: dayTotals[6 - i] ?? 0.0,
          billCount: dayCounts[6 - i] ?? 0,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;

    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) =>
          a.dailySales != b.dailySales ||
          a.status != b.status ||
          a.billHistory != b.billHistory ||
          a.salesRange != b.salesRange,
      builder: (context, state) {
        final sales = state.dailySales;
        final loading = state.status == ReportStatus.loading && sales == null;

        // 7-day data
        final weekDays = _weekDayData(state.billHistory);
        final hasTrend = weekDays.any((d) => d.total > 0);
        final today = weekDays.last.total;
        final prevDays = weekDays.take(6).toList();
        final prevAvg = prevDays.isEmpty
            ? 0.0
            : prevDays.map((d) => d.total).reduce((a, c) => a + c) / 6;
        final hasDelta = prevAvg > 0;
        final deltaPct = hasDelta ? ((today - prevAvg) / prevAvg) * 100 : 0.0;
        final isUp = deltaPct >= 0;

        // Compute metrics for active range
        double activeRevenue = 0.0;
        int activeBills = 0;
        double activeAvg = 0.0;
        double activeDiscount = 0.0;
        String rangeTitle = "TODAY'S SALES";

        if (_selectedRange == 0) {
          rangeTitle = "TODAY'S SALES";
          activeRevenue = sales?.totalSales ?? 0.0;
          activeBills = sales?.billCount ?? 0;
          activeAvg = sales?.averageBill ?? 0.0;
          activeDiscount = sales?.totalDiscount ?? 0.0;
        } else if (_selectedRange == 1) {
          rangeTitle = "7-DAY SALES";
          activeRevenue = state.billHistory
              .fold<double>(0, (sum, item) => sum + item.grandTotal);
          activeBills = state.billHistory.length;
          activeAvg = activeBills > 0 ? activeRevenue / activeBills : 0.0;
          activeDiscount = state.billHistory
              .fold<double>(0, (sum, item) => sum + item.discount);
        } else {
          rangeTitle = "30-DAY SALES";
          activeRevenue = state.salesRange
              .fold<double>(0, (sum, item) => sum + item.totalSales);
          activeBills = state.salesRange
              .fold<int>(0, (sum, item) => sum + item.billCount);
          activeAvg = activeBills > 0 ? activeRevenue / activeBills : 0.0;
          activeDiscount = state.salesRange
              .fold<double>(0, (sum, item) => sum + item.totalDiscount);
        }

        final billCountText = loading ? '—' : activeBills.toString();
        final avgBillText = loading ? '—' : _inrFormat.format(activeAvg);
        final discountText = loading ? '—' : _inrFormat.format(activeDiscount);

        return AnimatedSwap(
          child: loading
              ? const HeroCardSkeleton(key: ValueKey('hero-skeleton'))
              : AnimatedBuilder(
                  animation: widget.scrollController ?? ScrollController(),
                  builder: (context, child) {
                    final offset = (widget.scrollController?.hasClients == true)
                        ? widget.scrollController!.offset
                        : 0.0;

                    // Alien Spaceship Tractor Beam Pull Mechanics:
                    // Phase 1 (offset <= 120): Card scrolls naturally at 100% scale. Razor is OFF.
                    // Phase 2 (120 < offset < 245): Tractor beam strikes and locks on!
                    // Card is beamed up with 3D perspective distortion. Razor is ON.
                    // Phase 3 (offset >= 245): Card is fully compact / swallowed into notch. Razor is BAND/OFF!
                    const double startMorphOffset = 120.0;
                    const double morphDistance = 125.0; // Exact match to _heroFoldOffset (245)

                    final double t;
                    final double parallaxDy;
                    if (offset <= startMorphOffset) {
                      t = 0.0;
                      parallaxDy = 0.0;
                    } else {
                      final morphProgress = offset - startMorphOffset;
                      t = (morphProgress / morphDistance).clamp(0.0, 1.0);
                      // Card is held suspended in the tractor beam, pulled straight up towards the notch
                      parallaxDy = morphProgress * 0.74;
                    }

                    final curveT = Curves.easeInOutCubic.transform(t);

                    // Razor lighting intensity: strikes instantly when compact starts, shuts off when compact completes
                    final razorIntensity = (t <= 0.0 || t >= 1.0)
                        ? 0.0
                        : ((t / 0.12).clamp(0.0, 1.0) * ((1.0 - t) / 0.12).clamp(0.0, 1.0));

                    // Alien Tractor Beam Pull Transformation:
                    // Rather than shrinking into a circle, the card preserves its card structure
                    // and undergoes tractor beam compression & upward elongation:
                    // - scaleX: Compresses horizontally into the razor cone width (1.0 -> 0.08)
                    // - scaleY: Vertically stretches/distorts as tractor gravity pulls it (1.0 -> 0.03)
                    final scaleX = lerpDouble(1.0, 0.08, curveT)!;
                    final scaleY = lerpDouble(1.0, 0.03, math.pow(curveT, 1.15).toDouble())!;

                    // Card fades out as it enters the final aperture
                    final cardOpacity = t < 0.92
                        ? 1.0
                        : ((1.0 - t) / 0.08).clamp(0.0, 1.0);

                    // Elements get scrambled/dissolved by the tractor beam energy:
                    // 1) Bottom sparkline & stats row dissolve (t = 0.28)
                    final subDetailsOpacity = (1.0 - t * 3.4).clamp(0.0, 1.0);
                    // 2) Top header row dissolves (t = 0.40)
                    final headerOpacity = (1.0 - t * 2.5).clamp(0.0, 1.0);
                    // 3) Money amount dissolves into laser light energy (t = 0.55)
                    final amountOpacity = (1.0 - t * 1.8).clamp(0.0, 1.0);

                    // Corner radius stays angular/card-like (24.0 to 14.0), NOT morphing into a circle!
                    final radius = lerpDouble(24.0, 14.0, curveT)!;

                    return Transform.translate(
                      offset: Offset(0, parallaxDy),
                      child: Transform(
                        transform: (Matrix4.identity()
                          ..setEntry(3, 2, 0.0015) // Subtle 3D perspective tilt as it's pulled up
                          ..rotateX(-0.35 * curveT))
                          * Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: cardOpacity,
                          child: Semantics(
                            button: true,
                            label:
                                '$rangeTitle ${_inrFormat.format(activeRevenue)}. Tap for breakdown.',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showHeroInsightSheet(
                                    context,
                                    periodTitle: rangeTitle,
                                    totalSales: activeRevenue,
                                    billCount: activeBills,
                                    avgBill: activeAvg,
                                    discount: activeDiscount,
                                    bills: state.billHistory,
                                  );
                                },
                                borderRadius: BorderRadius.circular(radius),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: lerpDouble(
                                        AppSpacing.xl, AppSpacing.lg, curveT)!,
                                    vertical: lerpDouble(
                                        AppSpacing.xl, AppSpacing.md, curveT)!,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t > 0.05
                                        ? Color.lerp(
                                            AppColors.surface(b),
                                            isDark
                                                ? const Color(0xFF04060A)
                                                : Colors.black,
                                            curveT)
                                        : AppColors.surface(b),
                                    borderRadius: BorderRadius.circular(radius),
                                    border: Border.all(
                                      color: razorIntensity > 0.05
                                          ? Color.lerp(
                                              AppColors.border(b),
                                              Colors.white,
                                              razorIntensity)!
                                          : AppColors.border(b),
                                      width: lerpDouble(1.0, 2.0, razorIntensity)!,
                                    ),
                                    boxShadow: razorIntensity > 0.05
                                        ? [
                                            // Razor energy field locked strictly to the card outline — zero spillover
                                            BoxShadow(
                                              color: AppColors.accent.withValues(
                                                  alpha: 0.60 * razorIntensity),
                                              blurRadius: 4,
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                  alpha: 0.35 * razorIntensity),
                                              blurRadius: 2,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Opacity(
                                            opacity: headerOpacity,
                                            child: Row(
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  child: Text(
                                                    rangeTitle,
                                                    key: ValueKey(rangeTitle),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 1.2,
                                                      color: AppColors.textTertiary(b),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (_selectedRange == 0 && hasDelta)
                                                  _DeltaPill(
                                                    percent: deltaPct.abs(),
                                                    isUp: isUp,
                                                    b: b,
                                                  ),
                                                if (subDetailsOpacity > 0.05) ...[
                                                  const SizedBox(width: 8),
                                                  Opacity(
                                                    opacity: subDetailsOpacity,
                                                    child: _buildTimeRangeSelector(
                                                        isDark, b),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Continuous rolling odometer counter
                                          Opacity(
                                            opacity: amountOpacity,
                                            child: CountUpMoney(
                                              key: const ValueKey(
                                                  'hero-sales-counter'),
                                              value: activeRevenue,
                                              duration:
                                                  const Duration(milliseconds: 500),
                                              style: AppMoneyText.sized(
                                                  34,
                                                  FontWeight.w700,
                                                  AppColors.textPrimary(b)),
                                            ),
                                          ),
                                          if (hasTrend &&
                                              subDetailsOpacity > 0.05) ...[
                                            const SizedBox(height: 14),
                                            Opacity(
                                              opacity: subDetailsOpacity,
                                              child: InteractiveSparkline(
                                                days: weekDays,
                                                lineColor: AppColors.accentText(b),
                                                fillColor: AppColors.accentSubtle,
                                                height: 52,
                                              ),
                                            ),
                                          ],
                                          if (subDetailsOpacity > 0.05) ...[
                                            const SizedBox(height: 16),
                                            Opacity(
                                              opacity: subDetailsOpacity,
                                              child: Container(
                                                  height: 1,
                                                  color: AppColors.divider(b)),
                                            ),
                                            const SizedBox(height: 16),
                                            Opacity(
                                              opacity: subDetailsOpacity,
                                              child: Row(
                                                children: [
                                                  _HeroStat(
                                                    label: 'Bills',
                                                    value: billCountText,
                                                    b: b,
                                                    isSelected:
                                                        _activeStatIndex == 0,
                                                    onTap: () {
                                                      HapticFeedback.selectionClick();
                                                      setState(() {
                                                        _activeStatIndex =
                                                            _activeStatIndex == 0
                                                                ? -1
                                                                : 0;
                                                      });
                                                    },
                                                  ),
                                                  _HeroDivider(b: b),
                                                  _HeroStat(
                                                    label: 'Avg Bill',
                                                    value: avgBillText,
                                                    b: b,
                                                    isSelected:
                                                        _activeStatIndex == 1,
                                                    onTap: () {
                                                      HapticFeedback.selectionClick();
                                                      setState(() {
                                                        _activeStatIndex =
                                                            _activeStatIndex == 1
                                                                ? -1
                                                                : 1;
                                                      });
                                                    },
                                                  ),
                                                  _HeroDivider(b: b),
                                                  _HeroStat(
                                                    label: 'Discount',
                                                    value: discountText,
                                                    b: b,
                                                    isSelected:
                                                        _activeStatIndex == 2,
                                                    onTap: () {
                                                      HapticFeedback.selectionClick();
                                                      setState(() {
                                                        _activeStatIndex =
                                                            _activeStatIndex == 2
                                                                ? -1
                                                                : 2;
                                                      });
                                                    },
                                                  ),
                                                  _HeroDivider(b: b),
                                                  Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 18,
                                                    color:
                                                        AppColors.textTertiary(b),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      // Alien Razor Light Scan Beam across card while being pulled
                                      // Strictly clipped within the card's available area — zero spill
                                      if (razorIntensity > 0.02)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(radius),
                                            child: Opacity(
                                              opacity: razorIntensity,
                                              child: Center(
                                                child: Container(
                                                  height: 2.5,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        AppColors.accent.withValues(alpha: 0.8),
                                                        Colors.white,
                                                        AppColors.accent.withValues(alpha: 0.8),
                                                        Colors.transparent,
                                                      ],
                                                      stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: AppColors.accent,
                                                        blurRadius: 4,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                ),
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
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector(bool isDark, Brightness b) {
    const labels = ['Today', '7D', '30D'];

    return SizedBox(
      width: 148,
      child: SlidingCapsuleSelector(
        items: labels,
        selectedIndex: _selectedRange,
        height: 28,
        fontSize: 10.5,
        onSelected: (i) {
          setState(() => _selectedRange = i);
        },
      ),
    );
  }
}

/// Delta pill — icon + text + tinted bg (hue never alone).
class _DeltaPill extends StatelessWidget {
  final double percent;
  final bool isUp;
  final Brightness b;

  const _DeltaPill(
      {required this.percent, required this.isUp, required this.b});

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppColors.successText(b) : AppColors.error(b);
    return TweenAnimationBuilder<double>(
      key: ValueKey('$percent-$isUp'),
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
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
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Brightness b;
  final bool isSelected;
  final VoidCallback? onTap;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.b,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accentText(b);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accent : AppColors.textTertiary(b),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppMoneyText.sized(
                  15,
                  isSelected ? FontWeight.w800 : FontWeight.w600,
                  isSelected ? accent : AppColors.textPrimary(b),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
// Primary action dock — New Bill (lime pill) + POS Quick Sale shortcut
// ═══════════════════════════════════════════════════════════════════════

class _NewBillButton extends StatelessWidget {
  const _NewBillButton();

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;

    return Row(
      children: [
        // Primary CTA: Scan & Create New Bill
        Expanded(
          child: SizedBox(
            height: AppTouchTarget.buttonHeight,
            child: SheenEffect(
              borderRadius: AppRadius.rLg,
              interval: const Duration(seconds: 4),
              sheenColor: Colors.white,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.go('/scan');
                },
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  _showNewBillQuickMenu(context);
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
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Secondary POS Quick Action Dock: Fast Sale / Manual Entry
        PressScale(
          pressedScale: 0.92,
          child: Tooltip(
            message: 'Fast Cash Bill',
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/scan/checkout');
              },
              borderRadius: AppRadius.rLg,
              child: Container(
                width: AppTouchTarget.buttonHeight,
                height: AppTouchTarget.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface(b),
                  borderRadius: AppRadius.rLg,
                  border: Border.all(
                    color: isDark
                        ? AppColors.accent.withValues(alpha: 0.25)
                        : AppColors.border(b),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.point_of_sale_rounded,
                    size: 22,
                    color: AppColors.accentText(b),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// New Bill Quick Action Menu (Long-press modal)
// ═══════════════════════════════════════════════════════════════════════

void _showNewBillQuickMenu(BuildContext context) {
  final b = Theme.of(context).brightness;
  final isDark = b == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border(b)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(b).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Billing Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(b),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Select preferred billing mode',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary(b),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.accent,
              title: 'Barcode / QR Scanner',
              subtitle: 'Scan products instantly with device camera',
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/scan');
              },
              b: b,
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.point_of_sale_rounded,
              color: AppColors.successText(b),
              title: 'Fast Cash Checkout',
              subtitle: 'Direct billing without camera scanning',
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/scan/checkout');
              },
              b: b,
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.inventory_2_rounded,
              color: AppColors.infoText(b),
              title: 'Product Catalog',
              subtitle: 'Pick items directly from inventory inventory',
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/products');
              },
              b: b,
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.history_rounded,
              color: AppColors.warningText(b),
              title: 'Recent Bills & History',
              subtitle: 'View, reprint, or inspect completed sales',
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/reports/bills');
              },
              b: b,
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildQuickMenuItem(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required Brightness b,
}) {
  return PressScale(
    pressedScale: 0.96,
    child: InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(b),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(b)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(b),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary(b),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary(b).withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════
// Cashier / Shift Status Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════

void _showCashierStatusSheet(BuildContext context, User user) {
  final b = Theme.of(context).brightness;
  final isDark = b == Brightness.dark;
  final userName = user.name.isNotEmpty ? user.name : 'Cashier';
  final userRole = user.role.toUpperCase();
  final userEmail = user.email;
  final userPhone = user.phone ?? '';
  final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'B';

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border(b)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(b).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Cashier identity header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent.withValues(alpha: isDark ? 0.35 : 0.45),
                        AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.20),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentText(b),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(b),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              userRole,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: AppColors.accentText(b),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userEmail.isNotEmpty
                            ? userEmail
                            : (userPhone.isNotEmpty ? userPhone : 'Active Counter Staff'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary(b),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Session Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(b),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(b)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.successText(b),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successText(b).withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active Shift Session',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(b),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('hh:mm a · EEE').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary(b),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Quick Actions List
            _buildQuickMenuItem(
              ctx,
              icon: Icons.menu_rounded,
              color: AppColors.infoText(b),
              title: 'Open Navigation Drawer',
              subtitle: 'Access full sidebar navigation menu',
              onTap: () {
                Navigator.of(ctx).pop();
                Scaffold.of(context).openDrawer();
              },
              b: b,
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.print_rounded,
              color: AppColors.accent,
              title: 'Bluetooth Thermal Printer',
              subtitle: 'Check printer pairing & ESC/POS connection',
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/printer/test');
              },
              b: b,
            ),
            const SizedBox(height: 8),
            _buildQuickMenuItem(
              ctx,
              icon: Icons.logout_rounded,
              color: AppColors.error(b),
              title: 'Sign Out / Switch Cashier',
              subtitle: 'End shift and return to login screen',
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              b: b,
            ),
          ],
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════
// Hero Insight Modal Sheet — sales velocity & payment method split
// ═══════════════════════════════════════════════════════════════════════

void _showHeroInsightSheet(
  BuildContext context, {
  required String periodTitle,
  required double totalSales,
  required int billCount,
  required double avgBill,
  required double discount,
  required List<BillSummary> bills,
}) {
  final b = Theme.of(context).brightness;
  final isDark = b == Brightness.dark;
  final inrFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // Compute payment method splits
  double upiTotal = 0.0;
  int upiCount = 0;
  double cashTotal = 0.0;
  int cashCount = 0;
  double cardTotal = 0.0;
  int cardCount = 0;

  for (final bill in bills) {
    final m = bill.paymentMethod.toLowerCase();
    if (m.contains('upi')) {
      upiTotal += bill.grandTotal;
      upiCount++;
    } else if (m.contains('cash')) {
      cashTotal += bill.grandTotal;
      cashCount++;
    } else if (m.contains('card') || m.contains('credit')) {
      cardTotal += bill.grandTotal;
      cardCount++;
    }
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.border(b),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(b).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$periodTitle Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(b),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Live transaction summary',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary(b),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Revenue highlight container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.accent.withValues(alpha: 0.16),
                          AppColors.surfaceElevated(b),
                        ]
                      : [
                          AppColors.accent.withValues(alpha: 0.14),
                          Colors.white,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL REVENUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.accentText(b),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inrFmt.format(totalSales),
                        style: AppMoneyText.sized(
                            28, FontWeight.w800, AppColors.textPrimary(b)),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$billCount bills',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentText(b),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Payment method breakdown chips
            Text(
              'PAYMENT METHODS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.textTertiary(b),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMethodPill(
                  label: 'UPI',
                  amount: inrFmt.format(upiTotal),
                  count: upiCount,
                  color: AppColors.infoText(b),
                  icon: Icons.qr_code_2_rounded,
                  b: b,
                ),
                const SizedBox(width: 8),
                _buildMethodPill(
                  label: 'Cash',
                  amount: inrFmt.format(cashTotal),
                  count: cashCount,
                  color: AppColors.successText(b),
                  icon: Icons.payments_rounded,
                  b: b,
                ),
                const SizedBox(width: 8),
                _buildMethodPill(
                  label: 'Card',
                  amount: inrFmt.format(cardTotal),
                  count: cardCount,
                  color: AppColors.warningText(b),
                  icon: Icons.credit_card_rounded,
                  b: b,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sub-metrics row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Average Ticket',
                    value: inrFmt.format(avgBill),
                    icon: Icons.show_chart_rounded,
                    b: b,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Discount',
                    value: inrFmt.format(discount),
                    icon: Icons.local_offer_rounded,
                    b: b,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Primary action: view daily sales report
            SizedBox(
              width: double.infinity,
              height: 48,
              child: PressScale(
                pressedScale: 0.95,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/reports/daily-sales');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_rounded, size: 20),
                  label: const Text(
                    'Open Detailed Report',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMethodPill({
  required String label,
  required String amount,
  required int count,
  required Color color,
  required IconData icon,
  required Brightness b,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(b),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$count bills',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary(b),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMetricTile({
  required String title,
  required String value,
  required IconData icon,
  required Brightness b,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(b),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border(b)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentText(b)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary(b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(b),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════
// Bill Quick Preview Bottom Sheet — receipt preview & quick actions
// ═══════════════════════════════════════════════════════════════════════

void _showBillQuickPreviewSheet(BuildContext context, BillSummary bill) {
  final b = Theme.of(context).brightness;
  final isDark = b == Brightness.dark;
  final inrFmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final shortId = bill.id.length >= 8
      ? bill.id.substring(0, 8).toUpperCase()
      : bill.id.toUpperCase();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151C2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border(b)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary(b).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: AppColors.accentText(b),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill #$shortId',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(bill.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary(b),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bill.paymentMethod.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentText(b),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(b),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(b)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CASHIER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary(b),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.staffName.isEmpty ? 'Staff' : bill.staffName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GRAND TOTAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary(b),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inrFmt.format(bill.grandTotal),
                        style: AppMoneyText.sized(
                            20, FontWeight.w800, AppColors.accentText(b)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (bill.items.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'ITEMS (${bill.items.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textTertiary(b),
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: bill.items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.divider(b),
                  ),
                  itemBuilder: (context, idx) {
                    final item = bill.items[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.quantity} × ₹${item.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary(b),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₹${item.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: PressScale(
                    pressedScale: 0.95,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.go('/reports/bills/${bill.id}', extra: bill);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text(
                        'View Full Details',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
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
    final shopState = context.watch<ShopBloc>().state;
    final shopName = shopState is ShopLoaded && shopState.shop.name.trim().isNotEmpty
        ? shopState.shop.name.trim()
        : 'MY SHOP';

    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.billHistory != b.billHistory,
      builder: (context, state) {
        final isLoading = state.status == ReportStatus.loading &&
            state.billHistory.isEmpty;

        // Sort by newest first, take up to 15 for the internally scrollable roll
        final txns = List.of(state.billHistory)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final displayed = txns.take(15).map((bill) {
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

        return AnimatedSwap(
          child: isLoading
              ? const TxnListSkeleton(key: ValueKey('txns-skeleton'))
              : RecentTransactionsCard(
                  key: const ValueKey('txns-content'),
                  transactions: displayed,
                  shopName: shopName,
                  onViewAll: () => context.go('/reports/bills'),
                  // Row tap → bill detail. Resolve the BillSummary by id
                  // (the route needs the full entity as extra).
                  onTransactionTap: (txn) {
                    HapticFeedback.lightImpact();
                    final bill = state.billHistory.firstWhere(
                      (b) => b.id == txn.id,
                      orElse: () => state.billHistory.first,
                    );
                    _showBillQuickPreviewSheet(context, bill);
                  },
                ),
        );
      },
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
      buildWhen: (a, b) =>
          a.billHistory != b.billHistory || a.status != b.status,
      builder: (context, state) {
        // Show a skeleton while the FIRST report load is still in flight, so
        // the chart card doesn't momentarily flash "No payment data yet".
        final isLoading = state.status == ReportStatus.loading &&
            state.billHistory.isEmpty;
        if (isLoading) {
          return const ChartCardSkeleton(
            key: ValueKey('donut-skeleton'),
            title: 'Payment Methods',
          );
        }
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
      buildWhen: (a, b) =>
          a.billHistory != b.billHistory || a.status != b.status,
      builder: (context, state) {
        final isLoading = state.status == ReportStatus.loading &&
            state.billHistory.isEmpty;
        if (isLoading) {
          return const ChartCardSkeleton(
            key: ValueKey('top-prod-skeleton'),
            title: 'Top Products',
          );
        }
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
      buildWhen: (a, b) =>
          a.salesRange != b.salesRange || a.status != b.status,
      builder: (context, state) {
        // Skeleton while first load in flight.
        final isLoading = state.status == ReportStatus.loading &&
            state.salesRange.isEmpty;
        if (isLoading) {
          return const ChartCardSkeleton(
            key: ValueKey('trend-skeleton'),
            title: '30-Day Trend',
          );
        }
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
        const threshold = DashboardPage._lowStockThreshold;
        int lowStock = 0;
        int outOfStock = 0;
        for (final p in products) {
          if (p.stock <= 0) {
            outOfStock++;
          } else if (p.stock <= threshold) {
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
// Error Banner — network failure on report queries, with retry
// ═══════════════════════════════════════════════════════════════════════

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.error != b.error,
      builder: (context, state) {
        final error = state.error;
        final hasError = error != null && error.isNotEmpty;
        final b = Theme.of(context).brightness;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasError
                ? Container(
                    key: const ValueKey('error-visible'),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error(b).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error(b).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: AppColors.error(b),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Data load nahi hua — connection check karo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error(b),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.read<ReportBloc>()
                                ..add(LoadDailySales(DateTime.now()))
                                ..add(const LoadLowStockProducts(
                                    DashboardPage._lowStockThreshold))
                                ..add(LoadFullBillHistory(
                                    from: DateTime.now().subtract(const Duration(days: 6)),
                                    to: DateTime.now()))
                                ..add(LoadSalesRange(
                                    from: DateTime(DateTime.now().year,
                                        DateTime.now().month, 1),
                                    to: DateTime.now()));
                              context.read<ProductBloc>().add(LoadProducts());
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error(b),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('error-hidden')),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Due badge — pending-amount pill on the Due Payments quick tile. Total is
// reformatted compactly (₹1.2K / ₹15.3K) so it fits the small corner spot.
// ═══════════════════════════════════════════════════════════════════════

class _DueBadge extends StatelessWidget {
  const _DueBadge();

  static String _fmtShort(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DuePaymentsBloc, DuePaymentsState>(
      buildWhen: (a, b) => a.totalPendingDue != b.totalPendingDue,
      builder: (context, state) {
        final total = state.totalPendingDue;
        // Nothing pending → no badge (zero-noise UI)
        if (total <= 0) return const SizedBox.shrink();
        final b = Theme.of(context).brightness;

        return TweenAnimationBuilder<double>(
          key: ValueKey(total),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error(b),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              '₹${_fmtShort(total)}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Low Stock Banner — glass warning card with ambient breathing glow
// ═══════════════════════════════════════════════════════════════════════

class _LowStockBanner extends StatefulWidget {
  const _LowStockBanner();

  @override
  State<_LowStockBanner> createState() => _LowStockBannerState();
}

class _LowStockBannerState extends State<_LowStockBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      if (_pulseCtrl.isAnimating) _pulseCtrl.stop();
    } else {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.lowStockProducts != b.lowStockProducts,
      builder: (context, state) {
        final count = state.lowStockProducts.length;
        final hasLowStock = count > 0;
        final b = Theme.of(context).brightness;

        Widget buildContainer(double glowAlpha, double borderAlpha, double iconAlpha) {
          return Container(
            key: ValueKey('low-stock-$count'),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error(b).withValues(alpha: glowAlpha),
                  AppColors.error(b).withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error(b).withValues(alpha: borderAlpha),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error(b).withValues(alpha: glowAlpha * 0.4),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/reports/low-stock');
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error(b)
                              .withValues(alpha: iconAlpha),
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
        }

        Widget content;
        if (!hasLowStock) {
          content = const SizedBox.shrink(key: ValueKey('low-stock-empty'));
        } else if (reduce) {
          content = buildContainer(0.12, 0.20, 0.10);
        } else {
          content = AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              final t = _pulseCtrl.value;
              final glowAlpha = 0.12 + (t * 0.18);
              final borderAlpha = 0.20 + (t * 0.25);
              final iconAlpha = 0.10 + (t * 0.10);
              return buildContainer(glowAlpha, borderAlpha, iconAlpha);
            },
          );
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: content,
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
