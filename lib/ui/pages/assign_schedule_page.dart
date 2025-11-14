import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/ui/widgets/assign_schedule_config_card.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class AssignSchedulePage extends StatefulWidget {
  final DateTime? selectedDate;

  const AssignSchedulePage({super.key, this.selectedDate});

  @override
  State<AssignSchedulePage> createState() => _AssignSchedulePageState();
}

class _AssignSchedulePageState extends State<AssignSchedulePage> {
  late final String selectedDayName;

  final searchController = TextEditingController();
  String search = "";
  Timer? _debounce;

  Workout? selectedWorkout;
  Schedule schedule = Schedule(
    startAt: DateTime.now(),
    startTime: DateTime.now(),
    recurrenceType: RecurrenceType.once,
  );

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      selectedDayName = DateFormat('EEEE').format(widget.selectedDate!);
      searchController.addListener(() {
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 150), () {
          setState(() {
            search = searchController.text;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectWorkout(Workout workout) {
    setState(() {
      selectedWorkout = workout;
    });
  }

  void _deleteSelectedWorkout() {
    setState(() {
      selectedWorkout = null;
    });
  }

  void _saveExercise() {
    final toast = Toast(context);
    final nav = Navigator.of(context);

    try {
      if (selectedWorkout == null) {
        Toast(context).error(content: Text("Please select a workout first!"));
        return;
      }

      final scheduleRepo = context.read<ScheduleRepository>();

      schedule.workout.value = selectedWorkout;

      scheduleRepo.createSchedule(schedule: schedule);

      toast.success(content: Text("New schedule created."));
      nav.pop(true);
    } catch (e) {
      toast.error(content: Text("Failed to create schedule. $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutRepo = context.read<WorkoutRepository>();

    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Pressable(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Iconsax.arrow_left_2_outline,
                          size: 24,
                        ),
                      ),
                      Text(
                        "Assign Schedule",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Pressable(
                        onTap: _saveExercise,
                        child: const Icon(
                          Iconsax.tick_square_outline,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.selectedDate != null)
                  SectionCard(
                    title: "Selected Day",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE dd MMM, y',
                          ).format(widget.selectedDate!),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("(0)", style: GoogleFonts.inter(fontSize: 16)),
                      ],
                    ),
                  ),

                // Select Workout Section
                if (selectedWorkout == null)
                  SectionCard(
                    title: "Select a Workout",
                    child: Column(
                      children: [
                        _SearchBar(controller: searchController),

                        SizedBox(
                          height: 400,
                          child: StreamBuilder(
                            stream: workoutRepo.watchAllWorkouts(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final List<Workout> workouts =
                                  snapshot.data ?? [];
                              List<Workout> filtered = workouts;

                              if (search.isNotEmpty) {
                                filtered = FuzzySearch.search(
                                  items: workouts,
                                  query: search,
                                  getSearchableText: (e) => e.name,
                                  threshold: 0.1,
                                );
                              } else {
                                filtered = workouts.toList()
                                  ..sort(
                                    (a, b) =>
                                        b.updatedAt.compareTo(a.updatedAt),
                                  );
                              }

                              if (workouts.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No workouts available.",
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
                                    "No matching workouts found.",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final workout = filtered[index];

                                  return Pressable(
                                    onTap: () => _selectWorkout(workout),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.grey[100],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: getImage(
                                                workout.thumbnailFallback,
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    workout.name,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    workout.description ??
                                                        workout.excerpt,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Selected Workout Section
                if (selectedWorkout != null)
                  SectionCard(
                    title: "Selected Workout",
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: getImage(
                                selectedWorkout!.thumbnailFallback,
                                width: 60,
                                height: 60,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedWorkout!.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedWorkout!.description ??
                                        selectedWorkout!.excerpt,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Pressable(
                              onTap: () => _deleteSelectedWorkout(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Iconsax.trash_outline,
                                  size: 18,
                                  color: Colors.red[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (selectedWorkout != null)
                  SectionCard(
                    title: "Configure Schedule",
                    child: AssignScheduleConfigCard(
                      exerciseId: '1',
                      workoutName: 'Workout Name',
                      index: 1,
                      config: schedule,
                      selectedDayName: selectedDayName,
                      selectedDate: widget.selectedDate ?? DateTime.now(),
                      onConfigChanged: (v) {},
                    ),
                  ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(bottom: 16),
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
              fillColor: Colors.grey[100],
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
