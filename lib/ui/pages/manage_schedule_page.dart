import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/base_button.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/filter.dart';
import 'package:tracks/ui/pages/assign_schedule_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class ManageSchedulePage extends StatefulWidget {
  const ManageSchedulePage({super.key});

  @override
  State<ManageSchedulePage> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  final searchController = TextEditingController();
  Timer? _debounce;
  String search = "";

  List<Filter<Schedule>> activeFilters = [];

  final now = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          search = searchController.text;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _deleteSchedule(BuildContext context, Schedule schedule) async {
    final scheduleRepo = context.read<ScheduleRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return _ConfirmDeleteDialog(schedule: schedule);
      },
    );

    if (confirmed == true) {
      await scheduleRepo.deleteSchedule(schedule);
      if (context.mounted) {
        Toast(context).success(content: const Text("Schedule deleted"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleRepo = context.read<ScheduleRepository>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Pressable(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Iconsax.arrow_left_2_outline, size: 24),
                  ),
                  Text(
                    "All Schedules",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Tooltip(
                    message: 'Create New Schedule',
                    child: Pressable(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignSchedulePage(
                              selectedDate: DateTime.now(),
                            ),
                          ),
                        );
                      },
                      child: const Icon(Iconsax.add_outline, size: 32),
                    ),
                  ),
                ],
              ),
            ),

            _SearchBar(controller: searchController),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseButton(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text("Filter"),
                        const SizedBox(width: 8),
                        Icon(Iconsax.filter_outline, size: 20),
                      ],
                    ),
                  ),
                  if (activeFilters.isNotEmpty)
                    BaseButton(onTap: () {}, child: Text("Clear")),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: StreamBuilder(
                  stream: scheduleRepo.watchAllSchedules(),
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
                    List<Schedule> filtered = schedules;

                    if (search.isNotEmpty) {
                      filtered = FuzzySearch.search(
                        items: schedules,
                        query: search,
                        getSearchableText: (e) {
                          e.workout.load();
                          return e.workout.value!.name;
                        },
                        threshold: 0.1,
                      );
                    } else {
                      // Apply filters
                      for (final filter in activeFilters) {
                        filtered = filter.onTransform(filtered);
                        print(filter.name);
                      }
                    }

                    if (schedules.isEmpty) {
                      return Center(
                        child: Text(
                          "No schedules available.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          "No matching schedules found.",
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
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final schedule = filtered[index];

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
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await _deleteSchedule(context, schedule);
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
                          child: _ScheduleCard(schedule: schedule),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 250),
                    child: Text(
                      'Searching for `${controller.text}`',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Pressable(
                    onTap: () {
                      controller.text = "";
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  _ScheduleCard({required this.schedule});

  final Schedule schedule;
  final DateTime now = DateTime.now();

  String getQuickSelectedDates() {
    if (schedule.recurrenceType == RecurrenceType.once) {
      return 'Once at ${schedule.selectedDates.first.yMMMd}';
    }

    if (schedule.recurrenceType == RecurrenceType.daily) {
      return schedule.dailyWeekday
          .map((e) => e.name.substring(0, 3).capitalize())
          .join(', ');
    }

    return 'Monthly on ${schedule.selectedDates.map((e) => e.day.ordinal).join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleRepository = context.read<ScheduleRepository>();
    final workout = schedule.workout.value!;

    bool isActive = schedule.recurrenceType == RecurrenceType.monthly
        ? true
        : scheduleRepository.isScheduleActiveOnDate(schedule, now);

    return Pressable(
      onTap: () {},
      child: Column(
        children: [
          AppContainer(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      getWorkoutColage(workout),
            
                      const SizedBox(width: 16),
            
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('#${schedule.id.toString().padLeft(2, '0')}'),
                                const SizedBox(width: 8),
                                Text(
                                  workout.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(MingCute.time_line, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeFormat(schedule.startTime),
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
                                    Icon(MingCute.barbell_line, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${schedule.workout.value!.exercises.length}x',
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
                                Icon(MingCute.target_line, size: 16),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    getQuickSelectedDates(),
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
                                Icon(MingCute.calendar_time_add_line, size: 16),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    workout.createdAt.yMMMd,
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
                _ActiveBadge(isActive: isActive),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;

  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[900] : Colors.grey[600],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Text(
          isActive ? "Active" : "Expired",
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

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Delete Schedule?',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete "${schedule.workout.value!.name}"? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
