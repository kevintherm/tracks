import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/session_activity.dart';
import 'package:tracks/ui/pages/modals/select_sets_n_reps_modal.dart';
import 'package:tracks/ui/pages/modals/select_session_activity_modal.dart';
import 'package:tracks/ui/pages/session_page.dart';
import 'package:tracks/ui/pages/view_exercise_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';

class _ExerciseParam {
  Exercise exercise;
  int sets;
  int reps;

  _ExerciseParam({
    required this.exercise,
    required this.sets,
    required this.reps,
  });
}

class StartSessionPage extends StatefulWidget {
  final Schedule? schedule;
  final Workout? workout;
  final Exercise? exercise;

  const StartSessionPage({
    super.key,
    this.schedule,
    this.workout,
    this.exercise,
  });

  @override
  State<StartSessionPage> createState() => _StartSessionPageState();
}

class _StartSessionPageState extends State<StartSessionPage> {
  SessionActivity? activity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (widget.schedule != null) {
      activity = ScheduleActivity(widget.schedule!);
    } else if (widget.workout != null) {
      activity = WorkoutActivity(widget.workout!);
    } else if (widget.exercise != null) {
      activity = ExerciseActivity(widget.exercise!);
    }

    if (activity == null) {
      final success = await _selectActivity(cancelOnDismiss: true);
      if (!success) return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onPickActivity() async {
    if (await _selectActivity(cancelOnDismiss: false)) {
      setState(() {});
    }
  }

  Future<bool> _selectActivity({required bool cancelOnDismiss}) async {
    final s = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      builder: (_) {
        return SelectSessionActivityModal(canPop: true);
      },
    );

    if (s == null) {
      if (cancelOnDismiss && mounted) {
        Navigator.pop(context);
      }
      return false;
    }

    if (s is Schedule) {
      activity = ScheduleActivity(s);
    } else if (s is Workout) {
      activity = WorkoutActivity(s);
    } else if (s is Exercise) {
      if (mounted) {
        final result = await showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (_) => SelectSetsRepsModal(canPop: false),
        );

        if (result == null) {
          if (cancelOnDismiss) {
            cancelSession();
          }
          return false;
        }

        final (sets, reps) = result;
        if (sets == null || reps == null) {
          if (cancelOnDismiss) {
            cancelSession();
          }
          return false;
        }

        activity = ExerciseActivity(s, sets: sets, reps: reps);
      }
    } else {
      if (cancelOnDismiss) {
        cancelSession();
      }
      return false;
    }

