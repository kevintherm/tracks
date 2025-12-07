import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/create_exercise_page.dart';
import 'package:tracks/ui/pages/view_exercise_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';
import 'package:tracks/utils/toast.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final searchController = TextEditingController();
  String search = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          search = searchController.text;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();

    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ExercisesAppBar(),

              _SearchBar(controller: searchController),

              Expanded(
                child: StreamBuilder<List<Exercise>>(
                  stream: exerciseRepo.watchAllExercises(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Something went wrong: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final List<Exercise> exercises = snapshot.data ?? [];
                    List<Exercise> filtered = exercises;

                    if (search.isNotEmpty) {
                      filtered = FuzzySearch.search(
                        items: exercises,
                        query: search,
                        getSearchableText: (e) => e.name,
                        threshold: 0.1,
                      );
                    } else {
                      filtered = exercises.toList()
                        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                    }

                    if (exercises.isEmpty) {
                      return Center(
                        child: Text(
                          "No exercise available.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          "No matching exercise found.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return _ExercisesList(exercises: filtered);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercisesAppBar extends StatelessWidget {
  const _ExercisesAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BackButton(),
          Text(
            "Exercises",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          _ActionButtons(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: "Back",
          child: Pressable(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Iconsax.arrow_left_2_outline, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: "Import Exercises",
          child: Pressable(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const Placeholder(child: Text("Import Exercises")),
                ),
              );
            },
            child: const Icon(Iconsax.import_1_outline, size: 28),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Create New Exercise',
          child: Pressable(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateExercisePage(),
                ),
              );
            },
            child: const Icon(Iconsax.add_outline, size: 32),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 250),
                    child: Text(
                      'Searching for `${controller.text}`',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Pressable(
                    onTap: () {
                      controller.text = "";
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
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

class _ExercisesList extends StatelessWidget {
  final List<Exercise> exercises;

  const _ExercisesList({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ListView.separated(
        itemCount: exercises.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return _ExerciseListItem(exercise: exercise);
        },
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseListItem({required this.exercise});

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final exerciseRepo = context.read<ExerciseRepository>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return _ConfirmDeleteDialog(exercise: exercise);
      },
    );

    if (confirmed == true) {
      await exerciseRepo.deleteExercise(exercise);
      if (context.mounted) {
        Toast(context).success(content: const Text("Exercise deleted"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(exercise.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (exercise.public) {
          Toast(context).neutral(
            content: Text("Cannot modify or delete public exercises."),
            duration: Duration(milliseconds: 500),
          );
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          await _showDeleteConfirmation(context);
          return false;
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateExercisePage(exercise: exercise),
            ),
          );
          return false; // Don't dismiss
        }
      },
      background: _DismissBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green[200]!,
        icon: Icons.edit,
        padding: const EdgeInsets.only(left: 20),
      ),
      secondaryBackground: _DismissBackground(
        alignment: Alignment.centerRight,
        color: Colors.red[200]!,
        icon: Icons.delete,
        padding: const EdgeInsets.only(right: 20),
      ),
      child: Pressable(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewExercisePage(exercise: exercise),
            ),
          );
        },
        child: _ExerciseCard(exercise: exercise),
      ),
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.trash_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Delete Exercise?',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete "${exercise.name}"? This action cannot be undone.',
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
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final EdgeInsets padding;

  const _DismissBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({required this.exercise});

  String get muscleExcerpt {
    final muscles = List.of(exercise.musclesWithActivation)
      ..sort((a, b) => b.activation.compareTo(a.activation));

    return muscles.map((e) => e.muscle.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Hero(
                  tag: 'exercise-${exercise.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: getImage(exercise.thumbnail),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          _ExerciseStat(
                            icon: MingCute.fire_line,
                            label: "${exercise.caloriesBurned} Kkal",
                          ),
                          const SizedBox(width: 16),
                          _ExerciseStat(
                            icon: MingCute.refresh_3_line,
                            label: "0x",
                          ),
                        ],
                      ),
                      if (muscleExcerpt.isNotEmpty)
                        _ExerciseStat(
                          icon: MingCute.barbell_line,
                          label: muscleExcerpt,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _PublicBadge(isPublic: exercise.public),
        ],
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
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 175),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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

class _PublicBadge extends StatelessWidget {
  final bool isPublic;

  const _PublicBadge({required this.isPublic});

  @override
  Widget build(BuildContext context) {
    if (!isPublic) return const SizedBox.shrink();

    return Positioned(
      right: 32 + 10,
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Text(
          "Public",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
