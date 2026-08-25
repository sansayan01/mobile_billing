import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
// ignore_for_file: prefer_const_constructors
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QrGeneratorPage extends StatefulWidget {
  final Product product;
  const QrGeneratorPage({super.key, required this.product});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  late final TextEditingController _qrDataController;

  @override
  void initState() {
    super.initState();
    _qrDataController =
        TextEditingController(text: widget.product.qrData ?? widget.product.barcode);
  }

  @override
  void dispose() {
    _qrDataController.dispose();
    super.dispose();
  }

  Future<void> _shareQr() async {
    try {
      await Share.share(
        'Product: ${widget.product.name}\n'
        'Barcode: ${widget.product.barcode}\n'
        'Price: ₹${widget.product.price.toStringAsFixed(2)}\n'
        'QR Data: ${_qrDataController.text}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open share options. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveQrImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR rendered on screen. Use share/Screenshot to save.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AdaptiveAppBarLeading(),
        title: const Text('QR Code',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image (if available)
              if (widget.product.imageUrl != null &&
                  widget.product.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.product.imageUrl!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest),
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Product Name
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Barcode
              Text(
                'Barcode: ${widget.product.barcode}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Price
              Text(
                '₹${widget.product.price.toStringAsFixed(2)}',
                style: AppMoneyText.sized(
                  18,
                  FontWeight.w600,
                  AppColors.accentText(Theme.of(context).brightness),
                ),
              ),
              const SizedBox(height: 32),

              // Large QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PrettyQrView.data(
                  data: _qrDataController.text,
                  decoration: PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveQrImage,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareQr,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoText(Theme.of(context).brightness),
                        foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.onAccent : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printing not configured in this view.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print QR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentText(Theme.of(context).brightness),
                    side: BorderSide(color: AppColors.accentText(Theme.of(context).brightness)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
