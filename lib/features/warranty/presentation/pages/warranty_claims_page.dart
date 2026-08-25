import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../bloc/warranty_bloc.dart';
import '../../domain/entities/warranty_claim.dart';
import '../../../report/domain/entities/report_entities.dart';
import '../../../report/domain/repositories/report_repository.dart';
import '../../../../core/service_locator.dart';
import 'package:go_router/go_router.dart';

class WarrantyClaimsPage extends StatefulWidget {
  const WarrantyClaimsPage({super.key});

  @override
  State<WarrantyClaimsPage> createState() => _WarrantyClaimsPageState();
}

class _WarrantyClaimsPageState extends State<WarrantyClaimsPage> {
  String _selectedStatus = '';
  String _selectedType = '';
  bool _isFetchingBill = false;

  @override
  void initState() {
    super.initState();
    context.read<WarrantyBloc>().add(const LoadWarrantyClaims());
  }

  /// Scan the receipt QR (encodes billId), fetch that bill from DB, then
  /// open a pre-filled claim form. Error-proof: handles cancel / not-found /
  /// network failure without crashing, and never touches the navigator while
  /// a route transition is in flight (uses an in-page overlay, not a dialog).
  Future<void> _scanBillAndCreateClaim() async {
    final scanned = await context.push<String>('/scan/scanner');
    if (!mounted) return;
    if (scanned == null || scanned.isEmpty) return; // user cancelled

    // In-page loading overlay (no Navigator.pop -> no route-lock crash).
    setState(() => _isFetchingBill = true);

    final repo = sl<ReportRepository>();
    final result = await repo.getBillDetail(scanned.trim());

    if (!mounted) return;
    setState(() => _isFetchingBill = false);

    result.fold(
      (failure) => _showErrorSnack('Could not load bill: ${failure.message}'),
      (bill) {
        if (bill.items.isEmpty) {
          _showErrorSnack('This bill has no items to claim against.');
          return;
        }
        _showPrefilledClaimDialog(bill);
      },
    );
  }

  void _showErrorSnack(String message) {
    AppFeedback.error(context, message);
  }

  /// Dart-side warranty expiry check. Returns the date the warranty ends,
  /// or null if the item has no warranty info.
  DateTime? _warrantyEndDate(BillItem item, DateTime billDate) {
    if (item.warrantyDuration == null || item.warrantyUnit == null) return null;
    switch (item.warrantyUnit) {
      case 'days':
        return billDate.add(Duration(days: item.warrantyDuration!));
      case 'months':
        return DateTime(billDate.year, billDate.month + item.warrantyDuration!, billDate.day);
      case 'years':
        return DateTime(billDate.year + item.warrantyDuration!, billDate.month, billDate.day);
      default:
        return null;
    }
  }

