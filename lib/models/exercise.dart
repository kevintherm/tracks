import 'package:isar/isar.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? pocketbaseId;

  late String name;
  
  bool needSync;

  Exercise({
    required this.name,
    this.pocketbaseId,
    this.needSync = true,
  });
}