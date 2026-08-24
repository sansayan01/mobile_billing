import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

class ImageUploadService {
  static SupabaseClient get _supabase => SupabaseConfig.client;

  /// Upload compressed image to Supabase Storage and return public URL
  static Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ext = imageFile.path.split('.').last;
      final path = 'products/${productId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from('product-images').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      // Get public URL
      final url = _supabase.storage.from('product-images').getPublicUrl(path);
      return url;
    } catch (e) {
      // Upload failed — return null so product saves without image
      return null;
    }
  }
}
