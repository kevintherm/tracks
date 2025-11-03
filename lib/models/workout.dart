import 'package:isar/isar.dart';

part 'workout.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  String name;
  String? description;
  String? thumbnailCloud;
  String? thumbnailLocal;

  bool needSync;
  bool owned;

  late DateTime createdAt;
  late DateTime updatedAt;

  Workout({
    required this.name,
    this.pocketbaseId,
    this.description,
    this.thumbnailCloud,
    this.thumbnailLocal,
    this.needSync = true,
    this.owned = true
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
