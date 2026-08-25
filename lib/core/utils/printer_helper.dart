import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

/// Native ESC/POS QR code command (printer encodes it itself).
/// Model 2, error correction level 33 (≈M), module size 4, centered below.
List<int> _qrCodeBytes(String data) {
  List<int> bytes = [];
  // QR Code: Model 2
  bytes += [0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00];
  // Error correction level (33 = M)
  bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x33];
  // Store data
  final dataBytes = data.codeUnits;
  final len = dataBytes.length + 3;
  bytes += [
    0x1D,
    0x28,
    0x6B,
    len & 0xFF,
    (len >> 8) & 0xFF,
    0x31,
    0x50,
    0x30,
    ...dataBytes,
  ];
  // Module size (4 = readable on 58mm thermal)
  bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x04];
  // Print the QR code
  bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30];
  return bytes;
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    // Request Bluetooth and Location permissions
    // Android 12+ needs BLUETOOTH_SCAN, BLUETOOTH_CONNECT
    // Older Android needs BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _isConnected =
          !result; // If disconnected successfully, isConnected is false
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> printText(String text) async {
    try {
      if (!_isConnected) return false;

      // Verify the socket is still alive before writing
      final bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
      if (!connectionStatus) return false;

      await PrintBluetoothThermal.writeBytes(_textToBytes(text));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items, // Name, Qty, Price, Total
    required double total,
    required String footer,
    String? customerName,
    String? customerPhone,
    String? billId,
    String? paymentMethod,
    double? amountPaid,
    double? dueAmount,
  }) async {
    if (!_isConnected) return;

    // Construct ESC/POS bytes manually or using helper
    List<int> bytes = [];

    // Init
    bytes += EscPos.init;

    // Shop Name (Center, Bold, Large)
    bytes += EscPos.alignCenter;
    bytes += EscPos.boldOn;
    bytes += EscPos.textLarge;
    bytes += _textToBytes(shopName);
    bytes += EscPos.lineFeed;

    // Address & Phone (Normal, Center)
    bytes += EscPos.textNormal;
    bytes += EscPos.boldOff;
    if (address1.isNotEmpty) {
      bytes += _textToBytes(address1);
      bytes += EscPos.lineFeed;
    }
    if (address2.isNotEmpty) {
      bytes += _textToBytes(address2);
      bytes += EscPos.lineFeed;
    }
    bytes += _textToBytes(phone);
    bytes += EscPos.lineFeed;

    // Date and Time
    String formattedDate =
        DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    bytes += _textToBytes(formattedDate);
    bytes += EscPos.lineFeed;

    // Bill ID
    if (billId != null && billId.isNotEmpty) {
      bytes += _textToBytes('Bill: $billId');
      bytes += EscPos.lineFeed;
      // Scannable QR encoding the unique bill id
      bytes += EscPos.alignCenter;
      bytes += _qrCodeBytes(billId);
      bytes += EscPos.lineFeed;
      bytes += EscPos.lineFeed;
      bytes += EscPos.alignLeft;
    }

    // Customer Info (if provided)
    if (customerName != null && customerName.isNotEmpty) {
      bytes += _textToBytes('Customer: $customerName');
      bytes += EscPos.lineFeed;
    }
    if (customerPhone != null && customerPhone.isNotEmpty) {
      bytes += _textToBytes('Phone: $customerPhone');
      bytes += EscPos.lineFeed;
    }
    if ((customerName != null && customerName.isNotEmpty) ||
        (customerPhone != null && customerPhone.isNotEmpty)) {
      bytes += _textToBytes('--------------------------------');
      bytes += EscPos.lineFeed;
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Header (Align Left)
    bytes += EscPos.alignLeft;
    bytes += _textToBytes('Item            Price   Total');
    bytes += EscPos.lineFeed;
    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Items
    for (var item in items) {
      String name = item['name'].toString();
      String qty = item['qty'].toString();
      String price = item['price'].toString();
      String totalItem = item['total'].toString();
      String? warranty = item['warranty']?.toString();

      String prefix = '${qty}x $name';
      if (prefix.length > 16) prefix = prefix.substring(0, 16);

      String line = prefix.padRight(16) + price.padRight(8) + totalItem;
      bytes += _textToBytes(line);
      bytes += EscPos.lineFeed;

      // Show warranty info below the item if available
      if (warranty != null && warranty.isNotEmpty) {
        bytes += _textToBytes('  $warranty');
        bytes += EscPos.lineFeed;
      }
    }

    bytes += _textToBytes('--------------------------------');
    bytes += EscPos.lineFeed;

    // Total (Align Right)
    bytes += EscPos.alignRight;
    bytes += EscPos.boldOn;
    bytes += _textToBytes('TOTAL: $total');
    bytes += EscPos.lineFeed;
    bytes += EscPos.boldOff;
    bytes += EscPos.lineFeed;

    // Payment & Due
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      bytes += EscPos.alignLeft;
      bytes += _textToBytes('Payment: $paymentMethod');
      bytes += EscPos.lineFeed;
    }
    if (dueAmount != null && dueAmount > 0) {
      bytes += EscPos.alignLeft;
      bytes += _textToBytes('Paid: ${amountPaid ?? 0}');
      bytes += EscPos.lineFeed;
      bytes += EscPos.boldOn;
      bytes += _textToBytes('DUE: $dueAmount');
      bytes += EscPos.lineFeed;
      bytes += EscPos.boldOff;
    }

    // Footer (Center)
    bytes += EscPos.alignCenter;
    bytes += _textToBytes(footer);
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed; // One line space after footer
    bytes += EscPos.lineFeed;
    bytes += EscPos.lineFeed; // Additional Feed

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  /// ASCII-safe ESC/POS text encoding.
  ///
  /// Cheap thermal printers render multi-byte UTF-8 as mojibake (₹ becomes
  /// garbage, Devanagari is unreadable), so map known symbols first and then
  /// drop every non-ASCII codepoint instead of sending broken bytes.
  // TODO: Proper Unicode support needs an ESC/POS codepage switch
  // (FS & + UTF-8-capable codepage) or rendering the receipt to an image.
  List<int> _textToBytes(String text) {
    const symbolMap = {
      '₹': 'Rs.',
      '€': 'EUR',
      '£': 'GBP',
      '\u2013': '-', // en dash
      '\u2014': '-', // em dash
      '\u2018': "'",
      '\u2019': "'",
      '\u201C': '"',
      '\u201D': '"',
    };
    var mapped = text;
    symbolMap.forEach((symbol, replacement) {
      mapped = mapped.replaceAll(symbol, replacement);
    });
    // Strip anything still outside ASCII (Devanagari etc.) — printer would
    // print mojibake for these anyway.
    final ascii =
        String.fromCharCodes(mapped.runes.where((r) => r >= 32 && r < 128));
    return List.from(ascii.codeUnits);
  }
}
