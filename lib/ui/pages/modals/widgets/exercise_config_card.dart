import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/utils/app_colors.dart';

export 'package:tracks/ui/pages/modals/widgets/exercise_config_card.dart'
    show ExerciseConfig, ScheduleTypes;

enum ScheduleTypes { individual, dayName, day }

class ExerciseConfig {
  int sets;
  int reps;
  ScheduleTypes scheduleType;
  TimeOfDay? startTime;
  Duration plannedDuration;
  bool durationAlert;

  ExerciseConfig({
    this.sets = 3,
    this.reps = 8,
    this.scheduleType = ScheduleTypes.individual,
    this.startTime,
    this.plannedDuration = const Duration(hours: 1),
    this.durationAlert = false,
  });

  ExerciseConfig copyWith({
    int? sets,
    int? reps,
    ScheduleTypes? scheduleType,
    TimeOfDay? startTime,
    Duration? plannedDuration,
    bool? durationAlert,
  }) {
    return ExerciseConfig(
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      scheduleType: scheduleType ?? this.scheduleType,
      startTime: startTime ?? this.startTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      durationAlert: durationAlert ?? this.durationAlert,
    );
  }
}

class ExerciseConfigCard extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final int index;
  final ExerciseConfig config;
  final String selectedDayName;
  final int selectedDayNumber;
  final ValueChanged<ExerciseConfig> onConfigChanged;
  final String? imagePath;
  final String? subtitle;

  const ExerciseConfigCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.index,
    required this.config,
    required this.selectedDayName,
    required this.selectedDayNumber,
    required this.onConfigChanged,
    this.imagePath,
    this.subtitle,
  });

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: config.startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onConfigChanged(config.copyWith(startTime: picked));
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) {
      return 'Not set';
    }
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(exerciseId),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[100],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Iconsax.sort_outline,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath ?? 'assets/drawings/pushup.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              exerciseName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: const [10, 5],
                              strokeWidth: 2,
                              radius: const Radius.circular(16),
                              color: AppColors.darkSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                            ),
                            child: Text(
                              (index + 1).toString(),
                              style: GoogleFonts.inter(
                                color: AppColors.darkSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle ?? "Average of 8 sets per week",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SegmentedButton<ScheduleTypes>(
                  segments: <ButtonSegment<ScheduleTypes>>[
                    ButtonSegment<ScheduleTypes>(
                      value: ScheduleTypes.individual,
                      label: const Text('Once'),
                      icon: const Icon(MingCute.time_line),
                      tooltip: "Start this workout only on this day.",
                    ),
                    ButtonSegment<ScheduleTypes>(
                      value: ScheduleTypes.dayName,
                      label: const Text("Day"),
                      icon: const Icon(MingCute.sun_line),
                      tooltip:
                          "Start this workout every $selectedDayName of the week.",
                    ),
                    ButtonSegment<ScheduleTypes>(
                      value: ScheduleTypes.day,
                      label: const Text("Month"),
                      icon: const Icon(MingCute.calendar_line),
                      tooltip:
                          "Start this workout every ${selectedDayNumber}th of the month.",
                    ),
                  ],
                  selected: {config.scheduleType},
                  onSelectionChanged: (Set<ScheduleTypes> newSelection) {
                    if (newSelection.isNotEmpty) {
                      onConfigChanged(
                        config.copyWith(scheduleType: newSelection.first),
                      );
                    }
                  },
                  multiSelectionEnabled: false,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  title: const Text('Start Time'),
                  visualDensity: const VisualDensity(vertical: -2),
                  trailing: Pressable(
                    onTap: () => _selectStartTime(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        _formatTimeOfDay(config.startTime),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Planned Duration'),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            child: Text(
                              _formatDuration(config.plannedDuration),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: config.plannedDuration.inMinutes.toDouble(),
                        min: 15,
                        max: 180,
                        divisions: 11, // (180 - 15) / 15 = 11 steps
                        label: _formatDuration(config.plannedDuration),
                        onChanged: (value) {
                          final duration = Duration(minutes: value.round());
                          onConfigChanged(
                            config.copyWith(plannedDuration: duration),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(vertical: -2),
                  subtitle: const Text(
                    "Show an alert when a session exceed the planned duration.",
                  ),
                  title: const Text('Duration Alert'),
                  value: config.durationAlert,
                  onChanged: (value) {
                    onConfigChanged(config.copyWith(durationAlert: value));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
