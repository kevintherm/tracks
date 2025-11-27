import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';

sealed class SessionActivity {
  List<Exercise> getExercises();
  Workout? getWorkout();
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
}
