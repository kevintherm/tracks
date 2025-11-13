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

  Future<Map<String, String?>> saveImage({
    required String sourcePath,
    required String directory,
    String? fileName,
    String? collection,
    RecordModel? pbRecord,
    String? fieldName,
    bool syncEnabled = true,
  }) async {
    final localPath = await _saveToLocalDisk(
      sourcePath: sourcePath,
      directory: directory,
      fileName: fileName,
    );

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

  Future<String> _saveToLocalDisk({
    required String sourcePath,
    required String directory,
    String? fileName,
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      final Directory imageDir = Directory(path.join(appDir.path, directory));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final String finalFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';

      final File sourceFile = File(sourcePath);
      final String destinationPath = path.join(imageDir.path, finalFileName);
      final File destinationFile = await sourceFile.copy(destinationPath);

      return destinationFile.path;
    } catch (e) {
      rethrow;
    }
  }

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

      final fileName = path.basename(localPath);
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        localPath,
        filename: fileName,
      );

      final updatedRecord = await pb.collection(collection).update(
        recordId,
        body: {
          'user': authService.currentUser?['id']
        },
        files: [multipartFile],
      );

      final updatedFileName = updatedRecord.getStringValue('thumbnail');
      final fileUrl = pb.files.getUrl(updatedRecord, updatedFileName);

      return fileUrl.toString();
    } catch (e) {
      return null;
    }
  }

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

  Future<void> deleteImage({
    required String? localPath,
    required String? collection,
    required String? recordId,
    required String? fieldName,
    bool syncEnabled = false,
  }) async {
    if (localPath != null) {
      await deleteLocalImage(localPath);
    }

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

  Future<String> getLocalPath(String directory, String fileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, directory, fileName);
  }

  Future<String?> downloadImageFromCloud({
    required String cloudUrl,
    required String directory,
    String? fileName,
  }) async {
    try {
      final response = await http.get(Uri.parse(cloudUrl));
      
      if (response.statusCode != 200) {
        return null;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      
      final Directory imageDir = Directory(path.join(appDir.path, directory));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      String finalFileName;
      if (fileName != null) {
        finalFileName = fileName;
      } else {
        final uri = Uri.parse(cloudUrl);
        final urlFileName = path.basename(uri.path);
        finalFileName = urlFileName.isNotEmpty 
            ? urlFileName 
            : '${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      final String destinationPath = path.join(imageDir.path, finalFileName);
      final File destinationFile = File(destinationPath);
      await destinationFile.writeAsBytes(response.bodyBytes);

      return destinationFile.path;
    } catch (e) {
      return null;
    }
  }
}
