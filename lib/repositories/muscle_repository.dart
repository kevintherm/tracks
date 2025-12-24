import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

class MuscleRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;
  late final ImageStorageService imageStorageService;

  MuscleRepository(this.isar, this.pb, this.authService) {
    imageStorageService = ImageStorageService(pb, authService);
  }

  IsarCollection<Muscle> get collection => isar.muscles;

  Stream<List<Muscle>> watchAllMuscles() {
    return isar.muscles.where().watch(fireImmediately: true);
  }

  Future<void> saveMuscle(Muscle muscle) async {
    // Handle thumbnail update if needed
    if (muscle.pendingThumbnailPaths.isNotEmpty) {
      try {
        for (final path in muscle.pendingThumbnailPaths) {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: path,
            directory: 'exercises',
            syncEnabled: false,
          );

          if (imageResult['local_path'] != null) {
            muscle.pendingThumbnailPaths.add(imageResult['localPath']!);
          }
        }
      } catch (e) {
        print('Failed to save muscle thumbnail: $e');
        muscle.pendingThumbnailPaths = [];
      }
    }

    if (muscle.pocketbaseId != null) {
      muscle.needSync = true;
    }

    // Update local DB
    await isar.writeTxn(() async {
      await isar.muscles.put(muscle);
    });

    // Sync to cloud if enabled
    await _saveMuscleOnCloud(muscle);
  }

  Future<void> deleteMuscle(Muscle muscle) async {
    if (muscle.pendingThumbnailPaths.isNotEmpty) {
      try {
        for (final path in muscle.pendingThumbnailPaths) {
          await imageStorageService.deleteLocalImage(path);
        }
      } catch (e) {}
    }

    await isar.writeTxn(() async {
      await isar.muscles.delete(muscle.id);
    });

    if (authService.isSyncEnabled && muscle.pocketbaseId != null) {
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
    if (!authService.isSyncEnabled) return;

    try {
      
      final body = {
              'user': authService.currentUser?['id'],
              'name': muscle.name,
            };

      final RecordModel record;
      if (muscle.pocketbaseId == null) {
        record = await pb.collection(PBCollections.muscles.value).create(body: body);
      } else {
        record = await pb.collection(PBCollections.muscles.value).update(muscle.pocketbaseId!, body: body);
      }

      // Handle thumbnail sync if exists
      if (muscle.pendingThumbnailPaths.isNotEmpty) {
        try {
          for (final path in muscle.pendingThumbnailPaths) {
            final imageResult = await imageStorageService.saveImage(
              sourcePath: path,
              directory: 'muscles',
              collection: PBCollections.muscles.value,
              pbRecord: record,
              fieldName: 'thumbnails',
              syncEnabled: true,
            );

            if (imageResult['cloudUrl'] != null) {
              muscle.thumbnails = imageResult['cloudUrl'] as List<String>;
              muscle.pendingThumbnailPaths = [];
            }
          }
        } catch (e) {
          print('Failed to upload muscle thumbnail to cloud: $e');
          // Continue without thumbnail sync
        }
      }

      muscle.needSync = false;

      // Write update to local DB
      await isar.writeTxn(() async {
        await isar.muscles.put(muscle);
      });
    } catch (e) {
      // muscle remains marked as needsSync = true
    }
  }

  Future<void> performInitialSync() async {
    // if (!authService.isSyncEnabled) return;

    final muscleRecords = await pb
        .collection(PBCollections.muscles.value)
        .getFullList();

    await isar.writeTxn(() async {
      for (final record in muscleRecords) {
        final exists = await isar.muscles
            .filter()
            .pocketbaseIdEqualTo(record.id)
            .findFirst();

        if (exists != null) continue;

        final muscle = Muscle(
          name: record.data['name'],
          description: record.data['description'],
          pocketbaseId: record.id,
          needSync: false
        );

        muscle.createdAt =
            DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now();
        muscle.updatedAt =
            DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

        final thumbnailField = record.data['thumbnail'];
        if (thumbnailField != null) {
          if (thumbnailField is List) {
            muscle.thumbnails = thumbnailField
                .map((thumb) => pb.files.getUrl(record, thumb).toString())
                .toList();
          } else if (thumbnailField.toString().isNotEmpty) {
            muscle.thumbnails = [
              pb.files.getUrl(record, thumbnailField).toString(),
            ];
          }
        }

        await isar.muscles.put(muscle);
      }
    });
  }
}
