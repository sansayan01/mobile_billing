import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/stat_card.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.black87),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Greeting(),
              const SizedBox(height: 20),
              const _LowStockBanner(),
              const _TodaysSales(),
              const SizedBox(height: 24),
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 12),
              DashboardActionCard(
                icon: Icons.shopping_cart_rounded,
                title: 'New Bill',
                subtitle: 'Scan products & checkout',
                color: AppTheme.primaryColor,
                onTap: () => context.go('/scan'),
              ),
              const SizedBox(height: 16),
              _buildQuickTiles(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );

  Widget _buildQuickTiles(BuildContext context) {
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

    // Staff tile — sirf owner ko dikhaye (staff management owner-only hai)
    final authState = context.read<AuthBloc>().state;
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
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is Authenticated ? state.user.name : 'there';
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingPrefix(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _greetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _TodaysSales extends StatelessWidget {
  const _TodaysSales();

  String _formatCurrency(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(v);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final sales = state.dailySales;
        final loading = state.status == ReportStatus.loading && sales == null;

        final totalSales = loading
            ? '…'
            : _formatCurrency(sales?.totalSales ?? 0);
        final billCount =
            loading ? '…' : (sales?.billCount ?? 0).toString();
        final avgBill =
            loading ? '…' : _formatCurrency(sales?.averageBill ?? 0);
        final discount =
            loading ? '…' : _formatCurrency(sales?.totalDiscount ?? 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Sales",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Sales',
                    value: totalSales,
                    color: Colors.green,
                    icon: Icons.currency_rupee_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Bills',
                    value: billCount,
                    color: AppTheme.primaryColor,
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Avg Bill',
                    value: avgBill,
                    color: Colors.orange,
                    icon: Icons.trending_up_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Discount',
                    value: discount,
                    color: Colors.redAccent,
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/reports/low-stock'),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.errorColor),
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
                    const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.errorColor),
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
