import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/schedule.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/schedule_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/confirm_dialog.dart';
import 'package:tracks/ui/components/modal_padding.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

class ViewRemoteSchedulePage extends StatefulWidget {
  final String scheduleId;

  const ViewRemoteSchedulePage({super.key, required this.scheduleId});

  @override
  State<ViewRemoteSchedulePage> createState() => _ViewRemoteSchedulePageState();
}

class _ViewRemoteSchedulePageState extends State<ViewRemoteSchedulePage> {
  final pb = PocketBaseService.instance.client;
  Schedule? _schedule;
  String? _authorId;
  bool _isLoading = true;
  bool _isCopying = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final record = await pb.collection('schedules').getOne(
        widget.scheduleId,
        expand: 'workout',
      );
      final schedule = Schedule.fromRecord(record);

      if (mounted) {
        setState(() {
          _schedule = schedule;
          _authorId = record.data['user'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Toast(context).error(content: Text("Failed to load details: $e"));
      }
    }
  }

  Future<void> _copySchedule() async {
    if (_schedule == null) return;

    final confirm = await showModalBottomSheet(context: context, builder: (context) => ModalPadding(child: ConfirmDialog(itemName: _schedule!.workout.value?.name ?? '', confirmType: ConfirmType.action, entityType: 'Schedule')));

    if (confirm != true || !mounted) return; 

    setState(() => _isCopying = true);
    try {
      final scheduleRepo = context.read<ScheduleRepository>();
      final workoutRepo = context.read<WorkoutRepository>();
      final exerciseRepo = context.read<ExerciseRepository>();

      final remoteWorkout = _schedule!.workout.value;
      if (remoteWorkout == null) {
        Toast(context).error(content: Text("Schedule has no workout linked"));
        setState(() => _isCopying = false);
        return;
      }

      // Check if workout exists locally
      var localWorkout = await workoutRepo.collection.filter().fromPocketBaseIdEqualTo(remoteWorkout.pocketbaseId).findFirst();
      
      if (localWorkout == null) {
        // Copy workout logic
        final pb = PocketBaseService.instance.client;
        final result = await pb.collection('workout_exercises').getList(
          filter: 'workout = "${remoteWorkout.pocketbaseId}"',
          expand: 'exercise',
        );

        final newWorkout = Workout(
          name: remoteWorkout.name,
          description: remoteWorkout.description,
          thumbnail: remoteWorkout.thumbnail,
          needSync: true,
        )..fromPocketBaseId = remoteWorkout.pocketbaseId;

        List<WorkoutConfigParam> exercisesToLink = [];

        for (final record in result.items) {
          final exercises = record.expand['exercise'];
          final exerciseRecord = (exercises != null && exercises.isNotEmpty) ? exercises.first : null;

          if (exerciseRecord != null) {
            final remoteExercise = Exercise.fromRecord(exerciseRecord);

            var localExercise = await exerciseRepo.collection
                .filter()
                .fromPocketBaseIdEqualTo(remoteExercise.pocketbaseId)
                .findFirst();

            if (localExercise == null) {
              localExercise = Exercise(
                name: remoteExercise.name,
                description: remoteExercise.description,
                thumbnail: remoteExercise.thumbnail,
                caloriesBurned: remoteExercise.caloriesBurned,
                needSync: true,
              )..fromPocketBaseId = remoteExercise.pocketbaseId;

              await exerciseRepo.isar.writeTxn(() async {
                await exerciseRepo.collection.put(localExercise!);
              });
            }

            exercisesToLink.add(
              WorkoutConfigParam(
                exercise: localExercise,
                sets: record.data['sets'] ?? 0,
                reps: record.data['reps'] ?? 0,
                order: record.data['order'] ?? 0,
              )
            );
          }
        }

        await workoutRepo.createWorkout(
          workout: newWorkout,
          exercises: exercisesToLink,
        );

        localWorkout = await workoutRepo.collection.filter().fromPocketBaseIdEqualTo(remoteWorkout.pocketbaseId).findFirst();
      }

      if (localWorkout == null) {
        throw Exception("Failed to copy workout");
      }

      // Create local schedule
      final newSchedule = Schedule(
        startTime: _schedule!.startTime,
        plannedDuration: _schedule!.plannedDuration,
        durationAlert: _schedule!.durationAlert,
        recurrenceType: _schedule!.recurrenceType,
        needSync: true,
      )
      ..fromPocketBaseId = _schedule!.pocketbaseId
      ..dailyWeekday = _schedule!.dailyWeekday
      ..selectedDates = _schedule!.selectedDates;

      await scheduleRepo.createSchedule(
        schedule: newSchedule,
        workout: localWorkout,
      );

      if (mounted) {
        Toast(context).success(content: Text("Schedule copied to library"));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Toast(context).error(content: Text("Failed to copy: $e"));
      }
    } finally {
      if (mounted) {
        setState(() => _isCopying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_schedule == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text("Failed to load schedule")),
      );
    }

    final workout = _schedule!.workout.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Pressable(
          onTap: () => Navigator.pop(context),
          child: const Icon(Iconsax.arrow_left_2_outline, color: Colors.black),
        ),
        title: Text(
          "View Schedule",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Recurrence", _schedule!.recurrenceType.name.toUpperCase()),
                const SizedBox(height: 16),
                _buildInfoRow("Duration", "${_schedule!.plannedDuration} min"),
                const SizedBox(height: 16),
                if (workout != null) ...[
                  Text(
                    "Linked Workout",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.weight_1_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          workout.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: (_authorId != null && pb.authStore.model?.id == _authorId)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  onTap: _isCopying ? null : _copySchedule,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: _isCopying
                            ? CircularProgressIndicator(color: Colors.white)
                            : Icon(Iconsax.copy_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Copy to Library",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
