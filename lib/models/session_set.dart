import 'package:isar/isar.dart';
import 'package:tracks/models/session_exercise.dart';

part 'session_set.g.dart';

@collection
class SessionSet {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  bool needSync;

  IsarLink<SessionExercise> sessionExercise = IsarLink();

  double weight;
  double reps;
  double duration; // In Seconds

  SessionSet({
    required this.weight,
    required this.reps,
    required this.duration,
    this.needSync = true,
  });
}
