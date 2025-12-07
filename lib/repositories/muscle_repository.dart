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
        );

        // Download thumbnail from cloud if exists
        final thumbnailField = record.data['thumbnail'];
        if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
          try {
            final cloudUrl = pb.files.getUrl(record, thumbnailField).toString();

            final localPath = await imageStorageService.downloadImageFromCloud(
              cloudUrl: cloudUrl,
              directory: 'muscles',
            );

            if (localPath != null) {
              muscle.thumbnail = localPath;
            }

          } catch (e) {
            // Continue without thumbnail
          }
        }

        await isar.muscles.put(muscle);
      }
    });
  }
}
