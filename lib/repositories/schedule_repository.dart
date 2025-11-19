import 'package:isar/isar.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/services/auth_service.dart';
import 'package:tracks/utils/consts.dart';

class ScheduleRepository {
  final Isar isar;
  final PocketBase pb;
  final AuthService authService;

  ScheduleRepository(this.isar, this.pb, this.authService);

  IsarCollection<Schedule> get collection {
    return isar.schedules;
  }

  Stream<List<Schedule>> watchAllSchedules() {
    return isar.schedules.where().watch(fireImmediately: true);
  }

  /// Get schedules for a specific date
  Future<List<Schedule>> getSchedulesForDate(DateTime date) async {
    final allSchedules = await isar.schedules.where().findAll();
    final matchingSchedules = <Schedule>[];

    for (final schedule in allSchedules) {
      if (isScheduleActiveOnDate(schedule, date)) {
        matchingSchedules.add(schedule);
      }
    }

    return matchingSchedules;
  }

  /// Watch schedules for a specific date
  Stream<List<Schedule>> watchSchedulesForDate(DateTime date) {
    return isar.schedules.where().watch(fireImmediately: true).map((schedules) {
      return schedules.where((s) => isScheduleActiveOnDate(s, date)).toList();
    });
  }

  Future<void> createSchedule({required Schedule schedule}) async {
    schedule.needSync = true;

    await isar.writeTxn(() async {
      await isar.schedules.put(schedule);
      await schedule.workout.save();
    });

    if (authService.isSyncEnabled) {
      await _uploadScheduleToCloud(schedule);
    }
  }

