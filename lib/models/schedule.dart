import 'package:isar/isar.dart';
import 'package:tracks/models/workout.dart';

part 'schedule.g.dart';

@collection
class Schedule {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  DateTime startTime;
  int plannedDuration; // In Minutes
  bool durationAlert;

  @enumerated
  RecurrenceType recurrenceType;

  @enumerated
  List<Weekday> dailyWeekday = [];

  List<DateTime> selectedDates = [];

  IsarLink<Workout> workout = IsarLink();

  List<DateTime> get activeSelectedDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return selectedDates.where((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly.isAfter(today) || dateOnly == today;
    }).toList()..sort((a, b) => a.compareTo(b));
  }

  Schedule({
    required this.startTime,
    this.plannedDuration = 30,
    this.durationAlert = false,
    required this.recurrenceType,
    this.needSync = true,
  }) : createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  Schedule copyWith({
    DateTime? startAt,
    DateTime? startTime,
    int? plannedDuration,
    bool? durationAlert,
    RecurrenceType? recurrenceType,
    List<Weekday>? weeklyDays,
    List<DateTime>? selectedDates,
    String? pocketbaseId,
    bool? needSync,
  }) {
    final copy =
        Schedule(
            startTime: startTime ?? this.startTime,
            plannedDuration: plannedDuration ?? this.plannedDuration,
            durationAlert: durationAlert ?? this.durationAlert,
            recurrenceType: recurrenceType ?? this.recurrenceType,
            needSync: needSync ?? this.needSync,
          )
          ..id = id
          ..pocketbaseId = pocketbaseId ?? this.pocketbaseId
          ..dailyWeekday = weeklyDays ?? dailyWeekday
          ..selectedDates = selectedDates ?? this.selectedDates
          ..createdAt = createdAt
          ..updatedAt = DateTime.now();

    // Copy workout link
    copy.workout.value = workout.value;

    return copy;
  }

  @override
  String toString() {
    return 'Schedule(id: '
        '$id, '
        'recurrence: $recurrenceType, '
        'startTime: $startTime, '
        'duration: ${plannedDuration}min, '
        'alert: $durationAlert, '
        'weekdays: $dailyWeekday, '
        'selectedDates: $selectedDates, '
        'workout: ${workout.value?.id}, '
        'needSync: $needSync, '
        'pocketbaseId: $pocketbaseId)';
  }
}

enum RecurrenceType {
  once("Applies once in the selected days."),
  daily("Applies daily with the ability to exclude specific exception days."),
  monthly("Applies monthly on the selected date or pattern.");

  final String description;

  const RecurrenceType(this.description);
}

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
