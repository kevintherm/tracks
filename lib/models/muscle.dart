import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';

part 'muscle.g.dart';

@collection
class Muscle {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  String? fromPocketBaseId;

  late String name;
  late String? description;
  List<String> thumbnails = [];
  List<String> removedThumbnails = [];

  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  List<String> get safeThumbnails => thumbnails;

  Muscle({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description,
    this.pocketbaseId,
    this.needSync = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  factory Muscle.fromRecord(
    RecordModel record,
    String Function(String thumb) getUrl,
  ) {
    final muscle =
        Muscle(
            name: record.data['name'] ?? '',
            description: record.data['description'],
            pocketbaseId: record.id,
            needSync: false,
          )
          ..createdAt =
              DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

    final thumbnails = record.getListValue<String>('thumbnails');
    for (final thumb in thumbnails) {
      muscle.thumbnails.add(getUrl(thumb));
    }

    return muscle;
  }

  Map<String, dynamic> toPayload() {
    return {'name': name, 'description': description};
  }

  void updateFrom(Muscle other) {
    name = other.name;
    description = other.description;
    thumbnails = List.from(other.thumbnails);
    pocketbaseId = other.pocketbaseId;
    needSync = other.needSync;
    updatedAt = other.updatedAt;
  }
}
