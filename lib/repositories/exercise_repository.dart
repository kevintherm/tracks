import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
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

  Future<void> createExercise(Exercise exercise) async {
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

    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);
    });

    if (authService.isSyncEnabled) {
      _syncExerciseToCloud(exercise);
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    // Handle thumbnail update if needed
    if (exercise.thumbnailLocal != null &&
        !exercise.thumbnailLocal!.contains('app_flutter')) {
      try {
        // Delete old image if exists
        final oldExercise = await isar.exercises.get(exercise.id);
        if (oldExercise?.thumbnailLocal != null) {
          await imageStorageService.deleteImage(
            localPath: oldExercise!.thumbnailLocal,
            collection: PBCollections.exercises.value,
            recordId: oldExercise.pocketbaseId,
            fieldName: 'thumbnail',
            syncEnabled: authService.isSyncEnabled,
          );
        }

        // Save new image
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailLocal!,
          directory: 'exercises',
          syncEnabled: false,
        );

        exercise.thumbnailLocal = imageResult['localPath'];
      } catch (e) {
        // Keep old thumbnail path if new one fails
      }
    }

    // Mark as needing sync if cloud ID exists
    if (exercise.pocketbaseId != null) {
      exercise.needSync = true;
    }

    // Update local DB
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);
    });

    // Sync to cloud if enabled
    if (authService.isSyncEnabled && exercise.pocketbaseId != null) {
      _updateExerciseOnCloud(exercise);
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
      final record = await pb
          .collection('exercises')
          .create(
            body: {
              'user': authService.currentUser?['id'],
              'name': exercise.name,
              'description': exercise.description,
              'calories_burned': exercise.caloriesBurned,
            },
          );

      if (exercise.thumbnailLocal != null) {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailLocal!,
          directory: 'exercises',
          collection: 'exercises',
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
      print('Error sync ${exercise.name}: $e');
      // Exercise remains marked as needsSync = true
      // You can run a background job later to sync all exercises where needsSync == true
    }
  }

  // Update an existing exercise on the cloud
  Future<void> _updateExerciseOnCloud(Exercise exercise) async {
    try {
      // Update the record
      final pbRecord = await pb
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

      // Upload new thumbnail if changed
      if (exercise.thumbnailLocal != null &&
          !exercise.thumbnailLocal!.contains('app_flutter')) {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailLocal!,
          directory: 'exercises',
          collection: PBCollections.exercises.value,
          pbRecord: pbRecord,
          fieldName: 'thumbnail',
          syncEnabled: true,
        );

        exercise.thumbnailLocal = imageResult['cloudUrl'];
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
      print('Synching ${exercise.name}');
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
        );

        toInsert.createdAt = DateTime.tryParse(record.data['created']) ?? DateTime.now();
        toInsert.updatedAt = DateTime.tryParse(record.data['updated']) ?? DateTime.now();

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
            print('Error downloading thumbnail for new exercise: $e');
            // Continue without thumbnail
          }
        }

        exercisesToSave.add(toInsert);
      } else {
        // CONFLICT: Note exists locally and on cloud. 
        // Checking: Last update
        final cloudLastUpdated = DateTime.tryParse(record.data['updated']);

        if (cloudLastUpdated != null && exists.updatedAt.isBefore(cloudLastUpdated)) {
          exists
            ..name = record.data['name']
            ..description = record.data['description']
            ..caloriesBurned = record.data['calories_burned']?.toDouble()
            ..updatedAt = cloudLastUpdated;

          // Download image from cloud and update the thumbnailLocal
          final thumbnailField = record.data['thumbnail'];
          if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
            try {
              final cloudUrl = pb.files.getUrl(record, thumbnailField).toString();
              exists.thumbnailCloud = cloudUrl;
              
              final localPath = await imageStorageService.downloadImageFromCloud(
                cloudUrl: cloudUrl,
                directory: 'exercises',
              );
              
              if (localPath != null) {
                // Delete old local image if it exists
                if (exists.thumbnailLocal != null) {
                  await imageStorageService.deleteLocalImage(exists.thumbnailLocal!);
                }
                exists.thumbnailLocal = localPath;
              }
            } catch (e) {
              print('Error downloading thumbnail from cloud: $e');
              // Keep existing thumbnailLocal if download fails
            }
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
