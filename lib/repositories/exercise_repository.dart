import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

class MuscleActivationParam {
  Muscle muscle;
  int activation;

  MuscleActivationParam({required this.muscle, required this.activation});
}

class ExerciseRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;
  late final ImageStorageService imageStorageService;

  ExerciseRepository(this.isar, this.pb, this.authService) {
    imageStorageService = ImageStorageService(pb, authService);
  }

  IsarCollection<Exercise> get collection {
    return isar.exercises;
  }

  Stream<List<Exercise>> watchAllExercises() {
    return isar.exercises.where().watch(fireImmediately: true);
  }

  Future<List<Map<String, dynamic>>> getMusclesForExercise(
    int exerciseId,
  ) async {
    final junctions = await isar.exerciseMuscles
        .filter()
        .exercise((q) => q.idEqualTo(exerciseId))
        .findAll();

    final results = <Map<String, dynamic>>[];
    for (final junction in junctions) {
      await junction.muscle.load();
      final muscle = junction.muscle.value;
      if (muscle != null) {
        results.add({'muscle': muscle, 'activation': junction.activation});
      }
    }
    return results;
  }

  Future<void> createExercise({
    required Exercise exercise,
    required List<MuscleActivationParam> muscles,
  }) async {
    if (exercise.thumbnail != null) {
      try {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnail!,
          directory: 'exercises',
          syncEnabled: false,
        );

        exercise.thumbnail = imageResult['localPath'];
      } catch (e) {
        print('Failed to save exercise thumbnail: $e');
        exercise.thumbnail = null;
      }
    }

    exercise.imported = false;
    exercise.needSync = true;

    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);

      for (final entry in muscles) {
        final muscle = entry.muscle;
        final activation = entry.activation;

        final exerciseMuscle =
            ExerciseMuscles(activation: activation, needSync: true)
              ..exercise.value = exercise
              ..muscle.value = muscle;

        await isar.exerciseMuscles.put(exerciseMuscle);
        await exerciseMuscle.exercise.save();
        await exerciseMuscle.muscle.save();
      }
    });

    if (authService.isSyncEnabled) {
      await _uploadExerciseToCloud(exercise);
    }
  }

  Future<void> updateExercise({
    required Exercise exercise,
    required List<MuscleActivationParam> muscles,
  }) async {
    final oldExercise = await isar.exercises.get(exercise.id);

    // Handle thumbnail update if needed
    // Check if this is a NEW image (path changed or doesn't point to app directory yet)
    if (exercise.thumbnail != null) {
      final isNewImage = oldExercise?.thumbnail != exercise.thumbnail;

      if (isNewImage) {
        try {
          if (oldExercise?.thumbnail != null) {
            await imageStorageService.deleteImage(
              localPath: oldExercise!.thumbnail,
              collection: PBCollections.exercises.value,
              recordId: oldExercise.pocketbaseId,
              fieldName: 'thumbnail',
              syncEnabled: false,
            );
          }

          final imageResult = await imageStorageService.saveImage(
            sourcePath: exercise.thumbnail!,
            directory: 'exercises',
            syncEnabled: false,
          );

          exercise.thumbnail = imageResult['localPath'];
        } catch (e) {
          if (oldExercise?.thumbnail != null) {
            exercise.thumbnail = oldExercise!.thumbnail;
          }
        }
      }
    }

    if (exercise.pocketbaseId != null) {
      exercise.needSync = true;
    }

    // Update local DB
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);

      // Update muscle relationships if provided
      final existingJunctions = await isar.exerciseMuscles
          .filter()
          .exercise((q) => q.idEqualTo(exercise.id))
          .findAll();

      for (final junction in existingJunctions) {
        await isar.exerciseMuscles.delete(junction.id);
      }

      // Create new junction entries
      for (final entry in muscles) {
        final muscle = entry.muscle;
        final activation = entry.activation;

        final exerciseMuscle = ExerciseMuscles(activation: activation)
          ..exercise.value = exercise
          ..muscle.value = muscle;

        await isar.exerciseMuscles.put(exerciseMuscle);
        await exerciseMuscle.exercise.save();
        await exerciseMuscle.muscle.save();
      }
    });

    // Sync to cloud if enabled
    if (exercise.pocketbaseId != null) {
      await _updateExerciseOnCloud(exercise);
    } else {
      await _uploadExerciseToCloud(exercise);
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    if (exercise.thumbnail != null) {
      try {
        await imageStorageService.deleteImage(
          localPath: exercise.thumbnail,
          collection: PBCollections.exercises.value,
          recordId: exercise.pocketbaseId,
          fieldName: 'thumbnail',
          syncEnabled: false, // We're deleting the entire row anyway
        );
      } catch (e) {
        // Continue with deletion even if image deletion fails
      }
    }

    await isar.writeTxn(() async {
      await isar.exercises.delete(exercise.id);
    });

    if (authService.isSyncEnabled && exercise.pocketbaseId != null) {
      try {
        await pb
            .collection(PBCollections.exercises.value)
            .delete(exercise.pocketbaseId!);
      } catch (e) {
        // Already deleted locally, cloud deletion failure is acceptabler
      }
    }
  }

  // --- SYNC LOGIC ---

  // Upload a single exercise to the cloud
  Future<void> _uploadExerciseToCloud(Exercise exercise) async {
    if (!authService.isSyncEnabled) return;

    try {
      // Get muscles and activations from junction table
      final junctions = await isar.exerciseMuscles
          .filter()
          .exercise((q) => q.idEqualTo(exercise.id))
          .findAll();

      // Load muscle data for each junction
      final List<MuscleActivationParam> musclesParam = [];
      for (final junction in junctions) {
        await junction.muscle.load();
        final muscle = junction.muscle.value;

        if (muscle != null && muscle.pocketbaseId != null) {
          musclesParam.add(
            MuscleActivationParam(
              muscle: muscle,
              activation: junction.activation,
            ),
          );
        }
      }

      final record = await pb
          .collection(PBCollections.exercises.value)
          .create(
            body: {
              'user': authService.currentUser?['id'],
              'name': exercise.name,
              'description': exercise.description,
              'calories_burned': exercise.caloriesBurned,
            },
          );

      // Create exercise_muscles records in cloud and update junction table
      for (final data in musclesParam) {
        final junction = junctions.firstWhere(
          (j) => j.muscle.value?.id == data.muscle.id,
        );

        final junctionRecord = await pb
            .collection(PBCollections.exerciseMuscles.value)
            .create(
              body: {
                'exercise': record.id,
                'muscle': data.muscle.pocketbaseId,
                'activation': data.activation,
              },
            );

        // Update local junction with pocketbaseId
        junction.pocketbaseId = junctionRecord.id;
        junction.needSync = false;
      }

      if (exercise.thumbnail != null) {
        try {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: exercise.thumbnail!,
            directory: 'exercises',
            collection: PBCollections.exercises.value,
            pbRecord: record,
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          exercise.thumbnail = imageResult['localPath'];
        } catch (e) {
          print('Failed to upload exercise thumbnail to cloud: $e');
          // Continue without thumbnail sync
        }
      }

      exercise.pocketbaseId = record.id;
      exercise.needSync = false;

      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
        // Update junctions with pocketbaseId
        for (final junction in junctions) {
          await isar.exerciseMuscles.put(junction);
        }
      });
    } catch (e) {
      print('Failed to upload exercise to cloud: $e');
      // Exercise remains marked as needSync = true
    }
  }

  // Update an existing exercise on the cloud
  Future<void> _updateExerciseOnCloud(Exercise exercise) async {
    if (!authService.isSyncEnabled) return;

    try {
      // Get muscles and activations from junction table
      final junctions = await isar.exerciseMuscles
          .filter()
          .exercise((q) => q.idEqualTo(exercise.id))
          .findAll();

      // Update the record
      await pb
          .collection(PBCollections.exercises.value)
          .update(
            exercise.pocketbaseId!,
            body: {
              'user': authService.currentUser?['id'],
              'name': exercise.name,
              'description': exercise.description,
              'calories_burned': exercise.caloriesBurned,
            },
          );

      // Handle thumbnail sync if exists
      if (exercise.thumbnail != null) {
        try {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: exercise.thumbnail!,
            directory: 'exercises',
            collection: PBCollections.exercises.value,
            pbRecord: await pb
                .collection(PBCollections.exercises.value)
                .getOne(exercise.pocketbaseId!),
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          if (imageResult['localPath'] != null) {
            exercise.thumbnail = imageResult['localPath'];
          }
        } catch (e) {
          // Continue with sync even if image upload fails
        }
      }

      exercise.needSync = false;

      // Delete existing exercise_muscles records in cloud
      try {
        await pb.send(
          '/collections/${PBCollections.exerciseMuscles.value}/records',
          method: 'DELETE',
          query: {'filter': 'exercise = "${exercise.pocketbaseId}"'},
        );
      } catch (e) {
        // Continue even if deletion fails
      }

      // Create new exercise_muscles records in cloud
      for (final junction in junctions) {
        await junction.muscle.load();
        final muscle = junction.muscle.value;

        if (muscle?.pocketbaseId != null) {
          await pb
              .collection(PBCollections.exerciseMuscles.value)
              .create(
                body: {
                  'exercise': exercise.pocketbaseId,
                  'muscle': muscle!.pocketbaseId,
                  'activation': junction.activation,
                },
              );
        }
      }

      // Write update to local DB
      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
      });
    } catch (e) {
      // Exercise remains marked as needsSync = true
    }
  }

  // This is the complex part: The initial sync when a user logs in
  Future<void> performInitialSync() async {
    if (!authService.isSyncEnabled) return;

    // 1. Upload local-only exercises to cloud
    await _uploadLocalExercises();

    // 2. Download and merge cloud exercises
    await _downloadAndMergeCloudExercises();
  }

  /// Upload all local exercises that don't have a pocketbaseId yet
  Future<void> _uploadLocalExercises() async {
    final localExercises = await isar.exercises
        .filter()
        .pocketbaseIdIsNull()
        .findAll();

    for (final exercise in localExercises) {
      await _uploadExerciseToCloud(exercise);
    }
  }

  /// Download cloud exercises and merge with local data
  Future<void> _downloadAndMergeCloudExercises() async {
    try {
      // Fetch all cloud data
      final pbRecords = await pb
          .collection(PBCollections.exercises.value)
          .getFullList();
      final pbExerciseMuscles = await pb
          .collection(PBCollections.exerciseMuscles.value)
          .getFullList(expand: 'muscle');

      final List<Exercise> exercisesToSave = [];
      final List<ExerciseMuscles> exerciseMusclesToSave = [];

      // Process each cloud exercise
      for (final record in pbRecords) {
        final exists = await isar.exercises
            .filter()
            .pocketbaseIdEqualTo(record.id)
            .findFirst();

        if (exists == null) {
          // New exercise from cloud - insert it
          await _insertNewExerciseFromCloud(
            record,
            pbExerciseMuscles,
            exercisesToSave,
            exerciseMusclesToSave,
          );
        } else {
          // Exercise exists locally - check for updates
          await _updateExistingExerciseFromCloud(
            record,
            exists,
            pbExerciseMuscles,
            exercisesToSave,
            exerciseMusclesToSave,
          );
        }
      }

      // Save all changes in a single transaction
      if (exercisesToSave.isNotEmpty || exerciseMusclesToSave.isNotEmpty) {
        await isar.writeTxn(() async {
          // First save all exercises to generate IDs
          await isar.exercises.putAll(exercisesToSave);

          // Then save exercise-muscle relationships and link them
          for (final junction in exerciseMusclesToSave) {
            await isar.exerciseMuscles.put(junction);
            await junction.exercise.save();
            await junction.muscle.save();
          }
        });
      }
    } catch (e) {
      print('Failed to download and merge cloud exercises: $e');
      rethrow;
    }
  }

  /// Insert a new exercise from cloud that doesn't exist locally
  Future<void> _insertNewExerciseFromCloud(
    dynamic record,
    List<dynamic> pbExerciseMuscles,
    List<Exercise> exercisesToSave,
    List<ExerciseMuscles> exerciseMusclesToSave,
  ) async {
    final exercise = Exercise(
      name: record.data['name'] ?? '',
      description: record.data['description'],
      caloriesBurned:
          (record.data['calories_burned'] as num?)?.toDouble() ?? 0.0,
      pocketbaseId: record.id,
      needSync: false,
      imported: record.data['user'] != authService.currentUser?['id'],
    );

    exercise.createdAt =
        DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now();
    exercise.updatedAt =
        DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

    // Download thumbnail if exists
    await _downloadThumbnail(record, exercise);

    // Add exercise muscles relationships
    await _addExerciseMuscleRelationships(
      record.id,
      exercise,
      pbExerciseMuscles,
      exerciseMusclesToSave,
    );

    exercisesToSave.add(exercise);
  }

  /// Update an existing exercise from cloud if cloud version is newer
  Future<void> _updateExistingExerciseFromCloud(
    dynamic record,
    Exercise exists,
    List<dynamic> pbExerciseMuscles,
    List<Exercise> exercisesToSave,
    List<ExerciseMuscles> exerciseMusclesToSave,
  ) async {
    final cloudLastUpdated = DateTime.tryParse(record.data['updated'] ?? '');

    if (cloudLastUpdated == null ||
        !exists.updatedAt.isBefore(cloudLastUpdated)) {
      return; // Local version is newer or same, skip
    }

    // Update exercise fields
    exists
      ..name = record.data['name'] ?? exists.name
      ..description = record.data['description']
      ..caloriesBurned =
          (record.data['calories_burned'] as num?)?.toDouble() ?? 0.0
      ..updatedAt = cloudLastUpdated;

    // Update thumbnail if cloud version is different
    await _updateThumbnail(record, exists);

    // Update exercise muscles relationships
    await _updateExerciseMuscleRelationships(
      record.id,
      exists,
      pbExerciseMuscles,
      exerciseMusclesToSave,
    );

    exercisesToSave.add(exists);
  }

  /// Download thumbnail from cloud for an exercise
  Future<void> _downloadThumbnail(dynamic record, Exercise exercise) async {
    final thumbnailField = record.data['thumbnail'];
    if (thumbnailField == null || thumbnailField.toString().isEmpty) {
      return;
    }

    try {
      final cloudUrl = pb.files.getUrl(record, thumbnailField).toString();

      final localPath = await imageStorageService.downloadImageFromCloud(
        cloudUrl: cloudUrl,
        directory: 'exercises',
      );

      if (localPath != null) {
        exercise.thumbnail = localPath;
      }
    } catch (e) {
      print('Failed to download thumbnail for exercise ${exercise.name}: $e');
      // Continue without thumbnail
    }
  }

  /// Update thumbnail for existing exercise if cloud version changed
  Future<void> _updateThumbnail(dynamic record, Exercise exists) async {
    final thumbnailField = record.data['thumbnail'];

    if (thumbnailField == null || thumbnailField.toString().isEmpty) {
      return; // Cloud has no thumbnail - keep local one
    }

    try {
      final cloudUrl = pb.files.getUrl(record, thumbnailField).toString();

      final localPath = await imageStorageService.downloadImageFromCloud(
        cloudUrl: cloudUrl,
        directory: 'exercises',
      );

      if (localPath != null) {
        // Delete old local image if it exists
        if (exists.thumbnail != null) {
          await imageStorageService.deleteLocalImage(exists.thumbnail!);
        }
        exists.thumbnail = localPath;
      }
    } catch (e) {
      print('Failed to update thumbnail for exercise ${exists.name}: $e');
      // Keep existing thumbnail if download fails
    }
  }

  /// Add exercise-muscle relationships for a new exercise from cloud
  Future<void> _addExerciseMuscleRelationships(
    String exercisePbId,
    Exercise exercise,
    List<dynamic> pbExerciseMuscles,
    List<ExerciseMuscles> exerciseMusclesToSave,
  ) async {
    final muscles = pbExerciseMuscles.where(
      (element) => element.data['exercise'] == exercisePbId,
    );

    for (final muscle in muscles) {
      final musclePbId = muscle.data['muscle'];
      final muscleLocal = await isar.muscles
          .filter()
          .pocketbaseIdEqualTo(musclePbId)
          .findFirst();

      if (muscleLocal == null) continue;

      final activation = (muscle.data['activation'] as int?) ?? 50;
      final pocketbaseId = muscle.id;
      final createdAt = DateTime.tryParse(muscle.data['created'] ?? '');
      final updatedAt = DateTime.tryParse(muscle.data['updated'] ?? '');

      final exerciseMuscle =
          ExerciseMuscles(
              activation: activation,
              pocketbaseId: pocketbaseId,
              needSync: false,
            )
            ..exercise.value = exercise
            ..muscle.value = muscleLocal;

      if (createdAt != null) exerciseMuscle.createdAt = createdAt;
      if (updatedAt != null) exerciseMuscle.updatedAt = updatedAt;

      exerciseMusclesToSave.add(exerciseMuscle);
    }
  }

  /// Update exercise-muscle relationships for an existing exercise
  Future<void> _updateExerciseMuscleRelationships(
    String exercisePbId,
    Exercise exists,
    List<dynamic> pbExerciseMuscles,
    List<ExerciseMuscles> exerciseMusclesToSave,
  ) async {
    final muscles = pbExerciseMuscles.where(
      (element) => element.data['exercise'] == exercisePbId,
    );

    for (final muscle in muscles) {
      final musclePbId = muscle.data['muscle'];
      final muscleLocal = await isar.muscles
          .filter()
          .pocketbaseIdEqualTo(musclePbId)
          .findFirst();

      if (muscleLocal == null) continue;

      // Check if relationship already exists
      final relationExists = await isar.exerciseMuscles
          .filter()
          .exercise((q) => q.idEqualTo(exists.id))
          .and()
          .muscle((q) => q.idEqualTo(muscleLocal.id))
          .findFirst();

      if (relationExists != null) {
        // Update if cloud is newer
        final cloudUpdated = DateTime.tryParse(muscle.data['updated'] ?? '');
        if (cloudUpdated != null &&
            relationExists.updatedAt.isBefore(cloudUpdated)) {
          relationExists.activation = (muscle.data['activation'] as int?) ?? 50;
          relationExists.pocketbaseId = muscle.id;
          relationExists.needSync = false;
          relationExists.updatedAt = cloudUpdated;
          exerciseMusclesToSave.add(relationExists);
        }
        continue;
      }

      // Create new relationship
      final activation = (muscle.data['activation'] as int?) ?? 50;
      final pocketbaseId = muscle.id;
      final createdAt = DateTime.tryParse(muscle.data['created'] ?? '');
      final updatedAt = DateTime.tryParse(muscle.data['updated'] ?? '');

      final exerciseMuscle =
          ExerciseMuscles(
              activation: activation,
              pocketbaseId: pocketbaseId,
              needSync: false,
            )
            ..exercise.value = exists
            ..muscle.value = muscleLocal;

      if (createdAt != null) exerciseMuscle.createdAt = createdAt;
      if (updatedAt != null) exerciseMuscle.updatedAt = updatedAt;

      exerciseMusclesToSave.add(exerciseMuscle);
    }
  }
}
