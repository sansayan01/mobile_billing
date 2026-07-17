import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StockMovementPage extends StatefulWidget {
  const StockMovementPage({super.key});

  @override
  State<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends State<StockMovementPage> {
  String _selectedChangeType = 'All';
  late DateTime _fromDate;
  late DateTime _toDate;
  bool _filterApplied = false;

  final List<String> _changeTypes = ['All', 'add', 'sale', 'remove', 'return'];

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 30));
    _loadMovements();
  }

  void _loadMovements() {
    context.read<ReportBloc>().add(
          LoadStockMovements(
            changeType: _selectedChangeType == 'All' ? null : _selectedChangeType,
            from: _fromDate,
            to: _toDate,
          ),
        );
    setState(() {
      _filterApplied = true;
    });
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: _toDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Color _chipColor(String changeType) {
    switch (changeType.toLowerCase()) {
      case 'add':
      case 'return':
        return Colors.green;
      case 'sale':
      case 'remove':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movements'),
      ),
      body: Column(
        children: [
          // Filters Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change Type Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedChangeType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _changeTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == 'All' ? 'All Types' : type,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedChangeType = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Date Range + Apply Button
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickFromDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dateFormat.format(_fromDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'to',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickToDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dateFormat.format(_toDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loadMovements,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Movements List
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state.status == ReportStatus.loading &&
                    !_filterApplied) {
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
                            onPressed: _loadMovements,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final movements = state.stockMovements;

                if (movements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stock movements found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.status == ReportStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadMovements();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final movement = movements[index];
                      return _buildMovementCard(movement);
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

  Widget _buildMovementCard(StockMovement movement) {
    final isPositive = movement.changeType == 'add' ||
        movement.changeType == 'return';
    final quantitySign = isPositive ? '+' : '-';

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
            // Product Name + Change Type Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    movement.productName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _chipColor(movement.changeType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    movement.changeType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quantity + Staff Name
            Row(
              children: [
                Text(
                  '$quantitySign${movement.quantity}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  movement.staffName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Date + Notes
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(movement.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (movement.notes != null && movement.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                movement.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
