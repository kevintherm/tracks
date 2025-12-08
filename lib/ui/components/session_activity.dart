import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';

sealed class SessionActivity {
  List<Exercise> getExercises();
  Workout? getWorkout();
  WorkoutExercises? getPlan(Exercise exercise);

  static SessionActivity from(dynamic value) {
    if (value is Workout) return WorkoutActivity(value);
    if (value is Schedule) return ScheduleActivity(value);
    if (value is Exercise) return ExerciseActivity(value);
    throw ArgumentError("Unsupported type");
  }
}

class ScheduleActivity extends SessionActivity {
  final Schedule schedule;
  ScheduleActivity(this.schedule);

  @override
  List<Exercise> getExercises() {
    return schedule.workout.value?.exercises ?? [];
  }

  @override
  Workout? getWorkout() {
    return schedule.workout.value;
  }

  @override
  WorkoutExercises? getPlan(Exercise exercise) {
    final workout = schedule.workout.value;
    if (workout == null) return null;

    final exerciseWithPlan = workout.exercisesWithPivot
        .where((e) => e.exercise.id == exercise.id)
        .firstOrNull;

    if (exerciseWithPlan == null) return null;

    return WorkoutExercises(
      sets: exerciseWithPlan.sets,
      reps: exerciseWithPlan.reps,
    );
  }
}

class WorkoutActivity extends SessionActivity {
  final Workout workout;
  WorkoutActivity(this.workout);

  @override
  List<Exercise> getExercises() {
    return workout.exercises;
  }

  @override
  Workout? getWorkout() {
    return workout;
  }

  @override
  WorkoutExercises? getPlan(Exercise exercise) {
    final exerciseWithPlan = workout.exercisesWithPivot
        .where((e) => e.exercise.id == exercise.id)
        .firstOrNull;

    if (exerciseWithPlan == null) return null;

    return WorkoutExercises(
      sets: exerciseWithPlan.sets,
      reps: exerciseWithPlan.reps,
    );
  }
}

class ExerciseActivity extends SessionActivity {
  final Exercise exercise;
  final int sets;
  final int reps;
  ExerciseActivity(this.exercise, {this.sets = 3, this.reps = 8});

  @override
  List<Exercise> getExercises() {
    return [exercise];
  }

  @override
  Workout? getWorkout() {
    return null;
  }

  @override
  WorkoutExercises? getPlan(Exercise exercise) {
    if (exercise.id != this.exercise.id) return null;
    return WorkoutExercises(sets: sets, reps: reps);
  }
}
