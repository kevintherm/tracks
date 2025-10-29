import 'package:flutter_test/flutter_test.dart';
import 'package:tracks/services/secure_auth_store.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  group('SecureAuthStore', () {
    late SecureAuthStore authStore;

    setUp(() {
      // Note: In real tests, you'd want to use a mock FlutterSecureStorage
      // For now, this is a basic structure
      authStore = SecureAuthStore();
    });

    test('should initialize without errors', () async {
      await authStore.initialize();
      expect(authStore.isInitialized, true);
    });

    test('should clear tokens when clearing auth store', () {
      // Create a test record
      final testRecord = RecordModel.fromJson({
        'id': 'test123',
        'email': 'test@example.com',
        'name': 'Test User',
      });

      // Save auth data
      authStore.save('test_token', testRecord);

      expect(authStore.token, 'test_token');
      expect(authStore.record?.id, 'test123');

      // Clear auth data
      authStore.clear();

      expect(authStore.token, '');
      expect(authStore.record, null);
    });

    test('should handle save and clear operations', () {
      final testRecord = RecordModel.fromJson({
        'id': 'test456',
        'email': 'test2@example.com',
        'name': 'Test User 2',
      });

      // Test save
      authStore.save('another_token', testRecord);
      expect(authStore.token, 'another_token');
      expect(authStore.record?.id, 'test456');

      // Test clear
      authStore.clear();
      expect(authStore.token, '');
      expect(authStore.record, null);
    });
  });
}