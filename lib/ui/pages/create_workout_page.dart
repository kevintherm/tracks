import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:tracks/models/exercise.dart';
import 'package:tracks/models/workout.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/workout_repository.dart';
import 'package:tracks/ui/components/ai_recommendation.dart';
import 'package:tracks/ui/components/blur_away.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';
import 'package:tracks/ui/components/select_config/config_section.dart';
import 'package:tracks/ui/components/select_config/list_item.dart';
import 'package:tracks/ui/components/select_config/select_config.dart';
import 'package:tracks/ui/components/section_card.dart';
import 'package:tracks/ui/components/select_config/select_config_option.dart';
import 'package:tracks/utils/app_colors.dart';
import 'package:tracks/utils/toast.dart';

class CreateWorkoutPage extends StatefulWidget {
  final Workout? workout;

  const CreateWorkoutPage({super.key, this.workout});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  XFile? _thumbnailImage;
  bool _thumbnailRemoved = false;

  final List<SelectConfigOption> _selectedOptions = [];
  final Map<String, WorkoutConfig> _exerciseConfigs = {};

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _nameController.text = widget.workout!.name;
      _descriptionController.text = widget.workout!.description ?? '';
      _loadExistingMuscles(widget.workout!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMuscles(Workout workout) async {
    try {
      final workoutExercises = workout.exercisesWithPivot;

      for (final entry in workoutExercises) {
        final exercise = entry.exercise;

        final exerciseOption = SelectConfigOption(
          id: exercise.id.toString(),
          label: exercise.name,
          subtitle: exercise.description,
          imagePath: exercise.thumbnailLocal,
        );

        // Apply to selected options
        if (!_selectedOptions.any((opt) => opt.id == exerciseOption.id)) {
          setState(() {
            _selectedOptions.add(exerciseOption);
            _exerciseConfigs[exerciseOption.id] = WorkoutConfig(
              reps: entry.reps,
              sets: entry.sets,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Toast(context).error(content: Text("Failed to load muscles: $e"));
      }
    }
  }

  Future<void> _pickThumbnailImage() async {
    final toast = Toast(context);

    final ImageSource? source = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _thumbnailImage = image;
          _thumbnailRemoved = false;
        });
      }
    } catch (e) {
      toast.error(content: Text("Failed to pick image: $e"));
    }
  }

  void _removeThumbnailImage() {
    setState(() {
      _thumbnailImage = null;
      _thumbnailRemoved = true;
    });
  }

  void _toggleExerciseSelection(SelectConfigOption option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedOptions.contains(option)) {
          _selectedOptions.add(option);
          _exerciseConfigs[option.id] = WorkoutConfig(reps: 8, sets: 3);
        }
      } else {
        _selectedOptions.remove(option);
        _exerciseConfigs.remove(option.id);
      }
    });
  }

  void _updateConfigSets(String exerciseId, int sets) {
    _exerciseConfigs[exerciseId]!.sets = sets;
  }

  void _updateConfigReps(String exerciseId, int reps) {
    _exerciseConfigs[exerciseId]!.reps = reps;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _selectedOptions.removeAt(oldIndex);
      _selectedOptions.insert(newIndex, item);
    });
  }

  void _removeSelectedExercise(int index) {
    setState(() {
      final option = _selectedOptions[index];
      _selectedOptions.removeAt(index);
      _exerciseConfigs.remove(option.id);
    });
  }

  Future<List<WorkoutConfigParam>> _getConfigParams() async {
    final exerciseRepo = context.read<ExerciseRepository>();

    final selectedExercises = <WorkoutConfigParam>[];
    for (final opt in _selectedOptions) {
      final exerciseId = int.parse(opt.id);
      final exercise = await exerciseRepo.collection.get(exerciseId);
      if (exercise != null) {
        selectedExercises.add(
          WorkoutConfigParam(
            exercise: exercise,
            reps: _exerciseConfigs[opt.id]?.reps ?? 3,
            sets: _exerciseConfigs[opt.id]?.sets ?? 8,
          ),
        );
      }
    }

    return selectedExercises;
  }

  Future<void> _saveExercise() async {
    final toast = Toast(context);
    final nav = Navigator.of(context);

    if (_nameController.text.trim().isEmpty) {
      toast.error(content: const Text("Please enter a name"));
      return;
    }

    final workoutRepo = context.read<WorkoutRepository>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    try {
      if (widget.workout != null) {
        String? thumbnailPath;
        if (_thumbnailImage != null) {
          thumbnailPath = _thumbnailImage!.path;
        } else if (_thumbnailRemoved) {
          thumbnailPath = null;
        } else {
          thumbnailPath = widget.workout!.thumbnailLocal;
        }

        final updatedWorkout = Workout(
          name: name,
          description: description,
          thumbnailLocal: thumbnailPath,
          thumbnailCloud: widget.workout!.thumbnailCloud,
          pocketbaseId: widget.workout!.pocketbaseId,
          needSync: widget.workout!.needSync,
        )..id = widget.workout!.id;

        final selectedExercises = await _getConfigParams();

        await workoutRepo.updateWorkout(
          workout: updatedWorkout,
          exercises: selectedExercises,
        );

        toast.success(content: const Text("Exercise updated!"));
      } else {
        // Create New

        final newWorkout = Workout(
          name: name,
          description: description,
          thumbnailLocal: _thumbnailImage?.path,
        );

        final selectedExercises = await _getConfigParams();

        await workoutRepo.createWorkout(
          workout: newWorkout,
          exercises: selectedExercises,
        );

        toast.success(content: const Text("Exercise created!"));
      }

      nav.pop(true);
    } catch (e) {
      toast.error(content: Text("Failed to save exercise: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();

    return BlurAway(
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<List<Exercise>>(
            stream: exerciseRepo.watchAllExercises(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allItems = snapshot.data!
                  .map(
                    (exercise) => SelectConfigOption(
                      id: exercise.id.toString(),
                      label: exercise.name,
                      subtitle: exercise.description,
                      imagePath: exercise.thumbnailLocal,
                    ),
                  )
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Pressable(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Iconsax.arrow_left_2_outline,
                              size: 24,
                            ),
                          ),
                          Text(
                            widget.workout != null
                                ? "Edit Workout"
                                : "Create Workout",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Pressable(
                            onTap: _saveExercise,
                            child: const Icon(
                              Iconsax.tick_square_outline,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Thumbnail Section
                    _ThumbnailSection(
                      thumbnailImage: _thumbnailImage,
                      existingThumbnailPath: widget.workout?.thumbnailLocal,
                      thumbnailRemoved: _thumbnailRemoved,
                      onPickImage: _pickThumbnailImage,
                      onRemoveImage: _removeThumbnailImage,
                    ),

                    // Details Section
                    SectionCard(
                      title: "Workout Details",
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
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
                    ),

                    // Config Section
                    SectionCard(
                      title: "Select Exercises",
                      child: SelectConfig<SelectConfigOption>(
                        allOptions: allItems,
                        selectedOptions: _selectedOptions,
                        onToggle: _toggleExerciseSelection,
                        getLabel: (option) => option.label,
                        getId: (option) => option.id,
                        itemBuilder: (option, isSelected, onChanged) {
                          return ListItem(
                            id: option.id,
                            label: option.label,
                            isSelected: isSelected,
                            onChanged: onChanged,
                            imagePath: option.imagePath,
                            subtitle: option.subtitle,
                          );
                        },
                        aiRecommendation: AiRecommendation(
                          onUse: () {},
                          buttonText: "Use",
                        ),
                      ),
                    ),

                    if (_selectedOptions.isNotEmpty)
                      SectionCard(
                        title:
                            "Configure Exercises (${_selectedOptions.length})",
                        child: ConfigSection<SelectConfigOption, WorkoutConfig>(
                          selectedOptions: _selectedOptions,
                          configurations: _exerciseConfigs,
                          onReorder: _onReorder,
                          onDelete: _removeSelectedExercise,
                          getId: (option) => option.id,
                          getLabel: (option) => option.label,
                          defaultConfig: () => WorkoutConfig(reps: 8, sets: 3),
                          scrollController: _scrollController,
                          enableReordering: true,
                          enableReorderAnimation: true,
                          showReorderToast: true,
                          autoScrollToReorderedItem: true,
                          itemBuilder:
                              (
                                option,
                                index,
                                config,
                                onReorderTap,
                                onDeleteTap,
                              ) {
                                return _ConfigurableExerciseCard(
                                  key: ValueKey(option.id),
                                  option: option,
                                  order: index + 1,
                                  dragIndex: index,
                                  config: config,
                                  onSetsChanged: (value) =>
                                      _updateConfigSets(option.id, value),
                                  onRepsChanged: (value) =>
                                      _updateConfigReps(option.id, value),
                                  onReorderTap: onReorderTap,
                                  onDeleteTap: onDeleteTap,
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
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Thumbnail Section Widget
class _ThumbnailSection extends StatelessWidget {
  final XFile? thumbnailImage;
  final String? existingThumbnailPath;
  final bool thumbnailRemoved;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _ThumbnailSection({
    required this.thumbnailImage,
    this.existingThumbnailPath,
    this.thumbnailRemoved = false,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.secondary;

    return SectionCard(
      title: "Thumbnail",
      child: thumbnailImage != null
          ? _buildImagePreview(thumbnailImage!)
          : (existingThumbnailPath != null && !thumbnailRemoved)
          ? _buildExistingImagePreview(existingThumbnailPath!)
          : _buildUploadArea(color),
    );
  }

  Widget _buildExistingImagePreview(String imagePath) {
    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder<Uint8List>(
        future: File(imagePath).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_slash_outline,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        onRemoveImage();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.trash_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        onPickImage();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.camera_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(XFile image) {
    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder<Uint8List>(
        future: image.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_slash_outline,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        onRemoveImage();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.trash_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        onPickImage();
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Iconsax.edit_2_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUploadArea(Color color) {
    return InkWell(
      onTap: onPickImage,
      borderRadius: BorderRadius.circular(16),
      child: DottedBorder(
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
              const SizedBox(height: 4),
              Text(
                "Tap to select an image",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Configurable Exercise Card
class _ConfigurableExerciseCard extends StatefulWidget {
  final SelectConfigOption option;
  final int order;
  final int dragIndex;
  final WorkoutConfig config;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback? onReorderTap;
  final VoidCallback? onDeleteTap;

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.order,
    required this.dragIndex,
    required this.config,
    required this.onSetsChanged,
    required this.onRepsChanged,
    this.onReorderTap,
    this.onDeleteTap,
  });

  @override
  State<_ConfigurableExerciseCard> createState() =>
      _ConfigurableExerciseCardState();
}

class _ConfigurableExerciseCardState extends State<_ConfigurableExerciseCard> {
  late int _sets;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _sets = widget.config.sets;
    _reps = widget.config.reps;
  }

  @override
  void didUpdateWidget(covariant _ConfigurableExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync if parent updates externally
    if (oldWidget.config.sets != widget.config.sets) {
      _sets = widget.config.sets;
    }
    if (oldWidget.config.reps != widget.config.reps) {
      _reps = widget.config.reps;
    }
  }

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
                  _buildMuscleImage(
                    widget.option.imagePath ?? 'assets/drawings/not-found.jpg',
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
                                widget.option.label,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (widget.onDeleteTap != null)
                              Pressable(
                                onTap: widget.onDeleteTap,
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
                              onTap: widget.onReorderTap,
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
                                  widget.order.toString(),
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
                          widget.option.subtitle ?? '',
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
                    child: _buildPicker(
                      label: "Sets",
                      value: _sets,
                      onChanged: (v) {
                        setState(() => _sets = v);
                        widget.onSetsChanged(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPicker(
                      label: "Reps",
                      value: _reps,
                      onChanged: (v) {
                        setState(() => _reps = v);
                        widget.onRepsChanged(v);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
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
              value: value,
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
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleImage(String imagePath) {
    if (imagePath.startsWith('/') || imagePath.contains('app_flutter')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/drawings/not-found.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              );
            },
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/drawings/not-found.jpg',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
