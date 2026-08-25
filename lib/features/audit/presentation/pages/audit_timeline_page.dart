import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/features/audit/domain/entities/audit_log.dart';
import 'package:billing_app/features/audit/presentation/bloc/audit_bloc.dart';
import 'package:billing_app/features/audit/presentation/bloc/audit_event.dart';
import 'package:billing_app/features/audit/presentation/bloc/audit_state.dart';

class AuditTimelinePage extends StatefulWidget {
  const AuditTimelinePage({super.key});

  @override
  State<AuditTimelinePage> createState() => _AuditTimelinePageState();
}

class _AuditTimelinePageState extends State<AuditTimelinePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Filters
  String? _filterEntityType;
  String? _filterAction;
  String? _filterStaff;
  DateTime? _filterFrom;
  DateTime? _filterTo;

  // ── Lifecycle ──
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Data ──
  void _loadLogs() {
    context.read<AuditBloc>().add(LoadAuditLogs(
      entityType: _filterEntityType,
      action: _filterAction,
      from: _filterFrom,
      to: _filterTo,
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    ));
  }

  Future<void> _onRefresh() async {
    _loadLogs();
    // Wait for bloc to finish loading
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Debounced search — 300ms
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadLogs();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filterEntityType = null;
      _filterAction = null;
      _filterStaff = null;
      _filterFrom = null;
      _filterTo = null;
    });
    _loadLogs();
  }

  // ── Helpers ──
  Color _entityColor(String entityType, Brightness b) {
    switch (entityType) {
      case 'stock': return AppColors.successText(b);
      case 'bill': return AppColors.infoText(b);
      case 'product': return AppColors.warningText(b);
      case 'category': return AppColors.textSecondary(b);
      case 'auth': return AppColors.accentText(b);
      case 'settings': return AppColors.textTertiary(b);
      default: return AppColors.accentText(b);
    }
  }

  IconData _entityIcon(String entityType) {
    switch (entityType) {
      case 'stock': return Icons.inventory_2_rounded;
      case 'bill': return Icons.receipt_long_rounded;
      case 'product': return Icons.shopping_bag_rounded;
      case 'category': return Icons.category_rounded;
      case 'auth': return Icons.person_rounded;
      case 'settings': return Icons.settings_rounded;
      default: return Icons.circle;
    }
  }

  Color _actionColor(String action, Brightness b) {
    if (action.contains('created') || action.contains('added')) return AppColors.successText(b);
    if (action.contains('deleted') || action.contains('voided')) return AppColors.error(b);
    if (action.contains('edited') || action.contains('adjusted')) return AppColors.infoText(b);
    if (action.contains('login')) return AppColors.accentText(b);
    if (action.contains('payment')) return AppColors.warningText(b);
    return AppColors.textTertiary(b);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('d MMMM yyyy').format(dt);
  }

  bool get _hasActiveFilters =>
      _filterEntityType != null ||
      _filterAction != null ||
      _filterStaff != null ||
      _filterFrom != null;

  // Unique staff names from current logs (for dropdown)
  List<String> _uniqueStaffNames(List<AuditLog> logs) {
    final names = <String>{};
    for (final log in logs) {
      if (log.staffName != null && log.staffName!.isNotEmpty) {
        names.add(log.staffName!);
      }
    }
    return names.toList()..sort();
  }

  // Unique action types from current logs
  List<String> _uniqueActions(List<AuditLog> logs) {
    final actions = <String>{};
    for (final log in logs) {
      actions.add(log.action);
    }
    return actions.toList()..sort();
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.accent,
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ──
            SliverAppBar(
              pinned: true,
              expandedHeight: 60,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Activity Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
              actions: [
                if (_hasActiveFilters)
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
                    tooltip: 'Clear Filters',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _clearAllFilters();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 22),
                  tooltip: 'Export CSV',
                  onPressed: _exportCsv,
                ),
              ],
              backgroundColor: t.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
            ),

            // ── Search ──
            SliverToBoxAdapter(child: _buildSearch(t)),

            // ── Entity Type Filters ──
            SliverToBoxAdapter(child: _buildEntityFilters(t)),

            // ── Action Sub-Filters ──
            BlocBuilder<AuditBloc, AuditState>(
              builder: (context, state) {
                if (state.logs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(child: _buildActionFilters(t, state.logs));
              },
            ),

            // ── Staff Filter + Date Range ──
            BlocBuilder<AuditBloc, AuditState>(
              builder: (context, state) {
                if (state.logs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(child: _buildAdvancedFilters(t, state.logs));
              },
            ),

            // ── Statistics Summary ──
            BlocBuilder<AuditBloc, AuditState>(
              builder: (context, state) {
                if (state.logs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(child: _buildStatsSummary(t, state.logs));
              },
            ),

            // ── Timeline ──
            BlocBuilder<AuditBloc, AuditState>(
              builder: (context, state) {
                if (state.status == AuditStatus.loading && state.logs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.accent),
                          const SizedBox(height: 16),
                          Text('Loading activities...', style: TextStyle(color: t.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }

                if (state.status == AuditStatus.error && state.logs.isEmpty) {
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
                            onPressed: _loadLogs,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final logs = state.logs;

                if (logs.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(t),
                  );
                }

                // Group logs by date
                final grouped = <String, List<AuditLog>>{};
                for (final log in logs) {
                  final key = _dateKey(log.createdAt);
                  grouped.putIfAbsent(key, () => []).add(log);
                }
                final dateKeys = grouped.keys.toList();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Load more trigger
                        if (index == dateKeys.length) {
                          if (state.hasMore) {
                            context.read<AuditBloc>().add(const LoadMoreAuditLogs());
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final dateKey = dateKeys[index];
                        final dayLogs = grouped[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 10),
                              child: Row(children: [
                                Icon(Icons.calendar_today_rounded, size: 14, color: t.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  dateKey,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: t.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${dayLogs.length} events',
                                  style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                                ),
                              ]),
                            ),
                            // Timeline items
                            ...dayLogs.asMap().entries.map((entry) {
                              final i = entry.key;
                              final log = entry.value;
                              final isLast = i == dayLogs.length - 1;
                              return _buildTimelineItem(t, log, isLast);
                            }),
                          ],
                        );
                      },
                      childCount: dateKeys.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // SEARCH — with debounce
  // ══════════════════════════════════════════════════
  Widget _buildSearch(ThemeData t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14),
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search activities...',
            hintStyle: TextStyle(color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: t.colorScheme.onSurfaceVariant, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: t.colorScheme.onSurfaceVariant, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _debounceTimer?.cancel();
                      _loadLogs();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // ENTITY TYPE FILTERS
  // ══════════════════════════════════════════════════
  Widget _buildEntityFilters(ThemeData t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _entityChip('All', Icons.all_inclusive_rounded, null, t),
          const SizedBox(width: 6),
          _entityChip('Stock', Icons.inventory_2_rounded, 'stock', t),
          const SizedBox(width: 6),
          _entityChip('Bills', Icons.receipt_long_rounded, 'bill', t),
          const SizedBox(width: 6),
          _entityChip('Products', Icons.shopping_bag_rounded, 'product', t),
          const SizedBox(width: 6),
          _entityChip('Categories', Icons.category_rounded, 'category', t),
          const SizedBox(width: 6),
          _entityChip('Auth', Icons.person_rounded, 'auth', t),
        ]),
      ),
    );
  }

  Widget _entityChip(String label, IconData icon, String? entityType, ThemeData t) {
    final isSelected = _filterEntityType == entityType;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _filterEntityType = entityType);
        _loadLogs();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.onAccent : t.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.onAccent : t.colorScheme.onSurface,
            )),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // ACTION SUB-FILTERS
  // ══════════════════════════════════════════════════
  Widget _buildActionFilters(ThemeData t, List<AuditLog> logs) {
    final actions = _uniqueActions(logs);
    if (actions.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.tune_rounded, size: 13, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
          ]),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _actionChip('All Actions', null, t),
              const SizedBox(width: 6),
              ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _actionChip(_actionLabel(a), a, t),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(String label, String? action, ThemeData t) {
    final isSelected = _filterAction == action;
    final color = action != null ? _actionColor(action, t.brightness) : AppColors.accentText(t.brightness);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _filterAction = action);
        _loadLogs();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.14) : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w600,
            color: isSelected ? color : t.colorScheme.onSurface,
          )),
        ),
      ),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'stock.added': return 'Stock Added';
      case 'stock.removed': return 'Stock Removed';
      case 'stock.adjusted': return 'Stock Adjusted';
      case 'bill.created': return 'Bill Created';
      case 'bill.edited': return 'Bill Edited';
      case 'bill.voided': return 'Bill Voided';
      case 'bill.payment': return 'Payment';
      case 'product.created': return 'Product Added';
      case 'product.edited': return 'Product Edited';
      case 'product.deleted': return 'Product Deleted';
      case 'category.created': return 'Category Added';
      case 'category.edited': return 'Category Edited';
      case 'category.deleted': return 'Category Deleted';
      case 'auth.login': return 'Login';
      case 'settings.updated': return 'Settings';
      default: return action;
    }
  }

  // ══════════════════════════════════════════════════
  // ADVANCED FILTERS — Staff + Date Range
  // ══════════════════════════════════════════════════
  Widget _buildAdvancedFilters(ThemeData t, List<AuditLog> logs) {
    final staffNames = _uniqueStaffNames(logs);
    final hasDateFilter = _filterFrom != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          // Date Range Button
          Expanded(
            child: GestureDetector(
              onTap: _showDateRangePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasDateFilter
                      ? AppColors.accentSubtle
                      : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: hasDateFilter
                      ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.date_range_rounded, size: 16, color: hasDateFilter ? AppColors.accentText(t.brightness) : t.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hasDateFilter
                          ? '${DateFormat('d MMM').format(_filterFrom!)} - ${DateFormat('d MMM').format(_filterTo!)}'
                          : 'Date Range',
                      style: TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w600,
                        color: hasDateFilter ? AppColors.accentText(t.brightness) : t.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
          ),

          if (staffNames.isNotEmpty) ...[
            const SizedBox(width: 8),
            // Staff Filter Dropdown
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _filterStaff != null
                      ? AppColors.accentSubtle
                      : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: _filterStaff != null
                      ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStaff,
                    hint: Text('Staff', style: TextStyle(fontSize: 11.5, color: t.colorScheme.onSurfaceVariant)),
                    isExpanded: true,
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: t.colorScheme.onSurfaceVariant),
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Staff')),
                      ...staffNames.map((name) => DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _filterStaff = val);
                      _loadLogs();
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _filterFrom != null && _filterTo != null
          ? DateTimeRange(start: _filterFrom!, end: _filterTo!)
          : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.accent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _filterFrom = picked.start;
        _filterTo = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      _loadLogs();
    }
  }

  // ══════════════════════════════════════════════════
  // STATISTICS SUMMARY
  // ══════════════════════════════════════════════════
  Widget _buildStatsSummary(ThemeData t, List<AuditLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayLogs = logs.where((l) => l.createdAt.isAfter(today)).toList();
    final uniqueStaff = _uniqueStaffNames(logs);

    // Count by entity type
    final entityCounts = <String, int>{};
    for (final log in logs) {
      entityCounts[log.entityType] = (entityCounts[log.entityType] ?? 0) + 1;
    }
    final topEntity = entityCounts.isNotEmpty
        ? (entityCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.08),
              AppColors.accent.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            _statItem(t, '${logs.length}', 'Total', Icons.analytics_rounded),
            Container(width: 1, height: 28, color: t.colorScheme.outlineVariant.withValues(alpha: 0.2)),
            _statItem(t, '${todayLogs.length}', 'Today', Icons.today_rounded),
            Container(width: 1, height: 28, color: t.colorScheme.outlineVariant.withValues(alpha: 0.2)),
            _statItem(t, '${uniqueStaff.length}', 'Staff', Icons.people_rounded),
            if (topEntity != null) ...[
              Container(width: 1, height: 28, color: t.colorScheme.outlineVariant.withValues(alpha: 0.2)),
              _statItem(t, '${topEntity.value}', _capitalize(topEntity.key), _entityIcon(topEntity.key)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(ThemeData t, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.accentText(t.brightness).withValues(alpha: 0.7)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: t.colorScheme.onSurface)),
          Text(label, style: TextStyle(fontSize: 9.5, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  // ══════════════════════════════════════════════════
  // TIMELINE ITEM
  // ══════════════════════════════════════════════════
  Widget _buildTimelineItem(ThemeData t, AuditLog log, bool isLast) {
    final color = _entityColor(log.entityType, t.brightness);
    final icon = _entityIcon(log.entityType);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDetailSheet(t, log);
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            SizedBox(
              width: 40,
              child: Column(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            // Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.colorScheme.outlineVariant.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Action badge + time
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _actionColor(log.action, t.brightness).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.actionLabel,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _actionColor(log.action, t.brightness)),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded, size: 16, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(width: 2),
                      Text(_timeAgo(log.createdAt),
                          style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 8),

                    // Row 2: Entity name
                    if (log.entityName != null)
                      Text(
                        log.entityName!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Row 3: Description
                    Text(
                      log.description,
                      style: TextStyle(fontSize: 13, color: t.colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Row 4: Value diff (if present)
                    if (log.oldValue != null && log.newValue != null) ...[
                      const SizedBox(height: 6),
                      _buildValueDiff(t, log),
                    ],

                    // Row 5: Staff + exact time
                    const SizedBox(height: 6),
                    Row(children: [
                      if (log.staffName != null) ...[
                        Icon(Icons.person_outline_rounded, size: 12, color: t.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(log.staffName!,
                            style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      ],
                      const Spacer(),
                      Text(
                        DateFormat('h:mm a').format(log.createdAt),
                        style: TextStyle(fontSize: 10, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // VALUE DIFF
  // ══════════════════════════════════════════════════
  Widget _buildValueDiff(ThemeData t, AuditLog log) {
    final oldVal = log.oldValue!;
    final newVal = log.newValue!;
    final changes = <String>[];
    for (final key in newVal.keys) {
      if (oldVal[key] != newVal[key]) changes.add(key);
    }
    if (changes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: changes.take(3).map((key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              Text('$key: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface)),
              Flexible(
                child: Text('${oldVal[key]}', style: TextStyle(fontSize: 11, color: t.colorScheme.error.withValues(alpha: 0.8), decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 10, color: t.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text('${newVal[key]}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.successText(t.brightness)), overflow: TextOverflow.ellipsis),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // DETAIL BOTTOM SHEET — ENTITY-SPECIFIC
  // ══════════════════════════════════════════════════
  void _showDetailSheet(ThemeData t, AuditLog log) {
    final color = _entityColor(log.entityType, t.brightness);
    final actionColor = _actionColor(log.action, t.brightness);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: t.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ──
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(_entityIcon(log.entityType), size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (log.entityName != null)
                        Text(log.entityName!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: actionColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(log.actionLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: actionColor)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(log.entityType.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ]),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Timestamp ──
              _detailInfoRow(t, Icons.access_time_rounded, 'Timestamp', DateFormat('d MMMM yyyy, h:mm a').format(log.createdAt)),
              if (log.staffName != null)
                _detailInfoRow(t, Icons.person_rounded, 'Performed By', log.staffName!),
              if (log.entityId != null)
                _detailInfoRow(t, Icons.tag_rounded, 'Entity ID', log.entityId!.length > 12 ? '${log.entityId!.substring(0, 12)}...' : log.entityId!),

              const SizedBox(height: 16),
              Divider(color: t.colorScheme.outlineVariant.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 16),

              // ── ENTITY-SPECIFIC SECTIONS ──
              ..._buildEntityDetail(t, log),

              // ── Metadata (if present) ──
              if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _sectionHeader(t, 'Metadata', Icons.info_outline_rounded),
                const SizedBox(height: 8),
                _buildDetailMap(t, log.metadata!, isMetadata: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Info Row (icon + label + value) ──
  Widget _detailInfoRow(ThemeData t, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        Flexible(child: Text(value, style: TextStyle(fontSize: 12, color: t.colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ── Section Header ──
  Widget _sectionHeader(ThemeData t, String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 15, color: AppColors.accentText(t.brightness).withValues(alpha: 0.8)),
      const SizedBox(width: 6),
      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurface)),
    ]);
  }

  // ── Entity Dispatcher ──
  List<Widget> _buildEntityDetail(ThemeData t, AuditLog log) {
    switch (log.entityType) {
      case 'bill': return _buildBillDetail(t, log);
      case 'product': return _buildProductDetail(t, log);
      case 'category': return _buildCategoryDetail(t, log);
      case 'stock': return _buildStockDetail(t, log);
      case 'auth': return _buildAuthDetail(t, log);
      default: return _buildGenericDetail(t, log);
    }
  }

  // ══════════════════════════════════════════════════
  // BILL DETAIL — Customer + Items Table + Payment
  // ══════════════════════════════════════════════════
  List<Widget> _buildBillDetail(ThemeData t, AuditLog log) {
    final nv = log.newValue ?? {};
    final ov = log.oldValue;
    final widgets = <Widget>[];

    // ── Customer Info ──
    final customerName = nv['customer_name'] as String?;
    final customerPhone = nv['customer_phone'] as String?;
    if (customerName != null || customerPhone != null) {
      widgets.addAll([
        _sectionHeader(t, 'Customer Info', Icons.person_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
          ),
          child: Column(children: [
            if (customerName != null && customerName.isNotEmpty)
              _detailInfoRow(t, Icons.person_rounded, 'Name', customerName),
            if (customerPhone != null && customerPhone.isNotEmpty)
              _detailInfoRow(t, Icons.phone_rounded, 'Phone', customerPhone),
          ]),
        ),
        const SizedBox(height: 16),
      ]);
    }

    // ── Items Table ──
    final items = nv['items'];
    if (items is List && items.isNotEmpty) {
      widgets.addAll([
        _sectionHeader(t, 'Items (${items.length})', Icons.shopping_cart_rounded),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(children: [
                Expanded(flex: 3, child: Text('Product', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant))),
                Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant))),
              ]),
            ),
            // Item rows
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value as Map<String, dynamic>;
              final isLast = i == items.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: isLast ? null : Border(bottom: BorderSide(color: t.colorScheme.outlineVariant.withValues(alpha: 0.1))),
                ),
                child: Row(children: [
                  Expanded(flex: 3, child: Text('${item['name'] ?? '-'}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: t.colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 1, child: Text('×${item['qty'] ?? item['quantity'] ?? '-'}', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: t.colorScheme.onSurface))),
                  Expanded(flex: 2, child: Text('₹${_formatNumber(item['unit_price'] ?? item['price'] ?? 0)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, color: t.colorScheme.onSurfaceVariant))),
                  Expanded(flex: 2, child: Text('₹${_formatNumber(item['total'] ?? 0)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface))),
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height: 16),
      ]);
    }

    // ── Payment & Total ──
    final payment = nv['payment'] as String? ?? nv['payment_method'] as String?;
    final total = nv['total'] ?? nv['grand_total'] ?? nv['total_amount'];
    final status = nv['status'] as String?;
    final discount = nv['discount'];

    if (payment != null || total != null || status != null) {
      widgets.addAll([
        _sectionHeader(t, 'Payment Details', Icons.payment_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            if (payment != null)
              _detailInfoRow(t, Icons.payment_rounded, 'Method', _capitalize(payment)),
            if (status != null)
              _detailInfoRow(t, _statusIcon(status), 'Status', _capitalize(status)),
            if (discount != null && discount != 0)
              _detailInfoRow(t, Icons.discount_rounded, 'Discount', '₹${_formatNumber(discount)}'),
            if (total != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Text('Grand Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface)),
                  const Spacer(),
                  Text('₹${_formatNumber(total)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accentText(t.brightness))),
                ]),
              ),
            ],
          ]),
        ),
      ]);
    }

    // ── Bill Edit Diff (if old values present) ──
    if (ov != null && ov.isNotEmpty && log.action.contains('edited')) {
      widgets.addAll([
        const SizedBox(height: 16),
        _sectionHeader(t, 'Changes', Icons.compare_arrows_rounded),
        const SizedBox(height: 8),
        _buildFullDiff(t, log),
      ]);
    }

    return widgets;
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return Icons.check_circle_rounded;
      case 'partial': return Icons.hourglass_bottom_rounded;
      case 'due': return Icons.warning_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String _formatNumber(dynamic n) {
    if (n is num) return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
    return '$n';
  }

  // ══════════════════════════════════════════════════
  // PRODUCT DETAIL — Old vs New Comparison
  // ══════════════════════════════════════════════════
  List<Widget> _buildProductDetail(ThemeData t, AuditLog log) {
    final nv = log.newValue ?? {};
    final ov = log.oldValue;
    final widgets = <Widget>[];

    if (log.action.contains('created')) {
      // Product Created — show all new values
      widgets.addAll([
        _sectionHeader(t, 'Product Details', Icons.shopping_bag_rounded),
        const SizedBox(height: 8),
        _buildDetailMap(t, _prettyProductMap(nv), isNew: true),
      ]);
    } else if (log.action.contains('edited') && ov != null && ov.isNotEmpty) {
      // Product Edited — side-by-side diff
      widgets.addAll([
        _sectionHeader(t, 'Changes', Icons.compare_arrows_rounded),
        const SizedBox(height: 8),
        _buildProductDiff(t, ov, nv),
      ]);
    } else if (log.action.contains('deleted')) {
      // Product Deleted — show what was deleted
      widgets.addAll([
        _sectionHeader(t, 'Deleted Product', Icons.delete_forever_rounded),
        const SizedBox(height: 8),
        if (nv.isNotEmpty) _buildDetailMap(t, _prettyProductMap(nv), isOld: true),
      ]);
    } else {
      widgets.addAll(_buildGenericDetail(t, log));
    }

    return widgets;
  }

  Map<String, String> _prettyProductMap(Map<String, dynamic> map) {
    final pretty = <String, String>{};
    final labels = {
      'name': 'Name', 'price': 'Price', 'stock': 'Stock',
      'barcode': 'Barcode', 'category_id': 'Category ID',
      'location': 'Location', 'unit': 'Unit',
      'min_stock_level': 'Min Stock', 'description': 'Description',
    };
    for (final entry in map.entries) {
      final label = labels[entry.key] ?? entry.key;
      if (entry.key == 'price' && entry.value is num) {
        pretty[label] = '₹${entry.value.toStringAsFixed(0)}';
      } else {
        pretty[label] = '${entry.value ?? '-'}';
      }
    }
    return pretty;
  }

  Widget _buildProductDiff(ThemeData t, Map<String, dynamic> ov, Map<String, dynamic> nv) {
    final fieldLabels = {
      'name': 'Name', 'price': 'Price', 'stock': 'Stock',
      'barcode': 'Barcode', 'category_id': 'Category',
      'location': 'Location', 'unit': 'Unit', 'min_stock_level': 'Min Stock',
    };
    final allKeys = <String>{...ov.keys, ...nv.keys}.toList()
      ..sort((a, b) => (fieldLabels[a] ?? a).compareTo(fieldLabels[b] ?? b));

    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Expanded(child: Text('Field', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant))),
            Expanded(child: Text('Old', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.colorScheme.error))),
            const SizedBox(width: 4),
            Expanded(child: Text('New', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.successText(t.brightness)))),
          ]),
        ),
        // Rows
        ...allKeys.map((key) {
          final oldV = ov[key];
          final newV = nv[key];
          final changed = '$oldV' != '$newV';
          final label = fieldLabels[key] ?? key;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: changed ? AppColors.accent.withValues(alpha: 0.04) : null,
              border: Border(bottom: BorderSide(color: t.colorScheme.outlineVariant.withValues(alpha: 0.08))),
            ),
            child: Row(children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant))),
              Expanded(child: Text(changed ? '${oldV ?? '-'}' : '-', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: changed ? t.colorScheme.error : t.colorScheme.onSurfaceVariant.withValues(alpha: 0.4), decoration: changed ? TextDecoration.lineThrough : null))),
              const SizedBox(width: 4),
              Expanded(child: Text('${newV ?? '-'}', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: changed ? FontWeight.w600 : FontWeight.normal, color: changed ? AppColors.successText(t.brightness) : t.colorScheme.onSurface))),
            ]),
          );
        }),
      ]),
    );
  }

  // ══════════════════════════════════════════════════
  // CATEGORY DETAIL
  // ══════════════════════════════════════════════════
  List<Widget> _buildCategoryDetail(ThemeData t, AuditLog log) {
    final nv = log.newValue ?? {};
    final ov = log.oldValue;
    final widgets = <Widget>[];

    if (log.action.contains('created')) {
      widgets.addAll([
        _sectionHeader(t, 'Category Details', Icons.category_rounded),
        const SizedBox(height: 8),
        _buildDetailMap(t, _prettyCategoryMap(nv), isNew: true),
      ]);
    } else if (log.action.contains('edited') && ov != null && ov.isNotEmpty) {
      widgets.addAll([
        _sectionHeader(t, 'Changes', Icons.compare_arrows_rounded),
        const SizedBox(height: 8),
        _buildSimpleDiff(t, ov, nv, {'name': 'Name', 'description': 'Description'}),
      ]);
    } else if (log.action.contains('deleted')) {
      widgets.addAll([
        _sectionHeader(t, 'Deleted Category', Icons.delete_forever_rounded),
        const SizedBox(height: 8),
        if (ov != null) _buildDetailMap(t, _prettyCategoryMap(ov), isOld: true),
        if (nv.isNotEmpty && ov == null) _buildDetailMap(t, _prettyCategoryMap(nv), isOld: true),
      ]);
    } else {
      widgets.addAll(_buildGenericDetail(t, log));
    }

    return widgets;
  }

  Map<String, String> _prettyCategoryMap(Map<String, dynamic> map) {
    return {
      'Name': '${map['name'] ?? '-'}',
      'Description': '${map['description'] ?? '-'}',
    };
  }

  Widget _buildSimpleDiff(ThemeData t, Map<String, dynamic> ov, Map<String, dynamic> nv, Map<String, String> labels) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: labels.entries.map((e) {
        final oldV = ov[e.key];
        final newV = nv[e.key];
        final changed = '$oldV' != '$newV';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 90, child: Text(e.value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant))),
            if (changed) ...[
              Flexible(child: Text('${oldV ?? '-'}', style: TextStyle(fontSize: 11.5, color: t.colorScheme.error, decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded, size: 12, color: t.colorScheme.onSurfaceVariant),
              ),
              Flexible(child: Text('${newV ?? '-'}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.successText(t.brightness)), overflow: TextOverflow.ellipsis)),
            ] else
              Flexible(child: Text('${newV ?? '-'}', style: TextStyle(fontSize: 11.5, color: t.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
          ]),
        );
      }).toList()),
    );
  }

  // ══════════════════════════════════════════════════
  // STOCK DETAIL — Visual Quantity Change
  // ══════════════════════════════════════════════════
  List<Widget> _buildStockDetail(ThemeData t, AuditLog log) {
    final nv = log.newValue ?? {};
    final ov = log.oldValue ?? {};
    final oldStock = ov['stock'] ?? 0;
    final newStock = nv['stock'] ?? 0;
    final diff = (newStock is num && oldStock is num) ? newStock - oldStock : 0;
    final isIncrease = diff > 0;

    return [
      _sectionHeader(t, 'Stock Change', Icons.inventory_2_rounded),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isIncrease ? AppColors.success.withValues(alpha: 0.06) : AppColors.error(t.brightness).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isIncrease ? AppColors.success.withValues(alpha: 0.15) : AppColors.error(t.brightness).withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          // Old stock
          Expanded(
            child: Column(children: [
              Text('Before', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text('$oldStock', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: t.colorScheme.onSurface.withValues(alpha: 0.6))),
              Text('units', style: TextStyle(fontSize: 10, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
            ]),
          ),
          // Arrow
          Column(children: [
            Icon(isIncrease ? Icons.arrow_forward_rounded : Icons.arrow_forward_rounded, size: 24, color: isIncrease ? AppColors.successText(t.brightness) : t.colorScheme.error),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isIncrease ? AppColors.success.withValues(alpha: 0.12) : AppColors.error(t.brightness).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${isIncrease ? '+' : ''}$diff', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isIncrease ? AppColors.successText(t.brightness) : t.colorScheme.error)),
            ),
          ]),
          // New stock
          Expanded(
            child: Column(children: [
              Text('After', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text('$newStock', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: isIncrease ? AppColors.successText(t.brightness) : t.colorScheme.error)),
              Text('units', style: TextStyle(fontSize: 10, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
            ]),
          ),
        ]),
      ),
    ];
  }

  // ══════════════════════════════════════════════════
  // AUTH DETAIL
  // ══════════════════════════════════════════════════
  List<Widget> _buildAuthDetail(ThemeData t, AuditLog log) {
    return [
      _sectionHeader(t, 'Login Details', Icons.login_rounded),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
        ),
        child: Column(children: [
          if (log.staffName != null)
            _detailInfoRow(t, Icons.person_rounded, 'Staff', log.staffName!),
          _detailInfoRow(t, Icons.access_time_rounded, 'Time', DateFormat('h:mm a').format(log.createdAt)),
          _detailInfoRow(t, Icons.description_rounded, 'Action', log.description),
        ]),
      ),
    ];
  }

  // ══════════════════════════════════════════════════
  // GENERIC DETAIL — Fallback
  // ══════════════════════════════════════════════════
  List<Widget> _buildGenericDetail(ThemeData t, AuditLog log) {
    final widgets = <Widget>[];

    // Description
    widgets.addAll([
      _sectionHeader(t, 'Details', Icons.info_outline_rounded),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(log.description, style: TextStyle(fontSize: 13, color: t.colorScheme.onSurface)),
      ),
    ]);

    // Old values
    if (log.oldValue != null && log.oldValue!.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 12),
        _sectionHeader(t, 'Previous Values', Icons.history_rounded),
        const SizedBox(height: 8),
        _buildDetailMap(t, log.oldValue!, isOld: true),
      ]);
    }

    // New values
    if (log.newValue != null && log.newValue!.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 12),
        _sectionHeader(t, 'New Values', Icons.update_rounded),
        const SizedBox(height: 8),
        _buildDetailMap(t, log.newValue!, isNew: true),
      ]);
    }

    // Diff
    if (log.oldValue != null && log.newValue != null && log.oldValue!.isNotEmpty && log.newValue!.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 12),
        _sectionHeader(t, 'Changes', Icons.compare_arrows_rounded),
        const SizedBox(height: 8),
        _buildFullDiff(t, log),
      ]);
    }

    return widgets;
  }



  Widget _buildDetailMap(ThemeData t, Map<String, dynamic> map, {bool isOld = false, bool isNew = false, bool isMetadata = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isOld
            ? t.colorScheme.error.withValues(alpha: 0.04)
            : isNew
                ? AppColors.success.withValues(alpha: 0.04)
                : isMetadata
                    ? t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOld
              ? t.colorScheme.error.withValues(alpha: 0.12)
              : isNew
                  ? AppColors.success.withValues(alpha: 0.12)
                  : t.colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: map.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(e.key, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                  child: Text('${e.value ?? 'null'}', style: TextStyle(
                    fontSize: 11.5,
                    color: isOld ? t.colorScheme.error : isNew ? AppColors.successText(t.brightness) : t.colorScheme.onSurface,
                  )),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFullDiff(ThemeData t, AuditLog log) {
    final oldVal = log.oldValue!;
    final newVal = log.newValue!;
    final allKeys = <String>{...oldVal.keys, ...newVal.keys}.toList()..sort();
    if (allKeys.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: allKeys.map((key) {
          final oldV = oldVal[key];
          final newV = newVal[key];
          final changed = oldV != newV;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.colorScheme.onSurfaceVariant)),
                ),
                if (changed) ...[
                  Flexible(
                    child: Text('$oldV', style: TextStyle(fontSize: 11, color: t.colorScheme.error, decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward_rounded, size: 11, color: t.colorScheme.onSurfaceVariant),
                  ),
                  Flexible(
                    child: Text('$newV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.successText(t.brightness)), overflow: TextOverflow.ellipsis),
                  ),
                ] else
                  Flexible(
                    child: Text('$newV', style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // EMPTY STATE
  // ══════════════════════════════════════════════════
  Widget _buildEmptyState(ThemeData t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: t.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: 56, color: t.colorScheme.primary.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Activity Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: t.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Audit trail will appear here\nas actions are performed',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: t.colorScheme.onSurfaceVariant),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // EXPORT — respects current filters
  // ══════════════════════════════════════════════════
  Future<void> _exportCsv() async {
    final logs = context.read<AuditBloc>().state.logs;
    if (logs.isEmpty) {
      if (mounted) {
        AppFeedback.info(context, 'No logs to export');
      }
      return;
    }

    final rows = <List<dynamic>>[
      ['Date', 'Time', 'Action', 'Entity', 'Name', 'Description', 'Staff', 'Old Value', 'New Value']
    ];
    for (final log in logs) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(log.createdAt),
        DateFormat('HH:mm').format(log.createdAt),
        log.actionLabel,
        log.entityType,
        log.entityName ?? '',
        log.description,
        log.staffName ?? '',
        log.oldValue?.toString() ?? '',
        log.newValue?.toString() ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/audit_logs.csv');
    await file.writeAsString(csv);

    if (mounted) {
      final filterDesc = _hasActiveFilters ? ' (filtered)' : '';
      await Share.shareXFiles([XFile(file.path)], text: 'Audit Logs$filterDesc — ${logs.length} entries');
    }
  }
}
