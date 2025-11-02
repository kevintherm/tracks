import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/muscle_group.dart';
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

  Stream<List<MuscleGroup>> watchAllMuscleGroups() {
    return isar.muscleGroups.where().watch(fireImmediately: true);
  }

  Future<void> performInitialSync() async {
    // if (!authService.isSyncEnabled) return;

    final localMuscleGroups = await isar.muscleGroups.count();
    final localMuscles = await isar.muscles.count();

    if (localMuscleGroups > 0 && localMuscles > 0) {
      return;
    }

    final muscleGroupRecords = await pb
        .collection(PBCollections.muscleGroups.value)
        .getFullList();
    
    final Map<String, MuscleGroup> muscleGroupMap = {};
    
    await isar.writeTxn(() async {
      for (final record in muscleGroupRecords) {
        final muscleGroup = MuscleGroup(name: record.data['name']);
        
        await isar.muscleGroups.put(muscleGroup);
        muscleGroupMap[record.id] = muscleGroup;
      }
    });

    final muscleRecords = await pb
        .collection(PBCollections.muscles.value)
        .getFullList(expand: 'muscle_groups');
    
    await isar.writeTxn(() async {
      for (final record in muscleRecords) {
        final muscle = Muscle(
          name: record.data['name'],
          description: record.data['description'],
        );
        
        await isar.muscles.put(muscle);

        final muscleGroupIds = record.data['muscle_groups'] as List<dynamic>?;
        if (muscleGroupIds != null) {
          for (final mgId in muscleGroupIds) {
            final muscleGroup = muscleGroupMap[mgId];
            if (muscleGroup != null) {
              muscle.muscleGroups.add(muscleGroup);
            }
          }
          await muscle.muscleGroups.save();
        }
      }
    });
  }
}
