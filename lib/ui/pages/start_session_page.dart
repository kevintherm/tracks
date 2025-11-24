import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/modals/select_sets_n_reps_modal.dart';
import 'package:tracks/ui/pages/modals/select_workout_modal.dart';
import 'package:tracks/ui/pages/session_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

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
  Schedule? schedule;
  Workout? workout;
  Exercise? exercise;
  int exerciseSets = 3;
  int exerciseReps = 8;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    schedule = widget.schedule;
    workout = widget.workout;
    exercise = widget.exercise;

    if (schedule == null && workout == null && exercise == null) {
      final success = await _selectActivity(cancelOnDismiss: true);
      if (!success) return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> onPickActivity() async {
    await _selectActivity(cancelOnDismiss: false);
    setState(() {}); // Rebuild to show new selection
  }

  Future<bool> _selectActivity({required bool cancelOnDismiss}) async {
    final s = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      builder: (_) {
        return SelectWorkoutModal(canPop: true);
      },
    );

    if (s == null) {
      if (cancelOnDismiss && mounted) {
        Toast(context).neutral(content: Text("Session Cancelled."));
        Navigator.pop(context);
      }
      return false;
    }

    if (s is Schedule) {
      schedule = s;
      workout = null;
      exercise = null;
    } else if (s is Workout) {
      workout = s;
      schedule = null;
      exercise = null;
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

        exercise = s;
        schedule = null;
        workout = null;
        exerciseSets = sets;
        exerciseReps = reps;
      }
    } else {
      if (cancelOnDismiss) {
        cancelSession();
      }
      return false;
    }

    return true;
  }

  void onStartSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SessionPage()),
    );
  }

  void cancelSession() {
    if (mounted) {
      Toast(context).neutral(content: Text("Session Cancelled."));
      Navigator.pop(context);
    }
  }

  Future<List<_ExerciseParam>> getExercises() async {
    final list = <_ExerciseParam>[];

    if (schedule != null) {
      final workout = schedule!.workout.value;
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
    } else if (workout != null) {
      final exercises = workout!.exercisesWithPivot;

      for (final row in exercises) {
        final param = _ExerciseParam(
          exercise: row.exercise,
          sets: row.sets,
          reps: row.reps,
        );
        list.add(param);
      }
    } else if (exercise != null) {
      list.add(
        _ExerciseParam(
          exercise: exercise!,
          sets: exerciseSets,
          reps: exerciseReps,
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
                                        if (schedule != null &&
                                            scrollProgress > 0.5) ...[
                                          Text(
                                            schedule!.workout.value?.name ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[200],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Scheduled for ${schedule!.startTime.hour.toString().padLeft(2, '0')}:${schedule!.startTime.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[300],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else if (workout != null &&
                                            scrollProgress > 0.5)
                                          Text(
                                            workout!.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                                        workout != null &&
                                            workout!.thumbnailLocal != null
                                        ? getImage(
                                            workout!.thumbnailLocal,
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
                                onTap: () {},
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

  String get exercisesExcerpt {
    final muscles = List.of(exerciseParam.exercise.muscles).map((e) => e.name);

    return muscles.length > 3
        ? '${muscles.length} Exercises'
        : muscles.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: getImage(exerciseParam.exercise.thumbnailLocal),
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
                  _ExerciseStat(icon: MingCute.time_line, label: "32 Minutes"),
                  if (exercisesExcerpt.isNotEmpty)
                    _ExerciseStat(
                      icon: MingCute.barbell_line,
                      label: exercisesExcerpt,
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

class _FabMenu extends StatefulWidget {
  final VoidCallback onPickActivity;
  final VoidCallback onStartSession;

  const _FabMenu({required this.onPickActivity, required this.onStartSession});

  @override
  State<_FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<_FabMenu>
    with SingleTickerProviderStateMixin {
  bool open = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      open = !open;
      if (open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildFabButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedOpacity(
            opacity: open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: "Pick Another",
                  child: _buildFabButton(
                    icon: MingCute.barbell_line,
                    backgroundColor: AppColors.lightPrimary,
                    onTap: widget.onPickActivity,
                  ),
                ),
                const SizedBox(height: 8),
                Tooltip(
                  message: "Start Session",
                  child: _buildFabButton(
                    backgroundColor: AppColors.lightPrimary,
                    icon: MingCute.play_line,
                    onTap: widget.onStartSession,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Pressable(
          onTap: _toggle,
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
            child: Icon(
              open ? MingCute.close_line : MingCute.menu_line,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
