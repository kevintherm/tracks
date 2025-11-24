import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/single_row_calendar_pager.dart';
import 'package:tracks/ui/pages/assign_schedule_page.dart';
import 'package:tracks/ui/pages/manage_schedule_page.dart';
import 'package:tracks/ui/pages/sessions_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ScheduleFragment extends StatefulWidget {
  const ScheduleFragment({super.key});

  @override
  State<ScheduleFragment> createState() => _ScheduleFragmentState();
}

class _ScheduleFragmentState extends State<ScheduleFragment> {
  DateTime selectedDate = DateTime.now();

  DateTime _getScheduleDateTime(Schedule schedule, DateTime selectedDate) {
    if (schedule.recurrenceType == RecurrenceType.daily) {
      // For daily schedules, use the selected date with the schedule's start time
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        schedule.startTime.hour,
        schedule.startTime.minute,
        schedule.startTime.second,
      );
    } else {
      // For once/monthly schedules, use the actual scheduled date with start time
      final date = schedule.activeSelectedDates.isNotEmpty
          ? schedule.activeSelectedDates.first
          : selectedDate;
      return DateTime(
        date.year,
        date.month,
        date.day,
        schedule.startTime.hour,
        schedule.startTime.minute,
        schedule.startTime.second,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleRepo = context.read<ScheduleRepository>();
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Schedule",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'See All Sessions.',
                    child: Pressable(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionsPage(),
                          ),
                        );
                      },
                      child: Icon(MingCute.history_line, size: 28),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Manage All Schedules.',
                    child: Pressable(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageSchedulePage(),
                          ),
                        );
                      },
                      child: Icon(MingCute.list_search_line, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SingleRowCalendarPager(
          showNavigation: false,
          showMonthLabel: false,
          onDateSelected: (value) {
            if (!DateUtils.isSameDay(selectedDate, value)) {
              setState(() {
                final newSelected = DateTime(
                  value.year,
                  value.month,
                  value.day,
                  now.hour,
                  now.minute,
                  now.second,
                );
                selectedDate = newSelected;
              });
            }
          },
          selectedDate: selectedDate,
          initialStartDate: DateTime.utc(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day - 2,
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder(
              stream: scheduleRepo.watchSchedulesForDate(selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final List<Schedule> schedules = snapshot.data ?? [];
                final now = DateTime.now();

                // Sort: active schedules first, then expired, each sorted by start time
                schedules.sort((a, b) {
                  final aDateTime = _getScheduleDateTime(a, selectedDate);
                  final bDateTime = _getScheduleDateTime(b, selectedDate);
                  final aIsActive = aDateTime.isAfter(now);
                  final bIsActive = bDateTime.isAfter(now);

                  // Active schedules come first
                  if (aIsActive != bIsActive) {
                    return aIsActive ? -1 : 1;
                  }

                  // Within same status, sort by time (earliest first for active, latest first for expired)
                  if (aIsActive) {
                    return aDateTime.compareTo(bDateTime);
                  } else {
                    return bDateTime.compareTo(aDateTime);
                  }
                });

                if (schedules.isEmpty) {
                  return Center(
                    child: Text(
                      "No schedules for ${isToday(selectedDate) ? 'today' : 'this day'}.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: schedules.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];

                    return Dismissible(
                      key: ValueKey(index),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          Toast(context).success(content: Text("Delete"));
                          return false;
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AssignSchedulePage(schedule: schedule),
                            ),
                          );
                          return false;
                        }
                      },
                      child: _ScheduleCard(
                        schedule: schedule,
                        selectedDate: selectedDate,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule, required this.selectedDate});

  final Schedule schedule;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final workout = schedule.workout.value!;

    DateTime scheduleDateTime;
    if (schedule.recurrenceType == RecurrenceType.daily) {
      scheduleDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        schedule.startTime.hour,
        schedule.startTime.minute,
        schedule.startTime.second,
      );
    } else {
      final date = schedule.activeSelectedDates.isNotEmpty
          ? schedule.activeSelectedDates.first
          : selectedDate;
      scheduleDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        schedule.startTime.hour,
        schedule.startTime.minute,
        schedule.startTime.second,
      );
    }

    return Pressable(
      onTap: () {},
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      getWorkoutColage(workout, width: 80, height: 80),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(MingCute.play_circle_fill, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      Duration(
                                        minutes: schedule.plannedDuration,
                                      ).hM,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(MingCute.fire_line, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '32 Kkal',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(MingCute.barbell_line, size: 16),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    workout.excerpt,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(MingCute.target_line, size: 16),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    schedule.recurrenceType.name.capitalize(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _OnComingBadge(
                  onComingDate: scheduleDateTime,
                  selectedDate: selectedDate,
                  isActive: scheduleDateTime.isAfter(DateTime.now()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnComingBadge extends StatelessWidget {
  final DateTime onComingDate;
  final DateTime selectedDate;
  final bool isActive;

  _OnComingBadge({
    required this.onComingDate,
    required this.selectedDate,
    required this.isActive,
  });

  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDateOnly = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final todayOnly = DateTime(now.year, now.month, now.day);
    final isToday = selectedDateOnly.isAtSameMomentAs(todayOnly);

    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[900] : Colors.grey[600],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Text(
          isToday
              ? dateToHumans(onComingDate, from: now)
              : dateToHumans(selectedDate, from: now),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
