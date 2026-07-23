import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/theme/text_styles.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/greeting_header.dart';
import 'package:billing_app/core/widgets/inventory_health_card.dart';
import 'package:billing_app/core/widgets/premium_stat_card.dart';
import 'package:billing_app/core/widgets/recent_transactions_card.dart';
import 'package:billing_app/core/widgets/sales_trend_card.dart';
import 'package:billing_app/core/widgets/payment_donut_chart.dart';
import 'package:billing_app/core/widgets/top_products_bar_chart.dart';
import 'package:billing_app/core/widgets/monthly_trend_card.dart';
import 'package:billing_app/core/widgets/staff_performance_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// App home — a liquid glass dashboard with greeting, today's sales,
/// weekly trends, recent transactions, inventory health, quick actions
/// and a low-stock alert.
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
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    context.read<ReportBloc>()
      ..add(LoadDailySales(now))
      ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
      ..add(LoadBillHistory(from: weekAgo, to: now, page: 1))
      ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ignore: prefer_const_constructors
        decoration: BoxDecoration(
          gradient: AppTheme.gradientFor(context),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final now = DateTime.now();
              final weekAgo = now.subtract(const Duration(days: 6));
              context.read<ReportBloc>()
                ..add(LoadDailySales(now))
                ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
                ..add(LoadBillHistory(from: weekAgo, to: now, page: 1))
                ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now));
              await Future<void>.delayed(const Duration(milliseconds: 600));
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
                  leading: IconButton(
                    icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Open menu',
                  ),
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

                // ── Content ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Wrap entire scrollable content in RepaintBoundary
                      // so glassmorphism cards don't repaint the whole list
                      RepaintBoundary(
                        child: Column(
                          children: [
                      // Greeting
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) {
                          if (previous is! Authenticated || current is! Authenticated) return true;
                          return previous.user.name != current.user.name;
                        },
                        builder: (context, state) {
                          final name = state is Authenticated ? state.user.name : '';
                          return GreetingHeader(userName: name);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Low stock banner
                      const _LowStockBanner(),
                      const SizedBox(height: 16),

                      // ── Today's Sales Section ──
                      _sectionTitle("Today's Sales"),
                      const SizedBox(height: 16),
                      const _TodaysSales(),
                      const SizedBox(height: 24),

                      // ── Quick Actions ──
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 16),
                      DashboardActionCard(
                        icon: Icons.shopping_cart_rounded,
                        title: 'New Bill',
                        subtitle: 'Scan products & checkout',
                        color: AppTheme.primaryColor,
                        onTap: () { HapticFeedback.lightImpact(); context.go('/scan'); },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) {
                          if (previous is! Authenticated || current is! Authenticated) return true;
                          return previous.user.role != current.user.role;
                        },
                        builder: (context, state) => _buildQuickTiles(context, state),
                      ),
                      const SizedBox(height: 24),

                      // ── Weekly Trend ──
                      _sectionTitle('This Week'),
                      const SizedBox(height: 16),
                      const _WeeklyTrend(),
                      const SizedBox(height: 24),

                      // ── Payment Methods Donut ──
                      const _PaymentMethodsSection(),
                      const SizedBox(height: 24),

                      // ── Top Products Bar Chart ──
                      const _TopProductsSection(),
                      const SizedBox(height: 24),

                      // ── Inventory Health ──
                      const _InventoryHealth(),
                      const SizedBox(height: 24),

                      // ── Recent Transactions ──
                      const _RecentTransactions(),
                      const SizedBox(height: 24),

                      // ── Monthly / 30-Day Trend ──
                       const _MonthlyTrendSection(),
                      const SizedBox(height: 24),

                      // ── Staff Performance ──
                      const _StaffPerformanceSection(),
                      const SizedBox(height: 16),
                    ], // Column children
                  ), // Column
                ), // RepaintBoundary
              ], // SliverList delegate
            ),
          ), // SliverPadding
        ),
      ], // slivers
    ), // CustomScrollView
  ), // RefreshIndicator
), // SafeArea
), // Container
); // Scaffold
  }

  void _showProductSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _ProductSearchDelegate(),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(text, style: AppTextStyles.of(context).sectionTitle.copyWith(
      fontSize: 13,
      letterSpacing: 0.8,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    )),
  );

  Widget _buildQuickTiles(BuildContext context, AuthState authState) {
    final isOwner =
        authState is Authenticated && authState.user.role == 'owner';

    // Build widgets inline to avoid allocating a List that's recreated
    // on every auth change. Only the owner tile is conditional;
    // the rest are direct children with zero alloc.
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        QuickActionTile(
          icon: Icons.inventory_2_rounded,
          label: 'Products',
          color: AppTheme.primaryColor,
          onTap: () { HapticFeedback.lightImpact(); context.go('/products'); },
        ),
        QuickActionTile(
          icon: Icons.category_rounded,
          label: 'Categories',
          color: AppTheme.primaryColor,
          onTap: () { HapticFeedback.lightImpact(); context.go('/categories'); },
        ),
        QuickActionTile(
          icon: Icons.bar_chart_rounded,
          label: 'Reports',
          color: AppTheme.primaryColor,
          onTap: () { HapticFeedback.lightImpact(); context.go('/reports'); },
        ),
        QuickActionTile(
          icon: Icons.store_rounded,
          label: 'Shop',
          color: AppTheme.primaryColor,
          onTap: () { HapticFeedback.lightImpact(); context.go('/shop'); },
        ),
        QuickActionTile(
          icon: Icons.settings_rounded,
          label: 'Settings',
          color: AppTheme.primaryColor,
          onTap: () { HapticFeedback.lightImpact(); context.go('/settings'); },
        ),
        if (isOwner)
          QuickActionTile(
            icon: Icons.people_rounded,
            label: 'Staff',
            color: AppTheme.primaryColor,
            onTap: () { HapticFeedback.lightImpact(); context.go('/staff'); },
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Today's Sales — 4 glass stat cards in 2×2 grid
// ═══════════════════════════════════════════════════════════════════════

class _TodaysSales extends StatelessWidget {
  const _TodaysSales();

  static final _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _formatCurrency(double v) => _inrFormat.format(v);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.dailySales != b.dailySales || a.status != b.status,
      builder: (context, state) {
        final sales = state.dailySales;
        final loading = state.status == ReportStatus.loading && sales == null;

        final totalSales =
            loading ? '…' : _formatCurrency(sales?.totalSales ?? 0);
        final billCount =
            loading ? '…' : (sales?.billCount ?? 0).toString();
        final avgBill =
            loading ? '…' : _formatCurrency(sales?.averageBill ?? 0);
        final discount =
            loading ? '…' : _formatCurrency(sales?.totalDiscount ?? 0);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: PremiumStatCard(
                    label: 'Total Sales',
                    value: totalSales,
                    color: const Color(0xFF4CAF50),
                    icon: Icons.currency_rupee_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PremiumStatCard(
                    label: 'Bills',
                    value: billCount,
                    color: AppTheme.primaryColor,
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: PremiumStatCard(
                    label: 'Avg Bill',
                    value: avgBill,
                    color: const Color(0xFFFF9800),
                    icon: Icons.trending_up_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PremiumStatCard(
                    label: 'Discount',
                    value: discount,
                    color: const Color(0xFFE91E63),
                    icon: Icons.local_offer_rounded,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Weekly Trend — 7-day sales trend from billHistory
// ═══════════════════════════════════════════════════════════════════════

class _WeeklyTrend extends StatelessWidget {
  const _WeeklyTrend();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (a, b) => a.billHistory != b.billHistory,
      builder: (context, state) {
        final now = DateTime.now();
        final values = <double>[];
        final labels = <String>[];

        // Single-pass pre-grouping instead of O(n×7) nested loop
        final Map<int, double> dayTotals = {};
        for (int i = 6; i >= 0; i--) {
          dayTotals[i] = 0.0;
        }
        for (final bill in state.billHistory) {
          final diff = DateTime(now.year, now.month, now.day)
              .difference(DateTime(bill.createdAt.year, bill.createdAt.month, bill.createdAt.day))
              .inDays;
          if (diff >= 0 && diff <= 6) {
            dayTotals[6 - diff] = (dayTotals[6 - diff] ?? 0) + bill.grandTotal;
          }
        }
        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day - i);
          values.add(dayTotals[i] ?? 0);
          labels.add(DateFormat('EEE').format(day));
        }

        return SalesTrendCard(values: values, labels: labels);
      },
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
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.errorColor.withValues(alpha: 0.10),
                AppTheme.errorColor.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.25),
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
                        color: AppTheme.errorColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$count item${count == 1 ? '' : 's'} running low on stock',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.errorColor.withValues(alpha: 0.7),
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
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppTheme.primaryColor, size: 20),
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
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        color: isDark ? const Color(0xFF3A2A00) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isDark ? const Color(0xFF5C4000) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.saved_search_rounded,
              size: 12, color: isDark ? const Color(0xFFFFB800) : const Color(0xFFD97706)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              snippet,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFFFF3CD) : const Color(0xFF92400E),
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
