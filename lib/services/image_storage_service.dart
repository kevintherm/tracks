import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/services/auth_service.dart';

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
    final localPath = await saveToLocalDisk(
      sourcePath: sourcePath,
      directory: directory,
      fileName: fileName,
    );

    String? cloudUrl;
    if (syncEnabled &&
        collection != null &&
        pbRecord != null &&
        fieldName != null) {
      cloudUrl = await uploadToCloud(
        localPath: localPath,
        collection: collection,
        record: pbRecord,
        fieldName: fieldName,
      );
    }

    return {'localPath': localPath, 'cloudUrl': cloudUrl};
  }

  Future<String> saveToLocalDisk({
    required String sourcePath,
    required String directory,
    String? fileName,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, directory));

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final finalFileName =
        fileName ??
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
    final destinationPath = path.join(imageDir.path, finalFileName);
    final destinationFile = await File(sourcePath).copy(destinationPath);

    return destinationFile.path;
  }

  Future<String?> uploadToCloud({
    required String localPath,
    required String collection,
    required RecordModel record,
    required String fieldName,
  }) async {
    try {
      final imageFile = File(localPath);
      if (!await imageFile.exists()) return null;

      final fileName = path.basename(localPath);
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        localPath,
        filename: fileName,
      );

      final updatedRecord = await pb
          .collection(collection)
          .update(
            record.id,
            body: {'user': authService.currentUser?['id']},
            files: [multipartFile],
          );

      final updatedFileName = updatedRecord.getStringValue('thumbnail');
      return pb.files.getUrl(updatedRecord, updatedFileName).toString();
    } catch (e) {
      return null;
    }
  }

  Future<List<http.MultipartFile>> prepareMultipartBatch({
    required List<String> localPaths,
    required String fieldName,
  }) async {
    try {
      final files = <http.MultipartFile>[];

      for (final p in localPaths) {
        final imageFile = File(p);
        if (!await imageFile.exists()) continue;

        final fileName = path.basename(p);
        final multipartFile = await http.MultipartFile.fromPath(
          fieldName,
          p,
          filename: fileName,
        );

        files.add(multipartFile);
      }

      return files;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteLocalImage(String localPath) async {
    try {
      final file = File(localPath);
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

    if (syncEnabled &&
        collection != null &&
        recordId != null &&
        fieldName != null) {
      try {
        await pb
            .collection(collection)
            .update(recordId, body: {fieldName: null});
      } catch (e) {}
    }
  }

  Future<String> getLocalPath(String directory, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, directory, fileName);
  }

  Future<String?> downloadImageFromCloud({
    required String cloudUrl,
    required String directory,
    String? fileName,
  }) async {
    try {
      final response = await http.get(Uri.parse(cloudUrl));
      if (response.statusCode != 200) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(path.join(appDir.path, directory));

      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final finalFileName = fileName ?? _extractFileNameFromUrl(cloudUrl);
      final destinationPath = path.join(imageDir.path, finalFileName);
      final destinationFile = File(destinationPath);

      await destinationFile.writeAsBytes(response.bodyBytes);
      return destinationFile.path;
    } catch (e) {
      return null;
    }
  }

  String _extractFileNameFromUrl(String cloudUrl) {
    final uri = Uri.parse(cloudUrl);
    final urlFileName = path.basename(uri.path);
    return urlFileName.isNotEmpty
        ? urlFileName
        : '${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}
