import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/damaged_products/domain/entities/damaged_product.dart';

class CsvExportImport {
  /// Export products to CSV file and share it
  static Future<void> exportProducts(List<Product> products) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add([
      'Name',
      'Barcode',
      'Price',
      'Stock',
      'Min Stock Level',
      'Unit',
      'Category ID',
      'Location',
      'Description',
      'Warranty Type',
      'Warranty Duration',
      'Warranty Unit',
    ]);

    // Data rows
    for (final product in products) {
      rows.add([
        product.name,
        product.barcode,
        product.price,
        product.stock,
        product.minStockLevel,
        product.unit,
        product.categoryId ?? '',
        product.location ?? '',
        product.description ?? '',
        product.warrantyType,
        product.warrantyDuration ?? '',
        product.warrantyUnit ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/products_export_$stamp.csv');
    // UTF-8 BOM so Excel detects encoding correctly
    await file.writeAsString('\uFEFF$csv');

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Products Export');
  }

  /// Export damaged products to CSV and share it.
  static Future<void> exportDamagedProducts(
    List<DamagedProduct> damaged,
  ) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add([
      'Product Name',
      'Barcode',
      'Quantity Damaged',
      'Unit Price',
      'Estimated Loss',
      'Damage Type',
      'Notes',
      'Reported By',
      'Date',
    ]);

    for (final d in damaged) {
      rows.add([
        d.productName,
        d.productBarcode ?? '',
        d.quantityDamaged,
        d.productPrice.toStringAsFixed(2),
        d.estimatedLoss.toStringAsFixed(2),
        DamagedProduct.damageTypeLabel(d.damageType),
        d.notes ?? '',
        d.reportedByName ?? '',
        DateFormat('yyyy-MM-dd').format(d.damageDate),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/damaged_products_export_$stamp.csv');
    // UTF-8 BOM for Excel compatibility
    await file.writeAsString('\uFEFF$csv');

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Damaged Products Export',
    );
  }

  /// Pick CSV file and return parsed products
  static Future<List<Map<String, String>>> importProducts() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) {
      return [];
    }

    final file = File(result.files.first.path!);
    var csvString = await file.readAsString();
    // Strip UTF-8 BOM if present, else header becomes '\uFEFFName'
    if (csvString.startsWith('\uFEFF')) {
      csvString = csvString.substring(1);
    }

    final rows = const CsvToListConverter().convert(csvString);

    if (rows.isEmpty) return [];

    // First row is header
    final header = rows.first.map((e) => e.toString().trim()).toList();
    final dataRows = rows.skip(1).toList();

    final products = <Map<String, String>>[];

    for (final row in dataRows) {
      final product = <String, String>{};
      for (var i = 0; i < header.length && i < row.length; i++) {
        product[header[i]] = row[i].toString();
      }
      products.add(product);
    }

    return products;
  }
}
