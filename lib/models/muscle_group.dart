import 'package:isar/isar.dart';

part 'muscle_group.g.dart';

@collection
class MuscleGroup {
  Id id = Isar.autoIncrement;

  late String name;
  late String? thumbnailCloud;
  late String? thumbnailLocal;

  MuscleGroup({required this.name, this.thumbnailCloud, this.thumbnailLocal});
}