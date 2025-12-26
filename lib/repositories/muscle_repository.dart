import 'dart:developer';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

class MuscleRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService auth;
  late final ImageStorageService imageService;

  MuscleRepository(this.isar, this.pb, this.auth) {
    imageService = ImageStorageService(pb, auth);
  }

  IsarCollection<Muscle> get collection => isar.muscles;

  Stream<List<Muscle>> watchAllMuscles() {
    return isar.muscles.where().watch(fireImmediately: true);
  }

  Future<void> saveMuscle(Muscle muscle) async {
    final exists = await isar.muscles.where().idEqualTo(muscle.id).findFirst();

    if (exists != null) {
      muscle.updatedAt = DateTime.now();
    }

    final updatedThumbnails = <String>[];

    for (final path in muscle.thumbnails) {
      if (path.startsWith('http://') ||
          path.startsWith('https://') ||
          !path.contains('cache')) {
        updatedThumbnails.add(path);
        continue;
      }

      final localPath = await imageService.saveToLocalDisk(
        sourcePath: path,
        directory: 'muscles',
      );

      updatedThumbnails.add(localPath);
    }

    muscle.thumbnails = updatedThumbnails;

    // Delete local removed thumbnails
    final deletedThumbnails = <String>[];
    for (final path in muscle.removedThumbnails) {
      if (path.startsWith('http://') || path.startsWith('https://')) continue;

      final exists = await File(path).exists();
      if (exists) {
        await File(path).delete();
        deletedThumbnails.add(path);
      }
    }
    muscle.removedThumbnails.removeWhere((e) => deletedThumbnails.contains(e));

    if (muscle.pocketbaseId != null) {
      muscle.needSync = true;
    }

    await isar.writeTxn(() async {
      await isar.muscles.put(muscle);
    });

    await _saveMuscleOnCloud(muscle);
  }

  Future<void> deleteMuscle(Muscle muscle) async {
    // Delete local thumbnail files
    try {
      for (final thumbnail in muscle.thumbnails) {
        if (!thumbnail.startsWith('http://') &&
            !thumbnail.startsWith('https://')) {
          await imageService.deleteLocalImage(thumbnail);
        }
      }
    } catch (e) {}

    await isar.writeTxn(() async {
      await isar.muscles.delete(muscle.id);
    });

    if (auth.isSyncEnabled && muscle.pocketbaseId != null) {
      try {
        await pb
            .collection(PBCollections.muscles.value)
            .delete(muscle.pocketbaseId!);
      } catch (e) {
        // Already deleted locally, cloud deletion failure is acceptable
      }
    }
  }

  // --- SYNC LOGIC ---

  // Update an existing muscle on the cloud
  Future<void> _saveMuscleOnCloud(Muscle muscle) async {
    if (!auth.isSyncEnabled) return;

    try {
      final localPaths = <String>[];
      final cloudUrls = <String>[];

      for (final thumbnail in muscle.thumbnails) {
        if (thumbnail.startsWith('http://') ||
            thumbnail.startsWith('https://')) {
          cloudUrls.add(thumbnail);
        } else {
          localPaths.add(thumbnail);
        }
      }

      final removedThumbnails = muscle.removedThumbnails.map((e) => getFileName(e)).toList();

      final body = {
        'user': auth.user?.id,
        ...muscle.toPayload(),
        'thumbnails-': removedThumbnails
      };

      final files = await imageService.prepareMultipartBatch(
        localPaths: localPaths,
        fieldName: 'thumbnails+',
      );

      RecordModel record;
      if (muscle.pocketbaseId == null) {
        record = await pb
            .collection(PBCollections.muscles.value)
            .create(body: body, files: files);
      } else {
        record = await pb
            .collection(PBCollections.muscles.value)
            .update(muscle.pocketbaseId!, body: body, files: files);
      }

      muscle.pocketbaseId = record.id;
      muscle.needSync = false;

      muscle.thumbnails = record
          .getListValue<String>('thumbnails')
          .map((e) => '${pb.files.getURL(record, e)}')
          .toList();

      muscle.removedThumbnails.clear();

      // Delete local files after successful upload
      for (final localPath in localPaths) {
        try {
          await imageService.deleteLocalImage(localPath);
        } catch (e) {
          log('Failed to delete local thumbnail: $e');
        }
      }

      // Write update to local DB
      await isar.writeTxn(() async {
        await isar.muscles.put(muscle);
      });
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        muscle.pocketbaseId = null;
        await isar.writeTxn(() async {
          await isar.muscles.put(muscle);
        });
      }
      log('Failed to save muscle to cloud: $e');
    } catch (e) {
      log('Failed to save muscle to cloud: $e');
    }
  }

  Future<void> performInitialSync() async {
    if (!auth.isSyncEnabled) return;

    log('[Sync][Muscle] Starting...');

    await _uploadLocalMuscles();
    await _downloadAndMergeCloudMuscles();

    log('[Sync][Muscle] Done.');
  }

  Future<void> _uploadLocalMuscles() async {
    final localItems = await isar.muscles
        .filter()
        .pocketbaseIdIsNull()
        .findAll();

    for (final m in localItems) {
      await _saveMuscleOnCloud(m);
    }
  }

  Future<void> _downloadAndMergeCloudMuscles() async {
    try {
      final pbRecords = await pb
          .collection(PBCollections.muscles.value)
          .getFullList(filter: 'user = "${auth.user?.id}"');

      final List<Muscle> musclesToSave = [];

      for (final record in pbRecords) {
        final fromRecord = Muscle.fromRecord(
          record,
          (thumb) => pb.files.getURL(record, thumb).toString(),
        );

        final exists = await isar.muscles
            .filter()
            .pocketbaseIdEqualTo(record.id)
            .findFirst();

        if (exists != null) {
          exists.updateFrom(fromRecord);
          musclesToSave.add(exists);
        } else {
          musclesToSave.add(fromRecord);
        }
      }

      if (musclesToSave.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.muscles.putAll(musclesToSave);
        });
      }
    } catch (e) {
      log('Failed to download and merge cloud muscles: $e');
      rethrow;
    }
  }
}
