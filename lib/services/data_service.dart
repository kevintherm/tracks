import 'package:tracks/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

/// Example service that demonstrates how to use the PocketBase singleton
/// for non-authentication related operations
class DataService {
  /// Get the PocketBase client from the singleton
  PocketBase get _pb => PocketBaseService.instance.client;

  /// Example: Fetch all records from a collection
  Future<List<RecordModel>> getRecords(String collectionName) async {
    try {
      final result = await _pb.collection(collectionName).getFullList();
      return result;
    } catch (e) {
      throw Exception('Failed to fetch records: $e');
    }
  }

  /// Example: Create a new record
  Future<RecordModel> createRecord(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      final record = await _pb.collection(collectionName).create(body: data);
      return record;
    } catch (e) {
      throw Exception('Failed to create record: $e');
    }
  }

  /// Example: Update a record
  Future<RecordModel> updateRecord(
    String collectionName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    try {
      final record = await _pb
          .collection(collectionName)
          .update(recordId, body: data);
      return record;
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  /// Example: Delete a record
  Future<void> deleteRecord(String collectionName, String recordId) async {
    try {
      await _pb.collection(collectionName).delete(recordId);
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }

  /// Example: Subscribe to real-time changes
  void subscribeToCollection(
    String collectionName,
    Function(RecordSubscriptionEvent) callback,
  ) {
    _pb.collection(collectionName).subscribe('*', callback);
  }

  /// Example: Unsubscribe from real-time changes
  void unsubscribeFromCollection(String collectionName) {
    _pb.collection(collectionName).unsubscribe();
  }
}
