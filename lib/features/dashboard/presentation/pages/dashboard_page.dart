import 'dart:ui';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/greeting_header.dart';
import 'package:billing_app/core/widgets/inventory_health_card.dart';
import 'package:billing_app/core/widgets/premium_stat_card.dart';
import 'package:billing_app/core/widgets/recent_transactions_card.dart';
import 'package:billing_app/core/widgets/sales_trend_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      ..add(LoadBillHistory(from: weekAgo, to: now, page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8EAF6), // Lavender
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFE8F5E9), // Light green
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final now = DateTime.now();
              final weekAgo = now.subtract(const Duration(days: 6));
              context.read<ReportBloc>()
                ..add(LoadDailySales(now))
                ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold))
                ..add(LoadBillHistory(from: weekAgo, to: now, page: 1));
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
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[700]),
                    ),
                    IconButton(
                      onPressed: () => _showProductSearch(context),
                      icon: Icon(Icons.search_rounded, color: Colors.grey[700]),
                      tooltip: 'Search products',
                    ),
                  ],
                ),

                // ── Content ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Greeting
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final name = state is Authenticated ? state.user.name : '';
                          return GreetingHeader(userName: name);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Low stock banner
                      const _LowStockBanner(),
                      const SizedBox(height: 8),

                      // ── Today's Sales Section ──
                      _sectionTitle("Today's Sales"),
                      const SizedBox(height: 12),
                      const _TodaysSales(),
                      const SizedBox(height: 20),

                      // ── Weekly Trend ──
                      _sectionTitle('This Week'),
                      const SizedBox(height: 12),
                      const _WeeklyTrend(),
                      const SizedBox(height: 20),

                      // ── Quick Actions ──
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 12),
                      DashboardActionCard(
                        icon: Icons.shopping_cart_rounded,
                        title: 'New Bill',
                        subtitle: 'Scan products & checkout',
                        color: AppTheme.primaryColor,
                        onTap: () => context.go('/scan'),
                      ),
                      const SizedBox(height: 14),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => _buildQuickTiles(context, state),
                      ),
                      const SizedBox(height: 20),

                      // ── Inventory Health ──
                      const _InventoryHealth(),
                      const SizedBox(height: 20),

                      // ── Recent Transactions ──
                      const _RecentTransactions(),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _ProductSearchDelegate(),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.grey[800],
        letterSpacing: -0.2,
      ),
    ),
  );

  Widget _buildQuickTiles(BuildContext context, AuthState authState) {
    final tiles = <Widget>[
      QuickActionTile(
        icon: Icons.inventory_2_rounded,
        label: 'Products',
        color: AppTheme.primaryColor,
        onTap: () => context.go('/products'),
      ),
      QuickActionTile(
        icon: Icons.category_rounded,
        label: 'Categories',
        color: AppTheme.primaryColor,
        onTap: () => context.go('/categories'),
      ),
      QuickActionTile(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: AppTheme.primaryColor,
        onTap: () => context.go('/reports'),
      ),
      QuickActionTile(
        icon: Icons.store_rounded,
        label: 'Shop',
        color: AppTheme.primaryColor,
        onTap: () => context.go('/shop'),
      ),
      QuickActionTile(
        icon: Icons.settings_rounded,
        label: 'Settings',
        color: AppTheme.primaryColor,
        onTap: () => context.go('/settings'),
      ),
    ];

    final isOwner =
        authState is Authenticated && authState.user.role == 'owner';
    if (isOwner) {
      tiles.add(
        QuickActionTile(
          icon: Icons.people_rounded,
          label: 'Staff',
          color: AppTheme.primaryColor,
          onTap: () => context.go('/staff'),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Today's Sales — 4 glass stat cards in 2×2 grid
// ═══════════════════════════════════════════════════════════════════════

class _TodaysSales extends StatelessWidget {
  const _TodaysSales();

  String _formatCurrency(double v) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
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
      builder: (context, state) {
        final now = DateTime.now();
        final values = <double>[];
        final labels = <String>[];

        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day - i);
          final dayStart = DateTime(day.year, day.month, day.day);
          final dayEnd = dayStart.add(const Duration(days: 1));

          // Sum grandTotal of bills created on this day
          double dayTotal = 0;
          for (final bill in state.billHistory) {
            if (!bill.createdAt.isBefore(dayStart) &&
                bill.createdAt.isBefore(dayEnd)) {
              dayTotal += bill.grandTotal;
            }
          }
          values.add(dayTotal);
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
      builder: (context, state) {
        final isLoading = state.status == ReportStatus.loading &&
            state.billHistory.isEmpty;

        // Sort by newest first, take top 5
        final sorted = List.of(state.billHistory)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final txns = sorted.take(5).map((bill) {
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
          return _buildLoadingPlaceholder();
        }

        return RecentTransactionsCard(
          transactions: txns,
          onViewAll: () => context.go('/reports/bills'),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 50,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
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
      builder: (context, state) {
        final products = state.products;
        final total = products.length;
        final lowStock = products.where((p) => p.stock > 0 && p.stock <= 5).length;
        final outOfStock = products.where((p) => p.stock <= 0).length;

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
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
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
          style: TextStyle(color: Colors.grey[500], fontSize: 15),
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
          style: TextStyle(color: Colors.grey[500], fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0x1A6C63FF),
            child: Icon(Icons.inventory_2_outlined,
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              if (queryLower.isNotEmpty &&
                  product.description != null &&
                  product.description!
                      .toLowerCase()
                      .contains(queryLower)) ...[
                const SizedBox(height: 4),
                _buildDescriptionSnippet(product.description!, queryLower),
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

  Widget _buildDescriptionSnippet(String description, String query) {
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
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.saved_search_rounded,
              size: 12, color: Color(0xFFD97706)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              snippet,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF92400E),
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
