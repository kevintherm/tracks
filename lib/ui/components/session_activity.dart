import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';

sealed class SessionActivity {}

class ScheduleActivity extends SessionActivity {
  final Schedule schedule;
  ScheduleActivity(this.schedule);
}

class WorkoutActivity extends SessionActivity {
  final Workout workout;
  WorkoutActivity(this.workout);
}

class ExerciseActivity extends SessionActivity {
  final Exercise exercise;
  final int sets;
  final int reps;
  ExerciseActivity(this.exercise, {this.sets = 3, this.reps = 8});
}
