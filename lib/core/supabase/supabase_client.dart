import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _url = 'https://wwutchscfnhwijxyftlw.supabase.co';
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3dXRjaHNjZm5od2lqeHlmdGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyMTc5NzAsImV4cCI6MjA5OTc5Mzk3MH0.uOmtDo9AEkiKb_n-UiUT_OaR78f1Ci1lZ1XbmntHMk8';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      publishableKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
