import 'package:isar/isar.dart';

part 'muscle.g.dart';

@collection
class Muscle {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  late String name;
  late String? description;
  late String? thumbnail;
  late String? pendingThumbnailPath;

  Muscle({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
    this.thumbnail,
    this.pendingThumbnailPath,
    this.pocketbaseId,
  });
}
