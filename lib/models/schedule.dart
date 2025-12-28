import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/workout.dart';

part 'schedule.g.dart';

@collection
class Schedule {
  Id id = Isar.autoIncrement;

  String? pocketbaseId;
  String? fromPocketBaseId;
  bool needSync;

  late DateTime createdAt;
  late DateTime updatedAt;

  DateTime startTime;
  int plannedDuration; // In Minutes
  bool durationAlert;
  bool public;
  int views;
  int copies;

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
    this.public = false,
    this.views = 0,
    this.copies = 0,
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
    int? views,
    int? copies,
    bool? needSync,
  }) {
    final copy =
        Schedule(
            startTime: startTime ?? this.startTime,
            plannedDuration: plannedDuration ?? this.plannedDuration,
            durationAlert: durationAlert ?? this.durationAlert,
            recurrenceType: recurrenceType ?? this.recurrenceType,
            needSync: needSync ?? this.needSync,
            public: public,
            views: views ?? this.views,
            copies: copies ?? this.copies,
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

  factory Schedule.fromRecord(RecordModel record) {
    final schedule = Schedule(
      startTime: DateTime.tryParse(record.data['start_time'] ?? '') ?? DateTime.now(),
      views: record.getIntValue('views'),
      copies: record.getIntValue('copies'),
      plannedDuration: record.data['planned_duration'] ?? 30,
      durationAlert: record.data['duration_alert'] ?? false,
      recurrenceType: _parseRecurrenceType(record.data['recurrence_type']),
      public: record.getBoolValue('is_public'),
      needSync: false,
    )
      ..pocketbaseId = record.id
      ..createdAt = DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now();

    // Parse daily weekday
    final dailyWeekdayData = record.data['daily_weekday'];
    if (dailyWeekdayData is List) {
      schedule.dailyWeekday = dailyWeekdayData
          .map((e) => _parseWeekday(e.toString()))
          .whereType<Weekday>()
          .toList();
    }

    // Parse selected dates
    final selectedDatesData = record.data['selected_dates'];
    if (selectedDatesData is List) {
      schedule.selectedDates = selectedDatesData
          .map((e) => DateTime.tryParse(e.toString()))
          .whereType<DateTime>()
          .toList();
    }

    // Parse expanded workout
    if (record.expand.containsKey('workout')) {
      final workoutRecords = record.expand['workout'];
      if (workoutRecords != null && workoutRecords.isNotEmpty) {
        schedule.workout.value = Workout.fromRecord(workoutRecords.first);
      }
    }

    return schedule;
  }

  Map<String, dynamic> toPayload() {
    return {
      'start_time': startTime.toIso8601String(),
      'planned_duration': plannedDuration,
      'duration_alert': durationAlert,
      'recurrence_type': _recurrenceTypeToString(recurrenceType),
      'views': views,
      'copies': copies,
      'daily_weekday': dailyWeekday.map((e) => _weekdayToString(e)).toList(),
      'selected_dates': selectedDates.map((e) => e.toIso8601String()).toList(),
    };
  }

  static RecurrenceType _parseRecurrenceType(String? value) {
    switch (value?.toLowerCase()) {
      case 'once':
        return RecurrenceType.once;
      case 'daily':
        return RecurrenceType.daily;
      case 'monthly':
        return RecurrenceType.monthly;
      default:
        return RecurrenceType.once;
    }
  }

  static String _recurrenceTypeToString(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.once:
        return 'once';
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.monthly:
        return 'monthly';
    }
  }

  static Weekday? _parseWeekday(String value) {
    switch (value.toLowerCase()) {
      case 'monday':
        return Weekday.monday;
      case 'tuesday':
        return Weekday.tuesday;
      case 'wednesday':
        return Weekday.wednesday;
      case 'thursday':
        return Weekday.thursday;
      case 'friday':
        return Weekday.friday;
      case 'saturday':
        return Weekday.saturday;
      case 'sunday':
        return Weekday.sunday;
      default:
        return null;
    }
  }

  static String _weekdayToString(Weekday weekday) {
    switch (weekday) {
      case Weekday.monday:
        return 'monday';
      case Weekday.tuesday:
        return 'tuesday';
      case Weekday.wednesday:
        return 'wednesday';
      case Weekday.thursday:
        return 'thursday';
      case Weekday.friday:
        return 'friday';
      case Weekday.saturday:
        return 'saturday';
      case Weekday.sunday:
        return 'sunday';
    }
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
