import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/create_exercise_page.dart';
import 'package:tracks/utils/toast.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ExercisesAppBar(),
            const _SearchBar(),
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

                  final exercises = snapshot.data ?? [];

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

                  return _ExercisesList(exercises: exercises);
                },
              ),
            ),
          ],
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
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
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
    );
  }
}

class _ExercisesList extends StatelessWidget {
  final List<Exercise> exercises;

  const _ExercisesList({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: exercises.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return _ExerciseListItem(index: exercise.id, exercise: exercise);
        },
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final int index;

  const _ExerciseListItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(index),
      direction: DismissDirection.horizontal,
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
      onDismissed: (direction) {
        final message = direction == DismissDirection.endToStart
            ? "Swipe left"
            : "Swipe right";
        Toast(context).success(content: Text(message));
      },
      child: Pressable(
        onTap: () {},
        child: _ExerciseCard(exercise: exercise),
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

  @override
  Widget build(BuildContext context) {
    final hasLocalImage =
        exercise.thumbnailPath != null &&
        File(exercise.thumbnailPath!).existsSync();
    final image = hasLocalImage
        ? Image.memory(
            File(exercise.thumbnailPath!).readAsBytesSync(),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          )
        : Image.asset(
            'assets/drawings/pushup.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: image,
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
                      _ExerciseStat(
                        icon: MingCute.barbell_line,
                        label: "Chest, Triceps, Shoulders",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ImportedBadge(isImported: exercise.imported),
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
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ImportedBadge extends StatelessWidget {
  final bool isImported;

  const _ImportedBadge({required this.isImported});

  @override
  Widget build(BuildContext context) {
    if (!isImported) return const SizedBox.shrink();

    return Positioned(
      right: 32 + 10,
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Text(
          "Imported",
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
