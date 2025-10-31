/// Supabase configuration for RPI Communication App
///
/// Configuration is now loaded from environment files (.env)
/// This improves security by keeping credentials out of source code
///
/// To configure Supabase:
/// 1. Create a Supabase project at https://supabase.com
/// 2. Copy your project URL and anon key from project settings
/// 3. Create .env file from .env.example
/// 4. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env
///
/// Example usage:
/// ```dart
/// import 'supabase_config.dart';
/// import 'config/app_config.dart';
/// 
/// // Initialize config first
/// await AppConfig.initialize();
/// 
/// await Supabase.initialize(
///   url: SupabaseConfig.supabaseUrl,
///   anonKey: SupabaseConfig.supabaseAnonKey,
/// );
/// ```

import 'config/app_config.dart';

class SupabaseConfig {
  // 🔒 SECURITY: Credentials are loaded from .env files
  // These files are excluded from version control via .gitignore
  // See .env.example for configuration template
  
  static final _config = AppConfig();

  /// Supabase project URL
  /// Loaded from SUPABASE_URL environment variable
  static String get supabaseUrl => _config.supabaseUrl;

  /// Supabase anonymous/public key
  /// Loaded from SUPABASE_ANON_KEY environment variable
  static String get supabaseAnonKey => _config.supabaseAnonKey;

  /// Check if Supabase is properly configured
  static bool get isConfigured => _config.isSupabaseConfigured;

  // Storage bucket names
  static const String profileImagesBucket = 'profile-images';
  static const String noticeAttachmentsBucket = 'notice-attachments';
  static const String messageAttachmentsBucket = 'message-attachments';

  /// Validate configuration before use
  static void validate() {
    if (!isConfigured) {
      throw Exception(
        'Supabase is not configured. Please set SUPABASE_URL and '
        'SUPABASE_ANON_KEY in your .env file. '
        'See .env.example for template.'
      );
    }
  }
}
