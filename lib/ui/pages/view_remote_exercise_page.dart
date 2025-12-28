import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/services/pocketbase_service.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/ui/components/confirm_dialog.dart';
import 'package:tracks/ui/components/modal_padding.dart';
import 'package:tracks/ui/pages/exercises_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/toast.dart';

class RemoteExerciseMuscle {
  final Muscle muscle;
  final int activation;

  RemoteExerciseMuscle({required this.muscle, required this.activation});
}

class ViewRemoteExercisePage extends StatefulWidget {
  final String exerciseId;

  const ViewRemoteExercisePage({super.key, required this.exerciseId});

  @override
  State<ViewRemoteExercisePage> createState() => _ViewRemoteExercisePageState();
}

class _ViewRemoteExercisePageState extends State<ViewRemoteExercisePage> {
  final pb = PocketBaseService.instance.client;
  Exercise? _exercise;
  List<RemoteExerciseMuscle> _muscles = [];
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
      final exerciseRecord = await pb.collection('exercises').getOne(widget.exerciseId);
      final exercise = Exercise.fromRecord(exerciseRecord);

      final result = await pb
          .collection('exercise_muscles')
          .getList(
            filter: 'exercise = "${widget.exerciseId}"',
            expand: 'muscle',
          );

      final List<RemoteExerciseMuscle> items = [];
      for (final record in result.items) {
        final muscles = record.expand['muscle'];
        final muscleRecord = (muscles != null && muscles.isNotEmpty) ? muscles.first : null;
        if (muscleRecord != null) {
          final getUrl = PocketBaseService.instance.client.files.getURL;
          final muscle = Muscle.fromRecord(
            muscleRecord,
            (thumb) => getUrl(muscleRecord, thumb).toString(),
          );
          items.add(
            RemoteExerciseMuscle(
              muscle: muscle,
              activation: record.data['activation'] ?? 0,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _exercise = exercise;
          _muscles = items;
          _authorId = exerciseRecord.data['user'];
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

  Future<void> _copyExercise() async {
    if (_exercise == null) return;

    final confirm = await showModalBottomSheet(
      context: context,
      builder: (context) => ModalPadding(
        child: ConfirmDialog(
          itemName: _exercise!.name,
          confirmType: ConfirmType.action,
          entityType: 'Exercise',
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isCopying = true);
    try {
      final exerciseRepo = context.read<ExerciseRepository>();
      final muscleRepo = context.read<MuscleRepository>();

      // Check if already exists
      final existing = await exerciseRepo.collection
          .filter()
          .fromPocketBaseIdEqualTo(_exercise!.pocketbaseId)
          .findFirst();
      if (existing != null && mounted) {
        Toast(context).neutral(content: Text("Exercise already in library"));
        setState(() => _isCopying = false);
        return;
      }

      // Create local exercise object
      final newExercise = Exercise(
        name: _exercise!.name,
        description: _exercise!.description,
        thumbnail: _exercise!.thumbnail,
        caloriesBurned: _exercise!.caloriesBurned,
        needSync: true,
      )..fromPocketBaseId = _exercise!.pocketbaseId;

      // Prepare muscles
      List<MuscleActivationParam> musclesToLink = [];

      for (final rm in _muscles) {
        final remoteMuscle = rm.muscle;

        // Check if local muscle exists
        var localMuscle = await muscleRepo.collection
            .filter()
            .fromPocketBaseIdEqualTo(remoteMuscle.pocketbaseId)
            .findFirst();

        if (localMuscle == null) {
          // Create local muscle
          localMuscle = Muscle(
            name: remoteMuscle.name,
            description: remoteMuscle.description,
            needSync: true,
          )
            ..fromPocketBaseId = remoteMuscle.pocketbaseId
            ..thumbnails = remoteMuscle.thumbnails;

          await muscleRepo.isar.writeTxn(() async {
            await muscleRepo.collection.put(localMuscle!);
          });
        }

        musclesToLink.add(
          MuscleActivationParam(muscle: localMuscle, activation: rm.activation),
        );
      }

      await exerciseRepo.createExercise(
        exercise: newExercise,
        muscles: musclesToLink,
      );

      if (mounted) {
        Toast(context).success(content: Text("Exercise copied to library"));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExercisesPage()),
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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_exercise == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("Failed to load exercise")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                    Text(
                      _exercise!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_exercise!.description != null)
                      Text(
                        _exercise!.description!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 32),
                    _buildMusclesList(),
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
                  onTap: _isCopying ? null : _copyExercise,
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
      flexibleSpace: FlexibleSpaceBar(
        background: getSafeImage(
          _exercise!.thumbnail ?? '',
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildMusclesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_muscles.isEmpty) {
      return const SizedBox.shrink();
    }

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
          spacing: 8,
          runSpacing: 8,
          children: _muscles
              .map(
                (m) => Chip(
                  label: Text(m.muscle.name),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
