import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';

class ImportService {
  final Isar isar;

  ImportService(this.isar);

  Future<void> importMuscles(List<dynamic> jsonList) async {
    await isar.writeTxn(() async {
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        if (name == null || name.isEmpty) continue;

        final existing =
            await isar.muscles.filter().nameEqualTo(name).findFirst();
        if (existing != null) continue;

        final muscle = Muscle(
          name: name,
          description: item['description'] as String?,
        );
        // Handle thumbnails if provided as list of strings
        if (item['thumbnails'] is List) {
          muscle.thumbnails = (item['thumbnails'] as List).cast<String>();
        }
        
        await isar.muscles.put(muscle);
      }
    });
  }

  Future<void> importExercises(List<dynamic> jsonList) async {
    await isar.writeTxn(() async {
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        await _importExercise(item);
      }
    });
  }

  Future<Exercise?> _importExercise(Map<String, dynamic> item) async {
    final name = item['name'] as String?;
    final caloriesBurned = item['caloriesBurned'];

    if (name == null || name.isEmpty) return null;

    var exercise = await isar.exercises.filter().nameEqualTo(name).findFirst();
    if (exercise == null) {
      exercise = Exercise(
        name: name,
        description: item['description'] as String?,
        thumbnail: item['thumbnail'] as String?,
        caloriesBurned: (caloriesBurned is num) ? caloriesBurned.toDouble() : 0.0,
      );
      await isar.exercises.put(exercise);
    }

    final musclesJson = item['muscles'];
    if (musclesJson is List) {
      for (final muscleItem in musclesJson) {
        String? muscleName;
        if (muscleItem is String) {
          muscleName = muscleItem;
        } else if (muscleItem is Map && muscleItem['name'] is String) {
          muscleName = muscleItem['name'];
        }

        if (muscleName != null && muscleName.isNotEmpty) {
          var muscle =
              await isar.muscles.filter().nameEqualTo(muscleName).findFirst();
          if (muscle == null) {
            muscle = Muscle(name: muscleName);
            await isar.muscles.put(muscle);
          }

          final existingLink = await isar.exerciseMuscles
              .filter()
              .exercise((q) => q.idEqualTo(exercise!.id))
              .muscle((q) => q.idEqualTo(muscle!.id))
              .findFirst();

          if (existingLink == null) {
            final link = ExerciseMuscles();
            link.exercise.value = exercise;
            link.muscle.value = muscle;
            await isar.exerciseMuscles.put(link);
            await link.exercise.save();
            await link.muscle.save();
          }
        }
      }
    }
    return exercise;
  }

  Future<void> importWorkouts(List<dynamic> jsonList) async {
    await isar.writeTxn(() async {
      for (final item in jsonList) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        final exercisesJson = item['exercises'];

        if (name == null || name.isEmpty) continue;
        
        // If exercises are required for a workout as per prompt:
        // "since workout must have atleast 1 exercise so validate json, check if theres exercises"
        if (exercisesJson is! List || exercisesJson.isEmpty) continue;

        var workout =
            await isar.workouts.filter().nameEqualTo(name).findFirst();
        if (workout == null) {
          workout = Workout(
            name: name,
            description: item['description'] as String?,
            thumbnail: item['thumbnail'] as String?,
          );
          await isar.workouts.put(workout);
        }

        for (var i = 0; i < exercisesJson.length; i++) {
          final exerciseItem = exercisesJson[i];
          if (exerciseItem is! Map<String, dynamic>) continue;

          final exercise = await _importExercise(exerciseItem);
          if (exercise != null) {
            final sets = exerciseItem['sets'] as int? ?? 3;
            final reps = exerciseItem['reps'] as int? ?? 10;

            // Check if this exercise is already linked to this workout to avoid duplicates
            // We can check by exercise ID and workout ID. 
            // But if we want to allow duplicates (e.g. circuit training), we might skip this check.
            // However, for import, usually we want to avoid duplicating if we run import twice.
            // Let's check if there is a link with same exercise.
            
            // Actually, if the workout already existed, we might be appending.
            // If we just created the workout, it's empty.
            
            // Let's assume we only add if not present for now to be safe.
            // Or better, if we just created the workout, we add.
            // If workout existed, we might want to skip adding exercises if they are already there?
            // The prompt says "validate exercise then add and link them to the workout".
            
            // I'll check if the specific link exists (same workout, same exercise).
            // This prevents adding the same exercise multiple times to the same workout during import.
            // If the user wants multiple same exercises, they can edit later.
            
            final existingLink = await isar.workoutExercises
                .filter()
                .workout((q) => q.idEqualTo(workout!.id))
                .exercise((q) => q.idEqualTo(exercise.id))
                .findFirst();
                
            if (existingLink == null) {
                final link = WorkoutExercises(
                  sets: sets,
                  reps: reps,
                  order: i,
                );
                link.workout.value = workout;
                link.exercise.value = exercise;
                await isar.workoutExercises.put(link);
                await link.workout.save();
                await link.exercise.save();
            }
          }
        }
      }
    });
  }
}
