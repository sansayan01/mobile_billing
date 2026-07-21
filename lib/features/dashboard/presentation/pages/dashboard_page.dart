import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/greeting_header.dart';
import 'package:billing_app/core/widgets/premium_stat_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// App home — a dashboard with greeting, today's sales, quick actions and a
/// low-stock alert. Barcode scanning lives on `/scan` (via "New Bill").
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
    context.read<ReportBloc>()
      ..add(LoadDailySales(DateTime.now()))
      ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Open menu',
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
          ),
          IconButton(
            onPressed: () => _showProductSearch(context),
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            tooltip: 'Search products',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ReportBloc>()
            ..add(LoadDailySales(DateTime.now()))
            ..add(const LoadLowStockProducts(DashboardPage._lowStockThreshold));
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final name = state is Authenticated ? state.user.name : '';
          return GreetingHeader(userName: name);
        },
      ),
              const SizedBox(height: 24),
              const _LowStockBanner(),
              const SizedBox(height: 28),
              _sectionTitle("Today's Sales"),
              const SizedBox(height: 14),
              const _TodaysSales(),
              const SizedBox(height: 28),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 14),
              DashboardActionCard(
                icon: Icons.shopping_cart_rounded,
                title: 'New Bill',
                subtitle: 'Scan products & checkout',
                color: AppTheme.primaryColor,
                onTap: () => context.go('/scan'),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => _buildQuickTiles(context, state),
              ),
              const SizedBox(height: 16),
            ],
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

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Colors.black87,
      letterSpacing: -0.2,
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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.errorColor.withValues(alpha: 0.12),
                AppTheme.errorColor.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.35),
              width: 1.2,
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
                        color: AppTheme.errorColor.withValues(alpha: 0.15),
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

/// Search delegate that filters products from the ProductBloc state
/// by name, barcode, or description. Tapping a result navigates to product detail page.
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
