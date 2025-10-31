import 'package:isar/isar.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  late String name;
  late String? description;
  late String? thumbnailPath;
  late String? thumbnailUrl;
  late double caloriesBurned;

  bool needSync;
  bool imported;

  Exercise({
    required this.name,
    this.description,
    this.thumbnailPath,
    this.thumbnailUrl,
    required this.caloriesBurned,
    this.pocketbaseId,
    this.needSync = true,
    this.imported = false,
  });
}
