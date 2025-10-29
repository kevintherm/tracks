import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/models/exercise_option.dart';
import 'package:tracks/ui/components/ai_recommendation.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/exercise_list_item.dart';
import 'package:tracks/ui/components/exercise_selection_section.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

// --- Models (for Type Safety) ---
class ExerciseConfig {
  int muscleActivation;

  ExerciseConfig({this.muscleActivation = 30});
}

// --- Page Widget ---

class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  State<CreateExercisePage> createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final ScrollController _scrollController = ScrollController();

  // All available exercises in the system
  final List<ExerciseOption> _allMuscles = [
    const ExerciseOption(label: 'Long Head Bicep', id: '123'),
    const ExerciseOption(label: 'Short Head Bicep', id: '1234'),
    const ExerciseOption(label: 'Chest', id: '12345'),
    const ExerciseOption(label: 'Lats', id: '123451'),
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

  void _updateExerciseConfig(String exerciseId, int muscleActivation) {
    setState(() {
      _exerciseConfigs[exerciseId] = ExerciseConfig(
        muscleActivation: muscleActivation,
      );
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
              _AppBar(),

              _ThumbnailSection(
                onChanged: (value) {
                  setState(() {});
                },
              ),

              _ExerciseDetailsSection(),

              SectionCard(
                title: "Targeted Muscles",
                child: ExerciseSelectionSection<ExerciseOption>(
                  allOptions: _allMuscles,
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
                  title: "Configure Activation (${_selectedOptions.length})",
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedOptions.length,
                    itemBuilder: (context, index) {
                      final option = _selectedOptions[index];
                      final config =
                          _exerciseConfigs[option.id] ?? ExerciseConfig();

                      return _ConfigurableExerciseCard(
                        key: ValueKey(option.id),
                        option: option,
                        muscleActivation: config.muscleActivation,
                        onActivationChanged: (value) =>
                            _updateExerciseConfig(option.id, value),
                      );
                    },
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Looking for something else?",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Pressable(
                          onTap: () {},
                          child: Text(
                            "Create via Import (JSON)",
                            style: GoogleFonts.inter(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
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
            "New Exercise",
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
  final ValueChanged<bool> onChanged;

  const _ThumbnailSection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.secondary;

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
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailsSection extends StatelessWidget {
  const _ExerciseDetailsSection();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Exercise Details",
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
          const SizedBox(height: 16),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            decoration: InputDecoration(
              prefixIcon: Icon(MingCute.fire_line),
              labelText: 'Calories Burned (Kkal/Set)',
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
  final int muscleActivation;
  final ValueChanged<int> onActivationChanged;

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.muscleActivation,
    required this.onActivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
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

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Muscle Activation (EMG)",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(width: 32),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: NumberPicker(
                              step: 5,
                              value: muscleActivation,
                              minValue: 5,
                              maxValue: 100,
                              haptics: false,
                              axis: Axis.horizontal,
                              itemWidth: 60,
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
                              onChanged: onActivationChanged,
                            ),
                          ),
                          Icon(
                            Iconsax.percentage_square_outline,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
