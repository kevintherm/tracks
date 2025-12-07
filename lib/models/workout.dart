import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout_exercises.dart';

part 'workout.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  String name;
  String? description;
  String? thumbnail;

  bool needSync;
  bool public;

  late DateTime createdAt;
  late DateTime updatedAt;

  Workout({
    required this.name,
    this.pocketbaseId,
    this.description,
    this.thumbnail,
    this.needSync = true,
    this.public = false
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  @ignore
  List<Exercise> get exercises {
    final isar = Isar.getInstance();
    if (isar == null) return [];
    
    final workoutExercises = isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(id))
        .findAllSync();
    
    return workoutExercises
        .map((we) => we.exercise.value)
        .whereType<Exercise>()
        .toList();
  }

  @ignore
  List<({Exercise exercise, int sets, int reps})> get exercisesWithPivot {
    final isar = Isar.getInstance();
    if (isar == null) return [];
    
    final workoutExercises = isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(id))
        .findAllSync();
    
    return workoutExercises
        .where((we) => we.exercise.value != null)
        .map((we) => (
          exercise: we.exercise.value!,
          sets: we.sets,
          reps: we.reps,
        ))
        .toList();
  }

  @ignore
  String get excerpt {
    return exercises.map((e) => e.name).join(', ');
  }

  @ignore
  String get thumbnailFallback {
    return thumbnail ?? exercises.first.thumbnail ?? 'assets/drawings/not-found.jpg';
  }
}
