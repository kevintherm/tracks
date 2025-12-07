import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/models/session_exercise.dart';
import 'package:tracks/models/session_set.dart';
import 'package:tracks/models/workout_exercises.dart';
import 'package:tracks/repositories/session_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/session_activity.dart';
import 'package:tracks/ui/pages/modals/session_finish_failure_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_note_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_rate_fail_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_set_dialog.dart';
import 'package:tracks/ui/pages/modals/session_options.dart';
import 'package:tracks/ui/pages/modals/session_finish_reps_dialog.dart';
import 'package:tracks/ui/pages/modals/session_finish_weight_dialog.dart';
import 'package:tracks/ui/pages/session_finish_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class SessionPage extends StatefulWidget {
  final SessionActivity activity;

  const SessionPage({super.key, required this.activity});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final SessionRepository sessionRepo;
  late final WorkoutRepository workoutRepo;

  late final Session session;
  final List<Exercise> exercises = [];

  // Current exercise and its sets
  final List<SessionSet> sessionSets = [];
  late SessionExercise currentSE;
  WorkoutExercises? exercisePlan;

  Timer? _timer;

  final stopwatch = Stopwatch();
  final restStopwatch = Stopwatch();
  Duration elapsed = Duration();
  Duration restElapsed = Duration();

  bool sessionStarted = false;
  bool isLoading = false;
  int progress = 1;
  bool lastExercise = false;

  @override
  void initState() {
    super.initState();

    currentSE = SessionExercise(exerciseName: '', order: -1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    stopwatch.stop();
    restStopwatch.stop();
  }

  Future<void> initialize() async {
    workoutRepo = context.read<WorkoutRepository>();
    sessionRepo = context.read<SessionRepository>();

    exercises.addAll(widget.activity.getExercises());
    if (exercises.isEmpty) {
      Toast(context).error(content: Text("Cannot find related activity."));
      Navigator.pop(context);
      return;
    }

    final workout = widget.activity.getWorkout();
    session = Session(start: DateTime.now());
    session.workout.value = workout;
    await sessionRepo.createSession(session: session, exercises: []);

    setState(() {
      exercisePlan = widget.activity.getPlan(exercises.first);
      currentSE = SessionExercise(
        exerciseName: exercises.first.name,
        order: progress,
      )..exercise.value = exercises.first;

      lastExercise = exercises.length == 1;
    });


    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (restStopwatch.isRunning) {
        setState(() {
          restElapsed = restStopwatch.elapsed;
        });
      }
      if (stopwatch.isRunning) {
        setState(() {
          elapsed = stopwatch.elapsed;
        });
      }
    });
  }

  void handleNextButton() async {
    if (!sessionStarted) {
      // Stop rest timer and start work timer
      restStopwatch.stop();
      stopwatch.start();

      setState(() {
        sessionStarted = true;
      });

      return;
    }

    // === Finish Set ===

    int? currentReps = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(
            child: SessionFinishRepsDialog(
              initialReps: exercisePlan?.reps ?? 8,
            ),
          ),
        );
      },
    );

    if (currentReps == null || !mounted) return;

    double? weight = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(child: SessionFinishWeightDialog()),
        );
      },
    );

    if (weight == null || !mounted) return;

    int? failOnRep = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(child: SessionFinishFailureDialog()),
        );
      },
    );

    if (!mounted) return;

    int? effortRate = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(child: SessionFinishRateFailDialog()),
        );
      },
    );

    if (effortRate == null || !mounted) return;

    String? note = await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(child: SessionFinishNoteDialog()),
        );
      },
    );

    if (!mounted) return;

    // Finish exercise or another set
    if (!lastExercise &&
        (exercisePlan != null && sessionSets.length < exercisePlan!.sets)) {
      return;
    }

    if (!mounted) return;
    final finishExercise = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _ModalPadding(child: SessionFinishSetDialog()),
        );
      },
    );

    final setDuration = elapsed.inSeconds;
    final setRestDuration = restElapsed.inSeconds;

    sessionSets.add(
      SessionSet(
        weight: weight,
        reps: currentReps,
        duration: setDuration,
        effortRate: effortRate,
        restDuration: setRestDuration,
        failOnRep: failOnRep,
        note: note,
      ),
    );

    setState(() {
      sessionStarted = false;
    });

    // Stop work timer and reset, start rest timer
    stopwatch.stop();
    stopwatch.reset();
    elapsed = Duration();
    
    restStopwatch.reset();
    restStopwatch.start();
    restElapsed = Duration();

    final seToSave = SessionExerciseData(
      sessionExercise: currentSE,
      sets: sessionSets,
    );

    final sessionSaved = await sessionRepo.collection.get(session.id);
    if (sessionSaved != null) {
      await sessionRepo.createSession(session: session, exercises: [seToSave]);
    } else {
      // Next exercise or smth
      await sessionRepo.addExercisesToSession(
        session: session,
        exercises: [seToSave],
      );
    }

    if (finishExercise == true) {
      final pos = exercises.indexOf(
        currentSE.exercise.value ?? Exercise(name: '', caloriesBurned: -1),
      );

      // Session ends
      if (pos == -1 || ((pos + 2) > exercises.length)) {
        session.end = DateTime.now();
        await sessionRepo.updateSession(session);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SessionFinishPage()),
        );
        return;
      }

      final nextExercise = exercises[pos + 1];

      setState(() {
        sessionSets.clear();

        exercisePlan = widget.activity.getPlan(nextExercise);

        currentSE = SessionExercise(
          exerciseName: nextExercise.name,
          order: progress,
        )..exercise.value = nextExercise;

        lastExercise = exercises.length == 1;
        progress++;
      });

      // Reset rest timer for new exercise
      restStopwatch.reset();
      restStopwatch.start();
      restElapsed = Duration();
    }
  }

  void toggleStopwatch() {
    setState(() {
      if (stopwatch.isRunning) {
        stopwatch.stop();
      } else {
        stopwatch.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Exercise $progress of ${exercises.length}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: exercises.isEmpty ? 0 : (progress / exercises.length) - 0.1,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Pressable(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                builder: (context) => ModalOptions(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Icon(
                MingCute.settings_3_line,
                size: 24,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            currentSE.exerciseName,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _buildTargetBadge(),

          const SizedBox(height: 40),

          Center(child: _buildTimer()),

          const SizedBox(height: 40),

          if (sessionSets.isNotEmpty) ...[
            Text(
              "Completed Sets",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildSetsList(),
          ] else ...[
            Center(
              child: Opacity(
                opacity: 0.5,
                child: SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/idle-people.json',
                    animate: stopwatch.isRunning,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetBadge() {
    if (exercisePlan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MingCute.target_line, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            "Target: ${exercisePlan!.sets} sets × ${exercisePlan!.reps} reps",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Column(
      children: [
        Text(
          sessionStarted ? "WORKING" : "RESTING",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: sessionStarted ? Colors.orange : Colors.green,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sessionStarted ? elapsed.mmss : restElapsed.mmss,
          style: GoogleFonts.spaceMono(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSetsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessionSets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final set = sessionSets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${set.weight} kg × ${set.reps} reps",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (set.note != null && set.note!.isNotEmpty)
                      Text(
                        set.note!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRpeColor(set.effortRate).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "RPE ${set.effortRate}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getRpeColor(set.effortRate),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRpeColor(int rpe) {
    if (rpe < 7) return Colors.green;
    if (rpe < 9) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          if (sessionStarted)
            Row(
              children: [
                Pressable(
                  onTap: toggleStopwatch,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      stopwatch.isRunning
                          ? MingCute.pause_fill
                          : MingCute.play_fill,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    onTap: isLoading || stopwatch.isRunning
                        ? null
                        : handleNextButton,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Finish Set",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            PrimaryButton(
              onTap: isLoading ? null : handleNextButton,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(MingCute.play_fill, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Start Set ${sessionSets.length + 1}",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