    return true;
  }

  void onStartSession() async {
    final confirm = await showModalBottomSheet(
      context: context,
      builder: (_) => _ConfirmStartSessionDialog(),
    );

    if (activity == null) {
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          builder: (_) => _MissingActivityDialog(),
        );
      }
      return;
    }

    if (mounted && confirm == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionPage(activity: activity!),
        ),
      );
    }
  }

  void cancelSession() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<List<_ExerciseParam>> getExercises() async {
    final list = <_ExerciseParam>[];

    if (activity is ScheduleActivity) {
      final schedule = (activity as ScheduleActivity).schedule;
      final workout = schedule.workout.value;
      if (workout == null) {
        log("[FATAL] Missing workout value from Schedule collection");
        return Future.error(fatalError);
      }

      final exercises = workout.exercisesWithPivot;

      for (final row in exercises) {
        final param = _ExerciseParam(
          exercise: row.exercise,
          sets: row.sets,
          reps: row.reps,
        );
        list.add(param);
      }
    } else if (activity is WorkoutActivity) {
      final workout = (activity as WorkoutActivity).workout;
      final exercises = workout.exercisesWithPivot;

      for (final row in exercises) {
        final param = _ExerciseParam(
          exercise: row.exercise,
          sets: row.sets,
          reps: row.reps,
        );
        list.add(param);
      }
    } else if (activity is ExerciseActivity) {
      final exerciseActivity = activity as ExerciseActivity;
      list.add(
        _ExerciseParam(
          exercise: exerciseActivity.exercise,
          sets: exerciseActivity.sets,
          reps: exerciseActivity.reps,
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Text(
                  "Waiting for your activity...",
                  style: TextStyle(
                    fontVariations: [FontVariation.italic(1)],
                    color: Color.from(alpha: 1, red: 97, green: 97, blue: 97),
                  ),
                ),
              )
            : FutureBuilder<List<_ExerciseParam>>(
                future: getExercises(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final List<_ExerciseParam> exercises = snapshot.data ?? [];

                  if (exercises.isEmpty) {
                    return Center(
                      child: Text(
                        "No details available.",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 280,
                        pinned: true,
                        backgroundColor: Colors.grey[100],
                        surfaceTintColor: Colors.transparent,
                        automaticallyImplyLeading: false,
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxHeight = constraints.maxHeight;
                            final minHeight =
                                kToolbarHeight +
                                MediaQuery.of(context).padding.top;
                            final scrollProgress =
                                ((maxHeight - minHeight) / (280 - minHeight))
                                    .clamp(0.0, 1.0);

                            return FlexibleSpaceBar(
                              titlePadding: EdgeInsets.only(
                                left: 16,
                                bottom: 16,
                                right: 16,
                              ),
                              centerTitle: false,
                              title: Row(
                                children: [
                                  if (scrollProgress < 0.5)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Tooltip(
                                        message: "Back",
                                        child: Pressable(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: Icon(
                                            Iconsax.arrow_left_2_outline,
                                            color: Colors.grey[700],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Workout Overview",
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color.lerp(
                                              Colors.white,
                                              Colors.black,
                                              1 - scrollProgress,
                                            ),
                                          ),
                                        ),
                                        if (activity is ScheduleActivity &&
                                            scrollProgress > 0.5) ...[
                                          Text(
                                            (activity as ScheduleActivity)
                                                    .schedule
                                                    .workout
                                                    .value
                                                    ?.name ??
                                                '',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[200],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Scheduled for ${(activity as ScheduleActivity).schedule.startTime.hour.toString().padLeft(2, '0')}:${(activity as ScheduleActivity).schedule.startTime.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[300],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else if (activity
                                                is WorkoutActivity &&
                                            scrollProgress > 0.5)
                                          Text(
                                            (activity as WorkoutActivity)
                                                .workout
                                                .name,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[200],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Center(
                                    child:
                                        activity is WorkoutActivity &&
                                            (activity as WorkoutActivity)
                                                    .workout
                                                    .thumbnail !=
                                                null
                                        ? getImage(
                                            (activity as WorkoutActivity)
                                                .workout
                                                .thumbnail,
                                            pendingPath:
                                                (activity as WorkoutActivity)
                                                    .workout
                                                    .pendingThumbnailPath,
                                            width: 1000,
                                            height: 1000,
                                          )
                                        : SvgPicture.asset(
                                            'assets/drawings/undraw_athletes_training.svg',
                                          ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: const [
                                          0.0,
                                          0.25,
                                          0.5,
                                          0.95,
                                          1.0,
                                        ],
                                        colors: [
                                          Colors.black.withValues(alpha: 0.2),
                                          Colors.black.withValues(alpha: 0.35),
                                          Colors.black.withValues(alpha: 0.5),
                                          Colors.black.withValues(alpha: 0.65),
                                          Colors.grey[100]!,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    top: MediaQuery.of(context).padding.top + 8,
                                    child: Tooltip(
                                      message: "Back",
                                      child: Pressable(
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                        child: Icon(
                                          Iconsax.arrow_left_2_outline,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final exercise = exercises[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < exercises.length - 1 ? 8 : 0,
                              ),
                              child: Pressable(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 0.7,
                                    child: ClipRRect(
                                      borderRadius: BorderRadiusGeometry.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: ViewExercisePage(
                                        exercise: exercise.exercise,
                                        asModal: true,
                                      ),
                                    ),
                                  ),
                                ),
                                child: _ExerciseCard(exerciseParam: exercise),
                              ),
                            );
                          }, childCount: exercises.length),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: _FabMenu(
        onPickActivity: onPickActivity,
        onStartSession: onStartSession,
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseParam exerciseParam;

  const _ExerciseCard({required this.exerciseParam});

  String get excerpt {
    final muscles = List.of(exerciseParam.exercise.muscles).map((e) => e.name);

    return muscles.length > 3
        ? '${muscles.length} muscles'
        : muscles.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Hero(
              tag: 'exercise-${exerciseParam.exercise.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: getImage(
                  exerciseParam.exercise.thumbnail,
                  pendingPath: exerciseParam.exercise.pendingThumbnailPath,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseParam.exercise.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (excerpt.isNotEmpty)
                    _ExerciseStat(icon: MingCute.barbell_line, label: excerpt),
                  Row(
                    children: [
                      _ExerciseStat(
                        icon: MingCute.barbell_line,
                        label: '${exerciseParam.sets} Sets',
                      ),
                      const SizedBox(width: 8),
                      _ExerciseStat(
                        icon: MingCute.repeat_line,
                        label: '${exerciseParam.reps} Reps',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExerciseStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 175),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

class _FabMenu extends StatelessWidget {
  final VoidCallback onPickActivity;
  final VoidCallback onStartSession;

  const _FabMenu({required this.onPickActivity, required this.onStartSession});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pressable(
          onTap: onPickActivity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Icon(MingCute.color_picker_fill, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Pressable(
          onTap: onStartSession,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Icon(MingCute.play_fill, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ConfirmStartSessionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MingCute.play_circle_fill, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Start Workout?',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to start session?',
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Start',
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

class _MissingActivityDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MingCute.alert_fill, size: 48, color: AppColors.darkAccent),
          const SizedBox(height: 16),
          Text(
            'Cannot Start Session',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t selected any activity for session to start.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'OK',
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
