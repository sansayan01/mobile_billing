import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/core/theme/app_colors.dart';

class MarkDamagedDialog extends StatefulWidget {
  final String productName;
  final int currentStock;
  final Function(int quantity, String? damageType, String? notes) onConfirm;

  const MarkDamagedDialog({
    super.key,
    required this.productName,
    required this.currentStock,
    required this.onConfirm,
  });

  @override
  State<MarkDamagedDialog> createState() => _MarkDamagedDialogState();
}

class _MarkDamagedDialogState extends State<MarkDamagedDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  String? _selectedDamageType;

  static const _damageTypes = [
    {'value': 'broken', 'label': 'Broken', 'icon': Icons.camera_alt_outlined},
    {'value': 'defective', 'label': 'Defective', 'icon': Icons.warning_amber_rounded},
    {'value': 'expired', 'label': 'Expired', 'icon': Icons.event_busy_rounded},
    {'value': 'water_damage', 'label': 'Water Damage', 'icon': Icons.water_drop_outlined},
    {'value': 'scratched', 'label': 'Scratched', 'icon': Icons.brush_outlined},
    {'value': 'other', 'label': 'Other', 'icon': Icons.help_outline_rounded},
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error(b).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.broken_image_rounded,
              color: AppColors.error(b),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('Mark as Damaged')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product name
            Text(
              widget.productName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Available stock: ${widget.currentStock}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary(b),
              ),
            ),
            const SizedBox(height: 20),

            // Quantity
            Text(
              'Quantity Damaged',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(b),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuantityButton(
                  context,
                  Icons.remove,
                  () {
                    final current = int.tryParse(_quantityController.text) ?? 1;
                    if (current > 1) {
                      setState(() {
                        _quantityController.text = (current - 1).toString();
                      });
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                _buildQuantityButton(
                  context,
                  Icons.add,
                  () {
                    final current = int.tryParse(_quantityController.text) ?? 0;
                    if (current < widget.currentStock) {
                      setState(() {
                        _quantityController.text = (current + 1).toString();
                      });
                    }
                  },
                ),
              ],
            ),
            if (quantity > widget.currentStock)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Cannot exceed available stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error(b),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Damage type
            Text(
              'Damage Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(b),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _damageTypes.map((type) {
                final isSelected = _selectedDamageType == type['value'];
                final chipColor = AppColors.error(b);
                return ChoiceChip(
                  label: Text(type['label'] as String),
                  avatar: Icon(
                    type['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? chipColor
                        : AppColors.textTertiary(b),
                  ),
                  selected: isSelected,
                  selectedColor: chipColor.withValues(alpha: 0.12),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color:
                        isSelected ? chipColor : AppColors.border(b),
                  ),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? chipColor
                        : AppColors.textPrimary(b),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedDamageType =
                          selected ? type['value'] as String : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Notes
            Text(
              'Notes (optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(b),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe the damage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary(b)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: (quantity > 0 && quantity <= widget.currentStock)
              ? () {
                  widget.onConfirm(
                    quantity,
                    _selectedDamageType,
                    _notesController.text.isEmpty
                        ? null
                        : _notesController.text,
                  );
                  Navigator.pop(context);
                }
              : null,
          icon: const Icon(Icons.broken_image_rounded, size: 18),
          label: const Text('Mark Damaged'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error(b),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(b),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(b)),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary(b)),
      ),
    );
  }
}
