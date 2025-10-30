import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/utils/app_colors.dart';

export 'package:tracks/ui/widgets/assign_schedule_config_card.dart'
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

class AssignScheduleConfigCard extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final int index;
  final ExerciseConfig config;
  final String selectedDayName;
  final int selectedDayNumber;
  final DateTime selectedDay;
  final ValueChanged<ExerciseConfig> onConfigChanged;
  final VoidCallback? onReorderTap;
  final String? imagePath;
  final String? subtitle;

  const AssignScheduleConfigCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.index,
    required this.config,
    required this.selectedDayName,
    required this.selectedDayNumber,
    required this.selectedDay,
    required this.onConfigChanged,
    this.onReorderTap,
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

  bool _isSelectedDayInPast() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    return selected.isBefore(today);
  }

  Future<void> _selectPlannedDuration(BuildContext context) async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return _DurationPickerDialog(
          initialDuration: config.plannedDuration,
        );
      },
    );

    if (picked != null) {
      onConfigChanged(config.copyWith(plannedDuration: Duration(minutes: picked)));
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
    // If the selected day is in the past and the schedule type is "Once",
    // automatically change it to "Day" (dayName)
    if (_isSelectedDayInPast() && config.scheduleType == ScheduleTypes.individual) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onConfigChanged(config.copyWith(scheduleType: ScheduleTypes.dayName));
      });
    }

    return RepaintBoundary(
      child: Container(
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
                          Pressable(
                            onTap: onReorderTap,
                            child: DottedBorder(
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
                      enabled: !_isSelectedDayInPast(),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  title: const Text('Planned Duration'),
                  visualDensity: const VisualDensity(vertical: -2),
                  trailing: Pressable(
                    onTap: () => _selectPlannedDuration(context),
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
                        _formatDuration(config.plannedDuration),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
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
      ),
    );
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const _DurationPickerDialog({
    required this.initialDuration,
  });

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int selectedMinutes;

  // Duration options from 15 to 180 minutes in 15-minute increments
  final List<int> durationOptions = List.generate(12, (index) => 15 + (index * 15));

  @override
  void initState() {
    super.initState();
    selectedMinutes = widget.initialDuration.inMinutes;
    // Ensure the selected duration is in our options list
    if (!durationOptions.contains(selectedMinutes)) {
      selectedMinutes = durationOptions.reduce((a, b) => 
        (a - selectedMinutes).abs() < (b - selectedMinutes).abs() ? a : b
      );
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Duration',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: durationOptions.length,
                itemBuilder: (context, index) {
                  final minutes = durationOptions[index];
                  final isSelected = minutes == selectedMinutes;
                  
                  return Pressable(
                    onTap: () {
                      setState(() {
                        selectedMinutes = minutes;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _formatDuration(minutes),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selectedMinutes),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
