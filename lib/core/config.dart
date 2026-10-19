/// Build-time configuration, supplied with
/// `flutter run --dart-define-from-file=.env` (see .env.example).
/// Only public values belong here: the Supabase URL and the publishable
/// (anon) key. Never put a service-role/secret key in the app.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Amounts at or above this ask for confirmation before saving.
  static const largeAmountPaise = 1000000; // ₹10,000

  /// Foreground reconciliation interval while the app is open.
  static const periodicSync = Duration(minutes: 5);
}
