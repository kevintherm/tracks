import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/services/pocketbase_service.dart';

part 'workout.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;

  String name;
  String? description;
  String? thumbnail;
  String? pendingThumbnailPath;

  bool needSync;
  bool public;

  late DateTime createdAt;
  late DateTime updatedAt;

  Workout({
    required this.name,
    this.pocketbaseId,
    this.description,
    this.thumbnail,
    this.pendingThumbnailPath,
    this.needSync = true,
    this.public = false,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  @ignore
  List<Exercise> get exercises {
    final isar = Isar.getInstance();
    if (isar == null) return [];

    final workoutExercises = isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(id))
        .findAllSync();

    return workoutExercises
        .map((we) => we.exercise.value)
        .whereType<Exercise>()
        .toList();
  }

  @ignore
  List<({Exercise exercise, int sets, int reps})> get exercisesWithPivot {
    final isar = Isar.getInstance();
    if (isar == null) return [];

    final workoutExercises = isar.workoutExercises
        .filter()
        .workout((q) => q.idEqualTo(id))
        .findAllSync();

    return workoutExercises
        .where((we) => we.exercise.value != null)
        .map(
          (we) => (exercise: we.exercise.value!, sets: we.sets, reps: we.reps),
        )
        .toList();
  }

  @ignore
  String get excerpt {
    return exercises.map((e) => e.name).join(', ');
  }

  @ignore
  String get thumbnailFallback {
    return thumbnail ??
        exercises.first.thumbnail ??
        'assets/drawings/not-found.jpg';
  }

  factory Workout.fromRecord(RecordModel record) {
    final pb = PocketBaseService.instance.client;
    final workout =
        Workout(
            name: record.data['name'] ?? '',
            description: record.data['description'],
            pocketbaseId: record.id,
            needSync: false,
            public: record.data['is_public'] ?? false,
          )
          ..createdAt =
              DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

    final thumbnailField = record.data['thumbnail'];
    if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
      workout.thumbnail = pb.files.getURL(record, thumbnailField).toString();
    }

    return workout;
  }

  factory Workout.fromMap(
    Map<String, dynamic> data,
    String Function(String field) getUrl,
  ) {
    final workout =
        Workout(
            name: data['name'] ?? '',
            description: data['description'],
            pocketbaseId: data['id'],
            needSync: false,
            public: data['is_public'] ?? false,
          )
          ..createdAt =
              DateTime.tryParse(data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(data['updated'] ?? '') ?? DateTime.now();

    final thumbnailField = data['thumbnail'];
    if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
      workout.thumbnail = getUrl(thumbnailField);
    }

    return workout;
  }

  Map<String, dynamic> toPayload() {
    return {'name': name, 'description': description, 'is_public': public};
  }

  void updateFrom(Workout other) {
    name = other.name;
    description = other.description;
    thumbnail = other.thumbnail;
    public = other.public;
    pocketbaseId = other.pocketbaseId;
    needSync = other.needSync;
    updatedAt = other.updatedAt;
  }
}
