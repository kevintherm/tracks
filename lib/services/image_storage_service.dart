import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/services/auth_service.dart';

/// Service for handling image storage both locally and in the cloud
class ImageStorageService {
  final PocketBase pb;
  final AuthService authService;

  ImageStorageService(this.pb, this.authService);

  /// Saves an image to local disk and optionally uploads to cloud
  /// 
  /// Returns a map containing:
  /// - 'localPath': The local file path where the image is saved
  /// - 'cloudUrl': The cloud URL (if sync is enabled and upload succeeds)
  /// 
  /// [sourcePath] - The source image file path (e.g., from image picker)
  /// [directory] - The subdirectory name (e.g., 'exercises', 'profiles')
  /// [fileName] - Optional custom file name (defaults to timestamp-based name)
  /// [collection] - The PocketBase collection name for upload
  /// [pbRecord] - The PocketBase record to attach the file to
  /// [fieldName] - The field name in PocketBase collection (e.g., 'thumbnail')
  /// [syncEnabled] - Whether to upload to cloud
  Future<Map<String, String?>> saveImage({
    required String sourcePath,
    required String directory,
    String? fileName,
    String? collection,
    RecordModel? pbRecord,
    String? fieldName,
    bool syncEnabled = true,
  }) async {
    // Step 1: Save to local disk
    final localPath = await _saveToLocalDisk(
      sourcePath: sourcePath,
      directory: directory,
      fileName: fileName,
    );

    // Step 2: Upload to cloud if sync is enabled
    String? cloudUrl;
    if (syncEnabled && collection != null && pbRecord != null && fieldName != null) {
      cloudUrl = await _uploadToCloud(
        localPath: localPath,
        collection: collection,
        record: pbRecord,
        fieldName: fieldName,
      );
    }

    return {
      'localPath': localPath,
      'cloudUrl': cloudUrl,
    };
  }

  /// Saves an image file to local app directory
  Future<String> _saveToLocalDisk({
    required String sourcePath,
    required String directory,
    String? fileName,
  }) async {
    try {
      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Create subdirectory if it doesn't exist
      final Directory imageDir = Directory(path.join(appDir.path, directory));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate file name if not provided
      final String finalFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';

      // Copy file to app directory
      final File sourceFile = File(sourcePath);
      final String destinationPath = path.join(imageDir.path, finalFileName);
      final File destinationFile = await sourceFile.copy(destinationPath);

      return destinationFile.path;
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads an image to PocketBase cloud storage
  Future<String?> _uploadToCloud({
    required String localPath,
    required String collection,
    required RecordModel record,
    required String fieldName,
  }) async {
    try {
      final File imageFile = File(localPath);
      if (!await imageFile.exists()) {
        return null;
      }

      final recordId = record.id;

      // Create multipart file
      final fileName = path.basename(localPath);
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        localPath,
        filename: fileName,
      );

      print('$recordId, $fileName, $multipartFile');

      // Update the record with the file
      final updatedRecord = await pb.collection(collection).update(
        recordId,
        body: {
          'user': authService.currentUser?['id']
        },
        files: [multipartFile],
      );

      // Get the file URL from the record

      final updatedFileName = updatedRecord.getStringValue('thumbnail');

      final fileUrl = pb.files.getUrl(updatedRecord, updatedFileName);
      return fileUrl.toString();
    } catch (e) {
      print('Error updating collection image $e');
      return null;
    }
  }

  /// Deletes an image from local disk
  Future<bool> deleteLocalImage(String localPath) async {
    try {
      final File file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Deletes an image from both local disk and cloud
  Future<void> deleteImage({
    required String? localPath,
    required String? collection,
    required String? recordId,
    required String? fieldName,
    bool syncEnabled = false,
  }) async {
    // Delete from local disk
    if (localPath != null) {
      await deleteLocalImage(localPath);
    }

    // Delete from cloud (set field to empty)
    if (syncEnabled && collection != null && recordId != null && fieldName != null) {
      try {
        await pb.collection(collection).update(
          recordId,
          body: {fieldName: null},
        );
      } catch (e) {
        // Failed to delete from cloud
      }
    }
  }

  /// Gets the local path for a given directory and filename
  Future<String> getLocalPath(String directory, String fileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, directory, fileName);
  }

  /// Downloads an image from cloud URL and saves it locally
  /// 
  /// Returns the local file path where the image was saved, or null if download fails
  /// 
  /// [cloudUrl] - The URL of the image in PocketBase cloud storage
  /// [directory] - The subdirectory name where to save locally (e.g., 'exercises')
  /// [fileName] - Optional custom file name (defaults to extracted from URL)
  Future<String?> downloadImageFromCloud({
    required String cloudUrl,
    required String directory,
    String? fileName,
  }) async {
    try {
      // Download the image from the URL
      final response = await http.get(Uri.parse(cloudUrl));
      
      if (response.statusCode != 200) {
        return null;
      }

      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      // Create subdirectory if it doesn't exist
      final Directory imageDir = Directory(path.join(appDir.path, directory));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate file name if not provided
      String finalFileName;
      if (fileName != null) {
        finalFileName = fileName;
      } else {
        // Extract filename from URL or generate timestamp-based name
        final uri = Uri.parse(cloudUrl);
        final urlFileName = path.basename(uri.path);
        finalFileName = urlFileName.isNotEmpty 
            ? urlFileName 
            : '${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      // Save the downloaded bytes to local file
      final String destinationPath = path.join(imageDir.path, finalFileName);
      final File destinationFile = File(destinationPath);
      await destinationFile.writeAsBytes(response.bodyBytes);

      return destinationFile.path;
    } catch (e) {
      print('Error downloading image from cloud: $e');
      return null;
    }
  }
}
