import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// ignore_for_file: prefer_const_constructors
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

enum DateRange { today, thisWeek, thisMonth, lastMonth, custom }

class BillHistoryPage extends StatefulWidget {
  const BillHistoryPage({super.key});

  @override
  State<BillHistoryPage> createState() => _BillHistoryPageState();
}

class _BillHistoryPageState extends State<BillHistoryPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  DateRange _selectedRange = DateRange.thisMonth;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _paymentMethodFilter;
  String? _staffFilter;

  @override
  void initState() {
    super.initState();
    _applyDateRange(DateRange.thisMonth);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyDateRange(DateRange range) {
    final now = DateTime.now();
    DateTime from;
    DateTime to = now;

    switch (range) {
      case DateRange.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case DateRange.thisWeek:
        from = now.subtract(Duration(days: now.weekday - 1));
        from = DateTime(from.year, from.month, from.day);
        break;
      case DateRange.thisMonth:
        from = DateTime(now.year, now.month, 1);
        break;
      case DateRange.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        from = lastMonth;
        to = DateTime(now.year, now.month, 0);
        break;
      case DateRange.custom:
        return;
    }

    setState(() {
      _fromDate = from;
      _toDate = to;
      _selectedRange = range;
    });
    _loadBills();
  }

  void _loadBills({int page = 1}) {
    context.read<ReportBloc>().add(
      LoadBillHistory(
        from: _fromDate,
        to: _toDate,
        page: page,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        paymentMethod: _paymentMethodFilter,
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadBills(page: 1);
  }

  Future<void> _selectDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _selectedRange = DateRange.custom;
      });
      _loadBills();
    }
  }

  Future<void> _exportBills(List<BillSummary> bills) async {
    final rows = <List<dynamic>>[];
    rows.add(['Bill ID', 'Date', 'Staff', 'Customer', 'Phone', 'Items', 'Total', 'Discount', 'Payment', 'Status', 'Due']);
    final dateFormat = DateFormat('dd MMM yyyy');
    for (final bill in bills) {
      rows.add([
        bill.id.substring(0, bill.id.length > 8 ? 8 : bill.id.length),
        dateFormat.format(bill.createdAt), bill.staffName,
        bill.customerName ?? '', bill.customerPhone ?? '',
        bill.itemCount, bill.grandTotal, bill.discount,
        bill.paymentMethod, bill.paymentStatus, bill.dueAmount,
      ]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/bills_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Bills Export');
    if (mounted) {
      AppFeedback.success(context, 'Exported ${bills.length} bills');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  PDF EXPORT
  // ═══════════════════════════════════════════════════════════════
  Future<void> _exportPdf(List<BillSummary> bills) async {
    final pdf = pw.Document();
    final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final df = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Bill History Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('${df.format(_fromDate)} — ${df.format(_toDate)}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.Text('${bills.length} bills', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 10),
          pw.Divider(),
        ]),
        footer: (context) => pw.Center(child: pw.Text('Generated from Billing App', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500))),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['Bill ID', 'Date', 'Staff', 'Customer', 'Total', 'Payment', 'Status', 'Due'],
            data: bills.map((b) => [
              b.id.substring(0, min(8, b.id.length)),
              df.format(b.createdAt),
              b.staffName,
              b.customerName ?? '-',
              nf.format(b.grandTotal),
              b.paymentMethod.toUpperCase(),
              b.paymentStatus.toUpperCase(),
              b.dueAmount > 0 ? nf.format(b.dueAmount) : '-',
            ]).toList(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1),
              7: const pw.FlexColumnWidth(1),
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    if (mounted) {
      AppFeedback.success(context, 'PDF exported');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final numberFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: const AdaptiveAppBarLeading(),
        title: const Text('Bill History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              final bills = context.read<ReportBloc>().state.billHistory;
              if (bills.isEmpty) {
                AppFeedback.info(context, 'No bills to export');
              } else {
                _exportPdf(bills);
              }
            },
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: Icon(Icons.file_download_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              final bills = context.read<ReportBloc>().state.billHistory;
              if (bills.isEmpty) {
                AppFeedback.info(context, 'No bills to export');
              } else {
                _exportBills(bills);
              }
            },
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Stats Header ───
          _buildStatsHeader(theme, numberFormat),

          // ─── Quick Date Filters ───
          _buildQuickDateFilters(theme),

          // ─── Search + Filters ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search bills...',
                      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _searchController.clear(); _onSearchChanged(''); })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 10),
                // Payment + Staff filter row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _paymentMethodFilter ?? 'All',
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down, size: 18, color: theme.colorScheme.onSurfaceVariant),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Payments')),
                              DropdownMenuItem(value: 'cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'upi', child: Text('UPI')),
                              DropdownMenuItem(value: 'card', child: Text('Card')),
                            ],
                            onChanged: (v) => setState(() { _paymentMethodFilter = v == 'All' ? null : v; _loadBills(); }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _staffFilter ?? 'All',
                            isDense: true,
                            icon: Icon(Icons.arrow_drop_down, size: 18, color: theme.colorScheme.onSurfaceVariant),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                            items: _buildStaffFilterItems(),
                            onChanged: (v) => setState(() { _staffFilter = v == 'All' ? null : v; _loadBills(); }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Bill List ───
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state.status == ReportStatus.loading && state.billHistory.isEmpty) {
                  return const SingleChildScrollView(child: AppSkeletonList(itemCount: 7));
                }

                if (state.status == ReportStatus.error && state.billHistory.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: theme.colorScheme.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.error_outline_rounded, size: 40, color: theme.colorScheme.error)),
                    const SizedBox(height: 16),
                    Text(state.error ?? 'Something went wrong', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(onPressed: _loadBills, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
                  ]));
                }

                final bills = state.billHistory;
                if (bills.isEmpty && state.status == ReportStatus.loaded) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                     TweenAnimationBuilder<double>(tween: Tween(begin: 0.6, end: 1.0), duration: const Duration(milliseconds: 800), curve: Curves.easeOutBack,
                         builder: (_, val, child) => Transform.scale(scale: val, child: child),
                         child: Container(width: 100, height: 100, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentSubtle, AppColors.accent.withValues(alpha: 0.04)]), shape: BoxShape.circle),
                             child: Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.accentText(theme.brightness)))),
                    const SizedBox(height: 20),
                    Text('No Bills Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Bills will appear here once you\nmake your first sale', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
                  ]));
                }

                // Filter by staff if selected
                final filteredBills = _staffFilter != null
                    ? bills.where((b) => b.staffName == _staffFilter).toList()
                    : bills;

                return RefreshIndicator(
                  onRefresh: () async { HapticFeedback.mediumImpact(); _loadBills(); await Future.delayed(const Duration(milliseconds: 500)); },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    children: [
                      // Top Customers Section
                      _buildTopCustomers(filteredBills, theme),
                      // Bill Comparison
                      _buildBillComparison(theme, numberFormat),
                      // Payment Pie Chart
                      _buildPaymentPieChart(filteredBills, theme),
                      // Sales Trend Line
                      _buildSalesTrend(filteredBills, theme),
                      // Bill List
                      ...List.generate(filteredBills.length + (state.hasMorePages ? 1 : 0), (index) {
                        if (index == filteredBills.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: ElevatedButton(
                              onPressed: () => context.read<ReportBloc>().add(LoadBillHistory(
                                from: _fromDate,
                                to: _toDate,
                                page: state.currentPage + 1,
                                searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                                paymentMethod: _paymentMethodFilter,
                              )),
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Load More'),
                            )),
                          );
                        }
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 350 + (index * 60).clamp(0, 600)),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, child) => Transform.translate(offset: Offset(0, 20 * (1 - val)), child: Opacity(opacity: val, child: child)),
                          child: _buildBillCard(filteredBills[index], dateFormat, numberFormat),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATS HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsHeader(ThemeData t, NumberFormat nf) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final bills = state.billHistory;
        final totalRevenue = bills.fold(0.0, (sum, b) => sum + b.grandTotal);
        final paidCount = bills.where((b) => b.paymentStatus == 'paid').length;
        final partialCount = bills.where((b) => b.paymentStatus == 'partial').length;
        final dueCount = bills.where((b) => b.paymentStatus == 'due').length;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.onAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.onAccent, size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${bills.length}', style: TextStyle(color: AppColors.onAccent, fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
                    Text('Bills', style: TextStyle(color: AppColors.onAccent.withValues(alpha: 0.75), fontSize: 12)),
                  ]),
                ])),
                Container(width: 1, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.onAccent.withValues(alpha: 0.1), AppColors.onAccent.withValues(alpha: 0.5), AppColors.onAccent.withValues(alpha: 0.1)]))),
                Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.onAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.currency_rupee_rounded, color: AppColors.onAccent, size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(nf.format(totalRevenue), style: AppMoneyText.sized(20, FontWeight.w800, AppColors.onAccent)),
                    Text('Revenue', style: TextStyle(color: AppColors.onAccent.withValues(alpha: 0.75), fontSize: 12)),
                  ]),
                ])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _quickStatBadge('Paid', paidCount, AppColors.success),
                const SizedBox(width: 8),
                _quickStatBadge('Partial', partialCount, AppColors.warning),
                const SizedBox(width: 8),
                _quickStatBadge('Due', dueCount, t.colorScheme.error),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _quickStatBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.onAccent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: AppColors.onAccent.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(color: AppColors.onAccent, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  QUICK DATE FILTERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickDateFilters(ThemeData t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _dateFilterChip('Today', DateRange.today, Icons.today_rounded),
          const SizedBox(width: 6),
          _dateFilterChip('Week', DateRange.thisWeek, Icons.view_week_rounded),
          const SizedBox(width: 6),
          _dateFilterChip('Month', DateRange.thisMonth, Icons.calendar_month_rounded),
          const SizedBox(width: 6),
          _dateFilterChip('Last Month', DateRange.lastMonth, Icons.history_rounded),
          const SizedBox(width: 6),
          _dateFilterChip('Custom', DateRange.custom, Icons.date_range_rounded),
        ],
      ),
    );
  }

  Widget _dateFilterChip(String label, DateRange range, IconData icon) {
    final isSelected = _selectedRange == range;
    final accentText = AppColors.accentText(Theme.of(context).brightness);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (range == DateRange.custom) {
          _selectDate(isFrom: true);
        } else {
          _applyDateRange(range);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.accentSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.onAccent : accentText),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? AppColors.onAccent : accentText)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STAFF FILTER ITEMS
  // ═══════════════════════════════════════════════════════════════
  List<DropdownMenuItem<String>> _buildStaffFilterItems() {
    final bills = context.read<ReportBloc>().state.billHistory;
    final staffNames = bills.map((b) => b.staffName).toSet().toList()..sort();
    return [
      const DropdownMenuItem(value: 'All', child: Text('All Staff')),
      ...staffNames.map((name) => DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 12)))),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOP CUSTOMERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopCustomers(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    final customerMap = <String, int>{};
    for (final b in bills) {
      if (b.customerName != null && b.customerName!.isNotEmpty) {
        customerMap[b.customerName!] = (customerMap[b.customerName!] ?? 0) + 1;
      }
    }
    if (customerMap.isEmpty) return const SizedBox.shrink();

    final topCustomers = customerMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topCustomers.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 10),
          child: Row(children: [
            Icon(Icons.people_rounded, size: 16, color: AppColors.accentText(t.brightness)),
            const SizedBox(width: 6),
            Text('Top Customers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
          ]),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: top5.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final entry = top5[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentSubtle),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.person_rounded, size: 14, color: AppColors.accentText(t.brightness)),
                  const SizedBox(width: 6),
                  Text(entry.key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentText(t.brightness))),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                    child: Text('${entry.value}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentText(t.brightness))),
                  ),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BILL COMPARISON
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBillComparison(ThemeData t, NumberFormat nf) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final bills = state.billHistory;
        if (bills.isEmpty) return const SizedBox.shrink();

        final now = DateTime.now();
        final thisMonthStart = DateTime(now.year, now.month, 1);
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);

        final thisMonthBills = bills.where((b) => b.createdAt.isAfter(thisMonthStart.subtract(const Duration(days: 1)))).toList();
        final lastMonthBills = bills.where((b) => b.createdAt.isAfter(lastMonthStart.subtract(const Duration(days: 1))) && b.createdAt.isBefore(lastMonthEnd.add(const Duration(days: 1)))).toList();

        final thisMonthRevenue = thisMonthBills.fold(0.0, (sum, b) => sum + b.grandTotal);
        final lastMonthRevenue = lastMonthBills.fold(0.0, (sum, b) => sum + b.grandTotal);

        if (lastMonthBills.isEmpty) return const SizedBox.shrink();

        final revenueChange = lastMonthRevenue > 0 ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100) : 0.0;
        final isUp = revenueChange >= 0;
        final upColor = AppColors.successText(t.brightness);
        final downColor = t.colorScheme.error;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.compare_arrows_rounded, size: 20, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('vs Last Month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface),
                      children: [
                        TextSpan(text: '${thisMonthBills.length} bills · '),
                        TextSpan(text: nf.format(thisMonthRevenue), style: AppMoneyText.sized(13, FontWeight.w600, t.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUp ? upColor.withValues(alpha: 0.1) : downColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: isUp ? upColor : downColor),
                  const SizedBox(width: 4),
                  Text('${revenueChange.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isUp ? upColor : downColor)),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PAYMENT PIE CHART
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentPieChart(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    final cashCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'cash').length;
    final upiCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'upi').length;
    final cardCount = bills.where((b) => b.paymentMethod.toLowerCase() == 'card').length;
    final total = cashCount + upiCount + cardCount;
    if (total == 0) return const SizedBox.shrink();

    final cashAmt = bills.where((b) => b.paymentMethod.toLowerCase() == 'cash').fold(0.0, (s, b) => s + b.grandTotal);
    final upiAmt = bills.where((b) => b.paymentMethod.toLowerCase() == 'upi').fold(0.0, (s, b) => s + b.grandTotal);
    final cardAmt = bills.where((b) => b.paymentMethod.toLowerCase() == 'card').fold(0.0, (s, b) => s + b.grandTotal);
    final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.pie_chart_rounded, size: 16, color: AppColors.accentText(t.brightness)),
          const SizedBox(width: 8),
          Text('Payment Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Row(children: [
            // Pie chart
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _PieChartPainter(
                  values: [cashAmt, upiAmt, cardAmt],
                  colors: [AppColors.success, AppColors.info, AppColors.warning],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Legend
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _legendRow('Cash', '$cashCount bills', nf.format(cashAmt), AppColors.success),
                const SizedBox(height: 6),
                _legendRow('UPI', '$upiCount bills', nf.format(upiAmt), AppColors.info),
                const SizedBox(height: 6),
                _legendRow('Card', '$cardCount bills', nf.format(cardAmt), AppColors.warning),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _legendRow(String label, String count, String amount, Color color) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(width: 4),
      Text(count, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const Spacer(),
      Text(amount, style: AppMoneyText.sized(12, FontWeight.w700, Theme.of(context).colorScheme.onSurface)),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  //  SALES TREND LINE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSalesTrend(List<BillSummary> bills, ThemeData t) {
    if (bills.isEmpty) return const SizedBox.shrink();

    // Group by date
    final dailyMap = <String, double>{};
    final df = DateFormat('d MMM');
    for (final b in bills) {
      final key = df.format(b.createdAt);
      dailyMap[key] = (dailyMap[key] ?? 0) + b.grandTotal;
    }

    if (dailyMap.length < 2) return const SizedBox.shrink();

    final entries = dailyMap.entries.toList();
    final maxVal = entries.fold<double>(0, (max, e) => e.value > max ? e.value : max);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.show_chart_rounded, size: 16, color: AppColors.accentText(t.brightness)),
          const SizedBox(width: 8),
          Text('Sales Trend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: Size.infinite,
            painter: _LineChartPainter(
              values: entries.map((e) => e.value).toList(),
              labels: entries.map((e) => e.key).toList(),
              maxValue: maxVal,
              lineColor: AppColors.accentText(t.brightness),
              fillColor: AppColors.accentSubtle,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Bottom labels
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: entries.take(7).map((e) =>
          Text(e.key, style: TextStyle(fontSize: 9, color: t.colorScheme.onSurfaceVariant))
        ).toList()),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BILL CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBillCard(BillSummary bill, DateFormat dateFormat, NumberFormat numberFormat) {
    final t = Theme.of(context);
    final shortId = bill.id.length > 8 ? bill.id.substring(0, 8) : bill.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/reports/bills/${bill.id}', extra: bill),
        child: Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: t.shadowColor.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('Bill #$shortId', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 8),
                _buildPaymentStatusBadge(bill),
              ]),
              Text(numberFormat.format(bill.grandTotal), style: AppMoneyText.sized(18, FontWeight.bold, AppColors.accentText(t.brightness))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.storefront_rounded, size: 14, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(bill.staffName, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Icon(Icons.shopping_bag_outlined, size: 14, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${bill.itemCount} items', style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
              if (bill.discount > 0) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                  child: Text('-${_formatDiscount(bill.discount)}', style: AppMoneyText.sized(11, FontWeight.w600, AppColors.accentText(t.brightness))),
                ),
              ],
            ]),
            if ((bill.customerName != null && bill.customerName!.isNotEmpty) || (bill.customerPhone != null && bill.customerPhone!.isNotEmpty)) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.person_outline_rounded, size: 14, color: t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                if (bill.customerName != null && bill.customerName!.isNotEmpty)
                  Text(bill.customerName!, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                if (bill.customerPhone != null && bill.customerPhone!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.phone_rounded, size: 12, color: t.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(bill.customerPhone!, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                ],
              ]),
            ],
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(dateFormat.format(bill.createdAt), style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant)),
              const Spacer(),
              if (bill.hasDue)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withValues(alpha: 0.2))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warningText(t.brightness)),
                    const SizedBox(width: 4),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warningText(t.brightness)),
                        children: [
                          const TextSpan(text: 'Due: '),
                          TextSpan(
                            text: '₹${_formatDueAmount(bill.dueAmount)}',
                            style: AppMoneyText.sized(11, FontWeight.w700, AppColors.warningText(t.brightness)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _paymentColor(bill.paymentMethod).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(bill.paymentMethod.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _paymentColor(bill.paymentMethod))),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(BillSummary bill) {
    final b = Theme.of(context).brightness;
    Color bgColor, textColor;
    String label;
    IconData icon;

    switch (bill.paymentStatus) {
      case 'paid': bgColor = AppColors.success.withValues(alpha: 0.12); textColor = AppColors.successText(b); label = 'Paid'; icon = Icons.check_circle_rounded;
      case 'partial': bgColor = AppColors.warning.withValues(alpha: 0.12); textColor = AppColors.warningText(b); label = 'Partial'; icon = Icons.schedule_rounded;
      case 'due': bgColor = Theme.of(context).colorScheme.error.withValues(alpha: 0.12); textColor = Theme.of(context).colorScheme.error; label = 'Due'; icon = Icons.warning_amber_rounded;
      default: bgColor = AppColors.success.withValues(alpha: 0.12); textColor = AppColors.successText(b); label = 'Paid'; icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor)),
      ]),
    );
  }

  Color _paymentColor(String method) {
    final b = Theme.of(context).brightness;
    switch (method.toLowerCase()) {
      case 'upi': return AppColors.infoText(b);
      case 'cash': return AppColors.successText(b);
      case 'card': return AppColors.warningText(b);
      default: return AppColors.accentText(b);
    }
  }

  String _formatDueAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    if (fixed.endsWith('.00')) return fixed.substring(0, fixed.length - 3);
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatDiscount(double discount) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(discount);
  }
}

// ═══════════════════════════════════════════════════════════════
//  PIE CHART PAINTER
// ═══════════════════════════════════════════════════════════════
class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return;

    var startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweepAngle = (values[i] / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true, paint,
      );
      startAngle += sweepAngle;
    }
    // Inner white circle (donut effect)
    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
//  LINE CHART PAINTER
// ═══════════════════════════════════════════════════════════════
class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || maxValue == 0) return;

    const padding = EdgeInsets.fromLTRB(4, 8, 4, 24);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = padding.left + (i / (values.length - 1)) * chartWidth;
      final y = padding.top + chartHeight - (values[i] / maxValue) * chartHeight;
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path()
      ..moveTo(points.first.dx, padding.top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, padding.top + chartHeight);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line
    final linePath = Path()
      ..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 3.5, Paint()..color = lineColor);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
