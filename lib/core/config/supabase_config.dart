import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static late Supabase _instance;
  
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static SupabaseClient get client => _instance.client;
  
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Initialize Supabase
    _instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }
  
  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;
  static Session? get currentSession => client.auth.currentSession;
  
  // Database helpers
  static SupabaseQueryBuilder from(String table) => client.from(table);
  static SupabaseStorageClient get storage => client.storage;
  
  // Auth methods
  static GoTrueClient get auth => client.auth;
  
  // Real-time subscriptions
  static RealtimeChannel realtime(String channelName) {
    return client.realtime.channel(channelName);
  }
}