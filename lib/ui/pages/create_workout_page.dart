import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/buttons/primary_button.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

// --- Models (for Type Safety) ---

class ExerciseOption {
  final String id;
  final String label;

  ExerciseOption({required this.id, required this.label});

  // Add equals and hashCode for proper list comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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
    ExerciseOption(label: 'Apple', id: '123'),
    ExerciseOption(label: 'Banana', id: '1234'),
    ExerciseOption(label: 'Mango', id: '12345'),
    ExerciseOption(label: 'Cherry', id: '123451'),
    ExerciseOption(label: 'Pier', id: '123452'),
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
      if (newIndex > oldIndex) newIndex--;
      final item = _selectedOptions.removeAt(oldIndex);
      _selectedOptions.insert(newIndex, item);
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
              _ExerciseSelectionSection(
                allOptions: _allExercises,
                selectedOptions: _selectedOptions,
                onToggle: _toggleExerciseSelection,
              ),

              // Exercise Configuration Section
              if (_selectedOptions.isNotEmpty)
                _ExerciseConfigurationSection(
                  selectedOptions: _selectedOptions,
                  exerciseConfigs: _exerciseConfigs,
                  onReorder: _onReorder,
                  onUpdateConfig: _updateExerciseConfig,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Card Widget ---

const List<BoxShadow> _kCardShadow = [
  BoxShadow(
    color: Color(0xFFE0E0E0), // Colors.grey[300]!
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
  BoxShadow(
    color: Color(0xFFF5F5F5), // Colors.grey[200]!
    offset: Offset(0, -2),
    blurRadius: 10,
  ),
];

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.white,
          boxShadow: _kCardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
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

    return _CardSection(
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
    return _CardSection(
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

const OutlineInputBorder _kSearchBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(32)),
  borderSide: BorderSide.none,
);

// --- Exercise Selection Section (Checkboxes) ---
class _ExerciseSelectionSection extends StatefulWidget {
  final List<ExerciseOption> allOptions;
  final List<ExerciseOption> selectedOptions;
  final void Function(ExerciseOption, bool) onToggle;

  const _ExerciseSelectionSection({
    required this.allOptions,
    required this.selectedOptions,
    required this.onToggle,
  });

  @override
  State<_ExerciseSelectionSection> createState() =>
      _ExerciseSelectionSectionState();
}

class _ExerciseSelectionSectionState extends State<_ExerciseSelectionSection> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.allOptions.where((option) {
      return option.label.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return _CardSection(
      title: "Select Exercises",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: const Icon(Iconsax.search_normal_1_outline, size: 20),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: _kSearchBorder,
              enabledBorder: _kSearchBorder,
              focusedBorder: _kSearchBorder,
            ),
          ),
          const SizedBox(height: 16),

          // AI Recommendation
          _AiRecommendation(),
          const SizedBox(height: 16),

          // Exercise List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOptions.length,
            itemBuilder: (context, index) {
              final option = filteredOptions[index];
              final isSelected = widget.selectedOptions.contains(option);

              return _ExerciseCheckboxItem(
                key: ValueKey(option.id),
                option: option,
                isSelected: isSelected,
                onChanged: (value) => widget.onToggle(option, value ?? false),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Simple Checkbox Item ---
class _ExerciseCheckboxItem extends StatelessWidget {
  final ExerciseOption option;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _ExerciseCheckboxItem({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
        border: Border.all(
          color: isSelected ? AppColors.secondary : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/drawings/pushup.jpg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Average of 8 sets per week",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Exercise Configuration Section ---
class _ExerciseConfigurationSection extends StatelessWidget {
  final List<ExerciseOption> selectedOptions;
  final Map<String, ExerciseConfig> exerciseConfigs;
  final void Function(int, int) onReorder;
  final void Function(String, int, int) onUpdateConfig;

  const _ExerciseConfigurationSection({
    required this.selectedOptions,
    required this.exerciseConfigs,
    required this.onReorder,
    required this.onUpdateConfig,
  });

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: "Configure Exercises (${selectedOptions.length})",
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        onReorder: onReorder,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedOptions.length,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final option = selectedOptions[index];
          final config = exerciseConfigs[option.id] ?? ExerciseConfig();

          return _ConfigurableExerciseCard(
            key: ValueKey(option.id),
            option: option,
            order: index + 1,
            dragIndex: index,
            sets: config.sets,
            reps: config.reps,
            onSetsChanged: (value) =>
                onUpdateConfig(option.id, value, config.reps),
            onRepsChanged: (value) =>
                onUpdateConfig(option.id, config.sets, value),
          );
        },
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

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.order,
    required this.dragIndex,
    required this.sets,
    required this.reps,
    required this.onSetsChanged,
    required this.onRepsChanged,
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
                ReorderableDragStartListener(
                  index: dragIndex,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Iconsax.sort_outline,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.label,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DottedBorder(
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
    );
  }
}

class _AiRecommendation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ai-weight.svg',
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Try recommendation!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            PrimaryButton(
              onTap: () {},
              child: Text(
                "Use!",
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Exercise'),
          content: const Text('Are you sure you want to remove this exercise?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        ),
      ) ??
      false;
}
