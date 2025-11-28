import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/models/session_exercise.dart';
import 'package:tracks/models/session_set.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/repositories/session_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/create_exercise_page.dart';
import 'package:tracks/ui/pages/view_workout_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ViewExercisePage extends StatefulWidget {
  final Exercise exercise;
  final bool asModal;

  const ViewExercisePage({
    super.key,
    required this.exercise,
    this.asModal = false,
  });

  @override
  State<ViewExercisePage> createState() => _ViewExercisePageState();
}

class _ViewExercisePageState extends State<ViewExercisePage> {
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
  }

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();

    return StreamBuilder<Exercise?>(
      stream: exerciseRepo.collection.watchObject(_exercise.id, fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _exercise = snapshot.data!;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildMusclesSection(),
                      const SizedBox(height: 32),
                      _buildRelatedWorkouts(),
                      const SizedBox(height: 32),
                      _buildLastSessions(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRelatedWorkouts() {
    final workoutRepo = context.read<WorkoutRepository>();

    return StreamBuilder<List<WorkoutExercises>>(
      stream: workoutRepo.watchWorkoutsForExercise(_exercise.id),
      builder: (context, snapshot) {
        final workouts = _exercise.workouts;
        if (workouts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Workouts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Pressable(
                  onTap: widget.asModal
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.7,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: ViewWorkoutPage(
                                  workout: workout,
                                  asModal: true,
                                ),
                              ),
                            ),
                          );
                        },
                  child: _RelatedWorkoutCard(workout: workout, readOnly: widget.asModal),
                );
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildLastSessions(BuildContext context) {
    final sessionRepo = context.read<SessionRepository>();
    final scheduleRepo = context.read<ScheduleRepository>();

    return StreamBuilder<List<SessionExercise>>(
      stream: sessionRepo.watchSessionExercisesForExercise(_exercise.id),
      builder: (context, sessionSnapshot) {
        if (!sessionSnapshot.hasData) return const SizedBox.shrink();
        final sessionExercises = sessionSnapshot.data!;
        if (sessionExercises.isEmpty) return const SizedBox.shrink();

        return StreamBuilder<List<Schedule>>(
          stream: scheduleRepo.watchAllSchedules(),
          builder: (context, scheduleSnapshot) {
            if (!scheduleSnapshot.hasData) return const SizedBox.shrink();
            final schedules = scheduleSnapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessionExercises.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final se = sessionExercises[index];
                    final session = se.session.value!;
                    final matchingSchedule = _findMatchingSchedule(
                      session,
                      schedules,
                    );

                    return _SessionCard(
                      sessionExercise: se,
                      session: session,
                      schedule: matchingSchedule,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Schedule? _findMatchingSchedule(Session session, List<Schedule> schedules) {
    for (final schedule in schedules) {
      if (session.workout.value?.id != schedule.workout.value?.id) continue;

      final sessionDate = session.start;
      final scheduleTime = schedule.startTime;

      final sessionMinutes = sessionDate.hour * 60 + sessionDate.minute;
      final scheduleMinutes = scheduleTime.hour * 60 + scheduleTime.minute;
      final diff = (sessionMinutes - scheduleMinutes).abs();

      bool dateMatches = false;
      final targetDate = DateTime(
        sessionDate.year,
        sessionDate.month,
        sessionDate.day,
      );

      switch (schedule.recurrenceType) {
        case RecurrenceType.once:
          if (schedule.selectedDates.isEmpty) break;
          final onceDate = schedule.selectedDates.first;
          final sDate = DateTime(onceDate.year, onceDate.month, onceDate.day);
          dateMatches = targetDate == sDate;
          break;
        case RecurrenceType.daily:
          if (schedule.dailyWeekday.isEmpty) {
            dateMatches = false;
          } else {
            final weekdayIndex = sessionDate.weekday - 1;
            final weekdayEnum = Weekday.values[weekdayIndex];
            dateMatches = schedule.dailyWeekday.contains(weekdayEnum);
          }
          break;
        case RecurrenceType.monthly:
          dateMatches = schedule.selectedDates.any(
            (d) =>
                d.year == targetDate.year &&
                d.month == targetDate.month &&
                d.day == targetDate.day,
          );
          break;
      }

      if (dateMatches) {
        if (diff <= 90) {
          return schedule;
        }
      }
    }
    return null;
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.grey[100],
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: widget.asModal
          ? Text(
              "View Exercise",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      leading: Tooltip(
        message: "Back",
        child: Pressable(
          onTap: () => Navigator.pop(context),
          child: Icon(Iconsax.arrow_left_2_outline, color: Colors.grey[700]),
        ),
      ),
      actions: widget.asModal
          ? [
              Tooltip(
                message: "Go To Details",
                child: Pressable(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewExercisePage(exercise: _exercise),
                      ),
                    );
                  },
                  child: Icon(
                    MingCute.external_link_line,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ]
          : [
              Tooltip(
                message: "Action",
                child: Pressable(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 16.0,
                          ),
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: Icon(MingCute.pencil_line),
                                title: Text('Edit Exercise'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateExercisePage(
                                        exercise: _exercise,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Iconsax.trash_bold),
                                title: Text('Delete Exercise'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteConfirmation(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(Iconsax.menu_outline, color: Colors.grey[700]),
                ),
              ),
            ],
      actionsPadding: EdgeInsets.only(right: 16),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'exercise-${_exercise.id}',
          child: _buildExerciseImage(),
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    // 1. Try Local Image
    if (_exercise.thumbnailLocal != null &&
        _exercise.thumbnailLocal!.isNotEmpty) {
      final file = File(_exercise.thumbnailLocal!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    // 2. Try Cloud Image
    if (_exercise.thumbnailCloud != null &&
        _exercise.thumbnailCloud!.isNotEmpty) {
      String url = _exercise.thumbnailCloud!;
      if (!url.startsWith('http')) {
        if (_exercise.pocketbaseId != null) {
          url =
              '$backendUrlAndroid/api/files/exercises/${_exercise.pocketbaseId}/$url';
        }
      }

      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // 3. Fallback
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Image.asset('assets/drawings/not-found.jpg', fit: BoxFit.cover);
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _exercise.name,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Last updated: ${_formatDate(_exercise.updatedAt)}',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChip(
              Icon(MingCute.barbell_line, size: 16, color: AppColors.accent),
              'Exercise',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            if (!_exercise.needSync)
              _buildChip(
                Icon(
                  MingCute.check_circle_fill,
                  size: 16,
                  color: AppColors.lightPrimary,
                ),
                'Synced',
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              )
            else
              _buildChip(
                Icon(
                  MingCute.close_circle_fill,
                  size: 16,
                  color: AppColors.darkSecondary,
                ),
                'Not Synced',
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Iconsax.flash_1_bold,
            value: '${_exercise.caloriesBurned.toInt()}',
            label: 'Kcal',
            color: Colors.orange,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem(
            icon: Iconsax.timer_1_bold,
            value: '15', // Placeholder or derived
            label: 'Min',
            color: Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem(
            icon: Iconsax.activity_bold,
            value: 'Med', // Placeholder
            label: 'Intensity',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (_exercise.description == null || _exercise.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _exercise.description!,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMusclesSection() {
    final muscles = _exercise.muscles;
    if (muscles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Muscles',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: muscles
              .map((muscle) => _buildMuscleChip(muscle.name))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleChip(String name) {
    return _buildChip(
      const Icon(MingCute.fitness_fill, size: 16, color: Colors.redAccent),
      name,
    );
  }

  Widget _buildChip(Icon icon, String name, {EdgeInsets? padding}) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return date.yMMMd;
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final exerciseRepo = context.read<ExerciseRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return _ModalPadding(child: _ConfirmDeleteDialog(exercise: _exercise));
      },
    );

    if (confirmed == true) {
      await exerciseRepo.deleteExercise(_exercise);
      if (context.mounted) {
        Toast(context).success(content: const Text("Exercise deleted"));
        Navigator.pop(context);
      }
    }
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
        const SizedBox(height: 16),
        Text(
          'Delete Exercise?',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
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
    );
  }
}

class _RelatedWorkoutCard extends StatelessWidget {
  final Workout workout;
  final bool readOnly;

  const _RelatedWorkoutCard({required this.workout, this.readOnly = false});

  String get exercisesExcerpt {
    final exercises = List.of(workout.exercises).map((e) => e.name);

    return exercises.length > 3
        ? '${exercises.first} and ${exercises.length - 1} other'
        : exercises.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: getImage(workout.thumbnailLocal, width: 80, height: 80),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStat(icon: MingCute.time_line, label: "32 Minutes"),
                  if (exercisesExcerpt.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildStat(
                      icon: MingCute.barbell_line,
                      label: exercisesExcerpt,
                    ),
                  ],
                ],
              ),
            ),
            if (!readOnly)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
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

class _SessionCard extends StatelessWidget {
  final SessionExercise sessionExercise;
  final Session session;
  final Schedule? schedule;

  const _SessionCard({
    required this.sessionExercise,
    required this.session,
    this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final isar = Isar.getInstance()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEE, d MMM').format(session.start),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm').format(session.start),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (session.end != null)
                    Text(
                      _formatDuration(session.end!.difference(session.start)),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      'Incomplete',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.orange[300],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTypeBadge(),
          const SizedBox(height: 12),
          FutureBuilder<List<SessionSet>>(
            future: isar.sessionSets
                .filter()
                .sessionExercise((q) => q.idEqualTo(sessionExercise.id))
                .findAll(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final sets = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey[100]),
                  const SizedBox(height: 8),
                  ...sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${set.weight}kg x ${set.reps}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (set.effortRate > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRpeColor(
                                  set.effortRate,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RPE ${set.effortRate}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: _getRpeColor(set.effortRate),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    if (schedule != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.calendar_1_bold, size: 14, color: Colors.blue),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _getScheduleConfig(schedule!),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (session.workout.value != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MingCute.barbell_fill, size: 14, color: Colors.purple),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                session.workout.value!.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.flash_1_bold, size: 14, color: Colors.orange),
            const SizedBox(width: 6),
            Text(
              'Single Exercise',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getScheduleConfig(Schedule schedule) {
    final time = DateFormat.Hm().format(schedule.startTime);
    switch (schedule.recurrenceType) {
      case RecurrenceType.daily:
        if (schedule.dailyWeekday.isEmpty) return 'Daily at $time';
        final days = schedule.dailyWeekday
            .map((w) => w.name.substring(0, 3).toUpperCase())
            .join(', ');
        return '$days at $time';
      case RecurrenceType.once:
        return 'Scheduled at $time';
      case RecurrenceType.monthly:
        return 'Monthly at $time';
    }
  }

  Color _getRpeColor(int rpe) {
    if (rpe < 7) return Colors.green;
    if (rpe < 9) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
