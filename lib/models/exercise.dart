import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/services/pocketbase_service.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  String? fromPocketBaseId;

  @Index()
  late String name;
  late String? description;
  late String? thumbnail;
  late String? pendingThumbnailPath;
  late double caloriesBurned;

  bool needSync;
  bool public;
  int views;
  int copies;

  late DateTime createdAt;
  late DateTime updatedAt;

  @ignore
  List<Muscle> get muscles {
    final isar = Isar.getInstance();
    if (isar == null) return [];

    final exerciseMuscles = isar.exerciseMuscles
        .filter()
        .exercise((q) => q.idEqualTo(id))
        .findAllSync();

    return exerciseMuscles
        .map((em) => em.muscle.value)
        .whereType<Muscle>()
        .toList();
  }

  @ignore
  List<({Muscle muscle, int activation})> get musclesWithActivation {
    final isar = Isar.getInstance();
    if (isar == null) return [];

    final exerciseMuscles = isar.exerciseMuscles
        .filter()
        .exercise((q) => q.idEqualTo(id))
        .findAllSync();

    exerciseMuscles.sort((a, b) => b.activation.compareTo(a.activation));

    return exerciseMuscles
        .where((em) => em.muscle.value != null)
        .map(
          (em) => (
            muscle: em.muscle.value!,
            activation: em.activation.clamp(0, 100),
          ),
        )
        .toList();
  }

  @ignore
  String get excerpt {
    return muscles.map((e) => e.name).join(', ');
  }

  @ignore
  List<Workout> get workouts {
    final isar = Isar.getInstance();
    if (isar == null) return [];

    final workoutExercises = isar.workoutExercises
        .filter()
        .exercise((q) => q.idEqualTo(id))
        .findAllSync();

    return workoutExercises
        .map((we) => we.workout.value)
        .whereType<Workout>()
        .toList();
  }

  Exercise({
    required this.name,
    this.description,
    this.thumbnail,
    this.pendingThumbnailPath,
    required this.caloriesBurned,
    this.pocketbaseId,
    this.needSync = true,
    this.public = false,
    this.views = 0,
    this.copies = 0,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  factory Exercise.fromRecord(RecordModel record) {
    final getUrl = PocketBaseService.instance.client.files.getURL;
    final exercise =
        Exercise(
            name: record.data['name'] ?? '',
            description: record.data['description'],
            caloriesBurned: (record.data['calories_burned'] ?? 0).toDouble(),
            pocketbaseId: record.id,
            views: record.data['views'] ?? 0,
            copies: record.data['copies'] ?? 0,
            needSync: false,
            public: record.data['is_public'] ?? false,
          )
          ..createdAt =
              DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

    final thumbnailField = record.data['thumbnail'];
    if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
      exercise.thumbnail = getUrl(record, thumbnailField).toString();
    }

    return exercise;
  }

  factory Exercise.fromMap(
    Map<String, dynamic> data,
    String Function(String field) getUrl,
  ) {
    final exercise =
        Exercise(
            name: data['name'] ?? '',
            description: data['description'],
            caloriesBurned: (data['calories_burned'] ?? 0).toDouble(),
            pocketbaseId: data['id'],
            views: data['views'] ?? 0,
            copies: data['copies'] ?? 0,
            needSync: false,
            public: data['is_public'] ?? false,
          )
          ..createdAt =
              DateTime.tryParse(data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(data['updated'] ?? '') ?? DateTime.now();

    final thumbnailField = data['thumbnail'];
    if (thumbnailField != null && thumbnailField.toString().isNotEmpty) {
      exercise.thumbnail = getUrl(thumbnailField);
    }

    return exercise;
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'description': description,
      'views': views,
      'copies': copies,
    };
  }

  void updateFrom(Exercise other) {
    name = other.name;
    description = other.description;
    thumbnail = other.thumbnail;
    caloriesBurned = other.caloriesBurned;
    public = other.public;
    views = other.views;
    copies = other.copies;
    caloriesBurned = other.caloriesBurned;
    public = other.public;
    pocketbaseId = other.pocketbaseId;
    needSync = other.needSync;
    updatedAt = other.updatedAt;
  }
}
