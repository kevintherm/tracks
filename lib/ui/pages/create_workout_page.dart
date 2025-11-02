import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/models/exercise_option.dart';
import 'package:tracks/ui/components/ai_recommendation.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/exercise_configuration_section.dart';
import 'package:tracks/ui/components/exercise_list_item.dart';
import 'package:tracks/ui/components/exercise_selection_section.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

// --- Models (for Type Safety) ---
class ExerciseConfig {
  int sets;
  int reps;

  ExerciseConfig({this.sets = 3, this.reps = 8});
}

// --- Page Widget ---

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  bool _useFirstExerciseThumbnail = false;
  final ScrollController _scrollController = ScrollController();

  // All available exercises in the system
  final List<ExerciseOption> _allExercises = [
    const ExerciseOption(label: 'Apple', id: '123'),
    const ExerciseOption(label: 'Banana', id: '1234'),
    const ExerciseOption(label: 'Mango', id: '12345'),
    const ExerciseOption(label: 'Cherry', id: '123451'),
    const ExerciseOption(label: 'Pier', id: '123452'),
  ];
  final List<ExerciseOption> _selectedOptions = [];
  final Map<String, ExerciseConfig> _exerciseConfigs = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- List Management Methods ---

  void _toggleExerciseSelection(ExerciseOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedOptions.contains(option)) {
          _selectedOptions.add(option);
          _exerciseConfigs[option.id] = ExerciseConfig();
        }
      } else {
        _selectedOptions.remove(option);
        _exerciseConfigs.remove(option.id);
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _selectedOptions.removeAt(oldIndex);
      _selectedOptions.insert(newIndex, item);
    });
  }

  void _onDelete(int index) {
    setState(() {
      final option = _selectedOptions[index];
      _selectedOptions.removeAt(index);
      _exerciseConfigs.remove(option.id);
    });
  }

  void _updateExerciseConfig(String exerciseId, int sets, int reps) {
    setState(() {
      _exerciseConfigs[exerciseId] = ExerciseConfig(sets: sets, reps: reps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Extracted AppBar
              _AppBar(),

              // Extracted Thumbnail Section
              _ThumbnailSection(
                useFirstExercise: _useFirstExerciseThumbnail,
                onChanged: (value) {
                  setState(() {
                    _useFirstExerciseThumbnail = value;
                  });
                },
              ),

              // Extracted Details Section
              _WorkoutDetailsSection(),

              // Exercise Selection Section
              SectionCard(
                title: "Select Exercises",
                child: ExerciseSelectionSection<ExerciseOption>(
                  allOptions: _allExercises,
                  selectedOptions: _selectedOptions,
                  onToggle: _toggleExerciseSelection,
                  getLabel: (option) => option.label,
                  getId: (option) => option.id,
                  itemBuilder: (option, isSelected, onChanged) {
                    return ExerciseListItem(
                      id: option.id,
                      label: option.label,
                      isSelected: isSelected,
                      onChanged: onChanged,
                      imagePath: option.imagePath,
                      subtitle: option.subtitle,
                    );
                  },
                  aiRecommendation: AiRecommendation(
                    onUse: () {
                      // TODO: Implement AI recommendation
                    },
                    buttonText: "Use!",
                  ),
                ),
              ),

              // Exercise Configuration Section
              if (_selectedOptions.isNotEmpty)
                SectionCard(
                  title: "Configure Exercises (${_selectedOptions.length})",
                  child:
                      ExerciseConfigurationSection<
                        ExerciseOption,
                        ExerciseConfig
                      >(
                        selectedOptions: _selectedOptions,
                        configurations: _exerciseConfigs,
                        onReorder: _onReorder,
                        onDelete: _onDelete,
                        getId: (option) => option.id,
                        getLabel: (option) => option.label,
                        defaultConfig: () => ExerciseConfig(),
                        scrollController: _scrollController,
                        enableReordering: true,
                        enableReorderAnimation: true,
                        showReorderToast: true,
                        autoScrollToReorderedItem: true,
                        itemBuilder: (option, index, config, onReorderTap, onDeleteTap) {
                          return _ConfigurableExerciseCard(
                            key: ValueKey(option.id),
                            option: option,
                            order: index + 1,
                            dragIndex: index,
                            sets: config.sets,
                            reps: config.reps,
                            onSetsChanged: (value) => _updateExerciseConfig(
                              option.id,
                              value,
                              config.reps,
                            ),
                            onRepsChanged: (value) => _updateExerciseConfig(
                              option.id,
                              config.sets,
                              value,
                            ),
                            onReorderTap: onReorderTap,
                            onDeleteTap: onDeleteTap,
                          );
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

// --- Extracted Page Sections ---

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Pressable(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Iconsax.arrow_left_2_outline, size: 24),
          ),
          Text(
            "New Workout",
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Pressable(
            onTap: () {
              Toast(context).success(content: Text("Saved"));
              Navigator.of(context).pop();
            },
            child: const Icon(Iconsax.tick_square_outline, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailSection extends StatelessWidget {
  final bool useFirstExercise;
  final ValueChanged<bool> onChanged;

  const _ThumbnailSection({
    required this.useFirstExercise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = useFirstExercise;
    final Color color = isDisabled ? Colors.grey : AppColors.secondary;

    return SectionCard(
      title: "Thumbnail",
      child: Column(
        children: [
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              dashPattern: const [10, 5],
              strokeWidth: 2,
              radius: const Radius.circular(16),
              color: color,
              padding: const EdgeInsets.all(16),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.document_upload_outline, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(
                    "Upload a thumbnail",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use First Exercise\'s'),
            value: useFirstExercise,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _WorkoutDetailsSection extends StatelessWidget {
  const _WorkoutDetailsSection();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Workout Details",
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Configurable Exercise Card ---
class _ConfigurableExerciseCard extends StatelessWidget {
  final ExerciseOption option;
  final int order;
  final int dragIndex;
  final int sets;
  final int reps;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback? onReorderTap;
  final VoidCallback? onDeleteTap;

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.order,
    required this.dragIndex,
    required this.sets,
    required this.reps,
    required this.onSetsChanged,
    required this.onRepsChanged,
    this.onReorderTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey[100],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/drawings/pushup.jpg',
                      width: 80,
                      height: 80,
                      cacheWidth: 160,
                      cacheHeight: 160,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                option.label,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (onDeleteTap != null)
                              Pressable(
                                onTap: onDeleteTap,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Iconsax.trash_outline,
                                    size: 18,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Pressable(
                              onTap: onReorderTap,
                              child: DottedBorder(
                                options: RoundedRectDottedBorderOptions(
                                  dashPattern: const [10, 5],
                                  strokeWidth: 2,
                                  radius: const Radius.circular(16),
                                  color: AppColors.darkSecondary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                ),
                                child: Text(
                                  order.toString(),
                                  style: GoogleFonts.inter(
                                    color: AppColors.darkSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Average of 8 sets per week",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

            // Sets and Reps Configuration
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Sets",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Center(
                          child: NumberPicker(
                            value: sets,
                            minValue: 1,
                            maxValue: 20,
                            haptics: false,
                            axis: Axis.horizontal,
                            itemWidth: 50,
                            itemHeight: 50,
                            textStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                            selectedTextStyle: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            onChanged: onSetsChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Reps",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Center(
                          child: NumberPicker(
                            value: reps,
                            minValue: 1,
                            maxValue: 20,
                            haptics: false,
                            axis: Axis.horizontal,
                            itemWidth: 50,
                            itemHeight: 50,
                            textStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                            selectedTextStyle: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            onChanged: onRepsChanged,
                          ),
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
    ),);
  }
}
