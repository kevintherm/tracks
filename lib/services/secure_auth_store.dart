import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

/// A custom AuthStore implementation that uses Flutter Secure Storage
/// to persist authentication state securely across app restarts.
class SecureAuthStore extends AuthStore {
  static const String _tokenKey = 'pb_auth_token';
  static const String _modelKey = 'pb_auth_model';

  final FlutterSecureStorage _secureStorage;
  bool _isInitialized = false;

  SecureAuthStore({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  /// Initialize the auth store by loading saved authentication data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final savedToken = await _secureStorage.read(key: _tokenKey);
      final savedModelJson = await _secureStorage.read(key: _modelKey);

      if (savedToken != null && savedModelJson != null) {
        final modelData = jsonDecode(savedModelJson) as Map<String, dynamic>;
        super.save(savedToken, RecordModel.fromJson(modelData));
      }
    } catch (e) {
      // If there's an error loading saved data, clear it
      clear();
    }

    _isInitialized = true;
  }

  @override
  void save(String newToken, RecordModel? newRecord) {
    super.save(newToken, newRecord);
    _persistAuthData();
  }

  @override
  void clear() {
    super.clear();
    _clearPersistedData();
  }

  /// Persist authentication data to secure storage
  Future<void> _persistAuthData() async {
    try {
      if (token.isNotEmpty && record != null) {
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(
          key: _modelKey,
          value: jsonEncode(record!.toJson()),
        );
      } else {
        await _clearPersistedData();
      }
    } catch (e) {
      // Handle storage errors gracefully
      // In production, you might want to use a proper logging framework
      debugPrint('Error persisting auth data: $e');
    }
  }

  /// Clear persisted authentication data
  Future<void> _clearPersistedData() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _modelKey);
    } catch (e) {
      // Handle storage errors gracefully
      debugPrint('Error clearing auth data: $e');
    }
  }

  /// Check if the auth store has been initialized
  bool get isInitialized => _isInitialized;
}
