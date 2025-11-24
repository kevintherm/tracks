import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/session.dart';

part 'session_exercise.g.dart';

@collection
class SessionExercise {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  bool needSync;

  IsarLink<Session> session = IsarLink();
  IsarLink<Exercise> exercise =  IsarLink();

  String exerciseName;
  int order;

  SessionExercise({
    required this.exerciseName,
    required this.order,
    this.needSync = true,
  });
}
