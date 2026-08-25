import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/core/utils/csv_export_import.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/app_skeleton.dart';
import 'package:billing_app/features/damaged_products/domain/entities/damaged_product.dart';
import 'package:billing_app/features/damaged_products/presentation/bloc/damaged_products_bloc.dart';

class DamagedProductsPage extends StatefulWidget {
  const DamagedProductsPage({super.key});

  @override
  State<DamagedProductsPage> createState() => _DamagedProductsPageState();
}

class _DamagedProductsPageState extends State<DamagedProductsPage> {
  final _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    context.read<DamagedProductsBloc>().add(const LoadDamagedProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go('/'),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Damaged Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
        actions: [
          BlocBuilder<DamagedProductsBloc, DamagedProductsState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: state.damagedProducts.isEmpty
                    ? null
                    : () async {
                        try {
                          await CsvExportImport.exportDamagedProducts(
                            state.damagedProducts,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            AppFeedback.error(context, 'Export failed: $e');
                          }
                        }
                      },
                tooltip: 'Export CSV',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _showDateFilter,
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: BlocConsumer<DamagedProductsBloc, DamagedProductsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppFeedback.success(context, state.successMessage!);
          }
          if (state.error != null) {
            AppFeedback.error(context, state.error!);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DamagedProductsBloc>().add(const LoadDamagedProducts());
              // Wait a tick so the in-flight load is reflected.
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: Column(
            children: [
              // Summary card
              _buildSummaryCard(context, state),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by product name or barcode...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<DamagedProductsBloc>()
                                  .add(const SearchDamagedProducts(null));
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    context
                        .read<DamagedProductsBloc>()
                        .add(SearchDamagedProducts(value.isEmpty ? null : value));
                  },
                ),
              ),

              // Date filter chips
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (_startDate != null)
                        Chip(
                          label: Text(
                              'From: ${DateFormat('dd MMM').format(_startDate!)}'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() => _startDate = null);
                            context
                                .read<DamagedProductsBloc>()
                                .add(const FilterDamagedProductsByDate());
                          },
                        ),
                      if (_startDate != null && _endDate != null)
                        const SizedBox(width: 8),
                      if (_endDate != null)
                        Chip(
                          label: Text(
                              'To: ${DateFormat('dd MMM').format(_endDate!)}'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() => _endDate = null);
                            context
                                .read<DamagedProductsBloc>()
                                .add(const FilterDamagedProductsByDate());
                          },
                        ),
                    ],
                  ),
                ),

              // Damaged products list
              Expanded(
                child: state.isLoading
                    ? const SingleChildScrollView(
                        child: AppSkeletonList(itemCount: 6),
                      )
                    : state.damagedProducts.isEmpty
                        ? _buildEmptyState(context)
                        : _buildDamagedProductsList(context, state),
              ),
            ],
          ));
        },
      ),
    ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, DamagedProductsState state) {
    final theme = Theme.of(context);
    final b = theme.brightness;

    // v3: solid error surface, white content, no gradient/glow.
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error(b),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Total Damage Loss',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${state.totalLoss.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.totalCount} damaged product${state.totalCount == 1 ? '' : 's'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 36,
              color: AppColors.accentText(b),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No damaged products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(b),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All products are in good condition!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary(b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamagedProductsList(
      BuildContext context, DamagedProductsState state) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: state.damagedProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final damaged = state.damagedProducts[index];
        return Card(
          elevation: 0,
          color: AppColors.surface(theme.brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border(theme.brightness)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image or placeholder
                _buildProductImage(context, damaged),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        damaged.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary(theme.brightness),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (damaged.productBarcode != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          damaged.productBarcode!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary(theme.brightness),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(
                            context,
                            '${damaged.quantityDamaged} units',
                            AppColors.error(theme.brightness),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            context,
                            '₹${damaged.productPrice.toStringAsFixed(0)}/unit',
                            AppColors.textSecondary(theme.brightness),
                          ),
                        ],
                      ),
                      if (damaged.damageType != null &&
                          damaged.damageType!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Reason: ${DamagedProduct.damageTypeLabel(damaged.damageType)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary(theme.brightness),
                          ),
                        ),
                      ],
                      if (damaged.notes != null &&
                          damaged.notes!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Note: ${damaged.notes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary(theme.brightness),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Loss amount + date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${damaged.estimatedLoss.toStringAsFixed(2)}',
                      style: AppMoneyText.sized(
                        15,
                        FontWeight.w700,
                        AppColors.error(theme.brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yy').format(damaged.damageDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary(theme.brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.restore_from_trash_outlined, size: 18),
                      color: AppColors.textTertiary(theme.brightness),
                      tooltip: 'Reverse damage',
                      onPressed: () => _confirmUndo(context, damaged),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(BuildContext context, dynamic damaged) {
    if (damaged.productImage != null && damaged.productImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          damaged.productImage!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(context, damaged),
        ),
      );
    }
    return _buildImagePlaceholder(context, damaged);
  }

  Widget _buildImagePlaceholder(BuildContext context, dynamic damaged) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final initial = damaged.productName.isNotEmpty
        ? damaged.productName[0].toUpperCase()
        : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.error(b).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.error(b),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _confirmUndo(BuildContext context, DamagedProduct damaged) async {
    final bloc = context.read<DamagedProductsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reverse damage?'),
        content: Text(
          'This will restore ${damaged.quantityDamaged} unit(s) of '
          '"${damaged.productName}" back to stock and remove this damage entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.restore_from_trash_outlined, size: 18),
            label: const Text('Reverse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      bloc.add(
        UndoDamagedProduct(
          adjustmentId: damaged.id,
          productId: damaged.productId,
          quantityRestored: damaged.quantityDamaged,
        ),
      );
    }
  }

  Future<void> _showDateFilter() async {
    final theme = Theme.of(context);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.error,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      context.read<DamagedProductsBloc>().add(
            FilterDamagedProductsByDate(
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }
  }
}
