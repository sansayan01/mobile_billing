import 'dart:io';

import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/app_skeleton.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StockMovementPage extends StatefulWidget {
  const StockMovementPage({super.key});

  @override
  State<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends State<StockMovementPage> with SingleTickerProviderStateMixin {
  String _selectedChangeType = 'All';
  String? _selectedStaff;
  bool _groupByProduct = false;
  late DateTime _fromDate;
  late DateTime _toDate;

  List<Map<String, dynamic>> _changeTypeItems(ThemeData t) => [
    {'label': 'All', 'icon': Icons.all_inclusive_rounded, 'color': null},
    {'label': 'add', 'icon': Icons.add_circle_outline_rounded, 'color': AppColors.success},
    {'label': 'sale', 'icon': Icons.shopping_cart_rounded, 'color': AppColors.warning},
    {'label': 'remove', 'icon': Icons.remove_circle_outline_rounded, 'color': t.colorScheme.error},
    {'label': 'return', 'icon': Icons.replay_rounded, 'color': AppColors.info},
  ];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 30));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadMovements();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadMovements() {
    context.read<ReportBloc>().add(
      LoadStockMovements(
        changeType: _selectedChangeType == 'All' ? null : _selectedChangeType,
        from: _fromDate,
        to: _toDate,
      ),
    );
    _animController.forward(from: 0);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  Color _changeColor(String type, ThemeData t) {
    switch (type.toLowerCase()) {
      case 'add':
      case 'return':
        return AppColors.successText(t.brightness);
      case 'sale':
        return AppColors.warningText(t.brightness);
      case 'remove':
        return t.colorScheme.error;
      default:
        return AppColors.textTertiary(t.brightness);
    }
  }

  IconData _changeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'add':
        return Icons.add_circle_rounded;
      case 'sale':
        return Icons.shopping_cart_rounded;
      case 'remove':
        return Icons.remove_circle_rounded;
      case 'return':
        return Icons.replay_rounded;
      default:
        return Icons.change_circle_rounded;
    }
  }

  String _formatDate(DateTime date) => DateFormat('d MMM, h:mm a').format(date);
  String _formatShortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final dateFormat = DateFormat('d MMM');

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Stock Movements', style: TextStyle(fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 22),
                tooltip: 'Export CSV',
                onPressed: _exportCsv,
              ),
            ],
            backgroundColor: t.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),

          // ── Summary Stats ──
          SliverToBoxAdapter(child: _buildSummaryStats(t)),

          // ── Type Filter Chips ──
          SliverToBoxAdapter(child: _buildTypeChips(t)),

          // ── Staff Filter + Group Toggle ──
          SliverToBoxAdapter(child: _buildStaffAndGroupControls(t)),

          // ── Date Range ──
          SliverToBoxAdapter(child: _buildDateRange(t, dateFormat)),

          // ── Movements List ──
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state.status == ReportStatus.loading) {
                return const SliverFillRemaining(
                  child: SingleChildScrollView(child: AppSkeletonList(itemCount: 6)),
                );
              }

              if (state.status == ReportStatus.error) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 64, color: t.colorScheme.error.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(state.error ?? 'Something went wrong', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadMovements,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var movements = state.stockMovements;

              // Apply staff filter
              if (_selectedStaff != null) {
                movements = movements.where((m) => m.staffName == _selectedStaff).toList();
              }

              if (movements.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(t),
                );
              }

              if (_groupByProduct) {
                // Group by product
                final grouped = <String, List<StockMovement>>{};
                for (final m in movements) {
                  grouped.putIfAbsent(m.productName, () => []).add(m);
                }
                final sortedKeys = grouped.keys.toList()..sort();
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: sortedKeys.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildGroupedCard(t, sortedKeys[index], grouped[sortedKeys[index]]!),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList.separated(
                  itemCount: movements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildMovementCard(t, movements[index], index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ────────────── Summary Stats ──────────────
  Widget _buildSummaryStats(ThemeData t) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final movements = state.stockMovements;
        final totalAdded = movements
            .where((m) => m.changeType == 'add' || m.changeType == 'return')
            .fold<int>(0, (sum, m) => sum + m.quantity);
        final totalRemoved = movements
            .where((m) => m.changeType == 'sale' || m.changeType == 'remove')
            .fold<int>(0, (sum, m) => sum + m.quantity);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.colorScheme.primaryContainer,
                t.colorScheme.primaryContainer.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _buildStatItem(t, 'Total', '${movements.length}', Icons.receipt_long_rounded, t.colorScheme.primary),
              _buildStatDivider(t),
              _buildStatItem(t, 'Added', '+$totalAdded', Icons.arrow_upward_rounded, AppColors.successText(t.brightness)),
              _buildStatDivider(t),
              _buildStatItem(t, 'Removed', '-$totalRemoved', Icons.arrow_downward_rounded, t.colorScheme.error),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(ThemeData t, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ThemeData t) {
    return Container(
      width: 1,
      height: 36,
      color: t.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  // ────────────── Type Chips ──────────────
  Widget _buildTypeChips(ThemeData t) {
    final typeItems = _changeTypeItems(t);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: typeItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = typeItems[index];
          final selected = _selectedChangeType == type['label'];
          final color = type['color'] as Color? ?? t.colorScheme.onSurface;

          return AnimatedScale(
            scale: selected ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              avatar: Icon(
                type['icon'] as IconData,
                size: 16,
                color: selected ? Colors.white : color,
              ),
              label: Text(
                type['label'] == 'All' ? 'All' : (type['label'] as String).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : color,
                ),
              ),
              selected: selected,
              selectedColor: color,
              backgroundColor: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              onSelected: (_) => setState(() => _selectedChangeType = type['label'] as String),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  // ────────────── Staff Filter + Group Toggle ──────────────
  Widget _buildStaffAndGroupControls(ThemeData t) {
    final movements = context.read<ReportBloc>().state.stockMovements;
    final staffNames = movements.map((m) => m.staffName).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Staff filter
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStaff ?? 'All',
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, size: 18, color: t.colorScheme.onSurfaceVariant),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface),
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All Staff')),
                    ...staffNames.map((name) => DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 12)))),
                  ],
                  onChanged: (v) => setState(() => _selectedStaff = v == 'All' ? null : v),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Group by product toggle
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact().then((_) => setState(() => _groupByProduct = !_groupByProduct)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _groupByProduct ? AppColors.accent : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.group_work_rounded, size: 16, color: _groupByProduct ? AppColors.onAccent : t.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _groupByProduct ? AppColors.onAccent : t.colorScheme.onSurface)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── Grouped Card (Product-wise) ──────────────
  Widget _buildGroupedCard(ThemeData t, String productName, List<StockMovement> movements) {
    final totalAdded = movements.where((m) => m.changeType == 'add' || m.changeType == 'return').fold<int>(0, (sum, m) => sum + m.quantity);
    final totalRemoved = movements.where((m) => m.changeType == 'sale' || m.changeType == 'remove').fold<int>(0, (sum, m) => sum + m.quantity);
    final staffSet = movements.map((m) => m.staffName).toSet();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.colorScheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: t.colorScheme.primary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Product name
        Row(children: [
          Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.accentText(t.brightness)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
          ),
          Text('${movements.length} moves', style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 10),
        // Stats row
        Row(children: [
          // Added
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_circle_rounded, size: 12, color: AppColors.successText(t.brightness)),
              const SizedBox(width: 4),
              Text('+$totalAdded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successText(t.brightness))),
            ]),
          ),
          const SizedBox(width: 8),
          // Removed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: t.colorScheme.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.remove_circle_rounded, size: 12, color: t.colorScheme.error),
              const SizedBox(width: 4),
              Text('-$totalRemoved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.colorScheme.error)),
            ]),
          ),
          const Spacer(),
          // Staff
          Text(staffSet.join(', '), style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
        ]),
        const SizedBox(height: 6),
        // Recent movement
        Text(
          'Last: ${movements.last.changeType.toUpperCase()} ${movements.last.quantity} by ${movements.last.staffName}',
          style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant),
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }

  // ────────────── Date Range ──────────────
  Widget _buildDateRange(ThemeData t, DateFormat dateFormat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildDateButton(t, _fromDate, _pickFromDate),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('→', style: TextStyle(color: t.colorScheme.onSurfaceVariant, fontSize: 16)),
          ),
          _buildDateButton(t, _toDate, _pickToDate),
          const Spacer(),
          // Apply button
          Container(
            decoration: BoxDecoration(
              color: t.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _loadMovements,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Apply',
                    style: TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(ThemeData t, DateTime date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                _formatShortDate(date),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────── Movement Card ──────────────
  Widget _buildMovementCard(ThemeData t, StockMovement movement, int index) {
    final isPositive = movement.changeType == 'add' || movement.changeType == 'return';
    final color = _changeColor(movement.changeType, t);
    final icon = _changeIcon(movement.changeType);
    final sign = isPositive ? '+' : '-';

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = (index * 0.06).clamp(0.0, 0.5);
        final animValue = (_animController.value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.colorScheme.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon Circle ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),

            // ── Details ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    movement.productName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Staff + Date
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 12, color: t.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        movement.staffName,
                        style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_rounded, size: 12, color: t.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(movement.createdAt),
                        style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  // Notes
                  if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      movement.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // ── Quantity ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${movement.quantity}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                // Change type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    movement.changeType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────── Empty State ──────────────
  Widget _buildEmptyState(ThemeData t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: t.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Movements Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: t.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No stock movements for selected filters',
            style: TextStyle(
              fontSize: 14,
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── Export ──────────────
  Future<void> _exportCsv() async {
    final movements = context.read<ReportBloc>().state.stockMovements;
    if (movements.isEmpty) {
      if (mounted) {
        AppFeedback.info(context, 'No movements to export');
      }
      return;
    }

    final rows = movements.map((m) => [
      m.productName,
      m.changeType,
      '${m.quantity}',
      m.staffName,
      DateFormat('yyyy-MM-dd HH:mm').format(m.createdAt),
      m.notes ?? '',
    ]).toList();

    final csv = 'Product,Type,Quantity,Staff,Date,Notes\n${rows.map((r) => r.join(',')).join('\n')}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/stock_movements.csv');
    await file.writeAsString(csv);

    if (mounted) {
      await Share.shareXFiles([XFile(file.path)], text: 'Stock Movements Report');
    }
  }
}
