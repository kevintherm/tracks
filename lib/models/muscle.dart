import 'package:isar/isar.dart';

part 'muscle.g.dart';

@collection
class Muscle {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  late String name;
  late String? description;
  List<String> thumbnails = [];
  List<String> pendingThumbnailPaths = [];

  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  ({bool pending, List<String> items}) get safeThumbnails =>
      pendingThumbnailPaths.isNotEmpty
      ? (pending: true, items: pendingThumbnailPaths)
      : (pending: false, items: thumbnails);

  Muscle({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
    this.pocketbaseId,
    this.needSync = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
