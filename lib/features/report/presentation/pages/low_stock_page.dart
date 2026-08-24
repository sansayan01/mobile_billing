import 'dart:io';

import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> with SingleTickerProviderStateMixin {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _threshold = 5;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  late AnimationController _animController;
  late Animation<double> _counterAnim;
  final int _animatedCount = 0;

  @override
  void initState() {
    super.initState();
    _thresholdController.text = '5';
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _counterAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<ReportBloc>().add(LoadLowStockProducts(_threshold));
    _animController.forward(from: 0);
  }

  void _applyThreshold() {
    final value = int.tryParse(_thresholdController.text.trim());
    if (value != null && value >= 0) {
      setState(() => _threshold = value);
      _loadProducts();
    }
  }

  String _formatCurrency(dynamic value) {
    final num val = (value is double) ? value : (value is int) ? value.toDouble() : 0.0;
    return NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(val);
  }

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('phone') || n.contains('mobile')) return Icons.phone_rounded;
    if (n.contains('charger') || n.contains('cable')) return Icons.cable_rounded;
    if (n.contains('headphone') || n.contains('earphone') || n.contains('earbuds')) return Icons.headphones_rounded;
    if (n.contains('cover') || n.contains('case')) return Icons.phone_android_rounded;
    if (n.contains('screen') || n.contains('tempered')) return Icons.screen_lock_portrait_rounded;
    if (n.contains('battery')) return Icons.battery_charging_full_rounded;
    if (n.contains('speaker')) return Icons.speaker_rounded;
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
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
            title: const Text('Low Stock', style: TextStyle(fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 22),
                tooltip: 'Reorder via WhatsApp',
                onPressed: _shareReorderWhatsApp,
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

          // ── Summary Card ──
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _counterAnim,
              builder: (_, __) => _buildSummaryHeader(t),
            ),
          ),

          // ── Threshold + Search ──
          SliverToBoxAdapter(child: _buildFilterSection(t)),

          // ── Category Chips ──
          SliverToBoxAdapter(child: _buildCategoryChips(t)),

          // ── Product List ──
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state.status == ReportStatus.loading) {
                return const SliverFillRemaining(
                  child: SingleChildScrollView(child: AppSkeletonList(itemCount: 6)),
                );
              }

              final products = state.lowStockProducts;
              final filtered = products.where((p) {
                final name = (p['name'] as String? ?? '').toLowerCase();
                final cat = (p['category'] as String? ?? 'General');
                final matchSearch = _searchQuery.isEmpty || name.contains(_searchQuery);
                final matchCat = _selectedCategory == 'All' || cat == _selectedCategory;
                return matchSearch && matchCat;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(t),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildProductCard(t, filtered[index], index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ────────────── Summary Header ──────────────
  Widget _buildSummaryHeader(ThemeData t) {
    final count = _animatedCount;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.colorScheme.error,
            t.colorScheme.error.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: t.colorScheme.error.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count Products',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Below stock threshold',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Out of stock count
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_outOfStockCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Out of Stock',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int get _outOfStockCount {
    final products = context.read<ReportBloc>().state.lowStockProducts;
    return products.where((p) => (p['stock'] as int? ?? 0) == 0).length;
  }

  // ────────────── Filter Section ──────────────
  Widget _buildFilterSection(ThemeData t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          // Threshold input
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _thresholdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Threshold',
                  labelStyle: TextStyle(color: t.colorScheme.onSurfaceVariant, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  isDense: true,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check_circle_rounded, color: t.colorScheme.primary, size: 20),
                    onPressed: _applyThreshold,
                  ),
                ),
                onSubmitted: (_) => _applyThreshold(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Search
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: t.colorScheme.onSurfaceVariant, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: t.colorScheme.onSurfaceVariant, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── Category Chips ──────────────
  Widget _buildCategoryChips(ThemeData t) {
    final products = context.read<ReportBloc>().state.lowStockProducts;
    final categories = <String>{};
    for (final p in products) {
      categories.add(p['category'] as String? ?? 'General');
    }
    final cats = ['All', ...categories.toList()..sort()];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = cats[index];
          final selected = _selectedCategory == cat;
          final count = cat == 'All'
              ? products.length
              : products.where((p) => (p['category'] as String? ?? 'General') == cat).length;

          return AnimatedScale(
            scale: selected ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              label: Text('$cat ($count)', style: TextStyle(fontSize: 12, color: selected ? Colors.white : t.colorScheme.onSurface)),
              selected: selected,
              selectedColor: t.colorScheme.error,
              backgroundColor: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              checkmarkColor: Colors.white,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  // ────────────── Product Card ──────────────
  Widget _buildProductCard(ThemeData t, Map<String, dynamic> product, int index) {
    final name = product['name'] as String? ?? 'Unknown';
    final stock = product['stock'] as int? ?? 0;
    final price = product['price'] as dynamic ?? 0;
    final category = product['category'] as String? ?? 'General';
    final minStock = product['minStockLevel'] as int? ?? _threshold;
    final unit = product['unit'] as String? ?? 'Pcs';

    final isOut = stock == 0;
    final isCritical = stock > 0 && stock <= 3;
    final statusColor = isOut
        ? t.colorScheme.error
        : isCritical
            ? const Color(0xFFFF6B35)
            : t.colorScheme.tertiary;

    final statusText = isOut ? 'OUT OF STOCK' : isCritical ? 'CRITICAL' : 'LOW STOCK';
    final statusIcon = isOut ? Icons.remove_shopping_cart_rounded : isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded;

    // Stock progress bar
    final progress = minStock > 0 ? (stock / minStock).clamp(0.0, 1.0) : 0.0;

    return AnimatedBuilder(
      animation: _counterAnim,
      builder: (context, child) {
        final delay = (index * 0.08).clamp(0.0, 0.5);
        final animValue = (_counterAnim.value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Category icon + Name + Stock badge
            Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_categoryIcon(category), color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Name + category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$category · $unit',
                        style: TextStyle(fontSize: 12, color: t.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Stock number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Stock progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: t.colorScheme.surfaceContainerHighest,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Min: $minStock',
                  style: TextStyle(fontSize: 11, color: t.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 3: Price + Status badge
            Row(
              children: [
                Text(
                  _formatCurrency(price),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: t.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
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
              Icons.check_circle_rounded,
              size: 56,
              color: t.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All Products Well-Stocked!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: t.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products below threshold of $_threshold',
            style: TextStyle(
              fontSize: 14,
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── Reorder via WhatsApp ──────────────
  void _shareReorderWhatsApp() {
    final products = context.read<ReportBloc>().state.lowStockProducts;
    if (products.isEmpty) {
      AppFeedback.info(context, 'No low stock products to reorder');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('📦 *Low Stock Reorder List*');
    buffer.writeln('Threshold: $_threshold units');
    buffer.writeln('Total: ${products.length} products');
    buffer.writeln('---');
    for (final p in products) {
      final name = p['name'] as String? ?? 'Unknown';
      final stock = p['stock'] as int? ?? 0;
      final minStock = p['minStockLevel'] as int? ?? _threshold;
      final needed = minStock - stock;
      buffer.writeln('• $name — Stock: $stock (need +$needed)');
    }
    buffer.writeln('---');
    buffer.writeln('Sent from Billing App 📱');

    Share.share(buffer.toString(), subject: 'Reorder List');
  }

  // ────────────── Export ──────────────
  Future<void> _exportCsv() async {
    final products = context.read<ReportBloc>().state.lowStockProducts;
    if (products.isEmpty) {
      if (mounted) {
        AppFeedback.info(context, 'No products to export');
      }
      return;
    }

    final rows = products.map((p) => [
      p['name'] as String? ?? '',
      '${p['stock'] ?? 0}',
      '${p['price'] ?? 0}',
      p['category'] as String? ?? 'General',
      p['unit'] as String? ?? 'Pcs',
    ]).toList();

    final csv = 'Name,Stock,Price,Category,Unit\n${rows.map((r) => r.join(',')).join('\n')}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/low_stock_products.csv');
    await file.writeAsString(csv);

    if (mounted) {
      await Share.shareXFiles([XFile(file.path)], text: 'Low Stock Products Report');
    }
  }
}
