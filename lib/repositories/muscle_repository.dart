import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/utils/consts.dart';

class MuscleRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;

  MuscleRepository(this.isar, this.pb, this.authService);

  Stream<List<Muscle>> watchAllMuscles() {
    return isar.muscles.where().watch(fireImmediately: true);
  }

  Future<void> performInitialSync() async {
    // if (!authService.isSyncEnabled) return;

    final localMuscles = await isar.muscles.count();

    if (localMuscles > 0) {
      return;
    }

    final muscleRecords = await pb
        .collection(PBCollections.muscles.value)
        .getFullList();

    await isar.writeTxn(() async {
      for (final record in muscleRecords) {
        final muscle = Muscle(
          name: record.data['name'],
          description: record.data['description'],
          thumbnailCloud: record.data['thumbnail'],
          pocketbaseId: record.id
        );

        await isar.muscles.put(muscle);
      }
    });
  }
}
