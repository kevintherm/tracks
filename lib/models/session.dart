import 'package:isar/isar.dart';
import 'package:tracks/models/workout.dart';

part 'session.g.dart';

@collection
class Session {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  bool needSync = true;

  DateTime created;
  DateTime updated;

  IsarLink<Workout> workout = IsarLink();

  DateTime start;
  DateTime end;
  
  Session({
    this.pocketbaseId,
    this.needSync = true,
    required this.start,
    required this.end,
  }) : created = DateTime.now(),
       updated = DateTime.now();
}
