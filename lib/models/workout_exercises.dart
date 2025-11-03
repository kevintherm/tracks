import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';

part 'workout_exercises.g.dart';

@collection
class WorkoutExercises {
  Id id = Isar.autoIncrement;

  IsarLink<Workout> workout = IsarLink();
  IsarLink<Exercise> exercise = IsarLink();

  int sets;
  int reps;

  WorkoutExercises({
    this.sets = 3,
    this.reps = 6
  });
}