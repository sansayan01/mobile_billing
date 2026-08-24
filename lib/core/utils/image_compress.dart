import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompress {
  /// Compress image to ~90% smaller size for Supabase storage
  /// Returns compressed file path
  static Future<String> compressImage(String imagePath) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: 10, // 10% quality = ~90% compression
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Image compression failed');
    }

    return result.path;
  }

  /// Get compressed file size in KB
  static Future<double> getCompressedSizeKB(String filePath) async {
    final file = File(filePath);
    final bytes = await file.length();
    return bytes / 1024;
  }

  /// Compress and return as bytes for direct upload
  static Future<List<int>> compressImageAsBytes(String imagePath) async {
    final result = await FlutterImageCompress.compressWithFile(
      imagePath,
      quality: 10, // 10% quality = ~90% compression
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Image compression failed');
    }

    return result;
  }
}
