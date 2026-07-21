import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/core/utils/printer_helper.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:go_router/go_router.dart';

class ReceiptPreviewPage extends StatefulWidget {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;
  final List<CartItem> cartItems;
  final double totalAmount;
  final double discount;
  final bool discountIsPercentage;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;

  const ReceiptPreviewPage({
    super.key,
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
    required this.cartItems,
    required this.totalAmount,
    required this.discount,
    required this.discountIsPercentage,
    this.customerName,
    this.customerPhone,
    this.paymentMethod = 'UPI',
  });

  @override
  State<ReceiptPreviewPage> createState() => _ReceiptPreviewPageState();
}

class _ReceiptPreviewPageState extends State<ReceiptPreviewPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSharing = false;

  String _formatPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Future<void> _printReceipt() async {
    try {
      final printerHelper = PrinterHelper();

      if (!printerHelper.isConnected) {
        final savedMac = HiveDatabase.settingsBox.get('printer_mac');
        if (savedMac != null) {
          final connected = await printerHelper.connect(savedMac);
          if (!connected) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to connect to printer'), backgroundColor: Colors.red),
              );
            }
            return;
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Printer not configured'), backgroundColor: Colors.red),
            );
          }
          return;
        }
      }

      final items = widget.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.unitPrice,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
        shopName: widget.shopName,
        address1: widget.address1,
        address2: widget.address2,
        phone: widget.phone,
        items: items,
        total: widget.totalAmount,
        footer: widget.footer,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printed successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareReceipt() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    final size = MediaQuery.of(context).size;

    try {
      final boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final phone = widget.customerPhone;

      if (phone != null && phone.isNotEmpty) {
        // Format phone: remove non-digits, ensure country code
        final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
        final waPhone = digits.startsWith('91') && digits.length == 12
            ? digits
            : digits.length == 10
                ? '91$digits'
                : digits;

        // Direct WhatsApp send via custom MethodChannel
        try {
          final result = await const MethodChannel('com.example.billing_app/whatsapp_share')
              .invokeMethod('shareFile', {
            'phone': waPhone,
            'filePath': [file.path],
          });

          if (result != true) {
            throw Exception('WhatsApp share returned false');
          }
        } on PlatformException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('WhatsApp not available: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // No customer phone — fallback to system share sheet
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Receipt from ${widget.shopName}\nTotal: ₹${_formatPrice(widget.totalAmount)}',
          sharePositionOrigin: Rect.fromLTWH(
            size.width / 2 - 150, size.height / 2 - 300, 300, 600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    final baseTotal = widget.cartItems.fold<double>(0, (sum, item) => sum + item.total);
    final discountAmount = widget.discountIsPercentage
        ? baseTotal * (widget.discount / 100)
        : widget.discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: RepaintBoundary(
            key: _receiptKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Shop header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                    child: Column(
                      children: [
                        Text(
                          widget.shopName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (widget.address1.isNotEmpty)
                          Text(widget.address1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        if (widget.address2.isNotEmpty)
                          Text(widget.address2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        if (widget.phone.isNotEmpty)
                          Text(widget.phone, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Text(dateStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 24, thickness: 1),
                  ),

                  // Customer info
                  if (widget.customerName != null && widget.customerName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      child: Row(
                        children: [
                          const Text('Customer:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.customerName!, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                        ],
                      ),
                    ),
                  if (widget.customerPhone != null && widget.customerPhone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      child: Row(
                        children: [
                          const Text('Phone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.customerPhone!, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                        ],
                      ),
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(height: 24, thickness: 1),
                  ),

                  // Items table header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.black45))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.black45), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.black45), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.black45), textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Items
                  ...widget.cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.product.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('${item.quantity}x', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[700]!)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('₹${_formatPrice(item.unitPrice)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, color: Colors.grey[700]!)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('₹${_formatPrice(item.total)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(thickness: 1),
                  ),

                  // Totals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        Text('₹${_formatPrice(baseTotal)}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  if (widget.discount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.discountIsPercentage ? 'Discount (${widget.discount.toStringAsFixed(0)}%)' : 'Discount',
                            style: const TextStyle(fontSize: 13, color: Colors.green),
                          ),
                          Text('-₹${_formatPrice(discountAmount)}', style: const TextStyle(fontSize: 13, color: Colors.green)),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GRAND TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        Text('₹${_formatPrice(widget.totalAmount)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(thickness: 1),
                  ),

                  // Payment & footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        Text('Payment: ${widget.paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 13, color: Colors.black45)),
                        const SizedBox(height: 6),
                        Text('Thank you for your purchase!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                        if (widget.footer.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(widget.footer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Print
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _printReceipt,
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // WhatsApp
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (widget.customerPhone == null || widget.customerPhone!.isEmpty || _isSharing)
                        ? null
                        : _shareReceipt,
                    icon: _isSharing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.message_rounded, size: 18),
                    label: Text(_isSharing ? 'Sending...' : 'WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Done - full width below
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => GoRouter.of(context).go('/'),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
