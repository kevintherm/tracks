import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:factual/services/secure_auth_store.dart';

/// Singleton service for managing the PocketBase instance
/// This ensures a single PocketBase client is used throughout the app
class PocketBaseService {
  static PocketBaseService? _instance;
  static late final PocketBase _pb;
  static late final SecureAuthStore _authStore;

  // Private constructor
  PocketBaseService._();

  /// Get the singleton instance
  static PocketBaseService get instance {
    _instance ??= PocketBaseService._();
    return _instance!;
  }

  /// Initialize the PocketBase service
  /// This should be called once at app startup
  static Future<void> initialize({String? baseUrl}) async {
    _authStore = SecureAuthStore();
    _pb = PocketBase(baseUrl ?? getPocketBaseUrl(), authStore: _authStore);

    // Initialize the auth store to load persisted data
    await _authStore.initialize();
  }

  /// Get the PocketBase client instance
  PocketBase get client => _pb;

  /// Get the auth store instance
  SecureAuthStore get authStore => _authStore;

  /// Determine the appropriate PocketBase URL based on platform
static String getPocketBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090';
      // return 'http://192.168.1.188:8090';
    }
    return 'http://127.0.0.1:8090';
  }

  /// Close the PocketBase client (if needed for cleanup)
  void close() {
    _pb.close();
  }
}
