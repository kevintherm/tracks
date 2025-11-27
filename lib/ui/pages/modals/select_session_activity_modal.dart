import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';

class SelectSessionActivityModal extends StatefulWidget {
  final bool canPop;

  const SelectSessionActivityModal({super.key, this.canPop = false});

  @override
  State<SelectSessionActivityModal> createState() => _SelectSessionActivityModalState();
}

class _SelectSessionActivityModalState extends State<SelectSessionActivityModal>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final searchController = TextEditingController();
  Timer? _debounce;
  String search = "";

  int tabIndex = 0;

  dynamic selectedItem;
  String? selectedId;

  List<Schedule> _allSchedules = [];
  List<Workout> _allWorkouts = [];
  List<Exercise> _allExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
        selectedId = null;
        selectedItem = null;
      });
    });

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          search = searchController.text;
        });
      });
    });

    _loadData();
  }

  Future<void> _loadData() async {
    final scheduleRepo = context.read<ScheduleRepository>();
    final workoutRepo = context.read<WorkoutRepository>();
    final exerciseRepo = context.read<ExerciseRepository>();

    final schedules = await scheduleRepo.watchAllSchedules().first;
    final workouts = await workoutRepo.watchAllWorkouts().first;
    final exercises = await exerciseRepo.watchAllExercises().first;

    setState(() {
      _allSchedules = schedules;
      _allWorkouts = workouts;
      _allExercises = exercises;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final now = DateTime.now();
    final selectedDate = DateTime.now();

    List<Schedule> schedules = List.from(_allSchedules)
      ..sort((a, b) {
        DateTime getScheduleDateTime(Schedule s) {
          if (s.recurrenceType == RecurrenceType.daily) {
            return DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              s.startTime.hour,
              s.startTime.minute,
              s.startTime.second,
            );
          } else {
            final date = s.activeSelectedDates.isNotEmpty
                ? s.activeSelectedDates.first
                : selectedDate;
            return DateTime(
              date.year,
              date.month,
              date.day,
              s.startTime.hour,
              s.startTime.minute,
              s.startTime.second,
            );
          }
        }

        final aDateTime = getScheduleDateTime(a);
        final bDateTime = getScheduleDateTime(b);

        final aIsUpcoming = aDateTime.isAfter(now);
        final bIsUpcoming = bDateTime.isAfter(now);

        if (aIsUpcoming && !bIsUpcoming) return -1;
        if (!aIsUpcoming && bIsUpcoming) return 1;

        return aDateTime.compareTo(bDateTime);
      });

    List<Workout> workouts = _allWorkouts;
    List<Exercise> exercises = _allExercises;

    if (search.isNotEmpty) {
      schedules = FuzzySearch.search(
        items: schedules,
        query: search,
        getSearchableText: (w) => w.workout.value?.name ?? '',
        threshold: 0.1,
      );

      workouts = FuzzySearch.search(
        items: workouts,
        query: search,
        getSearchableText: (w) => w.name,
        threshold: 0.1,
      );

      exercises = FuzzySearch.search(
        items: exercises,
        query: search,
        getSearchableText: (e) => e.name,
        threshold: 0.1,
      );
    }

    return PopScope(
      canPop: widget.canPop,
      child: _ModalPadding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Activity To Start Session',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            TabBar(
              controller: tabController,
              tabs: [
                Tab(child: Text("From Schedules", textAlign: TextAlign.center)),
                Tab(child: Text("From Workouts", textAlign: TextAlign.center)),
                Tab(child: Text("From Exercises", textAlign: TextAlign.center)),
              ],
            ),

            const SizedBox(height: 16),
            _SearchBar(controller: searchController),

            SizedBox(
              height: 450,
              child: TabBarView(
                controller: tabController,
                children: [
                  _ScheduleList(
                    schedules: schedules,
                    selectedId: selectedId,
                    onSelect: (schedule) {
                      selectedItem = schedule;
                      setState(() {
                        selectedId = schedule.id.toString();
                      });
                    },
                  ),
                  _WorkoutList(
                    workouts: workouts,
                    selectedId: selectedId,
                    onSelect: (workout) {
                      selectedItem = workout;
                      setState(() {
                        selectedId = workout.id.toString();
                      });
                    },
                  ),
                  _ExerciseList(
                    exercises: exercises,
                    selectedId: selectedId,
                    onSelect: (exercise) {
                      setState(() {
                        selectedItem = exercise;
                        selectedId = exercise.id.toString();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              onTap: selectedItem != null
                  ? () => Navigator.of(context).pop(selectedItem)
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(MingCute.right_line, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Schedule List
class _ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final String? selectedId;
  final Function(Schedule) onSelect;

  const _ScheduleList({
    required this.schedules,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Text(
          'No schedules available',
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: schedules.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        schedule.workout.load();
        final isSelected = selectedId == schedule.id.toString();
        return _ScheduleCard(
          key: ValueKey(schedule.id),
          schedule: schedule,
          isSelected: isSelected,
          onTap: () => onSelect(schedule),
        );
      },
    );
  }
}

class _WorkoutList extends StatelessWidget {
  final List<Workout> workouts;
  final String? selectedId;
  final Function(Workout) onSelect;

  const _WorkoutList({
    required this.workouts,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Center(
        child: Text(
          'No workouts available',
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: workouts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final isSelected = selectedId == workout.id.toString();
        return _WorkoutCard(
          key: ValueKey(workout.id),
          workout: workout,
          isSelected: isSelected,
          onTap: () => onSelect(workout),
        );
      },
    );
  }
}

class _ExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  final String? selectedId;
  final Function(Exercise) onSelect;

  const _ExerciseList({
    required this.exercises,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Center(
        child: Text(
          'No exercises available',
          style: TextStyle(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isSelected = selectedId == exercise.id.toString();
        return _ExerciseCard(
          key: ValueKey(exercise.id),
          exercise: exercise,
          isSelected: isSelected,
          onTap: () => onSelect(exercise),
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  _ScheduleCard({
    super.key,
    required this.schedule,
    required this.isSelected,
    required this.onTap,
  });

  final Schedule schedule;
  final DateTime selectedDate = DateTime.now();
  final bool isSelected;
  final Function() onTap;

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
      onTap: onTap,
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
                      getWorkoutColage(workout, width: 60, height: 60),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: GoogleFonts.inter(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(MingCute.target_line, size: 16),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        schedule.recurrenceType.name
                                            .capitalize(),
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
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Icon(MingCute.barbell_line, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${workout.exercises.length} exercises',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 32,
                    bottom: 32,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
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
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Workout Card
class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkoutCard({
    super.key,
    required this.workout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: getWorkoutColage(workout, width: 60, height: 60),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(MingCute.barbell_line, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.exercises.length} exercises',
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
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                left: 0,
                top: 32,
                bottom: 32,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Exercise Card
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  String get musclesExcerpt {
    final muscles = exercise.muscles.map((e) => e.name).toList();
    return muscles.length > 3
        ? '${muscles.length} muscles'
        : muscles.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: getImage(
                      exercise.thumbnailLocal,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (musclesExcerpt.isNotEmpty)
                          Row(
                            children: [
                              Icon(MingCute.barbell_line, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  musclesExcerpt,
                                  overflow: TextOverflow.ellipsis,
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
            if (isSelected)
              Positioned(
                left: 0,
                top: 32,
                bottom: 32,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
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

class _ModalPadding extends StatelessWidget {
  final Widget child;

  const _ModalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 24),
      child: child,
    );
  }
}