  Color _statusColor(String status, Brightness b) {
    switch (status) {
      case 'pending':
        return AppColors.warningText(b);
      case 'approved':
        return AppColors.successText(b);
      case 'rejected':
        return AppColors.error(b);
      case 'resolved':
        return AppColors.infoText(b);
      default:
        return AppColors.textTertiary(b);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'resolved':
        return Icons.done_all_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go('/'),
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Warranty Claims',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.accentText(theme.brightness)),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Claim',
            onPressed: () => _scanBillAndCreateClaim(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Type filter chips (Warranty/Guarantee)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeFilterChip('All', '', theme),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip('Warranty', 'warranty', theme),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip('Guarantee', 'guarantee', theme),
                ],
              ),
            ),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', '', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved', 'approved', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected', theme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved', theme),
                ],
              ),
            ),
          ),

          // Claims list
          Expanded(
            child: BlocBuilder<WarrantyBloc, WarrantyState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const SingleChildScrollView(
                    child: AppSkeletonList(itemCount: 5),
                  );
                }

                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 12),
                        Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<WarrantyBloc>().add(
                              LoadWarrantyClaims(status: _selectedStatus.isEmpty ? null : _selectedStatus)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = state.claims.where((c) {
                  final statusMatch = _selectedStatus.isEmpty || c.claimStatus == _selectedStatus;
                  final typeMatch = _selectedType.isEmpty || c.claimType == _selectedType;
                  return statusMatch && typeMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No warranty claims found',
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Claims will appear here when customers bring products',
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final claim = filtered[index];
                    return _buildClaimCard(claim, theme);
                  },
                );
              },
            ),
          ),
          if (_isFetchingBill)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Fetching bill…'),
                    ],
                  ),
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

  Widget _buildTypeFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedType = value);
      },
      selectedColor: AppColors.accentSubtle,
      checkmarkColor: AppColors.accentText(theme.brightness),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentText(theme.brightness) : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = value);
        context.read<WarrantyBloc>().add(
            LoadWarrantyClaims(status: value.isEmpty ? null : value));
      },
      selectedColor: AppColors.accentSubtle,
      checkmarkColor: AppColors.accentText(theme.brightness),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentText(theme.brightness) : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildClaimCard(WarrantyClaim claim, ThemeData theme) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final statusColor = _statusColor(claim.claimStatus, theme.brightness);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showClaimDetail(context, claim),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(claim.claimStatus), size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          claim.claimStatus.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Type badge (Warranty/Guarantee)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: claim.claimType == 'guarantee'
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10)
                          : AppColors.info.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: claim.claimType == 'guarantee'
                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2)
                            : AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          claim.claimType == 'guarantee'
                              ? Icons.verified_rounded
                              : Icons.shield_rounded,
                          size: 12,
                          color: claim.claimType == 'guarantee'
                              ? theme.colorScheme.onSurfaceVariant
                              : AppColors.infoText(theme.brightness),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          claim.warrantyLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: claim.claimType == 'guarantee'
                                ? theme.colorScheme.onSurfaceVariant
                                : AppColors.infoText(theme.brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(claim.createdAt),
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                claim.productName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (claim.customerName != null && claim.customerName!.isNotEmpty)
                Text(
                  'Customer: ${claim.customerName}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                ),
              const SizedBox(height: 4),
              Text(
                'Reason: ${claim.claimReason}',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimDetail(BuildContext context, WarrantyClaim claim) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          // Safe layout: handle + scrollable details + pinned buttons.
          // Avoids Spacer() inside a fixed-height Column (caused parentDataDirty crash).
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_statusIcon(claim.claimStatus),
                              color: _statusColor(claim.claimStatus, theme.brightness), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            claim.claimStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(claim.claimStatus, theme.brightness),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _detailRow('Product', claim.productName, theme),
                      _detailRow('Claim Type', claim.warrantyLabel, theme),
                      _detailRow('Bill ID', claim.billId, theme),
                      if (claim.customerName != null)
                        _detailRow('Customer', claim.customerName!, theme),
                      if (claim.customerPhone != null)
                        _detailRow('Phone', claim.customerPhone!, theme),
                      _detailRow('Reason', claim.claimReason, theme),
                      _detailRow('Date', dateFormat.format(claim.createdAt), theme),
                      if (claim.staffName != null)
                        _detailRow('Filed by', claim.staffName!, theme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Action buttons pinned to bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    if (claim.claimStatus == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<WarrantyBloc>().add(
                                    UpdateWarrantyClaimStatus(
                                        claimId: claim.id, status: 'approved'));
                                Navigator.pop(ctx);
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successText(theme.brightness),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<WarrantyBloc>().add(
                                    UpdateWarrantyClaimStatus(
                                        claimId: claim.id, status: 'rejected'));
                                Navigator.pop(ctx);
                              },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (claim.claimStatus == 'approved')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<WarrantyBloc>().add(
                                UpdateWarrantyClaimStatus(
                                    claimId: claim.id, status: 'resolved'));
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark Resolved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.infoText(theme.brightness),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Pre-filled claim dialog opened after scanning a bill QR.
  /// Customer + product list come straight from the fetched bill, so the
  /// shopkeeper only picks the product and writes a reason.
  void _showPrefilledClaimDialog(BillSummary bill) {
    final b = Theme.of(context).brightness;
    final List<BillItem> items = bill.items;
    BillItem selectedItem;
    // Pick the first item that actually has a warranty; fall back to the first item.
    final warranted = items.where((i) => i.hasWarranty).toList();
    if (warranted.isNotEmpty) {
      selectedItem = warranted.first;
    } else {
      selectedItem = items.first;
    }
    String claimType = selectedItem.warrantyType ?? 'warranty';
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final endDate = _warrantyEndDate(selectedItem, bill.createdAt);
            final isExpired = endDate != null && endDate.isBefore(DateTime.now());

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Claim from Bill')),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill reference (read-only)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bill: ${bill.id}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          if (bill.customerName != null && bill.customerName!.isNotEmpty)
                            Text('Customer: ${bill.customerName}', style: const TextStyle(fontSize: 13)),
                          Text('Date: ${DateFormat('dd MMM yyyy').format(bill.createdAt)}',
                              style: TextStyle(fontSize: 12, color: AppColors.textTertiary(b))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product picker — only items from this bill
                    const Text('Product', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<BillItem>(
                      initialValue: selectedItem,
                      isExpanded: true,
                      items: bill.items.map((item) {
                        final warrantyTxt = item.hasWarranty ? '  (${item.warrantyLabel})' : '';
                        return DropdownMenuItem(
                          value: item,
                          child: Text('${item.productName} x${item.quantity}$warrantyTxt',
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setDialogState(() {
                          selectedItem = val;
                          claimType = val.warrantyType ?? 'warranty';
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Expiry banner (Dart-side, non-blocking)
                    if (endDate != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? AppColors.error(b).withValues(alpha: 0.12)
                              : AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isExpired
                                ? AppColors.error(b).withValues(alpha: 0.3)
                                : AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpired ? Icons.warning_amber_rounded : Icons.verified_outlined,
                              color: isExpired ? AppColors.error(b) : AppColors.successText(b),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isExpired
                                    ? 'Warranty expired on ${DateFormat('dd MMM yyyy').format(endDate)}'
                                    : 'Under warranty until ${DateFormat('dd MMM yyyy').format(endDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isExpired ? AppColors.error(b) : AppColors.successText(b),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Claim Reason',
                        hintText: 'Describe the issue',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (reasonController.text.trim().isEmpty) {
                      _showErrorSnack('Please enter a claim reason');
                      return;
                    }
                    context.read<WarrantyBloc>().add(CreateWarrantyClaim(
                          billId: bill.id,
                          productId: selectedItem.productId,
                          productName: selectedItem.productName,
                          customerName: bill.customerName,
                          customerPhone: bill.customerPhone,
                          claimReason: reasonController.text.trim(),
                          claimType: claimType,
                          warrantyDuration: selectedItem.warrantyDuration,
                          warrantyUnit: selectedItem.warrantyUnit,
                        ));
                    Navigator.pop(ctx);
                    AppFeedback.success(
                      context,
                      'Warranty claim submitted successfully',
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
