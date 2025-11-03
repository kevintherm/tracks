import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/services/secure_auth_store.dart';

class PocketBaseService {
  static PocketBaseService? _instance;
  static late final PocketBase _pb;
  static late final SecureAuthStore _authStore;

  PocketBaseService._();

  static PocketBaseService get instance {
    _instance ??= PocketBaseService._();
    return _instance!;
  }

  static Future<void> initialize({String? baseUrl}) async {
    _authStore = SecureAuthStore();
    _pb = PocketBase(baseUrl ?? getPocketBaseUrl(), authStore: _authStore);

    await _authStore.initialize();
  }

  PocketBase get client => _pb;

  SecureAuthStore get authStore => _authStore;

  static String getPocketBaseUrl() {
    if (Platform.isAndroid) {
      // return 'http://10.0.2.2:8090';
      return 'http://192.168.1.188:8090';
    }
    return 'http://127.0.0.1:8090';
  }

  void close() {
    _pb.close();
  }
}
