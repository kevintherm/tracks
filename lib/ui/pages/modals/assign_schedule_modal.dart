import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:tracks/models/exercise_option.dart';
import 'package:tracks/ui/components/ai_recommendation.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/exercise_configuration_section.dart';
import 'package:tracks/ui/components/exercise_list_item.dart';
import 'package:tracks/ui/components/exercise_selection_section.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/ui/widgets/exercise_config_card.dart';
import 'package:tracks/utils/toast.dart';

class AssignScheduleModal extends StatefulWidget {
  const AssignScheduleModal({super.key, required this.selectedDay});

  final DateTime selectedDay;

  @override
  State<AssignScheduleModal> createState() => _AssignScheduleModalState();
}

class _AssignScheduleModalState extends State<AssignScheduleModal> {
  late final String selectedDayName;

  final Map<String, ExerciseConfig> exerciseConfigs = {};

  List<ExerciseOption> allOptions = [
    const ExerciseOption(label: 'Apple', id: '123'),
    const ExerciseOption(label: 'Banana', id: '1234'),
    const ExerciseOption(label: 'Mango', id: '12345'),
    const ExerciseOption(label: 'Cherry', id: '123451'),
    const ExerciseOption(label: 'Pier', id: '123452'),
  ];
  List<ExerciseOption> selectedOptions = [];

  void _toggleExerciseSelection(ExerciseOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!selectedOptions.contains(option)) {
          selectedOptions.add(option);
          exerciseConfigs[option.id] = ExerciseConfig();
        }
      } else {
        selectedOptions.remove(option);
        exerciseConfigs.remove(option.id);
      }
    });
  }

  void _updateExerciseConfig(String exerciseId, ExerciseConfig config) {
    setState(() {
      exerciseConfigs[exerciseId] = config;
    });
  }

  void _handleAiRecommendation() {
    // TODO: Implement AI recommendation logic
    Toast(context).success(content: const Text("AI Recommendation applied"));
  }

  void _saveSchedule() {
    // TODO: Implement save logic
    Toast(context).success(content: const Text("Saved"));
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    selectedDayName = DateFormat('EEEE').format(widget.selectedDay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Pressable(
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Iconsax.arrow_left_2_outline,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "Assign Schedule",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Pressable(
                      onTap: _saveSchedule,
                      child: const Icon(Iconsax.tick_square_outline, size: 24),
                    ),
                  ],
                ),
              ),

              SectionCard(
                title: "Selected Day",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE dd MMM, y').format(widget.selectedDay),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "(${selectedOptions.length})",
                      style: GoogleFonts.inter(fontSize: 16),
                    ),
                  ],
                ),
              ),

              SectionCard(
                title: "Workouts",
                child: ExerciseSelectionSection<ExerciseOption>(
                  allOptions: allOptions,
                  selectedOptions: selectedOptions,
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
                    onUse: _handleAiRecommendation,
                  ),
                ),
              ),

              SectionCard(
                title: "Configure Schedules (${selectedOptions.length})",
                child: (selectedOptions.isEmpty)
                    ? Text(
                        "No schedules selected.",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : ExerciseConfigurationSection<
                        ExerciseOption,
                        ExerciseConfig
                      >(
                        selectedOptions: selectedOptions,
                        configurations: exerciseConfigs,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = selectedOptions.removeAt(oldIndex);
                            selectedOptions.insert(newIndex, item);
                          });
                        },
                        getId: (option) => option.id,
                        defaultConfig: () => ExerciseConfig(),
                        itemBuilder: (option, index, config) {
                          return ExerciseConfigCard(
                            key: ValueKey(option.id),
                            exerciseId: option.id,
                            exerciseName: option.label,
                            index: index,
                            config: config,
                            selectedDayName: selectedDayName,
                            selectedDayNumber: widget.selectedDay.day,
                            onConfigChanged: (newConfig) =>
                                _updateExerciseConfig(option.id, newConfig),
                            imagePath: option.imagePath,
                            subtitle: option.subtitle,
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
