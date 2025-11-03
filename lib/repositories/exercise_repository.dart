import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';
import 'package:tracks/utils/consts.dart';

class ExerciseRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;
  late final ImageStorageService imageStorageService;

  ExerciseRepository(this.isar, this.pb, this.authService) {
    imageStorageService = ImageStorageService(pb, authService);
  }

  Stream<List<Exercise>> watchAllExercises() {
    return isar.exercises.where().watch(fireImmediately: true);
  }

  // Get muscles for a specific exercise with activation levels
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

  Future<void> createExercise(
    Exercise exercise, {
    Map<int, int>?
    muscleActivations, // Map of muscleId -> activation percentage
  }) async {
    if (exercise.thumbnailLocal != null) {
      try {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailLocal!,
          directory: 'exercises',
          syncEnabled: false,
        );

        exercise.thumbnailLocal = imageResult['localPath'];
      } catch (e) {
        exercise.thumbnailLocal = null;
      }
    }

    exercise.imported = false;

    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);

      // Create junction table entries if muscles provided
      if (muscleActivations != null && muscleActivations.isNotEmpty) {
        for (final entry in muscleActivations.entries) {
          final muscleId = entry.key;
          final activation = entry.value;

          final muscle = await isar.muscles.get(muscleId);
          if (muscle != null) {
            final exerciseMuscle = ExerciseMuscles(activation: activation);

            exerciseMuscle.exercise.value = exercise;
            exerciseMuscle.muscle.value = muscle;

            await isar.exerciseMuscles.put(exerciseMuscle);
            await exerciseMuscle.exercise.save();
            await exerciseMuscle.muscle.save();
          }
        }
      }
    });

    if (authService.isSyncEnabled) {
      _syncExerciseToCloud(exercise);
    }
  }

  Future<void> updateExercise(
    Exercise exercise, {
    Map<int, int>?
    muscleActivations, // Map of muscleId -> activation percentage
  }) async {
    // Get old exercise to compare
    final oldExercise = await isar.exercises.get(exercise.id);

    // Handle thumbnail update if needed
    // Check if this is a NEW image (path changed or doesn't point to app directory yet)
    if (exercise.thumbnailLocal != null) {
      final isNewImage = oldExercise?.thumbnailLocal != exercise.thumbnailLocal;

      if (isNewImage) {
        try {
          // Delete old image if exists
          if (oldExercise?.thumbnailLocal != null) {
            await imageStorageService.deleteImage(
              localPath: oldExercise!.thumbnailLocal,
              collection: PBCollections.exercises.value,
              recordId: oldExercise.pocketbaseId,
              fieldName: 'thumbnail',
              syncEnabled: false, // Just delete local, cloud will be replaced
            );
          }

          // Save new image to local storage
          final imageResult = await imageStorageService.saveImage(
            sourcePath: exercise.thumbnailLocal!,
            directory: 'exercises',
            syncEnabled: false, // We'll sync separately
          );

          exercise.thumbnailLocal = imageResult['localPath'];
        } catch (e) {
          // Keep old thumbnail path if new one fails
          if (oldExercise?.thumbnailLocal != null) {
            exercise.thumbnailLocal = oldExercise!.thumbnailLocal;
          }
        }
      }
    }

    // Mark as needing sync if cloud ID exists
    if (exercise.pocketbaseId != null) {
      exercise.needSync = true;
    }

    // Update local DB
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);

      // Update muscle relationships if provided
      if (muscleActivations != null) {
        // Delete all existing junction entries for this exercise
        final existingJunctions = await isar.exerciseMuscles
            .filter()
            .exercise((q) => q.idEqualTo(exercise.id))
            .findAll();

        for (final junction in existingJunctions) {
          await isar.exerciseMuscles.delete(junction.id);
        }

        // Create new junction entries
        if (muscleActivations.isNotEmpty) {
          for (final entry in muscleActivations.entries) {
            final muscleId = entry.key;
            final activation = entry.value;

            final muscle = await isar.muscles.get(muscleId);
            if (muscle != null) {
              final exerciseMuscle = ExerciseMuscles(activation: activation);

              exerciseMuscle.exercise.value = exercise;
              exerciseMuscle.muscle.value = muscle;

              await isar.exerciseMuscles.put(exerciseMuscle);
              await exerciseMuscle.exercise.save();
              await exerciseMuscle.muscle.save();
            }
          }
        }
      }
    });

    // Sync to cloud if enabled
    if (authService.isSyncEnabled) {
      if (exercise.pocketbaseId != null) {
        await _updateExerciseOnCloud(exercise);
      } else {
        // If no cloud ID yet, create it
        await _syncExerciseToCloud(exercise);
      }
    }
  }

  Future<void> deleteExercise(Exercise exercise) async {
    if (exercise.thumbnailLocal != null) {
      try {
        await imageStorageService.deleteImage(
          localPath: exercise.thumbnailLocal,
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
  Future<void> _syncExerciseToCloud(Exercise exercise) async {
    try {
      // Get muscles and activations from junction table
      final junctions = await isar.exerciseMuscles
          .filter()
          .exercise((q) => q.idEqualTo(exercise.id))
          .findAll();

      // Load muscle data for each junction
      final muscleData = <Map<String, dynamic>>[];
      for (final junction in junctions) {
        await junction.muscle.load();
        final muscle = junction.muscle.value;
        if (muscle?.pocketbaseId != null) {
          muscleData.add({
            'muscle': muscle!.pocketbaseId,
            'activation': junction.activation,
          });
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

      // Create exercise_muscles records in cloud
      if (muscleData.isNotEmpty) {
        for (final data in muscleData) {
          await pb
              .collection(PBCollections.exerciseMuscles.value)
              .create(
                body: {
                  'exercise': record.id,
                  'muscle': data['muscle'],
                  'activation': data['activation'],
                },
              );
        }
      }

      if (exercise.thumbnailLocal != null) {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailLocal!,
          directory: 'exercises',
          collection: PBCollections.exercises.value,
          pbRecord: record,
          fieldName: 'thumbnail',
          syncEnabled: true,
        );

        exercise.thumbnailCloud = imageResult['cloudUrl'];
      }

      exercise.pocketbaseId = record.id;
      exercise.needSync = false;

      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
      });
    } catch (e) {
      // Exercise remains marked as needsSync = true
      // You can run a background job later to sync all exercises where needsSync == true
    }
  }

  // Update an existing exercise on the cloud
  Future<void> _updateExerciseOnCloud(Exercise exercise) async {
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

      // Delete existing exercise_muscles records in cloud
      try {
        final existingJunctions = await pb
            .collection(PBCollections.exerciseMuscles.value)
            .getFullList(filter: 'exercise = "${exercise.pocketbaseId}"');

        for (final junction in existingJunctions) {
          await pb
              .collection(PBCollections.exerciseMuscles.value)
              .delete(junction.id);
        }
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

      // Handle thumbnail sync if exists
      if (exercise.thumbnailLocal != null) {
        try {
          // Upload the thumbnail to cloud
          final imageResult = await imageStorageService.saveImage(
            sourcePath: exercise.thumbnailLocal!,
            directory: 'exercises',
            collection: PBCollections.exercises.value,
            pbRecord: await pb
                .collection(PBCollections.exercises.value)
                .getOne(exercise.pocketbaseId!),
            fieldName: 'thumbnail',
            syncEnabled: true,
          );

          // Update cloud URL
          if (imageResult['cloudUrl'] != null) {
            exercise.thumbnailCloud = imageResult['cloudUrl'];

            // If local path changed (image was re-saved), update it
            if (imageResult['localPath'] != null) {
              exercise.thumbnailLocal = imageResult['localPath'];
            }
          }
        } catch (e) {
          print('Failed updating to cloud $e');
          // Continue with sync even if image upload fails
        }
      }

      // Success! Mark as synced
      exercise.needSync = false;

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

    // 1. Upload local-only data
    final localExercises = await isar.exercises
        .filter()
        .pocketbaseIdIsNull()
        .findAll();
    for (final exercise in localExercises) {
      await _syncExerciseToCloud(exercise);
    }

    // 2. Download cloud-only data
    final pbRecords = await pb
        .collection(PBCollections.exercises.value)
        .getFullList();
    final List<Exercise> exercisesToSave = [];

    for (final record in pbRecords) {
      // Check if we already have this exercise locally
      final exists = await isar.exercises
          .filter()
          .pocketbaseIdEqualTo(record.id)
          .findFirst();

      if (exists == null) {
        final toInsert = Exercise(
          name: record.data['name'],
          description: record.data['description'],
          caloriesBurned: record.data['calories_burned'].toDouble() ?? 0,
          pocketbaseId: record.id,
          needSync: false,
          imported: record.data['user'] != authService.currentUser?['id'],
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
              directory: 'exercises',
            );

            if (localPath != null) {
              toInsert.thumbnailLocal = localPath;
            }
          } catch (e) {
            // Continue without thumbnail
          }
        }

        exercisesToSave.add(toInsert);
      } else {
        // CONFLICT: Note exists locally and on cloud.
        // Checking: Last update
        final cloudLastUpdated = DateTime.tryParse(record.data['updated']);

        if (cloudLastUpdated != null &&
            exists.updatedAt.isBefore(cloudLastUpdated)) {
          exists
            ..name = record.data['name']
            ..description = record.data['description']
            ..caloriesBurned = record.data['calories_burned']?.toDouble()
            ..updatedAt = cloudLastUpdated;

          // Download image from cloud and update the thumbnailLocal
          final thumbnailField = record.data['thumbnail'];
          if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
            try {
              final cloudUrl = pb.files
                  .getUrl(record, thumbnailField)
                  .toString();

              // Only download if the cloud URL is different from what we have
              if (exists.thumbnailCloud != cloudUrl) {
                exists.thumbnailCloud = cloudUrl;

                final localPath = await imageStorageService
                    .downloadImageFromCloud(
                      cloudUrl: cloudUrl,
                      directory: 'exercises',
                    );

                if (localPath != null) {
                  // Delete old local image if it exists
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
          } else {
            // Cloud has no thumbnail - keep local one if it exists
            // Don't delete local thumbnail unless explicitly removed from cloud
          }

          exercisesToSave.add(exists);
        }
      }
    }

    // Save all new notes from the cloud to the local DB
    await isar.writeTxn(() async {
      await isar.exercises.putAll(exercisesToSave);
    });
  }
}
