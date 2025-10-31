import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/services/image_storage_service.dart';

class ExerciseRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;
  late final ImageStorageService imageStorageService;

  ExerciseRepository(this.isar, this.pb, this.authService) {
    imageStorageService = ImageStorageService(pb);
  }

  Stream<List<Exercise>> watchAllExercises() {
    return isar.exercises.where().watch(fireImmediately: true);
  }

  Future<void> createExercise(Exercise exercise) async {
    if (exercise.thumbnailPath != null) {
      try {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailPath!,
          directory: 'exercises',
          syncEnabled: false,
        );

        exercise.thumbnailPath = imageResult['localPath'];
      } catch (e) {
        print('Error saving exercise thumbnail: $e');
        exercise.thumbnailPath = null;
      }
    }

    // 2. ALWAYS save to local DB first (this is the offline-first part)
    await isar.writeTxn(() async {
      await isar.exercises.put(exercise);
    });

    // 3. Check if user wants to sync
    if (authService.isSyncEnabled) {
      // 4. Sync in the background
      _syncExerciseToCloud(exercise);
    }
  }

  // --- SYNC LOGIC ---

  // Upload a single exercise to the cloud
  Future<void> _syncExerciseToCloud(Exercise exercise) async {
    try {
      // Create the record first
      final record = await pb.collection('exercise').create(
        body: {
          'name': exercise.name,
          'description': exercise.description,
          'calories_burned': exercise.caloriesBurned,
        },
      );

      // Upload thumbnail if exists
      if (exercise.thumbnailPath != null) {
        final imageResult = await imageStorageService.saveImage(
          sourcePath: exercise.thumbnailPath!,
          directory: 'exercises',
          collection: 'exercise',
          recordId: record.id,
          fieldName: 'thumbnail',
          syncEnabled: true,
        );

        // Update exercise with cloud URL
        exercise.thumbnailUrl = imageResult['cloudUrl'];
      }

      // Success! Update local exercise with PocketBase ID and set sync to false
      exercise.pocketbaseId = record.id;
      exercise.needSync = false;

      // Write update to local DB
      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
      });
    } catch (e) {
      print("Sync failed: $e");
      // Exercise remains marked as needsSync = true
      // You can run a background job later to sync all exercises where needsSync == true
    }
  }

  // This is the complex part: The initial sync when a user logs in
  Future<void> performInitialSync() async {
    if (!authService.isSyncEnabled) return;

    // 1. Upload local-only data
    final localOnlyNotes = await isar.exercises
        .filter()
        .pocketbaseIdIsNull()
        .findAll();
    for (final note in localOnlyNotes) {
      await _syncExerciseToCloud(note);
    }

    // 2. Download cloud-only data
    final records = await pb.collection('notes').getFullList();
    final List<Exercise> notesToSave = [];

    for (final record in records) {
      // Check if we already have this note locally
      final exists = await isar.exercises
          .filter()
          .pocketbaseIdEqualTo(record.id)
          .findFirst();

      if (exists == null) {
        // Doesn't exist locally, so add it
        notesToSave.add(
          Exercise(
            name: record.data['name'],
            description: record.data['description'],
            caloriesBurned: record.data['calories_burned'],
            thumbnailPath: record.data['thumbnail_path'],
            thumbnailUrl: record.data['thumbnail_url'],
            pocketbaseId: record.id,
            needSync: false,
          ),
        );
      } else {
        // CONFLICT: Note exists locally and on cloud.
        // You must decide on a conflict resolution strategy.
        // E.g., Last-write-wins (check record.updated vs local timestamp)
      }
    }

    // Save all new notes from the cloud to the local DB
    await isar.writeTxn(() async {
      await isar.exercises.putAll(notesToSave);
    });
  }
}
