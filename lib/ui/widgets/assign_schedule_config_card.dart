import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/table_calendar_compact.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';

class AssignScheduleConfigCard extends StatefulWidget {
  final String exerciseId;
  final String workoutName;
  final int index;
  final Schedule config;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelectedDateChanged;
  final VoidCallback? onReorderTap;
  final VoidCallback? onDeleteTap;
  final String? imagePath;
  final String? subtitle;

  const AssignScheduleConfigCard({
    super.key,
    required this.exerciseId,
    required this.workoutName,
    required this.index,
    required this.config,
    required this.selectedDate,
    required this.onSelectedDateChanged,
    this.onReorderTap,
    this.onDeleteTap,
    this.imagePath,
    this.subtitle,
  });

  @override
  State<AssignScheduleConfigCard> createState() =>
      _AssignScheduleConfigCardState();
}

class _AssignScheduleConfigCardState extends State<AssignScheduleConfigCard> {
  late Schedule schedule;

  late TimeOfDay startTime;
  late Duration plannedDuration;

  DateTime selectedDate = DateTime.now();

  final now = DateTime.now();

  @override
  void initState() {
    super.initState();

    schedule = widget.config;

    startTime = TimeOfDay.fromDateTime(schedule.startTime);
    plannedDuration = Duration(minutes: schedule.plannedDuration);
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (picked != null) {
      setState(() => startTime = picked);
      schedule.startTime = DateTime(
        2000,
        1,
        1,
        startTime.hour,
        startTime.minute,
      );
    }
  }

