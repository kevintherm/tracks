import 'package:isar/isar.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/muscle.dart';

part 'exercise_muscles.g.dart';

@collection
class ExerciseMuscles {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  // Link to exercise
  final exercise = IsarLink<Exercise>();

  // Link to muscle
  final muscle = IsarLink<Muscle>();

  // Muscle activation percentage (0-100)
  late int activation;

  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  ExerciseMuscles({
    this.activation = 50,
    this.pocketbaseId,
    this.needSync = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
