import 'package:isar/isar.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';

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
    
    return exerciseMuscles
        .where((em) => em.muscle.value != null)
        .map((em) => (
          muscle: em.muscle.value!,
          activation: em.activation.clamp(0, 100),
        ))
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
    this.thumbnailLocal,
    this.thumbnailCloud,
    required this.caloriesBurned,
    this.pocketbaseId,
    this.needSync = true,
    this.imported = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();
}
