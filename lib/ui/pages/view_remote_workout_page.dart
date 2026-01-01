import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/confirm_dialog.dart';
import 'package:tracks/ui/components/modal_padding.dart';
import 'package:tracks/ui/pages/workouts_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class RemoteWorkoutExercise {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int order;

  RemoteWorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.order,
  });
}

class ViewRemoteWorkoutPage extends StatefulWidget {
  final String workoutId;

  const ViewRemoteWorkoutPage({super.key, required this.workoutId});

  @override
  State<ViewRemoteWorkoutPage> createState() => _ViewRemoteWorkoutPageState();
}

class _ViewRemoteWorkoutPageState extends State<ViewRemoteWorkoutPage> {
  final pb = PocketBaseService.instance.client;
  Workout? _workout;
  List<RemoteWorkoutExercise> _workoutExercises = [];
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
      final workoutRecord = await pb.collection('workouts').getOne(widget.workoutId);
      final workout = Workout.fromRecord(workoutRecord);

      final result = await pb
          .collection('workout_exercises')
          .getList(
            filter: 'workout = "${widget.workoutId}"',
            expand: 'exercise',
          );

      final List<RemoteWorkoutExercise> items = [];
      for (final record in result.items) {
        final exercises = record.expand['exercise'];
        final exerciseRecord = (exercises != null && exercises.isNotEmpty) ? exercises.first : null;
        if (exerciseRecord != null) {
          final exercise = Exercise.fromRecord(exerciseRecord);
          items.add(
            RemoteWorkoutExercise(
              exercise: exercise,
              sets: record.data['sets'] ?? 0,
              reps: record.data['reps'] ?? 0,
              order: record.data['order'] ?? 0,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _workout = workout;
          _workoutExercises = items;
          _authorId = workoutRecord.data['user'];
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

  Future<void> _copyWorkout() async {
    if (_workout == null) return;
    
    final confirm = await showModalBottomSheet(
      context: context,
      builder: (context) => ModalPadding(
        child: ConfirmDialog(
          itemName: _workout!.name,
          confirmType: ConfirmType.action,
          entityType: 'Workout',
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isCopying = true);
    try {
      final workoutRepo = context.read<WorkoutRepository>();
      final exerciseRepo = context.read<ExerciseRepository>();

      // Check if already exists
      final existing = await workoutRepo.collection
          .filter()
          .fromPocketBaseIdEqualTo(_workout!.pocketbaseId)
          .findFirst();

      if (existing != null && mounted) {
        Toast(context).neutral(content: Text("Workout already in library"));
        setState(() => _isCopying = false);
        return;
      }

      // 1. Create local workout object
      final newWorkout = Workout(
        name: _workout!.name,
        description: _workout!.description,
        thumbnail: _workout!.thumbnail,
        needSync: true,
      )..fromPocketBaseId = _workout!.pocketbaseId;

      // 2. Prepare exercises
      List<WorkoutConfigParam> exercisesToLink = [];

      for (final we in _workoutExercises) {
        final remoteExercise = we.exercise;

        // Check if local exercise exists
        var localExercise = await exerciseRepo.collection
            .filter()
            .fromPocketBaseIdEqualTo(remoteExercise.pocketbaseId)
            .findFirst();

        if (localExercise == null) {
          // Create local exercise
          localExercise = Exercise(
            name: remoteExercise.name,
            description: remoteExercise.description,
            thumbnail: remoteExercise.thumbnail,
            caloriesBurned: remoteExercise.caloriesBurned,
            needSync: true,
          )..fromPocketBaseId = remoteExercise.pocketbaseId;

          // Save exercise directly since we don't have muscle info here to use createExercise
          await exerciseRepo.isar.writeTxn(() async {
            await exerciseRepo.collection.put(localExercise!);
          });
        }

        exercisesToLink.add(
          WorkoutConfigParam(
            exercise: localExercise,
            sets: we.sets,
            reps: we.reps,
            order: we.order,
          ),
        );
      }

      await workoutRepo.createWorkout(
        workout: newWorkout,
        exercises: exercisesToLink,
      );

      if (mounted) {
        Toast(context).success(content: Text("Workout copied to library"));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutsPage()),
        );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_workout == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load workout")),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchDetails,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    if (_workout!.description != null) ...[
                      Text(
                        _workout!.description!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    _buildExercisesList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (_authorId != null && pb.authStore.model?.id == _authorId)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  onTap: _isCopying ? null : _copyWorkout,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: _isCopying
                            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                            : Icon(Iconsax.copy_outline, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Copy to Library",
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Tooltip(
        message: "Back",
        child: Pressable(
          onTap: () => Navigator.pop(context),
          child: Icon(Iconsax.arrow_left_2_outline, color: Theme.of(context).iconTheme.color),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: getSafeImage(
          _workout!.thumbnail ?? '',
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _workout!.name,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Remote",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // _buildStatItem(Iconsax.clock_outline, "15 min"), // Placeholder
        // const SizedBox(width: 24),
        // _buildStatItem(Iconsax.flash_outline, "Intermediate"), // Placeholder
        const SizedBox(width: 24),
        _buildStatItem(MingCute.fire_line, "320 cal"), // Placeholder
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workoutExercises.isEmpty) {
      return Text(
        "No exercises found",
        style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _workoutExercises.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final we = _workoutExercises[index];
            final exercise = we.exercise;
            return _RemoteExerciseCard(
              exercise: exercise,
              sets: we.sets,
              reps: we.reps,
            );
          },
        ),
      ],
    );
  }
}

class _RemoteExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int sets;
  final int reps;

  const _RemoteExerciseCard({
    required this.exercise,
    required this.sets,
    required this.reps,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: getImage(exercise.thumbnail, width: 80, height: 80),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$sets Sets • $reps Reps",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
