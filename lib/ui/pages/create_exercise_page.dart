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
import 'package:tracks/models/exercise_option.dart';
import 'package:tracks/models/muscle.dart';
import 'package:tracks/repositories/exercise_repository.dart';
import 'package:tracks/repositories/muscle_repository.dart';
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
  final Exercise? exercise; // Optional exercise for editing

  const CreateExercisePage({super.key, this.exercise});

  @override
  State<CreateExercisePage> createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  // Thumbnail image
  XFile? _thumbnailImage;
  bool _thumbnailRemoved = false; // Track if user explicitly removed thumbnail

  // Selected muscles and their configurations
  final List<ExerciseOption> _selectedOptions = [];
  final Map<String, ExerciseConfig> _exerciseConfigs = {};

  @override
  void initState() {
    super.initState();
    // If editing, populate the form
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _descriptionController.text = widget.exercise!.description ?? '';
      _caloriesController.text = widget.exercise!.caloriesBurned.toString();

      // Load existing thumbnail if available
      if (widget.exercise!.thumbnailLocal != null) {
        // Note: We'll need to handle this differently since XFile expects a path
        // For now, we'll just keep the path and handle it in the image preview
      }
      
      // Load existing muscle relationships
      _loadExistingMuscles();
    }
  }

  Future<void> _loadExistingMuscles() async {
    try {
      // Load the muscle links
      await widget.exercise!.muscles.load();
      final linkedMuscles = widget.exercise!.muscles.toList();
      
      // Convert to ExerciseOption and add to selected
      for (final muscle in linkedMuscles) {
        final muscleOption = ExerciseOption(
          id: muscle.id.toString(),
          label: muscle.name,
          subtitle: muscle.description,
          imagePath: muscle.thumbnailLocal ?? muscle.thumbnailCloud,
        );
        
        if (!_selectedOptions.any((opt) => opt.id == muscleOption.id)) {
          setState(() {
            _selectedOptions.add(muscleOption);
            // Initialize with default muscle activation of 50%
            _exerciseConfigs[muscleOption.id] = ExerciseConfig(
              muscleActivation: 50,
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

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // --- List Management Methods ---

  Future<void> _pickThumbnailImage() async {
    // Show dialog to choose between camera and gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Image Source',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera_outline),
                title: Text('Camera', style: GoogleFonts.inter()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery_outline),
                title: Text('Gallery', style: GoogleFonts.inter()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
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
          _thumbnailRemoved =
              false; // Reset removal flag when new image is picked
        });
      }
    } catch (e) {
      if (mounted) {
        Toast(context).error(content: Text("Failed to pick image: $e"));
      }
    }
  }

  void _removeThumbnailImage() {
    setState(() {
      _thumbnailImage = null;
      _thumbnailRemoved = true;
    });
  }

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

  void _removeSelectedMuscle(int index) {
    setState(() {
      final option = _selectedOptions[index];
      _selectedOptions.removeAt(index);
      _exerciseConfigs.remove(option.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseRepo = context.read<ExerciseRepository>();
    final muscleRepo = context.read<MuscleRepository>();

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Muscle>>(
          stream: muscleRepo.watchAllMuscles(),
          builder: (context, snapshot) {
            // Map muscles to ExerciseOption
            final allMuscles = snapshot.hasData
                ? snapshot.data!
                      .map(
                        (muscle) => ExerciseOption(
                          id: muscle.id.toString(),
                          label: muscle.name,
                          subtitle: muscle.description,
                          imagePath: muscle.thumbnailLocal
                        ),
                      )
                      .toList()
                : <ExerciseOption>[];

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _AppBar(
                    title: widget.exercise != null
                        ? "Edit Exercise"
                        : "Create Exercise",
                    onSave: () async {
                      final toast = Toast(context);
                      final nav = Navigator.of(context);

                      if (_nameController.text.trim().isEmpty) {
                        Toast(
                          context,
                        ).error(content: const Text("Please enter a name"));
                        return;
                      }

                      final calories =
                          double.tryParse(_caloriesController.text) ?? 0.0;
                      final name = _nameController.text.trim();
                      final description =
                          _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim();

                      if (widget.exercise != null) {
                        // Update existing exercise
                        String? thumbnailPath;
                        if (_thumbnailImage != null) {
                          // New image selected
                          thumbnailPath = _thumbnailImage!.path;
                        } else if (_thumbnailRemoved) {
                          // User explicitly removed the thumbnail
                          thumbnailPath = null;
                        } else {
                          // Keep existing thumbnail
                          thumbnailPath = widget.exercise!.thumbnailLocal;
                        }

                        final updatedExercise = Exercise(
                          name: name,
                          description: description,
                          caloriesBurned: calories,
                          thumbnailLocal: thumbnailPath,
                          thumbnailCloud: widget.exercise!.thumbnailCloud,
                          pocketbaseId: widget.exercise!.pocketbaseId,
                          needSync: widget.exercise!.needSync,
                          imported: widget.exercise!.imported,
                        )..id = widget.exercise!.id;

                        // Get selected muscle IDs and convert to Muscle objects
                        final selectedMuscleIds = _selectedOptions
                            .map((opt) => int.parse(opt.id))
                            .toList();
                        
                        await exerciseRepo.updateExercise(
                          updatedExercise,
                          muscleIds: selectedMuscleIds,
                        );
                        toast.success(content: const Text("Exercise updated!"));
                      } else {
                        // Create new exercise
                        final newExercise = Exercise(
                          name: name,
                          description: description,
                          caloriesBurned: calories,
                          thumbnailLocal: _thumbnailImage?.path,
                        );

                        // Get selected muscle IDs
                        final selectedMuscleIds = _selectedOptions
                            .map((opt) => int.parse(opt.id))
                            .toList();

                        await exerciseRepo.createExercise(
                          newExercise,
                          muscleIds: selectedMuscleIds,
                        );
                        toast.success(content: const Text("Exercise created!"));
                      }

                      nav.pop(true);
                    },
                  ),

                  _ThumbnailSection(
                    thumbnailImage: _thumbnailImage,
                    existingThumbnailPath: widget.exercise?.thumbnailLocal,
                    thumbnailRemoved: _thumbnailRemoved,
                    onPickImage: _pickThumbnailImage,
                    onRemoveImage: _removeThumbnailImage,
                  ),

                  _ExerciseDetailsSection(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    caloriesController: _caloriesController,
                  ),

                  SectionCard(
                    title: "Targeted Muscles",
                    child: ExerciseSelectionSection<ExerciseOption>(
                      allOptions: allMuscles,
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
                      title:
                          "Configure Activation (${_selectedOptions.length})",
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
                            onDelete: () => _removeSelectedMuscle(index),
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
    );
  }
}

// --- Extracted Page Sections ---

class _AppBar extends StatelessWidget {
  final VoidCallback onSave;
  final String title;

  const _AppBar({required this.onSave, this.title = "New Exercise"});

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
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Pressable(
            onTap: onSave,
            child: const Icon(Iconsax.tick_square_outline, size: 24),
          ),
        ],
      ),
    );
  }
}

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

class _ExerciseDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController caloriesController;

  const _ExerciseDetailsSection({
    required this.nameController,
    required this.descriptionController,
    required this.caloriesController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Exercise Details",
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
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
            controller: caloriesController,
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
  final VoidCallback? onDelete;

  const _ConfigurableExerciseCard({
    super.key,
    required this.option,
    required this.muscleActivation,
    required this.onActivationChanged,
    this.onDelete,
  });

  Widget _buildMuscleImage(String imagePath) {
    // Check if it's a local file path (starts with / or contains app_flutter)
    if (imagePath.startsWith('/') || imagePath.contains('app_flutter')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
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
        );
      }
    }
    
    // Use asset image
    return Image.asset(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image to display
    final String imagePath = option.imagePath ?? 'assets/drawings/not-found.jpg';
    
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
                  child: _buildMuscleImage(imagePath),
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
                          const SizedBox(width: 8),
                          if (onDelete != null)
                            Pressable(
                              onTap: onDelete,
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
