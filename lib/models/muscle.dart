import 'package:isar/isar.dart';

part 'muscle.g.dart';

@collection
class Muscle {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  late String name;
  late String? description;
  late String? thumbnailCloud;
  late String? thumbnailLocal;

  Muscle({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
    this.thumbnailCloud,
    this.thumbnailLocal,
    this.pocketbaseId
  });
}
