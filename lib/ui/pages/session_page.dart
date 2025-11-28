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
import 'package:tracks/ui/components/safe_keyboard.dart';
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
  late final List<Exercise> exercises;

  // Current exercise and its sets
  final List<SessionSet> sessionSets = [];
  late SessionExercise currentSE;
  WorkoutExercises? exercisePlan;

  Timer? _timer;

  final stopwatch = Stopwatch();
  Duration elapsed = Duration();

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
  }

  Future<void> initialize() async {
    workoutRepo = context.read<WorkoutRepository>();
    sessionRepo = context.read<SessionRepository>();

    exercises = widget.activity.getExercises();
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
  }

  void handleNextButton() async {
    if (!sessionStarted) {
      stopwatch.start();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (stopwatch.isRunning) {
          setState(() {
            elapsed = stopwatch.elapsed;
          });
        }
      });

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

    final setDuration = elapsed.inSeconds;

    sessionSets.add(
      SessionSet(
        weight: weight,
        reps: currentReps,
        duration: setDuration,
        effortRate: effortRate,
        failOnRep: failOnRep,
        note: note,
      ),
    );

    setState(() {
      sessionStarted = false;
    });

    _timer?.cancel();
    _timer = null;
    stopwatch.reset();
    elapsed = Duration();

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Pressable(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            builder: (context) => ModalOptions(),
                          );
                        },
                        child: Icon(MingCute.settings_3_line, size: 32),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 20,
                            disabledActiveTrackColor: AppColors.lightPrimary,
                            thumbShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            value: progress * 10,
                            min: 0,
                            max: 100,
                            onChanged: null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current exercise:",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[600]
                              : Colors.grey[300],
                        ),
                      ),
                      Text(
                        currentSE.exerciseName,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SafeKeyboard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 300,
                              child: Lottie.asset(
                                'assets/animations/idle-people.json',
                                animate: stopwatch.isRunning,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Set ${sessionSets.length + 1}",
                              style: GoogleFonts.spaceMono(fontSize: 16),
                            ),
                          ),
                        ),
                        if (!stopwatch.isRunning && sessionStarted)
                          Text(
                            "Paused",
                            style: GoogleFonts.spaceMono(fontSize: 16),
                          ),
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              sessionStarted ? elapsed.mmss : "00:00",
                              style: GoogleFonts.spaceMono(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!sessionStarted)
                          Expanded(
                            child: PrimaryButton(
                              onTap: isLoading ? null : handleNextButton,
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              child: Text(
                                "Start Set",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 52),
                                Pressable(
                                  onTap: toggleStopwatch,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      stopwatch.isRunning
                                          ? MingCute.pause_fill
                                          : MingCute.play_fill,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Pressable(
                                  onTap: stopwatch.isRunning
                                      ? null
                                      : handleNextButton,
                                  child: Icon(
                                    MingCute.skip_forward_fill,
                                    color: AppColors.primary.withValues(
                                      alpha: stopwatch.isRunning ? 0.5 : 1,
                                    ),
                                    size: 36,
                                  ),
                                ),
                              ],
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
