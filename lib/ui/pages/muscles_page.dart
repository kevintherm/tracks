import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/muscle_repository.dart';
import 'package:tracks/ui/components/app_container.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/pages/view_muscle_page.dart';
import 'package:tracks/utils/consts.dart';
import 'package:tracks/utils/fuzzy_search.dart';

class MusclesPage extends StatefulWidget {
  const MusclesPage({super.key});

  @override
  State<MusclesPage> createState() => _MusclesPageState();
}

class _MusclesPageState extends State<MusclesPage> {
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
    final muscleRepo = context.read<MuscleRepository>();

    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MusclesAppBar(),

              _SearchBar(controller: searchController),

              Expanded(
                child: StreamBuilder<List<Muscle>>(
                  stream: muscleRepo.watchAllMuscles(),
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

                    final List<Muscle> muscles = snapshot.data ?? [];
                    List<Muscle> filtered = muscles;

                    if (search.isNotEmpty) {
                      filtered = FuzzySearch.search(
                        items: muscles,
                        query: search,
                        getSearchableText: (e) => e.name,
                        threshold: 0.1,
                      );
                    } else {
                      filtered = muscles.toList()
                        ..sort((a, b) => a.name.compareTo(b.name));
                    }

                    if (muscles.isEmpty) {
                      return Center(
                        child: Text(
                          "No muscles available.",
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
                          "No matching muscles found.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return _MusclesList(muscles: filtered);
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

class _MusclesAppBar extends StatelessWidget {
  const _MusclesAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BackButton(),
          Text(
            "Muscles",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
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

class _MusclesList extends StatelessWidget {
  final List<Muscle> muscles;

  const _MusclesList({required this.muscles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ListView.separated(
        itemCount: muscles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final muscle = muscles[index];
          return _MuscleListItem(muscle: muscle);
        },
      ),
    );
  }
}

class _MuscleListItem extends StatelessWidget {
  final Muscle muscle;

  const _MuscleListItem({required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewMusclePage(muscle: muscle),
          ),
        );
      },
      child: _MuscleCard(muscle: muscle),
    );
  }
}

class _MuscleCard extends StatelessWidget {
  final Muscle muscle;

  const _MuscleCard({required this.muscle});

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Hero(
              tag: 'muscle-${muscle.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: getImage(muscle.thumbnail, width: 60, height: 60),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    muscle.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (muscle.description != null && muscle.description!.isNotEmpty)
                    Text(
                      muscle.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
