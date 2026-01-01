import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/session.dart';
import 'package:tracks/models/session_exercise.dart';
import 'package:tracks/models/session_set.dart';
import 'package:tracks/repositories/session_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/buttons/secondary_button.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ViewSessionPage extends StatefulWidget {
  final Session session;

  const ViewSessionPage({super.key, required this.session});

  @override
  State<ViewSessionPage> createState() => _ViewSessionPageState();
}

class _ViewSessionPageState extends State<ViewSessionPage> {
  late Session _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  Widget build(BuildContext context) {
    final sessionRepo = context.read<SessionRepository>();

    return Scaffold(
      body: StreamBuilder<List<Session>>(
        stream: sessionRepo.collection
            .where()
            .idEqualTo(_session.id)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            _session = snapshot.data!.first;
          }

          return CustomScrollView(
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
                      _buildExercisesList(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
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
      actions: [
        Tooltip(
          message: "Edit Session",
          child: Pressable(
            onTap: () => _showEditSessionDialog(context),
            child: Icon(Iconsax.edit_2_outline, color: Theme.of(context).iconTheme.color),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'session-${_session.id}',
          child: _buildWorkoutImage(),
        ),
      ),
    );
  }

  Widget _buildWorkoutImage() {
    final workout = _session.workout.value;
    if (workout == null) return _buildPlaceholder();

    if (workout.thumbnail != null && workout.thumbnail!.isNotEmpty) {
      final file = File(workout.thumbnail!);
      if (file.existsSync()) {
        return getImage(
          workout.thumbnail,
          pendingPath: workout.pendingThumbnailPath,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Image.asset('assets/drawings/not-found.jpg', fit: BoxFit.cover);
  }

  Widget _buildHeader() {
    final workoutName = _session.workout.value?.name ?? 'Unknown Workout';
    final date = DateFormat('EEEE, d MMMM y').format(_session.start);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workoutName,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChip(
              Icon(MingCute.barbell_line, size: 16, color: AppColors.accent),
              'Session',
            ),
            if (!_session.needSync)
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

  Widget _buildChip(Icon icon, String name, {EdgeInsets? padding}) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor),
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final duration = _session.end != null
        ? _session.end!.difference(_session.start)
        : Duration.zero;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Iconsax.timer_1_bold,
            value: _formatDuration(duration),
            label: 'Duration',
            color: Colors.blue,
          ),
          Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
          _buildStatItem(
            icon: Iconsax.clock_bold,
            value: DateFormat('HH:mm').format(_session.start),
            label: 'Start',
            color: Colors.green,
          ),
          Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
          _buildStatItem(
            icon: Iconsax.clock_bold,
            value: _session.end != null
                ? DateFormat('HH:mm').format(_session.end!)
                : '-',
            label: 'End',
            color: Colors.orange,
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    final sessionRepo = context.read<SessionRepository>();

    return StreamBuilder<List<SessionExercise>>(
      stream: sessionRepo.watchSessionExercises(_session.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exercises = snapshot.data!;
        if (exercises.isEmpty) {
          return Text(
            "No exercises recorded.",
            style: GoogleFonts.poppins(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
              itemCount: exercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _SessionExerciseCard(
                  sessionExercise: exercises[index],
                  onEditSet: (set) => _showEditSetDialog(context, set),
                  onEditExercise: () =>
                      _showEditExerciseDialog(context, exercises[index]),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditExerciseDialog(
    BuildContext context,
    SessionExercise exercise,
  ) async {
    final sessionRepo = context.read<SessionRepository>();
    final nameController = TextEditingController(text: exercise.exerciseName);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Exercise',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SecondaryButton(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Exercise?'),
                            content: Text(
                              'This will delete the exercise and all its sets from this session. This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await sessionRepo.deleteSessionExercise(exercise);

                          if (context.mounted) {
                            Navigator.pop(context);
                            Toast(
                              context,
                            ).success(content: Text('Exercise deleted'));
                          }
                        }
                      },
                      child: Text(
                        'Delete',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    onTap: () async {
                      exercise.exerciseName = nameController.text;
                      await sessionRepo.updateSessionExercise(exercise);

                      if (context.mounted) {
                        Navigator.pop(context);
                        Toast(
                          context,
                        ).success(content: Text('Exercise updated'));
                      }
                    },
                    child: Text(
                      'Finish Exercise',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _showEditSessionDialog(BuildContext context) async {
    final sessionRepo = context.read<SessionRepository>();

    // Warning Dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Session Data'),
        content: Text(
          'Editing session data manually can lead to inconsistencies in your progress tracking. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    if (!mounted) return;

    DateTime start = _session.start;
    DateTime? end = _session.end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Session Time',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTimePicker(
                  context,
                  'Start Time',
                  start,
                  (newTime) => setState(() => start = newTime),
                ),
                const SizedBox(height: 16),
                _buildTimePicker(
                  context,
                  'End Time',
                  end ?? DateTime.now(),
                  (newTime) => setState(() => end = newTime),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onTap: () async {
                    _session.start = start;
                    _session.end = end;
                    await sessionRepo.updateSession(_session);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Toast(context).success(content: Text('Session updated'));
                    }
                  },
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    DateTime time,
    ValueChanged<DateTime> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 16)),
        TextButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: time,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null && context.mounted) {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(time),
              );
              if (pickedTime != null) {
                onChanged(
                  DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  ),
                );
              }
            }
          },
          child: Text(
            DateFormat('MMM d, HH:mm').format(time),
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditSetDialog(BuildContext context, SessionSet set) async {
    final sessionRepo = context.read<SessionRepository>();

    // Warning Dialog
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Set Data'),
        content: Text(
          'Editing set data manually can lead to inconsistencies in your progress tracking. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Proceed', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    if (!mounted) return;

    final weightController = TextEditingController(text: set.weight.toString());
    final repsController = TextEditingController(text: set.reps.toString());
    final rpeController = TextEditingController(
      text: set.effortRate.toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Set',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rpeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'RPE (1-10)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onTap: () async {
                final weight =
                    double.tryParse(weightController.text) ?? set.weight;
                final reps = int.tryParse(repsController.text) ?? set.reps;
                final rpe = int.tryParse(rpeController.text) ?? set.effortRate;

                set.weight = weight;
                set.reps = reps;
                set.effortRate = rpe;

                await sessionRepo.updateSessionSet(set);

                if (context.mounted) {
                  Navigator.pop(context);
                  Toast(context).success(content: Text('Set updated'));
                }
              },
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionExerciseCard extends StatelessWidget {
  final SessionExercise sessionExercise;
  final Function(SessionSet) onEditSet;
  final VoidCallback onEditExercise;

  const _SessionExerciseCard({
    required this.sessionExercise,
    required this.onEditSet,
    required this.onEditExercise,
  });

  @override
  Widget build(BuildContext context) {
    final sessionRepo = context.read<SessionRepository>();

    return AppContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: getImage(
                    sessionExercise.exercise.value?.thumbnail,
                    pendingPath:
                        sessionExercise.exercise.value?.pendingThumbnailPath,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sessionExercise.exerciseName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEditExercise,
                  icon: Icon(
                    Iconsax.edit_2_outline,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<SessionSet>>(
              stream: sessionRepo.watchSessionSets(sessionExercise.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final sets = snapshot.data!;
                return Column(
                  children: sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;
                    return InkWell(
                      onTap: () => onEditSet(set),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${set.weight}kg x ${set.reps}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (set.effortRate > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
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
                                    fontSize: 12,
                                    color: _getRpeColor(set.effortRate),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              Iconsax.edit_2_outline,
                              size: 16,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRpeColor(int effortRate) {
    if (effortRate < 7) return Colors.green;
    if (effortRate < 9) return Colors.orange;
    return Colors.red;
  }
}
