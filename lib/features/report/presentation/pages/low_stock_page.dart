import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _threshold = 5;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _thresholdController.text = '5';
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    context.read<ReportBloc>().add(LoadLowStockProducts(_threshold));
  }

  void _applyThreshold() {
    final text = _thresholdController.text.trim();
    final value = int.tryParse(text);
    if (value != null && value >= 0) {
      setState(() {
        _threshold = value;
      });
      _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 3) return Colors.orange;
    if (stock <= _threshold) return Colors.amber.shade700;
    return Colors.grey;
  }

  String _formatCurrency(dynamic value) {
    final num val;
    if (value is double) {
      val = value;
    } else if (value is int) {
      val = value.toDouble();
    } else {
      val = 0.0;
    }
    final format = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return format.format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Products'),
      ),
      body: Column(
        children: [
          // Threshold and Search Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Threshold',
                      hintText: 'Enter threshold',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _applyThreshold(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyThreshold,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),

          // Product List
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state.status == ReportStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == ReportStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.error ?? 'Something went wrong',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = state.lowStockProducts;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 48,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'All products are well-stocked! ✓',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts = products.where((product) {
                  if (_searchQuery.isEmpty) return true;
                  final name = (product['name'] as String? ?? '').toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No products match your search',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadProducts();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final name = product['name'] as String? ?? 'Unknown';
                      final stock = product['stock'] as int? ?? 0;
                      final price = product['price'] as dynamic ?? 0;
                      final category =
                          product['category'] as String? ?? 'General';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$stock',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _stockColor(stock),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    _formatCurrency(price),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
