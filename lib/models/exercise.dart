import 'package:isar/isar.dart';
import 'package:tracks/models/muscle.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  @Index()
  late String name;
  late String? description;
  late String? thumbnailLocal;
  late String? thumbnailCloud;
  late double caloriesBurned;

  bool needSync;
  bool imported;

  late DateTime createdAt;
  late DateTime updatedAt;

  final muscles = IsarLinks<Muscle>();

  Exercise({
    required this.name,
    this.description,
    this.thumbnailLocal,
    this.thumbnailCloud,
    required this.caloriesBurned,
    this.pocketbaseId,
    this.needSync = true,
    this.imported = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
