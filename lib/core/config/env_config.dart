import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');

    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // Validate required values
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing required environment variables');
    }
  }
}
