import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

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

  Future<void> createWorkout(
    Workout workout, {
    required Map<int, WorkoutConfig>
    exercises, // Map of exerciseId -> sets, reps
  }) async {
    if (workout.thumbnailLocal != null) {
      try {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: workout.thumbnailLocal!,
          directory: 'workouts',
          syncEnabled: false,
        );

        workout.thumbnailLocal = imageResult['localPath'];
      } catch (e) {
        workout.thumbnailLocal = null;
      }
    }

    await isar.writeTxn(() async {
      await isar.workouts.put(workout);

      // Create junction table entries if exercises provided
      if (exercises.isNotEmpty) {
        for (final entry in exercises.entries) {
          final exerciseId = entry.key;
          final sets = entry.value.sets;
          final reps = entry.value.reps;

          final exercise = await isar.exercises.get(exerciseId);

          if (exercise != null) {
            final workoutExercise = WorkoutExercises(sets: sets, reps: reps);

            workoutExercise.workout.value = workout;
            workoutExercise.exercise.value = exercise;

            await isar.workoutExercises.put(workoutExercise);
            await workoutExercise.workout.save();
            await workoutExercise.exercise.save();
          }
        }
      }
    });

    if (authService.isSyncEnabled) {
      _syncWorkoutToCloud(workout);
    }
  }

  Future<void> updateWorkout(
    Workout workout, {
    Map<int, WorkoutConfig>? exercises, // Map of exerciseId -> sets, reps
  }) async {
    // Get old workout to compare
    final oldWorkout = await isar.workouts.get(workout.id);

    // Handle thumbnail update if needed
    if (workout.thumbnailLocal != null) {
      final isNewImage = oldWorkout?.thumbnailLocal != workout.thumbnailLocal;

      if (isNewImage) {
        try {
          // Delete old image if exists
          if (oldWorkout?.thumbnailLocal != null) {
            await imageStorageService.deleteImage(
              localPath: oldWorkout!.thumbnailLocal,
              collection: PBCollections.workouts.value,
              recordId: oldWorkout.pocketbaseId,
              fieldName: 'thumbnail',
              syncEnabled: false,
            );
          }

          // Save new image to local storage
          final imageResult = await imageStorageService.saveImage(
            sourcePath: workout.thumbnailLocal!,
            directory: 'workouts',
            syncEnabled: false,
          );

          workout.thumbnailLocal = imageResult['localPath'];
        } catch (e) {
          // Keep old thumbnail path if new one fails
          if (oldWorkout?.thumbnailLocal != null) {
            workout.thumbnailLocal = oldWorkout!.thumbnailLocal;
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

      // Update exercise relationships if provided
      if (exercises != null) {
        // Delete all existing junction entries for this workout
        final existingJunctions = await isar.workoutExercises
            .filter()
            .workout((q) => q.idEqualTo(workout.id))
            .findAll();

        for (final junction in existingJunctions) {
          await isar.workoutExercises.delete(junction.id);
        }

        // Create new junction entries
        if (exercises.isNotEmpty) {
          for (final entry in exercises.entries) {
            final exerciseId = entry.key;
            final sets = entry.value.sets;
            final reps = entry.value.reps;

            final exercise = await isar.exercises.get(exerciseId);
            if (exercise != null) {
              final workoutExercise = WorkoutExercises(
                sets: sets,
                reps: reps,
              );

              workoutExercise.workout.value = workout;
              workoutExercise.exercise.value = exercise;

              await isar.workoutExercises.put(workoutExercise);
              await workoutExercise.workout.save();
              await workoutExercise.exercise.save();
            }
          }
        }
      }
    });

    // Sync to cloud if enabled
    if (authService.isSyncEnabled) {
      if (workout.pocketbaseId != null) {
        await _updateWorkoutOnCloud(workout);
      } else {
        await _syncWorkoutToCloud(workout);
      }
    }
  }

  Future<void> deleteWorkout(Workout workout) async {
    if (workout.thumbnailLocal != null) {
      try {
        await imageStorageService.deleteImage(
          localPath: workout.thumbnailLocal,
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
  Future<void> _syncWorkoutToCloud(Workout workout) async {
    try {
      // Get exercises from junction table
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

      // Create workout_exercises junction records in cloud
      if (junctions.isNotEmpty) {
        for (final junction in junctions) {
          await junction.exercise.load();
          final exercise = junction.exercise.value;
          
          if (exercise?.pocketbaseId != null) {
            await pb
                .collection(PBCollections.workoutExercises.value)
                .create(
                  body: {
                    'workout': record.id,
                    'exercise': exercise!.pocketbaseId,
                    'reps': junction.reps,
                    'sets': junction.sets,
                  },
                );
          }
        }
      }

      if (workout.thumbnailLocal != null) {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: workout.thumbnailLocal!,
          directory: 'workouts',
          collection: PBCollections.workouts.value,
          pbRecord: record,
          fieldName: 'thumbnail',
          syncEnabled: true,
        );

        workout.thumbnailCloud = imageResult['cloudUrl'];
      }

      workout.pocketbaseId = record.id;
      workout.needSync = false;

      await isar.writeTxn(() async {
        await isar.workouts.put(workout);
      });
    } catch (e) {
      // Workout remains marked as needsSync = true
    }
  }

  // Update an existing workout on the cloud
  Future<void> _updateWorkoutOnCloud(Workout workout) async {
    try {
      // Get exercises from junction table
      final junctions = await isar.workoutExercises
          .filter()
          .workout((q) => q.idEqualTo(workout.id))
          .findAll();

      // Update the workout record
      await pb
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

      // Create new workout_exercises records in cloud
      for (final junction in junctions) {
        await junction.exercise.load();
        final exercise = junction.exercise.value;
        if (exercise?.pocketbaseId != null) {
          await pb
              .collection(PBCollections.workoutExercises.value)
              .create(
                body: {
                  'workout': workout.pocketbaseId,
                  'exercise': exercise!.pocketbaseId,
                  'sets': junction.sets,
                  'reps': junction.reps,
                },
              );
        }
      }

      // Handle thumbnail sync if exists
      if (workout.thumbnailLocal != null) {
        try {
          final imageResult = await imageStorageService.saveImage(
            sourcePath: workout.thumbnailLocal!,
            directory: 'workouts',
            collection: PBCollections.workouts.value,
            pbRecord: await pb
                .collection(PBCollections.workouts.value)
                .getOne(workout.pocketbaseId!),
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          if (imageResult['cloudUrl'] != null) {
            workout.thumbnailCloud = imageResult['cloudUrl'];

            if (imageResult['localPath'] != null) {
              workout.thumbnailLocal = imageResult['localPath'];
            }
          }
        } catch (e) {
          print('Failed updating workout thumbnail to cloud: $e');
        }
      }

      // Success! Mark as synced
      workout.needSync = false;

      await isar.writeTxn(() async {
        await isar.workouts.put(workout);
      });
    } catch (e) {
      // Workout remains marked as needsSync = true
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
      await _syncWorkoutToCloud(workout);
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
            toInsert.thumbnailCloud = cloudUrl;

            final localPath = await imageStorageService.downloadImageFromCloud(
              cloudUrl: cloudUrl,
              directory: 'workouts',
            );

            if (localPath != null) {
              toInsert.thumbnailLocal = localPath;
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

          // Download image from cloud and update the thumbnailLocal
          final thumbnailField = record.data['thumbnail'];
          if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
            try {
              final cloudUrl = pb.files
                  .getUrl(record, thumbnailField)
                  .toString();

              if (exists.thumbnailCloud != cloudUrl) {
                exists.thumbnailCloud = cloudUrl;

                final localPath = await imageStorageService
                    .downloadImageFromCloud(
                      cloudUrl: cloudUrl,
                      directory: 'workouts',
                    );

                if (localPath != null) {
                  if (exists.thumbnailLocal != null) {
                    await imageStorageService.deleteLocalImage(
                      exists.thumbnailLocal!,
                    );
                  }
                  exists.thumbnailLocal = localPath;
                }
              }
            } catch (e) {
              // Keep existing thumbnailLocal if download fails
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
