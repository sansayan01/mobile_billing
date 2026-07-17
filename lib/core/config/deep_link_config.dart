/// App ke deep-link scheme constants.
///
/// Jab user apne email mein aaye verification link par click karta hai,
/// Supabase `emailRedirectTo` mein diye gaye URL ko open karta hai.
/// Wo URL is scheme par open hota hai aur app khud hi confirm ho jata hai
/// (Supabase automatically token parse kar leta hai).
class DeepLinkConfig {
  const DeepLinkConfig._();

  /// Custom URL scheme jo AndroidManifest / Info.plist mein register kiya gaya hai.
  static const String scheme = 'billingapp';

  /// Host — scheme ke baad aata hai (billingapp://verify).
  static const String host = 'verify';

  /// Full redirect URL jo signUp/resend ke `emailRedirectTo` mein jayega.
  static const String emailRedirectTo = '$scheme://$host';
}
