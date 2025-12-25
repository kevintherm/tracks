import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/exercise_muscles.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/create_muscle_page.dart';
import 'package:tracks/ui/pages/view_exercise_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class ViewMusclePage extends StatefulWidget {
  final Muscle muscle;
  final bool asModal;

  const ViewMusclePage({super.key, required this.muscle, this.asModal = false});

  @override
  State<ViewMusclePage> createState() => _ViewMusclePageState();
}

class _ViewMusclePageState extends State<ViewMusclePage> {
  late Muscle _muscle;

  @override
  void initState() {
    super.initState();
    _muscle = widget.muscle;
  }

  @override
  Widget build(BuildContext context) {
    final muscleRepo = context.read<MuscleRepository>();

    return StreamBuilder<Muscle?>(
      stream: muscleRepo.collection.watchObject(
        _muscle.id,
        fireImmediately: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _muscle = snapshot.data!;
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                fatalError,
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
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
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildExercisesSection(),
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

  Future<void> _showDeleteConfirmation() async {
    final musclerepo = context.read<MuscleRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) {
        return _ModalPadding(child: _ConfirmDeleteDialog(muscle: _muscle));
      },
    );

    if (confirmed == true) {
      await musclerepo.deleteMuscle(_muscle);

      if (!mounted) return;

      Toast(context).success(content: const Text("Muscle deleted."));
      Navigator.pop(context);
    }
  }

  void _openImagesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: CarouselSlider.builder(
              itemCount: _muscle.safeThumbnails.items.length,
              itemBuilder: (context, index, realIndex) {
                final image = _muscle.safeThumbnails.items[index];
                return GestureDetector(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(16),
                    child: _buildMuscleImage(
                      image,
                      pending: _muscle.safeThumbnails.pending,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                aspectRatio: 1 / 1,
                enlargeCenterPage: true,
                autoPlay: true,
                enableInfiniteScroll: false,
              ),
            ),
          ),
        );
      },
    );
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
              "View Muscle",
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
                        builder: (_) => ViewMusclePage(muscle: _muscle),
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
                                title: Text('Edit Muscle'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateMusclePage(muscle: _muscle),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Iconsax.trash_bold),
                                title: Text('Delete Muscle'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteConfirmation();
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
          tag: 'muscle-${_muscle.id}',
          child: Pressable(
            onTap: _muscle.safeThumbnails.items.isEmpty
                ? null
                : () => _openImagesDialog(),
            child: _buildMuscleImage(
              _muscle.safeThumbnails.items.isEmpty
                  ? ""
                  : _muscle.safeThumbnails.items.first,
              pending: _muscle.safeThumbnails.pending,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleImage(String imagePath, {bool pending = false}) {
    return getImage(
      pending ? null : imagePath,
      pendingPath: pending ? imagePath : null,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _muscle.name,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (_muscle.description == null || _muscle.description!.isEmpty) {
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
          _muscle.description!,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    final isar = Isar.getInstance()!;

    return StreamBuilder<List<ExerciseMuscles>>(
      stream: isar.exerciseMuscles
          .filter()
          .muscle((q) => q.idEqualTo(_muscle.id))
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final exerciseMuscles = snapshot.data!;
        if (exerciseMuscles.isEmpty) return const SizedBox.shrink();

        // Sort by activation
        exerciseMuscles.sort((a, b) => b.activation.compareTo(a.activation));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Targeted by Exercises',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exerciseMuscles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final em = exerciseMuscles[index];
                final exercise = em.exercise.value;

                if (exercise == null) return const SizedBox.shrink();

                return Pressable(
                  onTap: widget.asModal
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.9,
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
                  child: _ExerciseCard(
                    exercise: exercise,
                    activation: em.activation,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int activation;

  const _ExerciseCard({required this.exercise, required this.activation});

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
              child: _buildExerciseImage(),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getActivationColor(
                            activation,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Activation: $activation%',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getActivationColor(activation),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    return getImage(
      exercise.thumbnail,
      pendingPath: exercise.pendingThumbnailPath,
      width: 80,
      height: 80,
    );
  }

  Color _getActivationColor(int activation) {
    if (activation >= 80) return Colors.green;
    if (activation >= 50) return Colors.orange;
    return Colors.red;
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

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.muscle});

  final Muscle muscle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
        const SizedBox(height: 16),
        Text(
          'Delete Muscle?',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Are you sure you want to delete "${muscle.name}"? This action cannot be undone.',
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
