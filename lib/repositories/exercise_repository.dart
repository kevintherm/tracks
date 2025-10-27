import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/services/auth_service.dart';

class ExerciseRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;

  ExerciseRepository(this.isar, this.pb, this.authService);

  Stream<List<Exercise>> watchAllExercises() {
    return isar.exercises.where().watch(fireImmediately: true);
  }

  // This is the key function for your flow
  Future<void> createExercise(String name) async {
    final newExercise = Exercise(name: name);

    // 1. ALWAYS save to local DB first (this is the offline-first part)
    await isar.writeTxn(() async {
      await isar.exercises.put(newExercise);
    });

    // 2. Check if user wants to sync
    if (authService.isSyncEnabled) {
      // 3. Sync in the background
      _syncNoteToCloud(newExercise);
    }
  }

  // --- SYNC LOGIC ---

  // Upload a single note
  Future<void> _syncNoteToCloud(Exercise exercise) async {
    try {
      final record = await pb
          .collection('exercise')
          .create(
            body: {
              'name': exercise.name,
              // any other fields...
            },
          );

      // Success! Update local note with PocketBase ID and set sync to false
      exercise.pocketbaseId = record.id;
      exercise.needSync = false;

      // Write update to local DB
      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
      });
    } catch (e) {
      print("Sync failed: $e");
      // Note remains marked as needsSync = true
      // You can run a background job later to sync all notes where needsSync == true
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
      await _syncNoteToCloud(note);
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
