import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class SupabaseConfig {
  static const String _url = AppConfig.supabaseUrl;
  static const String _anonKey = AppConfig.supabaseAnonKey;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      publishableKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