  Future<void> updateSchedule({required Schedule schedule}) async {
    // Mark as needing sync if cloud ID exists
    if (schedule.pocketbaseId != null) {
      schedule.needSync = true;
    }

    schedule.updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.schedules.put(schedule);
      await schedule.workout.save();
    });

    // Sync to cloud if enabled
    if (authService.isSyncEnabled) {
      if (schedule.pocketbaseId != null) {
        await _updateScheduleOnCloud(schedule);
      } else {
        await _uploadScheduleToCloud(schedule);
      }
    }
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    await isar.writeTxn(() async {
      await isar.schedules.delete(schedule.id);
    });

    if (authService.isSyncEnabled && schedule.pocketbaseId != null) {
      try {
        await pb
            .collection(PBCollections.schedules.value)
            .delete(schedule.pocketbaseId!);
      } catch (e) {
        print('Failed to delete schedule from cloud: $e');
        // Already deleted locally, cloud deletion failure is acceptable
      }
    }
  }

  // --- SYNC LOGIC ---

  /// Check if a schedule is active on a given date
  bool isScheduleActiveOnDate(Schedule schedule, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    switch (schedule.recurrenceType) {
      case RecurrenceType.daily:
        if (schedule.dailyWeekday.isEmpty) return false;

        final weekday = dateTimeWeekdayToWeekday(date.weekday);
        return schedule.dailyWeekday.contains(weekday);

      case RecurrenceType.once:
        final onceDate = schedule.selectedDates.first;
        final scheduleDate = DateTime(
          onceDate.year,
          onceDate.month,
          onceDate.day,
        );

        return targetDate == scheduleDate;

      case RecurrenceType.monthly:
        return schedule.selectedDates.any((selectedDate) {
          final selected = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
          return selected == targetDate;
        });
    }
  }

  /// Convert DateTime.weekday (1-7, Monday-Sunday) to Weekday enum
  Weekday dateTimeWeekdayToWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return Weekday.monday;
      case DateTime.tuesday:
        return Weekday.tuesday;
      case DateTime.wednesday:
        return Weekday.wednesday;
      case DateTime.thursday:
        return Weekday.thursday;
      case DateTime.friday:
        return Weekday.friday;
      case DateTime.saturday:
        return Weekday.saturday;
      case DateTime.sunday:
        return Weekday.sunday;
      default:
        throw ArgumentError('Invalid weekday: $weekday');
    }
  }

  Future<void> _uploadScheduleToCloud(Schedule schedule) async {
    if (!authService.isSyncEnabled) return;

    try {
      await schedule.workout.load();
      final workout = schedule.workout.value;

      if (workout?.pocketbaseId == null) {
        print('Cannot upload schedule: workout not synced to cloud');
        return;
      }

      final record = await pb
          .collection(PBCollections.schedules.value)
          .create(
            body: {
              'user': authService.currentUser?['id'],
              'workout': workout!.pocketbaseId,
              'start_time': schedule.startTime.toIso8601String(),
              'planned_duration': schedule.plannedDuration,
              'duration_alert': schedule.durationAlert,
              'recurrence_type': schedule.recurrenceType.name,
              'daily_weekday': schedule.dailyWeekday
                  .map((w) => w.name)
                  .toList(),
              'selected_dates': schedule.selectedDates
                  .map((d) => d.toIso8601String())
                  .toList(),
            },
          );

      schedule.pocketbaseId = record.id;
      schedule.needSync = false;

      await isar.writeTxn(() async {
        await isar.schedules.put(schedule);
      });
    } catch (e) {
      print('Failed to upload schedule to cloud: $e');
      // Remains marked as needSync = true
    }
  }

  Future<void> _updateScheduleOnCloud(Schedule schedule) async {
    if (!authService.isSyncEnabled) return;

    try {
      await schedule.workout.load();
      final workout = schedule.workout.value;

      if (workout?.pocketbaseId == null) {
        print('Cannot update schedule: workout not synced to cloud');
        return;
      }

      await pb
          .collection(PBCollections.schedules.value)
          .update(
            schedule.pocketbaseId!,
            body: {
              'user': authService.currentUser?['id'],
              'workout': workout!.pocketbaseId,
              'start_time': schedule.startTime.toIso8601String(),
              'planned_duration': schedule.plannedDuration,
              'duration_alert': schedule.durationAlert,
              'recurrence_type': schedule.recurrenceType.name,
              'daily_weekday': schedule.dailyWeekday
                  .map((w) => w.name)
                  .toList(),
              'selected_dates': schedule.selectedDates
                  .map((d) => d.toIso8601String())
                  .toList(),
            },
          );

      schedule.needSync = false;

      await isar.writeTxn(() async {
        await isar.schedules.put(schedule);
      });
    } catch (e) {
      print('Failed to update schedule on cloud: $e');
      // Remains marked as needSync = true
    }
  }

  Future<void> performInitialSync() async {
    if (!authService.isSyncEnabled) return;

    // 1. Upload local-only to cloud
    await _uploadLocalSchedules();

    // 2. Download and merge cloud schedules
    await _downloadAndMergeCloudSchedules();
  }

  Future<void> _uploadLocalSchedules() async {
    final localSchedules = await isar.schedules
        .filter()
        .pocketbaseIdIsNull()
        .findAll();

    for (final schedule in localSchedules) {
      await _uploadScheduleToCloud(schedule);
    }
  }

  /// Download cloud schedules and merge with local data
  Future<void> _downloadAndMergeCloudSchedules() async {
    try {
      // Fetch all cloud schedules
      final pbRecords = await pb
          .collection(PBCollections.schedules.value)
          .getFullList(expand: 'workout');

      final List<Schedule> schedulesToSave = [];

      // Process each cloud schedule
      for (final record in pbRecords) {
        final exists = await isar.schedules
            .filter()
            .pocketbaseIdEqualTo(record.id)
            .findFirst();

        if (exists == null) {
          // New schedule from cloud - insert it
          await _insertNewScheduleFromCloud(record, schedulesToSave);
        } else {
          // Schedule exists locally - check for updates
          await _updateExistingScheduleFromCloud(
            record,
            exists,
            schedulesToSave,
          );
        }
      }

      // Save all changes in a single transaction
      if (schedulesToSave.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final schedule in schedulesToSave) {
            await isar.schedules.put(schedule);
            await schedule.workout.save();
          }
        });
      }
    } catch (e) {
      print('Failed to download and merge cloud schedules: $e');
      rethrow;
    }
  }

  /// Insert a new schedule from cloud that doesn't exist locally
  Future<void> _insertNewScheduleFromCloud(
    dynamic record,
    List<Schedule> schedulesToSave,
  ) async {
    // Find the workout by pocketbaseId
    final workoutPbId = record.data['workout'] as String?;
    if (workoutPbId == null) return;

    final workout = await isar.workouts
        .filter()
        .pocketbaseIdEqualTo(workoutPbId)
        .findFirst();

    if (workout == null) {
      print('Cannot create schedule: workout not found locally');
      return;
    }

    final schedule =
        Schedule(
            startTime: DateTime.parse(
              record.data['start_time'] ?? DateTime.now().toIso8601String(),
            ),
            plannedDuration:
                (record.data['planned_duration'] as num?)?.toInt() ?? 30,
            durationAlert: record.data['duration_alert'] ?? false,
            recurrenceType: _parseRecurrenceType(
              record.data['recurrence_type'],
            ),
            needSync: false,
          )
          ..pocketbaseId = record.id
          ..createdAt =
              DateTime.tryParse(record.data['created'] ?? '') ?? DateTime.now()
          ..updatedAt =
              DateTime.tryParse(record.data['updated'] ?? '') ?? DateTime.now()
          ..dailyWeekday = _parseWeekdays(record.data['daily_weekday'])
          ..selectedDates = _parseDates(record.data['selected_dates'])
          ..workout.value = workout;

    schedulesToSave.add(schedule);
  }

  /// Update an existing schedule from cloud if cloud version is newer
  Future<void> _updateExistingScheduleFromCloud(
    dynamic record,
    Schedule exists,
    List<Schedule> schedulesToSave,
  ) async {
    final cloudLastUpdated = DateTime.tryParse(record.data['updated'] ?? '');

    if (cloudLastUpdated == null ||
        !exists.updatedAt.isBefore(cloudLastUpdated)) {
      return; // Local version is newer or same, skip
    }

    // Find the workout by pocketbaseId
    final workoutPbId = record.data['workout'] as String?;
    if (workoutPbId == null) return;

    final workout = await isar.workouts
        .filter()
        .pocketbaseIdEqualTo(workoutPbId)
        .findFirst();

    if (workout == null) {
      print('Cannot update schedule: workout not found locally');
      return;
    }

    // Update schedule fields
    exists
      ..startTime = DateTime.parse(
        record.data['start_time'] ?? exists.startTime.toIso8601String(),
      )
      ..plannedDuration =
          (record.data['planned_duration'] as num?)?.toInt() ??
          exists.plannedDuration
      ..durationAlert = record.data['duration_alert'] ?? exists.durationAlert
      ..recurrenceType = _parseRecurrenceType(record.data['recurrence_type'])
      ..dailyWeekday = _parseWeekdays(record.data['daily_weekday'])
      ..selectedDates = _parseDates(record.data['selected_dates'])
      ..updatedAt = cloudLastUpdated
      ..workout.value = workout;

    schedulesToSave.add(exists);
  }

  RecurrenceType _parseRecurrenceType(dynamic value) {
    if (value == null) return RecurrenceType.once;

    switch (value.toString().toLowerCase()) {
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

  List<Weekday> _parseWeekdays(dynamic value) {
    if (value == null || value is! List) return [];

    return value
        .map<Weekday?>((w) {
          switch (w.toString().toLowerCase()) {
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
        })
        .whereType<Weekday>()
        .toList();
  }

  List<DateTime> _parseDates(dynamic value) {
    if (value == null || value is! List) return [];

    return value
        .map<DateTime?>((d) => DateTime.tryParse(d.toString()))
        .whereType<DateTime>()
        .toList();
  }
}
