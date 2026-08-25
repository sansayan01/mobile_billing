import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/widgets/dashboard_action_card.dart';
import 'package:billing_app/core/widgets/premium_stat_card.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';

class ReportsHomePage extends StatefulWidget {
  const ReportsHomePage({super.key});

  @override
  State<ReportsHomePage> createState() => _ReportsHomePageState();
}

class _ReportsHomePageState extends State<ReportsHomePage> {
  @override
  void initState() {
    super.initState();
    // Ensure month sales range + low stock are loaded fresh — don't rely
    // on whatever billHistory happens to be left over from navigation.
    final now = DateTime.now();
    context.read<ReportBloc>()
      ..add(LoadSalesRange(from: DateTime(now.year, now.month, 1), to: now))
      ..add(const LoadLowStockProducts(5));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final bills = state.billHistory;
        final monthBills =
            bills.where((b) => b.createdAt.isAfter(monthStart)).toList();
        // Revenue from salesRange (daily aggregates) — independent of the
        // billHistory page-size cap and of navigation history.
        final monthRevenue = state.salesRange
            .where((d) =>
                !d.date.isBefore(monthStart) && d.date.isBefore(nextMonthStart))
            .fold(0.0, (s, d) => s + d.totalSales);
        final lowStockCount = state.lowStockProducts.length;

        final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientFor(context),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  final w = DateTime.now();
                  context
                    ..read<ReportBloc>().add(LoadBillHistory(
                        from: DateTime(w.year, w.month, 1), to: w, page: 1))
                    ..read<ReportBloc>().add(const LoadLowStockProducts(5));
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── AppBar ──
                    const SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: AdaptiveAppBarLeading(),
                      title: Text('Reports & History',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      centerTitle: true,
                    ),

                    // ── Hero Stat: Month Revenue ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: PremiumStatCard(
                          label: 'This Month Revenue',
                          value: nf.format(monthRevenue),
                          color: AppColors.accentText(
                              Theme.of(context).brightness),
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                    ),

                    // ── Secondary Stats Row ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: PremiumStatCard(
                                label: 'Bills',
                                value: '${monthBills.length}',
                                color: AppColors.infoText(
                                    Theme.of(context).brightness),
                                icon: Icons.receipt_long_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PremiumStatCard(
                                label: 'Low Stock',
                                value: '$lowStockCount',
                                color: AppColors.warningText(
                                    Theme.of(context).brightness),
                                icon: Icons.warning_amber_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Section Heading ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                        child: Row(
                          children: [
                            Icon(Icons.insights_rounded,
                                size: 16,
                                color: AppColors.accentText(
                                    Theme.of(context).brightness)),
                            const SizedBox(width: 6),
                            Text('Explore Reports',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                )),
                          ],
                        ),
                      ),
                    ),

                    // ── Action Cards ──
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      sliver: SliverList.separated(
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return DashboardActionCard(
                                icon: Icons.receipt_long_rounded,
                                title: 'Bill History',
                                subtitle:
                                    '${monthBills.length} bills this month',
                                color: AppColors.accentText(
                                    Theme.of(context).brightness),
                                onTap: () =>
                                    context.push('/reports/bills'),
                              );
                            case 1:
                              return DashboardActionCard(
                                icon: Icons.trending_up_rounded,
                                title: 'Daily Sales',
                                subtitle: 'Track daily revenue',
                                color: AppColors.successText(
                                    Theme.of(context).brightness),
                                onTap: () =>
                                    context.push('/reports/daily-sales'),
                              );
                            case 2:
                              return DashboardActionCard(
                                icon: Icons.warning_amber_rounded,
                                title: 'Low Stock',
                                subtitle: lowStockCount > 0
                                    ? '$lowStockCount need reorder'
                                    : 'All well-stocked',
                                color: AppColors.warningText(
                                    Theme.of(context).brightness),
                                onTap: () =>
                                    context.push('/reports/low-stock'),
                              );
                            case 3:
                              return DashboardActionCard(
                                icon: Icons.swap_horiz_rounded,
                                title: 'Stock Movement',
                                subtitle: 'Inventory changes',
                                color: AppColors.infoText(
                                    Theme.of(context).brightness),
                                onTap: () =>
                                    context.push('/reports/stock-movements'),
                              );
                            default:
                              return DashboardActionCard(
                                icon: Icons.history_rounded,
                                title: 'Audit Trail',
                                subtitle: 'Activity timeline',
                                color: AppColors.infoText(
                                    Theme.of(context).brightness),
                                onTap: () =>
                                    context.push('/reports/audit-trail'),
                              );
                            }
                        },
                      ),
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
