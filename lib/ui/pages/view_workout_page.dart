import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/create_workout_page.dart';
import 'package:tracks/ui/pages/view_exercise_page.dart';
import 'package:tracks/ui/pages/view_muscle_page.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ViewWorkoutPage extends StatefulWidget {
  final Workout workout;
  final bool asModal;

  const ViewWorkoutPage({
    super.key,
    required this.workout,
    this.asModal = false,
  });

  @override
  State<ViewWorkoutPage> createState() => _ViewWorkoutPageState();
}

class _ViewWorkoutPageState extends State<ViewWorkoutPage> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  @override
  Widget build(BuildContext context) {
    final workoutRepo = context.read<WorkoutRepository>();

    return StreamBuilder<Workout?>(
      stream: workoutRepo.collection.watchObject(widget.workout.id, fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _workout = snapshot.data!;
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
                      _buildExercises(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildExercises(BuildContext context) {
    final workoutRepo = context.read<WorkoutRepository>();

    return StreamBuilder<List<dynamic>>(
      stream: workoutRepo.watchExercisesForWorkout(_workout.id),
      builder: (context, snapshot) {
        final exercisesWithPlan = _workout.exercisesWithPivot;
        if (exercisesWithPlan.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercises',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercisesWithPlan.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final exercisePlan = exercisesWithPlan[index];
                final exercise = exercisePlan.exercise;
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
                                child: ViewExercisePage(
                                  exercise: exercise,
                                  asModal: true,
                                ),
                              ),
                            ),
                          );
                        },
                  child: _ExerciseCard(exercise: exercise, readonly: widget.asModal),
                );
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.grey[100],
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Tooltip(
        message: "Back",
        child: Pressable(
          onTap: () => Navigator.pop(context),
          child: Icon(Iconsax.arrow_left_2_outline, color: Colors.grey[700]),
        ),
      ),
      title: widget.asModal
          ? Text(
              "View Workout",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
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
                        builder: (_) => ViewWorkoutPage(workout: _workout),
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
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(MingCute.pencil_line),
                              title: Text('Edit Workout'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateWorkoutPage(workout: _workout),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(Iconsax.trash_bold),
                              title: Text('Delete Workout'),
                              onTap: () {
                                Navigator.pop(context);
                                _showDeleteConfirmation(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Icon(Iconsax.menu_outline, color: Colors.grey[700]),
                ),
              ),
            ],
      actionsPadding: EdgeInsets.only(right: 16),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'workout-${_workout.id}',
          child: _buildExerciseImage(),
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    if (_workout.thumbnail != null && _workout.thumbnail!.isNotEmpty) {
      final file = File(_workout.thumbnail!);
      if (file.existsSync()) {
        return getImage(_workout.thumbnail, width: double.infinity, height: double.infinity);
      }
    }
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
          _workout.name,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Last updated: ${_formatDate(_workout.updatedAt)}',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChip(
              Icon(MingCute.barbell_line, size: 16, color: AppColors.accent),
              'Workout',
            ),
            if (!_workout.needSync)
              _buildChip(
                Icon(MingCute.check_circle_fill, size: 16, color: AppColors.lightPrimary),
                'Synced',
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              )
            else
              _buildChip(
                Icon(
                  MingCute.close_circle_fill,
                  size: 16,
                  color: AppColors.darkSecondary,
                ),
                'Not Synced',
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMusclesSection() {
    final muscles = _workout.exercises
        .map((e) => e.muscles.take(1))
        .expand((e) => e);
    if (muscles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Target Muscles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '(Major)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: muscles
              .map((muscle) => _buildMuscleChip(muscle))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleChip(Muscle muscle) {
    return Pressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewMusclePage(muscle: muscle),
          ),
        );
      },
      child: _buildChip(
        const Icon(MingCute.fitness_fill, size: 16, color: Colors.redAccent),
        muscle.name,
      ),
    );
  }

  Widget _buildChip(Icon icon, String name, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            value:
                '${_workout.exercises.map((e) => e.caloriesBurned).reduce((value, e) => value + e).toInt()}~',
            label: 'Kcal',
            color: Colors.orange,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem(
            icon: Iconsax.timer_1_bold,
            value: '15',
            label: 'Min',
            color: Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem(
            icon: Iconsax.activity_bold,
            value: 'Med',
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
    if (_workout.description == null || _workout.description!.isEmpty) {
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
          _workout.description!,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return date.yMMMd;
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final workoutRepo = context.read<WorkoutRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return _ModalPadding(child: _ConfirmDeleteDialog(workout: _workout));
      },
    );

    if (confirmed == true) {
      await workoutRepo.deleteWorkout(_workout);
      if (context.mounted) {
        Toast(context).success(content: const Text("Workout deleted"));
        Navigator.pop(context);
      }
    }
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
        const SizedBox(height: 16),
        Text(
          'Delete Workout?',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Are you sure you want to delete "${workout.name}"? This action cannot be undone.',
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

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool readonly;

  const _ExerciseCard({required this.exercise, this.readonly = false});

  String get excerpt {
    final exercises = List.of(exercise.muscles).map((e) => e.name);

    return exercises.length > 3
        ? '${exercises.first} and ${exercises.length - 1} other'
        : exercises.join(', ');
  }

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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStat(icon: MingCute.time_line, label: "32 Minutes"),
                  if (excerpt.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildStat(icon: MingCute.barbell_line, label: excerpt),
                  ],
                ],
              ),
            ),
            if (!readonly)
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
