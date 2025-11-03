import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';

part 'workout_exercises.g.dart';

@collection
class WorkoutExercises {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  final workout = IsarLink<Workout>();
  final exercise = IsarLink<Exercise>();

  late int sets;
  late int reps;

  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  WorkoutExercises({
    this.sets = 3,
    this.reps = 6,
    this.pocketbaseId,
    this.needSync = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}