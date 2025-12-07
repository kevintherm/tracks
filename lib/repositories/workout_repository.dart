import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

class WorkoutConfigParam {
  Exercise exercise;
  int reps;
  int sets;

  WorkoutConfigParam({
    required this.exercise,
    required this.sets,
    required this.reps,
  });
}

class WorkoutConfig {
  int reps;
  int sets;

  WorkoutConfig({required this.reps, required this.sets});
}

class WorkoutRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;
  late final ImageStorageService imageStorageService;

  WorkoutRepository(this.isar, this.pb, this.authService) {
    imageStorageService = ImageStorageService(pb, authService);
  }

  Stream<List<Workout>> watchAllWorkouts() {
    return isar.workouts.where().watch(fireImmediately: true);
  }

  Stream<List<WorkoutExercises>> watchExercisesForWorkout(int workoutId) {
    return isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(workoutId))
        .watch(fireImmediately: true);
  }

  Stream<List<WorkoutExercises>> watchWorkoutsForExercise(int exerciseId) {
    return isar.workoutExercises
        .filter()
        .exercise((q) => q.idEqualTo(exerciseId))
        .watch(fireImmediately: true);
  }

  // Get exercises for a specific workout with sets and reps
  Future<List<Map<String, dynamic>>> getExercisesForWorkout(
    int workoutId,
  ) async {
    final junctions = await isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(workoutId))
        .findAll();

    final results = <Map<String, dynamic>>[];
    for (final junction in junctions) {
      await junction.exercise.load();
      final exercise = junction.exercise.value;
      if (exercise != null) {
        results.add({
          'exercise': exercise,
          'sets': junction.sets,
          'reps': junction.reps,
        });
      }
    }
    return results;
  }

  IsarCollection<Workout> get collection {
    return isar.workouts;
  }

  IsarCollection<WorkoutExercises> get weCollection {
    return isar.workoutExercises;
  }

  Future<void> createWorkout({
    required Workout workout,
    required List<WorkoutConfigParam> exercises,
  }) async {
    if (workout.thumbnail != null) {
      try {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: workout.thumbnail!,
          directory: 'workouts',
          syncEnabled: false,
        );

        workout.thumbnail = imageResult['localPath'];
      } catch (e) {
        workout.thumbnail = null;
      }
    }

    await isar.writeTxn(() async {
      await isar.workouts.put(workout);

      // Create junction table entries if exercises provided
      if (exercises.isNotEmpty) {
        for (final entry in exercises) {
          final exercise = entry.exercise;
          final sets = entry.sets;
          final reps = entry.reps;

          final workoutExercise = WorkoutExercises(sets: sets, reps: reps)
            ..workout.value = workout
            ..exercise.value = exercise;

          await isar.workoutExercises.put(workoutExercise);
          await workoutExercise.workout.save();
          await workoutExercise.exercise.save();
        }
      }
    });

    if (authService.isSyncEnabled) {
      _uploadWorkoutToCloud(workout);
    }
  }

  Future<void> updateWorkout({
    required Workout workout,
    required List<WorkoutConfigParam> exercises,
  }) async {
    // Get old workout to compare
    final oldWorkout = await isar.workouts.get(workout.id);

    // Handle thumbnail update if needed
    if (workout.thumbnail != null) {
      final isNewImage = oldWorkout?.thumbnail != workout.thumbnail;

      if (isNewImage) {
        try {
          // Delete old image if exists
          if (oldWorkout?.thumbnail != null) {
            await imageStorageService.deleteImage(
              localPath: oldWorkout!.thumbnail,
              collection: PBCollections.workouts.value,
              recordId: oldWorkout.pocketbaseId,
              fieldName: 'thumbnail',
              syncEnabled: false,
            );
          }

          // Save new image to local storage
          final imageResult = await imageStorageService.saveImage(
            sourcePath: workout.thumbnail!,
            directory: 'workouts',
            syncEnabled: false,
          );

          workout.thumbnail = imageResult['localPath'];
        } catch (e) {
          // Keep old thumbnail path if new one fails
          if (oldWorkout?.thumbnail != null) {
            workout.thumbnail = oldWorkout!.thumbnail;
          }
        }
      }
    }

    // Mark as needing sync if cloud ID exists
    if (workout.pocketbaseId != null) {
      workout.needSync = true;
    }

    // Update local DB
    await isar.writeTxn(() async {
      await isar.workouts.put(workout);

      if (exercises.isNotEmpty) {
        final existingJunctions = await isar.workoutExercises
            .filter()
            .workout((q) => q.idEqualTo(workout.id))
            .findAll();

        for (final junction in existingJunctions) {
          await isar.workoutExercises.delete(junction.id);
        }

        for (final entry in exercises) {
          final exercise = entry.exercise;
          final sets = entry.sets;
          final reps = entry.reps;

          final workoutExercise = WorkoutExercises(sets: sets, reps: reps)
            ..workout.value = workout
            ..exercise.value = exercise;

          await isar.workoutExercises.put(workoutExercise);
          await workoutExercise.workout.save();
          await workoutExercise.exercise.save();
        }
      }
    });

    // Sync to cloud if enabled
    if (authService.isSyncEnabled) {
      if (workout.pocketbaseId != null) {
        await _updateWorkoutOnCloud(workout);
      } else {
        await _uploadWorkoutToCloud(workout);
      }
    }
  }

  Future<void> deleteWorkout(Workout workout) async {
    if (workout.thumbnail != null) {
      try {
        await imageStorageService.deleteImage(
          localPath: workout.thumbnail,
          collection: PBCollections.workouts.value,
          recordId: workout.pocketbaseId,
          fieldName: 'thumbnail',
          syncEnabled: false,
        );
      } catch (e) {
        // Continue with deletion even if image deletion fails
      }
    }

    await isar.writeTxn(() async {
      // Delete junction table entries
      final junctions = await isar.workoutExercises
          .filter()
          .workout((q) => q.idEqualTo(workout.id))
          .findAll();

      for (final junction in junctions) {
        await isar.workoutExercises.delete(junction.id);
      }

      final schedules = await isar.schedules.filter().workout((q) => q.idEqualTo(workout.id)).findAll();
      final scheduleIds = schedules.map((e) => e.id).toList();
      await isar.schedules.deleteAll(scheduleIds);

      // Delete the workout
      await isar.workouts.delete(workout.id);
    });

    if (authService.isSyncEnabled && workout.pocketbaseId != null) {
      try {
        await pb
            .collection(PBCollections.workouts.value)
            .delete(workout.pocketbaseId!);
      } catch (e) {
        // Already deleted locally, cloud deletion failure is acceptable
      }
    }
  }

  // --- SYNC LOGIC ---

  // Upload a single workout to the cloud
  Future<void> _uploadWorkoutToCloud(Workout workout) async {
    if (!authService.isSyncEnabled) return;

    try {
      final junctions = await isar.workoutExercises
          .filter()
          .workout((q) => q.idEqualTo(workout.id))
          .findAll();

      final record = await pb
          .collection(PBCollections.workouts.value)
          .create(
            body: {
              'user': authService.currentUser?['id'],
              'name': workout.name,
              'description': workout.description,
            },
          );

      for (final junction in junctions) {
        await junction.exercise.load();
        final exercise = junction.exercise.value;

        if (exercise?.pocketbaseId != null) {
          final junctionRecord = await pb
              .collection(PBCollections.workoutExercises.value)
              .create(
                body: {
                  'workout': record.id,
                  'exercise': exercise!.pocketbaseId,
                  'reps': junction.reps,
                  'sets': junction.sets,
                },
              );

          // Update local junction with pocketbaseId
          junction.pocketbaseId = junctionRecord.id;
          junction.needSync = false;
        }
      }

      if (workout.thumbnail != null) {
        try {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: workout.thumbnail!,
            directory: 'workouts',
            collection: PBCollections.workouts.value,
            pbRecord: record,
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          workout.thumbnail = imageResult['localPath'];
        } catch (e) {
          print('Failed to upload workout thumbnail to cloud: $e');
          // Continue without thumbnail sync
        }
      }

      workout.pocketbaseId = record.id;
      workout.needSync = false;

      await isar.writeTxn(() async {
        await isar.workouts.put(workout);
        // Update junctions with pocketbaseId
        for (final junction in junctions) {
          await isar.workoutExercises.put(junction);
        }
      });
    } catch (e) {
      print('Failed to upload workout to cloud: $e');
      // Workout remains marked as needSync = true
    }
  }

  // Update an existing workout on the cloud
  Future<void> _updateWorkoutOnCloud(Workout workout) async {
    if (!authService.isSyncEnabled) return;

    try {
      // Get exercises from junction table
      final junctions = await isar.workoutExercises
          .filter()
          .workout((q) => q.idEqualTo(workout.id))
          .findAll();

      // Update the workout record
      final record = await pb
          .collection(PBCollections.workouts.value)
          .update(
            workout.pocketbaseId!,
            body: {
              'user': authService.currentUser?['id'],
              'name': workout.name,
              'description': workout.description,
            },
          );

      // Delete existing workout_exercises records in cloud
      try {
        final existingJunctions = await pb
            .collection(PBCollections.workoutExercises.value)
            .getFullList(filter: 'workout = "${workout.pocketbaseId}"');

        for (final junction in existingJunctions) {
          await pb
              .collection(PBCollections.workoutExercises.value)
              .delete(junction.id);
        }
      } catch (e) {
        // Continue even if deletion fails
      }

      // Create new workout_exercises records in cloud and update local
      for (final junction in junctions) {
        await junction.exercise.load();
        final exercise = junction.exercise.value;
        if (exercise?.pocketbaseId != null) {
          final junctionRecord = await pb
              .collection(PBCollections.workoutExercises.value)
              .create(
                body: {
                  'workout': workout.pocketbaseId,
                  'exercise': exercise!.pocketbaseId,
                  'sets': junction.sets,
                  'reps': junction.reps,
                },
              );

          // Update local junction with pocketbaseId
          junction.pocketbaseId = junctionRecord.id;
          junction.needSync = false;
        }
      }

      // Handle thumbnail sync if exists
      if (workout.thumbnail != null) {
        try {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: workout.thumbnail!,
            directory: 'workouts',
            collection: PBCollections.workouts.value,
            pbRecord: record,
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          if (imageResult['localPath'] != null) {
            workout.thumbnail = imageResult['localPath'];
          }
        } catch (e) {
          print('Failed updating workout thumbnail to cloud: $e');
          // Continue without thumbnail sync
        }
      }

      // Success! Mark as synced
      workout.needSync = false;

      await isar.writeTxn(() async {
        await isar.workouts.put(workout);
        // Update junctions with pocketbaseId
        for (final junction in junctions) {
          await isar.workoutExercises.put(junction);
        }
      });
    } catch (e) {
      print('Failed to update workout on cloud: $e');
      // Workout remains marked as needSync = true
    }
  }

  // This is the complex part: The initial sync when a user logs in
  Future<void> performInitialSync() async {
    if (!authService.isSyncEnabled) return;

    // 1. Upload local-only workouts
    final localWorkouts = await isar.workouts
        .filter()
        .pocketbaseIdIsNull()
        .findAll();
    for (final workout in localWorkouts) {
      await _uploadWorkoutToCloud(workout);
    }

    // 2. Download cloud-only workouts
    final pbRecords = await pb
        .collection(PBCollections.workouts.value)
        .getFullList();
    final List<Workout> workoutsToSave = [];

    for (final record in pbRecords) {
      // Check if we already have this workout locally
      final exists = await isar.workouts
          .filter()
          .pocketbaseIdEqualTo(record.id)
          .findFirst();

      if (exists == null) {
        final toInsert = Workout(
          name: record.data['name'],
          description: record.data['description'],
          pocketbaseId: record.id,
          needSync: false,
        );

        toInsert.createdAt =
            DateTime.tryParse(record.data['created']) ?? DateTime.now();
        toInsert.updatedAt =
            DateTime.tryParse(record.data['updated']) ?? DateTime.now();

        // Download thumbnail from cloud if exists
        final thumbnailField = record.data['thumbnail'];
        if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
          try {
            final cloudUrl = pb.files.getUrl(record, thumbnailField).toString();

            final localPath = await imageStorageService.downloadImageFromCloud(
              cloudUrl: cloudUrl,
              directory: 'workouts',
            );

            if (localPath != null) {
              toInsert.thumbnail = localPath;
            }
          } catch (e) {
            // Continue without thumbnail
          }
        }

        workoutsToSave.add(toInsert);
      } else {
        // CONFLICT: Workout exists locally and on cloud
        final cloudLastUpdated = DateTime.tryParse(record.data['updated']);

        if (cloudLastUpdated != null &&
            exists.updatedAt.isBefore(cloudLastUpdated)) {
          exists
            ..name = record.data['name']
            ..description = record.data['description']
            ..updatedAt = cloudLastUpdated;

          // Download image from cloud and update the thumbnail
          final thumbnailField = record.data['thumbnail'];
          if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
            try {
              final cloudUrl = pb.files
                  .getUrl(record, thumbnailField)
                  .toString();

              final localPath = await imageStorageService
                  .downloadImageFromCloud(
                    cloudUrl: cloudUrl,
                    directory: 'workouts',
                  );

              if (localPath != null) {
                if (exists.thumbnail != null) {
                  await imageStorageService.deleteLocalImage(
                    exists.thumbnail!,
                  );
                }
                exists.thumbnail = localPath;
              }
            } catch (e) {
              // Keep existing thumbnail if download fails
            }
          }

          workoutsToSave.add(exists);
        }
      }
    }

    // Save all workouts from the cloud to the local DB
    await isar.writeTxn(() async {
      await isar.workouts.putAll(workoutsToSave);
    });

    // 3. Sync workout_exercises junction table
    try {
      final pbWorkoutExercises = await pb
          .collection(PBCollections.workoutExercises.value)
          .getFullList(expand: 'workout,exercise');

      await isar.writeTxn(() async {
        for (final record in pbWorkoutExercises) {
          final workoutPbId = record.data['workout'];
          final exercisePbId = record.data['exercise'];
          final sets = record.data['sets'] as int? ?? 3;
          final reps = record.data['reps'] as int? ?? 10;

          if (workoutPbId == null || exercisePbId == null) continue;

          // Get local workout and exercise
          final localWorkout = await isar.workouts
              .filter()
              .pocketbaseIdEqualTo(workoutPbId)
              .findFirst();

          final localExercise = await isar.exercises
              .filter()
              .pocketbaseIdEqualTo(exercisePbId)
              .findFirst();

          if (localWorkout != null && localExercise != null) {
            // Check if this junction already exists locally
            final existingJunction = await isar.workoutExercises
                .filter()
                .workout((q) => q.idEqualTo(localWorkout.id))
                .and()
                .exercise((q) => q.idEqualTo(localExercise.id))
                .findFirst();

            if (existingJunction == null) {
              // Create new junction
              final junction = WorkoutExercises(
                sets: sets,
                reps: reps,
                pocketbaseId: record.id,
                needSync: false,
              );

              junction.workout.value = localWorkout;
              junction.exercise.value = localExercise;

              await isar.workoutExercises.put(junction);
              await junction.workout.save();
              await junction.exercise.save();
            } else {
              // Update existing junction if cloud is newer
              final cloudUpdated = DateTime.tryParse(
                record.data['updated'] ?? '',
              );
              if (cloudUpdated != null &&
                  existingJunction.updatedAt.isBefore(cloudUpdated)) {
                existingJunction.sets = sets;
                existingJunction.reps = reps;
                existingJunction.pocketbaseId = record.id;
                existingJunction.needSync = false;
                existingJunction.updatedAt = cloudUpdated;

                await isar.workoutExercises.put(existingJunction);
              }
            }
          }
        }
      });
    } catch (e) {
      // Continue even if workout_exercises sync fails
      print('Failed to sync workout_exercises: $e');
    }
  }
}
