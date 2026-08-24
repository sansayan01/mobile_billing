import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.error.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Total Damage Loss',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${state.totalLoss.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.totalCount} damaged product${state.totalCount == 1 ? '' : 's'}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No damaged products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All products are in good condition!',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.damagedProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final damaged = state.damagedProducts[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
            ),
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
                          color: theme.colorScheme.onSurface,
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
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(
                            context,
                            '${damaged.quantityDamaged} units',
                            theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            context,
                            '₹${damaged.productPrice.toStringAsFixed(0)}/unit',
                            theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      if (damaged.damageType != null &&
                          damaged.damageType!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reason: ${DamagedProduct.damageTypeLabel(damaged.damageType)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
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
                            color: theme.colorScheme.onSurfaceVariant,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yy').format(damaged.damageDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    IconButton(
                      icon: const Icon(Icons.restore_from_trash_outlined, size: 18),
                      color: theme.colorScheme.primary,
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
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          damaged.productImage!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(context, damaged),
        ),
      );
    }
    return _buildImagePlaceholder(context, damaged);
  }

  Widget _buildImagePlaceholder(BuildContext context, dynamic damaged) {
    final theme = Theme.of(context);
    final initial = damaged.productName.isNotEmpty
        ? damaged.productName[0].toUpperCase()
        : '?';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
    final theme = Theme.of(context);
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
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
