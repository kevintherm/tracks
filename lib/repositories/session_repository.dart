import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/models/session_exercise.dart';
import 'package:tracks/models/session_set.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/utils/consts.dart';

class SessionExerciseData {
  final SessionExercise sessionExercise;
  final List<SessionSet> sets;

  SessionExerciseData({required this.sessionExercise, required this.sets});
}

class SessionRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;

  SessionRepository(this.isar, this.pb, this.authService);

  IsarCollection<Session> get collection {
    return isar.sessions;
  }

  Stream<List<Session>> watchAllSessions() {
    return isar.sessions.where().sortByStartDesc().watch(fireImmediately: true);
  }

  Future<List<SessionExercise>> getSessionExercisesForExercise(
    int exerciseId,
  ) async {
    final sessionExercises = await isar.sessionExercises
        .filter()
        .exercise((q) => q.idEqualTo(exerciseId))
        .findAll();

    for (final se in sessionExercises) {
      await se.session.load();
    }

    final valid = sessionExercises
        .where((se) => se.session.value != null)
        .toList();

    valid.sort(
      (a, b) => b.session.value!.start.compareTo(a.session.value!.start),
    );

    return valid;
  }

  Future<void> createSession({
    required Session session,
    required List<SessionExerciseData> exercises,
  }) async {
    session.needSync = true;

    try {
      await isar.writeTxn(() async {
        await isar.sessions.put(session);
        await session.workout.save();

        for (final data in exercises) {
          final se = data.sessionExercise;
          se.session.value = session;
          se.needSync = true;
          await isar.sessionExercises.put(se);
          await se.exercise.save();
          await se.session.save();

          for (final set in data.sets) {
            set.sessionExercise.value = se;
            set.needSync = true;
            await isar.sessionSets.put(set);
            await set.sessionExercise.save();
          }
        }
      });
    } catch (e) {
      log('Failed to create session, $e');
    }

    if (authService.isSyncEnabled) {
      await _uploadSessionToCloud(session);
    }
  }

  Future<void> updateSession(Session session) async {
    if (session.pocketbaseId != null) {
      session.needSync = true;
    }
    session.updated = DateTime.now();

    await isar.writeTxn(() async {
      await isar.sessions.put(session);
      await session.workout.save();
    });

    if (authService.isSyncEnabled) {
      if (session.pocketbaseId != null) {
        await _updateSessionOnCloud(session);
      } else {
        await _uploadSessionToCloud(session);
      }
    }
  }

  Future<void> addExercisesToSession({
    required Session session,
    required List<SessionExerciseData> exercises,
  }) async {
    session.updated = DateTime.now();
    if (session.pocketbaseId != null) {
      session.needSync = true;
    }

    await isar.writeTxn(() async {
      await isar.sessions.put(session);

      for (final data in exercises) {
        final se = data.sessionExercise;
        se.session.value = session;
        se.needSync = true;
        await isar.sessionExercises.put(se);
        await se.exercise.save();
        await se.session.save();

        for (final set in data.sets) {
          set.sessionExercise.value = se;
          set.needSync = true;
          await isar.sessionSets.put(set);
          await set.sessionExercise.save();
        }
      }
    });

    if (authService.isSyncEnabled) {
      if (session.pocketbaseId != null) {
        for (final data in exercises) {
          await _uploadSessionExerciseToCloud(
            data.sessionExercise,
            session.pocketbaseId!,
          );
        }
        await _updateSessionOnCloud(session);
      } else {
        await _uploadSessionToCloud(session);
      }
    }
  }

  Future<void> deleteSession(Session session) async {
    await isar.writeTxn(() async {
      // Delete sets
      final exercises = await isar.sessionExercises
          .filter()
          .session((q) => q.idEqualTo(session.id))
          .findAll();

      for (final ex in exercises) {
        await isar.sessionSets
            .filter()
            .sessionExercise((q) => q.idEqualTo(ex.id))
            .deleteAll();
      }

      // Delete exercises
      await isar.sessionExercises
          .filter()
          .session((q) => q.idEqualTo(session.id))
          .deleteAll();

      // Delete session
      await isar.sessions.delete(session.id);
    });

    if (authService.isSyncEnabled && session.pocketbaseId != null) {
      try {
        await pb
            .collection(PBCollections.sessions.value)
            .delete(session.pocketbaseId!);
      } catch (e) {
        print('Failed to delete session from cloud: $e');
      }
    }
  }

  // --- SYNC LOGIC ---

  Future<void> performInitialSync() async {
    if (!authService.isSyncEnabled) return;

    await _uploadLocalSessions();
    await _downloadAndMergeCloudSessions();
  }

  Future<void> _uploadLocalSessions() async {
    final localSessions = await isar.sessions
        .filter()
        .pocketbaseIdIsNull()
        .findAll();

    for (final session in localSessions) {
      await _uploadSessionToCloud(session);
    }
  }

  Future<void> _uploadSessionToCloud(Session session) async {
    if (!authService.isSyncEnabled) return;

    try {
      await session.workout.load();
      final workout = session.workout.value;

      if (workout?.pocketbaseId == null) {
        print('Cannot upload session: workout not synced to cloud');
        return;
      }

      // 1. Upload Session
      final record = await pb
          .collection(PBCollections.sessions.value)
          .create(
            body: {
              'user': authService.currentUser?['id'],
              'workout': workout!.pocketbaseId,
              'start': session.start.toIso8601String(),
              'end': session.end?.toIso8601String(),
            },
          );

      session.pocketbaseId = record.id;
      session.needSync = false;

      await isar.writeTxn(() async {
        await isar.sessions.put(session);
      });

      // 2. Upload Exercises
      final exercises = await isar.sessionExercises
          .filter()
          .session((q) => q.idEqualTo(session.id))
          .findAll();

      for (final ex in exercises) {
        await _uploadSessionExerciseToCloud(ex, session.pocketbaseId!);
      }
    } catch (e) {
      print('Failed to upload session to cloud: $e');
    }
  }

  Future<void> _updateSessionOnCloud(Session session) async {
    if (!authService.isSyncEnabled) return;

    try {
      await session.workout.load();
      final workout = session.workout.value;

      if (workout?.pocketbaseId == null) {
        print('Cannot update session: workout not synced to cloud');
        return;
      }

      await pb
          .collection(PBCollections.sessions.value)
          .update(
            session.pocketbaseId!,
            body: {
              'user': authService.currentUser?['id'],
              'workout': workout!.pocketbaseId,
              'start': session.start.toIso8601String(),
              'end': session.end?.toIso8601String(),
            },
          );

      session.needSync = false;

      await isar.writeTxn(() async {
        await isar.sessions.put(session);
      });
    } catch (e) {
      print('Failed to update session on cloud: $e');
    }
  }

  Future<void> _uploadSessionExerciseToCloud(
    SessionExercise exercise,
    String sessionPbId,
  ) async {
    try {
      await exercise.exercise.load();
      final exerciseDef = exercise.exercise.value;

      if (exerciseDef?.pocketbaseId == null) {
        print('Cannot upload session exercise: exercise definition not synced');
        return;
      }

      final record = await pb
          .collection(PBCollections.sessionExercises.value)
          .create(
            body: {
              'session': sessionPbId,
              'exercise': exerciseDef!.pocketbaseId,
              'exercise_name': exercise.exerciseName,
              'order': exercise.order,
            },
          );

      exercise.pocketbaseId = record.id;
      exercise.needSync = false;

      await isar.writeTxn(() async {
        await isar.sessionExercises.put(exercise);
      });

      // 3. Upload Sets
      final sets = await isar.sessionSets
          .filter()
          .sessionExercise((q) => q.idEqualTo(exercise.id))
          .findAll();

      for (final set in sets) {
        await _uploadSessionSetToCloud(set, exercise.pocketbaseId!);
      }
    } catch (e) {
      print('Failed to upload session exercise: $e');
    }
  }

  Future<void> _uploadSessionSetToCloud(
    SessionSet set,
    String sessionExercisePbId,
  ) async {
    try {
      final record = await pb
          .collection(PBCollections.sessionSets.value)
          .create(
            body: {
              'session_exercise': sessionExercisePbId,
              'weight': set.weight,
              'reps': set.reps,
              'duration': set.duration,
              'effort_rate': set.effortRate,
              'fail_on_rep': set.failOnRep,
              'note': set.note,
            },
          );

      set.pocketbaseId = record.id;
      set.needSync = false;

      await isar.writeTxn(() async {
        await isar.sessionSets.put(set);
      });
    } catch (e) {
      print('Failed to upload session set: $e');
    }
  }

  Future<void> _downloadAndMergeCloudSessions() async {
    try {
      // Fetch all cloud sessions with nested relations
      // Note: PocketBase expand syntax might vary, assuming standard relation expansion
      final pbRecords = await pb
          .collection(PBCollections.sessions.value)
          .getFullList(
            expand:
                'workout,session_exercises(session).exercise,session_exercises(session).session_sets(session_exercise)',
          );

      for (final record in pbRecords) {
        await _processCloudSession(record);
      }
    } catch (e) {
      print('Failed to download cloud sessions: $e');
    }
  }

  Future<void> _processCloudSession(RecordModel record) async {
    final workoutPbId = record.data['workout'] as String?;
    if (workoutPbId == null) return;

    final workout = await isar.workouts
        .filter()
        .pocketbaseIdEqualTo(workoutPbId)
        .findFirst();

    if (workout == null) return;

    // Check if session exists
    var session = await isar.sessions
        .filter()
        .pocketbaseIdEqualTo(record.id)
        .findFirst();

    final start = DateTime.parse(record.data['start']);
    final end = DateTime.parse(record.data['end']);
    final created = DateTime.parse(record.created);
    final updated = DateTime.parse(record.updated);

    await isar.writeTxn(() async {
      if (session == null) {
        session = Session(
          start: start,
          end: end,
          pocketbaseId: record.id,
          needSync: false,
        );
        session!.created = created;
        session!.updated = updated;
        session!.workout.value = workout;
        await isar.sessions.put(session!);
        await session!.workout.save();
      } else {
        // Update if cloud is newer
        if (updated.isAfter(session!.updated)) {
          session!.start = start;
          session!.end = end;
          session!.updated = updated;
          session!.workout.value = workout;
          await isar.sessions.put(session!);
          await session!.workout.save();
        }
      }
    });

    // Process Exercises
    final exercisesData = record.expand['session_exercises(session)'] ?? [];
    for (final exRecord in exercisesData) {
      await _processCloudSessionExercise(exRecord, session!);
    }
  }

  Future<void> _processCloudSessionExercise(
    RecordModel record,
    Session session,
  ) async {
    final exercisePbId = record.data['exercise'] as String?;
    if (exercisePbId == null) return;

    final exerciseDef = await isar.exercises
        .filter()
        .pocketbaseIdEqualTo(exercisePbId)
        .findFirst();

    if (exerciseDef == null) return;

    var sessionExercise = await isar.sessionExercises
        .filter()
        .pocketbaseIdEqualTo(record.id)
        .findFirst();

    await isar.writeTxn(() async {
      if (sessionExercise == null) {
        sessionExercise = SessionExercise(
          exerciseName: record.data['exercise_name'] ?? '',
          order: record.data['order'] ?? 0,
          needSync: false,
        );
        sessionExercise!.pocketbaseId = record.id;
        sessionExercise!.session.value = session;
        sessionExercise!.exercise.value = exerciseDef;
        await isar.sessionExercises.put(sessionExercise!);
        await sessionExercise!.session.save();
        await sessionExercise!.exercise.save();
      } else {
        // Update logic if needed
        sessionExercise!.exerciseName = record.data['exercise_name'] ?? '';
        sessionExercise!.order = record.data['order'] ?? 0;
        sessionExercise!.session.value = session;
        sessionExercise!.exercise.value = exerciseDef;
        await isar.sessionExercises.put(sessionExercise!);
      }
    });

    // Process Sets
    final setsData = record.expand['session_sets(session_exercise)'] ?? [];
    for (final setRecord in setsData) {
      await _processCloudSessionSet(setRecord, sessionExercise!);
    }
  }

  Future<void> _processCloudSessionSet(
    RecordModel record,
    SessionExercise sessionExercise,
  ) async {
    var sessionSet = await isar.sessionSets
        .filter()
        .pocketbaseIdEqualTo(record.id)
        .findFirst();

    await isar.writeTxn(() async {
      if (sessionSet == null) {
        sessionSet = SessionSet(
          weight: (record.data['weight'] as num).toDouble(),
          reps: record.data['reps'] as int,
          duration: record.data['duration'] as int,
          effortRate: record.data['effort_rate'] as int,
          failOnRep: record.data['fail_on_rep'] as int?,
          note: record.data['note'] as String?,
          needSync: false,
        );
        sessionSet!.pocketbaseId = record.id;
        sessionSet!.sessionExercise.value = sessionExercise;
        await isar.sessionSets.put(sessionSet!);
        await sessionSet!.sessionExercise.save();
      } else {
        // Update logic
        sessionSet!.weight = (record.data['weight'] as num).toDouble();
        sessionSet!.reps = record.data['reps'] as int;
        sessionSet!.duration = record.data['duration'] as int;
        sessionSet!.effortRate = record.data['effort_rate'] as int;
        sessionSet!.failOnRep = record.data['fail_on_rep'] as int?;
        sessionSet!.note = record.data['note'] as String?;
        await isar.sessionSets.put(sessionSet!);
      }
    });
  }
}
