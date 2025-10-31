/// Supabase configuration for RPI Communication App
///
/// To configure Supabase:
/// 1. Create a Supabase project at https://supabase.com
/// 2. Copy your project URL and anon key from project settings
/// 3. Replace the placeholder values below
///
/// Example usage:
/// ```dart
/// import 'supabase_config.dart';
/// await Supabase.initialize(
///   url: SupabaseConfig.supabaseUrl,
///   anonKey: SupabaseConfig.supabaseAnonKey,
/// );
/// ```

class SupabaseConfig {
  // ⚠️ IMPORTANT: Replace these with your actual Supabase project credentials
  // Get them from: https://app.supabase.com/project/YOUR_PROJECT_ID/settings/api
  //
  // 🔒 SECURITY: Do NOT commit real credentials to version control!
  // Consider using:
  // 1. Environment variables (.env file with flutter_dotenv)
  // 2. Build-time configuration (--dart-define)
  // 3. Add this file to .gitignore after adding real credentials

  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Optional: Storage bucket names
  static const String profileImagesBucket = 'profile-images';
  static const String noticeAttachmentsBucket = 'notice-attachments';
  static const String messageAttachmentsBucket = 'message-attachments';
}
