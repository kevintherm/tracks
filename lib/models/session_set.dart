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

  int reps;
  int? failOnRep;
  int effortRate;
  int restDuration;
  int duration; // In Seconds
  String? note;

  SessionSet({
    required this.weight,
    required this.reps,
    required this.duration,
    required this.effortRate,
    this.restDuration = 0,
    this.needSync = true,
    this.failOnRep,
    this.note,
  });
}