  Future<void> _selectPlannedDuration(BuildContext context) async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return _DurationPickerDialog(initialDuration: plannedDuration);
      },
    );

    if (picked != null) {
      setState(() => plannedDuration = Duration(minutes: picked));
      schedule.plannedDuration = Duration(minutes: picked).inMinutes;
    }
  }

  Future<void> _selectRecurrenceType(BuildContext context) async {
    final RecurrenceType? picked = await showDialog<RecurrenceType>(
      context: context,
      builder: (BuildContext context) {
        return _RecurrenceTypePickerDialog(
          initialRecurrenceType: schedule.recurrenceType,
          allowedTypes: RecurrenceType.values,
        );
      },
    );

    if (picked == RecurrenceType.once) {
      if (mounted) {
        final newDate = await showDatePicker(
          context: context,
          firstDate: now,
          lastDate: DateTime.utc(now.year + 1, now.month, now.day),
          initialDate: selectedDate,
        );

        if (newDate == null) {
          return;
        }

        setState(() {
          schedule.selectedDates.clear();
          schedule.selectedDates.add(newDate);
        });

        schedule.dailyWeekday.clear();
        widget.onSelectedDateChanged(newDate);
      }
    }

    if (picked == RecurrenceType.monthly) {
      if (mounted) {
        final List<DateTime> selectedDates = await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return _SelectedDatesPicker(
              initialSelectedDates: schedule.selectedDates,
            );
          },
        );

        if (selectedDates.isEmpty) {
          return;
        }

        if (selectedDates.isNotEmpty) {
          setState(() => schedule.selectedDates = selectedDates);
        }
      }
    }

    if (picked != null) {
      setState(() => schedule.recurrenceType = picked);
    }
  }

  void _toggleDurationAlert(bool value) {
    setState(() => schedule.durationAlert = !schedule.durationAlert);
  }

  void _togglePublic(bool value) {
    setState(() => schedule.public = !schedule.public);
  }

  void _toggleSelectedDay(Weekday day) {
    setState(() {
      if (schedule.dailyWeekday.contains(day)) {
        schedule.dailyWeekday.remove(day);
      } else {
        schedule.dailyWeekday.add(day);
      }
    });
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

  Widget? _getRecurrenceExcerpt() {
    if (schedule.recurrenceType == RecurrenceType.once) {
      return Text(DateFormat('EEEE dd MMM, y').format(selectedDate));
    }

    if (schedule.recurrenceType == RecurrenceType.daily) {
      return null;
    }

    return Text(
      '${schedule.recurrenceType.name.capitalize()} on ${schedule.selectedDates.map((e) => e.day).join('th, ')}th ',
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.exerciseId),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              title: const Text('Recurrence Type'),
              subtitle: _getRecurrenceExcerpt(),
              visualDensity: const VisualDensity(vertical: -2),
              trailing: Pressable(
                onTap: () => _selectRecurrenceType(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.00),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Text(
                    schedule.recurrenceType.name.capitalize(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            if (schedule.recurrenceType == RecurrenceType.daily)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(Weekday.values.length, (i) {
                  final day = Weekday.values[i];
                  final selected = schedule.dailyWeekday.contains(day);

                  return Pressable(
                    onTap: () => _toggleSelectedDay(day),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.lightPrimary.withValues(alpha: 0.2)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.name[0].capitalize(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? AppColors.lightPrimary
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }),
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
                    borderRadius: BorderRadius.circular(16.00),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Text(
                    _formatTimeOfDay(startTime),
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
                    borderRadius: BorderRadius.circular(16.00),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  child: Text(
                    _formatDuration(plannedDuration),
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
              value: schedule.durationAlert,
              onChanged: (value) => _toggleDurationAlert(value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(vertical: -2),
              subtitle: const Text(
                "Make this schedule visible to everyone",
              ),
              title: const Text('Public'),
              value: schedule.public,
              onChanged: (value) => _togglePublic(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const _DurationPickerDialog({required this.initialDuration});

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late int selectedMinutes;

  // Duration options from 15 to 180 minutes in 15-minute increments
  final List<int> durationOptions = List.generate(
    12,
    (index) => 15 + (index * 15),
  );

  @override
  void initState() {
    super.initState();
    selectedMinutes = widget.initialDuration.inMinutes;
    // Ensure the selected duration is in our options list
    if (!durationOptions.contains(selectedMinutes)) {
      selectedMinutes = durationOptions.reduce(
        (a, b) =>
            (a - selectedMinutes).abs() < (b - selectedMinutes).abs() ? a : b,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.00)),
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
                        borderRadius: BorderRadius.circular(16),
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
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black87,
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
                TextButton(
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

class _RecurrenceTypePickerDialog extends StatefulWidget {
  final RecurrenceType initialRecurrenceType;
  final List<RecurrenceType> allowedTypes;

  const _RecurrenceTypePickerDialog({
    required this.initialRecurrenceType,
    required this.allowedTypes,
  });

  @override
  State<_RecurrenceTypePickerDialog> createState() =>
      _RecurrenceTypePickerDialogState();
}

class _RecurrenceTypePickerDialogState
    extends State<_RecurrenceTypePickerDialog> {
  late RecurrenceType selectedType;

  late List<RecurrenceType> typeOptions;

  @override
  void initState() {
    super.initState();
    typeOptions = widget.allowedTypes;
    selectedType = widget.initialRecurrenceType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.00)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Recurrence Type',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedType.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: typeOptions.length,
                itemBuilder: (context, index) {
                  final type = typeOptions[index];
                  final isSelected = type == selectedType;

                  return Pressable(
                    onTap: () {
                      setState(() {
                        selectedType = type;
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        type.name.capitalize(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black87,
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
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedType),
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

class _SelectedDatesPicker extends StatefulWidget {
  final List<DateTime> initialSelectedDates;

  const _SelectedDatesPicker({required this.initialSelectedDates});

  @override
  State<_SelectedDatesPicker> createState() => _SelectedDatesPickerState();
}

class _SelectedDatesPickerState extends State<_SelectedDatesPicker> {
  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    selectedDates.addAll(widget.initialSelectedDates);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.00)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Applied Dates',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selectedDates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${selectedDates.length} date${selectedDates.length == 1 ? '' : 's'} selected',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TableCalendarCompact(
                selectedDates: selectedDates,
                onSelectionChanged: (dates) {
                  setState(() {
                    selectedDates = dates;
                  });
                },
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
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(selectedDates),
                    child: const Text('OK'),
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
