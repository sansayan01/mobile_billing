import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';

enum TimeRange { week, month, custom }

class DailySalesPage extends StatefulWidget {
  const DailySalesPage({super.key});

  @override
  State<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends State<DailySalesPage> {
  late DateTime _selectedDate;
  TimeRange _timeRange = TimeRange.week;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  void _loadData() {
    final from = _selectedDate;
    context.read<ReportBloc>().add(LoadDailySales(from));
    context.read<ReportBloc>().add(LoadSalesRange(
      from: from.subtract(const Duration(days: 6)),
      to: from,
    ));
    // Load bills for the selected day (for hourly heatmap, best selling, payment split)
    final dayStart = DateTime(from.year, from.month, from.day);
    final dayEnd = DateTime(from.year, from.month, from.day, 23, 59, 59);
    context.read<ReportBloc>().add(LoadBillHistory(from: dayStart, to: dayEnd, page: 1));
  }

  void _applyTimeRange(TimeRange range) {
    setState(() {
      _timeRange = range;
      if (range == TimeRange.week || range == TimeRange.month) {
        _selectedDate = DateTime.now();
      }
    });
    _loadData();
  }

  void _goPreviousDay() {
    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
    _loadData();
  }

  void _goNextDay() {
    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
    _loadData();
  }

  void _goToday() {
    setState(() => _selectedDate = DateTime.now());
    _loadData();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _timeRange = TimeRange.custom;
      });
      _loadData();
    }
  }

  Future<void> _exportData(List<DailySales> sales) async {
    final rows = <List<dynamic>>[['Date', 'Total Sales', 'Bill Count', 'Average Bill', 'Discount']];
    final dateFormat = DateFormat('dd MMM yyyy');
    for (final s in sales) {
      rows.add([dateFormat.format(s.date), s.totalSales, s.billCount, s.averageBill, s.totalDiscount]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/daily_sales_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Daily Sales Export');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${sales.length} days!'), backgroundColor: Colors.green),
      );
    }
  }

  String _fc(double v) => NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(v);
  String _fn(int v) => NumberFormat('#,##0').format(v);
  String _dayAbbr(DateTime d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: theme.primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Daily Sales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              final sales = context.read<ReportBloc>().state.salesRange;
              if (sales.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No data to export'), backgroundColor: Colors.orange),
                );
              } else {
                _exportData(sales);
              }
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status == ReportStatus.loading && state.dailySales == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportStatus.error && state.dailySales == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline_rounded, size: 40, color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  Text(state.error ?? 'Something went wrong', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                ],
              ),
            );
          }

          final dailySales = state.dailySales;
          final salesRange = state.salesRange;
          final maxSales = salesRange.fold<double>(0, (max, s) => s.totalSales > max ? s.totalSales : max);
          final totalRevenue = salesRange.fold<double>(0, (sum, s) => sum + s.totalSales);
          final totalBills = salesRange.fold<int>(0, (sum, s) => sum + s.billCount);

          // Get bills for today's detail (hourly heatmap, best selling, payment split)
          final todayBills = state.billHistory;

          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Navigation
                  _buildDateNav(theme),
                  const SizedBox(height: 16),

                  // Summary Header
                  _buildSummaryHeader(totalRevenue, totalBills, dailySales, theme),
                  const SizedBox(height: 16),

                  // Time Range Toggle
                  _buildTimeRangeToggle(theme),
                  const SizedBox(height: 16),

                  // Stat Cards
                  if (dailySales != null) _buildStatCards(dailySales, theme),
                  if (dailySales != null) const SizedBox(height: 20),

                  // ── Yesterday Comparison ──
                  _buildYesterdayComparison(dailySales, theme),
                  const SizedBox(height: 16),

                  // ── Cash vs UPI Split ──
                  _buildPaymentSplit(todayBills, theme),
                  const SizedBox(height: 16),

                  // ── Best Selling Product ──
                  _buildBestSelling(todayBills, theme),
                  const SizedBox(height: 16),

                  // ── Hourly Heatmap ──
                  _buildHourlyHeatmap(todayBills, theme),
                  const SizedBox(height: 16),

                  // Bar Chart
                  Text('Sales Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _buildBarChart(salesRange, maxSales, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DATE NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDateNav(ThemeData t) {
    final isToday = _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.dividerColor),
      ),
      child: Row(children: [
        IconButton(onPressed: _goPreviousDay, icon: const Icon(Icons.chevron_left_rounded, size: 22)),
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(DateFormat('d MMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        IconButton(onPressed: _goNextDay, icon: const Icon(Icons.chevron_right_rounded, size: 22)),
        if (!isToday)
          TextButton(
            onPressed: _goToday,
            child: Text('Today', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SUMMARY HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSummaryHeader(double totalRevenue, int totalBills, DailySales? daily, ThemeData t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_fc(totalRevenue),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                Text('Period Revenue', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
              ]),
            ]),
          ),
          Container(
            width: 1,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.5),
                Colors.white.withValues(alpha: 0.1),
              ]),
            ),
          ),
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$totalBills',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                Text('Total Bills', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
              ]),
            ]),
          ),
        ]),
        if (daily != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            _miniStat('Today Sales', _fc(daily.totalSales)),
            _miniStat('Bills', '${daily.billCount}'),
            _miniStat('Avg Bill', _fc(daily.averageBill)),
          ]),
        ],
      ]),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TIME RANGE TOGGLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTimeRangeToggle(ThemeData t) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _rangeBtn('This Week', TimeRange.week),
        _rangeBtn('This Month', TimeRange.month),
      ]),
    );
  }

  Widget _rangeBtn(String label, TimeRange range) {
    final isSelected = _timeRange == range;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _applyTimeRange(range);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STAT CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatCards(DailySales ds, ThemeData t) {
    return Column(children: [
      Row(children: [
        Expanded(child: _statCard('Total Sales', _fc(ds.totalSales), Colors.green, Icons.trending_up_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Bill Count', _fn(ds.billCount), Colors.blue, Icons.receipt_long_rounded)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _statCard('Average Bill', _fc(ds.averageBill), Colors.orange, Icons.analytics_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Total Discount', _fc(ds.totalDiscount), Colors.red, Icons.discount_rounded)),
      ]),
    ]);
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  YESTERDAY COMPARISON (Feature #5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildYesterdayComparison(DailySales? today, ThemeData t) {
    if (today == null || today.billCount == 0) return const SizedBox.shrink();

    final yesterday = _selectedDate.subtract(const Duration(days: 1));
    final salesRange = context.read<ReportBloc>().state.salesRange;

    // Find yesterday in sales range
    DailySales? yesterdaySales;
    for (final s in salesRange) {
      if (s.date.day == yesterday.day && s.date.month == yesterday.month && s.date.year == yesterday.year) {
        yesterdaySales = s;
        break;
      }
    }

    if (yesterdaySales == null || yesterdaySales.totalSales == 0) return const SizedBox.shrink();

    final change = ((today.totalSales - yesterdaySales.totalSales) / yesterdaySales.totalSales * 100);
    final isUp = change >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isUp ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isUp ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isUp ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('vs Yesterday', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(
              '${_fc(today.totalSales)} vs ${_fc(yesterdaySales.totalSales)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isUp ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${isUp ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isUp ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CASH vs UPI SPLIT (Feature #3)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentSplit(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    final cashCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'cash').length;
    final upiCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'upi').length;
    final cardCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'card').length;
    final total = cashCount + upiCount + cardCount;
    if (total == 0) return const SizedBox.shrink();

    final cashPercent = (cashCount / total * 100).round();
    final upiPercent = (upiCount / total * 100).round();
    final cardPercent = 100 - cashPercent - upiPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.pie_chart_rounded, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Payment Split', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 12),
          // Mini pie chart using CustomPaint
          SizedBox(
            height: 80,
            child: Row(children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _DonutPainter(
                    values: [cashCount.toDouble(), upiCount.toDouble(), cardCount.toDouble()],
                    colors: [Colors.green, Colors.purple, Colors.blue],
                    strokeWidth: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _splitLegend('Cash', '$cashCount ($cashPercent%)', Colors.green),
                  const SizedBox(height: 4),
                  _splitLegend('UPI', '$upiCount ($upiPercent%)', Colors.purple),
                  const SizedBox(height: 4),
                  _splitLegend('Card', '$cardCount ($cardPercent%)', Colors.blue),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _splitLegend(String label, String value, Color color) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  //  BEST SELLING PRODUCT (Feature #4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBestSelling(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    // Aggregate product sales
    final productMap = <String, int>{};
    final productRevenue = <String, double>{};
    for (final bill in bills) {
      for (final item in bill.items) {
        productMap[item.productName] = (productMap[item.productName] ?? 0) + item.quantity;
        productRevenue[item.productName] = (productRevenue[item.productName] ?? 0) + item.total;
      }
    }

    if (productMap.isEmpty) return const SizedBox.shrink();

    final sorted = productMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.emoji_events_rounded, size: 16, color: Colors.amber[700]),
            const SizedBox(width: 8),
            Text('Best Selling Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 12),
          ...top5.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final maxQty = top5.first.value;
            final percent = maxQty > 0 ? item.value / maxQty : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                // Rank badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.amber.withValues(alpha: 0.15) : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: i == 0 ? Colors.amber[700] : t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Product name + quantity
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 4,
                        backgroundColor: t.colorScheme.surfaceContainerHighest,
                        color: i == 0 ? Colors.amber : AppTheme.primaryColor,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${item.value} units', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                  Text(_fc(productRevenue[item.key] ?? 0),
                      style: TextStyle(fontSize: 10, color: t.colorScheme.onSurfaceVariant)),
                ]),
              ]),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HOURLY HEATMAP (Feature #1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHourlyHeatmap(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    // Group by hour (6-hour blocks for phone shop: 6-12, 12-18, 18-24)
    final blocks = [
      {'label': '6AM-12PM', 'start': 6, 'end': 12, 'icon': Icons.wb_sunny_outlined},
      {'label': '12PM-6PM', 'start': 12, 'end': 18, 'icon': Icons.wb_sunny_rounded},
      {'label': '6PM-12AM', 'start': 18, 'end': 24, 'icon': Icons.nights_stay_rounded},
      {'label': '12AM-6AM', 'start': 0, 'end': 6, 'icon': Icons.dark_mode_rounded},
    ];

    final blockSales = blocks.map((block) {
      final start = block['start'] as int;
      final end = block['end'] as int;
      return bills
          .where((b) => b.createdAt.hour >= start && b.createdAt.hour < end)
          .fold<double>(0, (sum, b) => sum + b.grandTotal);
    }).toList();

    final maxBlock = blockSales.fold<double>(0, (max, s) => s > max ? s : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.access_time_rounded, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Sales by Time Block', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 12),
          ...List.generate(4, (i) {
            final block = blocks[i];
            final sales = blockSales[i];
            final percent = maxBlock > 0 ? sales / maxBlock : 0.0;
            final intensity = percent.clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(block['icon'] as IconData, size: 16, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(block['label'] as String,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.grey.withValues(alpha: 0.1), AppTheme.primaryColor, intensity),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _fc(sales),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: intensity > 0.5 ? Colors.white : t.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BAR CHART
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBarChart(List<DailySales> salesRange, double maxSales, ThemeData t) {
    if (salesRange.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: t.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text('No sales data', style: TextStyle(color: t.colorScheme.onSurfaceVariant))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: salesRange.map((sale) {
            final barHeight = maxSales > 0 ? ((sale.totalSales / maxSales) * 160).clamp(4.0, 160.0) : 4.0;
            final isToday = sale.date.day == _selectedDate.day && sale.date.month == _selectedDate.month;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(_fc(sale.totalSales),
                      style: TextStyle(fontSize: 9, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: barHeight),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, child) => Container(
                      height: val,
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        boxShadow: isToday
                            ? [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_dayAbbr(sale.date),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? AppTheme.primaryColor : t.colorScheme.onSurfaceVariant)),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DONUT PAINTER for Payment Split
// ═══════════════════════════════════════════════════════════════
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  _DonutPainter({required this.values, required this.colors, this.strokeWidth = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth / 2;
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return;

    var startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweepAngle = (values[i] / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
