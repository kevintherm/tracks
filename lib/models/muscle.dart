import 'package:isar/isar.dart';
import 'package:tracks/models/muscle_group.dart';

part 'muscle.g.dart';

@collection
class Muscle {
  Id id = Isar.autoIncrement;

  late String name;
  late String? description;

  final muscleGroups = IsarLinks<MuscleGroup>();

  Muscle({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
  });
}
